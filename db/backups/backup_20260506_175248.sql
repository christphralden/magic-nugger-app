--
-- PostgreSQL database dump
--

\restrict bLrcTANkptjFPMJNNBtmg0CLHxyvW7ocK0gViCDfrgC8bMBehwLkS0AYbq2JqVF

-- Dumped from database version 16.13
-- Dumped by pg_dump version 18.3

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
-- Name: _v; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA _v;


ALTER SCHEMA _v OWNER TO postgres;

--
-- Name: audit; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA audit;


ALTER SCHEMA audit OWNER TO postgres;

--
-- Name: partman; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA partman;


ALTER SCHEMA partman OWNER TO postgres;

--
-- Name: pg_partman; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_partman WITH SCHEMA partman;


--
-- Name: EXTENSION pg_partman; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_partman IS 'Extension to manage partitioned tables by time or ID';


--
-- Name: try_register_patch(text, text[], text); Type: FUNCTION; Schema: _v; Owner: postgres
--

CREATE FUNCTION _v.try_register_patch(patch_name text, dependencies text[] DEFAULT NULL::text[], description text DEFAULT NULL::text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
DECLARE
  dep TEXT;
BEGIN
  IF EXISTS (SELECT 1 FROM _v.patches WHERE patches.patch_name = $1) THEN
    RETURN false;
  END IF;

  IF dependencies IS NOT NULL THEN
    FOREACH dep IN ARRAY dependencies LOOP
      IF NOT EXISTS (SELECT 1 FROM _v.patches WHERE patches.patch_name = dep) THEN
        RAISE EXCEPTION 'Missing dependency: %', dep;
      END IF;
    END LOOP;
  END IF;

  INSERT INTO _v.patches (patch_name, dependencies, description)
  VALUES ($1, $2, $3);
  RETURN true;
END;
$_$;


ALTER FUNCTION _v.try_register_patch(patch_name text, dependencies text[], description text) OWNER TO postgres;

--
-- Name: unregister_patch(text); Type: FUNCTION; Schema: _v; Owner: postgres
--

CREATE FUNCTION _v.unregister_patch(patch_name text) RETURNS void
    LANGUAGE plpgsql
    AS $_$
BEGIN
  DELETE FROM _v.patches WHERE patches.patch_name = $1;
END;
$_$;


ALTER FUNCTION _v.unregister_patch(patch_name text) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: patches; Type: TABLE; Schema: _v; Owner: postgres
--

CREATE TABLE _v.patches (
    id integer NOT NULL,
    patch_name character varying(255) NOT NULL,
    dependencies text[],
    description text,
    applied_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE _v.patches OWNER TO postgres;

--
-- Name: patches_id_seq; Type: SEQUENCE; Schema: _v; Owner: postgres
--

CREATE SEQUENCE _v.patches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE _v.patches_id_seq OWNER TO postgres;

--
-- Name: patches_id_seq; Type: SEQUENCE OWNED BY; Schema: _v; Owner: postgres
--

ALTER SEQUENCE _v.patches_id_seq OWNED BY _v.patches.id;


--
-- Name: audit_events; Type: TABLE; Schema: audit; Owner: partman_user
--

CREATE TABLE audit.audit_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    url character varying(255) NOT NULL,
    status_code smallint NOT NULL,
    ip_address inet,
    user_agent text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    http_method character varying(10) DEFAULT NULL::character varying
)
PARTITION BY RANGE (created_at);


ALTER TABLE audit.audit_events OWNER TO partman_user;

--
-- Name: audit_events_default; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.audit_events_default (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    url character varying(255) NOT NULL,
    status_code smallint NOT NULL,
    ip_address inet,
    user_agent text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    http_method character varying(10) DEFAULT NULL::character varying
);


ALTER TABLE audit.audit_events_default OWNER TO postgres;

--
-- Name: audit_events_p20260201; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.audit_events_p20260201 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    url character varying(255) NOT NULL,
    status_code smallint NOT NULL,
    ip_address inet,
    user_agent text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    http_method character varying(10) DEFAULT NULL::character varying
);


ALTER TABLE audit.audit_events_p20260201 OWNER TO postgres;

--
-- Name: audit_events_p20260301; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.audit_events_p20260301 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    url character varying(255) NOT NULL,
    status_code smallint NOT NULL,
    ip_address inet,
    user_agent text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    http_method character varying(10) DEFAULT NULL::character varying
);


ALTER TABLE audit.audit_events_p20260301 OWNER TO postgres;

--
-- Name: audit_events_p20260401; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.audit_events_p20260401 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    url character varying(255) NOT NULL,
    status_code smallint NOT NULL,
    ip_address inet,
    user_agent text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    http_method character varying(10) DEFAULT NULL::character varying
);


ALTER TABLE audit.audit_events_p20260401 OWNER TO postgres;

--
-- Name: audit_events_p20260501; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.audit_events_p20260501 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    url character varying(255) NOT NULL,
    status_code smallint NOT NULL,
    ip_address inet,
    user_agent text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    http_method character varying(10) DEFAULT NULL::character varying
);


ALTER TABLE audit.audit_events_p20260501 OWNER TO postgres;

--
-- Name: audit_events_p20260601; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.audit_events_p20260601 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    url character varying(255) NOT NULL,
    status_code smallint NOT NULL,
    ip_address inet,
    user_agent text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    http_method character varying(10) DEFAULT NULL::character varying
);


ALTER TABLE audit.audit_events_p20260601 OWNER TO postgres;

--
-- Name: audit_events_p20260701; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.audit_events_p20260701 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    url character varying(255) NOT NULL,
    status_code smallint NOT NULL,
    ip_address inet,
    user_agent text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    http_method character varying(10) DEFAULT NULL::character varying
);


ALTER TABLE audit.audit_events_p20260701 OWNER TO postgres;

--
-- Name: audit_events_p20260801; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.audit_events_p20260801 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    url character varying(255) NOT NULL,
    status_code smallint NOT NULL,
    ip_address inet,
    user_agent text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    http_method character varying(10) DEFAULT NULL::character varying
);


ALTER TABLE audit.audit_events_p20260801 OWNER TO postgres;

--
-- Name: log_events; Type: TABLE; Schema: audit; Owner: partman_user
--

CREATE TABLE audit.log_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    event character varying(255) NOT NULL,
    level character varying(16) DEFAULT 'info'::character varying NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT log_events_level_check CHECK (((level)::text = ANY ((ARRAY['info'::character varying, 'warning'::character varying, 'error'::character varying, 'fatal'::character varying])::text[])))
)
PARTITION BY RANGE (created_at);


ALTER TABLE audit.log_events OWNER TO partman_user;

--
-- Name: log_events_default; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.log_events_default (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    event character varying(255) NOT NULL,
    level character varying(16) DEFAULT 'info'::character varying NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT log_events_level_check CHECK (((level)::text = ANY ((ARRAY['info'::character varying, 'warning'::character varying, 'error'::character varying, 'fatal'::character varying])::text[])))
);


ALTER TABLE audit.log_events_default OWNER TO postgres;

--
-- Name: log_events_p20260201; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.log_events_p20260201 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    event character varying(255) NOT NULL,
    level character varying(16) DEFAULT 'info'::character varying NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT log_events_level_check CHECK (((level)::text = ANY ((ARRAY['info'::character varying, 'warning'::character varying, 'error'::character varying, 'fatal'::character varying])::text[])))
);


ALTER TABLE audit.log_events_p20260201 OWNER TO postgres;

--
-- Name: log_events_p20260301; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.log_events_p20260301 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    event character varying(255) NOT NULL,
    level character varying(16) DEFAULT 'info'::character varying NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT log_events_level_check CHECK (((level)::text = ANY ((ARRAY['info'::character varying, 'warning'::character varying, 'error'::character varying, 'fatal'::character varying])::text[])))
);


ALTER TABLE audit.log_events_p20260301 OWNER TO postgres;

--
-- Name: log_events_p20260401; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.log_events_p20260401 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    event character varying(255) NOT NULL,
    level character varying(16) DEFAULT 'info'::character varying NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT log_events_level_check CHECK (((level)::text = ANY ((ARRAY['info'::character varying, 'warning'::character varying, 'error'::character varying, 'fatal'::character varying])::text[])))
);


ALTER TABLE audit.log_events_p20260401 OWNER TO postgres;

--
-- Name: log_events_p20260501; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.log_events_p20260501 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    event character varying(255) NOT NULL,
    level character varying(16) DEFAULT 'info'::character varying NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT log_events_level_check CHECK (((level)::text = ANY ((ARRAY['info'::character varying, 'warning'::character varying, 'error'::character varying, 'fatal'::character varying])::text[])))
);


ALTER TABLE audit.log_events_p20260501 OWNER TO postgres;

--
-- Name: log_events_p20260601; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.log_events_p20260601 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    event character varying(255) NOT NULL,
    level character varying(16) DEFAULT 'info'::character varying NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT log_events_level_check CHECK (((level)::text = ANY ((ARRAY['info'::character varying, 'warning'::character varying, 'error'::character varying, 'fatal'::character varying])::text[])))
);


ALTER TABLE audit.log_events_p20260601 OWNER TO postgres;

--
-- Name: log_events_p20260701; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.log_events_p20260701 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    event character varying(255) NOT NULL,
    level character varying(16) DEFAULT 'info'::character varying NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT log_events_level_check CHECK (((level)::text = ANY ((ARRAY['info'::character varying, 'warning'::character varying, 'error'::character varying, 'fatal'::character varying])::text[])))
);


ALTER TABLE audit.log_events_p20260701 OWNER TO postgres;

--
-- Name: log_events_p20260801; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.log_events_p20260801 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    event character varying(255) NOT NULL,
    level character varying(16) DEFAULT 'info'::character varying NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT log_events_level_check CHECK (((level)::text = ANY ((ARRAY['info'::character varying, 'warning'::character varying, 'error'::character varying, 'fatal'::character varying])::text[])))
);


ALTER TABLE audit.log_events_p20260801 OWNER TO postgres;

--
-- Name: template_audit_audit_events; Type: TABLE; Schema: partman; Owner: partman_user
--

CREATE TABLE partman.template_audit_audit_events (
    id uuid NOT NULL,
    user_id uuid,
    url character varying(255) NOT NULL,
    status_code smallint NOT NULL,
    ip_address inet,
    user_agent text,
    metadata jsonb,
    created_at timestamp with time zone NOT NULL,
    http_method character varying(10) DEFAULT NULL::character varying
);


ALTER TABLE partman.template_audit_audit_events OWNER TO partman_user;

--
-- Name: template_audit_log_events; Type: TABLE; Schema: partman; Owner: partman_user
--

CREATE TABLE partman.template_audit_log_events (
    id uuid NOT NULL,
    user_id uuid,
    event character varying(255) NOT NULL,
    level character varying(16) NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE partman.template_audit_log_events OWNER TO partman_user;

--
-- Name: template_public_elo_history; Type: TABLE; Schema: partman; Owner: partman_user
--

CREATE TABLE partman.template_public_elo_history (
    id bigint NOT NULL,
    player_id uuid NOT NULL,
    session_id uuid,
    elo_before integer NOT NULL,
    elo_after integer NOT NULL,
    delta integer NOT NULL,
    reason character varying(32) NOT NULL,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE partman.template_public_elo_history OWNER TO partman_user;

--
-- Name: template_public_session_answers; Type: TABLE; Schema: partman; Owner: partman_user
--

CREATE TABLE partman.template_public_session_answers (
    id bigint NOT NULL,
    session_id uuid NOT NULL,
    is_correct boolean NOT NULL,
    elo_delta integer NOT NULL,
    time_taken_ms integer,
    answered_at timestamp with time zone NOT NULL
);


ALTER TABLE partman.template_public_session_answers OWNER TO partman_user;

--
-- Name: classroom_members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.classroom_members (
    classroom_id uuid NOT NULL,
    player_id uuid NOT NULL,
    classroom_elo integer NOT NULL,
    joined_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.classroom_members OWNER TO postgres;

--
-- Name: classrooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.classrooms (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(128) NOT NULL,
    description text,
    teacher_id uuid NOT NULL,
    visibility character varying(16) DEFAULT 'private'::character varying NOT NULL,
    starting_elo integer DEFAULT 0 NOT NULL,
    elo_cap integer,
    invite_code character varying(16) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT classrooms_visibility_check CHECK (((visibility)::text = ANY ((ARRAY['private'::character varying, 'public'::character varying])::text[]))),
    CONSTRAINT elo_cap_above_floor CHECK (((elo_cap IS NULL) OR (elo_cap > starting_elo)))
);


ALTER TABLE public.classrooms OWNER TO postgres;

--
-- Name: elo_history; Type: TABLE; Schema: public; Owner: partman_user
--

CREATE TABLE public.elo_history (
    id bigint NOT NULL,
    player_id uuid NOT NULL,
    session_id uuid,
    elo_before integer NOT NULL,
    elo_after integer NOT NULL,
    delta integer NOT NULL,
    reason character varying(32) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT elo_history_reason_check CHECK (((reason)::text = ANY ((ARRAY['session_completed'::character varying, 'session_failed'::character varying, 'admin_adjustment'::character varying, 'decay'::character varying])::text[])))
)
PARTITION BY RANGE (created_at);


ALTER TABLE public.elo_history OWNER TO partman_user;

--
-- Name: elo_history_id_seq; Type: SEQUENCE; Schema: public; Owner: partman_user
--

CREATE SEQUENCE public.elo_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.elo_history_id_seq OWNER TO partman_user;

--
-- Name: elo_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: partman_user
--

ALTER SEQUENCE public.elo_history_id_seq OWNED BY public.elo_history.id;


--
-- Name: elo_history_default; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.elo_history_default (
    id bigint DEFAULT nextval('public.elo_history_id_seq'::regclass) NOT NULL,
    player_id uuid NOT NULL,
    session_id uuid,
    elo_before integer NOT NULL,
    elo_after integer NOT NULL,
    delta integer NOT NULL,
    reason character varying(32) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT elo_history_reason_check CHECK (((reason)::text = ANY ((ARRAY['session_completed'::character varying, 'session_failed'::character varying, 'admin_adjustment'::character varying, 'decay'::character varying])::text[])))
);


ALTER TABLE public.elo_history_default OWNER TO postgres;

--
-- Name: elo_history_p20260415; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.elo_history_p20260415 (
    id bigint DEFAULT nextval('public.elo_history_id_seq'::regclass) NOT NULL,
    player_id uuid NOT NULL,
    session_id uuid,
    elo_before integer NOT NULL,
    elo_after integer NOT NULL,
    delta integer NOT NULL,
    reason character varying(32) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT elo_history_reason_check CHECK (((reason)::text = ANY ((ARRAY['session_completed'::character varying, 'session_failed'::character varying, 'admin_adjustment'::character varying, 'decay'::character varying])::text[])))
);


ALTER TABLE public.elo_history_p20260415 OWNER TO postgres;

--
-- Name: elo_history_p20260422; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.elo_history_p20260422 (
    id bigint DEFAULT nextval('public.elo_history_id_seq'::regclass) NOT NULL,
    player_id uuid NOT NULL,
    session_id uuid,
    elo_before integer NOT NULL,
    elo_after integer NOT NULL,
    delta integer NOT NULL,
    reason character varying(32) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT elo_history_reason_check CHECK (((reason)::text = ANY ((ARRAY['session_completed'::character varying, 'session_failed'::character varying, 'admin_adjustment'::character varying, 'decay'::character varying])::text[])))
);


ALTER TABLE public.elo_history_p20260422 OWNER TO postgres;

--
-- Name: elo_history_p20260429; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.elo_history_p20260429 (
    id bigint DEFAULT nextval('public.elo_history_id_seq'::regclass) NOT NULL,
    player_id uuid NOT NULL,
    session_id uuid,
    elo_before integer NOT NULL,
    elo_after integer NOT NULL,
    delta integer NOT NULL,
    reason character varying(32) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT elo_history_reason_check CHECK (((reason)::text = ANY ((ARRAY['session_completed'::character varying, 'session_failed'::character varying, 'admin_adjustment'::character varying, 'decay'::character varying])::text[])))
);


ALTER TABLE public.elo_history_p20260429 OWNER TO postgres;

--
-- Name: elo_history_p20260506; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.elo_history_p20260506 (
    id bigint DEFAULT nextval('public.elo_history_id_seq'::regclass) NOT NULL,
    player_id uuid NOT NULL,
    session_id uuid,
    elo_before integer NOT NULL,
    elo_after integer NOT NULL,
    delta integer NOT NULL,
    reason character varying(32) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT elo_history_reason_check CHECK (((reason)::text = ANY ((ARRAY['session_completed'::character varying, 'session_failed'::character varying, 'admin_adjustment'::character varying, 'decay'::character varying])::text[])))
);


ALTER TABLE public.elo_history_p20260506 OWNER TO postgres;

--
-- Name: elo_history_p20260513; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.elo_history_p20260513 (
    id bigint DEFAULT nextval('public.elo_history_id_seq'::regclass) NOT NULL,
    player_id uuid NOT NULL,
    session_id uuid,
    elo_before integer NOT NULL,
    elo_after integer NOT NULL,
    delta integer NOT NULL,
    reason character varying(32) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT elo_history_reason_check CHECK (((reason)::text = ANY ((ARRAY['session_completed'::character varying, 'session_failed'::character varying, 'admin_adjustment'::character varying, 'decay'::character varying])::text[])))
);


ALTER TABLE public.elo_history_p20260513 OWNER TO postgres;

--
-- Name: elo_history_p20260520; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.elo_history_p20260520 (
    id bigint DEFAULT nextval('public.elo_history_id_seq'::regclass) NOT NULL,
    player_id uuid NOT NULL,
    session_id uuid,
    elo_before integer NOT NULL,
    elo_after integer NOT NULL,
    delta integer NOT NULL,
    reason character varying(32) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT elo_history_reason_check CHECK (((reason)::text = ANY ((ARRAY['session_completed'::character varying, 'session_failed'::character varying, 'admin_adjustment'::character varying, 'decay'::character varying])::text[])))
);


ALTER TABLE public.elo_history_p20260520 OWNER TO postgres;

--
-- Name: elo_history_p20260527; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.elo_history_p20260527 (
    id bigint DEFAULT nextval('public.elo_history_id_seq'::regclass) NOT NULL,
    player_id uuid NOT NULL,
    session_id uuid,
    elo_before integer NOT NULL,
    elo_after integer NOT NULL,
    delta integer NOT NULL,
    reason character varying(32) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT elo_history_reason_check CHECK (((reason)::text = ANY ((ARRAY['session_completed'::character varying, 'session_failed'::character varying, 'admin_adjustment'::character varying, 'decay'::character varying])::text[])))
);


ALTER TABLE public.elo_history_p20260527 OWNER TO postgres;

--
-- Name: game_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.game_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    player_id uuid NOT NULL,
    level_id integer NOT NULL,
    status character varying(16) DEFAULT 'in_progress'::character varying NOT NULL,
    score integer DEFAULT 0 NOT NULL,
    max_answers integer DEFAULT 0 NOT NULL,
    elo_before integer NOT NULL,
    elo_after integer,
    elo_delta integer,
    correct_count integer DEFAULT 0 NOT NULL,
    incorrect_count integer DEFAULT 0 NOT NULL,
    max_streak integer DEFAULT 0 NOT NULL,
    current_streak integer DEFAULT 0 NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    ended_at timestamp with time zone,
    client_ip inet,
    user_agent text,
    CONSTRAINT game_sessions_status_check CHECK (((status)::text = ANY ((ARRAY['in_progress'::character varying, 'completed'::character varying, 'failed'::character varying, 'abandoned'::character varying])::text[])))
);


ALTER TABLE public.game_sessions OWNER TO postgres;

--
-- Name: levels; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.levels (
    id integer NOT NULL,
    name character varying(64) NOT NULL,
    description text,
    order_index integer NOT NULL,
    elo_min integer DEFAULT 0 NOT NULL,
    elo_gain_correct integer DEFAULT 15 NOT NULL,
    elo_loss_incorrect integer DEFAULT 5 NOT NULL,
    time_limit_seconds integer,
    enemy_wave_config jsonb DEFAULT '{}'::jsonb NOT NULL,
    question_gen_config jsonb DEFAULT '{}'::jsonb NOT NULL,
    max_score integer DEFAULT 1000 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.levels OWNER TO postgres;

--
-- Name: levels_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.levels_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.levels_id_seq OWNER TO postgres;

--
-- Name: levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.levels_id_seq OWNED BY public.levels.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permissions (
    id integer NOT NULL,
    name character varying(64) NOT NULL
);


ALTER TABLE public.permissions OWNER TO postgres;

--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.permissions_id_seq OWNER TO postgres;

--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- Name: players; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.players (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    username character varying(32) NOT NULL,
    display_name character varying(64),
    email character varying(255) NOT NULL,
    avatar_url text,
    role_id integer DEFAULT 1 NOT NULL,
    oauth_provider character varying(32),
    oauth_id character varying(255),
    password_hash text,
    current_elo integer DEFAULT 0 NOT NULL,
    highest_level_unlocked integer DEFAULT 1 NOT NULL,
    total_questions_answered integer DEFAULT 0 NOT NULL,
    total_correct integer DEFAULT 0 NOT NULL,
    total_incorrect integer DEFAULT 0 NOT NULL,
    longest_streak integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_active_at timestamp with time zone,
    CONSTRAINT oauth_or_password CHECK ((((oauth_provider IS NOT NULL) AND (oauth_id IS NOT NULL)) OR (password_hash IS NOT NULL)))
);


ALTER TABLE public.players OWNER TO postgres;

--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role_permissions (
    role_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.role_permissions OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying(32) NOT NULL,
    description text
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session (
    sid character varying NOT NULL,
    sess json NOT NULL,
    expire timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.session OWNER TO postgres;

--
-- Name: session_answers; Type: TABLE; Schema: public; Owner: partman_user
--

CREATE TABLE public.session_answers (
    id bigint NOT NULL,
    session_id uuid NOT NULL,
    is_correct boolean NOT NULL,
    elo_delta integer NOT NULL,
    time_taken_ms integer,
    answered_at timestamp with time zone DEFAULT now() NOT NULL
)
PARTITION BY RANGE (answered_at);


ALTER TABLE public.session_answers OWNER TO partman_user;

--
-- Name: session_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: partman_user
--

CREATE SEQUENCE public.session_answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.session_answers_id_seq OWNER TO partman_user;

--
-- Name: session_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: partman_user
--

ALTER SEQUENCE public.session_answers_id_seq OWNED BY public.session_answers.id;


--
-- Name: session_answers_default; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session_answers_default (
    id bigint DEFAULT nextval('public.session_answers_id_seq'::regclass) NOT NULL,
    session_id uuid NOT NULL,
    is_correct boolean NOT NULL,
    elo_delta integer NOT NULL,
    time_taken_ms integer,
    answered_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.session_answers_default OWNER TO postgres;

--
-- Name: session_answers_p20260415; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session_answers_p20260415 (
    id bigint DEFAULT nextval('public.session_answers_id_seq'::regclass) NOT NULL,
    session_id uuid NOT NULL,
    is_correct boolean NOT NULL,
    elo_delta integer NOT NULL,
    time_taken_ms integer,
    answered_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.session_answers_p20260415 OWNER TO postgres;

--
-- Name: session_answers_p20260422; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session_answers_p20260422 (
    id bigint DEFAULT nextval('public.session_answers_id_seq'::regclass) NOT NULL,
    session_id uuid NOT NULL,
    is_correct boolean NOT NULL,
    elo_delta integer NOT NULL,
    time_taken_ms integer,
    answered_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.session_answers_p20260422 OWNER TO postgres;

--
-- Name: session_answers_p20260429; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session_answers_p20260429 (
    id bigint DEFAULT nextval('public.session_answers_id_seq'::regclass) NOT NULL,
    session_id uuid NOT NULL,
    is_correct boolean NOT NULL,
    elo_delta integer NOT NULL,
    time_taken_ms integer,
    answered_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.session_answers_p20260429 OWNER TO postgres;

--
-- Name: session_answers_p20260506; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session_answers_p20260506 (
    id bigint DEFAULT nextval('public.session_answers_id_seq'::regclass) NOT NULL,
    session_id uuid NOT NULL,
    is_correct boolean NOT NULL,
    elo_delta integer NOT NULL,
    time_taken_ms integer,
    answered_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.session_answers_p20260506 OWNER TO postgres;

--
-- Name: session_answers_p20260513; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session_answers_p20260513 (
    id bigint DEFAULT nextval('public.session_answers_id_seq'::regclass) NOT NULL,
    session_id uuid NOT NULL,
    is_correct boolean NOT NULL,
    elo_delta integer NOT NULL,
    time_taken_ms integer,
    answered_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.session_answers_p20260513 OWNER TO postgres;

--
-- Name: session_answers_p20260520; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session_answers_p20260520 (
    id bigint DEFAULT nextval('public.session_answers_id_seq'::regclass) NOT NULL,
    session_id uuid NOT NULL,
    is_correct boolean NOT NULL,
    elo_delta integer NOT NULL,
    time_taken_ms integer,
    answered_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.session_answers_p20260520 OWNER TO postgres;

--
-- Name: session_answers_p20260527; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session_answers_p20260527 (
    id bigint DEFAULT nextval('public.session_answers_id_seq'::regclass) NOT NULL,
    session_id uuid NOT NULL,
    is_correct boolean NOT NULL,
    elo_delta integer NOT NULL,
    time_taken_ms integer,
    answered_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.session_answers_p20260527 OWNER TO postgres;

--
-- Name: audit_events_default; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events ATTACH PARTITION audit.audit_events_default DEFAULT;


--
-- Name: audit_events_p20260201; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events ATTACH PARTITION audit.audit_events_p20260201 FOR VALUES FROM ('2026-02-01 00:00:00+00') TO ('2026-03-01 00:00:00+00');


--
-- Name: audit_events_p20260301; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events ATTACH PARTITION audit.audit_events_p20260301 FOR VALUES FROM ('2026-03-01 00:00:00+00') TO ('2026-04-01 00:00:00+00');


--
-- Name: audit_events_p20260401; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events ATTACH PARTITION audit.audit_events_p20260401 FOR VALUES FROM ('2026-04-01 00:00:00+00') TO ('2026-05-01 00:00:00+00');


--
-- Name: audit_events_p20260501; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events ATTACH PARTITION audit.audit_events_p20260501 FOR VALUES FROM ('2026-05-01 00:00:00+00') TO ('2026-06-01 00:00:00+00');


--
-- Name: audit_events_p20260601; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events ATTACH PARTITION audit.audit_events_p20260601 FOR VALUES FROM ('2026-06-01 00:00:00+00') TO ('2026-07-01 00:00:00+00');


--
-- Name: audit_events_p20260701; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events ATTACH PARTITION audit.audit_events_p20260701 FOR VALUES FROM ('2026-07-01 00:00:00+00') TO ('2026-08-01 00:00:00+00');


--
-- Name: audit_events_p20260801; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events ATTACH PARTITION audit.audit_events_p20260801 FOR VALUES FROM ('2026-08-01 00:00:00+00') TO ('2026-09-01 00:00:00+00');


--
-- Name: log_events_default; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events ATTACH PARTITION audit.log_events_default DEFAULT;


--
-- Name: log_events_p20260201; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events ATTACH PARTITION audit.log_events_p20260201 FOR VALUES FROM ('2026-02-01 00:00:00+00') TO ('2026-03-01 00:00:00+00');


--
-- Name: log_events_p20260301; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events ATTACH PARTITION audit.log_events_p20260301 FOR VALUES FROM ('2026-03-01 00:00:00+00') TO ('2026-04-01 00:00:00+00');


--
-- Name: log_events_p20260401; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events ATTACH PARTITION audit.log_events_p20260401 FOR VALUES FROM ('2026-04-01 00:00:00+00') TO ('2026-05-01 00:00:00+00');


--
-- Name: log_events_p20260501; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events ATTACH PARTITION audit.log_events_p20260501 FOR VALUES FROM ('2026-05-01 00:00:00+00') TO ('2026-06-01 00:00:00+00');


--
-- Name: log_events_p20260601; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events ATTACH PARTITION audit.log_events_p20260601 FOR VALUES FROM ('2026-06-01 00:00:00+00') TO ('2026-07-01 00:00:00+00');


--
-- Name: log_events_p20260701; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events ATTACH PARTITION audit.log_events_p20260701 FOR VALUES FROM ('2026-07-01 00:00:00+00') TO ('2026-08-01 00:00:00+00');


--
-- Name: log_events_p20260801; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events ATTACH PARTITION audit.log_events_p20260801 FOR VALUES FROM ('2026-08-01 00:00:00+00') TO ('2026-09-01 00:00:00+00');


--
-- Name: elo_history_default; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history ATTACH PARTITION public.elo_history_default DEFAULT;


--
-- Name: elo_history_p20260415; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history ATTACH PARTITION public.elo_history_p20260415 FOR VALUES FROM ('2026-04-15 00:00:00+00') TO ('2026-04-22 00:00:00+00');


--
-- Name: elo_history_p20260422; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history ATTACH PARTITION public.elo_history_p20260422 FOR VALUES FROM ('2026-04-22 00:00:00+00') TO ('2026-04-29 00:00:00+00');


--
-- Name: elo_history_p20260429; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history ATTACH PARTITION public.elo_history_p20260429 FOR VALUES FROM ('2026-04-29 00:00:00+00') TO ('2026-05-06 00:00:00+00');


--
-- Name: elo_history_p20260506; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history ATTACH PARTITION public.elo_history_p20260506 FOR VALUES FROM ('2026-05-06 00:00:00+00') TO ('2026-05-13 00:00:00+00');


--
-- Name: elo_history_p20260513; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history ATTACH PARTITION public.elo_history_p20260513 FOR VALUES FROM ('2026-05-13 00:00:00+00') TO ('2026-05-20 00:00:00+00');


--
-- Name: elo_history_p20260520; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history ATTACH PARTITION public.elo_history_p20260520 FOR VALUES FROM ('2026-05-20 00:00:00+00') TO ('2026-05-27 00:00:00+00');


--
-- Name: elo_history_p20260527; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history ATTACH PARTITION public.elo_history_p20260527 FOR VALUES FROM ('2026-05-27 00:00:00+00') TO ('2026-06-03 00:00:00+00');


--
-- Name: session_answers_default; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers ATTACH PARTITION public.session_answers_default DEFAULT;


--
-- Name: session_answers_p20260415; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers ATTACH PARTITION public.session_answers_p20260415 FOR VALUES FROM ('2026-04-15 00:00:00+00') TO ('2026-04-22 00:00:00+00');


--
-- Name: session_answers_p20260422; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers ATTACH PARTITION public.session_answers_p20260422 FOR VALUES FROM ('2026-04-22 00:00:00+00') TO ('2026-04-29 00:00:00+00');


--
-- Name: session_answers_p20260429; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers ATTACH PARTITION public.session_answers_p20260429 FOR VALUES FROM ('2026-04-29 00:00:00+00') TO ('2026-05-06 00:00:00+00');


--
-- Name: session_answers_p20260506; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers ATTACH PARTITION public.session_answers_p20260506 FOR VALUES FROM ('2026-05-06 00:00:00+00') TO ('2026-05-13 00:00:00+00');


--
-- Name: session_answers_p20260513; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers ATTACH PARTITION public.session_answers_p20260513 FOR VALUES FROM ('2026-05-13 00:00:00+00') TO ('2026-05-20 00:00:00+00');


--
-- Name: session_answers_p20260520; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers ATTACH PARTITION public.session_answers_p20260520 FOR VALUES FROM ('2026-05-20 00:00:00+00') TO ('2026-05-27 00:00:00+00');


--
-- Name: session_answers_p20260527; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers ATTACH PARTITION public.session_answers_p20260527 FOR VALUES FROM ('2026-05-27 00:00:00+00') TO ('2026-06-03 00:00:00+00');


--
-- Name: patches id; Type: DEFAULT; Schema: _v; Owner: postgres
--

ALTER TABLE ONLY _v.patches ALTER COLUMN id SET DEFAULT nextval('_v.patches_id_seq'::regclass);


--
-- Name: elo_history id; Type: DEFAULT; Schema: public; Owner: partman_user
--

ALTER TABLE ONLY public.elo_history ALTER COLUMN id SET DEFAULT nextval('public.elo_history_id_seq'::regclass);


--
-- Name: levels id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.levels ALTER COLUMN id SET DEFAULT nextval('public.levels_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: session_answers id; Type: DEFAULT; Schema: public; Owner: partman_user
--

ALTER TABLE ONLY public.session_answers ALTER COLUMN id SET DEFAULT nextval('public.session_answers_id_seq'::regclass);


--
-- Data for Name: patches; Type: TABLE DATA; Schema: _v; Owner: postgres
--

COPY _v.patches (id, patch_name, dependencies, description, applied_at) FROM stdin;
1	202605020000_patch_infrastructure	\N	Patch tracking infrastructure	2026-05-05 17:26:15.734213+00
2	202605020001_create_permissions	{202605020000_patch_infrastructure}	Create permissions table	2026-05-05 17:26:15.7527+00
3	202605020002_create_roles	{202605020000_patch_infrastructure}	Create roles table	2026-05-05 17:26:15.759062+00
4	202605020003_create_role_permissions	{202605020001_create_permissions,202605020002_create_roles}	Create role_permissions join table and seed	2026-05-05 17:26:15.765593+00
5	202605020004_create_players	{202605020002_create_roles}	Create players table	2026-05-05 17:26:15.771338+00
6	202605020005_create_levels	{202605020000_patch_infrastructure}	Create levels table	2026-05-05 17:26:15.782251+00
7	202605020006_create_classrooms	{202605020004_create_players}	Create classrooms table	2026-05-05 17:26:15.788812+00
8	202605020007_create_classroom_members	{202605020006_create_classrooms,202605020004_create_players}	Create classroom_members table	2026-05-05 17:26:15.796844+00
9	202605020008_create_game_sessions	{202605020004_create_players,202605020005_create_levels}	Create game_sessions table	2026-05-05 17:26:15.802807+00
10	202605020009_create_session_answers	{202605020008_create_game_sessions}	Create session_answers table	2026-05-05 17:26:15.810724+00
11	202605020010_create_elo_history	{202605020004_create_players,202605020008_create_game_sessions}	Create elo_history table	2026-05-05 17:26:15.816515+00
12	202605020011_create_pg_session	\N	Create connect-pg-simple session store table	2026-05-05 17:26:15.822235+00
13	202605020012_create_pg_partman	\N	Create partman schema and install pg_partman extension	2026-05-05 17:26:15.827936+00
14	202605020013_create_audit_events	{202605020012_create_pg_partman,202605020004_create_players}	Create audit schema and partitioned audit events table	2026-05-05 17:26:15.852634+00
22	202605060001_update_audit_events_http_method	{202605020013_create_audit_events}	Update audit schema to capture http method	2026-05-06 16:48:55.482679+00
25	202605070001_create_log_events	{202605020012_create_pg_partman,202605020013_create_audit_events}	Create log schema and partitioned log events table	2026-05-06 16:49:44.090388+00
26	202605070002_create_admin_indexes	{202605020004_create_players,202605020008_create_game_sessions}	Add indexes for admin pagination queries on players and game_sessions	2026-05-06 16:49:44.178885+00
28	202605070003_update_audit_partition_interval	{202605020013_create_audit_events}	Update audit partition interval from 1 month to 1 week	2026-05-06 17:11:41.810631+00
31	202605080001_partition_session_answers	{202605020009_create_session_answers,202605020012_create_pg_partman}	Recreate session_answers as weekly partitioned table	2026-05-06 17:12:38.600119+00
32	202605080002_partition_elo_history	{202605020010_create_elo_history,202605020012_create_pg_partman}	Recreate elo_history as weekly partitioned table	2026-05-06 17:12:38.6668+00
\.


--
-- Data for Name: audit_events_default; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.audit_events_default (id, user_id, url, status_code, ip_address, user_agent, metadata, created_at, http_method) FROM stdin;
\.


--
-- Data for Name: audit_events_p20260201; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.audit_events_p20260201 (id, user_id, url, status_code, ip_address, user_agent, metadata, created_at, http_method) FROM stdin;
\.


--
-- Data for Name: audit_events_p20260301; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.audit_events_p20260301 (id, user_id, url, status_code, ip_address, user_agent, metadata, created_at, http_method) FROM stdin;
\.


--
-- Data for Name: audit_events_p20260401; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.audit_events_p20260401 (id, user_id, url, status_code, ip_address, user_agent, metadata, created_at, http_method) FROM stdin;
\.


--
-- Data for Name: audit_events_p20260501; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.audit_events_p20260501 (id, user_id, url, status_code, ip_address, user_agent, metadata, created_at, http_method) FROM stdin;
d8f6703d-1717-4caf-aa47-200982c1fec8	\N	/health	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 17:26:31.331278+00	\N
a7e82d41-b84b-4202-a090-ea5767992d08	\N	/v1/auth/login	401	::1	PostmanRuntime/7.51.1	{"email": "demo@magicnugger.com"}	2026-05-05 17:26:55.516515+00	\N
2de2be0b-c7f5-4c7f-9f8d-a5ae615dfa67	\N	/v1/auth/register	201	::1	PostmanRuntime/7.51.1	\N	2026-05-05 17:26:59.290125+00	\N
7c94336f-e65f-4ad0-96a8-7cef4771a08b	\N	/v1/auth/register	409	::1	PostmanRuntime/7.51.1	{"email": "demo@magicnugger.com", "username": "demo"}	2026-05-05 17:27:01.754395+00	\N
c849bd5b-4f66-49cf-bc37-68cfa9103b70	\N	/v1/auth/login	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 17:27:04.563572+00	\N
8cfbaa56-f604-4c55-a0df-4eb969d17a33	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/me	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 17:27:08.966419+00	\N
dde3af46-1539-459a-b3f7-567b7b4c6eef	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/me	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 17:28:57.661737+00	\N
b3ca8472-959c-4fdc-90d1-9f9604d61f2f	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/internal/me	404	::1	PostmanRuntime/7.51.1	{}	2026-05-05 17:45:24.228119+00	\N
bb380f42-8d4b-43f6-9591-f45a81b38263	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/internal/cpu	404	::1	PostmanRuntime/7.51.1	{}	2026-05-05 17:45:30.741626+00	\N
0979683f-af22-4dd5-bf77-0ce398d26667	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/internal/cpu	404	::1	PostmanRuntime/7.51.1	{}	2026-05-05 17:45:39.702011+00	\N
3ebe2097-8dee-4924-b1d6-124afbf34d95	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/internal/cpu	404	::1	PostmanRuntime/7.51.1	{}	2026-05-05 17:47:22.347045+00	\N
3129b0c5-c2d0-4de7-a037-906792838963	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/internal/cpu	404	::1	PostmanRuntime/7.51.1	{}	2026-05-05 17:48:16.036359+00	\N
0eb9447d-6515-437c-8ca7-55cb3cf42c28	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/internal/cpu	404	::1	PostmanRuntime/7.51.1	{}	2026-05-05 17:48:17.588028+00	\N
f3431751-7e02-4cd3-b7bb-8eb6981eb7f9	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/internal/cpu	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 17:48:24.961232+00	\N
36199aa5-dd0b-4685-b9e0-59714bd3bb2a	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/internal/memory	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 17:48:33.961356+00	\N
56b90f7b-eafd-4fc6-8d25-64726debaddd	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/internal/cpu	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 17:50:07.645556+00	\N
a83c9953-3553-40c8-b905-031599d8763a	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/internal/cpu	404	::1	PostmanRuntime/7.51.1	{}	2026-05-05 17:50:26.679104+00	\N
6f0d82f0-7b69-4058-b4fe-d2dd5be81276	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/internal/memory	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 17:50:33.138563+00	\N
467c3799-a453-492e-922d-6b79a35d72ff	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/internal/memory	401	::1	PostmanRuntime/7.51.1	{}	2026-05-05 17:50:38.653308+00	\N
62e84bf6-7c3c-4e75-b46d-9dd167a69a3b	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/internal/memory	500	::1	PostmanRuntime/7.51.1	\N	2026-05-05 17:50:43.160733+00	\N
5908f2c1-d7ef-4363-9e88-ee56b736cab5	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/internal/memory	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 17:50:47.211528+00	\N
4b116f75-4466-4621-9728-2b575526c510	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/internal/memory	401	::1	PostmanRuntime/7.51.1	\N	2026-05-05 17:51:05.924908+00	\N
d044d005-9916-481a-a349-31883960b2ff	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/internal/memory	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 17:51:09.551617+00	\N
60b15c71-28b2-4700-bdb1-336bb777a971	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/players/1	404	::1	PostmanRuntime/7.51.1	\N	2026-05-05 17:56:52.326297+00	\N
d97a5ba7-bb64-4994-956c-79239e08d223	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/players/1	400	::1	PostmanRuntime/7.51.1	\N	2026-05-05 17:56:59.528986+00	\N
8f1a2644-e9b5-4c00-917b-46145b7a49c2	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/players/ac3f0987-3526-4544-9981-6c8c099ff629	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 17:57:17.128207+00	\N
c2119d13-9462-47c9-9a45-443a37d5d175	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/register	201	::1	PostmanRuntime/7.51.1	\N	2026-05-05 17:59:06.644709+00	\N
163afd00-7197-4d71-bdbc-567988134776	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/login	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 17:59:13.098844+00	\N
90013acf-3157-4c1b-8f4d-f45bba1db96b	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/logout	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 17:59:19.262048+00	\N
e998362b-bfee-4cc1-9d8c-5e7a1faa5240	\N	/v1/auth/login	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 17:59:28.263319+00	\N
3b8f0e72-8809-4918-ad3a-9c5e2b763226	7c6d3174-1ea0-4d2f-99fe-b4ea16e9ced0	/v1/auth/me	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 17:59:32.062515+00	\N
78005b65-6a27-4076-8494-bd5e72f74d2a	7c6d3174-1ea0-4d2f-99fe-b4ea16e9ced0	/v1/players/ac3f0987-3526-4544-9981-6c8c099ff629	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 17:59:36.035978+00	\N
32df8da6-7c74-465c-996b-e3d7eab2eeef	7c6d3174-1ea0-4d2f-99fe-b4ea16e9ced0	/v1/players/ac3f0987-3526-4544-9981-6c8c099ff629	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 17:59:37.545825+00	\N
eede61d2-e7d9-4944-95f9-88e5fc93da33	7c6d3174-1ea0-4d2f-99fe-b4ea16e9ced0	/v1/players/ac3f0987-3526-4544-9981-6c8c099ff629	400	::1	PostmanRuntime/7.51.1	\N	2026-05-05 18:00:06.544278+00	\N
30fdbd8b-0b32-48cb-98a0-512d2a2db110	7c6d3174-1ea0-4d2f-99fe-b4ea16e9ced0	/v1/auth/me	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 18:00:20.184825+00	\N
ffbbae8d-bd99-483d-aea5-fb8845fbd808	7c6d3174-1ea0-4d2f-99fe-b4ea16e9ced0	/v1/players/ac3f0987-3526-4544-9981-6c8c099ff629	403	::1	PostmanRuntime/7.51.1	{"display_name": "hello_world"}	2026-05-05 18:01:21.726392+00	\N
0f6e3810-62bb-4189-9707-d36aa0bf8868	7c6d3174-1ea0-4d2f-99fe-b4ea16e9ced0	/v1/auth/me	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 18:02:19.428325+00	\N
9db01d0b-92f2-4d94-a24e-c740b9f8fddc	7c6d3174-1ea0-4d2f-99fe-b4ea16e9ced0	/v1/players/7c6d3174-1ea0-4d2f-99fe-b4ea16e9ced0	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 18:02:41.473445+00	\N
10d9a6b6-fb20-4a29-9d7f-73f002e29873	7c6d3174-1ea0-4d2f-99fe-b4ea16e9ced0	/v1/players	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 18:04:32.387161+00	\N
dad3bbee-b649-40d2-9f16-7c2d909abbe7	7c6d3174-1ea0-4d2f-99fe-b4ea16e9ced0	/v1/players	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 18:04:36.899524+00	\N
b511fd18-ceaf-45d7-b72d-7ee1b8ecfa62	7c6d3174-1ea0-4d2f-99fe-b4ea16e9ced0	/v1/players/ac3f0987-3526-4544-9981-6c8c099ff629	404	::1	PostmanRuntime/7.51.1	{"display_name": "KRooK11"}	2026-05-05 18:07:37.972544+00	\N
df1b287c-337c-4b1c-b895-d987d2b4b637	7c6d3174-1ea0-4d2f-99fe-b4ea16e9ced0	/v1/players/ac3f0987-3526-4544-9981-6c8c099ff629	403	::1	PostmanRuntime/7.51.1	{"display_name": "KRooK11"}	2026-05-05 18:08:02.866085+00	\N
47a97800-4b63-47af-8639-19072a1f1f35	7c6d3174-1ea0-4d2f-99fe-b4ea16e9ced0	/v1/players/ac3f0987-3526-4544-9981-6c8c099ff629	403	::1	PostmanRuntime/7.51.1	{"display_name": "KRooK11"}	2026-05-05 18:08:06.772954+00	\N
29e2ceb4-c7eb-4847-b899-fddf3b46053e	7c6d3174-1ea0-4d2f-99fe-b4ea16e9ced0	/v1/auth/logout	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 18:08:11.088871+00	\N
b739ea46-9c0b-4851-a9c1-704068d9b43b	\N	/v1/auth/login	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 18:08:24.615595+00	\N
838741d8-d138-4360-b90e-09b58f7a260e	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/login	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 18:16:34.576965+00	\N
a27c0eab-f3c4-4056-943e-5c02736a0437	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/login	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 18:16:58.444796+00	\N
459cef05-bbc5-43fb-9211-ba137081d6af	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/login	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 18:16:59.391613+00	\N
f5c8f71f-02a4-4572-b9c4-494a152c06cc	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/me	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 18:17:12.103976+00	\N
eb96da23-8229-4682-af09-4961abdf9078	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/players	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 18:17:41.455709+00	\N
bffa9295-aa94-45e7-9d72-f96715080ad6	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/players/ac3f0987-3526-4544-9981-6c8c099ff629	403	::1	PostmanRuntime/7.51.1	{"display_name": "KRooK11"}	2026-05-05 18:17:44.07372+00	\N
2c8e9c90-4899-4d64-a1d2-0a6010d403ee	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/me	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 18:27:16.854539+00	\N
580897d9-0c22-45f7-8c38-39b14c5a9cae	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/me	200	::1	curl/8.6.0	\N	2026-05-05 18:31:10.478269+00	\N
8ba822d6-c2f3-469b-95b0-c1434771e9ab	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 18:56:20.270088+00	\N
f0312430-5269-4475-8bdb-eb0ba711695b	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/:id	400	::1	PostmanRuntime/7.51.1	\N	2026-05-05 18:57:02.289358+00	\N
8a2d2c1b-5051-4dc7-a2ff-9b920621c301	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/1	404	::1	PostmanRuntime/7.51.1	\N	2026-05-05 18:57:07.046106+00	\N
7f278579-e938-4b99-b519-57dd382a12a4	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/1	404	::1	PostmanRuntime/7.51.1	\N	2026-05-05 18:59:29.869494+00	\N
4879be6c-4f86-4f75-bc6d-25dc78838c87	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/	204	::1	PostmanRuntime/7.51.1	\N	2026-05-05 18:59:40.196307+00	\N
ec61dcb5-8afc-45fc-ada2-b21b53d778b1	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/:id	400	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:00:03.996147+00	\N
d2be7a9d-f9ab-4974-b31b-a8fcb5b21e2f	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/	204	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:00:07.903762+00	\N
ff18d4b2-f30f-4e05-803b-b237574154b8	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/	403	::1	PostmanRuntime/7.51.1	{"name": "Addition", "elo_min": 0, "description": "Practice addition!", "order_index": 1, "time_limit_seconds": 60}	2026-05-05 19:26:22.953159+00	\N
e6925422-ce5b-4107-ade4-03ad523184ed	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/logout	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:26:34.130455+00	\N
81e6cbfc-c3f1-433a-843d-08c10e7585b4	\N	/v1/auth/login	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:26:39.043263+00	\N
ab1fedc5-3098-48f9-ac8a-acb3b96d9d80	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/	403	::1	PostmanRuntime/7.51.1	{"name": "Addition", "elo_min": 0, "description": "Practice addition!", "order_index": 1, "time_limit_seconds": 60}	2026-05-05 19:26:50.38308+00	\N
a6921aab-cbac-4b57-9ee3-738a7e77b56d	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/	403	::1	PostmanRuntime/7.51.1	{"name": "Addition", "elo_min": 0, "description": "Practice addition!", "order_index": 1, "time_limit_seconds": 60}	2026-05-05 19:27:18.176599+00	\N
da8214f2-d184-4e09-afa9-2f05d1b57334	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/	201	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:27:25.463208+00	\N
69f4ed68-5aa6-48c2-a4c5-970da8b4c95f	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:27:31.156549+00	\N
c17867e6-c4dd-4262-b92d-bbf6a9107c46	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/1	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:27:37.519573+00	\N
a09b50db-3cff-4705-bc83-73b77d093a26	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/	409	::1	PostmanRuntime/7.51.1	{"name": "Substraction", "elo_min": 0, "max_score": 1000, "description": "Practice addition!", "order_index": 1, "elo_gain_correct": 15, "enemy_wave_config": {}, "elo_loss_incorrect": 5, "time_limit_seconds": 60, "question_gen_config": {}}	2026-05-05 19:28:01.739657+00	\N
979c1a36-2eda-4081-afa1-394a9a87157d	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/	201	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:28:07.673071+00	\N
cfac7138-1c19-4d52-9f52-36b4369510ef	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/1	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:28:51.704929+00	\N
e3c15cf0-fa4b-4917-a6a0-2c1df5df85e6	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/2	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:29:16.939562+00	\N
c6e28167-847c-4c74-9e64-15978a8e8f9c	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/3	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:30:37.190314+00	\N
a6626a51-9761-4316-94ad-e892b81eda35	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/2	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:31:18.272554+00	\N
438092fb-56d3-4d15-9701-a1164d23950b	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/2	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:31:26.881108+00	\N
24a8933d-b4d7-4a94-be1b-b5a10d5462ab	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/2	404	::1	PostmanRuntime/7.51.1	{"name": "Substraciton", "elo_min": 0, "description": "Practice substraction!", "order_index": 2, "time_limit_seconds": 60}	2026-05-05 19:31:33.929754+00	\N
ab7a3a48-1775-407e-8fe2-2f88dddf54f5	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/3	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:31:49.868712+00	\N
e8581604-b3b4-47c9-82e0-2f5289297df3	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/3	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:31:59.936006+00	\N
aed31516-50e2-4aba-8eef-57ac4110619e	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:32:05.100247+00	\N
65eac835-a978-45a4-b478-f7c63c22c77b	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/3	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:34:32.86384+00	\N
518e42c1-c63a-41f8-a377-a41a6592eb1c	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/3	204	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:36:31.152704+00	\N
49c5d715-2af8-4a68-82cc-cfabb73fc272	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/3	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:36:55.210132+00	\N
62faf768-8ee9-4d34-abd6-877f9c3731fe	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/3	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:37:19.64483+00	\N
8dc84a95-c591-4df1-8545-423f43b238de	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/3	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:37:21.412091+00	\N
da04802a-42a6-4983-b090-70a225732661	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/activate/:id	500	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:40:42.376801+00	\N
7f14478c-037d-47b7-9fbc-c40874e79ac7	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/activate/:id	500	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:41:20.520756+00	\N
7f5096d4-9b12-4dc3-a048-990ef648d683	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/activate/:id	400	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:41:31.439443+00	\N
f0c0b936-737e-4ad6-bebe-63b1597141f9	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/activate/:id	404	::1	PostmanRuntime/7.51.1	{"is_active": true}	2026-05-05 19:44:29.603993+00	\N
8859fb97-9bed-486f-a685-5cf2a7bfe1ef	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/active/:id	400	::1	PostmanRuntime/7.51.1	{"is_active": true}	2026-05-05 19:44:43.078996+00	\N
c70a846e-f825-4b76-97bc-c346698ddffd	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/active/:id	400	::1	PostmanRuntime/7.51.1	{"is_active": true}	2026-05-05 19:45:07.19677+00	\N
fdff870f-d383-4bcf-9ccb-91a8bccb5c0a	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/active/:id	400	::1	PostmanRuntime/7.51.1	{"is_active": true}	2026-05-05 19:45:47.80645+00	\N
4e82681a-24e4-4d91-a495-89450a4a98e5	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/active/:id	400	::1	PostmanRuntime/7.51.1	{"is_active": true}	2026-05-05 19:46:07.204736+00	\N
9dfcc2f3-9371-46c8-8902-d0468fc7bf5d	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/active/3	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:48:09.9751+00	\N
537ddb16-3167-48c0-94e6-ce1c1788f9e4	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/active/:id	400	::1	PostmanRuntime/7.51.1	{"is_active": true}	2026-05-05 19:48:48.890909+00	\N
f0e41e7d-948e-4046-ba1c-e8af605bdabd	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/active/3	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:48:52.944701+00	\N
c77bf67e-f04e-43fd-9d8c-77cc505836c7	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/active/:id	400	::1	PostmanRuntime/7.51.1	{"is_active": true}	2026-05-05 19:50:52.594826+00	\N
15a76a2c-ccb2-4a1b-be84-79138d1f2604	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/active/3	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 19:50:57.428055+00	\N
c366c706-239c-4493-a928-c3b0d3f3e221	\N	/v1/players/ac3f0987-3526-4544-9981-6c8c099ff629	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 20:23:46.056341+00	\N
881bdc7f-af13-46bb-a198-384637b7a83f	\N	/v1/players	401	::1	PostmanRuntime/7.51.1	{"display_name": "KRooK11"}	2026-05-05 20:23:49.761026+00	\N
c307da77-4a3d-4340-8df3-aa7187f37761	\N	/v1/players/ac3f0987-3526-4544-9981-6c8c099ff629	200	::1	PostmanRuntime/7.51.1	\N	2026-05-05 20:23:54.548207+00	\N
8a9a3983-6414-4da4-8a7a-02cf4eab0b72	\N	/v1/players/ac3f0987-3526-4544-9981-6c8c099ff629	401	::1	PostmanRuntime/7.51.1	{"display_name": "KRooK11"}	2026-05-05 20:23:58.871729+00	\N
495ff059-27f4-4f00-b417-9cf39a2a05bd	\N	/v1/players/ac3f0987-3526-4544-9981-6c8c099ff629	401	::1	PostmanRuntime/7.51.1	\N	2026-05-05 20:26:43.380381+00	\N
5a696cb2-2b46-402d-aa69-a7a68687ce61	\N	/v1/players/ac3f0987-3526-4544-9981-6c8c099ff629	401	::1	PostmanRuntime/7.51.1	\N	2026-05-06 06:57:03.924403+00	\N
ca5ace7a-1d10-4ec4-a415-9ab842b4eaa1	\N	/v1/auth/login	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 06:57:09.339698+00	\N
33b01ba9-e547-41f6-8a1f-5af43cc71bb5	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/players	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 06:57:23.404929+00	\N
3f20b1b2-c4d3-4729-be64-78953b890c79	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/me	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 06:57:30.862875+00	\N
7859a43b-a9a9-41c0-b33f-fe67a8d18c1e	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 06:57:36.246146+00	\N
6397ed62-15a5-4464-9def-07d9eefaf153	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/register	400	::1	PostmanRuntime/7.51.1	\N	2026-05-06 07:11:16.300518+00	\N
51f41464-6dfd-400d-8713-a2aa9732b8ac	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/register	400	::1	PostmanRuntime/7.51.1	\N	2026-05-06 07:16:02.480089+00	\N
b8ce7248-7aab-4b51-9236-c3ba34f4d983	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/register	400	::1	PostmanRuntime/7.51.1	\N	2026-05-06 07:19:16.293115+00	\N
432cf1ac-ab7c-4f45-a663-4c647623fba8	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/register	400	::1	PostmanRuntime/7.51.1	\N	2026-05-06 07:28:27.457153+00	\N
491edac3-cb82-46ed-8aa7-85792645206a	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/register	400	::1	PostmanRuntime/7.51.1	\N	2026-05-06 07:34:26.842751+00	\N
53a8c5e7-b4bc-4207-93cc-df4b44a9f732	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/register	400	::1	PostmanRuntime/7.51.1	\N	2026-05-06 07:36:52.33292+00	\N
03d0e153-c82e-4f3a-9f65-002a0ab25706	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/login	400	::1	PostmanRuntime/7.51.1	\N	2026-05-06 07:38:44.087176+00	\N
4fa31ac6-bc96-4c6a-8730-59dfefef7425	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/register	201	::1	PostmanRuntime/7.51.1	\N	2026-05-06 07:39:30.758623+00	\N
62498822-d41e-4798-a05f-798638989a05	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/internal/cpu	401	::1	PostmanRuntime/7.51.1	\N	2026-05-06 07:39:51.885144+00	\N
f9432c8e-c838-4694-a300-bb2bccef2cac	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/players	400	::1	PostmanRuntime/7.51.1	\N	2026-05-06 07:40:12.375339+00	\N
2c6b65c2-413b-4396-9680-b87e24026ef2	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/players	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 07:40:54.230075+00	\N
c179cdfc-bb6d-4af0-8775-2b5fe467ee82	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/players/ac3f0987-3526-4544-9981-6c8c099ff629	400	::1	PostmanRuntime/7.51.1	\N	2026-05-06 07:41:02.646437+00	\N
8ae0bdbc-6ee4-465b-a01c-ae1349ed272b	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/active/3	400	::1	PostmanRuntime/7.51.1	\N	2026-05-06 07:41:22.839995+00	\N
dd341423-2196-4a57-8337-73bc0cc182ff	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/	400	::1	PostmanRuntime/7.51.1	\N	2026-05-06 07:41:58.801382+00	\N
ee04a3c4-c46f-479a-b8e2-f777603d8f29	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/3	400	::1	PostmanRuntime/7.51.1	\N	2026-05-06 07:42:16.432865+00	\N
dc5fd729-b7df-4e5d-b0f2-5228f7e11cce	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/3	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 08:43:30.903563+00	\N
d0a3ee9a-4217-4672-b42e-a5930d3c5a6d	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game-sessions/	400	::1	PostmanRuntime/7.51.1	\N	2026-05-06 09:45:12.612713+00	\N
c6b47d28-1baa-46dc-8ad3-8e872668666a	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game-sessions/	400	::1	PostmanRuntime/7.51.1	{"level_id": 2}	2026-05-06 09:46:14.682007+00	\N
ceb994d8-b9f8-4c0b-820b-316de20d3fcc	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game-sessions/	404	::1	PostmanRuntime/7.51.1	{"level_id": 2}	2026-05-06 09:47:42.297805+00	\N
e7abd72f-2365-492e-8f2b-ed0806c18333	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game-sessions/	404	::1	PostmanRuntime/7.51.1	{"level_id": 2}	2026-05-06 09:50:20.435605+00	\N
65438bed-329c-417d-bdfa-04cabad2ce0e	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game-sessions/	404	::1	PostmanRuntime/7.51.1	{"level_id": 2}	2026-05-06 09:51:31.152416+00	\N
e4b09b81-2225-4d8a-aa72-ab92e5426d11	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game-sessions/	404	::1	PostmanRuntime/7.51.1	{"level_id": 2}	2026-05-06 09:51:37.952434+00	\N
310cdf58-7ee4-4aeb-a28a-cdece279bc1c	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game-sessions/	201	::1	PostmanRuntime/7.51.1	\N	2026-05-06 09:51:45.85311+00	\N
07239dec-8e14-4bcc-bcb5-39a9c23a0bf7	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game-sessions/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 09:52:58.238704+00	\N
4591c19f-4548-4acf-9a10-266c04d9e884	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game-sessions/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 09:53:00.929788+00	\N
dfc4c85c-c46d-4a3b-bf00-5a7fe7669727	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game-sessions/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 09:53:28.424298+00	\N
8a7fc644-1a93-407b-9b70-0c546acd1203	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game-sessions/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 09:53:38.919288+00	\N
0089345a-9abb-46c7-91b3-ee4a15356d78	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game-sessions/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 09:53:44.973982+00	\N
7ebe923e-f84a-4dba-ba01-8f9fe886ab62	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game-sessions/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 09:53:48.164798+00	\N
d58ffc1d-22b8-4eb7-8565-c0f53d8382d0	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game-sessions/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 09:58:00.303247+00	\N
6883d23a-1187-4f4e-a9fc-c56c388bfa25	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game-sessions/	201	::1	PostmanRuntime/7.51.1	\N	2026-05-06 09:58:23.33561+00	\N
99b076ab-2e6e-4646-b43c-fb8265201b63	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game-sessions/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 09:59:46.775635+00	\N
ff42e16c-2085-46a5-b2f4-4351632aeca2	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game-sessions/	201	::1	PostmanRuntime/7.51.1	\N	2026-05-06 10:00:15.672239+00	\N
18251e89-27c2-4a38-b299-0ca1558ca2aa	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game-sessions/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 10:01:05.189142+00	\N
af56dbdf-a922-4f6b-924e-c33091d42e97	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game-sessions/	201	::1	PostmanRuntime/7.51.1	\N	2026-05-06 10:01:22.107817+00	\N
55097f04-a115-4059-a9b2-605619b5ac73	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/login	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 10:44:19.46901+00	\N
466d517f-315a-4dc3-b55b-41ab279d67ed	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/me	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 10:44:25.842921+00	\N
a9566ac7-67f4-4748-a0c3-b9ad3913e737	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/register	409	::1	PostmanRuntime/7.51.1	{"email": "demo@magicnugger.com", "username": "demo"}	2026-05-06 10:44:43.486832+00	\N
449a5f7a-2df7-4623-9810-449f0a0e499f	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/register	409	::1	PostmanRuntime/7.51.1	{"email": "demo@magicnugger.com", "password": "<REDACTED>", "username": "demo"}	2026-05-06 10:45:11.078224+00	\N
ce787a54-e1f0-4106-a511-3d22da67ba59	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/	404	::1	PostmanRuntime/7.51.1	\N	2026-05-06 13:22:27.501398+00	\N
c9d7845b-b1cc-4420-b598-9206931f516b	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/	404	::1	PostmanRuntime/7.51.1	\N	2026-05-06 13:22:40.639041+00	\N
2909ae91-e875-4f07-959b-3ede27565289	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/	400	::1	PostmanRuntime/7.51.1	\N	2026-05-06 13:23:27.494927+00	\N
08f8cd45-1a3a-44a2-b09c-64c02e428909	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/	404	::1	PostmanRuntime/7.51.1	{"level_id": 2}	2026-05-06 13:23:33.027659+00	\N
ac36fe92-5ff7-43c9-85b8-542d96ef2b70	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/	201	::1	PostmanRuntime/7.51.1	\N	2026-05-06 13:23:38.621112+00	\N
8bd1fa46-73c5-43ef-a43d-ed11c4dc6375	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 13:23:42.916735+00	\N
30e8c09d-ead4-4ef2-9971-3e88f17a4f7c	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 13:23:50.345658+00	\N
32cc9074-5643-4df0-962e-8fa8910592c7	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 13:23:53.353471+00	\N
d33f0ad3-0b74-4b68-9f86-4642dd5e70d3	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 13:23:55.394486+00	\N
aac47a04-d7e5-4f37-9c54-d7e31fce1622	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 13:23:59.817106+00	\N
caad7e41-456d-4f2c-bd18-0f79fdce8639	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 13:24:03.635823+00	\N
6a3149d8-1a9f-4ec3-9386-413faf6f6f21	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 13:24:05.930484+00	\N
03cf89a8-0369-485d-8cd0-804c7533c5cc	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 13:24:08.210105+00	\N
cb253598-1bd7-491e-a542-dcf52789bb5f	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/	201	::1	PostmanRuntime/7.51.1	\N	2026-05-06 13:24:11.948151+00	\N
da52f269-f2b4-40a0-8cb2-4c44359c9513	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 13:27:22.601613+00	\N
daa1b2e5-c192-406b-bf2b-2e2da3c3968e	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/register	201	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:15:55.212475+00	\N
3e5022ac-a3d8-41bc-8440-7d03c5336c2d	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/login	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:16:05.928208+00	\N
60e859f7-f3da-4775-a24a-1517c2c4f302	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/auth/login	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:16:07.977049+00	\N
ccd9afd2-a50b-471f-abcf-8211fa981d2a	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/auth/logout	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:16:11.623867+00	\N
e5db6ab4-a0b8-4615-8d99-b8c67c390f6c	\N	/v1/auth/me	401	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:16:15.949799+00	\N
937ef67b-40a2-42be-bd74-b00507f61cd9	\N	/v1/auth/login	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:16:19.609943+00	\N
aa18ab9e-f406-409b-bfb9-54b1a394ad37	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/auth/me	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:16:22.769893+00	\N
2b5e00cc-42cb-4817-b8ff-a63404e2bb2a	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/internal/cpu	404	::1	PostmanRuntime/7.51.1	{"secret": "<REDACTED>"}	2026-05-06 14:16:26.991995+00	\N
33bd4750-a397-487e-9af4-a450058d1815	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/internal/memory	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:16:38.132886+00	\N
4d0030fb-102e-4bba-b6b1-26aa1eb8ba22	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/players/ac3f0987-3526-4544-9981-6c8c099ff629	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:16:43.670783+00	\N
f3611eb7-1726-49c3-b1d0-a834c213cc3a	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/players	409	::1	PostmanRuntime/7.51.1	{"username": "alden", "display_name": "Christopher Alden"}	2026-05-06 14:16:59.656561+00	\N
cb10c33a-ab07-4311-9a81-57ede374175d	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/players	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:17:27.654827+00	\N
2dba6868-3e30-4cb1-8b30-2a0863c432a1	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/players/ac3f0987-3526-4544-9981-6c8c099ff629	403	::1	PostmanRuntime/7.51.1	{}	2026-05-06 14:17:42.267879+00	\N
54883d87-4416-4843-b510-0535b738c21c	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/levels/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:17:52.382762+00	\N
a68ae28b-27e1-4610-b66f-6120169daa48	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/levels/1	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:17:58.489568+00	\N
ba377e18-fed5-4c38-80a6-d62f21a9903d	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/levels/1	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:18:08.655717+00	\N
55b46888-48e6-4005-b51d-4bf56956fa6e	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/levels/1	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:23:47.241772+00	\N
2d6d886c-0096-4485-ab78-60f3a3edc282	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/levels/1	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:23:56.627916+00	\N
b9f750c6-a162-4168-b705-9ee3cf3546d7	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/levels/1	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:24:08.598787+00	\N
a69004cc-f350-4224-8a2a-6e980a526788	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/levels/1	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:24:21.365606+00	\N
5e080943-d512-46d5-b481-48cea62a4eb1	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/levels/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:24:28.644952+00	\N
f5eb8f12-96ea-4934-9d14-e9a861d92ef3	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/levels/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:24:41.152507+00	\N
acc07751-9f85-4246-8b68-59e8fb6b2609	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/levels/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:25:16.831564+00	\N
bb2cd379-af21-42c3-ade7-470ccfe3cd86	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/game/	201	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:32:42.876611+00	\N
a58b033d-225d-4677-a728-54b23daaacab	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/game/answer	404	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:34:13.380297+00	\N
c1414a5f-b91e-4875-ac45-178b056726d4	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/game/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:34:42.266902+00	\N
4e117cf1-4a63-42fe-931f-02439188ddf0	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/game/5441a8ff-8947-4483-bfe1-0cd2bac57bfc/answer	400	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:34:56.306367+00	\N
c8a5d277-7a3a-402b-880e-86d3535b24cb	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/game/5441a8ff-8947-4483-bfe1-0cd2bac57bfc/answer	409	::1	PostmanRuntime/7.51.1	{"is_correct": true, "time_taken_ms": 3000}	2026-05-06 14:35:32.568326+00	\N
42d9d1de-ffb4-4051-9a10-1387ef8b4ee3	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/game/5441a8ff-8947-4483-bfe1-0cd2bac57bfc/answer	400	::1	PostmanRuntime/7.51.1	{"is_correct": true, "time_taken_ms": 3000}	2026-05-06 14:37:31.698981+00	\N
7fca986e-b519-46f5-a098-3aa1983b15ed	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/game/5441a8ff-8947-4483-bfe1-0cd2bac57bfc/answer	304	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:38:43.628382+00	\N
2b23551a-34e1-4c45-9c4e-756c75e2efd2	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/game/5441a8ff-8947-4483-bfe1-0cd2bac57bfc/answer	304	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:38:46.946729+00	\N
7dbb2e29-4d57-49f4-b7dd-22012390077a	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/game/5441a8ff-8947-4483-bfe1-0cd2bac57bfc/answer	304	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:38:47.735315+00	\N
a60132d8-9259-4698-a0f5-ab289798b985	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/game/5441a8ff-8947-4483-bfe1-0cd2bac57bfc/answer	304	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:38:48.659273+00	\N
48f956c8-3c09-4484-89c9-e08a6d0d5990	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/auth/me	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:39:24.279663+00	\N
21fcc14c-2284-41d4-832b-29e1c96a1841	593dc93e-c4d3-4b0c-af64-da9cbca61910	/v1/auth/login	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:39:34.679699+00	\N
2ff54993-9021-443e-9415-2cc19f12cd9e	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/me	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:39:38.934181+00	\N
9e4da93b-036f-44a1-9264-5b775c549750	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/3	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:42:10.396451+00	\N
2f3752c9-e3ed-4f65-aab5-713e9ea5a055	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/:id	400	::1	PostmanRuntime/7.51.1	{}	2026-05-06 14:42:18.366039+00	\N
b8c75edd-d24d-464a-ad47-a8f2f753ded1	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/1	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:42:34.466971+00	\N
fdc1f104-c497-4dbf-9da5-f169330e78ce	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/	400	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:42:58.725952+00	\N
577be219-ebde-425b-bf99-0ecdacb5c5e3	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/	400	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:43:29.417911+00	\N
feb30465-9271-448d-bf92-0b2321d86b41	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/	400	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:52:12.597563+00	\N
1ae32224-1391-4deb-a763-50c68b6522ae	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/	400	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:52:37.450148+00	\N
bcbe7c89-a2a3-4a06-861d-cc7535544989	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/1	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:53:00.623617+00	\N
e454c474-64d3-4fcf-9e5f-e5d21bd5567c	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/1	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:55:25.185645+00	\N
538042a0-e705-403d-88e1-3f44332ebe23	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:55:33.425637+00	\N
0af99282-98ae-4a20-88e7-4073e72230b2	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/3	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:55:54.855635+00	\N
3f522b6d-c356-497b-a634-bf995f02fb45	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/	201	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:56:31.088758+00	\N
12036171-ff06-4a65-9837-f7026dcce399	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/5441a8ff-8947-4483-bfe1-0cd2bac57bfc/answer	304	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:56:37.112314+00	\N
504f0aee-6432-4cf7-8488-1f7f1e854e6d	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:57:44.102204+00	\N
fb115766-4b8a-49d3-b6d4-ccfc00ad7455	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:57:48.145866+00	\N
cf3c490f-cfad-42e9-9b01-daf8335db8d0	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:57:49.06848+00	\N
e4db7e1c-24b2-44f8-9059-40dce2215c08	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:57:49.929922+00	\N
f2fc8f78-3fc1-4580-a464-2724457e3867	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:57:50.731141+00	\N
2152f2cf-5e52-441c-a074-cba707dddf60	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:57:51.410124+00	\N
250e410c-9c7d-4044-9c29-85e0c60e3c50	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:57:52.335424+00	\N
936cb0a5-c269-436f-8b38-398e3f3b41ac	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:57:53.16258+00	\N
6702777a-303c-46a0-965e-be16afe57e18	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:57:53.912185+00	\N
89737e68-a252-4f2e-b682-7f98ef8014d0	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:57:54.703968+00	\N
a56dbd3e-54da-40ea-a77e-080da50964ad	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:57:55.420623+00	\N
b3f57d92-5005-49e0-9cd9-6fd9752321a1	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:57:56.053758+00	\N
78e185a7-08a1-4b1f-9d23-b404296bffd0	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:57:56.795017+00	\N
a12cf449-d025-449e-9b71-7094600fc26d	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:57:57.392459+00	\N
e5334d0c-50e2-4712-9b19-7f0a2205e4e6	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:57:58.19155+00	\N
1bd5abbe-b26a-4575-ac12-72113f844458	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:57:58.588778+00	\N
e004b698-b43c-45b2-af2d-40cfcc3d5a4c	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:57:59.225004+00	\N
0b81532c-1c9b-4a1d-87f5-37bd8f03a2bb	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:57:59.889125+00	\N
4b595bba-b4bb-4d3c-86c3-279eac512dad	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:58:00.585264+00	\N
5ab970a6-e7c0-422b-a794-68f100a47007	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:58:01.262069+00	\N
69055f2b-012c-4a01-b949-86769ae75164	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:58:11.568267+00	\N
2a0c22b0-1349-47bb-b2c1-ba8040b34bb1	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:58:16.423995+00	\N
51ae5006-aaf9-4ecd-94f3-255a93b2b768	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 14:58:18.746558+00	\N
a876b49f-9601-4cb2-83b3-280bde130c63	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 15:04:39.123735+00	\N
ba01c910-c059-43f9-abd3-0a3be3204190	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 15:04:39.993141+00	\N
ed64818c-d4c5-446e-91e7-b86a8645ec0b	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 15:04:41.106331+00	\N
501ca70d-48be-4b21-b9f5-9cdbc90e54b8	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 15:04:41.951624+00	\N
4ed3a5be-f812-4553-bfd2-b20ed42000f4	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 15:04:42.591382+00	\N
00b966d9-126c-4aea-8756-de6c3b3737d0	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 15:04:43.354763+00	\N
dc63e9ad-bfd4-4b4e-a486-a5a15dafb42b	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/answer	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 15:04:44.024198+00	\N
53c1e4d5-2baf-40e7-9969-af8ccb9fbe48	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/end	500	::1	PostmanRuntime/7.51.1	\N	2026-05-06 15:09:17.503082+00	\N
81b40e63-b1c1-43f5-8c21-0ebcb3da2983	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f/end	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 15:14:17.555228+00	\N
cf85b22d-4b95-4b7d-ad50-47f0bc4a8388	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/	201	::1	PostmanRuntime/7.51.1	\N	2026-05-06 15:14:37.948432+00	\N
69d62b0d-623d-4ba0-9338-9ad21af871aa	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/a86d5fcd-1e7c-44c7-bbda-d0665f5f24e/fail	400	::1	PostmanRuntime/7.51.1	\N	2026-05-06 15:14:48.040415+00	\N
2ad88da2-d63d-4d70-9b6c-8f46a9e57bc6	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/a86d5fcd-1e7c-44c7-bbda-d0665f5f24e1/fail	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 15:15:09.13478+00	\N
428c58fc-8662-4c01-b82c-7371974636bf	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/	201	::1	PostmanRuntime/7.51.1	\N	2026-05-06 15:15:15.262743+00	\N
cbc72de7-333e-4569-861c-c82cecbb1d23	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/a551da92-3050-4f40-a230-c1d834df97b2/abandon	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 15:15:39.326844+00	\N
6ac2a56b-48f7-4c2c-a421-de3184866d75	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions/active	404	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:01:52.258738+00	\N
0788f222-3185-471b-9f05-49cea1dd3471	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions/active	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:02:12.074404+00	\N
58a023e8-d2f0-40a2-9ed6-bc7c056bfaaa	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/me	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:02:38.84569+00	\N
986a9880-ba78-430e-8ee8-52ec98a00c79	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/players/ac3f0987-3526-4544-9981-6c8c099ff629	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:02:54.23587+00	\N
20762f50-1ecf-4eff-93cc-9ee6abb8fe61	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions/active	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:04:02.380189+00	\N
ca657aab-8789-4e2b-97dd-b7ffd3228f77	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/auth/me	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:04:36.099667+00	\N
bc9e509d-5b19-4a2e-bf23-f29bb17ba432	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions/active	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:04:42.128207+00	\N
5192934f-1a31-40ae-87ce-505a8c41f335	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions	400	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:06:29.648288+00	\N
0a948c16-acf0-4358-85da-2c14aea7d4cc	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:06:40.572141+00	\N
25aef488-0869-4c22-864f-47159f420af7	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:06:52.798806+00	\N
6431f380-5d69-4eb6-9840-85ce38fa5da0	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:06:56.347979+00	\N
7a210cf5-5979-453b-9ba6-68fab2e29839	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:06:58.844568+00	\N
dcf12768-6232-4a29-ac4a-aefb2152cc2d	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:07:04.95517+00	\N
1e3b1ce0-5e7e-4976-93d0-e045a3e6dce5	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/levels/	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:07:10.086599+00	\N
9e38b453-1691-4cda-bd38-b06d0a9f4503	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:07:18.708364+00	\N
d30b1528-c58e-42c0-b6ec-669366838e14	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:07:28.749046+00	\N
6357d6d9-0348-4a14-990f-9c1746a616b5	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/stats	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:08:01.470003+00	\N
5eb3f186-e0ec-492f-959d-6dd8679f1c63	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/players	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:09:00.985718+00	\N
c82eb482-2162-498b-90d0-a7e7b95d005e	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:10:16.398801+00	\N
a713fcdc-7465-44fe-be14-995db0f5f98d	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:10:21.159943+00	\N
36f3379f-9540-4b65-843c-33ec719cc146	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:10:31.618503+00	\N
54165312-bc7e-49fc-b7e2-7a2c32c06efd	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:18:57.617959+00	\N
fbf1b02b-a2b2-43f4-a810-79ea594f2dbd	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:19:15.286692+00	\N
7e9ed828-889b-4142-8ccb-0bdb05e49cc6	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:19:21.854198+00	\N
fa06e902-6619-45a8-9000-81866d007eef	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:19:26.697765+00	\N
ffe993e6-53f0-45f2-9dab-b53d8140b255	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:19:42.726204+00	\N
4ba7ffbc-78e9-4f1e-bff1-9374e9529928	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:19:46.047855+00	\N
315a47ea-8233-427f-8cc3-00052063d09e	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:19:55.227309+00	\N
ba0c3217-ae45-4cd5-9ff8-1861923256c6	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:20:01.063259+00	\N
6826e5ee-60ea-449d-b76f-f6d75b6ac0a2	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:20:11.487225+00	\N
2a1b0497-650b-40d5-b147-4d7d5fb7c89d	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:20:14.990698+00	\N
efe53eb6-878d-4259-96ea-dac0c127d970	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/game-sessions	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:20:28.343099+00	\N
564bce4a-fea5-47fb-8792-a48fd0cb443d	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/players	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:21:05.417415+00	\N
e4ff9006-04c8-4912-a91a-f3168399f99c	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/players	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:21:10.702046+00	\N
29cb279f-8e5b-4d19-ae00-3e32a90a15f7	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/players	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:21:21.750205+00	\N
aab96b1b-8b5d-48f7-b94b-58e004f35903	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/players	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:21:25.471299+00	\N
c2ef861b-3a78-4556-88b3-f5d477ace7b8	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/players	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:21:32.136823+00	\N
2c285742-78f7-42e3-a0b0-4be94a289658	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/admin/players	200	::1	PostmanRuntime/7.51.1	\N	2026-05-06 16:21:38.217703+00	\N
35daea5a-e2b2-4d25-846f-2dec180a6ba6	ac3f0987-3526-4544-9981-6c8c099ff629	/v1/game/	201	::1	PostmanRuntime/7.51.1	\N	2026-05-06 17:44:20.302885+00	POST
\.


--
-- Data for Name: audit_events_p20260601; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.audit_events_p20260601 (id, user_id, url, status_code, ip_address, user_agent, metadata, created_at, http_method) FROM stdin;
\.


--
-- Data for Name: audit_events_p20260701; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.audit_events_p20260701 (id, user_id, url, status_code, ip_address, user_agent, metadata, created_at, http_method) FROM stdin;
\.


--
-- Data for Name: audit_events_p20260801; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.audit_events_p20260801 (id, user_id, url, status_code, ip_address, user_agent, metadata, created_at, http_method) FROM stdin;
\.


--
-- Data for Name: log_events_default; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.log_events_default (id, user_id, event, level, metadata, created_at) FROM stdin;
\.


--
-- Data for Name: log_events_p20260201; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.log_events_p20260201 (id, user_id, event, level, metadata, created_at) FROM stdin;
\.


--
-- Data for Name: log_events_p20260301; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.log_events_p20260301 (id, user_id, event, level, metadata, created_at) FROM stdin;
\.


--
-- Data for Name: log_events_p20260401; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.log_events_p20260401 (id, user_id, event, level, metadata, created_at) FROM stdin;
\.


--
-- Data for Name: log_events_p20260501; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.log_events_p20260501 (id, user_id, event, level, metadata, created_at) FROM stdin;
7a739642-2088-4bfb-a6ea-96849b533565	\N	cron:session-cleanup	info	{"count": 1, "duration_ms": 5}	2026-05-06 17:43:09.864253+00
c5740c75-9214-43c9-b01b-04569de9fb0b	\N	cron:session-cleanup	info	{"count": 0, "duration_ms": 3}	2026-05-06 17:44:32.537391+00
c3e18086-c431-4e03-bcc8-1ea85604ee7a	\N	cron:session-cleanup	info	{"count": 0, "duration_ms": 4}	2026-05-06 17:50:08.078365+00
\.


--
-- Data for Name: log_events_p20260601; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.log_events_p20260601 (id, user_id, event, level, metadata, created_at) FROM stdin;
\.


--
-- Data for Name: log_events_p20260701; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.log_events_p20260701 (id, user_id, event, level, metadata, created_at) FROM stdin;
\.


--
-- Data for Name: log_events_p20260801; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.log_events_p20260801 (id, user_id, event, level, metadata, created_at) FROM stdin;
\.


--
-- Data for Name: part_config; Type: TABLE DATA; Schema: partman; Owner: postgres
--

COPY partman.part_config (parent_table, control, time_encoder, time_decoder, partition_interval, partition_type, premake, automatic_maintenance, template_table, retention, retention_schema, retention_keep_index, retention_keep_table, epoch, constraint_cols, optimize_constraint, infinite_time_partitions, datetime_string, jobmon, sub_partition_set_full, undo_in_progress, inherit_privileges, constraint_valid, ignore_default_data, date_trunc_interval, maintenance_order, retention_keep_publication, maintenance_last_run, async_partitioning_in_progress) FROM stdin;
audit.audit_events	created_at	\N	\N	1 week	range	3	on	partman.template_audit_audit_events	\N	\N	t	t	none	\N	30	f	YYYYMMDD	t	f	f	f	t	t	\N	\N	f	2026-05-06 17:11:41.837126+00	\N
audit.log_events	created_at	\N	\N	1 week	range	3	on	partman.template_audit_log_events	\N	\N	t	t	none	\N	30	f	YYYYMMDD	t	f	f	f	t	t	\N	\N	f	2026-05-06 17:11:41.844524+00	\N
public.session_answers	answered_at	\N	\N	7 days	range	3	on	partman.template_public_session_answers	\N	\N	t	t	none	\N	30	f	YYYYMMDD	t	f	f	f	t	t	\N	\N	f	\N	\N
public.elo_history	created_at	\N	\N	7 days	range	3	on	partman.template_public_elo_history	\N	\N	t	t	none	\N	30	f	YYYYMMDD	t	f	f	f	t	t	\N	\N	f	\N	\N
\.


--
-- Data for Name: part_config_sub; Type: TABLE DATA; Schema: partman; Owner: postgres
--

COPY partman.part_config_sub (sub_parent, sub_control, sub_time_encoder, sub_time_decoder, sub_partition_interval, sub_partition_type, sub_premake, sub_automatic_maintenance, sub_template_table, sub_retention, sub_retention_schema, sub_retention_keep_index, sub_retention_keep_table, sub_epoch, sub_constraint_cols, sub_optimize_constraint, sub_infinite_time_partitions, sub_jobmon, sub_inherit_privileges, sub_constraint_valid, sub_ignore_default_data, sub_default_table, sub_date_trunc_interval, sub_maintenance_order, sub_retention_keep_publication, sub_control_not_null) FROM stdin;
\.


--
-- Data for Name: template_audit_audit_events; Type: TABLE DATA; Schema: partman; Owner: partman_user
--

COPY partman.template_audit_audit_events (id, user_id, url, status_code, ip_address, user_agent, metadata, created_at, http_method) FROM stdin;
\.


--
-- Data for Name: template_audit_log_events; Type: TABLE DATA; Schema: partman; Owner: partman_user
--

COPY partman.template_audit_log_events (id, user_id, event, level, metadata, created_at) FROM stdin;
\.


--
-- Data for Name: template_public_elo_history; Type: TABLE DATA; Schema: partman; Owner: partman_user
--

COPY partman.template_public_elo_history (id, player_id, session_id, elo_before, elo_after, delta, reason, created_at) FROM stdin;
\.


--
-- Data for Name: template_public_session_answers; Type: TABLE DATA; Schema: partman; Owner: partman_user
--

COPY partman.template_public_session_answers (id, session_id, is_correct, elo_delta, time_taken_ms, answered_at) FROM stdin;
\.


--
-- Data for Name: classroom_members; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.classroom_members (classroom_id, player_id, classroom_elo, joined_at) FROM stdin;
\.


--
-- Data for Name: classrooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.classrooms (id, name, description, teacher_id, visibility, starting_elo, elo_cap, invite_code, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: elo_history_default; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.elo_history_default (id, player_id, session_id, elo_before, elo_after, delta, reason, created_at) FROM stdin;
\.


--
-- Data for Name: elo_history_p20260415; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.elo_history_p20260415 (id, player_id, session_id, elo_before, elo_after, delta, reason, created_at) FROM stdin;
\.


--
-- Data for Name: elo_history_p20260422; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.elo_history_p20260422 (id, player_id, session_id, elo_before, elo_after, delta, reason, created_at) FROM stdin;
\.


--
-- Data for Name: elo_history_p20260429; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.elo_history_p20260429 (id, player_id, session_id, elo_before, elo_after, delta, reason, created_at) FROM stdin;
\.


--
-- Data for Name: elo_history_p20260506; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.elo_history_p20260506 (id, player_id, session_id, elo_before, elo_after, delta, reason, created_at) FROM stdin;
1	ac3f0987-3526-4544-9981-6c8c099ff629	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	0	250	250	session_completed	2026-05-06 15:14:17.506999+00
2	ac3f0987-3526-4544-9981-6c8c099ff629	a86d5fcd-1e7c-44c7-bbda-d0665f5f24e1	250	250	0	session_failed	2026-05-06 15:15:09.11761+00
\.


--
-- Data for Name: elo_history_p20260513; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.elo_history_p20260513 (id, player_id, session_id, elo_before, elo_after, delta, reason, created_at) FROM stdin;
\.


--
-- Data for Name: elo_history_p20260520; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.elo_history_p20260520 (id, player_id, session_id, elo_before, elo_after, delta, reason, created_at) FROM stdin;
\.


--
-- Data for Name: elo_history_p20260527; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.elo_history_p20260527 (id, player_id, session_id, elo_before, elo_after, delta, reason, created_at) FROM stdin;
\.


--
-- Data for Name: game_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.game_sessions (id, player_id, level_id, status, score, max_answers, elo_before, elo_after, elo_delta, correct_count, incorrect_count, max_streak, current_streak, started_at, ended_at, client_ip, user_agent) FROM stdin;
cfefd8c9-684f-4b1a-8728-e72218c054f9	ac3f0987-3526-4544-9981-6c8c099ff629	3	abandoned	0	0	0	\N	\N	0	0	0	0	2026-05-06 10:01:22.100686+00	2026-05-06 13:23:38.60603+00	::1	PostmanRuntime/7.51.1
9d145ea3-60d1-431e-8e95-18528075e4a2	ac3f0987-3526-4544-9981-6c8c099ff629	3	abandoned	0	0	0	\N	\N	0	0	0	0	2026-05-06 13:23:38.60603+00	2026-05-06 13:24:11.931697+00	::1	PostmanRuntime/7.51.1
656a21cd-e64e-4715-9881-6364d15997b5	ac3f0987-3526-4544-9981-6c8c099ff629	3	abandoned	0	0	0	\N	\N	0	0	0	0	2026-05-06 13:24:11.931697+00	2026-05-06 14:56:31.07605+00	::1	PostmanRuntime/7.51.1
bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	ac3f0987-3526-4544-9981-6c8c099ff629	3	completed	265	50	0	250	250	20	10	20	0	2026-05-06 14:56:31.07605+00	2026-05-06 15:14:17.506999+00	::1	PostmanRuntime/7.51.1
a86d5fcd-1e7c-44c7-bbda-d0665f5f24e1	ac3f0987-3526-4544-9981-6c8c099ff629	3	failed	0	50	250	250	\N	0	0	0	0	2026-05-06 15:14:37.933319+00	2026-05-06 15:15:09.11761+00	::1	PostmanRuntime/7.51.1
a551da92-3050-4f40-a230-c1d834df97b2	ac3f0987-3526-4544-9981-6c8c099ff629	3	abandoned	0	50	250	\N	\N	0	0	0	0	2026-05-06 15:15:15.245819+00	2026-05-06 15:15:39.320072+00	::1	PostmanRuntime/7.51.1
5441a8ff-8947-4483-bfe1-0cd2bac57bfc	593dc93e-c4d3-4b0c-af64-da9cbca61910	3	abandoned	0	0	0	\N	\N	0	0	0	0	2026-05-06 14:32:42.85138+00	2026-05-06 17:43:09.859669+00	::1	PostmanRuntime/7.51.1
3a0f449f-25da-4bb8-b4f6-5a7eee9e7e15	ac3f0987-3526-4544-9981-6c8c099ff629	3	in_progress	0	50	250	\N	\N	0	0	0	0	2026-05-06 17:44:20.286896+00	\N	::1	PostmanRuntime/7.51.1
\.


--
-- Data for Name: levels; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.levels (id, name, description, order_index, elo_min, elo_gain_correct, elo_loss_incorrect, time_limit_seconds, enemy_wave_config, question_gen_config, max_score, is_active, created_at, updated_at) FROM stdin;
1	Addition	Practice addition!	1	0	15	5	60	{}	{"data": {"total_questions": 10}, "schema": 1}	1000	t	2026-05-05 19:27:25.455979+00	2026-05-06 14:55:25.169435+00
3	Substraction	Practice substraction!	2	0	15	5	60	{}	{"data": {"total_questions": 50}, "schema": 1}	1000	t	2026-05-05 19:28:07.667953+00	2026-05-06 14:55:54.847265+00
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.permissions (id, name) FROM stdin;
1	player:read
2	player:update
3	session:create
4	session:update
5	classroom:create
6	classroom:update
7	classroom:delete
8	classroom:read
9	classroom:join
10	classroom:leave
11	leaderboard:read
12	level:create
13	level:update
14	level:delete
15	admin:full
16	*
\.


--
-- Data for Name: players; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.players (id, username, display_name, email, avatar_url, role_id, oauth_provider, oauth_id, password_hash, current_elo, highest_level_unlocked, total_questions_answered, total_correct, total_incorrect, longest_streak, created_at, updated_at, last_active_at) FROM stdin;
7c6d3174-1ea0-4d2f-99fe-b4ea16e9ced0	Shawn Andrew	KRooK11	shawn@magicnugger.com	\N	1	\N	\N	$2b$12$jOImRfimRW8sIMzBWNlfeeRnFY4tqCydkIEeGv6GZKNp0/PeShMKu	0	1	0	0	0	0	2026-05-05 17:59:06.636933+00	2026-05-05 18:04:36.894913+00	\N
a41eef86-7b54-484b-99cc-538c10c9d1ff	alden	\N	alden@magicnugger.com	\N	1	\N	\N	$2b$12$IiYC21aKi9nEkRWZntSGrukl2n08wE0YX632Dph9NTvp5Mfh64xI6	0	1	0	0	0	0	2026-05-06 07:39:30.748553+00	2026-05-06 07:39:30.748553+00	\N
593dc93e-c4d3-4b0c-af64-da9cbca61910	alden+1	Christopher Alden	demo+1@magicnugger.com	\N	1	\N	\N	$2b$12$uIzF6FUUzyUaNxySbbCxfOP/k9omozJCRmN5YIZC2HvuQNAbtvFBy	0	1	0	0	0	0	2026-05-06 14:15:55.196049+00	2026-05-06 14:17:27.645857+00	\N
ac3f0987-3526-4544-9981-6c8c099ff629	alden+magicnugger	Christopher Alden	demo@magicnugger.com	\N	3	\N	\N	$2b$12$6GUs.eJu4fD217DhaZxLgOgNefuCqGugMWcCQkbLXknCRZ2SIt3mC	250	1	30	20	10	20	2026-05-05 17:26:59.2861+00	2026-05-06 15:15:09.11761+00	2026-05-06 15:15:09.11761+00
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role_permissions (role_id, permission_id) FROM stdin;
1	1
1	2
1	3
1	4
1	9
1	10
1	11
2	1
2	2
2	3
2	4
2	5
2	6
2	7
2	8
2	11
3	15
3	16
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, name, description) FROM stdin;
1	student	Default student role
2	teacher	Teacher role
3	admin	Admin with full access
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session (sid, sess, expire) FROM stdin;
1WrvNbEPuTsgoiVzhj-Tsea-eQuMm6Qn	{"cookie":{"originalMaxAge":604800000,"expires":"2026-05-13T14:39:34.677Z","secure":false,"httpOnly":true,"path":"/","sameSite":"lax"},"passport":{"user":"ac3f0987-3526-4544-9981-6c8c099ff629"}}	2026-05-13 17:44:21
\.


--
-- Data for Name: session_answers_default; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session_answers_default (id, session_id, is_correct, elo_delta, time_taken_ms, answered_at) FROM stdin;
\.


--
-- Data for Name: session_answers_p20260415; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session_answers_p20260415 (id, session_id, is_correct, elo_delta, time_taken_ms, answered_at) FROM stdin;
\.


--
-- Data for Name: session_answers_p20260422; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session_answers_p20260422 (id, session_id, is_correct, elo_delta, time_taken_ms, answered_at) FROM stdin;
\.


--
-- Data for Name: session_answers_p20260429; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session_answers_p20260429 (id, session_id, is_correct, elo_delta, time_taken_ms, answered_at) FROM stdin;
\.


--
-- Data for Name: session_answers_p20260506; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session_answers_p20260506 (id, session_id, is_correct, elo_delta, time_taken_ms, answered_at) FROM stdin;
1	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	t	15	3000	2026-05-06 14:57:44.091211+00
2	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	t	15	3000	2026-05-06 14:57:48.136306+00
3	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	t	15	3000	2026-05-06 14:57:49.05686+00
4	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	t	15	3000	2026-05-06 14:57:49.915232+00
5	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	t	15	3000	2026-05-06 14:57:50.718048+00
6	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	t	15	3000	2026-05-06 14:57:51.398506+00
7	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	t	15	3000	2026-05-06 14:57:52.323344+00
8	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	t	15	3000	2026-05-06 14:57:53.148554+00
9	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	t	15	3000	2026-05-06 14:57:53.899326+00
10	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	t	15	3000	2026-05-06 14:57:54.693242+00
11	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	t	15	3000	2026-05-06 14:57:55.409778+00
12	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	t	15	3000	2026-05-06 14:57:56.047413+00
13	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	t	15	3000	2026-05-06 14:57:56.781097+00
14	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	t	15	3000	2026-05-06 14:57:57.381961+00
15	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	t	15	3000	2026-05-06 14:57:58.179604+00
16	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	t	15	3000	2026-05-06 14:57:58.576568+00
17	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	t	15	3000	2026-05-06 14:57:59.214577+00
18	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	t	15	3000	2026-05-06 14:57:59.879501+00
19	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	t	15	3000	2026-05-06 14:58:00.56996+00
20	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	t	15	3000	2026-05-06 14:58:01.252797+00
21	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	f	-5	3000	2026-05-06 14:58:11.557832+00
22	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	f	-5	3000	2026-05-06 14:58:16.410684+00
23	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	f	-5	3000	2026-05-06 14:58:18.735307+00
24	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	f	-5	3000	2026-05-06 15:04:39.108824+00
25	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	f	-5	3000	2026-05-06 15:04:39.978658+00
26	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	f	-5	3000	2026-05-06 15:04:41.094852+00
27	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	f	-5	3000	2026-05-06 15:04:41.935063+00
28	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	f	-5	3000	2026-05-06 15:04:42.57966+00
29	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	f	-5	3000	2026-05-06 15:04:43.343331+00
30	bc1e7d44-82dc-43f6-ac1a-6c9c34a09b3f	f	-5	3000	2026-05-06 15:04:44.012189+00
\.


--
-- Data for Name: session_answers_p20260513; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session_answers_p20260513 (id, session_id, is_correct, elo_delta, time_taken_ms, answered_at) FROM stdin;
\.


--
-- Data for Name: session_answers_p20260520; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session_answers_p20260520 (id, session_id, is_correct, elo_delta, time_taken_ms, answered_at) FROM stdin;
\.


--
-- Data for Name: session_answers_p20260527; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session_answers_p20260527 (id, session_id, is_correct, elo_delta, time_taken_ms, answered_at) FROM stdin;
\.


--
-- Name: patches_id_seq; Type: SEQUENCE SET; Schema: _v; Owner: postgres
--

SELECT pg_catalog.setval('_v.patches_id_seq', 32, true);


--
-- Name: elo_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: partman_user
--

SELECT pg_catalog.setval('public.elo_history_id_seq', 2, true);


--
-- Name: levels_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.levels_id_seq', 3, true);


--
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.permissions_id_seq', 16, true);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_seq', 3, true);


--
-- Name: session_answers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: partman_user
--

SELECT pg_catalog.setval('public.session_answers_id_seq', 30, true);


--
-- Name: patches patches_patch_name_key; Type: CONSTRAINT; Schema: _v; Owner: postgres
--

ALTER TABLE ONLY _v.patches
    ADD CONSTRAINT patches_patch_name_key UNIQUE (patch_name);


--
-- Name: patches patches_pkey; Type: CONSTRAINT; Schema: _v; Owner: postgres
--

ALTER TABLE ONLY _v.patches
    ADD CONSTRAINT patches_pkey PRIMARY KEY (id);


--
-- Name: audit_events audit_events_pkey; Type: CONSTRAINT; Schema: audit; Owner: partman_user
--

ALTER TABLE ONLY audit.audit_events
    ADD CONSTRAINT audit_events_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_events_default audit_events_default_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events_default
    ADD CONSTRAINT audit_events_default_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_events_p20260201 audit_events_p20260201_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events_p20260201
    ADD CONSTRAINT audit_events_p20260201_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_events_p20260301 audit_events_p20260301_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events_p20260301
    ADD CONSTRAINT audit_events_p20260301_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_events_p20260401 audit_events_p20260401_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events_p20260401
    ADD CONSTRAINT audit_events_p20260401_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_events_p20260501 audit_events_p20260501_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events_p20260501
    ADD CONSTRAINT audit_events_p20260501_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_events_p20260601 audit_events_p20260601_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events_p20260601
    ADD CONSTRAINT audit_events_p20260601_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_events_p20260701 audit_events_p20260701_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events_p20260701
    ADD CONSTRAINT audit_events_p20260701_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_events_p20260801 audit_events_p20260801_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events_p20260801
    ADD CONSTRAINT audit_events_p20260801_pkey PRIMARY KEY (id, created_at);


--
-- Name: log_events log_events_pkey; Type: CONSTRAINT; Schema: audit; Owner: partman_user
--

ALTER TABLE ONLY audit.log_events
    ADD CONSTRAINT log_events_pkey PRIMARY KEY (id, created_at);


--
-- Name: log_events_default log_events_default_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events_default
    ADD CONSTRAINT log_events_default_pkey PRIMARY KEY (id, created_at);


--
-- Name: log_events_p20260201 log_events_p20260201_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events_p20260201
    ADD CONSTRAINT log_events_p20260201_pkey PRIMARY KEY (id, created_at);


--
-- Name: log_events_p20260301 log_events_p20260301_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events_p20260301
    ADD CONSTRAINT log_events_p20260301_pkey PRIMARY KEY (id, created_at);


--
-- Name: log_events_p20260401 log_events_p20260401_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events_p20260401
    ADD CONSTRAINT log_events_p20260401_pkey PRIMARY KEY (id, created_at);


--
-- Name: log_events_p20260501 log_events_p20260501_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events_p20260501
    ADD CONSTRAINT log_events_p20260501_pkey PRIMARY KEY (id, created_at);


--
-- Name: log_events_p20260601 log_events_p20260601_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events_p20260601
    ADD CONSTRAINT log_events_p20260601_pkey PRIMARY KEY (id, created_at);


--
-- Name: log_events_p20260701 log_events_p20260701_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events_p20260701
    ADD CONSTRAINT log_events_p20260701_pkey PRIMARY KEY (id, created_at);


--
-- Name: log_events_p20260801 log_events_p20260801_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events_p20260801
    ADD CONSTRAINT log_events_p20260801_pkey PRIMARY KEY (id, created_at);


--
-- Name: classroom_members classroom_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classroom_members
    ADD CONSTRAINT classroom_members_pkey PRIMARY KEY (classroom_id, player_id);


--
-- Name: classrooms classrooms_invite_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classrooms
    ADD CONSTRAINT classrooms_invite_code_key UNIQUE (invite_code);


--
-- Name: classrooms classrooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classrooms
    ADD CONSTRAINT classrooms_pkey PRIMARY KEY (id);


--
-- Name: elo_history elo_history_pkey; Type: CONSTRAINT; Schema: public; Owner: partman_user
--

ALTER TABLE ONLY public.elo_history
    ADD CONSTRAINT elo_history_pkey PRIMARY KEY (id, created_at);


--
-- Name: elo_history_default elo_history_default_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history_default
    ADD CONSTRAINT elo_history_default_pkey PRIMARY KEY (id, created_at);


--
-- Name: elo_history_p20260415 elo_history_p20260415_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history_p20260415
    ADD CONSTRAINT elo_history_p20260415_pkey PRIMARY KEY (id, created_at);


--
-- Name: elo_history_p20260422 elo_history_p20260422_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history_p20260422
    ADD CONSTRAINT elo_history_p20260422_pkey PRIMARY KEY (id, created_at);


--
-- Name: elo_history_p20260429 elo_history_p20260429_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history_p20260429
    ADD CONSTRAINT elo_history_p20260429_pkey PRIMARY KEY (id, created_at);


--
-- Name: elo_history_p20260506 elo_history_p20260506_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history_p20260506
    ADD CONSTRAINT elo_history_p20260506_pkey PRIMARY KEY (id, created_at);


--
-- Name: elo_history_p20260513 elo_history_p20260513_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history_p20260513
    ADD CONSTRAINT elo_history_p20260513_pkey PRIMARY KEY (id, created_at);


--
-- Name: elo_history_p20260520 elo_history_p20260520_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history_p20260520
    ADD CONSTRAINT elo_history_p20260520_pkey PRIMARY KEY (id, created_at);


--
-- Name: elo_history_p20260527 elo_history_p20260527_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history_p20260527
    ADD CONSTRAINT elo_history_p20260527_pkey PRIMARY KEY (id, created_at);


--
-- Name: game_sessions game_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_sessions
    ADD CONSTRAINT game_sessions_pkey PRIMARY KEY (id);


--
-- Name: levels levels_order_index_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.levels
    ADD CONSTRAINT levels_order_index_key UNIQUE (order_index);


--
-- Name: levels levels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.levels
    ADD CONSTRAINT levels_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_name_key UNIQUE (name);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: players players_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_email_key UNIQUE (email);


--
-- Name: players players_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- Name: players players_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_username_key UNIQUE (username);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id, permission_id);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: session_answers session_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: partman_user
--

ALTER TABLE ONLY public.session_answers
    ADD CONSTRAINT session_answers_pkey PRIMARY KEY (id, answered_at);


--
-- Name: session_answers_default session_answers_default_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers_default
    ADD CONSTRAINT session_answers_default_pkey PRIMARY KEY (id, answered_at);


--
-- Name: session_answers_p20260415 session_answers_p20260415_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers_p20260415
    ADD CONSTRAINT session_answers_p20260415_pkey PRIMARY KEY (id, answered_at);


--
-- Name: session_answers_p20260422 session_answers_p20260422_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers_p20260422
    ADD CONSTRAINT session_answers_p20260422_pkey PRIMARY KEY (id, answered_at);


--
-- Name: session_answers_p20260429 session_answers_p20260429_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers_p20260429
    ADD CONSTRAINT session_answers_p20260429_pkey PRIMARY KEY (id, answered_at);


--
-- Name: session_answers_p20260506 session_answers_p20260506_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers_p20260506
    ADD CONSTRAINT session_answers_p20260506_pkey PRIMARY KEY (id, answered_at);


--
-- Name: session_answers_p20260513 session_answers_p20260513_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers_p20260513
    ADD CONSTRAINT session_answers_p20260513_pkey PRIMARY KEY (id, answered_at);


--
-- Name: session_answers_p20260520 session_answers_p20260520_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers_p20260520
    ADD CONSTRAINT session_answers_p20260520_pkey PRIMARY KEY (id, answered_at);


--
-- Name: session_answers_p20260527 session_answers_p20260527_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers_p20260527
    ADD CONSTRAINT session_answers_p20260527_pkey PRIMARY KEY (id, answered_at);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (sid);


--
-- Name: idx_audit_events_created_at; Type: INDEX; Schema: audit; Owner: partman_user
--

CREATE INDEX idx_audit_events_created_at ON ONLY audit.audit_events USING btree (created_at DESC);


--
-- Name: audit_events_default_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_default_created_at_idx ON audit.audit_events_default USING btree (created_at DESC);


--
-- Name: idx_audit_events_status_code; Type: INDEX; Schema: audit; Owner: partman_user
--

CREATE INDEX idx_audit_events_status_code ON ONLY audit.audit_events USING btree (status_code);


--
-- Name: audit_events_default_status_code_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_default_status_code_idx ON audit.audit_events_default USING btree (status_code);


--
-- Name: idx_audit_events_url; Type: INDEX; Schema: audit; Owner: partman_user
--

CREATE INDEX idx_audit_events_url ON ONLY audit.audit_events USING btree (url);


--
-- Name: audit_events_default_url_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_default_url_idx ON audit.audit_events_default USING btree (url);


--
-- Name: idx_audit_events_user_id; Type: INDEX; Schema: audit; Owner: partman_user
--

CREATE INDEX idx_audit_events_user_id ON ONLY audit.audit_events USING btree (user_id);


--
-- Name: audit_events_default_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_default_user_id_idx ON audit.audit_events_default USING btree (user_id);


--
-- Name: audit_events_p20260201_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260201_created_at_idx ON audit.audit_events_p20260201 USING btree (created_at DESC);


--
-- Name: audit_events_p20260201_status_code_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260201_status_code_idx ON audit.audit_events_p20260201 USING btree (status_code);


--
-- Name: audit_events_p20260201_url_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260201_url_idx ON audit.audit_events_p20260201 USING btree (url);


--
-- Name: audit_events_p20260201_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260201_user_id_idx ON audit.audit_events_p20260201 USING btree (user_id);


--
-- Name: audit_events_p20260301_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260301_created_at_idx ON audit.audit_events_p20260301 USING btree (created_at DESC);


--
-- Name: audit_events_p20260301_status_code_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260301_status_code_idx ON audit.audit_events_p20260301 USING btree (status_code);


--
-- Name: audit_events_p20260301_url_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260301_url_idx ON audit.audit_events_p20260301 USING btree (url);


--
-- Name: audit_events_p20260301_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260301_user_id_idx ON audit.audit_events_p20260301 USING btree (user_id);


--
-- Name: audit_events_p20260401_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260401_created_at_idx ON audit.audit_events_p20260401 USING btree (created_at DESC);


--
-- Name: audit_events_p20260401_status_code_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260401_status_code_idx ON audit.audit_events_p20260401 USING btree (status_code);


--
-- Name: audit_events_p20260401_url_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260401_url_idx ON audit.audit_events_p20260401 USING btree (url);


--
-- Name: audit_events_p20260401_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260401_user_id_idx ON audit.audit_events_p20260401 USING btree (user_id);


--
-- Name: audit_events_p20260501_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260501_created_at_idx ON audit.audit_events_p20260501 USING btree (created_at DESC);


--
-- Name: audit_events_p20260501_status_code_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260501_status_code_idx ON audit.audit_events_p20260501 USING btree (status_code);


--
-- Name: audit_events_p20260501_url_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260501_url_idx ON audit.audit_events_p20260501 USING btree (url);


--
-- Name: audit_events_p20260501_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260501_user_id_idx ON audit.audit_events_p20260501 USING btree (user_id);


--
-- Name: audit_events_p20260601_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260601_created_at_idx ON audit.audit_events_p20260601 USING btree (created_at DESC);


--
-- Name: audit_events_p20260601_status_code_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260601_status_code_idx ON audit.audit_events_p20260601 USING btree (status_code);


--
-- Name: audit_events_p20260601_url_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260601_url_idx ON audit.audit_events_p20260601 USING btree (url);


--
-- Name: audit_events_p20260601_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260601_user_id_idx ON audit.audit_events_p20260601 USING btree (user_id);


--
-- Name: audit_events_p20260701_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260701_created_at_idx ON audit.audit_events_p20260701 USING btree (created_at DESC);


--
-- Name: audit_events_p20260701_status_code_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260701_status_code_idx ON audit.audit_events_p20260701 USING btree (status_code);


--
-- Name: audit_events_p20260701_url_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260701_url_idx ON audit.audit_events_p20260701 USING btree (url);


--
-- Name: audit_events_p20260701_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260701_user_id_idx ON audit.audit_events_p20260701 USING btree (user_id);


--
-- Name: audit_events_p20260801_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260801_created_at_idx ON audit.audit_events_p20260801 USING btree (created_at DESC);


--
-- Name: audit_events_p20260801_status_code_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260801_status_code_idx ON audit.audit_events_p20260801 USING btree (status_code);


--
-- Name: audit_events_p20260801_url_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260801_url_idx ON audit.audit_events_p20260801 USING btree (url);


--
-- Name: audit_events_p20260801_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260801_user_id_idx ON audit.audit_events_p20260801 USING btree (user_id);


--
-- Name: idx_log_events_created_at; Type: INDEX; Schema: audit; Owner: partman_user
--

CREATE INDEX idx_log_events_created_at ON ONLY audit.log_events USING btree (created_at DESC);


--
-- Name: idx_log_events_event; Type: INDEX; Schema: audit; Owner: partman_user
--

CREATE INDEX idx_log_events_event ON ONLY audit.log_events USING btree (event);


--
-- Name: idx_log_events_level; Type: INDEX; Schema: audit; Owner: partman_user
--

CREATE INDEX idx_log_events_level ON ONLY audit.log_events USING btree (level);


--
-- Name: idx_log_events_user_id; Type: INDEX; Schema: audit; Owner: partman_user
--

CREATE INDEX idx_log_events_user_id ON ONLY audit.log_events USING btree (user_id);


--
-- Name: log_events_default_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_default_created_at_idx ON audit.log_events_default USING btree (created_at DESC);


--
-- Name: log_events_default_event_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_default_event_idx ON audit.log_events_default USING btree (event);


--
-- Name: log_events_default_level_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_default_level_idx ON audit.log_events_default USING btree (level);


--
-- Name: log_events_default_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_default_user_id_idx ON audit.log_events_default USING btree (user_id);


--
-- Name: log_events_p20260201_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260201_created_at_idx ON audit.log_events_p20260201 USING btree (created_at DESC);


--
-- Name: log_events_p20260201_event_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260201_event_idx ON audit.log_events_p20260201 USING btree (event);


--
-- Name: log_events_p20260201_level_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260201_level_idx ON audit.log_events_p20260201 USING btree (level);


--
-- Name: log_events_p20260201_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260201_user_id_idx ON audit.log_events_p20260201 USING btree (user_id);


--
-- Name: log_events_p20260301_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260301_created_at_idx ON audit.log_events_p20260301 USING btree (created_at DESC);


--
-- Name: log_events_p20260301_event_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260301_event_idx ON audit.log_events_p20260301 USING btree (event);


--
-- Name: log_events_p20260301_level_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260301_level_idx ON audit.log_events_p20260301 USING btree (level);


--
-- Name: log_events_p20260301_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260301_user_id_idx ON audit.log_events_p20260301 USING btree (user_id);


--
-- Name: log_events_p20260401_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260401_created_at_idx ON audit.log_events_p20260401 USING btree (created_at DESC);


--
-- Name: log_events_p20260401_event_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260401_event_idx ON audit.log_events_p20260401 USING btree (event);


--
-- Name: log_events_p20260401_level_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260401_level_idx ON audit.log_events_p20260401 USING btree (level);


--
-- Name: log_events_p20260401_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260401_user_id_idx ON audit.log_events_p20260401 USING btree (user_id);


--
-- Name: log_events_p20260501_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260501_created_at_idx ON audit.log_events_p20260501 USING btree (created_at DESC);


--
-- Name: log_events_p20260501_event_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260501_event_idx ON audit.log_events_p20260501 USING btree (event);


--
-- Name: log_events_p20260501_level_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260501_level_idx ON audit.log_events_p20260501 USING btree (level);


--
-- Name: log_events_p20260501_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260501_user_id_idx ON audit.log_events_p20260501 USING btree (user_id);


--
-- Name: log_events_p20260601_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260601_created_at_idx ON audit.log_events_p20260601 USING btree (created_at DESC);


--
-- Name: log_events_p20260601_event_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260601_event_idx ON audit.log_events_p20260601 USING btree (event);


--
-- Name: log_events_p20260601_level_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260601_level_idx ON audit.log_events_p20260601 USING btree (level);


--
-- Name: log_events_p20260601_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260601_user_id_idx ON audit.log_events_p20260601 USING btree (user_id);


--
-- Name: log_events_p20260701_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260701_created_at_idx ON audit.log_events_p20260701 USING btree (created_at DESC);


--
-- Name: log_events_p20260701_event_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260701_event_idx ON audit.log_events_p20260701 USING btree (event);


--
-- Name: log_events_p20260701_level_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260701_level_idx ON audit.log_events_p20260701 USING btree (level);


--
-- Name: log_events_p20260701_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260701_user_id_idx ON audit.log_events_p20260701 USING btree (user_id);


--
-- Name: log_events_p20260801_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260801_created_at_idx ON audit.log_events_p20260801 USING btree (created_at DESC);


--
-- Name: log_events_p20260801_event_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260801_event_idx ON audit.log_events_p20260801 USING btree (event);


--
-- Name: log_events_p20260801_level_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260801_level_idx ON audit.log_events_p20260801 USING btree (level);


--
-- Name: log_events_p20260801_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260801_user_id_idx ON audit.log_events_p20260801 USING btree (user_id);


--
-- Name: IDX_session_expire; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_session_expire" ON public.session USING btree (expire);


--
-- Name: idx_elo_history_player; Type: INDEX; Schema: public; Owner: partman_user
--

CREATE INDEX idx_elo_history_player ON ONLY public.elo_history USING btree (player_id, created_at DESC);


--
-- Name: elo_history_default_player_id_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX elo_history_default_player_id_created_at_idx ON public.elo_history_default USING btree (player_id, created_at DESC);


--
-- Name: elo_history_p20260415_player_id_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX elo_history_p20260415_player_id_created_at_idx ON public.elo_history_p20260415 USING btree (player_id, created_at DESC);


--
-- Name: elo_history_p20260422_player_id_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX elo_history_p20260422_player_id_created_at_idx ON public.elo_history_p20260422 USING btree (player_id, created_at DESC);


--
-- Name: elo_history_p20260429_player_id_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX elo_history_p20260429_player_id_created_at_idx ON public.elo_history_p20260429 USING btree (player_id, created_at DESC);


--
-- Name: elo_history_p20260506_player_id_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX elo_history_p20260506_player_id_created_at_idx ON public.elo_history_p20260506 USING btree (player_id, created_at DESC);


--
-- Name: elo_history_p20260513_player_id_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX elo_history_p20260513_player_id_created_at_idx ON public.elo_history_p20260513 USING btree (player_id, created_at DESC);


--
-- Name: elo_history_p20260520_player_id_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX elo_history_p20260520_player_id_created_at_idx ON public.elo_history_p20260520 USING btree (player_id, created_at DESC);


--
-- Name: elo_history_p20260527_player_id_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX elo_history_p20260527_player_id_created_at_idx ON public.elo_history_p20260527 USING btree (player_id, created_at DESC);


--
-- Name: idx_answers_session; Type: INDEX; Schema: public; Owner: partman_user
--

CREATE INDEX idx_answers_session ON ONLY public.session_answers USING btree (session_id, answered_at);


--
-- Name: idx_classrooms_invite; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_classrooms_invite ON public.classrooms USING btree (invite_code);


--
-- Name: idx_classrooms_teacher; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_classrooms_teacher ON public.classrooms USING btree (teacher_id);


--
-- Name: idx_members_player; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_members_player ON public.classroom_members USING btree (player_id);


--
-- Name: idx_players_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_players_created ON public.players USING btree (created_at DESC);


--
-- Name: idx_players_elo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_players_elo ON public.players USING btree (current_elo DESC);


--
-- Name: idx_players_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_players_email ON public.players USING btree (email);


--
-- Name: idx_players_oauth; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_players_oauth ON public.players USING btree (oauth_provider, oauth_id) WHERE (oauth_provider IS NOT NULL);


--
-- Name: idx_sessions_level; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sessions_level ON public.game_sessions USING btree (level_id, score DESC) WHERE ((status)::text = 'completed'::text);


--
-- Name: idx_sessions_player; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sessions_player ON public.game_sessions USING btree (player_id, started_at DESC);


--
-- Name: idx_sessions_started; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sessions_started ON public.game_sessions USING btree (started_at DESC);


--
-- Name: idx_sessions_status_started; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sessions_status_started ON public.game_sessions USING btree (status, started_at DESC);


--
-- Name: session_answers_default_session_id_answered_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX session_answers_default_session_id_answered_at_idx ON public.session_answers_default USING btree (session_id, answered_at);


--
-- Name: session_answers_p20260415_session_id_answered_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX session_answers_p20260415_session_id_answered_at_idx ON public.session_answers_p20260415 USING btree (session_id, answered_at);


--
-- Name: session_answers_p20260422_session_id_answered_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX session_answers_p20260422_session_id_answered_at_idx ON public.session_answers_p20260422 USING btree (session_id, answered_at);


--
-- Name: session_answers_p20260429_session_id_answered_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX session_answers_p20260429_session_id_answered_at_idx ON public.session_answers_p20260429 USING btree (session_id, answered_at);


--
-- Name: session_answers_p20260506_session_id_answered_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX session_answers_p20260506_session_id_answered_at_idx ON public.session_answers_p20260506 USING btree (session_id, answered_at);


--
-- Name: session_answers_p20260513_session_id_answered_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX session_answers_p20260513_session_id_answered_at_idx ON public.session_answers_p20260513 USING btree (session_id, answered_at);


--
-- Name: session_answers_p20260520_session_id_answered_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX session_answers_p20260520_session_id_answered_at_idx ON public.session_answers_p20260520 USING btree (session_id, answered_at);


--
-- Name: session_answers_p20260527_session_id_answered_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX session_answers_p20260527_session_id_answered_at_idx ON public.session_answers_p20260527 USING btree (session_id, answered_at);


--
-- Name: audit_events_default_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_created_at ATTACH PARTITION audit.audit_events_default_created_at_idx;


--
-- Name: audit_events_default_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.audit_events_pkey ATTACH PARTITION audit.audit_events_default_pkey;


--
-- Name: audit_events_default_status_code_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_status_code ATTACH PARTITION audit.audit_events_default_status_code_idx;


--
-- Name: audit_events_default_url_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_url ATTACH PARTITION audit.audit_events_default_url_idx;


--
-- Name: audit_events_default_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_user_id ATTACH PARTITION audit.audit_events_default_user_id_idx;


--
-- Name: audit_events_p20260201_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_created_at ATTACH PARTITION audit.audit_events_p20260201_created_at_idx;


--
-- Name: audit_events_p20260201_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.audit_events_pkey ATTACH PARTITION audit.audit_events_p20260201_pkey;


--
-- Name: audit_events_p20260201_status_code_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_status_code ATTACH PARTITION audit.audit_events_p20260201_status_code_idx;


--
-- Name: audit_events_p20260201_url_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_url ATTACH PARTITION audit.audit_events_p20260201_url_idx;


--
-- Name: audit_events_p20260201_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_user_id ATTACH PARTITION audit.audit_events_p20260201_user_id_idx;


--
-- Name: audit_events_p20260301_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_created_at ATTACH PARTITION audit.audit_events_p20260301_created_at_idx;


--
-- Name: audit_events_p20260301_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.audit_events_pkey ATTACH PARTITION audit.audit_events_p20260301_pkey;


--
-- Name: audit_events_p20260301_status_code_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_status_code ATTACH PARTITION audit.audit_events_p20260301_status_code_idx;


--
-- Name: audit_events_p20260301_url_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_url ATTACH PARTITION audit.audit_events_p20260301_url_idx;


--
-- Name: audit_events_p20260301_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_user_id ATTACH PARTITION audit.audit_events_p20260301_user_id_idx;


--
-- Name: audit_events_p20260401_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_created_at ATTACH PARTITION audit.audit_events_p20260401_created_at_idx;


--
-- Name: audit_events_p20260401_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.audit_events_pkey ATTACH PARTITION audit.audit_events_p20260401_pkey;


--
-- Name: audit_events_p20260401_status_code_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_status_code ATTACH PARTITION audit.audit_events_p20260401_status_code_idx;


--
-- Name: audit_events_p20260401_url_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_url ATTACH PARTITION audit.audit_events_p20260401_url_idx;


--
-- Name: audit_events_p20260401_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_user_id ATTACH PARTITION audit.audit_events_p20260401_user_id_idx;


--
-- Name: audit_events_p20260501_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_created_at ATTACH PARTITION audit.audit_events_p20260501_created_at_idx;


--
-- Name: audit_events_p20260501_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.audit_events_pkey ATTACH PARTITION audit.audit_events_p20260501_pkey;


--
-- Name: audit_events_p20260501_status_code_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_status_code ATTACH PARTITION audit.audit_events_p20260501_status_code_idx;


--
-- Name: audit_events_p20260501_url_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_url ATTACH PARTITION audit.audit_events_p20260501_url_idx;


--
-- Name: audit_events_p20260501_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_user_id ATTACH PARTITION audit.audit_events_p20260501_user_id_idx;


--
-- Name: audit_events_p20260601_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_created_at ATTACH PARTITION audit.audit_events_p20260601_created_at_idx;


--
-- Name: audit_events_p20260601_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.audit_events_pkey ATTACH PARTITION audit.audit_events_p20260601_pkey;


--
-- Name: audit_events_p20260601_status_code_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_status_code ATTACH PARTITION audit.audit_events_p20260601_status_code_idx;


--
-- Name: audit_events_p20260601_url_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_url ATTACH PARTITION audit.audit_events_p20260601_url_idx;


--
-- Name: audit_events_p20260601_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_user_id ATTACH PARTITION audit.audit_events_p20260601_user_id_idx;


--
-- Name: audit_events_p20260701_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_created_at ATTACH PARTITION audit.audit_events_p20260701_created_at_idx;


--
-- Name: audit_events_p20260701_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.audit_events_pkey ATTACH PARTITION audit.audit_events_p20260701_pkey;


--
-- Name: audit_events_p20260701_status_code_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_status_code ATTACH PARTITION audit.audit_events_p20260701_status_code_idx;


--
-- Name: audit_events_p20260701_url_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_url ATTACH PARTITION audit.audit_events_p20260701_url_idx;


--
-- Name: audit_events_p20260701_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_user_id ATTACH PARTITION audit.audit_events_p20260701_user_id_idx;


--
-- Name: audit_events_p20260801_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_created_at ATTACH PARTITION audit.audit_events_p20260801_created_at_idx;


--
-- Name: audit_events_p20260801_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.audit_events_pkey ATTACH PARTITION audit.audit_events_p20260801_pkey;


--
-- Name: audit_events_p20260801_status_code_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_status_code ATTACH PARTITION audit.audit_events_p20260801_status_code_idx;


--
-- Name: audit_events_p20260801_url_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_url ATTACH PARTITION audit.audit_events_p20260801_url_idx;


--
-- Name: audit_events_p20260801_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_user_id ATTACH PARTITION audit.audit_events_p20260801_user_id_idx;


--
-- Name: log_events_default_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_created_at ATTACH PARTITION audit.log_events_default_created_at_idx;


--
-- Name: log_events_default_event_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_event ATTACH PARTITION audit.log_events_default_event_idx;


--
-- Name: log_events_default_level_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_level ATTACH PARTITION audit.log_events_default_level_idx;


--
-- Name: log_events_default_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.log_events_pkey ATTACH PARTITION audit.log_events_default_pkey;


--
-- Name: log_events_default_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_user_id ATTACH PARTITION audit.log_events_default_user_id_idx;


--
-- Name: log_events_p20260201_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_created_at ATTACH PARTITION audit.log_events_p20260201_created_at_idx;


--
-- Name: log_events_p20260201_event_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_event ATTACH PARTITION audit.log_events_p20260201_event_idx;


--
-- Name: log_events_p20260201_level_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_level ATTACH PARTITION audit.log_events_p20260201_level_idx;


--
-- Name: log_events_p20260201_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.log_events_pkey ATTACH PARTITION audit.log_events_p20260201_pkey;


--
-- Name: log_events_p20260201_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_user_id ATTACH PARTITION audit.log_events_p20260201_user_id_idx;


--
-- Name: log_events_p20260301_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_created_at ATTACH PARTITION audit.log_events_p20260301_created_at_idx;


--
-- Name: log_events_p20260301_event_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_event ATTACH PARTITION audit.log_events_p20260301_event_idx;


--
-- Name: log_events_p20260301_level_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_level ATTACH PARTITION audit.log_events_p20260301_level_idx;


--
-- Name: log_events_p20260301_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.log_events_pkey ATTACH PARTITION audit.log_events_p20260301_pkey;


--
-- Name: log_events_p20260301_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_user_id ATTACH PARTITION audit.log_events_p20260301_user_id_idx;


--
-- Name: log_events_p20260401_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_created_at ATTACH PARTITION audit.log_events_p20260401_created_at_idx;


--
-- Name: log_events_p20260401_event_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_event ATTACH PARTITION audit.log_events_p20260401_event_idx;


--
-- Name: log_events_p20260401_level_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_level ATTACH PARTITION audit.log_events_p20260401_level_idx;


--
-- Name: log_events_p20260401_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.log_events_pkey ATTACH PARTITION audit.log_events_p20260401_pkey;


--
-- Name: log_events_p20260401_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_user_id ATTACH PARTITION audit.log_events_p20260401_user_id_idx;


--
-- Name: log_events_p20260501_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_created_at ATTACH PARTITION audit.log_events_p20260501_created_at_idx;


--
-- Name: log_events_p20260501_event_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_event ATTACH PARTITION audit.log_events_p20260501_event_idx;


--
-- Name: log_events_p20260501_level_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_level ATTACH PARTITION audit.log_events_p20260501_level_idx;


--
-- Name: log_events_p20260501_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.log_events_pkey ATTACH PARTITION audit.log_events_p20260501_pkey;


--
-- Name: log_events_p20260501_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_user_id ATTACH PARTITION audit.log_events_p20260501_user_id_idx;


--
-- Name: log_events_p20260601_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_created_at ATTACH PARTITION audit.log_events_p20260601_created_at_idx;


--
-- Name: log_events_p20260601_event_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_event ATTACH PARTITION audit.log_events_p20260601_event_idx;


--
-- Name: log_events_p20260601_level_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_level ATTACH PARTITION audit.log_events_p20260601_level_idx;


--
-- Name: log_events_p20260601_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.log_events_pkey ATTACH PARTITION audit.log_events_p20260601_pkey;


--
-- Name: log_events_p20260601_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_user_id ATTACH PARTITION audit.log_events_p20260601_user_id_idx;


--
-- Name: log_events_p20260701_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_created_at ATTACH PARTITION audit.log_events_p20260701_created_at_idx;


--
-- Name: log_events_p20260701_event_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_event ATTACH PARTITION audit.log_events_p20260701_event_idx;


--
-- Name: log_events_p20260701_level_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_level ATTACH PARTITION audit.log_events_p20260701_level_idx;


--
-- Name: log_events_p20260701_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.log_events_pkey ATTACH PARTITION audit.log_events_p20260701_pkey;


--
-- Name: log_events_p20260701_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_user_id ATTACH PARTITION audit.log_events_p20260701_user_id_idx;


--
-- Name: log_events_p20260801_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_created_at ATTACH PARTITION audit.log_events_p20260801_created_at_idx;


--
-- Name: log_events_p20260801_event_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_event ATTACH PARTITION audit.log_events_p20260801_event_idx;


--
-- Name: log_events_p20260801_level_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_level ATTACH PARTITION audit.log_events_p20260801_level_idx;


--
-- Name: log_events_p20260801_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.log_events_pkey ATTACH PARTITION audit.log_events_p20260801_pkey;


--
-- Name: log_events_p20260801_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_user_id ATTACH PARTITION audit.log_events_p20260801_user_id_idx;


--
-- Name: elo_history_default_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.elo_history_pkey ATTACH PARTITION public.elo_history_default_pkey;


--
-- Name: elo_history_default_player_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_elo_history_player ATTACH PARTITION public.elo_history_default_player_id_created_at_idx;


--
-- Name: elo_history_p20260415_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.elo_history_pkey ATTACH PARTITION public.elo_history_p20260415_pkey;


--
-- Name: elo_history_p20260415_player_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_elo_history_player ATTACH PARTITION public.elo_history_p20260415_player_id_created_at_idx;


--
-- Name: elo_history_p20260422_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.elo_history_pkey ATTACH PARTITION public.elo_history_p20260422_pkey;


--
-- Name: elo_history_p20260422_player_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_elo_history_player ATTACH PARTITION public.elo_history_p20260422_player_id_created_at_idx;


--
-- Name: elo_history_p20260429_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.elo_history_pkey ATTACH PARTITION public.elo_history_p20260429_pkey;


--
-- Name: elo_history_p20260429_player_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_elo_history_player ATTACH PARTITION public.elo_history_p20260429_player_id_created_at_idx;


--
-- Name: elo_history_p20260506_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.elo_history_pkey ATTACH PARTITION public.elo_history_p20260506_pkey;


--
-- Name: elo_history_p20260506_player_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_elo_history_player ATTACH PARTITION public.elo_history_p20260506_player_id_created_at_idx;


--
-- Name: elo_history_p20260513_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.elo_history_pkey ATTACH PARTITION public.elo_history_p20260513_pkey;


--
-- Name: elo_history_p20260513_player_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_elo_history_player ATTACH PARTITION public.elo_history_p20260513_player_id_created_at_idx;


--
-- Name: elo_history_p20260520_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.elo_history_pkey ATTACH PARTITION public.elo_history_p20260520_pkey;


--
-- Name: elo_history_p20260520_player_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_elo_history_player ATTACH PARTITION public.elo_history_p20260520_player_id_created_at_idx;


--
-- Name: elo_history_p20260527_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.elo_history_pkey ATTACH PARTITION public.elo_history_p20260527_pkey;


--
-- Name: elo_history_p20260527_player_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_elo_history_player ATTACH PARTITION public.elo_history_p20260527_player_id_created_at_idx;


--
-- Name: session_answers_default_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.session_answers_pkey ATTACH PARTITION public.session_answers_default_pkey;


--
-- Name: session_answers_default_session_id_answered_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_answers_session ATTACH PARTITION public.session_answers_default_session_id_answered_at_idx;


--
-- Name: session_answers_p20260415_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.session_answers_pkey ATTACH PARTITION public.session_answers_p20260415_pkey;


--
-- Name: session_answers_p20260415_session_id_answered_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_answers_session ATTACH PARTITION public.session_answers_p20260415_session_id_answered_at_idx;


--
-- Name: session_answers_p20260422_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.session_answers_pkey ATTACH PARTITION public.session_answers_p20260422_pkey;


--
-- Name: session_answers_p20260422_session_id_answered_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_answers_session ATTACH PARTITION public.session_answers_p20260422_session_id_answered_at_idx;


--
-- Name: session_answers_p20260429_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.session_answers_pkey ATTACH PARTITION public.session_answers_p20260429_pkey;


--
-- Name: session_answers_p20260429_session_id_answered_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_answers_session ATTACH PARTITION public.session_answers_p20260429_session_id_answered_at_idx;


--
-- Name: session_answers_p20260506_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.session_answers_pkey ATTACH PARTITION public.session_answers_p20260506_pkey;


--
-- Name: session_answers_p20260506_session_id_answered_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_answers_session ATTACH PARTITION public.session_answers_p20260506_session_id_answered_at_idx;


--
-- Name: session_answers_p20260513_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.session_answers_pkey ATTACH PARTITION public.session_answers_p20260513_pkey;


--
-- Name: session_answers_p20260513_session_id_answered_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_answers_session ATTACH PARTITION public.session_answers_p20260513_session_id_answered_at_idx;


--
-- Name: session_answers_p20260520_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.session_answers_pkey ATTACH PARTITION public.session_answers_p20260520_pkey;


--
-- Name: session_answers_p20260520_session_id_answered_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_answers_session ATTACH PARTITION public.session_answers_p20260520_session_id_answered_at_idx;


--
-- Name: session_answers_p20260527_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.session_answers_pkey ATTACH PARTITION public.session_answers_p20260527_pkey;


--
-- Name: session_answers_p20260527_session_id_answered_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_answers_session ATTACH PARTITION public.session_answers_p20260527_session_id_answered_at_idx;


--
-- Name: audit_events audit_events_user_id_fkey; Type: FK CONSTRAINT; Schema: audit; Owner: partman_user
--

ALTER TABLE audit.audit_events
    ADD CONSTRAINT audit_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.players(id) ON DELETE SET NULL;


--
-- Name: log_events log_events_user_id_fkey; Type: FK CONSTRAINT; Schema: audit; Owner: partman_user
--

ALTER TABLE audit.log_events
    ADD CONSTRAINT log_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.players(id) ON DELETE SET NULL;


--
-- Name: classroom_members classroom_members_classroom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classroom_members
    ADD CONSTRAINT classroom_members_classroom_id_fkey FOREIGN KEY (classroom_id) REFERENCES public.classrooms(id) ON DELETE CASCADE;


--
-- Name: classroom_members classroom_members_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classroom_members
    ADD CONSTRAINT classroom_members_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: classrooms classrooms_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classrooms
    ADD CONSTRAINT classrooms_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: elo_history elo_history_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: partman_user
--

ALTER TABLE public.elo_history
    ADD CONSTRAINT elo_history_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: elo_history elo_history_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: partman_user
--

ALTER TABLE public.elo_history
    ADD CONSTRAINT elo_history_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.game_sessions(id) ON DELETE SET NULL;


--
-- Name: game_sessions game_sessions_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_sessions
    ADD CONSTRAINT game_sessions_level_id_fkey FOREIGN KEY (level_id) REFERENCES public.levels(id);


--
-- Name: game_sessions game_sessions_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_sessions
    ADD CONSTRAINT game_sessions_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: players players_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: role_permissions role_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: session_answers session_answers_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: partman_user
--

ALTER TABLE public.session_answers
    ADD CONSTRAINT session_answers_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.game_sessions(id) ON DELETE CASCADE;


--
-- Name: SCHEMA audit; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA audit TO partman_user;
GRANT USAGE ON SCHEMA audit TO app;


--
-- Name: SCHEMA partman; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA partman TO partman_user;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO app;
GRANT USAGE ON SCHEMA public TO jas;


--
-- Name: FUNCTION apply_cluster(p_parent_schema text, p_parent_tablename text, p_child_schema text, p_child_tablename text); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.apply_cluster(p_parent_schema text, p_parent_tablename text, p_child_schema text, p_child_tablename text) TO partman_user;


--
-- Name: FUNCTION apply_constraints(p_parent_table text, p_child_table text, p_analyze boolean, p_job_id bigint); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.apply_constraints(p_parent_table text, p_child_table text, p_analyze boolean, p_job_id bigint) TO partman_user;


--
-- Name: FUNCTION apply_privileges(p_parent_schema text, p_parent_tablename text, p_child_schema text, p_child_tablename text, p_job_id bigint); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.apply_privileges(p_parent_schema text, p_parent_tablename text, p_child_schema text, p_child_tablename text, p_job_id bigint) TO partman_user;


--
-- Name: FUNCTION autovacuum_off(p_parent_schema text, p_parent_tablename text, p_source_schema text, p_source_tablename text); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.autovacuum_off(p_parent_schema text, p_parent_tablename text, p_source_schema text, p_source_tablename text) TO partman_user;


--
-- Name: FUNCTION autovacuum_reset(p_parent_schema text, p_parent_tablename text, p_source_schema text, p_source_tablename text); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.autovacuum_reset(p_parent_schema text, p_parent_tablename text, p_source_schema text, p_source_tablename text) TO partman_user;


--
-- Name: FUNCTION calculate_time_partition_info(p_time_interval interval, p_start_time timestamp with time zone, p_date_trunc_interval text, OUT base_timestamp timestamp with time zone, OUT datetime_string text); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.calculate_time_partition_info(p_time_interval interval, p_start_time timestamp with time zone, p_date_trunc_interval text, OUT base_timestamp timestamp with time zone, OUT datetime_string text) TO partman_user;


--
-- Name: FUNCTION check_automatic_maintenance_value(p_automatic_maintenance text); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.check_automatic_maintenance_value(p_automatic_maintenance text) TO partman_user;


--
-- Name: FUNCTION check_control_type(p_parent_schema text, p_parent_tablename text, p_control text); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.check_control_type(p_parent_schema text, p_parent_tablename text, p_control text) TO partman_user;


--
-- Name: FUNCTION check_default(p_exact_count boolean, p_ignore_infinity boolean); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.check_default(p_exact_count boolean, p_ignore_infinity boolean) TO partman_user;


--
-- Name: FUNCTION check_epoch_type(p_type text); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.check_epoch_type(p_type text) TO partman_user;


--
-- Name: FUNCTION check_name_length(p_object_name text, p_suffix text, p_table_partition boolean); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.check_name_length(p_object_name text, p_suffix text, p_table_partition boolean) TO partman_user;


--
-- Name: FUNCTION check_partition_type(p_type text); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.check_partition_type(p_type text) TO partman_user;


--
-- Name: FUNCTION check_subpart_sameconfig(p_parent_table text); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.check_subpart_sameconfig(p_parent_table text) TO partman_user;


--
-- Name: FUNCTION check_subpartition_limits(p_parent_table text, p_type text, OUT sub_min text, OUT sub_max text); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.check_subpartition_limits(p_parent_table text, p_type text, OUT sub_min text, OUT sub_max text) TO partman_user;


--
-- Name: FUNCTION config_cleanup(p_parent_table text, p_config_table boolean, p_config_sub_table boolean, p_template_table boolean); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.config_cleanup(p_parent_table text, p_config_table boolean, p_config_sub_table boolean, p_template_table boolean) TO partman_user;


--
-- Name: FUNCTION create_parent(p_parent_table text, p_control text, p_interval text, p_type text, p_epoch text, p_premake integer, p_start_partition text, p_default_table boolean, p_automatic_maintenance text, p_constraint_cols text[], p_template_table text, p_jobmon boolean, p_date_trunc_interval text, p_control_not_null boolean, p_time_encoder text, p_time_decoder text, p_offset_id bigint); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.create_parent(p_parent_table text, p_control text, p_interval text, p_type text, p_epoch text, p_premake integer, p_start_partition text, p_default_table boolean, p_automatic_maintenance text, p_constraint_cols text[], p_template_table text, p_jobmon boolean, p_date_trunc_interval text, p_control_not_null boolean, p_time_encoder text, p_time_decoder text, p_offset_id bigint) TO partman_user;


--
-- Name: FUNCTION create_partition(p_parent_table text, p_control text, p_interval text, p_type text, p_epoch text, p_premake integer, p_start_partition text, p_default_table boolean, p_automatic_maintenance text, p_constraint_cols text[], p_template_table text, p_jobmon boolean, p_date_trunc_interval text, p_control_not_null boolean, p_time_encoder text, p_time_decoder text, p_offset_id bigint); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.create_partition(p_parent_table text, p_control text, p_interval text, p_type text, p_epoch text, p_premake integer, p_start_partition text, p_default_table boolean, p_automatic_maintenance text, p_constraint_cols text[], p_template_table text, p_jobmon boolean, p_date_trunc_interval text, p_control_not_null boolean, p_time_encoder text, p_time_decoder text, p_offset_id bigint) TO partman_user;


--
-- Name: FUNCTION create_partition_id(p_parent_table text, p_partition_ids bigint[], p_start_partition text); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.create_partition_id(p_parent_table text, p_partition_ids bigint[], p_start_partition text) TO partman_user;


--
-- Name: FUNCTION create_partition_time(p_parent_table text, p_partition_times timestamp with time zone[], p_start_partition text); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.create_partition_time(p_parent_table text, p_partition_times timestamp with time zone[], p_start_partition text) TO partman_user;


--
-- Name: FUNCTION create_sub_parent(p_top_parent text, p_control text, p_interval text, p_type text, p_default_table boolean, p_declarative_check text, p_constraint_cols text[], p_premake integer, p_start_partition text, p_epoch text, p_jobmon boolean, p_date_trunc_interval text, p_control_not_null boolean, p_time_encoder text, p_time_decoder text); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.create_sub_parent(p_top_parent text, p_control text, p_interval text, p_type text, p_default_table boolean, p_declarative_check text, p_constraint_cols text[], p_premake integer, p_start_partition text, p_epoch text, p_jobmon boolean, p_date_trunc_interval text, p_control_not_null boolean, p_time_encoder text, p_time_decoder text) TO partman_user;


--
-- Name: FUNCTION create_sub_partition(p_top_parent text, p_control text, p_interval text, p_type text, p_default_table boolean, p_declarative_check text, p_constraint_cols text[], p_premake integer, p_start_partition text, p_epoch text, p_jobmon boolean, p_date_trunc_interval text, p_control_not_null boolean, p_time_encoder text, p_time_decoder text); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.create_sub_partition(p_top_parent text, p_control text, p_interval text, p_type text, p_default_table boolean, p_declarative_check text, p_constraint_cols text[], p_premake integer, p_start_partition text, p_epoch text, p_jobmon boolean, p_date_trunc_interval text, p_control_not_null boolean, p_time_encoder text, p_time_decoder text) TO partman_user;


--
-- Name: FUNCTION drop_constraints(p_parent_table text, p_child_table text, p_debug boolean); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.drop_constraints(p_parent_table text, p_child_table text, p_debug boolean) TO partman_user;


--
-- Name: FUNCTION drop_partition_id(p_parent_table text, p_retention bigint, p_keep_table boolean, p_keep_index boolean, p_retention_schema text); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.drop_partition_id(p_parent_table text, p_retention bigint, p_keep_table boolean, p_keep_index boolean, p_retention_schema text) TO partman_user;


--
-- Name: FUNCTION drop_partition_time(p_parent_table text, p_retention interval, p_keep_table boolean, p_keep_index boolean, p_retention_schema text, p_reference_timestamp timestamp with time zone); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.drop_partition_time(p_parent_table text, p_retention interval, p_keep_table boolean, p_keep_index boolean, p_retention_schema text, p_reference_timestamp timestamp with time zone) TO partman_user;


--
-- Name: FUNCTION dump_partitioned_table_definition(p_parent_table text, p_ignore_template_table boolean); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.dump_partitioned_table_definition(p_parent_table text, p_ignore_template_table boolean) TO partman_user;


--
-- Name: FUNCTION inherit_replica_identity(p_parent_schemaname text, p_parent_tablename text, p_child_tablename text); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.inherit_replica_identity(p_parent_schemaname text, p_parent_tablename text, p_child_tablename text) TO partman_user;


--
-- Name: FUNCTION inherit_template_properties(p_parent_table text, p_child_schema text, p_child_tablename text); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.inherit_template_properties(p_parent_table text, p_child_schema text, p_child_tablename text) TO partman_user;


--
-- Name: PROCEDURE partition_data_async(IN p_parent_table text, IN p_loop_count integer, IN p_interval text, IN p_lock_wait integer, IN p_lock_wait_tries integer, IN p_wait integer, IN p_order text, IN p_ignored_columns text[], IN p_quiet boolean); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON PROCEDURE partman.partition_data_async(IN p_parent_table text, IN p_loop_count integer, IN p_interval text, IN p_lock_wait integer, IN p_lock_wait_tries integer, IN p_wait integer, IN p_order text, IN p_ignored_columns text[], IN p_quiet boolean) TO partman_user;


--
-- Name: FUNCTION partition_data_id(p_parent_table text, p_batch_count integer, p_batch_interval bigint, p_lock_wait numeric, p_order text, p_analyze boolean, p_source_table text, p_ignored_columns text[], p_override_system_value boolean); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.partition_data_id(p_parent_table text, p_batch_count integer, p_batch_interval bigint, p_lock_wait numeric, p_order text, p_analyze boolean, p_source_table text, p_ignored_columns text[], p_override_system_value boolean) TO partman_user;


--
-- Name: PROCEDURE partition_data_proc(IN p_parent_table text, IN p_loop_count integer, IN p_interval text, IN p_lock_wait integer, IN p_lock_wait_tries integer, IN p_wait integer, IN p_order text, IN p_source_table text, IN p_ignored_columns text[], IN p_quiet boolean, IN p_ignore_infinity boolean); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON PROCEDURE partman.partition_data_proc(IN p_parent_table text, IN p_loop_count integer, IN p_interval text, IN p_lock_wait integer, IN p_lock_wait_tries integer, IN p_wait integer, IN p_order text, IN p_source_table text, IN p_ignored_columns text[], IN p_quiet boolean, IN p_ignore_infinity boolean) TO partman_user;


--
-- Name: FUNCTION partition_data_time(p_parent_table text, p_batch_count integer, p_batch_interval interval, p_lock_wait numeric, p_order text, p_analyze boolean, p_source_table text, p_ignored_columns text[], p_override_system_value boolean, p_ignore_infinity boolean); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.partition_data_time(p_parent_table text, p_batch_count integer, p_batch_interval interval, p_lock_wait numeric, p_order text, p_analyze boolean, p_source_table text, p_ignored_columns text[], p_override_system_value boolean, p_ignore_infinity boolean) TO partman_user;


--
-- Name: FUNCTION partition_gap_fill(p_parent_table text); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.partition_gap_fill(p_parent_table text) TO partman_user;


--
-- Name: PROCEDURE reapply_constraints_proc(IN p_parent_table text, IN p_drop_constraints boolean, IN p_apply_constraints boolean, IN p_analyze boolean, IN p_wait integer, IN p_dryrun boolean); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON PROCEDURE partman.reapply_constraints_proc(IN p_parent_table text, IN p_drop_constraints boolean, IN p_apply_constraints boolean, IN p_analyze boolean, IN p_wait integer, IN p_dryrun boolean) TO partman_user;


--
-- Name: FUNCTION reapply_privileges(p_parent_table text); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.reapply_privileges(p_parent_table text) TO partman_user;


--
-- Name: PROCEDURE run_analyze(IN p_skip_locked boolean, IN p_quiet boolean, IN p_parent_table text); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON PROCEDURE partman.run_analyze(IN p_skip_locked boolean, IN p_quiet boolean, IN p_parent_table text) TO partman_user;


--
-- Name: FUNCTION run_maintenance(p_parent_table text, p_analyze boolean, p_jobmon boolean); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.run_maintenance(p_parent_table text, p_analyze boolean, p_jobmon boolean) TO partman_user;


--
-- Name: PROCEDURE run_maintenance_proc(IN p_wait integer, IN p_analyze boolean, IN p_jobmon boolean); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON PROCEDURE partman.run_maintenance_proc(IN p_wait integer, IN p_analyze boolean, IN p_jobmon boolean) TO partman_user;


--
-- Name: FUNCTION show_partition_info(p_child_table text, p_partition_interval text, p_parent_table text, p_table_exists boolean, OUT child_start_time timestamp with time zone, OUT child_end_time timestamp with time zone, OUT child_start_id bigint, OUT child_end_id bigint, OUT suffix text); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.show_partition_info(p_child_table text, p_partition_interval text, p_parent_table text, p_table_exists boolean, OUT child_start_time timestamp with time zone, OUT child_end_time timestamp with time zone, OUT child_start_id bigint, OUT child_end_id bigint, OUT suffix text) TO partman_user;


--
-- Name: FUNCTION show_partition_name(p_parent_table text, p_value text, OUT partition_schema text, OUT partition_table text, OUT suffix_timestamp timestamp with time zone, OUT suffix_id bigint, OUT table_exists boolean); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.show_partition_name(p_parent_table text, p_value text, OUT partition_schema text, OUT partition_table text, OUT suffix_timestamp timestamp with time zone, OUT suffix_id bigint, OUT table_exists boolean) TO partman_user;


--
-- Name: FUNCTION show_partitions(p_parent_table text, p_order text, p_include_default boolean); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.show_partitions(p_parent_table text, p_order text, p_include_default boolean) TO partman_user;


--
-- Name: FUNCTION stop_sub_partition(p_parent_table text, p_jobmon boolean); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.stop_sub_partition(p_parent_table text, p_jobmon boolean) TO partman_user;


--
-- Name: FUNCTION undo_partition(p_parent_table text, p_target_table text, p_loop_count integer, p_batch_interval text, p_keep_table boolean, p_lock_wait numeric, p_ignored_columns text[], p_drop_cascade boolean, OUT partitions_undone integer, OUT rows_undone bigint); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.undo_partition(p_parent_table text, p_target_table text, p_loop_count integer, p_batch_interval text, p_keep_table boolean, p_lock_wait numeric, p_ignored_columns text[], p_drop_cascade boolean, OUT partitions_undone integer, OUT rows_undone bigint) TO partman_user;


--
-- Name: PROCEDURE undo_partition_proc(IN p_parent_table text, IN p_target_table text, IN p_loop_count integer, IN p_interval text, IN p_keep_table boolean, IN p_lock_wait integer, IN p_lock_wait_tries integer, IN p_wait integer, IN p_ignored_columns text[], IN p_drop_cascade boolean, IN p_quiet boolean); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON PROCEDURE partman.undo_partition_proc(IN p_parent_table text, IN p_target_table text, IN p_loop_count integer, IN p_interval text, IN p_keep_table boolean, IN p_lock_wait integer, IN p_lock_wait_tries integer, IN p_wait integer, IN p_ignored_columns text[], IN p_drop_cascade boolean, IN p_quiet boolean) TO partman_user;


--
-- Name: FUNCTION uuid7_time_decoder(uuidv7 text); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.uuid7_time_decoder(uuidv7 text) TO partman_user;


--
-- Name: FUNCTION uuid7_time_encoder(ts timestamp with time zone); Type: ACL; Schema: partman; Owner: postgres
--

GRANT ALL ON FUNCTION partman.uuid7_time_encoder(ts timestamp with time zone) TO partman_user;


--
-- Name: TABLE audit_events; Type: ACL; Schema: audit; Owner: partman_user
--

GRANT INSERT ON TABLE audit.audit_events TO app;


--
-- Name: TABLE log_events; Type: ACL; Schema: audit; Owner: partman_user
--

GRANT INSERT ON TABLE audit.log_events TO app;


--
-- Name: TABLE part_config; Type: ACL; Schema: partman; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE partman.part_config TO partman_user;


--
-- Name: TABLE part_config_sub; Type: ACL; Schema: partman; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE partman.part_config_sub TO partman_user;


--
-- Name: TABLE table_privs; Type: ACL; Schema: partman; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE partman.table_privs TO partman_user;


--
-- Name: TABLE classroom_members; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.classroom_members TO app;
GRANT SELECT ON TABLE public.classroom_members TO jas;


--
-- Name: TABLE classrooms; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.classrooms TO app;
GRANT SELECT ON TABLE public.classrooms TO jas;


--
-- Name: TABLE elo_history; Type: ACL; Schema: public; Owner: partman_user
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.elo_history TO app;
GRANT SELECT ON TABLE public.elo_history TO jas;


--
-- Name: SEQUENCE elo_history_id_seq; Type: ACL; Schema: public; Owner: partman_user
--

GRANT SELECT,USAGE ON SEQUENCE public.elo_history_id_seq TO app;


--
-- Name: TABLE elo_history_default; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.elo_history_default TO app;
GRANT SELECT ON TABLE public.elo_history_default TO jas;


--
-- Name: TABLE elo_history_p20260415; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.elo_history_p20260415 TO app;
GRANT SELECT ON TABLE public.elo_history_p20260415 TO jas;


--
-- Name: TABLE elo_history_p20260422; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.elo_history_p20260422 TO app;
GRANT SELECT ON TABLE public.elo_history_p20260422 TO jas;


--
-- Name: TABLE elo_history_p20260429; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.elo_history_p20260429 TO app;
GRANT SELECT ON TABLE public.elo_history_p20260429 TO jas;


--
-- Name: TABLE elo_history_p20260506; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.elo_history_p20260506 TO app;
GRANT SELECT ON TABLE public.elo_history_p20260506 TO jas;


--
-- Name: TABLE elo_history_p20260513; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.elo_history_p20260513 TO app;
GRANT SELECT ON TABLE public.elo_history_p20260513 TO jas;


--
-- Name: TABLE elo_history_p20260520; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.elo_history_p20260520 TO app;
GRANT SELECT ON TABLE public.elo_history_p20260520 TO jas;


--
-- Name: TABLE elo_history_p20260527; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.elo_history_p20260527 TO app;
GRANT SELECT ON TABLE public.elo_history_p20260527 TO jas;


--
-- Name: TABLE game_sessions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.game_sessions TO app;
GRANT SELECT ON TABLE public.game_sessions TO jas;


--
-- Name: TABLE levels; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.levels TO app;
GRANT SELECT ON TABLE public.levels TO jas;


--
-- Name: SEQUENCE levels_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.levels_id_seq TO app;


--
-- Name: TABLE permissions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.permissions TO app;
GRANT SELECT ON TABLE public.permissions TO jas;


--
-- Name: SEQUENCE permissions_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.permissions_id_seq TO app;


--
-- Name: TABLE players; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.players TO app;
GRANT SELECT ON TABLE public.players TO jas;


--
-- Name: TABLE role_permissions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.role_permissions TO app;
GRANT SELECT ON TABLE public.role_permissions TO jas;


--
-- Name: TABLE roles; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.roles TO app;
GRANT SELECT ON TABLE public.roles TO jas;


--
-- Name: SEQUENCE roles_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.roles_id_seq TO app;


--
-- Name: TABLE session; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.session TO app;
GRANT SELECT ON TABLE public.session TO jas;


--
-- Name: TABLE session_answers; Type: ACL; Schema: public; Owner: partman_user
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.session_answers TO app;
GRANT SELECT ON TABLE public.session_answers TO jas;


--
-- Name: SEQUENCE session_answers_id_seq; Type: ACL; Schema: public; Owner: partman_user
--

GRANT SELECT,USAGE ON SEQUENCE public.session_answers_id_seq TO app;


--
-- Name: TABLE session_answers_default; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.session_answers_default TO app;
GRANT SELECT ON TABLE public.session_answers_default TO jas;


--
-- Name: TABLE session_answers_p20260415; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.session_answers_p20260415 TO app;
GRANT SELECT ON TABLE public.session_answers_p20260415 TO jas;


--
-- Name: TABLE session_answers_p20260422; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.session_answers_p20260422 TO app;
GRANT SELECT ON TABLE public.session_answers_p20260422 TO jas;


--
-- Name: TABLE session_answers_p20260429; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.session_answers_p20260429 TO app;
GRANT SELECT ON TABLE public.session_answers_p20260429 TO jas;


--
-- Name: TABLE session_answers_p20260506; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.session_answers_p20260506 TO app;
GRANT SELECT ON TABLE public.session_answers_p20260506 TO jas;


--
-- Name: TABLE session_answers_p20260513; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.session_answers_p20260513 TO app;
GRANT SELECT ON TABLE public.session_answers_p20260513 TO jas;


--
-- Name: TABLE session_answers_p20260520; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.session_answers_p20260520 TO app;
GRANT SELECT ON TABLE public.session_answers_p20260520 TO jas;


--
-- Name: TABLE session_answers_p20260527; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.session_answers_p20260527 TO app;
GRANT SELECT ON TABLE public.session_answers_p20260527 TO jas;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: audit; Owner: partman_user
--

ALTER DEFAULT PRIVILEGES FOR ROLE partman_user IN SCHEMA audit GRANT INSERT ON TABLES TO app;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,USAGE ON SEQUENCES TO app;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: partman_user
--

ALTER DEFAULT PRIVILEGES FOR ROLE partman_user IN SCHEMA public GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES TO app;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES TO app;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON TABLES TO jas;


--
-- PostgreSQL database dump complete
--

\unrestrict bLrcTANkptjFPMJNNBtmg0CLHxyvW7ocK0gViCDfrgC8bMBehwLkS0AYbq2JqVF

