# -*- coding: utf-8 -*-
"""FastMCP Streamable HTTP server: approved sales knowledge (read) and sample ingest (write)."""
from starlette.middleware import Middleware

from app.mcp.auth import McpBearerAuthMiddleware
from app.mcp.tools.articles import (
    get_knowledge_article,
    list_knowledge_articles,
    search_knowledge_articles,
)
from app.mcp.tools.export_samples import (
    export_approved_rag_entries,
    preview_approved_training_data,
)
from app.mcp.tools.ingest import get_ingest_status, ingest_samples
from app.mcp.tools.retrieve import retrieve_sales_knowledge
from app.mcp.tools.stats import get_knowledge_corpus_stats


def _build_mcp():
    from fastmcp import FastMCP

    from app.mcp.scopes import McpScopeMiddleware

    mcp = FastMCP("aiwxchat-knowledge")
    mcp.add_middleware(McpScopeMiddleware())

    mcp.tool(retrieve_sales_knowledge)
    mcp.tool(search_knowledge_articles)
    mcp.tool(list_knowledge_articles)
    mcp.tool(get_knowledge_article)
    mcp.tool(get_knowledge_corpus_stats)
    mcp.tool(preview_approved_training_data)
    mcp.tool(export_approved_rag_entries)
    # 写入类：需要单独授权的 ingest 权限
    mcp.tool(ingest_samples)
    mcp.tool(get_ingest_status)

    mcp.resource("knowledge://stats")(get_knowledge_corpus_stats)
    mcp.resource("knowledge://articles/{article_id}")(get_knowledge_article)
    return mcp


def create_mcp_http_app():
    """Return the Streamable HTTP ASGI app to mount at /mcp."""
    mcp = _build_mcp()
    middleware = [Middleware(McpBearerAuthMiddleware)]
    kwargs = {
        "path": "/",
        "stateless_http": True,
        "middleware": middleware,
    }
    try:
        return mcp.http_app(
            transport="streamable-http",
            host_origin_protection=False,
            **kwargs,
        )
    except TypeError:
        try:
            return mcp.http_app(transport="streamable-http", **kwargs)
        except TypeError:
            return mcp.http_app(**kwargs)
