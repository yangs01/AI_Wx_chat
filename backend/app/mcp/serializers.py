# -*- coding: utf-8 -*-
"""Strip internals and cap text before MCP results leave the process."""
import json
from typing import Any, Dict, Iterable, List, Optional

MAX_TEXT_CHARS = 2000
MAX_EXPORT_LIMIT = 50
DEFAULT_EXPORT_LIMIT = 20

INTERNAL_KEYS = {
    "embedding",
    "source_session_id",
    "source_chunk_id",
    "source_ids",
    "session_id",
    "original_text",
    "sender_wxid",
    "wxid",
}


def cap_text(value: Any, max_chars: int = MAX_TEXT_CHARS) -> Any:
    if isinstance(value, str) and len(value) > max_chars:
        return value[:max_chars] + "..."
    return value


def clamp_limit(limit: Optional[int], default: int = DEFAULT_EXPORT_LIMIT) -> int:
    if limit is None:
        return default
    try:
        parsed = int(limit)
    except (TypeError, ValueError):
        return default
    return max(1, min(parsed, MAX_EXPORT_LIMIT))


def _parse_json_field(value: Any) -> Any:
    if value is None:
        return None
    if isinstance(value, list):
        return value
    if isinstance(value, str):
        try:
            return json.loads(value)
        except Exception:
            return None
    return value


def _drop_internal(payload: Dict[str, Any]) -> Dict[str, Any]:
    return {key: value for key, value in payload.items() if key not in INTERNAL_KEYS}


def serialize_article(article: Any) -> Dict[str, Any]:
    if isinstance(article, dict):
        data = {
            "id": article.get("id"),
            "type": "article",
            "scene": article.get("scene"),
            "scene_category": article.get("scene_category"),
            "customer_says": article.get("customer_says"),
            "recommended_response": article.get("recommended_response"),
            "key_points": _parse_json_field(article.get("key_points")) or [],
            "confidence": article.get("confidence") or 0.0,
            "is_verified": bool(article.get("is_verified")),
            "source_type": article.get("source_type"),
            "similarity": article.get("similarity"),
        }
    else:
        data = {
            "id": article.id,
            "type": "article",
            "scene": article.scene,
            "scene_category": article.scene_category,
            "customer_says": article.customer_says,
            "recommended_response": article.recommended_response,
            "key_points": _parse_json_field(article.key_points) or [],
            "confidence": article.confidence or 0.0,
            "is_verified": bool(article.is_verified),
            "source_type": article.source_type,
        }
    data = _drop_internal(data)
    for key in ("scene", "customer_says", "recommended_response"):
        data[key] = cap_text(data.get(key))
    return {key: value for key, value in data.items() if value is not None or key in {"id", "type"}}


def serialize_chunk(chunk: Dict[str, Any]) -> Dict[str, Any]:
    data = _drop_internal({
        "id": chunk.get("id"),
        "type": "chunk",
        "topic_summary": chunk.get("topic_summary"),
        "content_block": cap_text(chunk.get("content_block")),
        "keywords": _parse_json_field(chunk.get("keywords")) or [],
        "similarity": chunk.get("similarity"),
        "source": chunk.get("source"),
    })
    return {key: value for key, value in data.items() if value is not None or key in {"id", "type"}}


def serialize_retrieve_result(articles: Iterable[Any], chunks: Iterable[Dict[str, Any]]) -> Dict[str, Any]:
    return {
        "articles": [serialize_article(article) for article in articles],
        "chunks": [serialize_chunk(chunk) for chunk in chunks],
    }


def serialize_export_item(item: Dict[str, Any]) -> Dict[str, Any]:
    """Cap text in formatted export rows; never pass original_text through."""
    cleaned = _drop_internal(dict(item))

    conversations = cleaned.get("conversations")
    if isinstance(conversations, list):
        capped = []
        for turn in conversations:
            if not isinstance(turn, dict):
                continue
            capped.append({
                **turn,
                "value": cap_text(turn.get("value")),
            })
        cleaned["conversations"] = capped

    messages = cleaned.get("messages")
    if isinstance(messages, list):
        capped_messages = []
        for message in messages:
            if not isinstance(message, dict):
                continue
            capped_messages.append({
                **message,
                "content": cap_text(message.get("content")),
            })
        cleaned["messages"] = capped_messages

    for key in ("question", "answer", "instruction", "input", "output"):
        if key in cleaned:
            cleaned[key] = cap_text(cleaned.get(key))
    return cleaned


def assert_no_internal_fields(payload: Any) -> List[str]:
    """Return leaked internal keys (used by tests)."""
    leaked: List[str] = []

    def _walk(node: Any) -> None:
        if isinstance(node, dict):
            for key, value in node.items():
                if key in INTERNAL_KEYS:
                    leaked.append(key)
                _walk(value)
        elif isinstance(node, list):
            for item in node:
                _walk(item)

    _walk(payload)
    return leaked
