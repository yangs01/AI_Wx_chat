# -*- coding: utf-8 -*-
"""
AiWxChat 后端主入口
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import sqlalchemy

from app.config import get_settings
from app.models.database import get_engine, Base
# 导入所有模型以确保表被创建
from app.models.chat import RawChat, KnowledgeChunk, Session, Contact, LabeledConversation, StagingConversation, CustomConversation, Material, KnowledgeArticle, Quiz, QuizAttempt
from app.models.mcp_ingest import McpIngestBatch, McpIngestSample  # noqa: F401  MCP 写入批次表
from app.models.user import User
from app.models.student import Student
from app.models.student_report_binding import StudentReportBinding  # noqa: F401  确保 create_all 创建绑定表
from app.routers import chats, search, knowledge, export, filter, labeling, admin, custom, materials, auth, students, extractor, quiz
from app.services.schema_sync import ensure_legacy_material_schema, ensure_legacy_raw_chat_schema, ensure_legacy_student_schema
from app.mcp.clients import load_clients
from app.mcp.server import create_mcp_http_app

settings = get_settings()
mcp_http_app = create_mcp_http_app()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """应用生命周期管理"""
    # 启动时创建数据库表
    print("[INFO] Creating database tables...")
    try:
        engine = get_engine()
        # 尝试启用 pgvector 扩展（仅 PostgreSQL 有效，SQLite 会跳过）
        try:
            with engine.connect() as conn:
                conn.execute(sqlalchemy.text("CREATE EXTENSION IF NOT EXISTS vector"))
                conn.commit()
                print("[INFO] pgvector extension enabled")
        except Exception as e:
            print(f"[INFO] pgvector extension skipped (non-PostgreSQL or not available): {e}")
        # 无论 pgvector 是否成功，都要创建表
        Base.metadata.create_all(bind=engine)
        added_columns = ensure_legacy_raw_chat_schema(engine)
        if added_columns:
            print(f"[INFO] Patched legacy raw_chats columns: {', '.join(added_columns)}")
        added_material_columns = ensure_legacy_material_schema(engine)
        if added_material_columns:
            print(f"[INFO] Patched legacy materials columns: {', '.join(added_material_columns)}")
        added_student_columns = ensure_legacy_student_schema(engine)
        if added_student_columns:
            print(f"[INFO] Patched legacy students columns: {', '.join(added_student_columns)}")
        print("[INFO] Database tables ready")
    except Exception as e:
        print(f"[WARN] Database init failed: {e}")
        print("[INFO] Some features may not work without database")

    mcp_clients = load_clients(settings)  # MCP_CLIENTS 配置错误时启动即失败
    if settings.app_env == "prod" and not mcp_clients:
        raise RuntimeError("MCP_API_KEY or MCP_CLIENTS is required when APP_ENV=prod")

    async with mcp_http_app.lifespan(app):
        yield
    # 关闭时清理
    print("[INFO] Shutting down...")


# 创建应用
app = FastAPI(
    title="AiWxChat API",
    description="微信聊天记录知识库 API",
    version="1.0.0",
    lifespan=lifespan
)

# 配置 CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 开发环境允许所有来源
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["X-Tos-Key", "X-Total-Examples", "X-Total-Rows", "X-Total-Tags", "X-Format", "X-Knowledge-Items", "Content-Disposition"],
)

# 注册路由
app.include_router(chats.router)
app.include_router(search.router)
app.include_router(knowledge.router)
app.include_router(export.router)
app.include_router(filter.router)
app.include_router(labeling.router)
app.include_router(admin.router)
app.include_router(custom.router)
app.include_router(materials.router)
app.include_router(auth.router)
app.include_router(students.router)
app.include_router(extractor.router)
app.include_router(quiz.router)
app.mount("/mcp", mcp_http_app)


@app.get("/")
def root():
    """根路径"""
    return {
        "name": "AiWxChat API",
        "version": "1.0.0",
        "status": "running"
    }


@app.get("/health")
def health_check():
    """健康检查"""
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host=settings.api_host,
        port=settings.api_port,
        reload=settings.debug
    )
