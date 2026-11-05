# -*- coding: utf-8 -*-
"""Browse structured knowledge articles."""
from typing import Any, Dict, Optional

from app.mcp.db import mcp_db_session
from app.mcp.serializers import clamp_limit, serialize_article
from app.models.chat import KnowledgeArticle
from app.services.rag import ArticleSearch


def search_knowledge_articles(
    query: str,
    limit: int = 5,
    verified_only: bool = True,
) -> Dict[str, Any]:
    """Semantic search over structured sales knowledge articles."""
    fetch_limit = clamp_limit(limit, default=5)
    with mcp_db_session() as db:
        results = ArticleSearch(db).search(query, limit=fetch_limit)
        if verified_only:
            results = [item for item in results if item.get("is_verified")]
        return {
            "items": [serialize_article(item) for item in results],
            "count": len(results),
        }


def list_knowledge_articles(
    category: Optional[str] = None,
    verified_only: bool = True,
    offset: int = 0,
    limit: int = 20,
) -> Dict[str, Any]:
    """List knowledge articles with optional category filter."""
    fetch_limit = clamp_limit(limit)
    safe_offset = max(0, int(offset or 0))
    with mcp_db_session() as db:
        query = db.query(KnowledgeArticle)
        if category:
            query = query.filter(KnowledgeArticle.scene_category == category)
        if verified_only:
            query = query.filter(KnowledgeArticle.is_verified == True)  # noqa: E712
        total = query.count()
        articles = (
            query.order_by(KnowledgeArticle.confidence.desc())
            .offset(safe_offset)
            .limit(fetch_limit)
            .all()
        )
        return {
            "items": [serialize_article(article) for article in articles],
            "offset": safe_offset,
            "limit": fetch_limit,
            "total": total,
        }


def get_knowledge_article(article_id: int) -> Dict[str, Any]:
    """Fetch one knowledge article by id."""
    try:
        parsed_id = int(article_id)
    except (TypeError, ValueError):
        return {"error": "knowledge article not found", "id": article_id}
    with mcp_db_session() as db:
        article = db.query(KnowledgeArticle).get(parsed_id)
        if not article:
            return {"error": "knowledge article not found", "id": parsed_id}
        return serialize_article(article)
