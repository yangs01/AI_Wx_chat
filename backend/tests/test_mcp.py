import os
import sys
import unittest
from unittest.mock import patch

from sqlalchemy import create_engine
from sqlalchemy.ext.compiler import compiles
from sqlalchemy.orm import sessionmaker
from starlette.applications import Starlette
from starlette.middleware import Middleware
from starlette.responses import JSONResponse
from starlette.routing import Route
from starlette.testclient import TestClient

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from app.mcp.auth import McpBearerAuthMiddleware
from app.mcp.serializers import (
    MAX_EXPORT_LIMIT,
    MAX_TEXT_CHARS,
    assert_no_internal_fields,
    clamp_limit,
    serialize_article,
    serialize_chunk,
    serialize_export_item,
)
from app.mcp.tools.articles import get_knowledge_article, list_knowledge_articles
from app.mcp.tools.export_samples import (
    export_approved_rag_entries,
    preview_approved_training_data,
)
from app.mcp.tools.retrieve import retrieve_sales_knowledge
from app.mcp.tools.stats import get_knowledge_corpus_stats
from app.models.chat import (
    HAS_PGVECTOR,
    Base,
    CustomConversation,
    KnowledgeArticle,
    KnowledgeChunk,
    StagingConversation,
)
from app.services.rag import RAGService

if HAS_PGVECTOR:
    from pgvector.sqlalchemy import Vector
    from sqlalchemy.dialects.postgresql import JSONB

    @compiles(JSONB, "sqlite")
    def _jsonb_as_json(type_, compiler, **kw):
        return "JSON"

    @compiles(Vector, "sqlite")
    def _vector_as_text(type_, compiler, **kw):
        return "TEXT"


def _conversation_turns():
    return [
        {"role": "user", "content": "这个课程适合零基础吗"},
        {"role": "assistant", "content": "适合 从Python零基础讲起"},
        {"role": "user", "content": "要学多久"},
        {"role": "assistant", "content": "大概三个月 上班也能学"},
    ]


class SerializerTests(unittest.TestCase):
    def test_serialize_article_drops_internal_fields(self):
        payload = serialize_article({
            "id": 1,
            "scene": "问价格",
            "customer_says": "多少钱",
            "recommended_response": "找教务领优惠",
            "is_verified": True,
            "source_type": "labeled",
            "source_session_id": "wxid_abc",
            "source_chunk_id": 99,
            "embedding": [0.1, 0.2],
            "similarity": 0.91,
        })

        self.assertEqual(assert_no_internal_fields(payload), [])
        self.assertNotIn("embedding", payload)
        self.assertNotIn("source_session_id", payload)
        self.assertEqual(payload["scene"], "问价格")
        self.assertTrue(payload["is_verified"])

    def test_serialize_chunk_caps_text_and_drops_wxid_fields(self):
        payload = serialize_chunk({
            "id": 2,
            "topic_summary": "打招呼",
            "content_block": "wxid_secret: " + ("内容" * 2000),
            "source_ids": [1, 2, 3],
            "session_id": "wxid_abc",
            "source": "labeled",
            "similarity": 0.7,
            "keywords": ["课程"],
        })

        self.assertEqual(assert_no_internal_fields(payload), [])
        self.assertNotIn("session_id", payload)
        self.assertNotIn("source_ids", payload)
        self.assertLessEqual(len(payload["content_block"]), MAX_TEXT_CHARS + 3)
        self.assertTrue(payload["content_block"].endswith("..."))

    def test_serialize_export_item_never_keeps_original_text(self):
        payload = serialize_export_item({
            "id": "1",
            "original_text": "wxid_abc 原始聊天",
            "session_id": "wxid_abc",
            "question": "适合零基础吗",
            "answer": "适合",
        })

        self.assertNotIn("original_text", payload)
        self.assertNotIn("session_id", payload)
        self.assertEqual(assert_no_internal_fields(payload), [])

    def test_clamp_limit_hard_caps_at_fifty(self):
        self.assertEqual(clamp_limit(100), MAX_EXPORT_LIMIT)
        self.assertEqual(clamp_limit(0), 1)
        self.assertEqual(clamp_limit(None), 20)


class RetrieveFilterTests(unittest.TestCase):
    def test_retrieve_filters_unverified_articles_and_chat_chunks(self):
        service = RAGService.__new__(RAGService)
        service._retrieve = lambda *args, **kwargs: (
            [
                {"id": 1, "is_verified": True, "similarity": 0.9},
                {"id": 2, "is_verified": False, "similarity": 0.8},
            ],
            [
                {"id": 3, "source": "labeled"},
                {"id": 4, "source": "chat"},
            ],
        )

        articles, chunks = service.retrieve(
            "课程",
            verified_only=True,
            labeled_chunks_only=True,
        )

        self.assertEqual([item["id"] for item in articles], [1])
        self.assertEqual([item["id"] for item in chunks], [3])

    def test_retrieve_defaults_keep_rest_behavior(self):
        service = RAGService.__new__(RAGService)
        service._retrieve = lambda *args, **kwargs: (
            [{"id": 2, "is_verified": False}],
            [{"id": 4, "source": "chat"}],
        )

        articles, chunks = service.retrieve("课程")

        self.assertEqual([item["id"] for item in articles], [2])
        self.assertEqual([item["id"] for item in chunks], [4])


class McpToolTests(unittest.TestCase):
    def setUp(self):
        engine = create_engine("sqlite:///:memory:")
        Base.metadata.create_all(
            bind=engine,
            tables=[
                KnowledgeArticle.__table__,
                KnowledgeChunk.__table__,
                StagingConversation.__table__,
                CustomConversation.__table__,
            ],
        )
        self.SessionLocal = sessionmaker(bind=engine)
        self.db = self.SessionLocal()
        self.patcher = patch("app.mcp.db.get_session_local", return_value=self.SessionLocal)
        self.patcher.start()

        self.approved = StagingConversation(
            original_text="wxid_should_not_leak 原始内容",
            cleaned_text="这个课程适合零基础吗\n适合 从Python零基础讲起",
            conversation_json=_conversation_turns(),
            session_id="wxid_should_not_leak",
            status="approved",
            human_category="course",
            human_question="这个课程适合零基础吗",
            human_answer="适合 从Python零基础讲起",
        )
        self.pending = StagingConversation(
            original_text="待审核原始聊天",
            cleaned_text="待审核内容",
            conversation_json=_conversation_turns(),
            session_id="wxid_pending",
            status="pending",
            human_category="course",
        )
        self.priced = StagingConversation(
            original_text="课程只要3999元",
            cleaned_text="课程只要3999元 现在报名",
            conversation_json=[
                {"role": "user", "content": "多少钱"},
                {"role": "assistant", "content": "课程只要3999元"},
                {"role": "user", "content": "有优惠吗"},
                {"role": "assistant", "content": "现在报名只要3999"},
            ],
            session_id="wxid_price",
            status="approved",
            human_category="sales",
            human_question="多少钱",
            human_answer="课程只要3999元",
        )
        self.verified_article = KnowledgeArticle(
            scene="零基础能不能学",
            scene_category="course",
            customer_says="零基础可以学吗",
            recommended_response="可以 从Python讲起",
            source_type="labeled",
            is_verified=True,
            confidence=0.9,
            source_session_id="wxid_should_not_leak",
        )
        self.draft_article = KnowledgeArticle(
            scene="未验证草稿",
            scene_category="sales",
            customer_says="随便问问",
            recommended_response="草稿回复",
            source_type="chat",
            is_verified=False,
            confidence=0.4,
        )
        self.labeled_chunk = KnowledgeChunk(
            topic_summary="课程咨询",
            content_block="已标注对话块",
            chunk_type="labeled",
            session_id="wxid_should_not_leak",
        )
        self.custom = CustomConversation(
            conversation_json=_conversation_turns(),
            category="course",
            quality="high",
            is_active=True,
        )
        self.db.add_all([
            self.approved,
            self.pending,
            self.priced,
            self.verified_article,
            self.draft_article,
            self.labeled_chunk,
            self.custom,
        ])
        self.db.commit()

    def tearDown(self):
        self.patcher.stop()
        self.db.close()

    def test_list_articles_defaults_to_verified_only(self):
        result = list_knowledge_articles()
        scenes = [item["scene"] for item in result["items"]]
        self.assertEqual(scenes, ["零基础能不能学"])
        self.assertEqual(result["total"], 1)
        self.assertEqual(assert_no_internal_fields(result), [])

    def test_get_article_strips_source_session(self):
        result = get_knowledge_article(self.verified_article.id)
        self.assertEqual(result["scene"], "零基础能不能学")
        self.assertNotIn("source_session_id", result)
        self.assertEqual(assert_no_internal_fields(result), [])

    def test_preview_export_only_approved_and_caps_limit(self):
        result = preview_approved_training_data(format="sharegpt", limit=100)

        self.assertEqual(result["limit"], MAX_EXPORT_LIMIT)
        self.assertLessEqual(result["returned"], MAX_EXPORT_LIMIT)
        dumped = str(result)
        self.assertNotIn("待审核", dumped)
        self.assertNotIn("wxid_should_not_leak", dumped)
        self.assertNotIn("original_text", dumped)
        self.assertGreaterEqual(result["returned"], 1)
        self.assertEqual(assert_no_internal_fields(result), [])

    def test_preview_export_excludes_price_data_by_default(self):
        result = preview_approved_training_data(format="rag", exclude_price_data=True)
        dumped = str(result)
        self.assertNotIn("3999", dumped)

    def test_export_rag_entries_are_paginated(self):
        first = export_approved_rag_entries(limit=1, offset=0)
        self.assertEqual(first["returned"], 1)
        self.assertEqual(first["format"], "rag")
        self.assertIn("question", first["items"][0])
        self.assertEqual(assert_no_internal_fields(first), [])

    def test_corpus_stats_count_approved_only(self):
        stats = get_knowledge_corpus_stats()
        self.assertEqual(stats["verified_articles"], 1)
        self.assertEqual(stats["labeled_chunks"], 1)
        self.assertEqual(stats["approved_conversations"], 2)
        self.assertEqual(stats["custom_conversations"], 1)

    @patch("app.mcp.tools.retrieve.RAGService.retrieve")
    def test_retrieve_tool_prefers_serialized_articles(self, mock_retrieve):
        mock_retrieve.return_value = (
            [{
                "id": 1,
                "scene": "零基础能不能学",
                "is_verified": True,
                "source_type": "labeled",
                "source_session_id": "wxid_abc",
                "embedding": [0.1],
                "similarity": 0.93,
            }],
            [{
                "id": 9,
                "content_block": "chat fallback",
                "source": "labeled",
                "session_id": "wxid_abc",
                "source_ids": [1],
                "similarity": 0.4,
            }],
        )
        result = retrieve_sales_knowledge("零基础")
        mock_retrieve.assert_called_once()
        kwargs = mock_retrieve.call_args.kwargs
        self.assertTrue(kwargs["verified_only"])
        self.assertTrue(kwargs["labeled_chunks_only"])
        self.assertEqual(result["articles"][0]["scene"], "零基础能不能学")
        self.assertEqual(len(result["articles"]), 1)
        self.assertEqual(assert_no_internal_fields(result), [])


class McpAuthTests(unittest.TestCase):
    def _client(self, api_key: str):
        async def ok(_request):
            return JSONResponse({"ok": True})

        app = Starlette(
            routes=[Route("/", ok)],
            middleware=[Middleware(McpBearerAuthMiddleware)],
        )
        settings = type("Settings", (), {"mcp_api_key": api_key})()
        patcher = patch("app.mcp.auth.get_settings", return_value=settings)
        patcher.start()
        self.addCleanup(patcher.stop)
        return TestClient(app)

    def test_rejects_missing_or_wrong_bearer_token(self):
        client = self._client("secret-token")
        self.assertEqual(client.get("/").status_code, 401)
        self.assertEqual(
            client.get("/", headers={"Authorization": "Bearer wrong"}).status_code,
            401,
        )

    def test_accepts_matching_bearer_token(self):
        client = self._client("secret-token")
        response = client.get("/", headers={"Authorization": "Bearer secret-token"})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), {"ok": True})


if __name__ == "__main__":
    unittest.main()
