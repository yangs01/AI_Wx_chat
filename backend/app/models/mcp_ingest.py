# -*- coding: utf-8 -*-
"""
MCP 写入批次（ingest_samples）

一批 = 一次 ingest_samples 调用。(client_id, idempotency_key) 唯一，保证重复提交不产生重复数据。
批次表同时是写入审计记录：谁、哪个场景、多少条、结果统计，不存原文。
"""
from datetime import datetime

from sqlalchemy import JSON, Column, DateTime, Integer, String, UniqueConstraint

from .database import Base


class McpIngestBatch(Base):
    """MCP 写入批次"""
    __tablename__ = "mcp_ingest_batches"
    __table_args__ = (UniqueConstraint("client_id", "idempotency_key", name="uq_mcp_ingest_client_key"),)

    id = Column(Integer, primary_key=True, autoincrement=True)
    batch_id = Column(String(40), unique=True, nullable=False, index=True)
    client_id = Column(String(100), nullable=False, index=True)
    idempotency_key = Column(String(128), nullable=False)
    request_hash = Column(String(64), nullable=False)       # 请求内容哈希，同 key 不同内容视为冲突
    source = Column(String(50), nullable=False)              # 调用方声明的业务来源，如 online_chat / badcase
    scenario = Column(String(50), nullable=False)
    status = Column(String(20), default="processing")       # processing / completed
    sample_count = Column(Integer, default=0)
    staged_count = Column(Integer, default=0)
    deduplicated_count = Column(Integer, default=0)
    filtered_count = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class McpIngestSample(Base):
    """MCP 写入批次中的单条样本处理结果（不存原文，原文在 raw_chats / staging）"""
    __tablename__ = "mcp_ingest_samples"
    __table_args__ = (UniqueConstraint("batch_id", "sample_index", name="uq_mcp_ingest_sample"),)

    id = Column(Integer, primary_key=True, autoincrement=True)
    batch_id = Column(String(40), nullable=False, index=True)
    sample_index = Column(Integer, nullable=False)
    external_id = Column(String(100))                        # 调用方自己的样本 ID（可选）
    fingerprint = Column(String(64), nullable=False, index=True)  # 脱敏后内容的 sha256，用于去重
    session_id = Column(String(100))                          # raw_chats / staging 中的会话 ID
    outcome = Column(String(20), nullable=False)              # staged / deduplicated / filtered
    reason = Column(JSON)                                     # 过滤原因或重复来源
    staging_ids = Column(JSON)                                # 进入 staging 的记录 ID
    created_at = Column(DateTime, default=datetime.utcnow)
