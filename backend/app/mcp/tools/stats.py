# -*- coding: utf-8 -*-
"""Corpus stats for MCP health / discovery."""
from typing import Any, Dict

from sqlalchemy import func

from app.mcp.db import mcp_db_session
from app.models.chat import CustomConversation, KnowledgeChunk, StagingConversation
from app.services.extractor import KnowledgeExtractor


def get_knowledge_corpus_stats() -> Dict[str, Any]:
    """Counts of approved knowledge articles, labeled chunks, and exportable conversations."""
    with mcp_db_session() as db:
        stats = KnowledgeExtractor(db).get_stats()
        labeled_chunks = (
            db.query(func.count(KnowledgeChunk.id))
            .filter(KnowledgeChunk.chunk_type == "labeled")
            .scalar()
        ) or 0
        approved_conversations = (
            db.query(func.count(StagingConversation.id))
            .filter(StagingConversation.status == "approved")
            .scalar()
        ) or 0
        custom_conversations = (
            db.query(func.count(CustomConversation.id))
            .filter(CustomConversation.is_active == True)  # noqa: E712
            .scalar()
        ) or 0
        stats.update({
            "labeled_chunks": int(labeled_chunks),
            "approved_conversations": int(approved_conversations),
            "custom_conversations": int(custom_conversations),
        })
        return stats
