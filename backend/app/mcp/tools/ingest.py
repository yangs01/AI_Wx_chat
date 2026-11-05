# -*- coding: utf-8 -*-
"""Write path: push new samples (online chats, badcases) into the Data Engine pipeline.

Samples go through the existing pipeline and stop in staging as ``pending_review``.
They never reach the curated layer without human review. Sample text is stored
as data only: it is never interpreted as instructions or sent to an LLM.
"""
import hashlib
import logging
import re
from typing import Any, Dict, List, Literal, Optional

from pydantic import BaseModel, Field

from app.config import get_settings
from app.mcp.audit import audit
from app.mcp.clients import SCOPE_INGEST, current_client
from app.mcp.db import mcp_db_session
from app.services.mcp_ingest import IngestConflict, batch_status, ingest_batch

logger = logging.getLogger("app.mcp.ingest")

MAX_SAMPLES_PER_CALL = 50
MAX_TURNS_PER_SAMPLE = 20
MAX_MESSAGE_CHARS = 2000
SOURCE_PATTERN = re.compile(r"^[a-z0-9_-]{1,32}$")
KEY_PATTERN = re.compile(r"^[A-Za-z0-9._:-]{8,128}$")
EXTERNAL_ID_PATTERN = re.compile(r"^[A-Za-z0-9._:-]{1,100}$")
BATCH_ID_PATTERN = re.compile(r"^b_[0-9a-f]{32}$")


class IngestMessage(BaseModel):
    role: Literal["user", "assistant"] = Field(description="user = the customer, assistant = the agent")
    content: str = Field(description=f"Message text, at most {MAX_MESSAGE_CHARS} characters. Stored as data only.")


class IngestSample(BaseModel):
    external_id: Optional[str] = Field(default=None, description="Caller's own id for this sample (optional)")
    messages: List[IngestMessage] = Field(description=f"1 to {MAX_TURNS_PER_SAMPLE} turns of one conversation")


def _error(code: str, message: str, **extra: Any) -> Dict[str, Any]:
    return {"error": message, "code": code, **extra}


def allowed_scenarios() -> List[str]:
    raw = getattr(get_settings(), "mcp_ingest_scenarios", "") or ""
    return [item.strip() for item in raw.split(",") if item.strip()]


def _as_dict(sample: Any) -> Any:
    return sample.model_dump() if isinstance(sample, BaseModel) else sample


def _validate(source: Any, scenario: Any, samples: Any, idempotency_key: Any):
    """Return (error, normalized_samples). Messages never echo sample text back."""
    if not isinstance(source, str) or not SOURCE_PATTERN.match(source):
        return _error("INVALID_ARGUMENT", "source must match [a-z0-9_-]{1,32}", field="source"), None
    if not isinstance(idempotency_key, str) or not KEY_PATTERN.match(idempotency_key):
        return _error("INVALID_ARGUMENT", "idempotency_key must match [A-Za-z0-9._:-]{8,128}",
                      field="idempotency_key"), None
    scenarios = allowed_scenarios()
    if scenario not in scenarios:
        return _error("UNKNOWN_SCENARIO", "unknown scenario", field="scenario", supported=scenarios), None
    if not isinstance(samples, list) or not 1 <= len(samples) <= MAX_SAMPLES_PER_CALL:
        return _error("INVALID_ARGUMENT", f"samples must contain 1 to {MAX_SAMPLES_PER_CALL} items",
                      field="samples"), None

    normalized = []
    for index, raw in enumerate(samples):
        sample = _as_dict(raw)
        where = f"samples[{index}]"
        if not isinstance(sample, dict) or set(sample) - {"external_id", "messages"}:
            return _error("INVALID_ARGUMENT", f"{where} must only have external_id and messages", field=where), None
        external_id = sample.get("external_id")
        if external_id is not None and (not isinstance(external_id, str) or not EXTERNAL_ID_PATTERN.match(external_id)):
            return _error("INVALID_ARGUMENT", f"{where}.external_id must match [A-Za-z0-9._:-]{{1,100}}",
                          field=f"{where}.external_id"), None
        messages = sample.get("messages")
        if not isinstance(messages, list) or not 1 <= len(messages) <= MAX_TURNS_PER_SAMPLE:
            return _error("INVALID_ARGUMENT", f"{where}.messages must contain 1 to {MAX_TURNS_PER_SAMPLE} turns",
                          field=f"{where}.messages"), None
        turns = []
        for turn_index, message in enumerate(messages):
            message = _as_dict(message)
            at = f"{where}.messages[{turn_index}]"
            if not isinstance(message, dict) or message.get("role") not in ("user", "assistant"):
                return _error("INVALID_ARGUMENT", f"{at}.role must be user or assistant", field=at), None
            content = message.get("content")
            if not isinstance(content, str) or not content.strip():
                return _error("INVALID_ARGUMENT", f"{at}.content must be a non-empty string", field=at), None
            if len(content) > MAX_MESSAGE_CHARS:
                return _error("INVALID_ARGUMENT", f"{at}.content exceeds {MAX_MESSAGE_CHARS} characters",
                              field=at), None
            turns.append({"role": message["role"], "content": content})
        normalized.append({"external_id": external_id, "messages": turns})
    return None, normalized


def _key_digest(key: Any) -> Optional[str]:
    return hashlib.sha256(key.encode("utf-8")).hexdigest()[:12] if isinstance(key, str) else None


def ingest_samples(
    source: str,
    scenario: str,
    samples: List[IngestSample],
    idempotency_key: str,
) -> Dict[str, Any]:
    """Push new samples (e.g. online conversations, badcases) into the Data Engine for human review.

    Each sample runs through the existing pipeline: masking → dedup → raw layer →
    the scenario's filter rules → staging with status pending_review. Nothing is
    written to the curated layer. Re-sending the same idempotency_key returns the
    original batch instead of writing again. Requires the 'ingest' scope.

    Limits: at most 50 samples per call, 20 turns per sample, 2000 characters per turn.
    Sample text is stored as data only and is never executed or followed as instructions.

    Returns batch_id and, for each sample, its outcome: staged, deduplicated, or filtered (with the reason).
    """
    client = current_client()
    count = len(samples) if isinstance(samples, list) else None
    if client is None or not client.can(SCOPE_INGEST):
        audit("ingest_samples", client, outcome="forbidden", scenario=scenario if isinstance(scenario, str) else None,
              sample_count=count)
        return _error("FORBIDDEN", "this client is not allowed to ingest; an admin must grant it the 'ingest' scope")

    error, normalized = _validate(source, scenario, samples, idempotency_key)
    if error:
        audit("ingest_samples", client, outcome="invalid", code=error["code"], field=error.get("field"),
              scenario=scenario if isinstance(scenario, str) else None, sample_count=count)
        return error

    try:
        with mcp_db_session() as db:
            result = ingest_batch(db, client.client_id, source, scenario, normalized, idempotency_key)
    except IngestConflict as exc:
        audit("ingest_samples", client, outcome="conflict", scenario=scenario, sample_count=count,
              batch_id=str(exc), key_sha=_key_digest(idempotency_key))
        return _error("IDEMPOTENCY_CONFLICT",
                      "this idempotency_key was already used with different content; use a new key")
    except Exception as exc:  # 不把异常栈和原文带出去
        logger.error("ingest_samples failed for client %s: %s", client.client_id, type(exc).__name__)
        audit("ingest_samples", client, outcome="error", scenario=scenario, sample_count=count,
              error=type(exc).__name__, key_sha=_key_digest(idempotency_key))
        return _error("INTERNAL", "ingest failed; retry with the same idempotency_key to resume the batch")

    audit("ingest_samples", client, outcome="ok", scenario=scenario, origin=source, sample_count=count,
          batch_id=result["batch_id"], counts=result["counts"], replayed=result["replayed"],
          key_sha=_key_digest(idempotency_key))
    return result


def get_ingest_status(batch_id: str) -> Dict[str, Any]:
    """Current review status of every sample in a batch you ingested.

    review_status is pending_review, approved, rejected, or edited. Deduplicated and
    filtered samples never entered review and keep their outcome and reason.
    Requires the 'ingest' scope; a client can only see its own batches.
    """
    client = current_client()
    if client is None or not client.can(SCOPE_INGEST):
        audit("get_ingest_status", client, outcome="forbidden")
        return _error("FORBIDDEN", "this client is not allowed to read ingest batches; it needs the 'ingest' scope")
    if not isinstance(batch_id, str) or not BATCH_ID_PATTERN.match(batch_id):
        return _error("INVALID_ARGUMENT", "batch_id is not a valid batch id", field="batch_id")
    try:
        with mcp_db_session() as db:
            status = batch_status(db, client.client_id, batch_id)
    except Exception as exc:
        logger.error("get_ingest_status failed for client %s: %s", client.client_id, type(exc).__name__)
        return _error("INTERNAL", "could not read batch status")
    if status is None:
        return _error("NOT_FOUND", "batch not found", batch_id=batch_id)
    return status
