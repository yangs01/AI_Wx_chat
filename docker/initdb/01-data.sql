--
-- PostgreSQL database dump
--

\restrict a4bhPPdMHnwCjhiZFdouKYZuKF7EZ4jD0QnCdDRarNE4Qbz134PpadSjWC9p5kp

-- Dumped from database version 17.10 (Homebrew)
-- Dumped by pg_dump version 17.10 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: vector; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;


--
-- Name: EXTENSION vector; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION vector IS 'vector data type and ivfflat and hnsw access methods';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contacts (
    id integer NOT NULL,
    wxid character varying(100) NOT NULL,
    alias character varying(100),
    nickname character varying(200),
    remark character varying(200),
    display_name character varying(200),
    avatar_url text,
    is_chatroom boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- Name: custom_conversations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_conversations (
    id integer NOT NULL,
    conversation_json jsonb NOT NULL,
    category character varying(50),
    quality character varying(20),
    system_prompt text,
    title character varying(200),
    description text,
    tags jsonb,
    source character varying(100),
    created_by character varying(100),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    is_active boolean
);


--
-- Name: custom_conversations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.custom_conversations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_conversations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.custom_conversations_id_seq OWNED BY public.custom_conversations.id;


--
-- Name: knowledge_articles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knowledge_articles (
    id integer NOT NULL,
    scene text NOT NULL,
    scene_category character varying(50),
    customer_says text,
    recommended_response text,
    key_points jsonb,
    embedding public.vector(1024),
    source_chunk_id integer,
    source_session_id character varying(100),
    source_type character varying(20),
    confidence double precision,
    is_verified boolean,
    created_at timestamp without time zone
);


--
-- Name: knowledge_articles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knowledge_articles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledge_articles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knowledge_articles_id_seq OWNED BY public.knowledge_articles.id;


--
-- Name: knowledge_chunks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knowledge_chunks (
    id integer NOT NULL,
    topic_summary text,
    content_block text NOT NULL,
    embedding public.vector(1024),
    source_ids jsonb,
    session_id character varying(100),
    start_time bigint,
    end_time bigint,
    keywords jsonb,
    entities jsonb,
    chunk_type character varying(50),
    created_at timestamp without time zone
);


--
-- Name: knowledge_chunks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knowledge_chunks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledge_chunks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knowledge_chunks_id_seq OWNED BY public.knowledge_chunks.id;


--
-- Name: labeled_conversations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.labeled_conversations (
    id integer NOT NULL,
    conversation_text text NOT NULL,
    conversation_json jsonb,
    session_id character varying(100),
    source_message_ids jsonb,
    start_time bigint,
    end_time bigint,
    auto_category character varying(50),
    auto_quality_score double precision,
    auto_flags jsonb,
    human_category character varying(50),
    human_quality character varying(20),
    human_notes text,
    modified_text text,
    status character varying(20),
    labeled_by character varying(100),
    labeled_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: labeled_conversations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.labeled_conversations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: labeled_conversations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.labeled_conversations_id_seq OWNED BY public.labeled_conversations.id;


--
-- Name: materials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.materials (
    id integer NOT NULL,
    filename character varying(200) NOT NULL,
    stored_name character varying(200) NOT NULL,
    file_size bigint,
    file_type character varying(100),
    category character varying(50) NOT NULL,
    title character varying(200),
    description text,
    remark character varying(500),
    tags jsonb,
    uploaded_by character varying(100),
    download_count integer,
    oss_key character varying(500),
    source_material_id integer,
    is_pre_masked boolean,
    folder_id integer,
    created_at timestamp without time zone
);


--
-- Name: materials_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.materials_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: materials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.materials_id_seq OWNED BY public.materials.id;


--
-- Name: quiz_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quiz_attempts (
    id integer NOT NULL,
    quiz_id integer NOT NULL,
    user_answers_json jsonb,
    ai_evaluation_json jsonb,
    ai_total_score double precision,
    human_score double precision,
    human_feedback text,
    status character varying(20),
    created_at timestamp without time zone,
    submitted_at timestamp without time zone,
    graded_at timestamp without time zone
);


--
-- Name: quiz_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.quiz_attempts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quiz_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.quiz_attempts_id_seq OWNED BY public.quiz_attempts.id;


--
-- Name: quizzes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quizzes (
    id integer NOT NULL,
    title character varying(200) NOT NULL,
    category character varying(50),
    questions_json jsonb NOT NULL,
    question_count integer,
    status character varying(20),
    created_at timestamp without time zone
);


--
-- Name: quizzes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.quizzes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quizzes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.quizzes_id_seq OWNED BY public.quizzes.id;


--
-- Name: raw_chats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.raw_chats (
    id integer NOT NULL,
    local_id integer,
    session_id character varying(100) NOT NULL,
    sender_wxid character varying(100),
    sender_name character varying(200),
    content text,
    msg_type integer,
    is_sender boolean,
    "timestamp" bigint NOT NULL,
    display_content text,
    extra_data jsonb,
    source_db character varying(20),
    msg_server_id bigint,
    voice_path character varying(300),
    created_at timestamp without time zone,
    status character varying(20),
    clean_content text,
    auto_category character varying(50),
    auto_flags jsonb,
    reviewed_by character varying(100),
    reviewed_at timestamp without time zone
);


--
-- Name: raw_chats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.raw_chats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: raw_chats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.raw_chats_id_seq OWNED BY public.raw_chats.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id integer NOT NULL,
    session_id character varying(100) NOT NULL,
    display_name character varying(200),
    is_chatroom boolean,
    last_message text,
    last_time bigint,
    message_count integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: staging_conversations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staging_conversations (
    id integer NOT NULL,
    original_text text NOT NULL,
    cleaned_text text,
    conversation_json jsonb,
    session_id character varying(100) NOT NULL,
    source_message_ids jsonb,
    start_time bigint,
    end_time bigint,
    auto_question text,
    auto_answer text,
    auto_category character varying(50),
    auto_quality_score double precision,
    auto_flags jsonb,
    human_question text,
    human_answer text,
    human_category character varying(50),
    human_notes text,
    status character varying(20),
    reviewed_by character varying(100),
    reviewed_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: staging_conversations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.staging_conversations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: staging_conversations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.staging_conversations_id_seq OWNED BY public.staging_conversations.id;


--
-- Name: student_info_bindings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.student_info_bindings (
    id integer NOT NULL,
    student_id integer NOT NULL,
    material_id integer NOT NULL,
    is_primary boolean,
    sort_order integer,
    created_at timestamp without time zone
);


--
-- Name: student_info_bindings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.student_info_bindings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: student_info_bindings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.student_info_bindings_id_seq OWNED BY public.student_info_bindings.id;


--
-- Name: student_report_bindings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.student_report_bindings (
    id integer NOT NULL,
    student_id integer NOT NULL,
    material_id integer NOT NULL,
    is_primary boolean,
    sort_order integer,
    created_at timestamp without time zone
);


--
-- Name: student_report_bindings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.student_report_bindings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: student_report_bindings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.student_report_bindings_id_seq OWNED BY public.student_report_bindings.id;


--
-- Name: students; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.students (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    channel character varying(20),
    job_title character varying(100),
    pre_salary character varying(50),
    post_salary character varying(50),
    bday character varying(20),
    city character varying(100),
    education character varying(50),
    graduation_cohort character varying(50),
    enroll_date character varying(20),
    graduation_date character varying(20),
    phone character varying(20),
    douyin_order character varying(100),
    class_name character varying(100),
    main_report_material_id integer,
    status character varying(20),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    main_info_material_id integer
);


--
-- Name: students_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.students_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: students_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.students_id_seq OWNED BY public.students.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    hashed_password character varying(128) NOT NULL,
    nickname character varying(50),
    role character varying(20) NOT NULL,
    is_active boolean NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: COLUMN users.username; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.username IS '用户名';


--
-- Name: COLUMN users.hashed_password; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.hashed_password IS '加密后的密码';


--
-- Name: COLUMN users.nickname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.nickname IS '显示昵称';


--
-- Name: COLUMN users.role; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.role IS '角色: user/admin';


--
-- Name: COLUMN users.is_active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.is_active IS '是否启用';


--
-- Name: COLUMN users.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.created_at IS '创建时间';


--
-- Name: COLUMN users.updated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.updated_at IS '更新时间';


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- Name: custom_conversations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_conversations ALTER COLUMN id SET DEFAULT nextval('public.custom_conversations_id_seq'::regclass);


--
-- Name: knowledge_articles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_articles ALTER COLUMN id SET DEFAULT nextval('public.knowledge_articles_id_seq'::regclass);


--
-- Name: knowledge_chunks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_chunks ALTER COLUMN id SET DEFAULT nextval('public.knowledge_chunks_id_seq'::regclass);


--
-- Name: labeled_conversations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.labeled_conversations ALTER COLUMN id SET DEFAULT nextval('public.labeled_conversations_id_seq'::regclass);


--
-- Name: materials id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.materials ALTER COLUMN id SET DEFAULT nextval('public.materials_id_seq'::regclass);


--
-- Name: quiz_attempts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quiz_attempts ALTER COLUMN id SET DEFAULT nextval('public.quiz_attempts_id_seq'::regclass);


--
-- Name: quizzes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quizzes ALTER COLUMN id SET DEFAULT nextval('public.quizzes_id_seq'::regclass);


--
-- Name: raw_chats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.raw_chats ALTER COLUMN id SET DEFAULT nextval('public.raw_chats_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: staging_conversations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staging_conversations ALTER COLUMN id SET DEFAULT nextval('public.staging_conversations_id_seq'::regclass);


--
-- Name: student_info_bindings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_info_bindings ALTER COLUMN id SET DEFAULT nextval('public.student_info_bindings_id_seq'::regclass);


--
-- Name: student_report_bindings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_report_bindings ALTER COLUMN id SET DEFAULT nextval('public.student_report_bindings_id_seq'::regclass);


--
-- Name: students id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students ALTER COLUMN id SET DEFAULT nextval('public.students_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: contacts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.contacts (id, wxid, alias, nickname, remark, display_name, avatar_url, is_chatroom, created_at, updated_at) FROM stdin;
8606	wxid_zhangwei01	zhangwei_ai	张伟	张伟-想学AI	张伟-想学AI	\N	f	2026-05-25 10:44:38.333355	2026-05-25 10:44:38.333361
8607	wxid_lina02	lina_design	李娜	李娜-转行咨询	李娜-转行咨询	\N	f	2026-05-25 10:44:38.333362	2026-05-25 10:44:38.333363
8608	wxid_wangfang03	wangfang88	王芳	王芳-宝妈	王芳-宝妈	\N	f	2026-05-25 10:44:38.333364	2026-05-25 10:44:38.333365
8609	wxid_liuyang04	liuyang_dev	刘洋	刘洋-程序员	刘洋-程序员	\N	f	2026-05-25 10:44:38.333366	2026-05-25 10:44:38.333367
8610	wxid_chenxi05	chenxi_pm	陈曦	陈曦-产品经理	陈曦-产品经理	\N	f	2026-05-25 10:44:38.333368	2026-05-25 10:44:38.333369
8611	wxid_zhaolei06	zhaolei_fin	赵磊	赵磊-金融行业	赵磊-金融行业	\N	f	2026-05-25 10:44:38.33337	2026-05-25 10:44:38.333372
8612	wxid_sunli07	sunli_hr	孙丽	孙丽-HR转行	孙丽-HR转行	\N	f	2026-05-25 10:44:38.333373	2026-05-25 10:44:38.333374
8613	wxid_zhoujie08	zhoujie_stu	周杰	周杰-应届生	周杰-应届生	\N	f	2026-05-25 10:44:38.333375	2026-05-25 10:44:38.333376
8614	wxid_wumin09	wumin_teach	吴敏	吴敏-老师	吴敏-老师	\N	f	2026-05-25 10:44:38.333377	2026-05-25 10:44:38.333378
8615	wxid_huanghai10	huanghai_sale	黄海	黄海-销售	黄海-销售	\N	f	2026-05-25 10:44:38.333378	2026-05-25 10:44:38.333379
8616	wxid_tangyan11	tangyan_nurse	唐燕	唐燕-护士转行	唐燕-护士转行	\N	f	2026-05-25 10:44:38.33338	2026-05-25 10:44:38.333381
8617	wxid_hejun12	hejun_arch	何军	何军-建筑师	何军-建筑师	\N	f	2026-05-25 10:44:38.333382	2026-05-25 10:44:38.333383
8618	wxid_guofei13	guofei_media	郭飞	郭飞-自媒体	郭飞-自媒体	\N	f	2026-05-25 10:44:38.333384	2026-05-25 10:44:38.333385
8619	wxid_xulei14	xulei_driver	徐磊	徐磊-司机转行	徐磊-司机转行	\N	f	2026-05-25 10:44:38.333386	2026-05-25 10:44:38.333387
8620	wxid_malin15	malin_acct	马琳	马琳-会计	马琳-会计	\N	f	2026-05-25 10:44:38.333388	2026-05-25 10:44:38.333389
8621	wxid_songwei16	songwei_grad	宋伟	宋伟-研究生	宋伟-研究生	\N	f	2026-05-25 10:44:38.33339	2026-05-25 10:44:38.333391
8622	wxid_dengxia17	dengxia_shop	邓霞	邓霞-电商运营	邓霞-电商运营	\N	f	2026-05-25 10:44:38.333392	2026-05-25 10:44:38.333393
8623	wxid_caojie18	caojie_mech	曹杰	曹杰-机械工程师	曹杰-机械工程师	\N	f	2026-05-25 10:44:38.333394	2026-05-25 10:44:38.333394
8624	wxid_fengli19	fengli_art	冯丽	冯丽-美术老师	冯丽-美术老师	\N	f	2026-05-25 10:44:38.333395	2026-05-25 10:44:38.333396
8625	wxid_panyu20	panyu_law	潘宇	潘宇-律师	潘宇-律师	\N	f	2026-05-25 10:44:38.333397	2026-05-25 10:44:38.333398
8626	wxid_yeling21	yeling_food	叶玲	叶玲-餐饮老板	叶玲-餐饮老板	\N	f	2026-05-25 10:44:38.3334	2026-05-25 10:44:38.333401
\.


--
-- Data for Name: custom_conversations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.custom_conversations (id, conversation_json, category, quality, system_prompt, title, description, tags, source, created_by, created_at, updated_at, is_active) FROM stdin;
\.


--
-- Data for Name: knowledge_articles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.knowledge_articles (id, scene, scene_category, customer_says, recommended_response, key_points, embedding, source_chunk_id, source_session_id, source_type, confidence, is_verified, created_at) FROM stdin;
\.


--
-- Data for Name: knowledge_chunks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.knowledge_chunks (id, topic_summary, content_block, embedding, source_ids, session_id, start_time, end_time, keywords, entities, chunk_type, created_at) FROM stdin;
\.


--
-- Data for Name: labeled_conversations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.labeled_conversations (id, conversation_text, conversation_json, session_id, source_message_ids, start_time, end_time, auto_category, auto_quality_score, auto_flags, human_category, human_quality, human_notes, modified_text, status, labeled_by, labeled_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: materials; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.materials (id, filename, stored_name, file_size, file_type, category, title, description, remark, tags, uploaded_by, download_count, oss_key, source_material_id, is_pre_masked, folder_id, created_at) FROM stdin;
\.


--
-- Data for Name: quiz_attempts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.quiz_attempts (id, quiz_id, user_answers_json, ai_evaluation_json, ai_total_score, human_score, human_feedback, status, created_at, submitted_at, graded_at) FROM stdin;
\.


--
-- Data for Name: quizzes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.quizzes (id, title, category, questions_json, question_count, status, created_at) FROM stdin;
\.


--
-- Data for Name: raw_chats; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.raw_chats (id, local_id, session_id, sender_wxid, sender_name, content, msg_type, is_sender, "timestamp", display_content, extra_data, source_db, msg_server_id, voice_path, created_at, status, clean_content, auto_category, auto_flags, reviewed_by, reviewed_at) FROM stdin;
180099	133	wxid_sunli07	wxid_sunli07	孙丽-HR转行	老师我是开网约车的，学历不高，能学AI吗	1	f	1760519078	\N	\N	MSG0	9000000000000000132	\N	2026-05-25 10:44:38.34922	pending	\N	\N	\N	\N	\N
180100	134	wxid_sunli07	self	我	能学！我们有好几个学员之前也是类似背景。AI应用开发不需要特别高的学历，关键是动手能力和学习意愿。你愿意花时间学，就一定能学会	1	t	1760519144	\N	\N	MSG0	9000000000000000133	\N	2026-05-25 10:44:38.349223	pending	\N	\N	\N	\N	\N
180101	137	wxid_sunli07	wxid_sunli07	孙丽-HR转行	那我试试吧	1	f	1760519274	\N	\N	MSG0	9000000000000000136	\N	2026-05-25 10:44:38.349225	pending	\N	\N	\N	\N	\N
180102	136	wxid_sunli07	self	我	我们有专门的基础班，进度比较慢，讲得更细。而且有1对1辅导，卡住了随时问。你先试学7天，觉得跟不上全额退款，没有任何风险	1	t	1760519288	\N	\N	MSG0	9000000000000000135	\N	2026-05-25 10:44:38.349226	pending	\N	\N	\N	\N	\N
180103	135	wxid_sunli07	wxid_sunli07	孙丽-HR转行	我怕自己跟不上	1	f	1760519302	\N	\N	MSG0	9000000000000000134	\N	2026-05-25 10:44:38.349228	pending	\N	\N	\N	\N	\N
180104	138	wxid_sunli07	self	我	好的！我给你安排基础班，导师会特别关注你的学习进度。很多人一开始觉得难，坚持两周就上手了，加油💪	1	t	1760519638	\N	\N	MSG0	9000000000000000137	\N	2026-05-25 10:44:38.349229	pending	\N	\N	\N	\N	\N
180105	275	wxid_yeling21	wxid_yeling21	叶玲-餐饮老板	我做建筑设计的，想了解AI能不能用在我们行业	1	f	1760765402	\N	\N	MSG0	9000000000000000274	\N	2026-05-25 10:44:38.34923	pending	\N	\N	\N	\N	\N
180106	276	wxid_yeling21	self	我	太能了！AI辅助设计、智能BIM、参数化建筑这些方向现在很火。学完课程你可以开发自己的AI设计工具，在行业里会非常有竞争力	1	t	1760765470	\N	\N	MSG0	9000000000000000275	\N	2026-05-25 10:44:38.349231	pending	\N	\N	\N	\N	\N
180107	277	wxid_yeling21	wxid_yeling21	叶玲-餐饮老板	需要学多久才能用到工作中	1	f	1760765512	\N	\N	MSG0	9000000000000000276	\N	2026-05-25 10:44:38.349233	pending	\N	\N	\N	\N	\N
180108	278	wxid_yeling21	self	我	基础模块2-3周学完就能用一些AI工具了。完整学完3个月，你可以自己搭建AI辅助设计的workflow，比如用AI生成方案、自动出图等	1	t	1760765591	\N	\N	MSG0	9000000000000000277	\N	2026-05-25 10:44:38.349234	pending	\N	\N	\N	\N	\N
180109	231	wxid_wumin09	wxid_wumin09	吴敏-老师	我是护士，工作太累了想转行，AI行业适合我吗	1	f	1760840209	\N	\N	MSG0	9000000000000000230	\N	2026-05-25 10:44:38.349235	pending	\N	\N	\N	\N	\N
180110	233	wxid_wumin09	wxid_wumin09	吴敏-老师	但我完全不懂编程啊	1	f	1760840337	\N	\N	MSG0	9000000000000000232	\N	2026-05-25 10:44:38.349236	pending	\N	\N	\N	\N	\N
180111	232	wxid_wumin09	self	我	适合的！医疗+AI现在是热门方向，比如智能导诊、病历分析、医学影像AI。你有医疗背景反而是优势，很多AI医疗公司特别需要懂业务的人	1	t	1760840389	\N	\N	MSG0	9000000000000000231	\N	2026-05-25 10:44:38.349237	pending	\N	\N	\N	\N	\N
180112	234	wxid_wumin09	self	我	没关系，我们很多学员都是零基础。课程从最基础的Python开始教，而且有专门的入门衔接课。护士姐姐逻辑思维都不差的，学起来比你想象的快	1	t	1760840677	\N	\N	MSG0	9000000000000000233	\N	2026-05-25 10:44:38.349239	pending	\N	\N	\N	\N	\N
180113	235	wxid_wumin09	wxid_wumin09	吴敏-老师	学完能做什么岗位	1	f	1760840705	\N	\N	MSG0	9000000000000000234	\N	2026-05-25 10:44:38.34924	pending	\N	\N	\N	\N	\N
180114	236	wxid_wumin09	self	我	AI产品经理、医疗AI运营、数据标注项目经理这些都很适合你。薪资比护士高不少，而且不用上夜班了	1	t	1760840714	\N	\N	MSG0	9000000000000000235	\N	2026-05-25 10:44:38.349241	pending	\N	\N	\N	\N	\N
180115	127	wxid_fengli19	wxid_fengli19	冯丽-美术老师	我开了3家奶茶店，想用AI来管理运营，有什么建议吗	1	f	1760875793	\N	\N	MSG0	9000000000000000126	\N	2026-05-25 10:44:38.349242	pending	\N	\N	\N	\N	\N
180116	130	wxid_fengli19	self	我	有！你可以先学模块1和2，掌握Python和数据分析就够用了。大概4-6周的时间，就能自己写脚本分析销售数据、预测备货量这些	1	t	1760875949	\N	\N	MSG0	9000000000000000129	\N	2026-05-25 10:44:38.349243	pending	\N	\N	\N	\N	\N
180117	128	wxid_fengli19	self	我	AI在餐饮的应用很多！智能排班、销量预测、自动化营销、客户分析这些都能做。学完课程你可以搭建自己的数据分析系统，比请一个数据分析师便宜多了	1	t	1760875964	\N	\N	MSG0	9000000000000000127	\N	2026-05-25 10:44:38.349244	pending	\N	\N	\N	\N	\N
180118	129	wxid_fengli19	wxid_fengli19	冯丽-美术老师	我不需要那么深入，有没有轻量级的方案	1	f	1760876139	\N	\N	MSG0	9000000000000000128	\N	2026-05-25 10:44:38.349245	pending	\N	\N	\N	\N	\N
180119	132	wxid_fengli19	self	我	单独学前两个模块的话2666，但我建议你报全课程4666，因为后面的AI应用模块对你做自动化营销特别有用，性价比更高	1	t	1760876418	\N	\N	MSG0	9000000000000000131	\N	2026-05-25 10:44:38.349247	pending	\N	\N	\N	\N	\N
180120	131	wxid_fengli19	wxid_fengli19	冯丽-美术老师	这个实用，多少钱	1	f	1760876469	\N	\N	MSG0	9000000000000000130	\N	2026-05-25 10:44:38.349248	pending	\N	\N	\N	\N	\N
180121	237	wxid_sunli07	wxid_sunli07	孙丽-HR转行	我决定报名了，怎么付款	1	f	1760955589	\N	\N	MSG0	9000000000000000236	\N	2026-05-25 10:44:38.349249	pending	\N	\N	\N	\N	\N
180122	238	wxid_sunli07	self	我	太好了！我发你报名链接，支持微信支付、支付宝、银行卡都行。你想一次性付还是分期呀	1	t	1760955645	\N	\N	MSG0	9000000000000000237	\N	2026-05-25 10:44:38.34925	pending	\N	\N	\N	\N	\N
180123	239	wxid_sunli07	wxid_sunli07	孙丽-HR转行	微信支付吧，一次性付	1	f	1760955653	\N	\N	MSG0	9000000000000000238	\N	2026-05-25 10:44:38.349251	pending	\N	\N	\N	\N	\N
180124	242	wxid_sunli07	self	我	收到啦！欢迎加入第12期训练营🎉 我已经把你拉进班级群了，你的专属导师是王老师。本周六晚8点有开营直播，记得来哦！学习资料我稍后私发你	1	t	1760955854	\N	\N	MSG0	9000000000000000241	\N	2026-05-25 10:44:38.349252	pending	\N	\N	\N	\N	\N
180125	240	wxid_sunli07	self	我	好的，付款码发你了～确认收款后我马上拉你进班级群，把学习账号和资料包发给你	1	t	1760955871	\N	\N	MSG0	9000000000000000239	\N	2026-05-25 10:44:38.349253	pending	\N	\N	\N	\N	\N
180126	241	wxid_sunli07	wxid_sunli07	孙丽-HR转行	付好了！	1	f	1760956061	\N	\N	MSG0	9000000000000000240	\N	2026-05-25 10:44:38.349255	pending	\N	\N	\N	\N	\N
180127	99	wxid_caojie18	wxid_caojie18	曹杰-机械工程师	我是做机械设计的，感觉传统制造业越来越难了，AI能帮到我吗	1	f	1761009658	\N	\N	MSG0	9000000000000000098	\N	2026-05-25 10:44:38.349256	pending	\N	\N	\N	\N	\N
180128	102	wxid_caojie18	self	我	来得及！制造业+AI的岗位反而偏好有行业经验的人，你比应届生更懂生产线上的痛点。我们上期有个40岁的学员，之前做模具设计，现在在一家智能制造公司做AI项目经理	1	t	1761009763	\N	\N	MSG0	9000000000000000101	\N	2026-05-25 10:44:38.349257	pending	\N	\N	\N	\N	\N
180129	100	wxid_caojie18	self	我	当然！智能制造是国家重点方向，AI+制造的人才缺口很大。比如预测性维护、质量检测AI、智能排产这些，都需要懂制造又懂AI的人	1	t	1761009828	\N	\N	MSG0	9000000000000000099	\N	2026-05-25 10:44:38.349258	pending	\N	\N	\N	\N	\N
180130	101	wxid_caojie18	wxid_caojie18	曹杰-机械工程师	我都38了，还来得及吗	1	f	1761009944	\N	\N	MSG0	9000000000000000100	\N	2026-05-25 10:44:38.349259	pending	\N	\N	\N	\N	\N
180131	69	wxid_guofei13	wxid_guofei13	郭飞-自媒体	你好，我在抖音上看到你们的AI课程广告，想了解一下	1	f	1761020787	\N	\N	MSG0	9000000000000000068	\N	2026-05-25 10:44:38.34926	pending	\N	\N	\N	\N	\N
180132	70	wxid_guofei13	self	我	你好呀！感谢关注～我们这个是AI全栈实战训练营，主要教Python编程、大模型应用开发、RAG知识库搭建这些，3个月系统学习，适合零基础和想转行的同学	1	t	1761020871	\N	\N	MSG0	9000000000000000069	\N	2026-05-25 10:44:38.349261	pending	\N	\N	\N	\N	\N
180133	71	wxid_guofei13	wxid_guofei13	郭飞-自媒体	我是做运营的，完全没有编程基础，能学会吗	1	f	1761020895	\N	\N	MSG0	9000000000000000070	\N	2026-05-25 10:44:38.349262	pending	\N	\N	\N	\N	\N
180134	72	wxid_guofei13	self	我	完全可以的！我们60%的学员都是零基础转行的，课程从Python基础开始教，而且有1对1辅导，遇到问题随时问。上期有个做HR的姐姐，3个月就拿到了AI产品经理的offer	1	t	1761021195	\N	\N	MSG0	9000000000000000071	\N	2026-05-25 10:44:38.349263	pending	\N	\N	\N	\N	\N
180135	73	wxid_guofei13	wxid_guofei13	郭飞-自媒体	课程多少钱啊	1	f	1761021375	\N	\N	MSG0	9000000000000000072	\N	2026-05-25 10:44:38.349265	pending	\N	\N	\N	\N	\N
180136	74	wxid_guofei13	self	我	原价6980，现在新年活动价4666，包含全部课程+项目实战+就业辅导+终身回看。这个价格本周五截止哦	1	t	1761021377	\N	\N	MSG0	9000000000000000073	\N	2026-05-25 10:44:38.349266	pending	\N	\N	\N	\N	\N
180137	109	wxid_panyu20	wxid_panyu20	潘宇-律师	我做电商运营的，想学AI来提升工作效率，有针对电商的内容吗	1	f	1761107398	\N	\N	MSG0	9000000000000000108	\N	2026-05-25 10:44:38.349267	pending	\N	\N	\N	\N	\N
180138	110	wxid_panyu20	self	我	有的！课程里有推荐系统和用户画像的项目，跟电商直接相关。学完你可以搭建智能选品系统、自动化客服、个性化推荐这些	1	t	1761107449	\N	\N	MSG0	9000000000000000109	\N	2026-05-25 10:44:38.349268	pending	\N	\N	\N	\N	\N
180139	111	wxid_panyu20	wxid_panyu20	潘宇-律师	我们老板也想让团队学AI，能不能定制企业培训	1	f	1761107688	\N	\N	MSG0	9000000000000000110	\N	2026-05-25 10:44:38.349269	pending	\N	\N	\N	\N	\N
180140	112	wxid_panyu20	self	我	可以的！我们有企业定制方案，可以根据你们电商业务场景设计专属课程内容。我发你企业培训的介绍看看？	1	t	1761107698	\N	\N	MSG0	9000000000000000111	\N	2026-05-25 10:44:38.349271	pending	\N	\N	\N	\N	\N
180141	113	wxid_panyu20	wxid_panyu20	潘宇-律师	好的发我	1	f	1761107882	\N	\N	MSG0	9000000000000000112	\N	2026-05-25 10:44:38.349272	pending	\N	\N	\N	\N	\N
180142	114	wxid_panyu20	self	我	发你了！里面有电商行业的AI应用案例和培训方案。你跟老板商量下，我们可以安排一次免费的需求沟通会	1	t	1761107948	\N	\N	MSG0	9000000000000000113	\N	2026-05-25 10:44:38.349273	pending	\N	\N	\N	\N	\N
180143	121	wxid_liuyang04	wxid_liuyang04	刘洋-程序员	我决定报名了，怎么付款	1	f	1761280269	\N	\N	MSG0	9000000000000000120	\N	2026-05-25 10:44:38.349274	pending	\N	\N	\N	\N	\N
180144	122	wxid_liuyang04	self	我	太好了！我发你报名链接，支持微信支付、支付宝、银行卡都行。你想一次性付还是分期呀	1	t	1761280439	\N	\N	MSG0	9000000000000000121	\N	2026-05-25 10:44:38.349275	pending	\N	\N	\N	\N	\N
180145	123	wxid_liuyang04	wxid_liuyang04	刘洋-程序员	微信支付吧，一次性付	1	f	1761280479	\N	\N	MSG0	9000000000000000122	\N	2026-05-25 10:44:38.349276	pending	\N	\N	\N	\N	\N
180146	124	wxid_liuyang04	self	我	好的，付款码发你了～确认收款后我马上拉你进班级群，把学习账号和资料包发给你	1	t	1761280596	\N	\N	MSG0	9000000000000000123	\N	2026-05-25 10:44:38.349277	pending	\N	\N	\N	\N	\N
180147	125	wxid_liuyang04	wxid_liuyang04	刘洋-程序员	付好了！	1	f	1761280681	\N	\N	MSG0	9000000000000000124	\N	2026-05-25 10:44:38.349278	pending	\N	\N	\N	\N	\N
180148	126	wxid_liuyang04	self	我	收到啦！欢迎加入第12期训练营🎉 我已经把你拉进班级群了，你的专属导师是王老师。本周六晚8点有开营直播，记得来哦！学习资料我稍后私发你	1	t	1761281139	\N	\N	MSG0	9000000000000000125	\N	2026-05-25 10:44:38.34928	pending	\N	\N	\N	\N	\N
180149	7	wxid_lina02	wxid_lina02	李娜-转行咨询	老师你好，我上周报名的，但是还没开始学，不知道从哪里开始	1	f	1761453509	\N	\N	MSG0	9000000000000000006	\N	2026-05-25 10:44:38.349281	pending	\N	\N	\N	\N	\N
180150	8	wxid_lina02	self	我	没问题！你先登录学习平台，从模块1第一节课开始看就行。我把直达链接发你。另外今晚8点有新生答疑直播，建议来听听，对你入门很有帮助	1	t	1761453678	\N	\N	MSG0	9000000000000000007	\N	2026-05-25 10:44:38.349282	pending	\N	\N	\N	\N	\N
180151	9	wxid_lina02	wxid_lina02	李娜-转行咨询	好的谢谢！对了学完有证书吗	1	f	1761453715	\N	\N	MSG0	9000000000000000008	\N	2026-05-25 10:44:38.349283	pending	\N	\N	\N	\N	\N
180152	12	wxid_lina02	self	我	加油💪 有任何问题随时在群里问或者私聊我都行，我们一起努力！	1	t	1761453754	\N	\N	MSG0	9000000000000000011	\N	2026-05-25 10:44:38.349284	pending	\N	\N	\N	\N	\N
180153	10	wxid_lina02	self	我	有的！完成全部课程和毕业项目后会颁发结业证书，很多同学都放在LinkedIn和简历上了。另外优秀学员还有机会获得企业内推名额	1	t	1761453878	\N	\N	MSG0	9000000000000000009	\N	2026-05-25 10:44:38.349285	pending	\N	\N	\N	\N	\N
180154	11	wxid_lina02	wxid_lina02	李娜-转行咨询	那我加油学！	1	f	1761454101	\N	\N	MSG0	9000000000000000010	\N	2026-05-25 10:44:38.349287	pending	\N	\N	\N	\N	\N
180155	39	wxid_zhoujie08	wxid_zhoujie08	周杰-应届生	我今年35了，转行AI会不会太晚了	1	f	1761553247	\N	\N	MSG0	9000000000000000038	\N	2026-05-25 10:44:38.349288	pending	\N	\N	\N	\N	\N
180156	41	wxid_zhoujie08	wxid_zhoujie08	周杰-应届生	但是面试的时候会不会被年龄歧视	1	f	1761553335	\N	\N	MSG0	9000000000000000040	\N	2026-05-25 10:44:38.349289	pending	\N	\N	\N	\N	\N
180157	40	wxid_zhoujie08	self	我	一点都不晚！我们学员年龄从22到45都有。AI领域更看重解决问题的能力，你的行业经验反而是优势——你比应届生更懂业务场景，知道AI该用在哪里	1	t	1761553385	\N	\N	MSG0	9000000000000000039	\N	2026-05-25 10:44:38.34929	pending	\N	\N	\N	\N	\N
180158	42	wxid_zhoujie08	self	我	AI产品经理、解决方案架构师、技术顾问这些岗位反而偏好有经验的人。不是所有AI岗位都要卷算法，应用层的机会非常多，而且薪资不低	1	t	1761553478	\N	\N	MSG0	9000000000000000041	\N	2026-05-25 10:44:38.349291	pending	\N	\N	\N	\N	\N
180159	43	wxid_zhoujie08	wxid_zhoujie08	周杰-应届生	那我适合什么方向	1	f	1761553703	\N	\N	MSG0	9000000000000000042	\N	2026-05-25 10:44:38.349292	pending	\N	\N	\N	\N	\N
180160	44	wxid_zhoujie08	self	我	根据你的金融背景，AI+金融方向很适合你。比如智能风控、量化分析、金融知识库这些。我们课程里有金融场景的项目实战，学完直接能用	1	t	1761553732	\N	\N	MSG0	9000000000000000043	\N	2026-05-25 10:44:38.349293	pending	\N	\N	\N	\N	\N
180161	219	wxid_songwei16	wxid_songwei16	宋伟-研究生	我平时上班挺忙的，996那种，怕没时间学	1	f	1761554353	\N	\N	MSG0	9000000000000000218	\N	2026-05-25 10:44:38.349294	pending	\N	\N	\N	\N	\N
180162	220	wxid_songwei16	self	我	这个我们考虑到了！课程是录播+周末直播的模式，录播随时看，不限时间。大部分学员都是上班族，每天抽1-2小时就够了，周末集中做项目	1	t	1761554436	\N	\N	MSG0	9000000000000000219	\N	2026-05-25 10:44:38.349295	pending	\N	\N	\N	\N	\N
180163	223	wxid_songwei16	wxid_songwei16	宋伟-研究生	直播是什么时间	1	f	1761554481	\N	\N	MSG0	9000000000000000222	\N	2026-05-25 10:44:38.349297	pending	\N	\N	\N	\N	\N
180164	221	wxid_songwei16	wxid_songwei16	宋伟-研究生	那如果跟不上进度怎么办	1	f	1761554699	\N	\N	MSG0	9000000000000000220	\N	2026-05-25 10:44:38.349298	pending	\N	\N	\N	\N	\N
180165	222	wxid_songwei16	self	我	没关系的，课程终身有效，可以按自己节奏来。而且每周有答疑直播，落下的内容随时补。很多同学3个月学完，也有5-6个月慢慢学的，效果一样好	1	t	1761554725	\N	\N	MSG0	9000000000000000221	\N	2026-05-25 10:44:38.349299	pending	\N	\N	\N	\N	\N
180166	224	wxid_songwei16	self	我	每周六晚上8点到10点，主要是项目实战和答疑。如果赶不上也没关系，直播都有回放，第二天就能看	1	t	1761555068	\N	\N	MSG0	9000000000000000223	\N	2026-05-25 10:44:38.3493	pending	\N	\N	\N	\N	\N
180167	1	wxid_zhangwei01	wxid_zhangwei01	张伟-想学AI	你好，我在抖音上看到你们的AI课程广告，想了解一下	1	f	1761615977	\N	\N	MSG0	9000000000000000000	\N	2026-05-25 10:44:38.349301	pending	\N	\N	\N	\N	\N
180168	2	wxid_zhangwei01	self	我	你好呀！感谢关注～我们这个是AI全栈实战训练营，主要教Python编程、大模型应用开发、RAG知识库搭建这些，3个月系统学习，适合零基础和想转行的同学	1	t	1761616059	\N	\N	MSG0	9000000000000000001	\N	2026-05-25 10:44:38.349302	pending	\N	\N	\N	\N	\N
180169	3	wxid_zhangwei01	wxid_zhangwei01	张伟-想学AI	我是做运营的，完全没有编程基础，能学会吗	1	f	1761616073	\N	\N	MSG0	9000000000000000002	\N	2026-05-25 10:44:38.349303	pending	\N	\N	\N	\N	\N
180170	5	wxid_zhangwei01	wxid_zhangwei01	张伟-想学AI	课程多少钱啊	1	f	1761616109	\N	\N	MSG0	9000000000000000004	\N	2026-05-25 10:44:38.349304	pending	\N	\N	\N	\N	\N
180171	4	wxid_zhangwei01	self	我	完全可以的！我们60%的学员都是零基础转行的，课程从Python基础开始教，而且有1对1辅导，遇到问题随时问。上期有个做HR的姐姐，3个月就拿到了AI产品经理的offer	1	t	1761616175	\N	\N	MSG0	9000000000000000003	\N	2026-05-25 10:44:38.349306	pending	\N	\N	\N	\N	\N
180172	6	wxid_zhangwei01	self	我	原价6980，现在新年活动价4666，包含全部课程+项目实战+就业辅导+终身回看。这个价格本周五截止哦	1	t	1761616392	\N	\N	MSG0	9000000000000000005	\N	2026-05-25 10:44:38.349307	pending	\N	\N	\N	\N	\N
180173	179	wxid_yeling21	wxid_yeling21	叶玲-餐饮老板	我是护士，工作太累了想转行，AI行业适合我吗	1	f	1761645975	\N	\N	MSG0	9000000000000000178	\N	2026-05-25 10:44:38.349308	pending	\N	\N	\N	\N	\N
180174	180	wxid_yeling21	self	我	适合的！医疗+AI现在是热门方向，比如智能导诊、病历分析、医学影像AI。你有医疗背景反而是优势，很多AI医疗公司特别需要懂业务的人	1	t	1761646148	\N	\N	MSG0	9000000000000000179	\N	2026-05-25 10:44:38.349309	pending	\N	\N	\N	\N	\N
180175	183	wxid_yeling21	wxid_yeling21	叶玲-餐饮老板	学完能做什么岗位	1	f	1761646243	\N	\N	MSG0	9000000000000000182	\N	2026-05-25 10:44:38.34931	pending	\N	\N	\N	\N	\N
180176	181	wxid_yeling21	wxid_yeling21	叶玲-餐饮老板	但我完全不懂编程啊	1	f	1761646269	\N	\N	MSG0	9000000000000000180	\N	2026-05-25 10:44:38.349311	pending	\N	\N	\N	\N	\N
180177	182	wxid_yeling21	self	我	没关系，我们很多学员都是零基础。课程从最基础的Python开始教，而且有专门的入门衔接课。护士姐姐逻辑思维都不差的，学起来比你想象的快	1	t	1761646278	\N	\N	MSG0	9000000000000000181	\N	2026-05-25 10:44:38.349312	pending	\N	\N	\N	\N	\N
180178	184	wxid_yeling21	self	我	AI产品经理、医疗AI运营、数据标注项目经理这些都很适合你。薪资比护士高不少，而且不用上夜班了	1	t	1761646290	\N	\N	MSG0	9000000000000000183	\N	2026-05-25 10:44:38.349313	pending	\N	\N	\N	\N	\N
180179	201	wxid_panyu20	wxid_panyu20	潘宇-律师	我开了3家奶茶店，想用AI来管理运营，有什么建议吗	1	f	1761872666	\N	\N	MSG0	9000000000000000200	\N	2026-05-25 10:44:38.349314	pending	\N	\N	\N	\N	\N
180180	202	wxid_panyu20	self	我	AI在餐饮的应用很多！智能排班、销量预测、自动化营销、客户分析这些都能做。学完课程你可以搭建自己的数据分析系统，比请一个数据分析师便宜多了	1	t	1761872838	\N	\N	MSG0	9000000000000000201	\N	2026-05-25 10:44:38.349316	pending	\N	\N	\N	\N	\N
180181	205	wxid_panyu20	wxid_panyu20	潘宇-律师	这个实用，多少钱	1	f	1761872974	\N	\N	MSG0	9000000000000000204	\N	2026-05-25 10:44:38.349317	pending	\N	\N	\N	\N	\N
180182	203	wxid_panyu20	wxid_panyu20	潘宇-律师	我不需要那么深入，有没有轻量级的方案	1	f	1761873014	\N	\N	MSG0	9000000000000000202	\N	2026-05-25 10:44:38.349318	pending	\N	\N	\N	\N	\N
180183	204	wxid_panyu20	self	我	有！你可以先学模块1和2，掌握Python和数据分析就够用了。大概4-6周的时间，就能自己写脚本分析销售数据、预测备货量这些	1	t	1761873170	\N	\N	MSG0	9000000000000000203	\N	2026-05-25 10:44:38.349319	pending	\N	\N	\N	\N	\N
180184	206	wxid_panyu20	self	我	单独学前两个模块的话2666，但我建议你报全课程4666，因为后面的AI应用模块对你做自动化营销特别有用，性价比更高	1	t	1761873456	\N	\N	MSG0	9000000000000000205	\N	2026-05-25 10:44:38.34932	pending	\N	\N	\N	\N	\N
180185	291	wxid_zhangwei01	wxid_zhangwei01	张伟-想学AI	老师我学了一周了，感觉Python语法好多记不住怎么办	1	f	1762067508	\N	\N	MSG0	9000000000000000290	\N	2026-05-25 10:44:38.349321	pending	\N	\N	\N	\N	\N
180186	292	wxid_zhangwei01	self	我	很正常！刚开始不用死记语法，重要的是理解逻辑。建议你：1）跟着视频敲代码，别光看；2）每天花20分钟复习前一天的内容；3）遇到不懂的先记下来，答疑课上问	1	t	1762067589	\N	\N	MSG0	9000000000000000291	\N	2026-05-25 10:44:38.349322	pending	\N	\N	\N	\N	\N
180187	293	wxid_zhangwei01	wxid_zhangwei01	张伟-想学AI	我是不是太笨了，别人好像学得比我快	1	f	1762067612	\N	\N	MSG0	9000000000000000292	\N	2026-05-25 10:44:38.349323	pending	\N	\N	\N	\N	\N
180188	295	wxid_zhangwei01	wxid_zhangwei01	张伟-想学AI	谢谢老师鼓励，我继续加油	1	f	1762067716	\N	\N	MSG0	9000000000000000294	\N	2026-05-25 10:44:38.349324	pending	\N	\N	\N	\N	\N
180189	294	wxid_zhangwei01	self	我	千万别这么想！每个人基础不同，学习节奏不一样很正常。我见过很多开始慢的同学后面反而学得更扎实。坚持最重要，你已经迈出第一步了，比90%的人强	1	t	1762067997	\N	\N	MSG0	9000000000000000293	\N	2026-05-25 10:44:38.349325	pending	\N	\N	\N	\N	\N
180190	296	wxid_zhangwei01	self	我	加油！有问题随时问，群里的同学也很热心互相帮助。下周的项目课会很有意思，坚持到那里你会发现编程其实挺好玩的	1	t	1762068283	\N	\N	MSG0	9000000000000000295	\N	2026-05-25 10:44:38.349327	pending	\N	\N	\N	\N	\N
180191	75	wxid_xulei14	wxid_xulei14	徐磊-司机转行	我也在看其他家的课程，你们跟XX教育比有什么优势	1	f	1762156341	\N	\N	MSG0	9000000000000000074	\N	2026-05-25 10:44:38.349328	pending	\N	\N	\N	\N	\N
180192	76	wxid_xulei14	self	我	好问题！主要3个差异：\n1）我们是小班制（每期30人），他们大班200+人，辅导质量不一样\n2）我们的项目是真实企业需求，不是玩具demo\n3）我们提供1年就业跟踪服务，不是学完就不管了	1	t	1762156515	\N	\N	MSG0	9000000000000000075	\N	2026-05-25 10:44:38.349329	pending	\N	\N	\N	\N	\N
180193	77	wxid_xulei14	wxid_xulei14	徐磊-司机转行	他们价格比你们便宜一千多	1	f	1762156611	\N	\N	MSG0	9000000000000000076	\N	2026-05-25 10:44:38.34933	pending	\N	\N	\N	\N	\N
180194	78	wxid_xulei14	self	我	嗯价格确实有差异。但你可以对比一下：他们的课时、项目数量、辅导模式、就业服务。算下来我们的性价比其实更高。而且我们有7天无理由退款，零风险试学	1	t	1762156662	\N	\N	MSG0	9000000000000000077	\N	2026-05-25 10:44:38.349331	pending	\N	\N	\N	\N	\N
180195	79	wxid_xulei14	wxid_xulei14	徐磊-司机转行	有道理，我再对比看看	1	f	1762156677	\N	\N	MSG0	9000000000000000078	\N	2026-05-25 10:44:38.349332	pending	\N	\N	\N	\N	\N
180196	80	wxid_xulei14	self	我	好的～我把我们的详细课程对比表发你，你可以逐项对比。有问题随时问我，不管最后选哪家，选适合自己的最重要	1	t	1762157156	\N	\N	MSG0	9000000000000000079	\N	2026-05-25 10:44:38.349333	pending	\N	\N	\N	\N	\N
180197	195	wxid_yeling21	wxid_yeling21	叶玲-餐饮老板	我也在看其他家的课程，你们跟XX教育比有什么优势	1	f	1762480551	\N	\N	MSG0	9000000000000000194	\N	2026-05-25 10:44:38.349334	pending	\N	\N	\N	\N	\N
180198	196	wxid_yeling21	self	我	好问题！主要3个差异：\n1）我们是小班制（每期30人），他们大班200+人，辅导质量不一样\n2）我们的项目是真实企业需求，不是玩具demo\n3）我们提供1年就业跟踪服务，不是学完就不管了	1	t	1762480613	\N	\N	MSG0	9000000000000000195	\N	2026-05-25 10:44:38.349336	pending	\N	\N	\N	\N	\N
180199	197	wxid_yeling21	wxid_yeling21	叶玲-餐饮老板	他们价格比你们便宜一千多	1	f	1762480615	\N	\N	MSG0	9000000000000000196	\N	2026-05-25 10:44:38.349337	pending	\N	\N	\N	\N	\N
180200	200	wxid_yeling21	self	我	好的～我把我们的详细课程对比表发你，你可以逐项对比。有问题随时问我，不管最后选哪家，选适合自己的最重要	1	t	1762480771	\N	\N	MSG0	9000000000000000199	\N	2026-05-25 10:44:38.349338	pending	\N	\N	\N	\N	\N
180201	199	wxid_yeling21	wxid_yeling21	叶玲-餐饮老板	有道理，我再对比看看	1	f	1762480807	\N	\N	MSG0	9000000000000000198	\N	2026-05-25 10:44:38.349339	pending	\N	\N	\N	\N	\N
180202	198	wxid_yeling21	self	我	嗯价格确实有差异。但你可以对比一下：他们的课时、项目数量、辅导模式、就业服务。算下来我们的性价比其实更高。而且我们有7天无理由退款，零风险试学	1	t	1762480935	\N	\N	MSG0	9000000000000000197	\N	2026-05-25 10:44:38.34934	pending	\N	\N	\N	\N	\N
180203	167	wxid_hejun12	wxid_hejun12	何军-建筑师	我也在看其他家的课程，你们跟XX教育比有什么优势	1	f	1762486058	\N	\N	MSG0	9000000000000000166	\N	2026-05-25 10:44:38.349341	pending	\N	\N	\N	\N	\N
180204	168	wxid_hejun12	self	我	好问题！主要3个差异：\n1）我们是小班制（每期30人），他们大班200+人，辅导质量不一样\n2）我们的项目是真实企业需求，不是玩具demo\n3）我们提供1年就业跟踪服务，不是学完就不管了	1	t	1762486115	\N	\N	MSG0	9000000000000000167	\N	2026-05-25 10:44:38.349343	pending	\N	\N	\N	\N	\N
180205	170	wxid_hejun12	self	我	嗯价格确实有差异。但你可以对比一下：他们的课时、项目数量、辅导模式、就业服务。算下来我们的性价比其实更高。而且我们有7天无理由退款，零风险试学	1	t	1762486325	\N	\N	MSG0	9000000000000000169	\N	2026-05-25 10:44:38.349344	pending	\N	\N	\N	\N	\N
180206	169	wxid_hejun12	wxid_hejun12	何军-建筑师	他们价格比你们便宜一千多	1	f	1762486338	\N	\N	MSG0	9000000000000000168	\N	2026-05-25 10:44:38.349345	pending	\N	\N	\N	\N	\N
180207	171	wxid_hejun12	wxid_hejun12	何军-建筑师	有道理，我再对比看看	1	f	1762486486	\N	\N	MSG0	9000000000000000170	\N	2026-05-25 10:44:38.349346	pending	\N	\N	\N	\N	\N
180208	172	wxid_hejun12	self	我	好的～我把我们的详细课程对比表发你，你可以逐项对比。有问题随时问我，不管最后选哪家，选适合自己的最重要	1	t	1762486933	\N	\N	MSG0	9000000000000000171	\N	2026-05-25 10:44:38.349347	pending	\N	\N	\N	\N	\N
180209	17	wxid_liuyang04	wxid_liuyang04	刘洋-程序员	我做了8年会计，感觉这个行业要被AI取代了，想提前转型	1	f	1762585134	\N	\N	MSG0	9000000000000000016	\N	2026-05-25 10:44:38.349348	pending	\N	\N	\N	\N	\N
180210	18	wxid_liuyang04	self	我	你的危机意识很好！确实基础会计工作在被自动化替代，但财务+AI的复合人才反而更值钱了。比如智能财务分析、自动化审计、财税AI助手这些方向	1	t	1762585250	\N	\N	MSG0	9000000000000000017	\N	2026-05-25 10:44:38.349349	pending	\N	\N	\N	\N	\N
180211	19	wxid_liuyang04	wxid_liuyang04	刘洋-程序员	那学完我能做什么	1	f	1762585398	\N	\N	MSG0	9000000000000000018	\N	2026-05-25 10:44:38.349351	pending	\N	\N	\N	\N	\N
180212	20	wxid_liuyang04	self	我	你可以做AI财务产品经理、财税AI解决方案顾问，或者在现有公司推动AI转型。薪资比纯会计高50%以上，而且不可替代性更强	1	t	1762585506	\N	\N	MSG0	9000000000000000019	\N	2026-05-25 10:44:38.349352	pending	\N	\N	\N	\N	\N
180213	51	wxid_huanghai10	wxid_huanghai10	黄海-销售	我也在看其他家的课程，你们跟XX教育比有什么优势	1	f	1762588791	\N	\N	MSG0	9000000000000000050	\N	2026-05-25 10:44:38.349353	pending	\N	\N	\N	\N	\N
180214	53	wxid_huanghai10	wxid_huanghai10	黄海-销售	他们价格比你们便宜一千多	1	f	1762588919	\N	\N	MSG0	9000000000000000052	\N	2026-05-25 10:44:38.349354	pending	\N	\N	\N	\N	\N
180215	52	wxid_huanghai10	self	我	好问题！主要3个差异：\n1）我们是小班制（每期30人），他们大班200+人，辅导质量不一样\n2）我们的项目是真实企业需求，不是玩具demo\n3）我们提供1年就业跟踪服务，不是学完就不管了	1	t	1762588942	\N	\N	MSG0	9000000000000000051	\N	2026-05-25 10:44:38.349355	pending	\N	\N	\N	\N	\N
180216	54	wxid_huanghai10	self	我	嗯价格确实有差异。但你可以对比一下：他们的课时、项目数量、辅导模式、就业服务。算下来我们的性价比其实更高。而且我们有7天无理由退款，零风险试学	1	t	1762589049	\N	\N	MSG0	9000000000000000053	\N	2026-05-25 10:44:38.349356	pending	\N	\N	\N	\N	\N
180217	55	wxid_huanghai10	wxid_huanghai10	黄海-销售	有道理，我再对比看看	1	f	1762589239	\N	\N	MSG0	9000000000000000054	\N	2026-05-25 10:44:38.349357	pending	\N	\N	\N	\N	\N
180218	56	wxid_huanghai10	self	我	好的～我把我们的详细课程对比表发你，你可以逐项对比。有问题随时问我，不管最后选哪家，选适合自己的最重要	1	t	1762589686	\N	\N	MSG0	9000000000000000055	\N	2026-05-25 10:44:38.349358	pending	\N	\N	\N	\N	\N
180219	45	wxid_wumin09	wxid_wumin09	吴敏-老师	老师你好，我上周报名的，但是还没开始学，不知道从哪里开始	1	f	1762770781	\N	\N	MSG0	9000000000000000044	\N	2026-05-25 10:44:38.34936	pending	\N	\N	\N	\N	\N
180220	46	wxid_wumin09	self	我	没问题！你先登录学习平台，从模块1第一节课开始看就行。我把直达链接发你。另外今晚8点有新生答疑直播，建议来听听，对你入门很有帮助	1	t	1762770849	\N	\N	MSG0	9000000000000000045	\N	2026-05-25 10:44:38.349361	pending	\N	\N	\N	\N	\N
180221	48	wxid_wumin09	self	我	有的！完成全部课程和毕业项目后会颁发结业证书，很多同学都放在LinkedIn和简历上了。另外优秀学员还有机会获得企业内推名额	1	t	1762770910	\N	\N	MSG0	9000000000000000047	\N	2026-05-25 10:44:38.349362	pending	\N	\N	\N	\N	\N
180222	47	wxid_wumin09	wxid_wumin09	吴敏-老师	好的谢谢！对了学完有证书吗	1	f	1762770941	\N	\N	MSG0	9000000000000000046	\N	2026-05-25 10:44:38.349363	pending	\N	\N	\N	\N	\N
180223	49	wxid_wumin09	wxid_wumin09	吴敏-老师	那我加油学！	1	f	1762771209	\N	\N	MSG0	9000000000000000048	\N	2026-05-25 10:44:38.349364	pending	\N	\N	\N	\N	\N
180224	50	wxid_wumin09	self	我	加油💪 有任何问题随时在群里问或者私聊我都行，我们一起努力！	1	t	1762771256	\N	\N	MSG0	9000000000000000049	\N	2026-05-25 10:44:38.349365	pending	\N	\N	\N	\N	\N
180225	145	wxid_songwei16	wxid_songwei16	宋伟-研究生	我做了8年会计，感觉这个行业要被AI取代了，想提前转型	1	f	1762824129	\N	\N	MSG0	9000000000000000144	\N	2026-05-25 10:44:38.349366	pending	\N	\N	\N	\N	\N
180226	146	wxid_songwei16	self	我	你的危机意识很好！确实基础会计工作在被自动化替代，但财务+AI的复合人才反而更值钱了。比如智能财务分析、自动化审计、财税AI助手这些方向	1	t	1762824209	\N	\N	MSG0	9000000000000000145	\N	2026-05-25 10:44:38.349367	pending	\N	\N	\N	\N	\N
180227	147	wxid_songwei16	wxid_songwei16	宋伟-研究生	那学完我能做什么	1	f	1762824383	\N	\N	MSG0	9000000000000000146	\N	2026-05-25 10:44:38.349369	pending	\N	\N	\N	\N	\N
180228	148	wxid_songwei16	self	我	你可以做AI财务产品经理、财税AI解决方案顾问，或者在现有公司推动AI转型。薪资比纯会计高50%以上，而且不可替代性更强	1	t	1762824546	\N	\N	MSG0	9000000000000000147	\N	2026-05-25 10:44:38.34937	pending	\N	\N	\N	\N	\N
180229	285	wxid_wangfang03	wxid_wangfang03	王芳-宝妈	我也在看其他家的课程，你们跟XX教育比有什么优势	1	f	1762840812	\N	\N	MSG0	9000000000000000284	\N	2026-05-25 10:44:38.349371	pending	\N	\N	\N	\N	\N
180230	286	wxid_wangfang03	self	我	好问题！主要3个差异：\n1）我们是小班制（每期30人），他们大班200+人，辅导质量不一样\n2）我们的项目是真实企业需求，不是玩具demo\n3）我们提供1年就业跟踪服务，不是学完就不管了	1	t	1762840853	\N	\N	MSG0	9000000000000000285	\N	2026-05-25 10:44:38.349372	pending	\N	\N	\N	\N	\N
180231	289	wxid_wangfang03	wxid_wangfang03	王芳-宝妈	有道理，我再对比看看	1	f	1762840936	\N	\N	MSG0	9000000000000000288	\N	2026-05-25 10:44:38.349373	pending	\N	\N	\N	\N	\N
180232	287	wxid_wangfang03	wxid_wangfang03	王芳-宝妈	他们价格比你们便宜一千多	1	f	1762840948	\N	\N	MSG0	9000000000000000286	\N	2026-05-25 10:44:38.349374	pending	\N	\N	\N	\N	\N
180233	288	wxid_wangfang03	self	我	嗯价格确实有差异。但你可以对比一下：他们的课时、项目数量、辅导模式、就业服务。算下来我们的性价比其实更高。而且我们有7天无理由退款，零风险试学	1	t	1762841082	\N	\N	MSG0	9000000000000000287	\N	2026-05-25 10:44:38.349376	pending	\N	\N	\N	\N	\N
180234	290	wxid_wangfang03	self	我	好的～我把我们的详细课程对比表发你，你可以逐项对比。有问题随时问我，不管最后选哪家，选适合自己的最重要	1	t	1762841352	\N	\N	MSG0	9000000000000000289	\N	2026-05-25 10:44:38.349377	pending	\N	\N	\N	\N	\N
180235	265	wxid_wangfang03	wxid_wangfang03	王芳-宝妈	我想问下如果学了几天觉得不适合，能退款吗	1	f	1762925912	\N	\N	MSG0	9000000000000000264	\N	2026-05-25 10:44:38.349378	pending	\N	\N	\N	\N	\N
180236	266	wxid_wangfang03	self	我	可以的！我们有7天无理由退款政策，报名后7天内不满意全额退款，不需要任何理由。超过7天的话第一个月内可以按比例退	1	t	1762926085	\N	\N	MSG0	9000000000000000265	\N	2026-05-25 10:44:38.349379	pending	\N	\N	\N	\N	\N
180237	267	wxid_wangfang03	wxid_wangfang03	王芳-宝妈	那我就放心了，先试试看	1	f	1762926098	\N	\N	MSG0	9000000000000000266	\N	2026-05-25 10:44:38.34938	pending	\N	\N	\N	\N	\N
180238	268	wxid_wangfang03	self	我	对的，零风险试学！很多同学一开始也有顾虑，试了几天就觉得内容很实用，停不下来了哈哈。你先体验，有任何问题随时找我	1	t	1762926425	\N	\N	MSG0	9000000000000000267	\N	2026-05-25 10:44:38.349381	pending	\N	\N	\N	\N	\N
180239	27	wxid_zhaolei06	wxid_zhaolei06	赵磊-金融行业	你们课程具体教什么内容啊，能详细说说吗	1	f	1762944264	\N	\N	MSG0	9000000000000000026	\N	2026-05-25 10:44:38.349382	pending	\N	\N	\N	\N	\N
180240	29	wxid_zhaolei06	wxid_zhaolei06	赵磊-金融行业	第4个模块听起来很实用，现在企业是不是都在用RAG	1	f	1762944378	\N	\N	MSG0	9000000000000000028	\N	2026-05-25 10:44:38.349384	pending	\N	\N	\N	\N	\N
180241	28	wxid_zhaolei06	self	我	好的！课程分5个模块：\n1️⃣ Python编程基础（2周）\n2️⃣ 数据分析与机器学习（3周）\n3️⃣ 深度学习与大模型原理（3周）\n4️⃣ LLM应用开发：RAG、Agent、LangChain（3周）\n5️⃣ 全栈项目实战+就业冲刺（3周）	1	t	1762944422	\N	\N	MSG0	9000000000000000027	\N	2026-05-25 10:44:38.349385	pending	\N	\N	\N	\N	\N
180242	30	wxid_zhaolei06	self	我	对！RAG现在是企业AI落地最火的方向，50%以上的AI岗位都在做RAG相关的事。我们这个模块会带你从零搭建一个完整的知识库问答系统，用的都是企业级技术栈	1	t	1762944561	\N	\N	MSG0	9000000000000000029	\N	2026-05-25 10:44:38.349386	pending	\N	\N	\N	\N	\N
180243	31	wxid_zhaolei06	wxid_zhaolei06	赵磊-金融行业	学完能做什么样的项目	1	f	1762944604	\N	\N	MSG0	9000000000000000030	\N	2026-05-25 10:44:38.349387	pending	\N	\N	\N	\N	\N
180244	32	wxid_zhaolei06	self	我	你会做5个实战项目：智能客服机器人、文档问答系统、AI写作助手、数据分析平台、还有一个自选毕业项目。这些都能直接放简历里，面试的时候很加分	1	t	1762944909	\N	\N	MSG0	9000000000000000031	\N	2026-05-25 10:44:38.349388	pending	\N	\N	\N	\N	\N
180245	259	wxid_songwei16	wxid_songwei16	宋伟-研究生	我是律师，想了解AI在法律行业的应用	1	f	1762945097	\N	\N	MSG0	9000000000000000258	\N	2026-05-25 10:44:38.349389	pending	\N	\N	\N	\N	\N
180246	260	wxid_songwei16	self	我	法律AI现在发展很快！合同审查、案例检索、法律文书生成这些都有成熟的AI方案了。学完课程你可以自己搭建法律知识库和智能问答系统	1	t	1762945157	\N	\N	MSG0	9000000000000000259	\N	2026-05-25 10:44:38.34939	pending	\N	\N	\N	\N	\N
180247	262	wxid_songwei16	self	我	完全可以！这就是RAG知识库的典型应用场景。课程模块4会手把手教你搭建，你可以直接用律所的案例数据来做毕业项目，学完就能上线用	1	t	1762945208	\N	\N	MSG0	9000000000000000261	\N	2026-05-25 10:44:38.349391	pending	\N	\N	\N	\N	\N
180248	261	wxid_songwei16	wxid_songwei16	宋伟-研究生	我们律所想做一个内部的案例检索系统，课程能教这个吗	1	f	1762945249	\N	\N	MSG0	9000000000000000260	\N	2026-05-25 10:44:38.349393	pending	\N	\N	\N	\N	\N
180249	263	wxid_songwei16	wxid_songwei16	宋伟-研究生	那太好了，这个对我们很实用	1	f	1762945717	\N	\N	MSG0	9000000000000000262	\N	2026-05-25 10:44:38.349394	pending	\N	\N	\N	\N	\N
180250	264	wxid_songwei16	self	我	对的，而且你做出来的系统可以给律所降本增效，老板肯定支持你学。需要的话我可以出一份给律所领导看的ROI分析	1	t	1762945847	\N	\N	MSG0	9000000000000000263	\N	2026-05-25 10:44:38.349395	pending	\N	\N	\N	\N	\N
180251	269	wxid_huanghai10	wxid_huanghai10	黄海-销售	老师我是开网约车的，学历不高，能学AI吗	1	f	1763008375	\N	\N	MSG0	9000000000000000268	\N	2026-05-25 10:44:38.349396	pending	\N	\N	\N	\N	\N
180252	270	wxid_huanghai10	self	我	能学！我们有好几个学员之前也是类似背景。AI应用开发不需要特别高的学历，关键是动手能力和学习意愿。你愿意花时间学，就一定能学会	1	t	1763008406	\N	\N	MSG0	9000000000000000269	\N	2026-05-25 10:44:38.349397	pending	\N	\N	\N	\N	\N
180253	272	wxid_huanghai10	self	我	我们有专门的基础班，进度比较慢，讲得更细。而且有1对1辅导，卡住了随时问。你先试学7天，觉得跟不上全额退款，没有任何风险	1	t	1763008492	\N	\N	MSG0	9000000000000000271	\N	2026-05-25 10:44:38.349398	pending	\N	\N	\N	\N	\N
180254	271	wxid_huanghai10	wxid_huanghai10	黄海-销售	我怕自己跟不上	1	f	1763008493	\N	\N	MSG0	9000000000000000270	\N	2026-05-25 10:44:38.349399	pending	\N	\N	\N	\N	\N
180255	273	wxid_huanghai10	wxid_huanghai10	黄海-销售	那我试试吧	1	f	1763008851	\N	\N	MSG0	9000000000000000272	\N	2026-05-25 10:44:38.3494	pending	\N	\N	\N	\N	\N
180256	274	wxid_huanghai10	self	我	好的！我给你安排基础班，导师会特别关注你的学习进度。很多人一开始觉得难，坚持两周就上手了，加油💪	1	t	1763009230	\N	\N	MSG0	9000000000000000273	\N	2026-05-25 10:44:38.349401	pending	\N	\N	\N	\N	\N
180257	213	wxid_huanghai10	wxid_huanghai10	黄海-销售	老师我学了一周了，感觉Python语法好多记不住怎么办	1	f	1763111323	\N	\N	MSG0	9000000000000000212	\N	2026-05-25 10:44:38.349403	pending	\N	\N	\N	\N	\N
180258	214	wxid_huanghai10	self	我	很正常！刚开始不用死记语法，重要的是理解逻辑。建议你：1）跟着视频敲代码，别光看；2）每天花20分钟复习前一天的内容；3）遇到不懂的先记下来，答疑课上问	1	t	1763111475	\N	\N	MSG0	9000000000000000213	\N	2026-05-25 10:44:38.349404	pending	\N	\N	\N	\N	\N
180259	215	wxid_huanghai10	wxid_huanghai10	黄海-销售	我是不是太笨了，别人好像学得比我快	1	f	1763111611	\N	\N	MSG0	9000000000000000214	\N	2026-05-25 10:44:38.349405	pending	\N	\N	\N	\N	\N
180260	217	wxid_huanghai10	wxid_huanghai10	黄海-销售	谢谢老师鼓励，我继续加油	1	f	1763111687	\N	\N	MSG0	9000000000000000216	\N	2026-05-25 10:44:38.349406	pending	\N	\N	\N	\N	\N
180261	216	wxid_huanghai10	self	我	千万别这么想！每个人基础不同，学习节奏不一样很正常。我见过很多开始慢的同学后面反而学得更扎实。坚持最重要，你已经迈出第一步了，比90%的人强	1	t	1763111791	\N	\N	MSG0	9000000000000000215	\N	2026-05-25 10:44:38.349407	pending	\N	\N	\N	\N	\N
180262	218	wxid_huanghai10	self	我	加油！有问题随时问，群里的同学也很热心互相帮助。下周的项目课会很有意思，坚持到那里你会发现编程其实挺好玩的	1	t	1763111923	\N	\N	MSG0	9000000000000000217	\N	2026-05-25 10:44:38.349408	pending	\N	\N	\N	\N	\N
180263	149	wxid_yeling21	wxid_yeling21	叶玲-餐饮老板	我是计算机研究生，但方向不是AI，想补充这方面的实战能力	1	f	1763186333	\N	\N	MSG0	9000000000000000148	\N	2026-05-25 10:44:38.349409	pending	\N	\N	\N	\N	\N
180264	150	wxid_yeling21	self	我	你基础很好！对你来说重点是模块4和5——大模型应用开发和项目实战。你可以跳过前面的基础部分，直接从进阶内容开始	1	t	1763186383	\N	\N	MSG0	9000000000000000149	\N	2026-05-25 10:44:38.34941	pending	\N	\N	\N	\N	\N
180265	151	wxid_yeling21	wxid_yeling21	叶玲-餐饮老板	有没有针对有基础学员的快速通道	1	f	1763186433	\N	\N	MSG0	9000000000000000150	\N	2026-05-25 10:44:38.349411	pending	\N	\N	\N	\N	\N
180266	152	wxid_yeling21	self	我	有的！我们有进阶班，跳过Python基础直接从机器学习开始，6周就能学完。而且项目难度更高，更适合你的水平	1	t	1763186672	\N	\N	MSG0	9000000000000000151	\N	2026-05-25 10:44:38.349413	pending	\N	\N	\N	\N	\N
180267	154	wxid_yeling21	self	我	一样的价格，但内容密度更高。而且进阶班的同学背景都比较强，讨论质量很高，对你帮助会更大	1	t	1763186808	\N	\N	MSG0	9000000000000000153	\N	2026-05-25 10:44:38.349414	pending	\N	\N	\N	\N	\N
180268	153	wxid_yeling21	wxid_yeling21	叶玲-餐饮老板	价格一样吗	1	f	1763186897	\N	\N	MSG0	9000000000000000152	\N	2026-05-25 10:44:38.349415	pending	\N	\N	\N	\N	\N
180269	297	wxid_panyu20	wxid_panyu20	潘宇-律师	老师你好，我上周报名的，但是还没开始学，不知道从哪里开始	1	f	1763189053	\N	\N	MSG0	9000000000000000296	\N	2026-05-25 10:44:38.349416	pending	\N	\N	\N	\N	\N
180270	298	wxid_panyu20	self	我	没问题！你先登录学习平台，从模块1第一节课开始看就行。我把直达链接发你。另外今晚8点有新生答疑直播，建议来听听，对你入门很有帮助	1	t	1763189132	\N	\N	MSG0	9000000000000000297	\N	2026-05-25 10:44:38.349417	pending	\N	\N	\N	\N	\N
180271	299	wxid_panyu20	wxid_panyu20	潘宇-律师	好的谢谢！对了学完有证书吗	1	f	1763189171	\N	\N	MSG0	9000000000000000298	\N	2026-05-25 10:44:38.349418	pending	\N	\N	\N	\N	\N
180272	300	wxid_panyu20	self	我	有的！完成全部课程和毕业项目后会颁发结业证书，很多同学都放在LinkedIn和简历上了。另外优秀学员还有机会获得企业内推名额	1	t	1763189191	\N	\N	MSG0	9000000000000000299	\N	2026-05-25 10:44:38.349419	pending	\N	\N	\N	\N	\N
180273	249	wxid_zhoujie08	wxid_zhoujie08	周杰-应届生	我决定报名了，怎么付款	1	f	1763545304	\N	\N	MSG0	9000000000000000248	\N	2026-05-25 10:44:38.34942	pending	\N	\N	\N	\N	\N
180274	250	wxid_zhoujie08	self	我	太好了！我发你报名链接，支持微信支付、支付宝、银行卡都行。你想一次性付还是分期呀	1	t	1763545441	\N	\N	MSG0	9000000000000000249	\N	2026-05-25 10:44:38.349421	pending	\N	\N	\N	\N	\N
180275	251	wxid_zhoujie08	wxid_zhoujie08	周杰-应届生	微信支付吧，一次性付	1	f	1763545490	\N	\N	MSG0	9000000000000000250	\N	2026-05-25 10:44:38.349423	pending	\N	\N	\N	\N	\N
180276	252	wxid_zhoujie08	self	我	好的，付款码发你了～确认收款后我马上拉你进班级群，把学习账号和资料包发给你	1	t	1763545523	\N	\N	MSG0	9000000000000000251	\N	2026-05-25 10:44:38.349424	pending	\N	\N	\N	\N	\N
180277	253	wxid_zhoujie08	wxid_zhoujie08	周杰-应届生	付好了！	1	f	1763545728	\N	\N	MSG0	9000000000000000252	\N	2026-05-25 10:44:38.349425	pending	\N	\N	\N	\N	\N
180278	254	wxid_zhoujie08	self	我	收到啦！欢迎加入第12期训练营🎉 我已经把你拉进班级群了，你的专属导师是王老师。本周六晚8点有开营直播，记得来哦！学习资料我稍后私发你	1	t	1763545849	\N	\N	MSG0	9000000000000000253	\N	2026-05-25 10:44:38.349426	pending	\N	\N	\N	\N	\N
180279	279	wxid_panyu20	wxid_panyu20	潘宇-律师	我是计算机研究生，但方向不是AI，想补充这方面的实战能力	1	f	1763609599	\N	\N	MSG0	9000000000000000278	\N	2026-05-25 10:44:38.349428	pending	\N	\N	\N	\N	\N
180280	207	wxid_zhaolei06	wxid_zhaolei06	赵磊-金融行业	4666还是有点贵，我看网上免费教程也挺多的	1	f	1763609714	\N	\N	MSG0	9000000000000000206	\N	2026-05-25 10:44:38.349429	pending	\N	\N	\N	\N	\N
180281	280	wxid_panyu20	self	我	你基础很好！对你来说重点是模块4和5——大模型应用开发和项目实战。你可以跳过前面的基础部分，直接从进阶内容开始	1	t	1763609724	\N	\N	MSG0	9000000000000000279	\N	2026-05-25 10:44:38.34943	pending	\N	\N	\N	\N	\N
180282	208	wxid_zhaolei06	self	我	理解你的顾虑～免费教程确实多，但问题是：1）内容碎片化，学完不成体系；2）没人带着做项目，遇到bug卡住就放弃了；3）没有就业指导。我们的完课率85%，免费课程一般不到5%	1	t	1763609753	\N	\N	MSG0	9000000000000000207	\N	2026-05-25 10:44:38.349431	pending	\N	\N	\N	\N	\N
180283	211	wxid_zhaolei06	wxid_zhaolei06	赵磊-金融行业	好吧让我再想想	1	f	1763609862	\N	\N	MSG0	9000000000000000210	\N	2026-05-25 10:44:38.349432	pending	\N	\N	\N	\N	\N
180284	284	wxid_panyu20	self	我	一样的价格，但内容密度更高。而且进阶班的同学背景都比较强，讨论质量很高，对你帮助会更大	1	t	1763609899	\N	\N	MSG0	9000000000000000283	\N	2026-05-25 10:44:38.349433	pending	\N	\N	\N	\N	\N
180285	281	wxid_panyu20	wxid_panyu20	潘宇-律师	有没有针对有基础学员的快速通道	1	f	1763609925	\N	\N	MSG0	9000000000000000280	\N	2026-05-25 10:44:38.349434	pending	\N	\N	\N	\N	\N
180286	209	wxid_zhaolei06	wxid_zhaolei06	赵磊-金融行业	那有没有分期付款	1	f	1763610006	\N	\N	MSG0	9000000000000000208	\N	2026-05-25 10:44:38.349435	pending	\N	\N	\N	\N	\N
180287	282	wxid_panyu20	self	我	有的！我们有进阶班，跳过Python基础直接从机器学习开始，6周就能学完。而且项目难度更高，更适合你的水平	1	t	1763610007	\N	\N	MSG0	9000000000000000281	\N	2026-05-25 10:44:38.349437	pending	\N	\N	\N	\N	\N
180288	210	wxid_zhaolei06	self	我	有的！支持3期和6期免息分期，6期的话每月不到780块，一顿火锅钱就能投资自己。而且我们有7天无理由退款，试学不满意全额退	1	t	1763610233	\N	\N	MSG0	9000000000000000209	\N	2026-05-25 10:44:38.349438	pending	\N	\N	\N	\N	\N
180289	283	wxid_panyu20	wxid_panyu20	潘宇-律师	价格一样吗	1	f	1763610291	\N	\N	MSG0	9000000000000000282	\N	2026-05-25 10:44:38.349439	pending	\N	\N	\N	\N	\N
180290	212	wxid_zhaolei06	self	我	没问题，不着急～我先把课程大纲和学员案例发你看看，有问题随时找我。对了活动价周五就恢复原价了，想好了尽早跟我说哈	1	t	1763610339	\N	\N	MSG0	9000000000000000211	\N	2026-05-25 10:44:38.34944	pending	\N	\N	\N	\N	\N
180291	255	wxid_xulei14	wxid_xulei14	徐磊-司机转行	我做建筑设计的，想了解AI能不能用在我们行业	1	f	1763778797	\N	\N	MSG0	9000000000000000254	\N	2026-05-25 10:44:38.349441	pending	\N	\N	\N	\N	\N
180292	258	wxid_xulei14	self	我	基础模块2-3周学完就能用一些AI工具了。完整学完3个月，你可以自己搭建AI辅助设计的workflow，比如用AI生成方案、自动出图等	1	t	1763778917	\N	\N	MSG0	9000000000000000257	\N	2026-05-25 10:44:38.349442	pending	\N	\N	\N	\N	\N
180293	256	wxid_xulei14	self	我	太能了！AI辅助设计、智能BIM、参数化建筑这些方向现在很火。学完课程你可以开发自己的AI设计工具，在行业里会非常有竞争力	1	t	1763778932	\N	\N	MSG0	9000000000000000255	\N	2026-05-25 10:44:38.349443	pending	\N	\N	\N	\N	\N
180294	257	wxid_xulei14	wxid_xulei14	徐磊-司机转行	需要学多久才能用到工作中	1	f	1763779117	\N	\N	MSG0	9000000000000000256	\N	2026-05-25 10:44:38.349444	pending	\N	\N	\N	\N	\N
180295	185	wxid_songwei16	wxid_songwei16	宋伟-研究生	我是做机械设计的，感觉传统制造业越来越难了，AI能帮到我吗	1	f	1764039905	\N	\N	MSG0	9000000000000000184	\N	2026-05-25 10:44:38.349446	pending	\N	\N	\N	\N	\N
180296	187	wxid_songwei16	wxid_songwei16	宋伟-研究生	我都38了，还来得及吗	1	f	1764040037	\N	\N	MSG0	9000000000000000186	\N	2026-05-25 10:44:38.349447	pending	\N	\N	\N	\N	\N
180297	186	wxid_songwei16	self	我	当然！智能制造是国家重点方向，AI+制造的人才缺口很大。比如预测性维护、质量检测AI、智能排产这些，都需要懂制造又懂AI的人	1	t	1764040085	\N	\N	MSG0	9000000000000000185	\N	2026-05-25 10:44:38.349448	pending	\N	\N	\N	\N	\N
180298	188	wxid_songwei16	self	我	来得及！制造业+AI的岗位反而偏好有行业经验的人，你比应届生更懂生产线上的痛点。我们上期有个40岁的学员，之前做模具设计，现在在一家智能制造公司做AI项目经理	1	t	1764040157	\N	\N	MSG0	9000000000000000187	\N	2026-05-25 10:44:38.349449	pending	\N	\N	\N	\N	\N
180299	33	wxid_sunli07	wxid_sunli07	孙丽-HR转行	我是计算机研究生，但方向不是AI，想补充这方面的实战能力	1	f	1764067975	\N	\N	MSG0	9000000000000000032	\N	2026-05-25 10:44:38.34945	pending	\N	\N	\N	\N	\N
180300	34	wxid_sunli07	self	我	你基础很好！对你来说重点是模块4和5——大模型应用开发和项目实战。你可以跳过前面的基础部分，直接从进阶内容开始	1	t	1764068060	\N	\N	MSG0	9000000000000000033	\N	2026-05-25 10:44:38.349451	pending	\N	\N	\N	\N	\N
180301	37	wxid_sunli07	wxid_sunli07	孙丽-HR转行	价格一样吗	1	f	1764068115	\N	\N	MSG0	9000000000000000036	\N	2026-05-25 10:44:38.349452	pending	\N	\N	\N	\N	\N
180302	35	wxid_sunli07	wxid_sunli07	孙丽-HR转行	有没有针对有基础学员的快速通道	1	f	1764068297	\N	\N	MSG0	9000000000000000034	\N	2026-05-25 10:44:38.349454	pending	\N	\N	\N	\N	\N
180303	38	wxid_sunli07	self	我	一样的价格，但内容密度更高。而且进阶班的同学背景都比较强，讨论质量很高，对你帮助会更大	1	t	1764068370	\N	\N	MSG0	9000000000000000037	\N	2026-05-25 10:44:38.349455	pending	\N	\N	\N	\N	\N
180304	36	wxid_sunli07	self	我	有的！我们有进阶班，跳过Python基础直接从机器学习开始，6周就能学完。而且项目难度更高，更适合你的水平	1	t	1764068377	\N	\N	MSG0	9000000000000000035	\N	2026-05-25 10:44:38.349456	pending	\N	\N	\N	\N	\N
180305	189	wxid_songwei16	wxid_songwei16	宋伟-研究生	老师你好，我上周报名的，但是还没开始学，不知道从哪里开始	1	f	1764124056	\N	\N	MSG0	9000000000000000188	\N	2026-05-25 10:44:38.349457	pending	\N	\N	\N	\N	\N
180306	192	wxid_songwei16	self	我	有的！完成全部课程和毕业项目后会颁发结业证书，很多同学都放在LinkedIn和简历上了。另外优秀学员还有机会获得企业内推名额	1	t	1764124173	\N	\N	MSG0	9000000000000000191	\N	2026-05-25 10:44:38.349458	pending	\N	\N	\N	\N	\N
180307	194	wxid_songwei16	self	我	加油💪 有任何问题随时在群里问或者私聊我都行，我们一起努力！	1	t	1764124216	\N	\N	MSG0	9000000000000000193	\N	2026-05-25 10:44:38.349459	pending	\N	\N	\N	\N	\N
180308	190	wxid_songwei16	self	我	没问题！你先登录学习平台，从模块1第一节课开始看就行。我把直达链接发你。另外今晚8点有新生答疑直播，建议来听听，对你入门很有帮助	1	t	1764124234	\N	\N	MSG0	9000000000000000189	\N	2026-05-25 10:44:38.34946	pending	\N	\N	\N	\N	\N
180309	191	wxid_songwei16	wxid_songwei16	宋伟-研究生	好的谢谢！对了学完有证书吗	1	f	1764124350	\N	\N	MSG0	9000000000000000190	\N	2026-05-25 10:44:38.349461	pending	\N	\N	\N	\N	\N
180310	193	wxid_songwei16	wxid_songwei16	宋伟-研究生	那我加油学！	1	f	1764124768	\N	\N	MSG0	9000000000000000192	\N	2026-05-25 10:44:38.349462	pending	\N	\N	\N	\N	\N
180311	21	wxid_chenxi05	wxid_chenxi05	陈曦-产品经理	我是计算机研究生，但方向不是AI，想补充这方面的实战能力	1	f	1764125479	\N	\N	MSG0	9000000000000000020	\N	2026-05-25 10:44:38.349464	pending	\N	\N	\N	\N	\N
180312	22	wxid_chenxi05	self	我	你基础很好！对你来说重点是模块4和5——大模型应用开发和项目实战。你可以跳过前面的基础部分，直接从进阶内容开始	1	t	1764125605	\N	\N	MSG0	9000000000000000021	\N	2026-05-25 10:44:38.349465	pending	\N	\N	\N	\N	\N
180313	24	wxid_chenxi05	self	我	有的！我们有进阶班，跳过Python基础直接从机器学习开始，6周就能学完。而且项目难度更高，更适合你的水平	1	t	1764125611	\N	\N	MSG0	9000000000000000023	\N	2026-05-25 10:44:38.349466	pending	\N	\N	\N	\N	\N
180314	23	wxid_chenxi05	wxid_chenxi05	陈曦-产品经理	有没有针对有基础学员的快速通道	1	f	1764125795	\N	\N	MSG0	9000000000000000022	\N	2026-05-25 10:44:38.349467	pending	\N	\N	\N	\N	\N
180315	26	wxid_chenxi05	self	我	一样的价格，但内容密度更高。而且进阶班的同学背景都比较强，讨论质量很高，对你帮助会更大	1	t	1764125899	\N	\N	MSG0	9000000000000000025	\N	2026-05-25 10:44:38.349468	pending	\N	\N	\N	\N	\N
180316	25	wxid_chenxi05	wxid_chenxi05	陈曦-产品经理	价格一样吗	1	f	1764125975	\N	\N	MSG0	9000000000000000024	\N	2026-05-25 10:44:38.349469	pending	\N	\N	\N	\N	\N
180317	139	wxid_wumin09	wxid_wumin09	吴敏-老师	我做自媒体的，想用AI提高内容产出效率	1	f	1764143680	\N	\N	MSG0	9000000000000000138	\N	2026-05-25 10:44:38.349471	pending	\N	\N	\N	\N	\N
180318	140	wxid_wumin09	self	我	这个太对口了！课程里有AI写作助手的项目，学完你可以搭建自己的内容生成系统。很多自媒体学员学完后产出效率翻了3倍	1	t	1764143736	\N	\N	MSG0	9000000000000000139	\N	2026-05-25 10:44:38.349472	pending	\N	\N	\N	\N	\N
180319	143	wxid_wumin09	wxid_wumin09	吴敏-老师	听起来不错，有没有自媒体方向的学员案例	1	f	1764143924	\N	\N	MSG0	9000000000000000142	\N	2026-05-25 10:44:38.349473	pending	\N	\N	\N	\N	\N
180320	141	wxid_wumin09	wxid_wumin09	吴敏-老师	具体能帮我做什么	1	f	1764143928	\N	\N	MSG0	9000000000000000140	\N	2026-05-25 10:44:38.349474	pending	\N	\N	\N	\N	\N
180321	142	wxid_wumin09	self	我	选题策划、文案生成、视频脚本、数据分析、粉丝画像分析这些都能用AI自动化。而且你还能把AI技能做成新的内容方向，一举两得	1	t	1764144205	\N	\N	MSG0	9000000000000000141	\N	2026-05-25 10:44:38.349475	pending	\N	\N	\N	\N	\N
180322	144	wxid_wumin09	self	我	有！小陈之前做美食博主，学完后开了AI教程账号，3个月涨粉20万。还有做知识付费的学员，用AI搭建了自动答疑系统，省了2个客服的人力成本	1	t	1764144280	\N	\N	MSG0	9000000000000000143	\N	2026-05-25 10:44:38.349476	pending	\N	\N	\N	\N	\N
180323	63	wxid_hejun12	wxid_hejun12	何军-建筑师	我今年35了，转行AI会不会太晚了	1	f	1764293658	\N	\N	MSG0	9000000000000000062	\N	2026-05-25 10:44:38.349477	pending	\N	\N	\N	\N	\N
180324	64	wxid_hejun12	self	我	一点都不晚！我们学员年龄从22到45都有。AI领域更看重解决问题的能力，你的行业经验反而是优势——你比应届生更懂业务场景，知道AI该用在哪里	1	t	1764293744	\N	\N	MSG0	9000000000000000063	\N	2026-05-25 10:44:38.349479	pending	\N	\N	\N	\N	\N
180325	65	wxid_hejun12	wxid_hejun12	何军-建筑师	但是面试的时候会不会被年龄歧视	1	f	1764293822	\N	\N	MSG0	9000000000000000064	\N	2026-05-25 10:44:38.34948	pending	\N	\N	\N	\N	\N
180326	68	wxid_hejun12	self	我	根据你的金融背景，AI+金融方向很适合你。比如智能风控、量化分析、金融知识库这些。我们课程里有金融场景的项目实战，学完直接能用	1	t	1764294003	\N	\N	MSG0	9000000000000000067	\N	2026-05-25 10:44:38.349481	pending	\N	\N	\N	\N	\N
180327	67	wxid_hejun12	wxid_hejun12	何军-建筑师	那我适合什么方向	1	f	1764294106	\N	\N	MSG0	9000000000000000066	\N	2026-05-25 10:44:38.349482	pending	\N	\N	\N	\N	\N
180328	66	wxid_hejun12	self	我	AI产品经理、解决方案架构师、技术顾问这些岗位反而偏好有经验的人。不是所有AI岗位都要卷算法，应用层的机会非常多，而且薪资不低	1	t	1764294108	\N	\N	MSG0	9000000000000000065	\N	2026-05-25 10:44:38.349483	pending	\N	\N	\N	\N	\N
180329	93	wxid_dengxia17	wxid_dengxia17	邓霞-电商运营	我想和同事一起报名，有团购优惠吗	1	f	1764414616	\N	\N	MSG0	9000000000000000092	\N	2026-05-25 10:44:38.349484	pending	\N	\N	\N	\N	\N
180330	95	wxid_dengxia17	wxid_dengxia17	邓霞-电商运营	大概4-5个人，都是我们公司想转型AI的	1	f	1764414714	\N	\N	MSG0	9000000000000000094	\N	2026-05-25 10:44:38.349485	pending	\N	\N	\N	\N	\N
180331	94	wxid_dengxia17	self	我	有的！3人团报每人减500，5人以上团报打8折。你们几个人想一起学呀	1	t	1764414725	\N	\N	MSG0	9000000000000000093	\N	2026-05-25 10:44:38.349487	pending	\N	\N	\N	\N	\N
180332	98	wxid_dengxia17	self	我	方案发你了，里面包含课程内容、团购价格、企业发票等信息。你们商量好了随时找我，名额我先帮你们预留着	1	t	1764415046	\N	\N	MSG0	9000000000000000097	\N	2026-05-25 10:44:38.349488	pending	\N	\N	\N	\N	\N
180333	96	wxid_dengxia17	self	我	5个人的话可以享受8折优惠，每人3733元。而且我可以给你们安排同一个班级和导师，方便一起讨论学习。需要我出一份企业团购方案吗	1	t	1764415066	\N	\N	MSG0	9000000000000000095	\N	2026-05-25 10:44:38.349489	pending	\N	\N	\N	\N	\N
180334	97	wxid_dengxia17	wxid_dengxia17	邓霞-电商运营	好的，你发我看看，我跟他们商量下	1	f	1764415160	\N	\N	MSG0	9000000000000000096	\N	2026-05-25 10:44:38.34949	pending	\N	\N	\N	\N	\N
180335	161	wxid_caojie18	wxid_caojie18	曹杰-机械工程师	老师我是开网约车的，学历不高，能学AI吗	1	f	1764571029	\N	\N	MSG0	9000000000000000160	\N	2026-05-25 10:44:38.349491	pending	\N	\N	\N	\N	\N
180336	163	wxid_caojie18	wxid_caojie18	曹杰-机械工程师	我怕自己跟不上	1	f	1764571155	\N	\N	MSG0	9000000000000000162	\N	2026-05-25 10:44:38.349492	pending	\N	\N	\N	\N	\N
180337	166	wxid_caojie18	self	我	好的！我给你安排基础班，导师会特别关注你的学习进度。很多人一开始觉得难，坚持两周就上手了，加油💪	1	t	1764571179	\N	\N	MSG0	9000000000000000165	\N	2026-05-25 10:44:38.349494	pending	\N	\N	\N	\N	\N
180338	162	wxid_caojie18	self	我	能学！我们有好几个学员之前也是类似背景。AI应用开发不需要特别高的学历，关键是动手能力和学习意愿。你愿意花时间学，就一定能学会	1	t	1764571180	\N	\N	MSG0	9000000000000000161	\N	2026-05-25 10:44:38.349495	pending	\N	\N	\N	\N	\N
180339	164	wxid_caojie18	self	我	我们有专门的基础班，进度比较慢，讲得更细。而且有1对1辅导，卡住了随时问。你先试学7天，觉得跟不上全额退款，没有任何风险	1	t	1764571296	\N	\N	MSG0	9000000000000000163	\N	2026-05-25 10:44:38.349496	pending	\N	\N	\N	\N	\N
180340	165	wxid_caojie18	wxid_caojie18	曹杰-机械工程师	那我试试吧	1	f	1764571673	\N	\N	MSG0	9000000000000000164	\N	2026-05-25 10:44:38.349497	pending	\N	\N	\N	\N	\N
180341	115	wxid_yeling21	wxid_yeling21	叶玲-餐饮老板	我是美术老师，对AI绘画很感兴趣，你们课程有这方面内容吗	1	f	1764591645	\N	\N	MSG0	9000000000000000114	\N	2026-05-25 10:44:38.349498	pending	\N	\N	\N	\N	\N
180342	117	wxid_yeling21	wxid_yeling21	叶玲-餐饮老板	短期班多少钱	1	f	1764591779	\N	\N	MSG0	9000000000000000116	\N	2026-05-25 10:44:38.349499	pending	\N	\N	\N	\N	\N
180343	116	wxid_yeling21	self	我	有涉及！课程里有计算机视觉和图像生成的模块。不过如果你主要想学AI绘画（Midjourney、Stable Diffusion），我们有专门的AI创意设计短期班，2周就能上手	1	t	1764591809	\N	\N	MSG0	9000000000000000115	\N	2026-05-25 10:44:38.3495	pending	\N	\N	\N	\N	\N
180344	118	wxid_yeling21	self	我	短期班1299，教你用AI辅助创作、风格迁移、图像编辑这些。很多设计师和美术老师学完后把AI融入教学，效果特别好	1	t	1764591879	\N	\N	MSG0	9000000000000000117	\N	2026-05-25 10:44:38.349501	pending	\N	\N	\N	\N	\N
180345	119	wxid_yeling21	wxid_yeling21	叶玲-餐饮老板	我两个都想学，有优惠吗	1	f	1764592125	\N	\N	MSG0	9000000000000000118	\N	2026-05-25 10:44:38.349502	pending	\N	\N	\N	\N	\N
180346	120	wxid_yeling21	self	我	两个一起报的话总共减800，相当于短期班半价。而且全栈课程里的视觉模块会讲得更深入，两个互补	1	t	1764592385	\N	\N	MSG0	9000000000000000119	\N	2026-05-25 10:44:38.349504	pending	\N	\N	\N	\N	\N
180347	173	wxid_xulei14	wxid_xulei14	徐磊-司机转行	我做电商运营的，想学AI来提升工作效率，有针对电商的内容吗	1	f	1764639903	\N	\N	MSG0	9000000000000000172	\N	2026-05-25 10:44:38.349505	pending	\N	\N	\N	\N	\N
180348	175	wxid_xulei14	wxid_xulei14	徐磊-司机转行	我们老板也想让团队学AI，能不能定制企业培训	1	f	1764639971	\N	\N	MSG0	9000000000000000174	\N	2026-05-25 10:44:38.349506	pending	\N	\N	\N	\N	\N
180349	174	wxid_xulei14	self	我	有的！课程里有推荐系统和用户画像的项目，跟电商直接相关。学完你可以搭建智能选品系统、自动化客服、个性化推荐这些	1	t	1764639980	\N	\N	MSG0	9000000000000000173	\N	2026-05-25 10:44:38.349507	pending	\N	\N	\N	\N	\N
180350	176	wxid_xulei14	self	我	可以的！我们有企业定制方案，可以根据你们电商业务场景设计专属课程内容。我发你企业培训的介绍看看？	1	t	1764640425	\N	\N	MSG0	9000000000000000175	\N	2026-05-25 10:44:38.349508	pending	\N	\N	\N	\N	\N
180351	177	wxid_xulei14	wxid_xulei14	徐磊-司机转行	好的发我	1	f	1764640559	\N	\N	MSG0	9000000000000000176	\N	2026-05-25 10:44:38.349509	pending	\N	\N	\N	\N	\N
180352	178	wxid_xulei14	self	我	发你了！里面有电商行业的AI应用案例和培训方案。你跟老板商量下，我们可以安排一次免费的需求沟通会	1	t	1764640578	\N	\N	MSG0	9000000000000000177	\N	2026-05-25 10:44:38.34951	pending	\N	\N	\N	\N	\N
180353	155	wxid_tangyan11	wxid_tangyan11	唐燕-护士转行	4666还是有点贵，我看网上免费教程也挺多的	1	f	1764735545	\N	\N	MSG0	9000000000000000154	\N	2026-05-25 10:44:38.349512	pending	\N	\N	\N	\N	\N
180354	156	wxid_tangyan11	self	我	理解你的顾虑～免费教程确实多，但问题是：1）内容碎片化，学完不成体系；2）没人带着做项目，遇到bug卡住就放弃了；3）没有就业指导。我们的完课率85%，免费课程一般不到5%	1	t	1764735648	\N	\N	MSG0	9000000000000000155	\N	2026-05-25 10:44:38.349513	pending	\N	\N	\N	\N	\N
180355	160	wxid_tangyan11	self	我	没问题，不着急～我先把课程大纲和学员案例发你看看，有问题随时找我。对了活动价周五就恢复原价了，想好了尽早跟我说哈	1	t	1764735745	\N	\N	MSG0	9000000000000000159	\N	2026-05-25 10:44:38.349514	pending	\N	\N	\N	\N	\N
180356	157	wxid_tangyan11	wxid_tangyan11	唐燕-护士转行	那有没有分期付款	1	f	1764735755	\N	\N	MSG0	9000000000000000156	\N	2026-05-25 10:44:38.349515	pending	\N	\N	\N	\N	\N
180357	159	wxid_tangyan11	wxid_tangyan11	唐燕-护士转行	好吧让我再想想	1	f	1764735789	\N	\N	MSG0	9000000000000000158	\N	2026-05-25 10:44:38.349516	pending	\N	\N	\N	\N	\N
180358	158	wxid_tangyan11	self	我	有的！支持3期和6期免息分期，6期的话每月不到780块，一顿火锅钱就能投资自己。而且我们有7天无理由退款，试学不满意全额退	1	t	1764736016	\N	\N	MSG0	9000000000000000157	\N	2026-05-25 10:44:38.349518	pending	\N	\N	\N	\N	\N
180359	243	wxid_sunli07	wxid_sunli07	孙丽-HR转行	我是计算机研究生，但方向不是AI，想补充这方面的实战能力	1	f	1764898295	\N	\N	MSG0	9000000000000000242	\N	2026-05-25 10:44:38.349519	pending	\N	\N	\N	\N	\N
180360	244	wxid_sunli07	self	我	你基础很好！对你来说重点是模块4和5——大模型应用开发和项目实战。你可以跳过前面的基础部分，直接从进阶内容开始	1	t	1764898333	\N	\N	MSG0	9000000000000000243	\N	2026-05-25 10:44:38.34952	pending	\N	\N	\N	\N	\N
180361	246	wxid_sunli07	self	我	有的！我们有进阶班，跳过Python基础直接从机器学习开始，6周就能学完。而且项目难度更高，更适合你的水平	1	t	1764898388	\N	\N	MSG0	9000000000000000245	\N	2026-05-25 10:44:38.349521	pending	\N	\N	\N	\N	\N
180362	245	wxid_sunli07	wxid_sunli07	孙丽-HR转行	有没有针对有基础学员的快速通道	1	f	1764898423	\N	\N	MSG0	9000000000000000244	\N	2026-05-25 10:44:38.349522	pending	\N	\N	\N	\N	\N
180363	247	wxid_sunli07	wxid_sunli07	孙丽-HR转行	价格一样吗	1	f	1764898579	\N	\N	MSG0	9000000000000000246	\N	2026-05-25 10:44:38.349523	pending	\N	\N	\N	\N	\N
180364	248	wxid_sunli07	self	我	一样的价格，但内容密度更高。而且进阶班的同学背景都比较强，讨论质量很高，对你帮助会更大	1	t	1764898765	\N	\N	MSG0	9000000000000000247	\N	2026-05-25 10:44:38.349525	pending	\N	\N	\N	\N	\N
180365	57	wxid_tangyan11	wxid_tangyan11	唐燕-护士转行	我今年35了，转行AI会不会太晚了	1	f	1764989614	\N	\N	MSG0	9000000000000000056	\N	2026-05-25 10:44:38.349526	pending	\N	\N	\N	\N	\N
180366	58	wxid_tangyan11	self	我	一点都不晚！我们学员年龄从22到45都有。AI领域更看重解决问题的能力，你的行业经验反而是优势——你比应届生更懂业务场景，知道AI该用在哪里	1	t	1764989655	\N	\N	MSG0	9000000000000000057	\N	2026-05-25 10:44:38.349527	pending	\N	\N	\N	\N	\N
180367	59	wxid_tangyan11	wxid_tangyan11	唐燕-护士转行	但是面试的时候会不会被年龄歧视	1	f	1764989820	\N	\N	MSG0	9000000000000000058	\N	2026-05-25 10:44:38.349528	pending	\N	\N	\N	\N	\N
180368	61	wxid_tangyan11	wxid_tangyan11	唐燕-护士转行	那我适合什么方向	1	f	1764989834	\N	\N	MSG0	9000000000000000060	\N	2026-05-25 10:44:38.349529	pending	\N	\N	\N	\N	\N
180369	60	wxid_tangyan11	self	我	AI产品经理、解决方案架构师、技术顾问这些岗位反而偏好有经验的人。不是所有AI岗位都要卷算法，应用层的机会非常多，而且薪资不低	1	t	1764990142	\N	\N	MSG0	9000000000000000059	\N	2026-05-25 10:44:38.349531	pending	\N	\N	\N	\N	\N
180370	62	wxid_tangyan11	self	我	根据你的金融背景，AI+金融方向很适合你。比如智能风控、量化分析、金融知识库这些。我们课程里有金融场景的项目实战，学完直接能用	1	t	1764990234	\N	\N	MSG0	9000000000000000061	\N	2026-05-25 10:44:38.349532	pending	\N	\N	\N	\N	\N
180371	103	wxid_fengli19	wxid_fengli19	冯丽-美术老师	你好，我在抖音上看到你们的AI课程广告，想了解一下	1	f	1765090171	\N	\N	MSG0	9000000000000000102	\N	2026-05-25 10:44:38.349533	pending	\N	\N	\N	\N	\N
180372	104	wxid_fengli19	self	我	你好呀！感谢关注～我们这个是AI全栈实战训练营，主要教Python编程、大模型应用开发、RAG知识库搭建这些，3个月系统学习，适合零基础和想转行的同学	1	t	1765090263	\N	\N	MSG0	9000000000000000103	\N	2026-05-25 10:44:38.349534	pending	\N	\N	\N	\N	\N
180373	106	wxid_fengli19	self	我	完全可以的！我们60%的学员都是零基础转行的，课程从Python基础开始教，而且有1对1辅导，遇到问题随时问。上期有个做HR的姐姐，3个月就拿到了AI产品经理的offer	1	t	1765090303	\N	\N	MSG0	9000000000000000105	\N	2026-05-25 10:44:38.349535	pending	\N	\N	\N	\N	\N
180374	108	wxid_fengli19	self	我	原价6980，现在新年活动价4666，包含全部课程+项目实战+就业辅导+终身回看。这个价格本周五截止哦	1	t	1765090341	\N	\N	MSG0	9000000000000000107	\N	2026-05-25 10:44:38.349536	pending	\N	\N	\N	\N	\N
180375	107	wxid_fengli19	wxid_fengli19	冯丽-美术老师	课程多少钱啊	1	f	1765090375	\N	\N	MSG0	9000000000000000106	\N	2026-05-25 10:44:38.349539	pending	\N	\N	\N	\N	\N
180376	105	wxid_fengli19	wxid_fengli19	冯丽-美术老师	我是做运营的，完全没有编程基础，能学会吗	1	f	1765090523	\N	\N	MSG0	9000000000000000104	\N	2026-05-25 10:44:38.349541	pending	\N	\N	\N	\N	\N
180377	225	wxid_hejun12	wxid_hejun12	何军-建筑师	老师我学了一周了，感觉Python语法好多记不住怎么办	1	f	1765108454	\N	\N	MSG0	9000000000000000224	\N	2026-05-25 10:44:38.349542	pending	\N	\N	\N	\N	\N
180378	226	wxid_hejun12	self	我	很正常！刚开始不用死记语法，重要的是理解逻辑。建议你：1）跟着视频敲代码，别光看；2）每天花20分钟复习前一天的内容；3）遇到不懂的先记下来，答疑课上问	1	t	1765108606	\N	\N	MSG0	9000000000000000225	\N	2026-05-25 10:44:38.349544	pending	\N	\N	\N	\N	\N
180379	227	wxid_hejun12	wxid_hejun12	何军-建筑师	我是不是太笨了，别人好像学得比我快	1	f	1765108614	\N	\N	MSG0	9000000000000000226	\N	2026-05-25 10:44:38.349545	pending	\N	\N	\N	\N	\N
180380	228	wxid_hejun12	self	我	千万别这么想！每个人基础不同，学习节奏不一样很正常。我见过很多开始慢的同学后面反而学得更扎实。坚持最重要，你已经迈出第一步了，比90%的人强	1	t	1765108700	\N	\N	MSG0	9000000000000000227	\N	2026-05-25 10:44:38.349546	pending	\N	\N	\N	\N	\N
180381	229	wxid_hejun12	wxid_hejun12	何军-建筑师	谢谢老师鼓励，我继续加油	1	f	1765108950	\N	\N	MSG0	9000000000000000228	\N	2026-05-25 10:44:38.349547	pending	\N	\N	\N	\N	\N
180382	230	wxid_hejun12	self	我	加油！有问题随时问，群里的同学也很热心互相帮助。下周的项目课会很有意思，坚持到那里你会发现编程其实挺好玩的	1	t	1765109319	\N	\N	MSG0	9000000000000000229	\N	2026-05-25 10:44:38.349548	pending	\N	\N	\N	\N	\N
180383	87	wxid_songwei16	wxid_songwei16	宋伟-研究生	我也在看其他家的课程，你们跟XX教育比有什么优势	1	f	1765156361	\N	\N	MSG0	9000000000000000086	\N	2026-05-25 10:44:38.349549	pending	\N	\N	\N	\N	\N
180384	88	wxid_songwei16	self	我	好问题！主要3个差异：\n1）我们是小班制（每期30人），他们大班200+人，辅导质量不一样\n2）我们的项目是真实企业需求，不是玩具demo\n3）我们提供1年就业跟踪服务，不是学完就不管了	1	t	1765156533	\N	\N	MSG0	9000000000000000087	\N	2026-05-25 10:44:38.349551	pending	\N	\N	\N	\N	\N
180385	91	wxid_songwei16	wxid_songwei16	宋伟-研究生	有道理，我再对比看看	1	f	1765156585	\N	\N	MSG0	9000000000000000090	\N	2026-05-25 10:44:38.349552	pending	\N	\N	\N	\N	\N
180386	89	wxid_songwei16	wxid_songwei16	宋伟-研究生	他们价格比你们便宜一千多	1	f	1765156589	\N	\N	MSG0	9000000000000000088	\N	2026-05-25 10:44:38.349553	pending	\N	\N	\N	\N	\N
180387	90	wxid_songwei16	self	我	嗯价格确实有差异。但你可以对比一下：他们的课时、项目数量、辅导模式、就业服务。算下来我们的性价比其实更高。而且我们有7天无理由退款，零风险试学	1	t	1765156661	\N	\N	MSG0	9000000000000000089	\N	2026-05-25 10:44:38.349554	pending	\N	\N	\N	\N	\N
180388	92	wxid_songwei16	self	我	好的～我把我们的详细课程对比表发你，你可以逐项对比。有问题随时问我，不管最后选哪家，选适合自己的最重要	1	t	1765157076	\N	\N	MSG0	9000000000000000091	\N	2026-05-25 10:44:38.349555	pending	\N	\N	\N	\N	\N
180389	13	wxid_wangfang03	wxid_wangfang03	王芳-宝妈	我想问下如果学了几天觉得不适合，能退款吗	1	f	1765267752	\N	\N	MSG0	9000000000000000012	\N	2026-05-25 10:44:38.349556	pending	\N	\N	\N	\N	\N
180390	14	wxid_wangfang03	self	我	可以的！我们有7天无理由退款政策，报名后7天内不满意全额退款，不需要任何理由。超过7天的话第一个月内可以按比例退	1	t	1765267789	\N	\N	MSG0	9000000000000000013	\N	2026-05-25 10:44:38.349557	pending	\N	\N	\N	\N	\N
180391	15	wxid_wangfang03	wxid_wangfang03	王芳-宝妈	那我就放心了，先试试看	1	f	1765268012	\N	\N	MSG0	9000000000000000014	\N	2026-05-25 10:44:38.349559	pending	\N	\N	\N	\N	\N
180392	16	wxid_wangfang03	self	我	对的，零风险试学！很多同学一开始也有顾虑，试了几天就觉得内容很实用，停不下来了哈哈。你先体验，有任何问题随时找我	1	t	1765268106	\N	\N	MSG0	9000000000000000015	\N	2026-05-25 10:44:38.34956	pending	\N	\N	\N	\N	\N
180393	81	wxid_malin15	wxid_malin15	马琳-会计	你们课程具体教什么内容啊，能详细说说吗	1	f	1765688392	\N	\N	MSG0	9000000000000000080	\N	2026-05-25 10:44:38.349561	pending	\N	\N	\N	\N	\N
180394	84	wxid_malin15	self	我	对！RAG现在是企业AI落地最火的方向，50%以上的AI岗位都在做RAG相关的事。我们这个模块会带你从零搭建一个完整的知识库问答系统，用的都是企业级技术栈	1	t	1765688527	\N	\N	MSG0	9000000000000000083	\N	2026-05-25 10:44:38.349562	pending	\N	\N	\N	\N	\N
180395	82	wxid_malin15	self	我	好的！课程分5个模块：\n1️⃣ Python编程基础（2周）\n2️⃣ 数据分析与机器学习（3周）\n3️⃣ 深度学习与大模型原理（3周）\n4️⃣ LLM应用开发：RAG、Agent、LangChain（3周）\n5️⃣ 全栈项目实战+就业冲刺（3周）	1	t	1765688558	\N	\N	MSG0	9000000000000000081	\N	2026-05-25 10:44:38.349563	pending	\N	\N	\N	\N	\N
180396	83	wxid_malin15	wxid_malin15	马琳-会计	第4个模块听起来很实用，现在企业是不是都在用RAG	1	f	1765688618	\N	\N	MSG0	9000000000000000082	\N	2026-05-25 10:44:38.349564	pending	\N	\N	\N	\N	\N
180397	86	wxid_malin15	self	我	你会做5个实战项目：智能客服机器人、文档问答系统、AI写作助手、数据分析平台、还有一个自选毕业项目。这些都能直接放简历里，面试的时候很加分	1	t	1765689012	\N	\N	MSG0	9000000000000000085	\N	2026-05-25 10:44:38.349565	pending	\N	\N	\N	\N	\N
180398	85	wxid_malin15	wxid_malin15	马琳-会计	学完能做什么样的项目	1	f	1765689036	\N	\N	MSG0	9000000000000000084	\N	2026-05-25 10:44:38.349566	pending	\N	\N	\N	\N	\N
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sessions (id, session_id, display_name, is_chatroom, last_message, last_time, message_count, created_at, updated_at) FROM stdin;
1605	wxid_caojie18	曹杰-机械工程师	f	那我试试吧	1764571673	10	2026-05-25 10:44:38.406421	2026-05-25 10:44:38.406425
1606	wxid_chenxi05	陈曦-产品经理	f	价格一样吗	1764125975	6	2026-05-25 10:44:38.406427	2026-05-25 10:44:38.406428
1607	wxid_dengxia17	邓霞-电商运营	f	好的，你发我看看，我跟他们商量下	1764415160	6	2026-05-25 10:44:38.406429	2026-05-25 10:44:38.40643
1608	wxid_fengli19	冯丽-美术老师	f	我是做运营的，完全没有编程基础，能学会吗	1765090523	12	2026-05-25 10:44:38.406431	2026-05-25 10:44:38.406432
1609	wxid_guofei13	郭飞-自媒体	f	原价6980，现在新年活动价4666，包含全部课程+项目实战+就业辅导+终身回看。这个价格本周五截止哦	1761021377	6	2026-05-25 10:44:38.406433	2026-05-25 10:44:38.406434
1610	wxid_hejun12	何军-建筑师	f	加油！有问题随时问，群里的同学也很热心互相帮助。下周的项目课会很有意思，坚持到那里你会发现编程其实挺好玩的	1765109319	18	2026-05-25 10:44:38.406435	2026-05-25 10:44:38.406436
1611	wxid_huanghai10	黄海-销售	f	加油！有问题随时问，群里的同学也很热心互相帮助。下周的项目课会很有意思，坚持到那里你会发现编程其实挺好玩的	1763111923	18	2026-05-25 10:44:38.406437	2026-05-25 10:44:38.406438
1612	wxid_lina02	李娜-转行咨询	f	那我加油学！	1761454101	6	2026-05-25 10:44:38.406439	2026-05-25 10:44:38.40644
1613	wxid_liuyang04	刘洋-程序员	f	你可以做AI财务产品经理、财税AI解决方案顾问，或者在现有公司推动AI转型。薪资比纯会计高50%以上，而且不可替代性更强	1762585506	10	2026-05-25 10:44:38.406441	2026-05-25 10:44:38.406442
1614	wxid_malin15	马琳-会计	f	学完能做什么样的项目	1765689036	6	2026-05-25 10:44:38.406443	2026-05-25 10:44:38.406444
1615	wxid_panyu20	潘宇-律师	f	价格一样吗	1763610291	22	2026-05-25 10:44:38.406445	2026-05-25 10:44:38.406446
1616	wxid_songwei16	宋伟-研究生	f	好的～我把我们的详细课程对比表发你，你可以逐项对比。有问题随时问我，不管最后选哪家，选适合自己的最重要	1765157076	32	2026-05-25 10:44:38.406447	2026-05-25 10:44:38.406448
1617	wxid_sunli07	孙丽-HR转行	f	一样的价格，但内容密度更高。而且进阶班的同学背景都比较强，讨论质量很高，对你帮助会更大	1764898765	24	2026-05-25 10:44:38.406449	2026-05-25 10:44:38.40645
1618	wxid_tangyan11	唐燕-护士转行	f	根据你的金融背景，AI+金融方向很适合你。比如智能风控、量化分析、金融知识库这些。我们课程里有金融场景的项目实战，学完直接能用	1764990234	12	2026-05-25 10:44:38.406451	2026-05-25 10:44:38.406452
1619	wxid_wangfang03	王芳-宝妈	f	对的，零风险试学！很多同学一开始也有顾虑，试了几天就觉得内容很实用，停不下来了哈哈。你先体验，有任何问题随时找我	1765268106	14	2026-05-25 10:44:38.406453	2026-05-25 10:44:38.406454
1620	wxid_wumin09	吴敏-老师	f	有！小陈之前做美食博主，学完后开了AI教程账号，3个月涨粉20万。还有做知识付费的学员，用AI搭建了自动答疑系统，省了2个客服的人力成本	1764144280	18	2026-05-25 10:44:38.406455	2026-05-25 10:44:38.406456
1621	wxid_xulei14	徐磊-司机转行	f	发你了！里面有电商行业的AI应用案例和培训方案。你跟老板商量下，我们可以安排一次免费的需求沟通会	1764640578	16	2026-05-25 10:44:38.406457	2026-05-25 10:44:38.406458
1622	wxid_yeling21	叶玲-餐饮老板	f	两个一起报的话总共减800，相当于短期班半价。而且全栈课程里的视觉模块会讲得更深入，两个互补	1764592385	28	2026-05-25 10:44:38.406459	2026-05-25 10:44:38.40646
1623	wxid_zhangwei01	张伟-想学AI	f	加油！有问题随时问，群里的同学也很热心互相帮助。下周的项目课会很有意思，坚持到那里你会发现编程其实挺好玩的	1762068283	12	2026-05-25 10:44:38.406461	2026-05-25 10:44:38.406462
1624	wxid_zhaolei06	赵磊-金融行业	f	没问题，不着急～我先把课程大纲和学员案例发你看看，有问题随时找我。对了活动价周五就恢复原价了，想好了尽早跟我说哈	1763610339	12	2026-05-25 10:44:38.406463	2026-05-25 10:44:38.406464
1625	wxid_zhoujie08	周杰-应届生	f	收到啦！欢迎加入第12期训练营🎉 我已经把你拉进班级群了，你的专属导师是王老师。本周六晚8点有开营直播，记得来哦！学习资料我稍后私发你	1763545849	12	2026-05-25 10:44:38.406465	2026-05-25 10:44:38.406466
\.


--
-- Data for Name: staging_conversations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.staging_conversations (id, original_text, cleaned_text, conversation_json, session_id, source_message_ids, start_time, end_time, auto_question, auto_answer, auto_category, auto_quality_score, auto_flags, human_question, human_answer, human_category, human_notes, status, reviewed_by, reviewed_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: student_info_bindings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.student_info_bindings (id, student_id, material_id, is_primary, sort_order, created_at) FROM stdin;
\.


--
-- Data for Name: student_report_bindings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.student_report_bindings (id, student_id, material_id, is_primary, sort_order, created_at) FROM stdin;
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.students (id, name, channel, job_title, pre_salary, post_salary, bday, city, education, graduation_cohort, enroll_date, graduation_date, phone, douyin_order, class_name, main_report_material_id, status, created_at, updated_at, main_info_material_id) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, username, hashed_password, nickname, role, is_active, created_at, updated_at) FROM stdin;
1	le e	$2b$12$VUhyEXzOlNwhkMccs8aaQOBU8kNPBbVUzBRyPRjOhkza/.ewtyO6S	le e	admin	t	2026-05-21 07:21:49.809979	2026-05-21 07:21:49.809984
2	admin	$2b$12$IzX5KsKqsJqPU0fuiGdDce2kxiiHUIJGrBAlkHOUfjqcn3Yr7mtHy	admin	user	t	2026-05-21 07:24:48.797396	2026-05-21 07:24:48.797402
3	lee	$2b$12$ftWfr.krct/ZKyKw6ksJt.aW8KI9CHL6OFxgPD29iqqLei7OUfrUe	lee	user	t	2026-05-25 10:17:15.776635	2026-05-25 10:17:15.77664
\.


--
-- Name: contacts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.contacts_id_seq', 8626, true);


--
-- Name: custom_conversations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.custom_conversations_id_seq', 1, false);


--
-- Name: knowledge_articles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.knowledge_articles_id_seq', 1, false);


--
-- Name: knowledge_chunks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.knowledge_chunks_id_seq', 1, false);


--
-- Name: labeled_conversations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.labeled_conversations_id_seq', 1, false);


--
-- Name: materials_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.materials_id_seq', 1, false);


--
-- Name: quiz_attempts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.quiz_attempts_id_seq', 1, false);


--
-- Name: quizzes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.quizzes_id_seq', 1, false);


--
-- Name: raw_chats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.raw_chats_id_seq', 180398, true);


--
-- Name: sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sessions_id_seq', 1625, true);


--
-- Name: staging_conversations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.staging_conversations_id_seq', 1, false);


--
-- Name: student_info_bindings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.student_info_bindings_id_seq', 1, false);


--
-- Name: student_report_bindings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.student_report_bindings_id_seq', 1, false);


--
-- Name: students_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.students_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 3, true);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: custom_conversations custom_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_conversations
    ADD CONSTRAINT custom_conversations_pkey PRIMARY KEY (id);


--
-- Name: knowledge_articles knowledge_articles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_articles
    ADD CONSTRAINT knowledge_articles_pkey PRIMARY KEY (id);


--
-- Name: knowledge_chunks knowledge_chunks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledge_chunks
    ADD CONSTRAINT knowledge_chunks_pkey PRIMARY KEY (id);


--
-- Name: labeled_conversations labeled_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.labeled_conversations
    ADD CONSTRAINT labeled_conversations_pkey PRIMARY KEY (id);


--
-- Name: materials materials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.materials
    ADD CONSTRAINT materials_pkey PRIMARY KEY (id);


--
-- Name: quiz_attempts quiz_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quiz_attempts
    ADD CONSTRAINT quiz_attempts_pkey PRIMARY KEY (id);


--
-- Name: quizzes quizzes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quizzes
    ADD CONSTRAINT quizzes_pkey PRIMARY KEY (id);


--
-- Name: raw_chats raw_chats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.raw_chats
    ADD CONSTRAINT raw_chats_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: staging_conversations staging_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staging_conversations
    ADD CONSTRAINT staging_conversations_pkey PRIMARY KEY (id);


--
-- Name: student_info_bindings student_info_bindings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_info_bindings
    ADD CONSTRAINT student_info_bindings_pkey PRIMARY KEY (id);


--
-- Name: student_report_bindings student_report_bindings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.student_report_bindings
    ADD CONSTRAINT student_report_bindings_pkey PRIMARY KEY (id);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_article_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_article_category ON public.knowledge_articles USING btree (scene_category);


--
-- Name: idx_article_verified; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_article_verified ON public.knowledge_articles USING btree (is_verified);


--
-- Name: idx_custom_category_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_custom_category_active ON public.custom_conversations USING btree (category, is_active);


--
-- Name: idx_labeled_status_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_labeled_status_category ON public.labeled_conversations USING btree (status, human_category);


--
-- Name: idx_material_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_material_category ON public.materials USING btree (category);


--
-- Name: idx_material_folder; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_material_folder ON public.materials USING btree (folder_id, category);


--
-- Name: idx_material_tags_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_material_tags_gin ON public.materials USING gin (tags);


--
-- Name: idx_session_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_session_timestamp ON public.raw_chats USING btree (session_id, "timestamp");


--
-- Name: idx_staging_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_staging_created ON public.staging_conversations USING btree (created_at);


--
-- Name: idx_staging_status_session; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_staging_status_session ON public.staging_conversations USING btree (status, session_id);


--
-- Name: idx_status_session; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_status_session ON public.raw_chats USING btree (status, session_id);


--
-- Name: idx_student_channel; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_student_channel ON public.students USING btree (channel);


--
-- Name: idx_student_class; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_student_class ON public.students USING btree (class_name);


--
-- Name: ix_contacts_wxid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_contacts_wxid ON public.contacts USING btree (wxid);


--
-- Name: ix_custom_conversations_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_custom_conversations_category ON public.custom_conversations USING btree (category);


--
-- Name: ix_custom_conversations_is_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_custom_conversations_is_active ON public.custom_conversations USING btree (is_active);


--
-- Name: ix_knowledge_articles_scene_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_knowledge_articles_scene_category ON public.knowledge_articles USING btree (scene_category);


--
-- Name: ix_knowledge_chunks_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_knowledge_chunks_session_id ON public.knowledge_chunks USING btree (session_id);


--
-- Name: ix_labeled_conversations_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_labeled_conversations_session_id ON public.labeled_conversations USING btree (session_id);


--
-- Name: ix_labeled_conversations_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_labeled_conversations_status ON public.labeled_conversations USING btree (status);


--
-- Name: ix_materials_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_materials_category ON public.materials USING btree (category);


--
-- Name: ix_materials_folder_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_materials_folder_id ON public.materials USING btree (folder_id);


--
-- Name: ix_quiz_attempts_quiz_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_quiz_attempts_quiz_id ON public.quiz_attempts USING btree (quiz_id);


--
-- Name: ix_quiz_attempts_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_quiz_attempts_status ON public.quiz_attempts USING btree (status);


--
-- Name: ix_quizzes_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_quizzes_category ON public.quizzes USING btree (category);


--
-- Name: ix_quizzes_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_quizzes_status ON public.quizzes USING btree (status);


--
-- Name: ix_raw_chats_msg_server_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_raw_chats_msg_server_id ON public.raw_chats USING btree (msg_server_id);


--
-- Name: ix_raw_chats_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_raw_chats_session_id ON public.raw_chats USING btree (session_id);


--
-- Name: ix_raw_chats_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_raw_chats_status ON public.raw_chats USING btree (status);


--
-- Name: ix_raw_chats_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_raw_chats_timestamp ON public.raw_chats USING btree ("timestamp");


--
-- Name: ix_sessions_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_sessions_session_id ON public.sessions USING btree (session_id);


--
-- Name: ix_staging_conversations_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_staging_conversations_session_id ON public.staging_conversations USING btree (session_id);


--
-- Name: ix_staging_conversations_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_staging_conversations_status ON public.staging_conversations USING btree (status);


--
-- Name: ix_student_info_bindings_material_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_student_info_bindings_material_id ON public.student_info_bindings USING btree (material_id);


--
-- Name: ix_student_info_bindings_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_student_info_bindings_student_id ON public.student_info_bindings USING btree (student_id);


--
-- Name: ix_student_report_bindings_material_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_student_report_bindings_material_id ON public.student_report_bindings USING btree (material_id);


--
-- Name: ix_student_report_bindings_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_student_report_bindings_student_id ON public.student_report_bindings USING btree (student_id);


--
-- Name: ix_students_main_info_material_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_students_main_info_material_id ON public.students USING btree (main_info_material_id);


--
-- Name: ix_students_main_report_material_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_students_main_report_material_id ON public.students USING btree (main_report_material_id);


--
-- Name: ix_students_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_students_status ON public.students USING btree (status);


--
-- Name: ix_users_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_users_username ON public.users USING btree (username);


--
-- Name: uq_student_info_material; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_student_info_material ON public.student_info_bindings USING btree (student_id, material_id);


--
-- Name: uq_student_material; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_student_material ON public.student_report_bindings USING btree (student_id, material_id);


--
-- PostgreSQL database dump complete
--

\unrestrict a4bhPPdMHnwCjhiZFdouKYZuKF7EZ4jD0QnCdDRarNE4Qbz134PpadSjWC9p5kp

