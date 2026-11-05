# -*- coding: utf-8 -*-
"""Paginated samples of approved training / RAG entries."""
from typing import Any, Dict, Iterable, List, Optional

from app.mcp.db import mcp_db_session
from app.mcp.serializers import (
    DEFAULT_EXPORT_LIMIT,
    clamp_limit,
    serialize_export_item,
)
from app.models.chat import CustomConversation, StagingConversation
from app.services.export_format import (
    _contains_price_info,
    _format_custom_item,
    _format_staging_item,
)
from app.services.rag_rewriter import filter_rag_entries, rule_based_rewrite

SUPPORTED_FORMATS = {"sharegpt", "alpaca", "openai", "jsonl", "rag"}


def _item_has_price(item: StagingConversation) -> bool:
    content = item.cleaned_text or ""
    question = item.human_question or item.auto_question or ""
    answer = item.human_answer or item.auto_answer or ""
    return (
        _contains_price_info(content)
        or _contains_price_info(question)
        or _contains_price_info(answer)
    )


def _iter_approved_formatted(
    db,
    fmt: str,
    category: Optional[str],
    exclude_price_data: bool,
    include_custom: bool = True,
) -> Iterable[Dict[str, Any]]:
    staging_query = db.query(StagingConversation).filter(
        StagingConversation.status == "approved"
    )
    if category:
        staging_query = staging_query.filter(
            (StagingConversation.auto_category == category)
            | (StagingConversation.human_category == category)
        )
    for item in staging_query.order_by(StagingConversation.id.asc()).all():
        if exclude_price_data and _item_has_price(item):
            continue
        formatted = _format_staging_item(item, fmt, include_system_prompt=True)
        if formatted:
            yield formatted

    if not include_custom:
        return

    custom_query = db.query(CustomConversation).filter(
        CustomConversation.is_active == True  # noqa: E712
    )
    if category:
        custom_query = custom_query.filter(CustomConversation.category == category)
    for item in custom_query.order_by(CustomConversation.id.asc()).all():
        formatted = _format_custom_item(item, fmt, include_system_prompt=True)
        if formatted:
            yield formatted


def _paginate(items: List[Dict[str, Any]], offset: int, limit: int) -> Dict[str, Any]:
    safe_offset = max(0, int(offset or 0))
    page = items[safe_offset:safe_offset + limit]
    return {
        "items": [serialize_export_item(item) for item in page],
        "offset": safe_offset,
        "limit": limit,
        "returned": len(page),
        "total": len(items),
        "has_more": safe_offset + len(page) < len(items),
    }


def preview_approved_training_data(
    format: str = "sharegpt",
    category: Optional[str] = None,
    exclude_price_data: bool = True,
    offset: int = 0,
    limit: int = DEFAULT_EXPORT_LIMIT,
) -> Dict[str, Any]:
    """Preview approved training rows. Hard-capped at 50 items per call."""
    fmt = (format or "sharegpt").lower()
    if fmt not in SUPPORTED_FORMATS:
        return {"error": f"unsupported format: {format}", "supported": sorted(SUPPORTED_FORMATS)}

    fetch_limit = clamp_limit(limit)
    with mcp_db_session() as db:
        collected = list(_iter_approved_formatted(db, fmt, category, exclude_price_data))
        result = _paginate(collected, offset, fetch_limit)
        result["format"] = fmt
        return result


def export_approved_rag_entries(
    category: Optional[str] = None,
    exclude_price_data: bool = True,
    offset: int = 0,
    limit: int = DEFAULT_EXPORT_LIMIT,
) -> Dict[str, Any]:
    """Paginated rule-cleaned RAG Q&A from approved conversations. Hard-capped at 50."""
    fetch_limit = clamp_limit(limit)
    with mcp_db_session() as db:
        collected = list(_iter_approved_formatted(db, "rag", category, exclude_price_data))
        collected, filter_stats = filter_rag_entries(collected)
        collected = rule_based_rewrite(collected)
        result = _paginate(collected, offset, fetch_limit)
        result["format"] = "rag"
        result["filter"] = filter_stats
        return result
