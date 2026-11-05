# -*- coding: utf-8 -*-
"""Bearer auth for the MCP Streamable HTTP app."""
import logging

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse, Response

from app.config import get_settings
from app.mcp.clients import McpClientConfigError, acting_as, resolve_client

logger = logging.getLogger("app.mcp.auth")


class McpBearerAuthMiddleware(BaseHTTPMiddleware):
    """Reject MCP requests whose Bearer key is not on the client whitelist.

    The resolved client (id + scopes) is bound for the request so tools can
    check per-scope permissions such as ``ingest``.
    """

    async def dispatch(self, request: Request, call_next) -> Response:
        if request.method == "OPTIONS":
            return await call_next(request)

        auth = request.headers.get("authorization", "")
        token = auth[len("Bearer "):] if auth.startswith("Bearer ") else ""
        try:
            client = resolve_client(get_settings(), token)
        except McpClientConfigError as exc:
            logger.error("MCP client config invalid: %s", exc)
            return JSONResponse({"error": "server misconfigured"}, status_code=500)
        if client is None:
            return JSONResponse({"error": "unauthorized"}, status_code=401)

        request.state.mcp_client = client
        with acting_as(client):
            return await call_next(request)
