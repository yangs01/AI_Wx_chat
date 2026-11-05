# -*- coding: utf-8 -*-
"""MCP client whitelist: who is calling, and which scopes they hold.

Each client presents its own Bearer key. Scopes are granted one by one:
holding ``read`` never implies ``ingest``. The legacy shared MCP_API_KEY maps
to client_id ``default`` with ``read`` only, so existing callers keep working
but cannot write.
"""
import hmac
import json
import re
from contextlib import contextmanager
from contextvars import ContextVar
from dataclasses import dataclass
from typing import FrozenSet, List, Optional, Tuple

SCOPE_READ = "read"
SCOPE_INGEST = "ingest"
KNOWN_SCOPES = {SCOPE_READ, SCOPE_INGEST}
LEGACY_CLIENT_ID = "default"
CLIENT_ID_PATTERN = re.compile(r"^[A-Za-z0-9_.-]{1,40}$")


@dataclass(frozen=True)
class McpClient:
    client_id: str
    scopes: FrozenSet[str]

    def can(self, scope: str) -> bool:
        return scope in self.scopes


class McpClientConfigError(ValueError):
    """MCP_CLIENTS is not valid JSON or has a bad entry."""


_current_client: ContextVar[Optional[McpClient]] = ContextVar("mcp_client", default=None)


def load_clients(settings) -> List[Tuple[str, McpClient]]:
    """Return (api_key, client) pairs from settings. Raises McpClientConfigError on bad config."""
    entries: List[Tuple[str, McpClient]] = []
    legacy_key = (getattr(settings, "mcp_api_key", "") or "").strip()
    if legacy_key:
        entries.append((legacy_key, McpClient(LEGACY_CLIENT_ID, frozenset({SCOPE_READ}))))

    raw = (getattr(settings, "mcp_clients", "") or "").strip()
    if not raw:
        return entries
    try:
        items = json.loads(raw)
    except json.JSONDecodeError as exc:
        raise McpClientConfigError(f"MCP_CLIENTS is not valid JSON: {exc.msg}") from None
    if not isinstance(items, list):
        raise McpClientConfigError("MCP_CLIENTS must be a JSON array")

    seen_ids = {LEGACY_CLIENT_ID} if legacy_key else set()
    for index, item in enumerate(items):
        if not isinstance(item, dict):
            raise McpClientConfigError(f"MCP_CLIENTS[{index}] must be an object")
        client_id = str(item.get("client_id") or "")
        api_key = str(item.get("api_key") or "").strip()
        scopes = item.get("scopes") or []
        if not CLIENT_ID_PATTERN.match(client_id):
            raise McpClientConfigError(f"MCP_CLIENTS[{index}].client_id is invalid")
        if client_id in seen_ids:
            raise McpClientConfigError(f"MCP_CLIENTS[{index}].client_id is duplicated")
        if len(api_key) < 16:
            raise McpClientConfigError(f"MCP_CLIENTS[{index}].api_key must be at least 16 characters")
        if not isinstance(scopes, list) or not set(scopes) <= KNOWN_SCOPES:
            raise McpClientConfigError(
                f"MCP_CLIENTS[{index}].scopes must be a subset of {sorted(KNOWN_SCOPES)}"
            )
        if any(hmac.compare_digest(api_key, key) for key, _ in entries):
            raise McpClientConfigError(f"MCP_CLIENTS[{index}].api_key is shared with another client")
        seen_ids.add(client_id)
        entries.append((api_key, McpClient(client_id, frozenset(scopes))))
    return entries


def resolve_client(settings, token: str) -> Optional[McpClient]:
    """Match a Bearer token against the whitelist. Compares every key in constant time."""
    if not token:
        return None
    found = None
    for key, client in load_clients(settings):
        if hmac.compare_digest(token.encode("utf-8"), key.encode("utf-8")):
            found = client
    return found


def current_client() -> Optional[McpClient]:
    """The client bound by the auth middleware; falls back to the current HTTP request's state."""
    client = _current_client.get()
    if client is not None:
        return client
    try:
        from fastmcp.server.dependencies import get_http_request
        return getattr(get_http_request().state, "mcp_client", None)
    except Exception:  # 不在 HTTP 请求里（例如进程内直接调用）：没有 client，按无权限处理
        return None


@contextmanager
def acting_as(client: Optional[McpClient]):
    """Bind the calling client for the duration of a request (or a test)."""
    token = _current_client.set(client)
    try:
        yield client
    finally:
        _current_client.reset(token)
