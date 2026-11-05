# -*- coding: utf-8 -*-
"""Retrieve approved sales knowledge for other agents."""
from typing import Any, Dict

from app.mcp.db import mcp_db_session
from app.mcp.serializers import clamp_limit, serialize_retrieve_result
from app.services.rag import RAGService


def retrieve_sales_knowledge(
    query: str,
    top_k: int = 5,
    verified_only: bool = True,
) -> Dict[str, Any]:
    """Hybrid retrieve: verified knowledge articles first, labeled chunks as fallback.

    Returns structured sources only. The calling agent should generate its own answer.
    """
    limit = clamp_limit(top_k, default=5)
    with mcp_db_session() as db:
        service = RAGService(db)
        articles, chunks = service.retrieve(
            query,
            top_k=limit,
            verified_only=verified_only,
            labeled_chunks_only=True,
        )
        return serialize_retrieve_result(articles, chunks)
