# -*- coding: utf-8 -*-
"""Per-scope permission checks inside FastMCP.

Read tools and resources need the ``read`` scope. The ingest tools check the
``ingest`` scope themselves so they can return structured errors, so they are
skipped here. Holding one scope never grants the other.
"""
from fastmcp.exceptions import ResourceError, ToolError
from fastmcp.server.middleware import Middleware

from app.mcp.clients import SCOPE_READ, current_client

INGEST_TOOLS = {"ingest_samples", "get_ingest_status"}
READ_DENIED = "FORBIDDEN: this client is not allowed to read; an admin must grant it the 'read' scope"


def _can_read() -> bool:
    client = current_client()
    return client is not None and client.can(SCOPE_READ)


class McpScopeMiddleware(Middleware):
    async def on_call_tool(self, context, call_next):
        if context.message.name not in INGEST_TOOLS and not _can_read():
            raise ToolError(READ_DENIED)
        return await call_next(context)

    async def on_read_resource(self, context, call_next):
        if not _can_read():
            raise ResourceError(READ_DENIED)
        return await call_next(context)
