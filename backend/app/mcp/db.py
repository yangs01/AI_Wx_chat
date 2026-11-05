# -*- coding: utf-8 -*-
"""Database session helper for MCP tool handlers."""
from contextlib import contextmanager

from app.models.database import get_session_local


@contextmanager
def mcp_db_session():
    SessionLocal = get_session_local()
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
