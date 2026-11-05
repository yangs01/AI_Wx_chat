# -*- coding: utf-8 -*-
"""Audit log for MCP write calls.

One JSON line per call on the ``app.mcp.audit`` logger: who, which scenario,
how many samples, and the outcome counts. Never the sample text.
"""
import json
import logging
from datetime import datetime, timezone
from typing import Any, Optional

from app.mcp.clients import McpClient

audit_logger = logging.getLogger("app.mcp.audit")


def audit(event: str, client: Optional[McpClient], **fields: Any) -> None:
    record = {
        "ts": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "event": event,
        "client_id": client.client_id if client else None,
        **{key: value for key, value in fields.items() if value is not None},
    }
    audit_logger.info(json.dumps(record, ensure_ascii=False, sort_keys=True))
