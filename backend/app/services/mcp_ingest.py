# -*- coding: utf-8 -*-
"""
MCP 写入流水线编排：脱敏 → 去重 → raw layer → 按场景过滤 → staging（待人工审核）

只做编排，各环节复用现有模块：
- 脱敏：DataFilter.desensitize（与 staging 生成时同一个引擎）
- 写 raw：WeChatETL.save_message_batch
- 过滤 + 切块 + 写 staging：AdminService.preprocess_session（状态 pending）
- 文本规范：AdminService._finalize_block（与 staging 的 cleaned_text 同一套规则，用于去重比对）
新写的只有样本指纹去重。

写入内容一律当数据：不拼进任何 prompt，也不交给 LLM（关闭了 preprocess 的 LLM 质量打分）。
本模块不引用 LabeledConversation / publish_to_production，也不设置 approved 状态，
所以写入的数据只会停在 staging，等人工审核。
"""
import hashlib
import json
import time
import uuid
from collections import Counter
from typing import Any, Dict, List, Optional

from sqlalchemy.exc import IntegrityError

from app.models.chat import LabelStatus, RawChat, StagingConversation
from app.models.mcp_ingest import McpIngestBatch, McpIngestSample
from app.services.admin import AdminService
from app.services.etl import WeChatETL
from app.services.filter import get_data_filter

RAW_SOURCE_DB = "mcp"
STAGED, DEDUPLICATED, FILTERED = "staged", "deduplicated", "filtered"
# 库里的审核状态 → 对外的审核状态
REVIEW_STATUS = {
    LabelStatus.PENDING.value: "pending_review",
    LabelStatus.APPROVED.value: "approved",
    LabelStatus.REJECTED.value: "rejected",
    LabelStatus.MODIFIED.value: "edited",
}


class IngestConflict(Exception):
    """同一个 idempotency_key 提交了不同内容。"""


def source_tag(client_id: str) -> str:
    return f"mcp:{client_id}"


def request_hash(source: str, scenario: str, samples: List[Dict[str, Any]]) -> str:
    payload = json.dumps({"source": source, "scenario": scenario, "samples": samples},
                         ensure_ascii=False, sort_keys=True)
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()


def _ingest_service() -> AdminService:
    service = AdminService()
    service.quality_scorer = None  # 外部写入的内容不送进任何 LLM，用现有规则评分
    return service


def _masked_turns(sample: Dict[str, Any]) -> List[Dict[str, Any]]:
    data_filter = get_data_filter()
    return [{"role": m["role"], "content": data_filter.desensitize(m["content"])} for m in sample["messages"]]


def _find_duplicate(db, fingerprint: str, cleaned_text: str) -> Optional[Dict[str, Any]]:
    prior = (
        db.query(McpIngestSample)
        .filter(McpIngestSample.fingerprint == fingerprint, McpIngestSample.outcome != DEDUPLICATED)
        .first()
    )
    if prior is not None:
        return {"code": "duplicate", "matched": "previously_ingested_sample",
                "message": "与之前通过 MCP 写入的样本内容相同"}
    existing = db.query(StagingConversation.id).filter(StagingConversation.cleaned_text == cleaned_text).first()
    if existing is not None:
        return {"code": "duplicate", "matched": "existing_staging_data",
                "message": "与 staging 中已有的对话内容相同"}
    return None


def _write_raw(db, session_id: str, turns: List[Dict[str, Any]], tags: Dict[str, Any]) -> None:
    # 续跑时 raw 可能已经写过；raw layer 不可变，不再重复写入
    if db.query(RawChat.id).filter(RawChat.session_id == session_id).first() is not None:
        return
    base = int(time.time())
    rows = [
        RawChat(
            local_id=None,
            session_id=session_id,
            sender_wxid=None,
            sender_name=None,  # 外部样本没有微信身份，按 role 映射 is_sender
            content=turn["content"],
            msg_type=1,
            is_sender=turn["role"] == "assistant",
            timestamp=base + offset,
            extra_data={**tags, "turn": offset},
            source_db=RAW_SOURCE_DB,
        )
        for offset, turn in enumerate(turns)
    ]
    WeChatETL().save_message_batch(db, RAW_SOURCE_DB, rows)


def _filter_reasons(db, session_id: str) -> Dict[str, int]:
    rows = (
        db.query(RawChat.auto_category)
        .filter(RawChat.session_id == session_id, RawChat.status == LabelStatus.REJECTED.value)
        .all()
    )
    return dict(Counter(category or "unknown" for (category,) in rows))


def _process_sample(db, service, batch: McpIngestBatch, index: int, sample: Dict[str, Any]) -> McpIngestSample:
    turns = _masked_turns(sample)
    candidate = service._finalize_block({"conversation_json": [dict(t, sender_name=None) for t in turns]})
    cleaned_text = candidate["cleaned_text"]
    fingerprint = hashlib.sha256(cleaned_text.encode("utf-8")).hexdigest()
    session_id = f"{source_tag(batch.client_id)}:{batch.batch_id}:{index}"
    record = McpIngestSample(batch_id=batch.batch_id, sample_index=index, external_id=sample.get("external_id"),
                             fingerprint=fingerprint, session_id=session_id)

    duplicate = _find_duplicate(db, fingerprint, cleaned_text)
    if duplicate:
        record.outcome, record.reason, record.session_id = DEDUPLICATED, duplicate, None
        return record

    tags = {"source": source_tag(batch.client_id), "origin": batch.source, "scenario": batch.scenario,
            "batch_id": batch.batch_id, "sample_index": index, "external_id": sample.get("external_id"),
            "fingerprint": fingerprint}
    _write_raw(db, session_id, turns, tags)
    service.preprocess_session(db, session_id)

    staged = (
        db.query(StagingConversation)
        .filter(StagingConversation.session_id == session_id,
                StagingConversation.status == LabelStatus.PENDING.value)
        .order_by(StagingConversation.id.asc())
        .all()
    )
    dropped = _filter_reasons(db, session_id)
    if staged:
        for row in staged:
            row.auto_flags = {**(row.auto_flags or {}), **{k: tags[k] for k in ("source", "origin", "scenario",
                                                                                "batch_id", "sample_index")}}
        record.outcome, record.staging_ids = STAGED, [row.id for row in staged]
        if dropped:
            record.reason = {"code": "partially_filtered", "categories": dropped,
                             "message": "部分消息被过滤规则排除：" + _fmt_categories(dropped)}
    else:
        record.outcome = FILTERED
        record.reason = {"code": "filtered_by_rule", "scenario": batch.scenario, "categories": dropped,
                         "message": "全部消息被过滤规则排除：" + (_fmt_categories(dropped) or "无可用内容")}
    return record


def _fmt_categories(categories: Dict[str, int]) -> str:
    return "、".join(f"{name}×{count}" for name, count in sorted(categories.items()))


def ingest_batch(db, client_id: str, source: str, scenario: str, samples: List[Dict[str, Any]],
                 idempotency_key: str) -> Dict[str, Any]:
    """处理一批样本。同一 (client_id, idempotency_key) 已完成则直接返回原结果；未完成则续跑。"""
    digest = request_hash(source, scenario, samples)
    batch = db.query(McpIngestBatch).filter_by(client_id=client_id, idempotency_key=idempotency_key).first()
    if batch is None:
        batch = McpIngestBatch(batch_id=f"b_{uuid.uuid4().hex}", client_id=client_id,
                               idempotency_key=idempotency_key, request_hash=digest, source=source,
                               scenario=scenario, status="processing", sample_count=len(samples))
        db.add(batch)
        try:
            db.commit()
        except IntegrityError:  # 并发提交了同一个 key
            db.rollback()
            batch = db.query(McpIngestBatch).filter_by(client_id=client_id,
                                                       idempotency_key=idempotency_key).one()
    if batch.request_hash != digest:
        raise IngestConflict(batch.batch_id)

    replayed = batch.status == "completed"
    if not replayed:
        service = _ingest_service()
        done = {row.sample_index for row in db.query(McpIngestSample.sample_index).filter_by(batch_id=batch.batch_id)}
        for index, sample in enumerate(samples):
            if index in done:
                continue
            db.add(_process_sample(db, service, batch, index, sample))
            db.commit()
        counts = Counter(outcome for (outcome,) in
                         db.query(McpIngestSample.outcome).filter_by(batch_id=batch.batch_id))
        batch.staged_count = counts[STAGED]
        batch.deduplicated_count = counts[DEDUPLICATED]
        batch.filtered_count = counts[FILTERED]
        batch.status = "completed"
        db.commit()
    return _batch_result(db, batch, replayed)


def _sample_rows(db, batch_id: str) -> List[McpIngestSample]:
    return db.query(McpIngestSample).filter_by(batch_id=batch_id).order_by(McpIngestSample.sample_index).all()


def _batch_result(db, batch: McpIngestBatch, replayed: bool) -> Dict[str, Any]:
    results = []
    for row in _sample_rows(db, batch.batch_id):
        item = {"index": row.sample_index, "external_id": row.external_id, "outcome": row.outcome}
        if row.staging_ids:
            item["staging_ids"] = row.staging_ids
        if row.reason:
            item["reason"] = row.reason
        results.append(item)
    return {
        "batch_id": batch.batch_id,
        "status": batch.status,
        "replayed": replayed,
        "source": source_tag(batch.client_id),
        "origin": batch.source,
        "scenario": batch.scenario,
        "counts": {"total": batch.sample_count, STAGED: batch.staged_count,
                   DEDUPLICATED: batch.deduplicated_count, FILTERED: batch.filtered_count},
        "results": results,
    }


def batch_status(db, client_id: str, batch_id: str) -> Optional[Dict[str, Any]]:
    """批次中每条样本当前的审核状态。只能查自己的批次，别人的批次视为不存在。"""
    batch = db.query(McpIngestBatch).filter_by(batch_id=batch_id, client_id=client_id).first()
    if batch is None:
        return None
    rows = _sample_rows(db, batch_id)
    staging_ids = [sid for row in rows for sid in (row.staging_ids or [])]
    statuses = {}
    if staging_ids:
        statuses = dict(
            db.query(StagingConversation.id, StagingConversation.status)
            .filter(StagingConversation.id.in_(staging_ids))
            .all()
        )
    items, summary = [], Counter()
    for row in rows:
        item = {"index": row.sample_index, "external_id": row.external_id, "outcome": row.outcome,
                "review_status": None}
        if row.outcome == STAGED:
            reviews = [{"staging_id": sid, "review_status": REVIEW_STATUS.get(statuses.get(sid), "unknown")}
                       for sid in row.staging_ids or []]
            item["reviews"] = reviews
            states = {r["review_status"] for r in reviews}
            item["review_status"] = states.pop() if len(states) == 1 else "mixed"
            summary[item["review_status"]] += 1
        elif row.reason:
            item["reason"] = row.reason
        items.append(item)
    return {"batch_id": batch.batch_id, "status": batch.status, "scenario": batch.scenario,
            "review_summary": dict(summary), "items": items}
