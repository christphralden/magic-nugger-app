--
-- PostgreSQL database dump
--

\restrict 6wRlDUQge9QK1RVggxk3KkdZgBW5vu5ew79R2BIUtZVQWoq1fWHYU3z2HUfUUQD

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
-- Name: audit_events_p20260420; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.audit_events_p20260420 (
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


ALTER TABLE audit.audit_events_p20260420 OWNER TO postgres;

--
-- Name: audit_events_p20260427; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.audit_events_p20260427 (
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


ALTER TABLE audit.audit_events_p20260427 OWNER TO postgres;

--
-- Name: audit_events_p20260504; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.audit_events_p20260504 (
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


ALTER TABLE audit.audit_events_p20260504 OWNER TO postgres;

--
-- Name: audit_events_p20260511; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.audit_events_p20260511 (
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


ALTER TABLE audit.audit_events_p20260511 OWNER TO postgres;

--
-- Name: audit_events_p20260518; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.audit_events_p20260518 (
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


ALTER TABLE audit.audit_events_p20260518 OWNER TO postgres;

--
-- Name: audit_events_p20260525; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.audit_events_p20260525 (
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


ALTER TABLE audit.audit_events_p20260525 OWNER TO postgres;

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
-- Name: log_events; Type: TABLE; Schema: audit; Owner: partman_user
--

CREATE TABLE audit.log_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    event character varying(255) NOT NULL,
    level character varying(16) DEFAULT 'info'::character varying NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    description text,
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
    description text,
    CONSTRAINT log_events_level_check CHECK (((level)::text = ANY ((ARRAY['info'::character varying, 'warning'::character varying, 'error'::character varying, 'fatal'::character varying])::text[])))
);


ALTER TABLE audit.log_events_default OWNER TO postgres;

--
-- Name: log_events_p20260420; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.log_events_p20260420 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    event character varying(255) NOT NULL,
    level character varying(16) DEFAULT 'info'::character varying NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    description text,
    CONSTRAINT log_events_level_check CHECK (((level)::text = ANY ((ARRAY['info'::character varying, 'warning'::character varying, 'error'::character varying, 'fatal'::character varying])::text[])))
);


ALTER TABLE audit.log_events_p20260420 OWNER TO postgres;

--
-- Name: log_events_p20260427; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.log_events_p20260427 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    event character varying(255) NOT NULL,
    level character varying(16) DEFAULT 'info'::character varying NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    description text,
    CONSTRAINT log_events_level_check CHECK (((level)::text = ANY ((ARRAY['info'::character varying, 'warning'::character varying, 'error'::character varying, 'fatal'::character varying])::text[])))
);


ALTER TABLE audit.log_events_p20260427 OWNER TO postgres;

--
-- Name: log_events_p20260504; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.log_events_p20260504 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    event character varying(255) NOT NULL,
    level character varying(16) DEFAULT 'info'::character varying NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    description text,
    CONSTRAINT log_events_level_check CHECK (((level)::text = ANY ((ARRAY['info'::character varying, 'warning'::character varying, 'error'::character varying, 'fatal'::character varying])::text[])))
);


ALTER TABLE audit.log_events_p20260504 OWNER TO postgres;

--
-- Name: log_events_p20260511; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.log_events_p20260511 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    event character varying(255) NOT NULL,
    level character varying(16) DEFAULT 'info'::character varying NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    description text,
    CONSTRAINT log_events_level_check CHECK (((level)::text = ANY ((ARRAY['info'::character varying, 'warning'::character varying, 'error'::character varying, 'fatal'::character varying])::text[])))
);


ALTER TABLE audit.log_events_p20260511 OWNER TO postgres;

--
-- Name: log_events_p20260518; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.log_events_p20260518 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    event character varying(255) NOT NULL,
    level character varying(16) DEFAULT 'info'::character varying NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    description text,
    CONSTRAINT log_events_level_check CHECK (((level)::text = ANY ((ARRAY['info'::character varying, 'warning'::character varying, 'error'::character varying, 'fatal'::character varying])::text[])))
);


ALTER TABLE audit.log_events_p20260518 OWNER TO postgres;

--
-- Name: log_events_p20260525; Type: TABLE; Schema: audit; Owner: postgres
--

CREATE TABLE audit.log_events_p20260525 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    event character varying(255) NOT NULL,
    level character varying(16) DEFAULT 'info'::character varying NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    description text,
    CONSTRAINT log_events_level_check CHECK (((level)::text = ANY ((ARRAY['info'::character varying, 'warning'::character varying, 'error'::character varying, 'fatal'::character varying])::text[])))
);


ALTER TABLE audit.log_events_p20260525 OWNER TO postgres;

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
    description text,
    CONSTRAINT log_events_level_check CHECK (((level)::text = ANY ((ARRAY['info'::character varying, 'warning'::character varying, 'error'::character varying, 'fatal'::character varying])::text[])))
);


ALTER TABLE audit.log_events_p20260601 OWNER TO postgres;

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
    created_at timestamp with time zone NOT NULL,
    description text
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
    CONSTRAINT elo_history_reason_check CHECK (((reason)::text = ANY ((ARRAY['session_completed'::character varying, 'session_failed'::character varying, 'session_abandoned'::character varying, 'admin_adjustment'::character varying, 'decay'::character varying])::text[])))
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
    CONSTRAINT elo_history_reason_check CHECK (((reason)::text = ANY ((ARRAY['session_completed'::character varying, 'session_failed'::character varying, 'session_abandoned'::character varying, 'admin_adjustment'::character varying, 'decay'::character varying])::text[])))
);


ALTER TABLE public.elo_history_default OWNER TO postgres;

--
-- Name: elo_history_p20260420; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.elo_history_p20260420 (
    id bigint DEFAULT nextval('public.elo_history_id_seq'::regclass) NOT NULL,
    player_id uuid NOT NULL,
    session_id uuid,
    elo_before integer NOT NULL,
    elo_after integer NOT NULL,
    delta integer NOT NULL,
    reason character varying(32) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT elo_history_reason_check CHECK (((reason)::text = ANY ((ARRAY['session_completed'::character varying, 'session_failed'::character varying, 'session_abandoned'::character varying, 'admin_adjustment'::character varying, 'decay'::character varying])::text[])))
);


ALTER TABLE public.elo_history_p20260420 OWNER TO postgres;

--
-- Name: elo_history_p20260427; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.elo_history_p20260427 (
    id bigint DEFAULT nextval('public.elo_history_id_seq'::regclass) NOT NULL,
    player_id uuid NOT NULL,
    session_id uuid,
    elo_before integer NOT NULL,
    elo_after integer NOT NULL,
    delta integer NOT NULL,
    reason character varying(32) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT elo_history_reason_check CHECK (((reason)::text = ANY ((ARRAY['session_completed'::character varying, 'session_failed'::character varying, 'session_abandoned'::character varying, 'admin_adjustment'::character varying, 'decay'::character varying])::text[])))
);


ALTER TABLE public.elo_history_p20260427 OWNER TO postgres;

--
-- Name: elo_history_p20260504; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.elo_history_p20260504 (
    id bigint DEFAULT nextval('public.elo_history_id_seq'::regclass) NOT NULL,
    player_id uuid NOT NULL,
    session_id uuid,
    elo_before integer NOT NULL,
    elo_after integer NOT NULL,
    delta integer NOT NULL,
    reason character varying(32) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT elo_history_reason_check CHECK (((reason)::text = ANY ((ARRAY['session_completed'::character varying, 'session_failed'::character varying, 'session_abandoned'::character varying, 'admin_adjustment'::character varying, 'decay'::character varying])::text[])))
);


ALTER TABLE public.elo_history_p20260504 OWNER TO postgres;

--
-- Name: elo_history_p20260511; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.elo_history_p20260511 (
    id bigint DEFAULT nextval('public.elo_history_id_seq'::regclass) NOT NULL,
    player_id uuid NOT NULL,
    session_id uuid,
    elo_before integer NOT NULL,
    elo_after integer NOT NULL,
    delta integer NOT NULL,
    reason character varying(32) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT elo_history_reason_check CHECK (((reason)::text = ANY ((ARRAY['session_completed'::character varying, 'session_failed'::character varying, 'session_abandoned'::character varying, 'admin_adjustment'::character varying, 'decay'::character varying])::text[])))
);


ALTER TABLE public.elo_history_p20260511 OWNER TO postgres;

--
-- Name: elo_history_p20260518; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.elo_history_p20260518 (
    id bigint DEFAULT nextval('public.elo_history_id_seq'::regclass) NOT NULL,
    player_id uuid NOT NULL,
    session_id uuid,
    elo_before integer NOT NULL,
    elo_after integer NOT NULL,
    delta integer NOT NULL,
    reason character varying(32) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT elo_history_reason_check CHECK (((reason)::text = ANY ((ARRAY['session_completed'::character varying, 'session_failed'::character varying, 'session_abandoned'::character varying, 'admin_adjustment'::character varying, 'decay'::character varying])::text[])))
);


ALTER TABLE public.elo_history_p20260518 OWNER TO postgres;

--
-- Name: elo_history_p20260525; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.elo_history_p20260525 (
    id bigint DEFAULT nextval('public.elo_history_id_seq'::regclass) NOT NULL,
    player_id uuid NOT NULL,
    session_id uuid,
    elo_before integer NOT NULL,
    elo_after integer NOT NULL,
    delta integer NOT NULL,
    reason character varying(32) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT elo_history_reason_check CHECK (((reason)::text = ANY ((ARRAY['session_completed'::character varying, 'session_failed'::character varying, 'session_abandoned'::character varying, 'admin_adjustment'::character varying, 'decay'::character varying])::text[])))
);


ALTER TABLE public.elo_history_p20260525 OWNER TO postgres;

--
-- Name: elo_history_p20260601; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.elo_history_p20260601 (
    id bigint DEFAULT nextval('public.elo_history_id_seq'::regclass) NOT NULL,
    player_id uuid NOT NULL,
    session_id uuid,
    elo_before integer NOT NULL,
    elo_after integer NOT NULL,
    delta integer NOT NULL,
    reason character varying(32) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT elo_history_reason_check CHECK (((reason)::text = ANY ((ARRAY['session_completed'::character varying, 'session_failed'::character varying, 'session_abandoned'::character varying, 'admin_adjustment'::character varying, 'decay'::character varying])::text[])))
);


ALTER TABLE public.elo_history_p20260601 OWNER TO postgres;

--
-- Name: game_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.game_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    player_id uuid NOT NULL,
    level_id integer NOT NULL,
    status character varying(16) DEFAULT 'in_progress'::character varying NOT NULL,
    score integer DEFAULT 0 NOT NULL,
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
    child_levels text[],
    elo_min integer DEFAULT 0 NOT NULL,
    elo_gain_correct integer DEFAULT 15 NOT NULL,
    elo_loss_incorrect integer DEFAULT 5 NOT NULL,
    time_limit_seconds integer,
    enemy_wave_config jsonb DEFAULT '{}'::jsonb NOT NULL,
    question_gen_config jsonb DEFAULT '{}'::jsonb NOT NULL,
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
-- Name: levels_unlocked; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.levels_unlocked (
    player_id uuid NOT NULL,
    level_id integer NOT NULL,
    unlocked_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.levels_unlocked OWNER TO postgres;

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
    total_questions_answered integer DEFAULT 0 NOT NULL,
    total_correct integer DEFAULT 0 NOT NULL,
    total_incorrect integer DEFAULT 0 NOT NULL,
    longest_streak integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_active_at timestamp with time zone,
    age smallint,
    grade smallint,
    guardian_email character varying(255),
    CONSTRAINT oauth_or_password CHECK ((((oauth_provider IS NOT NULL) AND (oauth_id IS NOT NULL)) OR (password_hash IS NOT NULL))),
    CONSTRAINT players_age_check CHECK ((age > 0)),
    CONSTRAINT players_grade_check CHECK ((grade > 0))
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
-- Name: session_answers_p20260420; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session_answers_p20260420 (
    id bigint DEFAULT nextval('public.session_answers_id_seq'::regclass) NOT NULL,
    session_id uuid NOT NULL,
    is_correct boolean NOT NULL,
    elo_delta integer NOT NULL,
    time_taken_ms integer,
    answered_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.session_answers_p20260420 OWNER TO postgres;

--
-- Name: session_answers_p20260427; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session_answers_p20260427 (
    id bigint DEFAULT nextval('public.session_answers_id_seq'::regclass) NOT NULL,
    session_id uuid NOT NULL,
    is_correct boolean NOT NULL,
    elo_delta integer NOT NULL,
    time_taken_ms integer,
    answered_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.session_answers_p20260427 OWNER TO postgres;

--
-- Name: session_answers_p20260504; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session_answers_p20260504 (
    id bigint DEFAULT nextval('public.session_answers_id_seq'::regclass) NOT NULL,
    session_id uuid NOT NULL,
    is_correct boolean NOT NULL,
    elo_delta integer NOT NULL,
    time_taken_ms integer,
    answered_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.session_answers_p20260504 OWNER TO postgres;

--
-- Name: session_answers_p20260511; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session_answers_p20260511 (
    id bigint DEFAULT nextval('public.session_answers_id_seq'::regclass) NOT NULL,
    session_id uuid NOT NULL,
    is_correct boolean NOT NULL,
    elo_delta integer NOT NULL,
    time_taken_ms integer,
    answered_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.session_answers_p20260511 OWNER TO postgres;

--
-- Name: session_answers_p20260518; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session_answers_p20260518 (
    id bigint DEFAULT nextval('public.session_answers_id_seq'::regclass) NOT NULL,
    session_id uuid NOT NULL,
    is_correct boolean NOT NULL,
    elo_delta integer NOT NULL,
    time_taken_ms integer,
    answered_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.session_answers_p20260518 OWNER TO postgres;

--
-- Name: session_answers_p20260525; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session_answers_p20260525 (
    id bigint DEFAULT nextval('public.session_answers_id_seq'::regclass) NOT NULL,
    session_id uuid NOT NULL,
    is_correct boolean NOT NULL,
    elo_delta integer NOT NULL,
    time_taken_ms integer,
    answered_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.session_answers_p20260525 OWNER TO postgres;

--
-- Name: session_answers_p20260601; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session_answers_p20260601 (
    id bigint DEFAULT nextval('public.session_answers_id_seq'::regclass) NOT NULL,
    session_id uuid NOT NULL,
    is_correct boolean NOT NULL,
    elo_delta integer NOT NULL,
    time_taken_ms integer,
    answered_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.session_answers_p20260601 OWNER TO postgres;

--
-- Name: audit_events_default; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events ATTACH PARTITION audit.audit_events_default DEFAULT;


--
-- Name: audit_events_p20260420; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events ATTACH PARTITION audit.audit_events_p20260420 FOR VALUES FROM ('2026-04-20 00:00:00+00') TO ('2026-04-27 00:00:00+00');


--
-- Name: audit_events_p20260427; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events ATTACH PARTITION audit.audit_events_p20260427 FOR VALUES FROM ('2026-04-27 00:00:00+00') TO ('2026-05-04 00:00:00+00');


--
-- Name: audit_events_p20260504; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events ATTACH PARTITION audit.audit_events_p20260504 FOR VALUES FROM ('2026-05-04 00:00:00+00') TO ('2026-05-11 00:00:00+00');


--
-- Name: audit_events_p20260511; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events ATTACH PARTITION audit.audit_events_p20260511 FOR VALUES FROM ('2026-05-11 00:00:00+00') TO ('2026-05-18 00:00:00+00');


--
-- Name: audit_events_p20260518; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events ATTACH PARTITION audit.audit_events_p20260518 FOR VALUES FROM ('2026-05-18 00:00:00+00') TO ('2026-05-25 00:00:00+00');


--
-- Name: audit_events_p20260525; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events ATTACH PARTITION audit.audit_events_p20260525 FOR VALUES FROM ('2026-05-25 00:00:00+00') TO ('2026-06-01 00:00:00+00');


--
-- Name: audit_events_p20260601; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events ATTACH PARTITION audit.audit_events_p20260601 FOR VALUES FROM ('2026-06-01 00:00:00+00') TO ('2026-06-08 00:00:00+00');


--
-- Name: log_events_default; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events ATTACH PARTITION audit.log_events_default DEFAULT;


--
-- Name: log_events_p20260420; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events ATTACH PARTITION audit.log_events_p20260420 FOR VALUES FROM ('2026-04-20 00:00:00+00') TO ('2026-04-27 00:00:00+00');


--
-- Name: log_events_p20260427; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events ATTACH PARTITION audit.log_events_p20260427 FOR VALUES FROM ('2026-04-27 00:00:00+00') TO ('2026-05-04 00:00:00+00');


--
-- Name: log_events_p20260504; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events ATTACH PARTITION audit.log_events_p20260504 FOR VALUES FROM ('2026-05-04 00:00:00+00') TO ('2026-05-11 00:00:00+00');


--
-- Name: log_events_p20260511; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events ATTACH PARTITION audit.log_events_p20260511 FOR VALUES FROM ('2026-05-11 00:00:00+00') TO ('2026-05-18 00:00:00+00');


--
-- Name: log_events_p20260518; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events ATTACH PARTITION audit.log_events_p20260518 FOR VALUES FROM ('2026-05-18 00:00:00+00') TO ('2026-05-25 00:00:00+00');


--
-- Name: log_events_p20260525; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events ATTACH PARTITION audit.log_events_p20260525 FOR VALUES FROM ('2026-05-25 00:00:00+00') TO ('2026-06-01 00:00:00+00');


--
-- Name: log_events_p20260601; Type: TABLE ATTACH; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events ATTACH PARTITION audit.log_events_p20260601 FOR VALUES FROM ('2026-06-01 00:00:00+00') TO ('2026-06-08 00:00:00+00');


--
-- Name: elo_history_default; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history ATTACH PARTITION public.elo_history_default DEFAULT;


--
-- Name: elo_history_p20260420; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history ATTACH PARTITION public.elo_history_p20260420 FOR VALUES FROM ('2026-04-20 00:00:00+00') TO ('2026-04-27 00:00:00+00');


--
-- Name: elo_history_p20260427; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history ATTACH PARTITION public.elo_history_p20260427 FOR VALUES FROM ('2026-04-27 00:00:00+00') TO ('2026-05-04 00:00:00+00');


--
-- Name: elo_history_p20260504; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history ATTACH PARTITION public.elo_history_p20260504 FOR VALUES FROM ('2026-05-04 00:00:00+00') TO ('2026-05-11 00:00:00+00');


--
-- Name: elo_history_p20260511; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history ATTACH PARTITION public.elo_history_p20260511 FOR VALUES FROM ('2026-05-11 00:00:00+00') TO ('2026-05-18 00:00:00+00');


--
-- Name: elo_history_p20260518; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history ATTACH PARTITION public.elo_history_p20260518 FOR VALUES FROM ('2026-05-18 00:00:00+00') TO ('2026-05-25 00:00:00+00');


--
-- Name: elo_history_p20260525; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history ATTACH PARTITION public.elo_history_p20260525 FOR VALUES FROM ('2026-05-25 00:00:00+00') TO ('2026-06-01 00:00:00+00');


--
-- Name: elo_history_p20260601; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history ATTACH PARTITION public.elo_history_p20260601 FOR VALUES FROM ('2026-06-01 00:00:00+00') TO ('2026-06-08 00:00:00+00');


--
-- Name: session_answers_default; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers ATTACH PARTITION public.session_answers_default DEFAULT;


--
-- Name: session_answers_p20260420; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers ATTACH PARTITION public.session_answers_p20260420 FOR VALUES FROM ('2026-04-20 00:00:00+00') TO ('2026-04-27 00:00:00+00');


--
-- Name: session_answers_p20260427; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers ATTACH PARTITION public.session_answers_p20260427 FOR VALUES FROM ('2026-04-27 00:00:00+00') TO ('2026-05-04 00:00:00+00');


--
-- Name: session_answers_p20260504; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers ATTACH PARTITION public.session_answers_p20260504 FOR VALUES FROM ('2026-05-04 00:00:00+00') TO ('2026-05-11 00:00:00+00');


--
-- Name: session_answers_p20260511; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers ATTACH PARTITION public.session_answers_p20260511 FOR VALUES FROM ('2026-05-11 00:00:00+00') TO ('2026-05-18 00:00:00+00');


--
-- Name: session_answers_p20260518; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers ATTACH PARTITION public.session_answers_p20260518 FOR VALUES FROM ('2026-05-18 00:00:00+00') TO ('2026-05-25 00:00:00+00');


--
-- Name: session_answers_p20260525; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers ATTACH PARTITION public.session_answers_p20260525 FOR VALUES FROM ('2026-05-25 00:00:00+00') TO ('2026-06-01 00:00:00+00');


--
-- Name: session_answers_p20260601; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers ATTACH PARTITION public.session_answers_p20260601 FOR VALUES FROM ('2026-06-01 00:00:00+00') TO ('2026-06-08 00:00:00+00');


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
1	202605020000_patch_infrastructure	\N	Patch tracking infrastructure	2026-05-11 16:11:19.944278+00
2	202605020001_create_permissions	{202605020000_patch_infrastructure}	Create permissions table	2026-05-11 16:11:19.966971+00
3	202605020002_create_roles	{202605020000_patch_infrastructure}	Create roles table	2026-05-11 16:11:19.974437+00
4	202605020003_create_role_permissions	{202605020001_create_permissions,202605020002_create_roles}	Create role_permissions join table and seed	2026-05-11 16:11:19.981968+00
5	202605020004_create_players	{202605020002_create_roles}	Create players table	2026-05-11 16:11:19.989347+00
6	202605020005_create_levels	{202605020000_patch_infrastructure}	Create levels table	2026-05-11 16:11:20.002598+00
7	202605020006_create_classrooms	{202605020004_create_players}	Create classrooms table	2026-05-11 16:11:20.009526+00
8	202605020007_create_classroom_members	{202605020006_create_classrooms,202605020004_create_players}	Create classroom_members table	2026-05-11 16:11:20.019052+00
9	202605020008_create_game_sessions	{202605020004_create_players,202605020005_create_levels}	Create game_sessions table	2026-05-11 16:11:20.025086+00
10	202605020009_create_session_answers	{202605020008_create_game_sessions}	Create session_answers table	2026-05-11 16:11:20.034515+00
11	202605020010_create_elo_history	{202605020004_create_players,202605020008_create_game_sessions}	Create elo_history table	2026-05-11 16:11:20.040252+00
12	202605020011_create_pg_session	\N	Create connect-pg-simple session store table	2026-05-11 16:11:20.046374+00
13	202605020012_create_pg_partman	\N	Create partman schema and install pg_partman extension	2026-05-11 16:11:20.05224+00
14	202605020013_create_audit_events	{202605020012_create_pg_partman,202605020004_create_players}	Create audit schema and partitioned audit events table	2026-05-11 16:11:20.089516+00
15	202605060001_update_audit_events_http_method	{202605020013_create_audit_events}	Update audit schema to capture http method	2026-05-11 16:11:20.191512+00
16	202605070001_create_log_events	{202605020012_create_pg_partman,202605020013_create_audit_events}	Create log schema and partitioned log events table	2026-05-11 16:11:20.196492+00
17	202605070002_create_admin_indexes	{202605020004_create_players,202605020008_create_game_sessions}	Add indexes for admin pagination queries on players and game_sessions	2026-05-11 16:11:20.284206+00
18	202605070003_update_audit_partition_interval	{202605020013_create_audit_events}	Update audit partition interval from 1 month to 1 week	2026-05-11 16:11:20.291588+00
19	202605080001_partition_session_answers	{202605020009_create_session_answers,202605020012_create_pg_partman}	Recreate session_answers as weekly partitioned table	2026-05-11 16:11:20.321379+00
20	202605080002_partition_elo_history	{202605020010_create_elo_history,202605020012_create_pg_partman}	Recreate elo_history as weekly partitioned table	2026-05-11 16:11:20.370786+00
21	202605080003_update_log_events_description	{202605070001_create_log_events,202605020013_create_audit_events}	Update log schema to have description	2026-05-11 16:11:20.430724+00
22	202605090001_add_session_abandoned_reason	{202605080002_partition_elo_history}	Add session_abandoned to elo_history reason enum	2026-05-11 16:11:20.435494+00
23	202605110001_add_player_profile_fields	{202605020004_create_players}	Add age, grade, guardian_email to players	2026-05-11 16:11:20.4414+00
24	202605110002_create_levels_unlocked	{202605020004_create_players,202605020005_create_levels}	Create levels_unlocked pivot table	2026-05-11 16:11:20.444943+00
25	202605110003_drop_levels_max_score	{202605020005_create_levels}	Drop max_score column from levels	2026-05-11 16:11:20.452406+00
26	202605120001_drop_game_sessions_max_answers	{202605020008_create_game_sessions}	Drop max_answers column from game_sessions	2026-05-11 16:11:20.454856+00
\.


--
-- Data for Name: audit_events_default; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.audit_events_default (id, user_id, url, status_code, ip_address, user_agent, metadata, created_at, http_method) FROM stdin;
\.


--
-- Data for Name: audit_events_p20260420; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.audit_events_p20260420 (id, user_id, url, status_code, ip_address, user_agent, metadata, created_at, http_method) FROM stdin;
\.


--
-- Data for Name: audit_events_p20260427; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.audit_events_p20260427 (id, user_id, url, status_code, ip_address, user_agent, metadata, created_at, http_method) FROM stdin;
\.


--
-- Data for Name: audit_events_p20260504; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.audit_events_p20260504 (id, user_id, url, status_code, ip_address, user_agent, metadata, created_at, http_method) FROM stdin;
\.


--
-- Data for Name: audit_events_p20260511; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.audit_events_p20260511 (id, user_id, url, status_code, ip_address, user_agent, metadata, created_at, http_method) FROM stdin;
fbf3890c-668a-4500-bdff-acf50a755511	\N	/v1/auth/me	401	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:11:47.633033+00	GET
aa845a09-9f1c-4473-96be-c9e3091a906e	\N	/v1/auth/login	401	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{"email": "alden@gmail.com", "password": "<REDACTED>"}	2026-05-11 16:12:23.78314+00	POST
70a52c87-947c-4542-a7d6-bd083079f3da	\N	/v1/auth/login	401	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{"email": "alden@gmail.com", "password": "<REDACTED>"}	2026-05-11 16:12:25.007741+00	POST
6373dbe2-6e8a-4ae4-ae00-7479cb64f56f	\N	/v1/auth/login	401	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{"email": "alden@gmail.com", "password": "<REDACTED>"}	2026-05-11 16:12:25.967766+00	POST
94eb25d0-98da-46b9-96db-e9b0d8687390	\N	/v1/auth/login	401	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{"email": "alden@gmail.com", "password": "<REDACTED>"}	2026-05-11 16:12:26.952025+00	POST
8ea72c58-028a-4af1-b3c5-e67cb90c3802	\N	/v1/auth/register	201	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:12:44.480065+00	POST
b1bfa79b-40a5-485c-9d1b-458d43dfe716	\N	/v1/auth/me	401	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:13:56.602603+00	GET
e640e1a7-0805-4034-8740-88ce611a0060	\N	/v1/auth/login	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:14:09.204244+00	POST
09f2663c-80fe-4dca-823f-e7e4273fdde3	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	204	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:14:16.374901+00	GET
7d6ce5ed-c63a-491d-b1d7-eb74056e041c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/unlocked	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:14:16.375795+00	GET
eaf5283e-eda0-4fb9-9cac-59246bdf7a4c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:14:17.85881+00	GET
46635424-31e4-40d8-9eda-baf644e35cbd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/logout	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:14:29.506514+00	POST
2abeb288-6400-415c-b1bd-dff700675e72	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/logout	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:14:29.506662+00	POST
bb58eb16-ce54-4385-bbb7-68d2ac4e6104	\N	/v1/auth/me	401	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:14:36.531774+00	GET
8b3dc74a-60d0-4da7-8385-863baf9cee3b	\N	/v1/auth/login	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:14:46.324571+00	POST
a47e6e84-4fe3-4495-828b-a4b71fff052f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/logout	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:14:51.820705+00	POST
32e1aeeb-e1a6-4c4a-8621-a511fa7cdbe4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/logout	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:14:51.821343+00	POST
3eb3a9a9-d4df-46c3-9d2d-21d456ade4f0	\N	/v1/auth/me	401	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:15:40.566293+00	GET
0a2ca5c3-b988-4a0e-a126-79e548de1a73	\N	/v1/auth/login	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:15:48.34816+00	POST
8970a82f-abdc-478e-a9df-a07716529b02	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:15:54.279482+00	GET
22c21306-483a-45da-9992-47ec7eb7bbd7	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/unlocked	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:15:57.100574+00	GET
65a7ac8a-7c6a-411d-83d7-e3974072843d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	204	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:15:57.100556+00	GET
9b49d785-d8fd-483d-b456-47f9dd6ddee3	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:15:57.694694+00	GET
5ec1bebe-e88b-4700-aaf1-20552f383f98	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:16:01.225931+00	GET
865ac490-a47f-4bd5-8e2a-a3dbcd09e168	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:16:04.656617+00	GET
bb48bf0c-9e4f-4d9e-bb24-1e45861d057b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:16:12.19455+00	GET
4fdb722e-b798-448a-ade3-152b66b4261c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:16:12.812642+00	GET
0921a0c5-3bd1-4627-97b6-c154da61597d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:16:13.590628+00	GET
ed835d71-7761-4d20-8c1a-7bcf7d738f3d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:16:16.451068+00	GET
d897345e-f455-4d84-910e-d6a5306cb89a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:18:00.600162+00	GET
b31ebad0-502f-44fe-9503-7a37ca4b8ffd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:18:09.194438+00	GET
7ca31639-0e3a-4469-a5da-14e90a4a7f25	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:18:11.100973+00	GET
3ba52d3c-52b6-42e4-b811-ea559f2f33fb	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	204	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:18:55.875937+00	GET
afe9382d-e2eb-42a8-9b89-f6052bdefa25	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/unlocked	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:18:55.877201+00	GET
c9e2cd4b-e3b3-4cde-a4dc-dadeb420395a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:18:55.877613+00	GET
0f991a3f-07ca-49f4-96ae-28f5c8b2606e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:18:57.188068+00	GET
83dc9e6f-e60d-48fa-8986-9bb16d9e1b49	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:18:58.454891+00	GET
9906f5c5-43cc-46f0-a8c0-8c748488b535	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:18:59.786686+00	GET
53fd8d3b-2104-4263-9bb5-22cb1e5a58ef	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:19:01.930167+00	GET
4757fc81-2d4a-4433-9352-5ef87b3edc26	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	204	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:19:03.339404+00	GET
9d4631ce-2017-4ad2-bb48-a82c899d94b2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:18:57.189098+00	GET
eede235a-5762-4295-bf01-62059d2a4840	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:18:59.010979+00	GET
b5f81e82-2d2e-4cf4-aba4-fb3f03240df5	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:19:00.413339+00	GET
e56affd3-eb39-417e-9fb1-098f54355c22	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	204	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:19:01.08555+00	GET
f42fa2c6-f8f8-457c-b779-d5b73d356f4e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	204	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:20:34.652966+00	GET
d7cf1983-7762-4218-b283-79e618a44b37	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:20:35.70201+00	GET
debd20ff-1caf-4f4d-8253-b151ce0398ab	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	204	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:20:36.410811+00	GET
c8c9f4af-6a72-4739-9f79-eb40e203ae71	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:21:07.484105+00	GET
7a5d7368-a203-4c6a-ae65-0843e145bcfe	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	204	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:21:08.056435+00	GET
51f6c040-9ba9-4389-b58a-46c257baaa90	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	204	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:21:10.494708+00	GET
99bd01f3-93e8-4582-a592-bb4bd95f1ac8	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:21:11.193715+00	GET
c6c33689-426d-40c7-9f23-8a2082937d5a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:21:11.802377+00	GET
0ae2b701-0602-4a40-8fb3-877c4a9a66af	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:21:12.361499+00	GET
5dc1656a-8a70-4f09-95c7-3d10db21557e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:21:12.371436+00	GET
063c77b5-39f4-4482-8f8d-7caab8eae86e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:21:12.988052+00	GET
6e56d3c7-d80f-47da-ac26-ea345f8d9dad	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:27:05.511429+00	GET
361c8532-9820-4fcf-ada6-656b3051d3af	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:30:02.56603+00	GET
d44974b5-c1c1-4eee-a9f9-7c575bfe5451	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:30:02.57344+00	GET
48779320-c33b-4c23-979f-5265043ef45b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:30:04.541226+00	GET
0788ac12-2af2-4dc4-b4ef-cf51ccd9833f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:30:05.133633+00	GET
3a0b69c1-ad63-40d8-885f-e80347ff7bfa	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	204	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:30:05.790939+00	GET
6b489829-31b4-43d1-b179-b3375cec9be0	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:32:21.771921+00	GET
af7ab3be-c158-49b9-aa0d-86a3a4219811	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:32:22.626329+00	GET
28fb62b3-a4e9-49c9-ac62-d851ed7cf14d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:32:23.358823+00	GET
adbd6033-608e-4ff0-8677-cef7d7c7eee5	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:32:23.369606+00	GET
5231e704-2dbf-4f68-8786-25fcc0f66090	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:32:24.399861+00	GET
1cd35738-7114-42c6-a4ba-14d0b7fc1779	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	204	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:32:24.881012+00	GET
ad9be217-ee16-4a59-9bfb-4c0d2ee893f4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	204	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:32:26.304915+00	GET
6bc9d5d3-5cd9-4686-bdc5-90de0a74e7c8	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	204	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:32:31.700298+00	GET
07cad2ed-912d-4314-924d-b953613acdd3	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:32:33.114836+00	GET
f37b2599-02e5-47d1-86e8-2a7ef498e285	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:32:33.572439+00	GET
a4a5ae58-b16e-41ba-9957-c8b9ee9fa6c6	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:32:34.627657+00	GET
60ebb324-ffb6-4d27-a9ce-4dad65dc426e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:32:34.628498+00	GET
4529786a-8454-4df4-9da7-2cccfdaec0df	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	204	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:32:35.840301+00	GET
69c5f63f-becf-4bbb-9c42-e69df6a25fec	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	204	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:32:36.331322+00	GET
22a377a7-7983-43c2-8c71-e3eef9878abf	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	204	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-11 16:32:37.80092+00	GET
a13dce75-267c-4a33-af82-a65899925c12	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:07:22.799342+00	GET
e42a7a0e-91ed-4b7b-be12-5f02a0341fbf	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	204	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:07:24.244565+00	GET
c58c598b-1af5-4604-9d96-b785f88c0e32	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:07:24.261604+00	GET
5c5b4da2-76b2-4015-a4a4-b19a5560382b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:07:25.812156+00	GET
014aef67-01b1-4e32-929e-fef5d5182fde	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:07:25.823303+00	GET
5f00485d-a080-4e7f-b8a4-b2cfb101cfa2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:07:27.26194+00	GET
41deda67-347c-4bec-ab29-48c3f2c60f88	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:07:27.963231+00	GET
cba546a0-ed76-4150-b65d-ee98349038c1	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	204	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:07:28.782975+00	GET
191ace91-ae53-4fe8-82fc-be017cbc4bb7	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	204	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:07:29.579078+00	GET
926ed36c-a308-4b7f-a333-148175165480	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	204	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:07:30.913708+00	GET
37c4487b-d5a3-47cb-8e57-43d7ca98577f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:07:31.632143+00	GET
b7ff5120-40ee-4ba1-91dd-6a4a595aceb4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:07:32.686654+00	GET
0ea226b6-7918-4bcf-987d-610a98c434a7	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:07:33.509037+00	GET
44ea1f3c-c42d-41f6-8fb5-e4cb440f4fe0	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:07:33.509096+00	GET
336f4069-6238-42b0-81fb-ea3947df2bcb	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:07:53.314082+00	GET
1cc647a7-8efa-4a49-91af-f674162340f4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/unlocked	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:07:55.200728+00	GET
e40b6775-cddf-463a-854b-92e99c60634f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:08:01.88103+00	GET
6fec9ed8-f223-4ebe-aeb1-8337a4a43467	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:08:04.007484+00	GET
8f0f9a0f-57d3-4a73-82f6-1e741dfb2ad4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:08:04.038946+00	GET
5cfc9007-fb90-492e-8732-caf37aff05aa	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:08:05.250666+00	GET
362c5051-4dcc-4e97-8ea5-4ad1a03ceacc	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:08:06.751899+00	GET
3ae467a5-655b-4b6a-a3d0-faf05033c896	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:08:06.754922+00	GET
d6bdc492-1814-4346-b0c9-c83ac3dc22ad	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:08:08.07285+00	GET
70ae0214-ee5b-4480-813b-b1bbab6a3e0f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:08:08.965718+00	GET
9b832c90-3cd3-4ac4-bd1d-4fceab9bcd85	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:08:09.974449+00	GET
8dab43ce-3a8a-46c6-a823-180af46553d1	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:08:09.974691+00	GET
5fda3e0c-1419-445a-93d9-ac5b68a4d6f6	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:08:10.586537+00	GET
904092e2-40ad-4a34-98cb-4dc6802dbf0a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	204	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:08:11.189468+00	GET
3adbcdb4-3f40-4a0d-b454-abcf165e7d66	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	204	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:08:11.836788+00	GET
7fae069f-7409-4e59-a0d9-5329e964bbd5	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	204	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:08:13.362909+00	GET
95f97d6c-a365-44f2-b25e-765217ff7ca1	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	201	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:10:30.597431+00	POST
ff820121-20f2-4f9a-a778-64010ec98962	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:10:30.623003+00	GET
499ac4cb-38f7-40be-864d-02d142e31f97	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:11:18.770207+00	GET
ac5f125a-bdd7-4bec-ab25-c40e231f6c6c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:11:44.813143+00	GET
c6e2d98d-9700-4334-bbd7-3ed86e90764d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:11:58.603059+00	GET
98ddb5f6-8f04-47eb-9133-d73c20e8d4b6	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:12:10.611926+00	GET
10f9bd9e-90e8-49c8-ba54-f1e0db59c8bf	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/active/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:12:20.666783+00	PUT
5227ec5d-d5c6-4684-bb73-13d41e87f7f1	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/active/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:12:22.319747+00	PUT
8fbe25b3-b247-484d-8e0b-b39f813ee5f1	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/active/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:12:25.233241+00	PUT
f9b8d0a8-7e87-4ec3-b145-6502749b109b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/active/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:12:33.562992+00	PUT
fc5e58d5-c7dc-4d88-8168-ed851a85b35d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:12:35.770171+00	GET
ffcb366f-c9e7-487b-b1dd-920ef0ea4bdd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:12:38.560198+00	GET
873c6a6b-4980-4f95-96fb-5e4081bd355d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:12:38.936218+00	GET
c2c2c6cf-4a1c-4522-a64a-5282e914f298	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:12:40.666804+00	GET
8705a9c3-0b68-4764-af8e-d720f1eb2352	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:13:18.047364+00	GET
ac64e578-d6ea-4779-9a8f-abddfbd8e9e1	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:13:21.387979+00	GET
7a0a429b-5cd4-48fa-98c2-d343dbb5b073	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:13:28.465885+00	GET
680bc6eb-e501-4f15-8cb3-6ccc1a914cb3	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:13:38.857809+00	GET
dca66697-2638-4101-97bf-fceca63b53bc	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:15:49.337418+00	GET
753f971b-e763-47fa-9b42-31a79fba3dd0	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:15:55.164494+00	GET
790a47e1-056d-4f42-91bb-ced6c2e40c80	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:16:08.735426+00	GET
77759454-686f-49df-863e-940c85c5304f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:16:08.846926+00	GET
a49a743c-ca7f-4c1b-9d59-93c31cf53948	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:16:17.637254+00	GET
63b23421-2593-41af-a0d0-91ef8a646ff4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:16:19.594909+00	GET
e802335d-2fcd-4e71-ab19-923f7f3bc2cd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/cache/clear	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:16:23.193662+00	DELETE
84cff734-f5b2-4de0-873b-4c53648def08	\N	/v1/internal/memory	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:16:28.26914+00	POST
6b73d6d1-0f96-4275-88f3-c1ffce929335	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:16:33.341892+00	GET
8420cd22-8483-4b34-9a60-9bc66fed5d4d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:16:33.974387+00	GET
d5042f51-d23f-41b9-931e-948ee27b5015	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:16:35.724991+00	GET
46584d62-8d96-4438-a018-b330f8c1c903	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:16:38.491662+00	GET
9e182f49-9388-4106-88fe-22549a01dd1b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:16:39.67688+00	GET
1178c4c1-0157-4682-b6ba-7defd92af2ab	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:16:39.689309+00	GET
7434dee1-b4e0-452b-a2c9-c2e224031e24	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:16:40.863217+00	GET
f08ea619-aa21-4d0c-8826-3fc86a1ce4ef	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:16:41.659385+00	GET
152a2fc7-a3cf-49b2-9936-42350af46b02	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:16:51.67529+00	GET
5f5818e9-2546-4f51-b27a-590330289683	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:16:42.291619+00	GET
84f18ad2-0c6f-47dd-9b92-b55ffd2e808a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:16:42.973305+00	GET
da017adc-7e22-4383-80ea-d263206a3cf3	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:16:43.847591+00	GET
7b97fed7-1e36-48b5-845b-3753950995bd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:16:42.973767+00	GET
52eaa9bb-dac7-4311-8885-1fcf6e1da824	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:16:44.789351+00	GET
4c301c60-6cd3-4cf3-a7b0-d87ed8cd8188	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:16:51.67488+00	GET
ab16b0ac-2f3e-4e8a-820b-9f71ea54d3b8	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:17:25.077967+00	GET
a97e45dc-4f86-429c-abae-7bf3fe6b932f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:17:25.086954+00	GET
907fc05a-0882-498e-9823-e3399165c889	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:17:48.877734+00	GET
b5b16b2b-0e6b-4caf-8a61-db91bd4ae07e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:17:48.880675+00	GET
6660541d-bca9-49a6-a110-cbf0c6d35ade	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:18:06.625931+00	GET
fe03d7c4-e36b-4999-a926-435e1d199c6e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:18:06.62613+00	GET
3a971cf6-ef6e-4102-8baf-d5fa0a04d77f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:18:13.435941+00	GET
9fa5b17f-0e8b-4629-b3b5-c3b872e2589e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:18:13.436927+00	GET
1e9386c0-357c-4a64-9872-a8e327845004	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:18:20.673373+00	GET
592994cd-9b5d-45ca-9cb4-0f60406a8bf0	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:18:20.673389+00	GET
eee05f9c-275e-4802-9ade-7d3e59b7692d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:18:25.510215+00	GET
cb1c5bfa-ea59-4653-8d38-fdfe7f8b56fd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:18:25.51063+00	GET
1c79716a-b343-41cf-943f-eb9f44007dd2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:18:29.366232+00	GET
12034c89-04d2-47fa-a2ba-9c9b27633bef	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:18:29.366534+00	GET
e9e8def0-5d06-4191-8dfa-798d63ad1951	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:18:36.717325+00	GET
f398a4a9-5674-485f-8e1d-65b9425cc10a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:18:36.717402+00	GET
9c7202b3-6db8-4f9c-8562-8dd54ddb3916	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:19:03.081665+00	GET
1ed5c923-d3a7-4cd8-812f-8436418051a4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:19:03.082382+00	GET
cd30b83b-a15b-417c-bd52-3142cfa8dc41	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:19:10.027791+00	GET
b2ef6e54-bb6f-4410-863e-819c8ac85da8	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:19:10.032732+00	GET
a9ab75ea-cf6c-47b5-a81a-9392793beb35	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:19:10.134237+00	GET
5a7f348f-996b-480d-bfcc-9886c2277d20	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:19:10.134937+00	GET
13545358-b3f1-4bc3-a2eb-e842bd559e15	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:19:35.346954+00	GET
cb2940f0-441e-44c2-88de-265bc7641335	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:19:35.348103+00	GET
f0e873e1-3113-493c-884a-0fe6b780fa0e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:20:36.093081+00	GET
fa09f151-0938-433a-bd58-a34fb5413dae	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:20:36.101221+00	GET
407d1404-0132-481b-9f32-2bb7883af652	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:20:40.413651+00	GET
8ccd6b68-3e58-4884-8585-e3b2e886b6bc	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:20:40.414775+00	GET
0586a188-e433-4d1a-ae9b-a3fbef3a9998	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:20:44.527221+00	GET
280de9dd-c269-485f-9567-b20cbf8cb8fc	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:20:44.527519+00	GET
81c8cd25-e913-4498-9a76-0f9c908c177e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:20:49.781207+00	GET
0c6f8f1d-f7ca-44e0-a7c3-53d40c347640	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:20:49.78042+00	GET
775b1e9b-2973-470d-8231-8da3c4312fd2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:21:24.38267+00	GET
91026288-0499-4b14-9fd5-889b10341f24	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:21:24.391579+00	GET
67cf737b-211e-4858-80ae-e582ccca87b1	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:21:32.875061+00	GET
98f56a8c-79e2-4f31-bc86-e0aa22885652	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:21:32.878592+00	GET
1dfa9e8d-9a57-4990-8099-d103f14ad946	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:21:40.65917+00	GET
10861e2d-f90a-4f67-9f1e-8340b5115ae7	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:21:40.659757+00	GET
1aa66e88-2049-4360-ab12-5cc809068bd5	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:21:59.853047+00	GET
b3b757e4-6553-4a7f-a4e4-86a48b8037c4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:21:59.853733+00	GET
cf4338b6-cd12-493e-bd02-e7a0fde979ae	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:22:04.880504+00	GET
05458384-66b4-4f9d-9e64-1868ca4cd0a7	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:22:04.88123+00	GET
d39846db-9a74-4b82-9c57-60d421f17627	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:22:12.251892+00	GET
5efbeb2e-f69d-4b97-a4a6-a64f7ba7b6d6	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:22:12.25276+00	GET
7815d036-e6f8-4d56-8ad0-fb102b40647a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:22:23.270113+00	GET
ae045bb9-f6cb-4f66-b3ae-d5ed1bdb5353	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:22:23.27039+00	GET
9fccc0da-a141-4e3b-8979-7fe245c7bb54	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:22:27.205623+00	GET
90485c41-8124-4215-93f4-e9835cfab4c7	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:22:27.206619+00	GET
49978a48-5f37-4799-a06b-14985a9ba754	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:23:20.73321+00	GET
beae649e-4e2e-4d59-8094-df51126aefdd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:23:20.74379+00	GET
2182d575-814c-40cd-bfb3-01edff9f3999	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:23:42.292199+00	GET
7606802b-2f9c-4740-8ff1-6c7ffe63f228	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:23:42.293607+00	GET
f2c1893f-a6d9-491b-a01a-896a243598d3	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:23:44.598123+00	GET
2dd99d85-4ade-469a-89d2-c98692588438	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:23:44.603128+00	GET
b1b3e8ad-51c5-489e-9403-6c8dddf9f81a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:23:59.004553+00	GET
2d7f67e5-7efb-4ef2-b223-ad554073283b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:23:59.005429+00	GET
5a9a22b5-394b-4c60-bc7d-6d92efc0efe9	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:24:03.979689+00	GET
7eaf0124-41f5-4b72-81d8-8c4f77abb225	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:24:03.979649+00	GET
92bd59d5-4366-4738-a584-2cb4cf6811c3	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:24:08.723906+00	GET
5f3a0714-68b2-45f1-9050-652203c9e243	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:24:08.724766+00	GET
f1c00b62-1897-4571-b13c-5aaa91df705f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:24:13.912813+00	GET
b2b45235-9e1b-47e2-b004-58be6163619e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:24:13.913881+00	GET
9bde0205-48b2-4680-ad1a-b66ddbb74689	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:24:36.066908+00	GET
3261c7e4-020b-43da-84f0-fdacf639c023	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:24:36.067366+00	GET
93b90a99-dbf4-4688-8953-690ad1846106	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:24:40.963772+00	GET
a1085425-1905-4f0b-b8dc-dc05a1934c3e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:24:41.92206+00	GET
da402bb3-1a1d-496d-8cde-96ed521843cb	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:24:39.009147+00	GET
83d72991-9050-4355-a722-f5c0a0ac0530	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:24:39.462138+00	GET
f295a0a4-5edb-4a2f-8df4-3bcd8e39e8ab	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:24:40.964245+00	GET
6cdceef2-81cc-489c-8e46-f4445dddfbb2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:24:39.461181+00	GET
c36190d7-d72b-4cd7-923c-9e9f87d19e92	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:24:40.376902+00	GET
67cfbf47-723d-4075-9625-c5458570d1ac	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:32.7611+00	GET
34e8acd8-c783-49ae-85ae-2ffcd57e777d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:36.457442+00	GET
0144443b-ac88-4ef8-b365-9e2a56a80122	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:36.871525+00	GET
921cf387-e578-424d-879e-320503142b6e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:38.110977+00	GET
7daff87b-53d4-4dd8-beb3-1141a69d7e06	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:39.514257+00	GET
1932a700-9982-43b5-bda5-640902645b60	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:39.524502+00	GET
37aa07ee-0d70-4e63-a354-1ac780b4fb36	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:40.622036+00	GET
96d22b37-0933-4e53-96f8-32f64a0401fd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:41.867489+00	GET
6ee87947-3898-4e6a-9c79-83f4e2b2acc4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:41.867476+00	GET
dbe86f45-13b7-4b6e-ab0e-25c730650fc0	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:42.865714+00	GET
98aa6f57-1838-4ba3-9fc7-cd3f3ad47e69	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:43.435308+00	GET
11de5e36-6966-4ee7-a9ad-95a4eb2cd195	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:43.436481+00	GET
b9086ffb-7dfb-4783-a95e-4b3709bbe4fc	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:44.166302+00	GET
db886c96-7d58-4e4a-81f9-23591f1bcf67	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:44.782133+00	GET
8bbfd9ea-505d-40c2-b0f7-e63fcebd9e00	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:44.782489+00	GET
2e46dbd6-405f-4420-ab36-5955af5b8608	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:45.649866+00	GET
79540509-7227-416b-82bb-af18551a5f33	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:46.154388+00	GET
c3887f8d-72b7-4af9-a41a-dd8696220785	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:46.155516+00	GET
b3296b2a-3874-49b4-8224-6c7397a9c4e5	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:52.365206+00	GET
a60a60f7-3c08-40f8-b747-4fa1db27435b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:52.98575+00	GET
da7a5543-bff7-4bd4-b402-e7026a5be0bb	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:52.986302+00	GET
5533f3d9-0c71-4295-b317-3ec0ccdc1dc0	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:54.499449+00	GET
4fa6806b-9aa9-4795-880e-f568b3300e2d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:54.972965+00	GET
419fc0ec-9266-4da2-8637-3f2ea3f1f46e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:26:54.973361+00	GET
c77c2443-b9ee-40da-8a20-05f5002ffadb	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:27:27.347104+00	GET
12461f42-5a68-4467-a0d1-fdaef299648d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:27:27.354907+00	GET
2da1567e-57c9-4b24-998c-c150a1f7a1bc	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:27:27.826245+00	GET
8ccaa30c-b747-4bae-8b7f-39973e1aae5d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:27:28.475903+00	GET
c2ff3215-bf7c-4a95-b0eb-8945532cb837	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:27:28.476311+00	GET
ef24d994-fb78-4555-988e-888a53af7818	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:27:29.883386+00	GET
8342115c-8241-437a-af52-1634968c56c5	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:27:31.077374+00	GET
07283618-62d0-419b-af8c-c3610a4f8b4d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:27:32.470285+00	GET
ff98cd5a-a5e8-493a-ab99-7ddbfd95fa7b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:27:33.721065+00	GET
92a0a5ad-c3da-4940-9f30-63bfbf6a3201	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:27:38.209464+00	GET
387910d8-58e1-4a80-8639-aa214feb5025	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:27:51.790079+00	GET
0887508c-e2d2-474c-82f0-84c70fe72d89	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:27:52.527234+00	GET
d001725f-2739-4eb9-9e45-ea7b6adf8be8	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:27:55.381598+00	GET
2c70715a-f612-444f-ad6b-77a88abb1070	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:27:59.576406+00	GET
8ec80b02-6e6d-4867-8482-252b7115d9b7	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:00.921371+00	GET
9469edfa-0eff-4c68-afdd-89b8d956d9af	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:27:31.077911+00	GET
b447cad9-f448-4c71-ba76-88a85e68a2f9	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:27:38.210266+00	GET
9bd74cda-f943-4fc5-b26f-444d00a9a63f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:27:56.621052+00	GET
142f304c-9e67-40d6-85a2-22389ce3b2a8	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:27:33.720322+00	GET
79983fb9-6be9-4287-a5a9-42cd57b99673	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:27:36.843888+00	GET
9eb7c63e-621e-494c-8a7e-2e05e9f9ca21	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:27:52.528245+00	GET
627e632b-b0c8-41ce-8e30-bfa7b1db36ae	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:27:56.61336+00	GET
57de875e-68f5-4a62-a894-df452ae5aa6f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:27:57.670184+00	GET
674619ac-62f2-431f-8e23-1626a809b87c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:27:59.576272+00	GET
2c4c9432-0984-48c9-9420-2d211e7b3b88	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:12.735132+00	GET
e61f6e14-b860-49f7-b788-79ca3823d1c9	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:12.989864+00	GET
e4d412d8-6314-4570-9291-85e03b830570	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:13.67427+00	GET
7dfd59b9-e1f2-4c11-bde7-60e4042f6987	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:19.741262+00	GET
7728f7ec-877b-4187-bf11-fe2634ab2c14	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:19.7437+00	GET
ab69dcad-df06-4d1f-8322-1fe647838f30	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:20.837109+00	GET
4144ceef-6a73-4535-aed1-83951c322ee1	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:30.480597+00	GET
7456b69d-a58c-4310-895e-f641d6626139	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:30.871886+00	GET
eebdcce6-dc82-4db2-92a7-b72786b353ec	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:30.872992+00	GET
8b1151df-e1fb-4ad2-9050-9e2beb026381	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:31.514528+00	GET
69cdba8b-3a1b-4dca-9476-17510b86c27d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:32.984849+00	GET
9215f96f-392e-4e43-9582-0a8fa63721bc	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:32.985447+00	GET
ec9cfc16-3dac-42b4-90dc-5515bf5d758c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:39.709729+00	GET
5446bc8c-af79-4c8c-8d8b-6f5828c1db1c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:40.448311+00	GET
bccb513a-39af-4ba8-80b2-598d2106a024	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:40.44855+00	GET
1f664cb6-a92a-400a-84a0-34f829692ac4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:41.578009+00	GET
5b8cb2f6-4466-4229-815e-f816661cd824	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:44.921506+00	GET
83143029-9767-4298-8162-c59ec21b56c9	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:44.922231+00	GET
ba8376fc-6d7c-4968-a68a-ec52f74d4b94	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:55.532455+00	GET
2234b892-6b65-403b-aac7-611ba1431217	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:55.532683+00	GET
34b7d6a2-658e-4464-9276-3e45137367d4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:56.15615+00	GET
4ebe4f4a-0609-4416-ae66-8b1eed2f36b0	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:57.272027+00	GET
7eda3c96-715b-41ca-8fee-6babcf97d34c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:57.272714+00	GET
4f673ba9-4837-42a4-a555-2668dc32b86f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:58.337905+00	GET
f66a439c-ae69-4f26-810b-68bb9fb37587	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:28:59.495648+00	GET
e36ceb95-5941-4c90-9c71-9a64460ac0b3	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:29:01.682664+00	GET
ac1a43f3-90de-4627-b467-df03fc9307e2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:30:20.650679+00	GET
7cd7db7e-2bef-4165-b351-dcd272b682bb	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:30:23.896586+00	GET
08883507-91c5-42a6-9ce4-67531970aaea	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:30:25.503646+00	GET
dc3aef2c-f475-4eb4-8f4e-f65feb4c56d2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:30:31.705295+00	GET
8b7e960d-640f-49e9-800b-b4f06b4c4637	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:30:32.208899+00	GET
c4b8d490-f3ec-49c1-8eca-cb5c7881ecc2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:30:33.943186+00	GET
dfcbe2ed-a978-4af9-8eb3-657add792a0a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:30:34.49233+00	GET
af3072fb-7ac8-494e-8e51-79fb0de58fb2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:30:37.126081+00	GET
c60f7e7a-d705-42b4-b400-1841b2b93934	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:30:38.972041+00	GET
80efbd54-1ada-4abe-922a-972539c9826e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:30:41.117984+00	GET
a5bb839e-0ede-401d-8e54-89526994a8df	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:30:42.172247+00	GET
3f310ed7-663e-4080-9948-54f5e96212a4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:30:42.607563+00	GET
fa046564-6554-4601-b0fd-8de0a9ffe6db	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:31:08.309943+00	GET
e9ee7f23-9d3b-4f4e-847f-c2062ead8f7b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:31:21.860228+00	GET
a8700127-c20c-4ebe-b9be-e3ce694b69d6	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:31:28.831479+00	GET
0a6a08ec-5db2-4df0-a95f-53cee4ecab92	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:31:31.838238+00	GET
4a963eb5-9a53-4079-88ce-e714b82c31d9	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:31:32.318347+00	GET
bca0e2a9-9e91-431f-acf5-7212666a5575	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:31:37.741712+00	GET
3e67f0d7-057f-401a-b640-9d625a62576a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:31:38.077951+00	GET
1d567a91-4923-4b42-91f0-590b3d1b24ec	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:31:39.235286+00	GET
8548979b-9d5c-47f4-86c5-f5f72d8512f6	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:31:43.015908+00	GET
46fdb20e-fb29-44e0-bb78-b6eeda2bcdfa	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:31:43.027526+00	GET
80b2eb9b-9b69-4f95-b8fa-4439918cc3dd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:32:27.237452+00	GET
c6a520ff-da7b-4dca-898e-c77425ffcc33	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:32:37.200309+00	GET
ccc49b20-011c-4ef6-b2aa-142326f57ad6	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:32:53.459496+00	GET
22f915c6-9bc5-4f61-8d45-a3b0b61bd3f8	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:33:01.285143+00	GET
fab98eee-4260-4f77-b1c0-36e258a0a1ce	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:33:03.531013+00	GET
f7097ca1-369c-4e00-96ed-e8dbe70e9e15	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:33:06.007009+00	GET
c060ef93-92a0-4da8-ae66-732e2f0784c0	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:33:49.298457+00	GET
1fdcf3aa-288e-4ee0-9f49-7926cf9c14cf	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:33:49.335441+00	GET
10bf460f-3455-4400-bf7b-65219ff30cf2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:33:49.340613+00	GET
a043412f-0c5a-4ab3-9d77-d33ab3f7763b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:34:30.740648+00	GET
41b332c1-f494-4e68-955a-b17dc3b7d305	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:34:37.09315+00	GET
ac63dd0f-ecf1-4a1b-93a7-123b1b5d940c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:34:44.649916+00	GET
a4c4d4fd-e85a-4cd8-91e4-67823b1ff193	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:34:48.480005+00	GET
4edeaa27-fae3-4840-a74a-94a4a044c19a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:34:56.240596+00	GET
6491b062-9a4c-4105-a6fd-7fc3414b5b9f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:35:09.622989+00	GET
58de93fe-0a8d-45f1-a4e2-4f6cc5d310f1	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:35:15.593715+00	GET
61a7a4fc-24c5-493f-a6e9-9352afb39444	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:35:28.286875+00	GET
ae5429a2-f5a0-4dad-b489-06414a145088	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:35:55.319294+00	GET
65917d46-b304-4548-ac90-c1e244842cc7	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:36:08.230412+00	GET
dcf20b1d-d29e-43e6-800e-aad7ed73972d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:34:44.72955+00	GET
56b8fbbc-812f-4129-9c90-736eeeb8ae0a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:34:52.952411+00	GET
4be5fcb5-faec-4a03-9117-e60dedc5aa7d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:35:01.859289+00	GET
e2beeb0b-d903-46a3-af71-d7d0425348fb	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:35:12.665091+00	GET
f183b616-43e5-4912-8213-46da7b5a6689	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:35:20.571164+00	GET
64e0b5df-e4e8-4fb7-af97-b1c70b078918	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:35:35.577491+00	GET
c45b4215-c229-4280-8593-4eec9b0cf542	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:36:01.221071+00	GET
b5fd31bf-0da2-4376-b583-182be3b5c1c4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:36:11.00501+00	GET
f0c03cf0-aae6-4d18-b2b6-f31020fa3077	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/unlocked	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:36:14.907153+00	GET
a43e3612-b419-4528-9f2a-47d3f55e3960	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:36:21.503525+00	GET
51ddfee8-d553-4428-8176-2516b222d24a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:36:21.512517+00	GET
c6523785-d4a4-4ed2-a48a-133df40cf606	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:36:22.647284+00	GET
804d3cd9-58af-4865-a231-bf97a6b9e321	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:36:27.247904+00	GET
acd09840-ddd7-4c49-a547-dfc8fc1eea5a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:36:38.485553+00	PUT
f4089800-e646-4e09-9bae-1f83eb4fdec3	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:36:42.349464+00	GET
0a2da19b-34dd-4072-bbf7-1a471ee42dab	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/unlocked	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:36:42.349603+00	GET
d84512d2-91ff-4ffb-8438-071c06c28c14	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 04:36:42.358989+00	GET
3fb285cd-34a6-4204-8bfc-5eb2ea4d0918	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:30:21.436976+00	GET
760423b6-b238-4746-bbdc-fb28b5124d7d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:30:21.448136+00	GET
07c460d7-9755-458c-ba3e-e42645c41d77	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:33:00.596386+00	GET
eefaabd5-6bc0-4f25-adbf-1297c522378a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:33:01.139134+00	GET
9af0919c-a312-456c-944a-65f6444fc870	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:33:02.770662+00	GET
e3166bcc-00cb-4b95-8c84-bb24235fdefa	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:33:04.667149+00	GET
e875de89-5ffe-49a6-83b6-fdf3f9005e56	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:33:09.701517+00	PUT
25e4d079-4e36-4770-bc8e-249b4265b494	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:34:48.459301+00	GET
4b88f8c0-7cbf-4392-be35-e67365c22d8d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:34:49.141235+00	GET
20219b56-55a9-4b55-9651-0463054da487	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:34:49.694814+00	GET
880e16b2-ac4d-4fe0-8281-1f26d47f7ddd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:34:52.393675+00	GET
0d891943-6860-4513-8884-6bed8544c1af	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:34:54.265418+00	GET
318cafaa-7ccb-4de9-a887-951b135dc64c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:34:54.742111+00	GET
e56f8eac-a72c-4633-9d00-5c229cef3617	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:34:55.738883+00	GET
2481beef-b469-4132-a13d-323c611ad2c3	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:34:55.781883+00	GET
e301ff32-374e-4b45-a737-380e495c3835	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:34:56.491232+00	GET
3dfd5f84-571b-4ab8-aea1-41929575aad2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:34:58.258615+00	GET
5689d216-a09d-4db2-a903-59b7502a179d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:42:08.253132+00	GET
1cbc1662-a391-4ad0-b5de-fb83b5e76ff6	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:42:09.672931+00	GET
016b5315-63a0-43e2-ab3a-63f86001c2d6	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:42:09.681172+00	GET
c9fc4b52-9a4b-423f-9151-cfc03af97ac5	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:42:13.499506+00	GET
58d4b539-abd5-4899-a9d2-29598128f22f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:42:19.027601+00	GET
be5d6117-1ade-4dc0-b775-93108da30db9	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:42:20.086124+00	GET
7c8d1999-7930-4fd1-8f88-12c5d422215b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/active/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:42:25.550758+00	PUT
807b95fa-06e2-45ed-9898-3fe66529ced6	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/active/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:42:26.560501+00	PUT
14e18004-fe58-4030-933f-8a0c4e59e307	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:42:53.570342+00	GET
5623206f-faa4-45f6-8567-14a50e38cc18	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/active/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:42:56.525287+00	PUT
45e2ec65-83a8-4bff-8331-d62f31a5f454	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/active/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:42:57.55239+00	PUT
3dde34a9-5457-4fe6-ba0a-3060eb925aef	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/active/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:43:02.796777+00	PUT
81c9d646-9da0-43ce-803e-b700710e7c65	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:43:04.17253+00	GET
4cb51884-b34d-4878-8040-ab70fd6a92d1	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:43:07.122684+00	PUT
88893017-f6c9-475a-913c-65513bd649cd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:43:08.820167+00	GET
9f4f0575-e746-4bb4-a9b1-f6e9250ed30b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:43:13.011342+00	GET
e30a3066-95e5-4f74-a72e-9e74fb613ea3	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:43:13.620627+00	GET
3007181a-d161-4385-97b8-56edc3970ca9	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:43:14.686149+00	GET
bc5894ef-98ed-408b-bee1-4c75be506ece	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:43:15.82682+00	GET
429555f4-8d59-449f-8a46-9fbe4c5f6452	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:43:16.371269+00	GET
f7b4032c-8d25-4542-9c91-49dfc0614e66	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:43:16.37956+00	GET
f87d08ee-cb0e-4ef9-bc95-49a9806e6e46	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:43:17.579992+00	GET
90289d2d-268e-43b3-b957-7c90889c3f71	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:43:18.219974+00	GET
750be314-a228-4edb-be55-3e8f98942973	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:43:37.841953+00	GET
1413f04b-6c40-48c7-9f6c-70e783872a9a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:43:40.73686+00	GET
47424aeb-aa28-458f-be3c-c3f915ead5b1	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:43:40.826866+00	GET
da0859ba-1595-4d7c-89bf-038983bd3582	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:43:45.575834+00	GET
9abd8fed-652b-47a9-98b1-525885beaffb	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:44:08.066726+00	GET
036a5560-ee84-4885-87e0-d0163cd36cf0	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:44:11.031812+00	GET
a670326c-23b5-4ff3-85cc-bd244862d758	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:44:11.136523+00	GET
d1f0f65b-d7c8-4096-bbaa-833444cade7a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:44:20.753289+00	GET
16bf1933-03f7-46b7-9bbd-6a6bd94fd5cf	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:44:30.497457+00	GET
d48d692a-4d78-4fb5-9e7a-4cbe6a55458b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:44:31.260818+00	GET
47f4853d-5e64-4510-b405-d0bb431e906e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:44:31.296698+00	GET
f51459fe-f59b-478d-a629-bae57c1e83ab	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:44:32.414236+00	GET
ff7d8362-7a37-41ea-bd5a-ff8dfa3d7f4f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:44:32.947477+00	GET
fd72acfc-a009-4cb0-b97c-84ca884a8654	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:44:40.800004+00	GET
1158d61b-1cfe-4484-a0af-1095b253a351	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:44:48.556696+00	GET
91bf5e0d-f8f1-4b46-9fbf-751370f96665	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:44:48.55767+00	GET
2eb10470-5d9f-4407-8674-5ada899cb7d9	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:44:40.801532+00	GET
8c7c779b-260f-44ce-b8bb-b72f11620549	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:46:30.508174+00	GET
cdd6e0a9-cc7b-4f3c-8b3c-b458adf500b9	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:46:56.029801+00	GET
c58a19e5-de66-4e93-ac80-f0b53bc6e9d8	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:46:56.030772+00	GET
b6c036d3-ef48-4fcc-932d-7e8c48dedae9	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:46:57.043563+00	GET
a0ee8c2e-39e0-497b-b978-12a041d25917	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/unlocked	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:46:57.043566+00	GET
7386ee33-a133-4f78-93d3-6a3f43bc42c2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:46:57.581615+00	GET
68fad675-63ee-4a2c-a14a-c9807dd19d1c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:46:58.225388+00	GET
f531997b-1e31-4177-9e51-c85ecde66ee9	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:46:58.230226+00	GET
139ac8ad-2401-4667-ad6f-7d0a3dac3d75	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:47:26.923003+00	GET
1ba2eb35-e5db-4dda-8f7f-b194abff2e42	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:47:26.924398+00	GET
0cf57440-8912-473d-a6ff-9f39824b7fa3	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:47:54.927986+00	GET
2ad1edc8-0004-4554-a0db-8640426b7aa4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:47:55.280905+00	GET
0c7d844b-e449-4187-badc-9dd57acf385b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:47:55.282162+00	GET
54c69ae5-9d41-4d82-8d98-7c81618c7470	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:47:56.458079+00	GET
0242b884-f2f5-4143-8a61-f1262ef34178	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:47:58.181089+00	GET
9d0bb6d0-14d9-4165-8225-198c029cc489	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:48:05.101903+00	PUT
072112f7-a8a2-432b-abac-c2139d7634da	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:48:11.983764+00	GET
dee2a9e7-83c0-4090-85ca-c0804cab6514	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/unlocked	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:48:11.983776+00	GET
bfa95c8c-313a-491d-b3c2-68bf5d4d57db	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:48:11.985508+00	GET
a70514d7-041e-4faa-85c9-06e3b5c8158e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:49:38.704323+00	GET
7db01db0-dd59-408c-8164-8d473de824c4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:49:38.725233+00	GET
4bcdda6f-320e-49a6-a54d-95df030e86b9	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:49:39.668042+00	GET
30dd0d10-309b-4002-a2dc-f9480fcfbb19	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:49:41.361291+00	GET
27bd81c6-dd1b-4824-989b-5107f100a0fc	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/active/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:49:42.344671+00	PUT
6aed2eae-9dbc-4888-acc3-a17a706e6cfb	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/unlocked	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:49:45.163601+00	GET
fc9a7bcc-0e81-4a64-a817-002001d82744	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:49:45.163214+00	GET
e812b799-07dd-432e-82d7-ae694ea2188e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:49:45.165162+00	GET
30f8330b-542e-451a-b776-0ce1397f594e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:49:49.634262+00	GET
3c31547a-2d03-4073-bcdd-804f64f94108	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:52:03.846015+00	GET
59c41d96-e651-4bea-9e6f-bf602a971dd1	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	\N	2026-05-12 05:52:09.499867+00	GET
b50d9a7b-1787-4208-b7a3-42d46632b274	\N	/v1/auth/me	401	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:25:45.017244+00	GET
e423f7d8-ce5d-4939-a8b1-0bf8dfab4e63	\N	/v1/auth/login	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:26:32.045523+00	POST
5fcc405d-40d1-46c9-b756-119709e337d7	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:27:06.334409+00	GET
01541f58-eb73-40ac-b1d4-a46b0ed3dd46	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/unlocked	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:27:06.335006+00	GET
fc066328-b9f9-45fe-ac45-573c8b13bcfd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:27:08.613189+00	GET
5204bbda-f49e-4755-80ea-b04a09336589	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:27:13.297024+00	GET
b98f9949-4a45-4635-910e-6c2bbf5ad390	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:27:13.306074+00	GET
10693842-10fe-4884-9611-63f851533b7f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:27:15.002707+00	GET
93b2ee3c-2ec1-45d6-8ef7-49261cdc8a70	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:27:15.556203+00	GET
b715d7bc-aa84-44ef-8e9c-dbbb27350b1b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:27:16.198283+00	GET
6072e30e-39b0-4338-970c-f0c790a7702d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:27:16.689909+00	GET
e6076fa9-d71e-4538-951b-923b9e6eda88	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:27:20.740086+00	GET
7adf81d8-2fcf-4da2-8c40-d88a5b66f5de	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:27:21.711185+00	GET
d51739c5-aa49-49ef-85ad-cb863bd4172a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:27:21.712114+00	GET
6a5247a7-6b5a-476b-8c3a-afb61f46bb95	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:27:26.52691+00	GET
1cfda418-6b88-4646-be7a-549fcdfde3c3	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:27:26.528323+00	GET
c20d3fef-75c3-4c3c-abbd-451212da0c99	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:27:30.582695+00	GET
6195936a-0571-4b1d-9401-3501f392812a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:27:30.583347+00	GET
80e7d72d-5e78-42f1-935e-438f23c88f8e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:27:31.550612+00	GET
992b16c0-1c79-4b77-911f-ddfc3a4828b6	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:27:33.490773+00	GET
e1fc3fbd-4f0d-4e97-af31-f19a820f608b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:27:51.348965+00	GET
971e5053-8d97-4ddb-9a25-d737ab2d5ed2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:28:03.164875+00	GET
87eea879-2a87-4424-9dfc-9d593e09cc7e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:33:16.100821+00	GET
4fc1aa34-9705-4642-9485-3ce1fd06019c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:34:40.715247+00	GET
071d8a64-989a-43bf-afc8-7cc7791f47c4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:34:44.255892+00	GET
9f76af3c-1929-45b2-bec0-56f66ae7896c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:36:44.815957+00	GET
27cd3c7e-f298-4468-887d-b53f65fbde46	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:37:50.05492+00	GET
7a80439e-fe36-4496-9243-60da59a46f62	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:38:53.911425+00	GET
d2e092b9-0c6c-4cab-ad5f-4359877a886a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:39:45.148674+00	GET
0a9cce8a-c210-4d04-b3b3-407c4164b745	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/unlocked	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:39:45.149702+00	GET
e52c5d30-c398-49e5-8cde-645359cc6ef2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:47:01.210792+00	GET
7aa6b85f-ddea-4588-8fd0-cfc08564f67c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:47:01.211326+00	GET
704a89c8-f883-4932-bf96-2e65756ac712	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/unlocked	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:47:01.211561+00	GET
8fd5882e-e366-4a8d-ad9a-e110bd99966a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:47:23.655808+00	GET
c049a162-05ff-4689-b34a-3baaf8021820	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:47:23.656133+00	GET
e2eeb7b6-07db-4903-9b32-bd673d96c84d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:47:24.520796+00	GET
81a922d6-6be7-4f90-8593-6e86088703bf	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:47:25.583881+00	GET
e98b1d84-6bb2-445c-accb-0764e447eb83	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:47:37.562768+00	GET
6b458f3d-37f4-47bf-bea4-8f7dffce745a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:47:40.546889+00	GET
d806c796-db38-40b7-9490-0077e1ac26b5	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:47:43.729711+00	GET
94ced2f3-3d5e-4c60-9d38-0f5e4d50a212	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:47:46.477898+00	GET
01387efd-8a4c-4cde-bb85-9a108fb6c1e6	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:47:47.342154+00	GET
8537bd84-dcf5-4391-a1b7-639196b8a4f8	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:47:48.180444+00	GET
3ebe636e-1551-4c40-9996-e8c5355593c9	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:47:49.155908+00	GET
f438b072-86e6-4973-a69c-590425e7b50a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:47:51.475425+00	GET
be28d845-0b3a-4921-945e-7ee30ea201db	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:47:52.806523+00	GET
c1be3492-c477-4b20-b3ba-684bbf48373e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:47:59.338495+00	PUT
6d737663-cecb-4f79-a196-2491c1f64c99	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/unlocked	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:48:01.592733+00	GET
e1dabe8d-2917-496c-8312-4d41ba621278	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:47:46.479866+00	GET
b073bcd7-c547-46b7-b1d1-5c936d6fe8f8	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:48:01.592438+00	GET
0e16671a-ca75-456a-baba-39b44108bf33	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game	500	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	{"level_id": 1}	2026-05-13 16:48:14.330358+00	POST
ee181448-c422-4372-9b00-6c272fe09b53	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:49:44.111233+00	GET
399e2f29-5061-41c9-890a-ddc1bcdba35b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:49:44.115661+00	GET
6fa83042-05c3-4ee6-a5c4-2248b425f965	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/unlocked	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:49:44.11635+00	GET
e36881d1-2c06-4d94-9e8d-3cd52fa2ad03	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game	201	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:49:50.631195+00	POST
7a49d61b-cd29-4b49-9dd2-608f96a07945	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:49:53.957209+00	POST
d4482943-11ad-477a-a9eb-2d5f5c50abdd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:49:56.38863+00	POST
000c4150-7513-4e76-aa1f-9f256f434f6d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:49:59.587132+00	POST
e08de8a4-1a65-4d48-a2f3-2356ad91127d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:50:02.957366+00	POST
5165763e-05dc-4814-9a6a-a16663d2fb6f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:50:05.519013+00	POST
06990a9c-9455-4f03-9970-cf3da6a6759b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:50:11.72283+00	POST
12d3ae7b-242d-4f5f-8dae-594d2e5d4246	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:50:13.680123+00	POST
9ed70284-42e6-48f9-9b43-bd8f3dcc47a9	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:50:16.41867+00	POST
36e19049-9166-4ea3-90f9-1d5edffcb8a2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:50:19.154452+00	POST
aa83326f-f1a6-46ad-9642-6fb54eed3cf8	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:50:20.755222+00	POST
9530a14f-6cbf-4b5b-afd8-8c35259f72e3	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:50:23.629673+00	POST
b325a0b3-d629-4b11-b9b9-c788a88f88bd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948/end	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:50:25.268993+00	POST
0c539ddf-5db6-42f3-b035-3f82128d8898	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:50:58.617479+00	GET
42960184-ddec-4470-abec-ca8079a2637e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:51:00.809408+00	GET
9cf59068-d051-444b-8092-a9ad9accbb73	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:51:00.822849+00	GET
02a8d40e-4c9f-4269-b0fd-7b6a504a32c5	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:51:02.505408+00	GET
610d13e5-242e-4907-b2bc-a96bd575eae4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:51:03.149743+00	GET
ca39600e-736f-4c06-ad80-e6837ae14fe7	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:51:05.96697+00	GET
0200368c-8873-43ae-a610-f1ac214d68e6	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:51:06.607685+00	GET
7d625714-579b-4237-81f8-bb5637bdfd57	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:51:08.73383+00	GET
f50b85c9-4b75-407d-be80-d2c22843c9e7	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:51:09.510173+00	GET
cbeca9f4-8c43-469e-81cf-66ad5a6cea17	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:51:12.981647+00	GET
a7e98fb5-9c7c-48fd-ae9c-34cd1028ec22	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game	201	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:52:45.445027+00	POST
21123611-43e5-405c-8d1e-85256bbb9dc4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:52:47.479334+00	GET
5a6a65bf-49bd-4ad7-a64e-617803d901d3	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:52:54.357314+00	GET
51d47c51-7982-423b-9c7c-f84880449b7f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:52:54.367798+00	GET
e124a958-6381-468d-87b2-4e538a1f63e4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:53:03.137346+00	POST
445d0c2b-af27-47fb-b705-be4d689bc174	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/6bb24d15-d590-4511-984f-a00e142d22a9/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:53:14.16674+00	POST
2df28f70-9b4f-4ea6-ab58-8cf5b6433941	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/6bb24d15-d590-4511-984f-a00e142d22a9/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:53:16.761733+00	POST
a3778b3f-3f65-4f5e-b236-4b087a59d926	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/6bb24d15-d590-4511-984f-a00e142d22a9/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:53:21.695194+00	POST
da20b4a0-bcfb-4dee-97d7-b0873e2ff4a4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/6bb24d15-d590-4511-984f-a00e142d22a9/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:53:24.198958+00	POST
55d6f4be-1c8d-44af-a8eb-e7631be7bd83	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/6bb24d15-d590-4511-984f-a00e142d22a9/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:53:25.891468+00	POST
8dddf80c-5f31-4cec-b2c5-d5e002767303	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:53:27.959588+00	GET
e1722cda-a887-446e-820e-647dd8432851	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:53:27.974309+00	GET
775a9afb-595e-4fd7-b27b-f7371b40b067	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:53:40.21118+00	POST
4c302f05-6130-4d7a-81ed-f6ddb153de4f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/6bb24d15-d590-4511-984f-a00e142d22a9/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:53:42.943757+00	POST
e4f7d323-8aa8-4d91-b104-eaf7d6cb49a8	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/6bb24d15-d590-4511-984f-a00e142d22a9/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:53:46.269573+00	POST
f624681b-a72e-40b2-a730-71f7f044b96e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/6bb24d15-d590-4511-984f-a00e142d22a9/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:53:49.44886+00	POST
0bb30be1-8d58-49c1-a84f-a504b5bcbd5f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/6bb24d15-d590-4511-984f-a00e142d22a9/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:53:50.605146+00	POST
c5e3bee6-da71-4170-a789-61cc8875e567	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/6bb24d15-d590-4511-984f-a00e142d22a9/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:54:04.672877+00	POST
83ab4e28-152c-4a9d-82fd-397596eaa4ea	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/6bb24d15-d590-4511-984f-a00e142d22a9/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:54:05.378046+00	POST
9ae74b26-5284-41de-9d99-02a9ae4bf0f9	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/6bb24d15-d590-4511-984f-a00e142d22a9/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:54:06.079905+00	POST
2e975ebc-fa1a-4cc9-9597-3d88dd425700	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/6bb24d15-d590-4511-984f-a00e142d22a9/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:54:08.577179+00	POST
aece2e1f-f304-42f4-b06c-3c44e7c6f20f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/6bb24d15-d590-4511-984f-a00e142d22a9/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:54:11.14645+00	POST
1341c6e3-a48f-4939-8efc-a14efbb80cd7	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/6bb24d15-d590-4511-984f-a00e142d22a9/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:54:13.71262+00	POST
87553ade-19aa-4037-b18b-bca5bc09a363	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/6bb24d15-d590-4511-984f-a00e142d22a9/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:54:16.345596+00	POST
e6c32805-7c4b-4428-9872-cc4d4d266026	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/6bb24d15-d590-4511-984f-a00e142d22a9/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:54:18.784038+00	POST
d838c622-6bc0-49ad-a399-ab66a61e5a8e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/6bb24d15-d590-4511-984f-a00e142d22a9/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:54:35.381152+00	POST
1864a9c7-c79e-444b-a741-35a5af34d55c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/6bb24d15-d590-4511-984f-a00e142d22a9/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:54:41.602041+00	POST
812200d3-4da4-4735-a521-57f159a9e923	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/6bb24d15-d590-4511-984f-a00e142d22a9/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:54:42.77361+00	POST
a86d3b5a-daf2-43f0-947a-664ad23f7b8b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/6bb24d15-d590-4511-984f-a00e142d22a9/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:54:44.268924+00	POST
4c33f378-1abf-411a-8800-8f5646c5ba6b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/6bb24d15-d590-4511-984f-a00e142d22a9/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:54:45.706854+00	POST
1ef355e5-d114-42f6-b62f-1cd688da0374	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/6bb24d15-d590-4511-984f-a00e142d22a9/end	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:54:47.30918+00	POST
69525468-d668-4c9f-8813-40d31775c33f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:55:30.375283+00	GET
c8407daa-f209-495f-9c4b-f84d679b4df7	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:55:31.167838+00	GET
9e89bf5a-7c69-4209-9cb2-0fa5f8120d13	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:55:31.177365+00	GET
35e927be-143b-4de5-b180-cd81c9213dad	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:55:34.884326+00	GET
0505e1dd-050e-45f0-9598-74dc8075d7c6	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:57:41.846835+00	GET
7b2c2ab3-3ec5-4e4e-b662-76c1d53338d1	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:57:41.853779+00	GET
d710be17-57e7-470a-a4fb-fb3a745d3162	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:57:43.023522+00	GET
9bdec50a-6751-48a7-9426-e9ff4c1365ea	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:57:43.026567+00	GET
f2f81643-bc64-43f5-9718-f47f6b8be00d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:57:43.736424+00	GET
59057761-1970-4032-91c4-a6dff2bec235	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:57:48.413527+00	GET
16d8730d-b310-46bb-859a-9e5e755a244b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:57:49.525492+00	GET
d8a4b6c0-a3af-49e8-86e4-bd8aa225f3c6	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:57:50.52568+00	GET
62ee2642-7348-4c57-89a0-690e7a784a32	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:57:52.994018+00	GET
cf338d4a-d63b-4d62-b3b0-1a9f20045da2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:57:54.092593+00	GET
bf97668d-ee48-44f5-934c-c3548de8291f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:57:57.272751+00	GET
e20bc021-baf8-4979-8e70-c39d685f505c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:57:58.148366+00	GET
708e35f4-9162-40a2-a769-2fb6f90d0781	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:57:58.872851+00	GET
54f36bab-c262-4bfd-a5ce-5f312655c651	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 16:58:02.282772+00	GET
a2779725-a262-463f-8601-410a216c89f9	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:03:37.067496+00	GET
a0cc3fc0-364e-4d87-9fae-9433c458f816	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:03:37.103752+00	GET
b60b8487-bb0e-43e9-a9cc-984cb0c399c7	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:03:37.10496+00	GET
ebf2f119-490f-4802-9c8b-af42b62f7316	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:03:41.704696+00	GET
3845f58d-c383-491c-82c7-8e89cc0ad2c9	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:03:41.723178+00	GET
dce5c15b-9f15-484e-8214-9387be95c04b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:03:41.725185+00	GET
c54257bc-2060-43b6-995b-6643cde56586	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:03:46.34142+00	GET
5806188d-e35e-4d5a-ba7d-0872c081084b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:03:46.363249+00	GET
01215d88-e02b-4757-bbd4-90e0b4c9abba	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:03:46.364228+00	GET
1c086b41-cecd-4f8b-b9c1-7741abba0d72	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:03:50.342463+00	GET
18f40756-b354-479c-9d89-bef1e11a8708	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:03:50.362362+00	GET
5978dd42-f77f-481c-8f80-17acb7ac4ce0	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:03:50.363193+00	GET
93d2c5a1-2f81-4f4d-a2ad-b9da45618262	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:04:11.46241+00	GET
e3820611-9ed3-464a-bf2f-80dc5e980fe2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:04:11.480951+00	GET
70b7fd86-f385-4958-b4a0-fb22d6365de2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:04:11.481393+00	GET
e53fa578-0983-45c7-844c-7f657d59bcc8	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/unlocked	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:04:22.873462+00	GET
6c8df0e9-d9ed-4884-87f6-e13c9f587653	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game	201	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:04:33.596267+00	POST
68905fdd-7e93-4270-9ade-16207021a145	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/2dd947c1-bc93-495e-9adf-bb5108564fd4/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:04:35.750803+00	POST
8aad41be-a3e2-418c-aaf0-5517b1b57c0a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/2dd947c1-bc93-495e-9adf-bb5108564fd4/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:04:36.907659+00	POST
3b2e3b96-15e7-4cc0-b0fc-a85661d6e8fd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/2dd947c1-bc93-495e-9adf-bb5108564fd4/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:04:39.610748+00	POST
dfcaa58d-7c80-4d0f-b30d-5c945b488b6c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/2dd947c1-bc93-495e-9adf-bb5108564fd4/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:04:41.107172+00	POST
033df480-2025-438e-b81f-5811e82788d4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/2dd947c1-bc93-495e-9adf-bb5108564fd4/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:04:43.170133+00	POST
1e526a02-76a5-4d60-b9bf-3fe2b5ce8841	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/2dd947c1-bc93-495e-9adf-bb5108564fd4/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:04:46.978315+00	POST
fb48a0a6-b8ff-444f-a14c-be1ee3b430dd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/2dd947c1-bc93-495e-9adf-bb5108564fd4/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:04:49.043009+00	POST
1bc9b1f4-230a-4a5c-96d4-96e300a66ebf	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/2dd947c1-bc93-495e-9adf-bb5108564fd4/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:04:49.17535+00	POST
1b6c1e4a-737f-41f3-b526-2a5ec079cef3	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/2dd947c1-bc93-495e-9adf-bb5108564fd4/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:04:55.947127+00	POST
8659c472-36ed-499b-a112-9fea13c64e11	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/2dd947c1-bc93-495e-9adf-bb5108564fd4/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:04:57.382505+00	POST
b6857a8f-962a-499a-b348-ccb84b9b0894	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/2dd947c1-bc93-495e-9adf-bb5108564fd4/end	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:04:57.575317+00	POST
b00a1766-3241-449a-9447-75be3caec41d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:04:57.587278+00	GET
51caaf25-29fd-48eb-9c4e-3b10385d0447	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:05:39.526641+00	GET
78876511-c960-4794-9474-e6f44de28f1f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:05:40.245984+00	GET
f503a961-4881-4098-9b8f-7d0d3ca07450	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:05:40.256108+00	GET
058bb407-4586-42a9-9c2d-f2841eec37c7	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:05:42.519495+00	GET
aa44d3a3-460e-47a6-80c4-aebdf0ee2dfb	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:05:42.517395+00	GET
39abb1b8-661f-4fbb-8775-b0da6d468831	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:05:43.613836+00	GET
7ca487d1-5ec9-4274-85f5-997e77470465	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:05:44.233179+00	GET
21c96c4c-d152-46c8-a556-19cba15e22da	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:05:47.770446+00	GET
27b37ea7-e6c5-4985-b422-0f0eb5cfd054	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:05:48.814463+00	GET
1fdc9f2b-cbbd-40f3-bcb8-463e30fb330a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:07:46.278496+00	GET
47a5e7ab-52c3-47e0-83b5-75a4423f7fb9	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:07:49.615639+00	GET
2bf4577c-0ab4-4238-b67b-2e95f286c109	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:08:08.868336+00	GET
40a10600-0ee4-4da0-bbd2-9341127e45f2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:09:22.18095+00	GET
bb260625-7519-4cce-a54c-0614b4724af8	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:10:05.02769+00	GET
d43b279e-abd4-4561-b0f2-c230be183f06	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:10:19.813405+00	GET
05488c9f-56ff-4a69-ba9b-efd72e2a5419	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:11:22.903435+00	GET
981832f4-ae59-4e54-bb2f-3a10fbe7cb90	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:11:29.772926+00	GET
71a7b1e9-4637-4cf8-ab1a-a9bdc4fc2891	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:13:10.797076+00	GET
4105b1c1-a037-4a08-b912-780869117866	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:13:31.938161+00	GET
b435f93d-1fc2-4e7a-ab5c-33dd0c125c7b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:14:04.678499+00	GET
6052e7db-4f3d-45b0-80e0-a09c6f187ec9	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:15:00.875249+00	GET
3844a281-7e56-4b9d-b431-ffa7c4f43609	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:15:49.898211+00	GET
42da9094-7c0e-44a4-9592-c24d8099569d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:16:08.748344+00	GET
f868b1e7-04e9-4743-ab5d-6d5e841952d4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:16:40.253078+00	GET
7cf3523e-559c-4689-97e6-42ac0bd710d5	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:16:56.372134+00	GET
a699b0fc-eb32-46d2-96e6-a5d6034688f1	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:20:22.452728+00	GET
752d6782-117a-4ad9-ab2a-ae86974bb510	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels/unlocked	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:22:35.459603+00	GET
a094ab0b-7ef3-496c-9ddb-aef5b2eb304c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:22:35.46288+00	GET
ad10c95f-101c-4d76-8e3c-86856cf0714b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game	201	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:22:46.924962+00	POST
da45f56f-2c7f-4687-9451-eae8ba1a2320	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/c13ee2aa-bffc-48df-bfcb-a4e71161a911/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:22:49.076645+00	POST
1ea5a467-8fa4-46c3-952b-de54b44e1ca5	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/c13ee2aa-bffc-48df-bfcb-a4e71161a911/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:22:51.77179+00	POST
1d9f00ac-9b26-42b5-b002-d776b1ffabb2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/c13ee2aa-bffc-48df-bfcb-a4e71161a911/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:22:52.937578+00	POST
5db04f5a-b61d-4e9c-a703-a9090bd8f587	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/c13ee2aa-bffc-48df-bfcb-a4e71161a911/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:22:55.472706+00	POST
c9de5314-78e0-4ac2-8963-aef0b94b3f60	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/c13ee2aa-bffc-48df-bfcb-a4e71161a911/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:22:56.62902+00	POST
e6c6e7dc-2c92-4fb0-9701-571a355e84fc	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/c13ee2aa-bffc-48df-bfcb-a4e71161a911/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:22:58.906351+00	POST
c8673aee-7f2d-4fc9-adf0-bdeb7c103e53	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/c13ee2aa-bffc-48df-bfcb-a4e71161a911/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:23:01.399067+00	POST
dc1248d0-cf2d-4a92-b742-3d0799ff2aaf	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/c13ee2aa-bffc-48df-bfcb-a4e71161a911/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:23:05.271978+00	POST
7cde079f-d287-4350-a0a6-d1c3e56313fa	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/c13ee2aa-bffc-48df-bfcb-a4e71161a911/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:23:08.603326+00	POST
0d9333d1-25d9-494b-b2cd-50c5bad0c778	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/game/c13ee2aa-bffc-48df-bfcb-a4e71161a911/end	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:23:10.217883+00	POST
92570bec-b998-4552-b0d9-bb83d43b112f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/me	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:23:10.230367+00	GET
c052586e-d4ce-4a48-b5ab-f314b777c82e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:23:28.571086+00	GET
108d631d-0702-48bd-a370-42741683d45a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:23:31.128213+00	GET
83d58117-c793-484d-ab22-a0bca2338cad	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:23:32.662905+00	GET
ff815ff5-8f0e-4959-b049-24917ac85a65	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:23:35.112073+00	GET
2d15be71-9456-490f-aadd-e247d1501f90	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:23:35.1142+00	GET
63ce2f48-1188-4945-b9b0-358c1b1336bf	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:23:41.448519+00	GET
6a923c2d-b7f0-4be9-9538-64fa1b35a34c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:25:08.05967+00	GET
07652319-fdc7-41fb-a2c2-92862a9e3f80	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:25:14.395631+00	GET
adffe71b-9da6-4d4d-b3c7-75df737e9ef4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:25:14.408775+00	GET
df0167d4-70d6-4019-a86d-f44304d9517e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:25:16.670509+00	GET
deae7eab-eb4f-48b9-b92e-8b084dd5b5ed	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:25:19.530427+00	GET
988c6bdd-07d3-4977-9d7e-77d4a75ba39c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:25:26.108431+00	GET
eb17bd83-4cf8-468f-976c-43a63d28537a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:25:27.6894+00	GET
8b41866b-6e5d-4828-996e-5c441bb7c99c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:26:55.482489+00	GET
4e31c479-94fa-4fdd-a31a-a089b8809e5e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:26:56.024125+00	GET
bd890080-41aa-433d-84f7-473f44a0ffe4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/players	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:26:56.780035+00	GET
f66eafda-9c03-4daf-9e42-eaee3cfd3ad4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/stats	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:26:57.206883+00	GET
860f1157-2065-4c5f-93f0-e43f10abddc4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/admin/game-sessions/active	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:26:57.218242+00	GET
9be430b5-2df6-4cc5-add3-4a9cad112439	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:26:59.355065+00	GET
36aaed74-5044-4382-ad7a-590b60a13da5	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/logout	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:27:07.056663+00	POST
1ffba1fe-b055-48e9-8e67-419653ed2021	68769d71-b6a1-42e3-95cc-7bf4842e6f17	/v1/auth/logout	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:27:07.064413+00	POST
43d94ef7-6730-4849-8c87-d4a018342010	\N	/v1/auth/me	401	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:27:08.351456+00	GET
306edac5-4cd0-4219-9919-986fbd70e2bc	\N	/v1/auth/me	401	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:27:15.72092+00	GET
fba281ae-d87c-40ec-a7e9-fe1cdc8c8b37	\N	/v1/auth/register	201	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:27:30.354994+00	POST
f0463ddd-d647-42b2-a1b1-9f22a80094ff	\N	/v1/levels	401	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:27:33.138166+00	GET
9b06e8c1-564f-4a19-aeff-66ba2f771446	\N	/v1/levels/unlocked	401	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:27:33.138411+00	GET
6e3f3e94-8e89-4431-995b-de0c2272504d	\N	/v1/levels	401	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:27:36.137874+00	GET
a2c53f41-2c51-4cd9-b1b6-af37f2b095b1	\N	/v1/levels/unlocked	401	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:27:36.138103+00	GET
9bf5425f-a8c5-4bda-9e8b-557140706f74	\N	/v1/levels	401	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:27:38.336925+00	GET
c7d842c3-3759-41a7-a20c-9ce39e15f587	\N	/v1/leaderboard/global	401	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:27:38.338377+00	GET
9bc828a8-b727-4ead-b7d6-ee21af78c4ea	\N	/v1/auth/me	401	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:27:41.584714+00	GET
8b1266f7-d228-47ef-90e3-902bbd4de595	\N	/v1/auth/login	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:27:49.146243+00	POST
c68e8cfa-ed92-4217-b161-42519e58a7bc	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/levels	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:27:52.877534+00	GET
e504aa4d-22c4-48a3-8aba-d94e1b22bae4	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/levels/unlocked	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:27:52.878721+00	GET
217a0a2d-b253-440f-8b60-af8c7b0c562a	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:27:55.248555+00	GET
b0a504e9-278f-4be6-a3e6-9437c4abed4d	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:27:59.194566+00	GET
98e7bfd9-ff8b-4438-8961-765eab648338	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:28:00.56354+00	GET
cc8273f7-4a0b-4770-afb2-0df3a29d542a	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:28:02.402545+00	GET
5fb310b3-97f1-4c53-a4fa-931915f02c02	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:28:04.699506+00	GET
30c4e588-ec78-43b1-9f53-ed354b3f52b6	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/game	201	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:28:18.232402+00	POST
80bfe092-eac0-4379-8c00-7a33b34939dd	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/game/0b7e4f0d-dd65-435a-8c9e-937306e12f73/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:28:19.51293+00	POST
a0628d76-f5b6-459a-8ff6-2e2f4991ecc7	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/game/0b7e4f0d-dd65-435a-8c9e-937306e12f73/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:28:20.630327+00	POST
5d93a478-da40-46eb-a9b9-197f782c0c73	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/game/0b7e4f0d-dd65-435a-8c9e-937306e12f73/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:28:21.621414+00	POST
9f99f432-59f7-45b5-9d63-f660b0436ba8	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/game/0b7e4f0d-dd65-435a-8c9e-937306e12f73/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:28:23.697972+00	POST
dd4a1e6d-f109-4cd1-92be-98ca78d3001c	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/game/0b7e4f0d-dd65-435a-8c9e-937306e12f73/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:28:24.994191+00	POST
4d601a94-62ec-4c79-add0-aafb04f5e72b	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/game/0b7e4f0d-dd65-435a-8c9e-937306e12f73/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:28:27.00411+00	POST
7da11e8c-8fac-4444-bbcb-c54bf16ff369	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/game/0b7e4f0d-dd65-435a-8c9e-937306e12f73/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:28:28.284769+00	POST
5de52303-3d51-4c43-960a-d9879e913305	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/game/0b7e4f0d-dd65-435a-8c9e-937306e12f73/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:28:32.763355+00	POST
1a04d89c-0d78-4b41-8166-b34272884f09	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/game/0b7e4f0d-dd65-435a-8c9e-937306e12f73/answer	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:28:34.921939+00	POST
6984589f-4514-46a1-b1cb-24f5ba1909a5	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/game/0b7e4f0d-dd65-435a-8c9e-937306e12f73/end	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:28:36.539226+00	POST
3693e9c6-c1c7-478f-95ba-d4db45b374fe	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/auth/me	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:28:36.551534+00	GET
fc491afc-930a-47f0-b978-3a0ae810ecb0	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:28:47.901225+00	GET
353d27e2-30bd-4050-b3c8-237803783050	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:28:51.180036+00	GET
eee6af46-8b36-4926-ab5b-f0a46b11a2c2	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/leaderboard/levels/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:28:57.297691+00	GET
7a2e469f-7069-4a9b-a3dd-03d78b0d31e6	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:28:57.77943+00	GET
f3ac2ba3-ba30-4d48-a090-4b2735c37b48	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:28:59.323833+00	GET
1bf2d060-1411-41cf-8451-5fe292303cfc	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/leaderboard/levels/1	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:29:00.499897+00	GET
69bd0199-1896-488a-a329-d4664f8c708c	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:29:01.331911+00	GET
471374da-20d8-43c2-bca5-5bb318ab0fab	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:29:01.851587+00	GET
c6a474e8-d062-4c80-9364-e2a2e629dce2	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:29:02.590082+00	GET
f7542926-c28f-4936-ae71-e8a65838ba5e	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:29:03.197886+00	GET
2749e35b-b92d-4fb7-b490-8c63d3ae6dcf	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/leaderboard/levels/1	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:29:14.66409+00	GET
fa4e8dd8-a85d-44d5-ba4d-df5ec1edfc5c	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/leaderboard/global	304	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:29:21.638665+00	GET
44e7e1d7-ecbc-4031-a410-c995727aaaa5	ee7af00f-63bd-4f1a-9721-329432cbe1ef	/v1/leaderboard/global	200	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	\N	2026-05-13 17:29:25.75236+00	GET
\.


--
-- Data for Name: audit_events_p20260518; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.audit_events_p20260518 (id, user_id, url, status_code, ip_address, user_agent, metadata, created_at, http_method) FROM stdin;
\.


--
-- Data for Name: audit_events_p20260525; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.audit_events_p20260525 (id, user_id, url, status_code, ip_address, user_agent, metadata, created_at, http_method) FROM stdin;
\.


--
-- Data for Name: audit_events_p20260601; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.audit_events_p20260601 (id, user_id, url, status_code, ip_address, user_agent, metadata, created_at, http_method) FROM stdin;
\.


--
-- Data for Name: log_events_default; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.log_events_default (id, user_id, event, level, metadata, created_at, description) FROM stdin;
\.


--
-- Data for Name: log_events_p20260420; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.log_events_p20260420 (id, user_id, event, level, metadata, created_at, description) FROM stdin;
\.


--
-- Data for Name: log_events_p20260427; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.log_events_p20260427 (id, user_id, event, level, metadata, created_at, description) FROM stdin;
\.


--
-- Data for Name: log_events_p20260504; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.log_events_p20260504 (id, user_id, event, level, metadata, created_at, description) FROM stdin;
\.


--
-- Data for Name: log_events_p20260511; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.log_events_p20260511 (id, user_id, event, level, metadata, created_at, description) FROM stdin;
1934365d-b28a-4ab5-b8a1-08806ce6bf68	\N	error:unhandled	fatal	\N	2026-05-11 16:11:47.620115+00	You must be logged in
9f162f3e-5d53-4a0e-9b95-437a4cf03ef8	\N	error:unhandled	fatal	\N	2026-05-11 16:13:56.586282+00	You must be logged in
32777104-8eb3-4ee8-a611-07887950e37f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	auth:login	info	\N	2026-05-11 16:14:09.202487+00	alden@gmail.com
fd8ba9b2-28ef-4724-8286-1eb1d9f76009	\N	cache:miss	info	\N	2026-05-11 16:14:17.850959+00	leaderboard:scope=global:cursor=:limit=3
818dcb73-a528-4805-9c97-73f32dcd520f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	auth:logout	info	\N	2026-05-11 16:14:29.496815+00	\N
40464844-c09a-484a-b4ba-014998584d66	68769d71-b6a1-42e3-95cc-7bf4842e6f17	auth:logout	info	\N	2026-05-11 16:14:29.497314+00	\N
59ef4718-3a26-45bd-bba1-8cd478d9cc2d	\N	error:unhandled	fatal	\N	2026-05-11 16:14:36.523951+00	You must be logged in
8713fdf0-db4f-4e43-8f98-d0e1da7e44ef	68769d71-b6a1-42e3-95cc-7bf4842e6f17	auth:login	info	\N	2026-05-11 16:14:46.323061+00	alden@gmail.com
9d62230b-0d03-4268-ad66-48a2a91fbad3	68769d71-b6a1-42e3-95cc-7bf4842e6f17	auth:logout	info	\N	2026-05-11 16:14:51.818373+00	\N
bfb3bc52-0fee-4470-a43f-4d9eec7bb496	68769d71-b6a1-42e3-95cc-7bf4842e6f17	auth:logout	info	\N	2026-05-11 16:14:51.81901+00	\N
0635625f-312e-4819-8bfa-3063a297382b	\N	error:unhandled	fatal	\N	2026-05-11 16:15:40.544652+00	You must be logged in
3364d56d-a521-4804-a7ae-5a9151490c32	68769d71-b6a1-42e3-95cc-7bf4842e6f17	auth:login	info	\N	2026-05-11 16:15:48.34552+00	alden@gmail.com
d3ee83fb-0987-4a83-8292-cb4413d255bc	\N	cache:hit	info	\N	2026-05-11 16:15:57.691784+00	leaderboard:scope=global:cursor=:limit=3
ed4ed9ec-2094-4539-a3e4-8975b030fe9c	\N	cache:hit	info	\N	2026-05-11 16:16:01.222028+00	leaderboard:scope=global:cursor=:limit=3
e9b9464c-7fcf-4371-acd3-a6848b8121c1	\N	cache:hit	info	\N	2026-05-11 16:16:04.651939+00	leaderboard:scope=global:cursor=:limit=3
fa6539c0-4f0b-4001-b4b0-8c0158fe6039	\N	cache:hit	info	\N	2026-05-11 16:16:12.191184+00	leaderboard:scope=global:cursor=:limit=3
6cef25c1-f054-4112-a150-c5797360ed35	\N	cache:hit	info	\N	2026-05-11 16:16:12.809371+00	leaderboard:scope=global:cursor=:limit=3
1d5179f6-0710-448d-b08c-0c7d021a1eb6	\N	cache:hit	info	\N	2026-05-11 16:16:13.586428+00	leaderboard:scope=global:cursor=:limit=3
52a7c9ad-a71f-4eaa-93c7-597ed438c6c5	\N	cache:hit	info	\N	2026-05-11 16:16:16.448457+00	leaderboard:scope=global:cursor=:limit=3
364c0085-8b58-42d1-97fb-83889bb24670	\N	cache:hit	info	\N	2026-05-11 16:18:00.58828+00	leaderboard:scope=global:cursor=:limit=3
0d6d67ff-f09a-43e9-b90f-4185824cd512	\N	cache:hit	info	\N	2026-05-11 16:18:09.191032+00	leaderboard:scope=global:cursor=:limit=3
b6f84485-4e66-4190-8547-12c21b4e0dc8	\N	cache:hit	info	\N	2026-05-11 16:18:11.095455+00	leaderboard:scope=global:cursor=:limit=3
072a308a-a4d9-4ce0-b0c6-86332d01294f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-11 16:18:57.185113+00	\N
083824e3-f0c7-43dc-90fc-1b54cc5a7f14	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-11 16:18:58.452291+00	\N
d216a3af-1c7b-4b54-9b60-87f65220cec4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-11 16:18:59.008941+00	\N
4a0d28d9-3540-4385-b07e-530fe146822a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-11 16:18:59.784666+00	\N
57d9bb08-295e-443e-918a-53d69f4e364b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-11 16:19:00.410937+00	\N
4dfa187b-dfa1-47a0-bff3-a067c34211d0	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-11 16:19:01.927138+00	\N
9ea61769-d0b6-482a-bed8-f147c882fa12	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-11 16:20:35.677768+00	\N
45e4bab3-08a9-43d7-b7a2-ca8bcf48e85f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-11 16:21:07.472347+00	\N
07b024fe-b077-4a83-8260-4cab934e67ca	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-11 16:21:11.190171+00	\N
f9b793cf-d475-497e-a87e-11e5560662cf	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-11 16:21:11.799169+00	\N
42b887ce-5b86-405b-b051-158a9cf1af25	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-11 16:21:12.357679+00	\N
4e5db44b-4ef2-4b6d-813f-ad85c08e1db3	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-11 16:21:12.982983+00	\N
4da9825a-20ca-40cb-bb23-7a80debe3798	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-11 16:30:02.56341+00	\N
bd18c5c9-81ee-46fc-9029-6fa86fb4ca15	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-11 16:30:04.539193+00	\N
862564c8-1536-43d2-a8a1-e45218c672a5	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-11 16:30:05.131764+00	\N
2db1cde6-b9dc-4bbb-a3c2-824c23150cb5	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-11 16:32:21.762718+00	\N
68151377-2f23-484c-9bc2-76850ff46f54	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-11 16:32:22.623289+00	\N
db5e3289-a75f-43d1-bc8e-80a18d201117	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-11 16:32:23.356574+00	\N
2ecdbe43-880d-4ab3-9566-5b820464435a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-11 16:32:24.396972+00	\N
701550a8-a61b-452e-9fe5-844f3b22c0a7	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-11 16:32:33.113126+00	\N
b9398ad9-2c15-4df3-8d7c-419bc7367884	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-11 16:32:33.569679+00	\N
c4bf4456-1c3e-4b5c-a593-31418b77ef61	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-11 16:32:34.624522+00	\N
45fe57be-bef8-4dda-b8ba-8a1676b248d3	\N	cache:miss	info	\N	2026-05-12 04:07:24.256356+00	leaderboard:scope=global:cursor=:limit=3
3c9967ef-3d8f-4fa3-98b5-486779416b95	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:07:25.809409+00	\N
6f69b4d3-b23b-40af-a90d-b9fdc4b47440	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:07:27.258727+00	\N
70dee6df-cd11-4a02-9d73-c2c99af01b6f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 04:07:27.958385+00	\N
6fa6f658-fe7f-42c2-b016-813ecbc31681	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 04:07:31.628858+00	\N
90ce620c-ecd4-4874-b9ec-5c01328a394d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:07:32.682393+00	\N
a741da02-f1bf-4905-814a-51b0c0cddcd2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:07:33.506591+00	\N
2012946a-119c-4f6f-b988-f14f51e00aeb	\N	cache:hit	info	\N	2026-05-12 04:07:53.3105+00	leaderboard:scope=global:cursor=:limit=3
985ef5ef-dcb9-4ee3-b255-003e1f59cdd6	\N	cache:hit	info	\N	2026-05-12 04:08:01.877798+00	leaderboard:scope=global:cursor=:limit=3
a65db731-2069-4814-8323-b0cb460049f6	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:08:03.996941+00	\N
45ec1154-9bf5-44b7-bd78-9767fa5a79af	\N	cache:hit	info	\N	2026-05-12 04:08:05.246878+00	leaderboard:scope=global:cursor=:limit=3
2882cf5f-dad7-42d6-aa8c-594dc3891d17	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:08:06.750738+00	\N
d1a02b30-4029-40f9-8b1f-f28f2b94a05c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:08:08.065018+00	\N
8b105409-7194-47a1-9d8d-cf49ee1838ef	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 04:08:08.961394+00	\N
045e07a6-45bd-4615-83c9-2faa9810c9ea	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:08:09.970552+00	\N
5c417107-c6a4-4e01-a787-9a93e3f878da	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 04:08:10.578432+00	\N
d5751ad6-81e9-4f89-a465-d03b7e7f4035	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 04:12:38.921773+00	\N
5a390c3e-df82-49ac-8d65-cfc69540ea6d	\N	cache:pruned	info	\N	2026-05-12 04:16:23.177216+00	leaderboard:scope=all:
8f202e35-a586-4dd8-b390-b34ec750cb30	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 04:16:35.722066+00	\N
c0764642-172f-4017-813e-bebbe230b325	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:16:38.488292+00	\N
49749212-60af-4630-a3cc-faf3500dbecf	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:16:39.671697+00	\N
5d45cec7-524b-4472-b9cd-5827afa1038d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:16:40.86067+00	\N
93a9a480-1aa9-419c-8e5b-7260fb49c563	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 04:16:41.654906+00	\N
a201ed52-e851-4f72-9c1d-841d3171454b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:16:42.290128+00	\N
779f4738-1884-41b0-91b9-ebec59b73299	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:16:42.971869+00	\N
7ffa7dc7-95c0-4190-8093-080214fb69f9	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:16:43.844349+00	\N
f39fcac4-d531-460b-ad7c-2451dfa027ba	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 04:16:44.78738+00	\N
0c7bea14-b0ed-49d1-8632-0fa0e7dbcfe0	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:16:51.670822+00	\N
a8bf3887-c4d3-424c-bb57-594057e1a186	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:17:25.074085+00	\N
a18953bd-05dd-4682-bef2-1247c41e852d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:17:48.87538+00	\N
ff13cd2d-19c6-4926-9f6f-bd7d6048d8b2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:18:06.622801+00	\N
2078828c-8a2e-429a-b059-2473c0bf7fc4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:18:13.433948+00	\N
77f411b3-287d-4ed1-9fbf-dff19978ae52	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:18:20.671462+00	\N
247ed487-44a4-4662-aa2c-0be623c65e67	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:18:25.508137+00	\N
40cf393c-fff7-4468-be04-f39cb1cc2f53	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:18:29.364228+00	\N
409f5eb6-72e8-4b86-99a4-3a0eccde2306	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:18:36.714314+00	\N
6ceb890c-c159-4142-b780-57a5722279c6	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:19:03.080486+00	\N
b5ba059f-7fa8-4a24-8fe5-61be91b15e86	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:19:10.026819+00	\N
975aed39-c837-4c9b-9c5d-222f864b726e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:19:10.132089+00	\N
67da6c79-56e3-4856-8bcc-66f9ab375e5f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:19:35.344769+00	\N
03458816-9530-4c94-b093-e18b9f8ac641	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:20:36.091791+00	\N
356a0a2d-6f30-43b6-a1b2-3f4320e39c22	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:20:40.410643+00	\N
8ef42458-af4b-4614-befc-f2754d4b4a6d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:20:44.525443+00	\N
b01711eb-ba39-4acd-8871-8278f09d7e6a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:20:49.7783+00	\N
5708a026-6391-4529-9572-818cd2806a7a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:21:24.381526+00	\N
7fffeb6f-03a4-4a78-86aa-c9dbb348fbfd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:21:32.872375+00	\N
0f5ab051-d4b8-4fcc-9ffc-b032b8ef0de1	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:21:40.657876+00	\N
a0b35a69-081f-465f-a949-8758d155e17c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:21:59.849375+00	\N
38c6bfb4-3125-405f-a980-32e0062ccc77	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:22:04.878568+00	\N
f208bf2b-1205-499a-82fe-453ee6cfaa81	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:22:12.250264+00	\N
b32dc231-d63d-43f1-87ae-e56bbd57e4ea	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:22:23.266367+00	\N
d67ece91-80d6-458e-8666-5f1102ea7dc8	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:22:27.203546+00	\N
a45aa99d-441c-4432-9aae-ce36a06025ec	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:23:20.730735+00	\N
36b797ea-1fd3-430b-95f6-5d4de094bb3d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:23:42.285838+00	\N
c9b44621-c88b-4724-8754-171a18d40790	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:23:44.590378+00	\N
e60fe84b-2f6d-4662-8a42-5e4366c6f8bd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:23:59.003625+00	\N
cd4455fc-5570-4cf5-9393-2f69494320f1	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:24:03.976927+00	\N
5bf355e0-0237-4857-b4e9-c62658f841c3	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:24:08.720839+00	\N
569b3a90-3e7d-43e9-9248-b9c0748cc536	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:24:13.910657+00	\N
b84c1df3-4503-4d1c-a89e-ac694b211e5a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:24:36.062458+00	\N
c9effc6b-798c-48b5-a6f2-d5708e39aaae	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:24:39.007028+00	\N
0ada0bca-5e3b-421e-a476-64b0fc7d53bd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:24:39.458682+00	\N
0308d46b-bf00-4194-b944-480ca6ecc8dd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:24:40.374992+00	\N
ac23c61d-f7f1-400e-a5ae-532a6ac374f4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:24:40.960948+00	\N
0fed88ca-703a-4a8d-86f6-2008da45bf26	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:24:41.919834+00	\N
035575ec-3e83-48db-8d8d-1442ad796f1f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:26:32.749067+00	\N
535cbd40-92de-4936-9086-f1dd728f1333	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 04:26:36.45522+00	\N
b8baa824-f2e3-4882-bf32-48db78a33d2e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:26:36.864815+00	\N
3976b7d3-1696-4c55-8f06-4009058f46c4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:26:39.511149+00	\N
9800c6a5-7289-44f2-b699-f0eeabc128e2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:26:40.619556+00	\N
03a9f696-e7c9-4518-bb02-48f93a3306f5	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:26:41.864418+00	\N
eeb9fbd5-20cd-4008-b99d-668a3b45ead1	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:26:42.863461+00	\N
0ee91af6-9ee0-4ffc-97a3-a917ede1a095	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:26:43.433449+00	\N
b0c26645-6277-42a7-9a9b-44b3d8e265cb	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:26:44.164517+00	\N
2a49f14b-0d1d-4201-8861-e2ac82ffc053	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:26:44.779211+00	\N
8af6dcfe-d5b7-4ec1-b79a-9565a8788f07	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:26:45.644683+00	\N
165fb563-75fa-4ba0-93fe-cd596497c6ed	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:26:46.15118+00	\N
64d980e8-c11a-4c08-b07e-f27ab894c2c8	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:26:52.362758+00	\N
efd570e2-9951-4b88-ab66-fcd38138bdbc	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:26:52.985036+00	\N
aae8e88b-5784-4af1-8a1d-6b39872cbe56	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:26:54.49741+00	\N
d89ab690-25da-4d49-8b5b-356260316189	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:26:54.969308+00	\N
368d41a7-940c-4dbd-bb3b-9f72e0d20e68	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:27:27.345611+00	\N
e3b8e2ba-3fa5-4e62-9449-d3a285684205	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:27:27.823702+00	\N
a3e184fd-d3cb-467b-9dd8-16eac71be5a5	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:27:28.473944+00	\N
126fe3fe-5a3b-448a-b481-ae5212d38274	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:27:29.881437+00	\N
809dadb7-8b3f-4475-935e-4d0103022388	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:27:31.076119+00	\N
4773e0d4-695f-430d-9a16-c88c19af676c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:27:32.468295+00	\N
67eaa061-8cd6-4d22-99a4-5dfb5f78c152	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:27:33.715618+00	\N
115dd7d3-2b73-4e0e-a4ec-4da08d93b348	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:27:36.841506+00	\N
269c494a-5fb4-4385-9b57-c8112bebb66f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:27:38.207725+00	\N
58128a86-5d84-4e4b-a536-ee81d5547bf7	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:27:51.78752+00	\N
3a7cb5a6-c514-49a0-a09c-e90100dbd9ee	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:27:52.526136+00	\N
8f18c41c-af53-4c71-ae90-0d9e042bd23d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:27:55.379206+00	\N
f78d956c-59bc-4802-a93a-4bc375d176e3	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:27:56.595033+00	\N
f98b6002-44c6-41a0-a40f-222ef46d6ad1	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:27:57.667866+00	\N
392ca905-0b55-4d53-8d74-b2f22540144f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:27:59.573115+00	\N
77c8da31-e176-4630-b077-55d3edc2cfca	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:28:00.919196+00	\N
02ebfb2b-5c8b-4990-aacd-f2553d9600b4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:28:12.706257+00	\N
0912370f-c659-414e-9bf6-b0e3852dec1b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:28:13.671678+00	\N
0fa6e12a-77c6-43c8-af7f-ff73fb19c3e8	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:28:19.740097+00	\N
028e26b9-ce62-49a5-8adf-478084bccbe1	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:28:31.512111+00	\N
b94e48b3-a644-4c03-8176-e709f098d0bb	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:28:39.706788+00	\N
a8735842-4882-4e51-94df-9853b242634c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:28:40.445633+00	\N
7097d374-ab81-48d4-aca7-742dee7cc451	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:28:55.530669+00	\N
b0e0bbe7-fee2-4b74-82af-d51c872b3cec	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 04:28:58.335709+00	\N
05fa2777-c0e3-4599-8d62-a14a93b9283f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 04:29:01.671721+00	\N
d1bfd42b-6828-48b3-bc91-07a2d197dbbb	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 04:28:12.988523+00	\N
acbe031b-80bd-4af8-82d0-6f00e601883c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:28:30.477907+00	\N
4269d2c0-7e2c-4e47-b240-7c8b22beab08	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:28:32.983502+00	\N
e583d7e5-dc50-4ce3-9104-f8e7d72c6138	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:28:56.154212+00	\N
5172f670-9ad3-4212-87d7-0619484b32d8	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:28:57.270534+00	\N
bab68f01-cfe5-42e3-9e2c-c45c8684ac9f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:28:20.834299+00	\N
08a23874-c350-47b1-986a-8bbe0ea8ff39	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:28:30.868529+00	\N
cd7f9361-8d7f-4078-9af9-19aed78fa3e4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:28:41.575442+00	\N
2c1423e5-e44a-46f4-97d9-2f264dbc439b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:28:44.918901+00	\N
e2a79d1a-55d6-413e-83e9-7811aa7d58ba	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:28:59.492249+00	\N
cba60ebf-248b-4eee-996d-334bafdd9215	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 04:30:20.640392+00	\N
9f4a3e74-e5c7-4ae8-9b3f-a7220e11d723	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 04:30:25.500861+00	\N
466b7d01-8281-4634-82e2-81d2d5425af1	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:30:31.702601+00	\N
3149364a-0d9e-4fc9-990b-dec6ed04b645	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 04:30:32.205959+00	\N
dc1ae65d-1714-4738-a364-c1934fa78074	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 04:30:33.941202+00	\N
06c1a743-2031-4405-87ba-e88bf49f5da5	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 04:30:34.489713+00	\N
4e98cf62-f207-4939-ab44-199d3661c7fe	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {"level_id": "1"}}	2026-05-12 04:30:37.122902+00	\N
aa79d4a2-d97e-4c24-a92f-d92a5021d2b0	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {"level_id": "1"}}	2026-05-12 04:30:38.966969+00	\N
1a0b296b-4fe2-4ac1-b5ed-0e1d3904f76c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {"level_id": "1"}}	2026-05-12 04:30:42.168144+00	\N
d9b9692c-fd9a-421a-b1b0-12f7ed6382a0	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {"level_id": "1"}}	2026-05-12 04:31:31.819393+00	\N
ff6c8021-5525-4523-8c30-185f163b004f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {"level_id": "1"}}	2026-05-12 04:31:37.739553+00	\N
198f844b-0763-4980-9042-03f5b3ebb014	\N	cache:miss	info	\N	2026-05-12 04:31:43.012616+00	leaderboard:scope=global:cursor=:limit=3
0e173229-aa6f-4004-8785-699d846f37b3	\N	cache:hit	info	\N	2026-05-12 04:32:27.228723+00	leaderboard:scope=global:cursor=:limit=3
0b8db5b4-64e3-428e-a459-fd9b51e3225e	\N	cache:hit	info	\N	2026-05-12 04:32:37.198292+00	leaderboard:scope=global:cursor=:limit=3
bf9f4e0e-040e-48f4-9717-b8265b284769	\N	cache:hit	info	\N	2026-05-12 04:32:53.457997+00	leaderboard:scope=global:cursor=:limit=3
5e6b0b32-4535-416c-b468-1c2df1382a84	\N	cache:hit	info	\N	2026-05-12 04:33:01.283593+00	leaderboard:scope=global:cursor=:limit=3
cdf35e18-3a3c-4edf-a27d-706995dac384	\N	cache:hit	info	\N	2026-05-12 04:33:03.527612+00	leaderboard:scope=global:cursor=:limit=3
30c8a67d-df8c-4dad-9308-9227e41f940f	\N	cache:miss	info	\N	2026-05-12 04:33:06.001583+00	leaderboard:levelId=1:period=alltime:scope=level:cursor=:limit=3
627a0913-0474-4f2f-9d81-f38451c2550d	\N	cache:hit	info	\N	2026-05-12 04:33:49.319945+00	leaderboard:levelId=1:period=alltime:scope=level:cursor=:limit=3
18d38684-f56d-4275-ab19-554419f50dce	\N	cache:hit	info	\N	2026-05-12 04:34:30.728956+00	leaderboard:levelId=1:period=alltime:scope=level:cursor=:limit=3
cf1a9087-8283-433e-bd61-22bc1131c27d	\N	cache:hit	info	\N	2026-05-12 04:34:37.090838+00	leaderboard:levelId=1:period=alltime:scope=level:cursor=:limit=3
10e554ca-245f-4799-bd66-5f79f130e763	\N	cache:hit	info	\N	2026-05-12 04:34:44.647725+00	leaderboard:levelId=1:period=alltime:scope=level:cursor=:limit=3
01750130-a8ff-4e88-836a-f4e89799079c	\N	cache:hit	info	\N	2026-05-12 04:34:44.727991+00	leaderboard:levelId=1:period=alltime:scope=level:cursor=:limit=3
aa555a08-7304-41aa-969f-c07a71192671	\N	cache:hit	info	\N	2026-05-12 04:34:48.478509+00	leaderboard:levelId=1:period=alltime:scope=level:cursor=:limit=3
e4b0b688-53de-4166-8c10-055ccfd699d0	\N	cache:hit	info	\N	2026-05-12 04:34:52.950295+00	leaderboard:levelId=1:period=alltime:scope=level:cursor=:limit=3
2b5374b0-0a82-4bc2-8e1c-5236851bc12f	\N	cache:hit	info	\N	2026-05-12 04:34:56.238811+00	leaderboard:levelId=1:period=alltime:scope=level:cursor=:limit=3
8e7641d4-89f4-49fd-b032-42c94d9e3232	\N	cache:hit	info	\N	2026-05-12 04:35:01.857661+00	leaderboard:levelId=1:period=alltime:scope=level:cursor=:limit=3
57d88bf4-7aae-4483-a8f7-d549324e94be	\N	cache:hit	info	\N	2026-05-12 04:35:09.621108+00	leaderboard:levelId=1:period=alltime:scope=level:cursor=:limit=3
dec484eb-2d7b-4bb2-b474-af413b03586a	\N	cache:hit	info	\N	2026-05-12 04:35:12.66371+00	leaderboard:levelId=1:period=alltime:scope=level:cursor=:limit=3
2c98ee2c-1064-43a2-8d70-81b9da3a13f7	\N	cache:hit	info	\N	2026-05-12 04:35:15.586617+00	leaderboard:levelId=1:period=alltime:scope=level:cursor=:limit=3
f04a6f1f-103c-4e10-ad2d-fce319bbb206	\N	cache:hit	info	\N	2026-05-12 04:35:20.569621+00	leaderboard:levelId=1:period=alltime:scope=level:cursor=:limit=3
23f5ae8c-f1bb-4379-aec6-8b74aa6292fa	\N	cache:hit	info	\N	2026-05-12 04:35:28.285435+00	leaderboard:levelId=1:period=alltime:scope=level:cursor=:limit=3
781c7751-75ca-4693-8c08-967da1bcdf23	\N	cache:hit	info	\N	2026-05-12 04:35:35.575541+00	leaderboard:scope=global:cursor=:limit=3
4ceefd4b-3f08-4b98-a409-dc7fe5f3116f	\N	cache:hit	info	\N	2026-05-12 04:35:55.317641+00	leaderboard:scope=global:cursor=:limit=3
5e7529e1-8e1b-4c36-a2d4-cf7764ac2068	\N	cache:hit	info	\N	2026-05-12 04:36:01.219644+00	leaderboard:scope=global:cursor=:limit=3
dc4a00e0-f084-4a45-9767-fce4857359f3	\N	cache:hit	info	\N	2026-05-12 04:36:08.224006+00	leaderboard:scope=global:cursor=:limit=3
21836e66-def2-4633-9239-cb234f6adbb3	\N	cache:hit	info	\N	2026-05-12 04:36:11.002657+00	leaderboard:scope=global:cursor=:limit=3
290f7fcd-df0b-4ed2-bcb1-41b4920872fd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 04:36:21.499857+00	\N
4488807c-7f67-4dc6-b788-941ab91f083b	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 7, "session_ids": []}	2026-05-12 05:00:01.126089+00	\N
e4c95fae-6df7-496f-bdeb-83cba177d268	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 05:30:21.434677+00	\N
2f2fdc5f-911c-480a-8ac3-c7b813d9b7a1	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 05:33:00.581297+00	\N
a13ade08-aa67-4e1e-83b3-a89b2a499e60	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 05:33:01.1372+00	\N
bfa0d33f-07c6-4620-b0a2-70d83defdc08	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 05:34:48.446031+00	\N
2d06b76a-0f2d-4001-8206-70c6cba92376	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 05:34:49.139736+00	\N
8021a0de-dc05-4774-997e-eef6f2084393	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 05:34:49.689769+00	\N
9b6ee818-51a3-4d65-a7a6-855737651685	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 05:34:52.389964+00	\N
00819d62-7e9f-472c-bcab-f387bda26ff1	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 05:34:54.257765+00	\N
23984650-d767-435b-82e2-e6f275f0f071	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 05:34:54.739271+00	\N
50842605-7352-46e2-95f1-7519ba489c22	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 05:34:55.737075+00	\N
ed25eab9-5483-436b-b896-0ccafbc630e5	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 05:34:56.488765+00	\N
c37a38a2-72b1-4254-a57f-0948561114b9	\N	cache:miss	info	\N	2026-05-12 05:34:58.24845+00	leaderboard:scope=global:cursor=:limit=3
324e5628-56c5-40f0-bea5-be402859b89b	\N	cache:hit	info	\N	2026-05-12 05:42:08.242088+00	leaderboard:scope=global:cursor=:limit=3
04f2d979-8386-4f80-bfae-17ac48fb4146	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 05:42:09.669016+00	\N
a82ac983-bdd6-4e25-b908-841c5db1519f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 05:42:13.497217+00	\N
d4ec3e0d-be92-47c1-840d-0a691effa7ad	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 05:42:19.025525+00	\N
6b9787a3-ab14-4f33-bb49-2f4b529caaa4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 05:43:14.668221+00	\N
ebeadd78-d26b-4a78-9332-e2ba94005b25	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 05:43:15.824636+00	\N
3a147150-85b7-45dd-ad8c-be2d4a95db28	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 05:43:16.369682+00	\N
070330ba-4f3e-4987-a234-f500076950db	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 05:43:17.578086+00	\N
94bce081-4e94-4d7e-8610-cad2eec5f243	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 05:43:18.218058+00	\N
c0d53310-50d3-4103-b67b-1a27c98fc18f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 05:43:37.839788+00	\N
535c2685-6967-4ea4-8a35-26d35d7bc11f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 05:43:40.734461+00	\N
ef979336-fcd7-489c-86cf-ce0d7cf54167	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 05:43:45.573633+00	\N
79faaaa8-1301-474a-9440-dd30501f6e5f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 05:44:11.007004+00	\N
7abe9c92-2c7f-488f-a3a1-5ca3db87cede	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 05:44:20.748743+00	\N
7512f252-835b-4e5c-a5de-456c02cb628c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 05:43:40.8249+00	\N
2db2ded0-5055-431d-87b9-981ae8fa9f34	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 05:44:08.060869+00	\N
3070a2b6-0654-4770-a85b-063350b60dd7	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-12 05:44:11.134218+00	\N
c8c414cf-4a0d-46c0-86ee-592b027ff2ec	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 05:44:30.494204+00	\N
d4f48567-e11e-40b9-8050-dab1d19b8366	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 05:44:31.258322+00	\N
a3e1aea4-1ec4-426c-96d9-1840fba1f936	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 05:44:40.795792+00	\N
4e8f15d0-0dde-4df0-bf50-ab21fe84fda6	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 05:44:48.555178+00	\N
9494c0a1-8f5b-4541-9df4-858c5ffcd447	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 05:46:55.97222+00	\N
16ee1776-032a-4f80-a40c-cc4412a65cd2	\N	cache:miss	info	\N	2026-05-12 05:46:57.565452+00	leaderboard:scope=global:cursor=:limit=3
7136212f-db05-4aac-b24f-cbacd10b2865	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 05:46:58.226926+00	\N
17f90417-2588-4276-a58a-b24080aeb2d7	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 05:47:26.919615+00	\N
89fe0e4b-9194-4fba-a9b9-9c4c1773a767	\N	cache:hit	info	\N	2026-05-12 05:47:54.925284+00	leaderboard:scope=global:cursor=:limit=3
74cdd641-a81f-4824-bbad-d27ffeaf1fc9	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 05:47:55.280253+00	\N
713071a5-4411-4778-9e9d-905232b6e35b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-12 05:49:38.694964+00	\N
bd027e65-b25d-4b45-87a6-dd5d4ad93174	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-12 05:49:39.666011+00	\N
ff178687-bd3e-4eca-829e-22af67ede426	\N	cache:miss	info	\N	2026-05-12 05:49:49.629608+00	leaderboard:levelId=1:period=alltime:scope=level:cursor=:limit=3
145db2fc-7e6d-47fe-a0a7-fb929d09ce4c	\N	cache:hit	info	\N	2026-05-12 05:52:03.836649+00	leaderboard:scope=global:cursor=:limit=3
4a6a9efc-e394-486a-8d5c-4e969f588ee4	\N	cache:hit	info	\N	2026-05-12 05:52:09.493946+00	leaderboard:scope=global:cursor=:limit=3
b76665af-b37b-428e-a1a3-db87d960dc0c	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 6, "session_ids": []}	2026-05-12 06:00:00.275147+00	\N
2cad1ac7-ac69-4524-b257-76d1388c3d84	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 10, "session_ids": []}	2026-05-12 07:00:00.221259+00	\N
3d64db01-b407-4e11-ad82-0cfa2f5ab384	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 21, "session_ids": []}	2026-05-12 08:00:00.620253+00	\N
6df7dc8d-f03f-4334-8382-c27805cfd55b	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 8, "session_ids": []}	2026-05-12 09:00:00.736159+00	\N
3963e48c-2675-445e-b84f-0d1bdc36f3ae	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 8, "session_ids": []}	2026-05-12 10:00:00.83403+00	\N
33448dad-537e-4ec4-be07-fa75a2d98b1e	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 9, "session_ids": []}	2026-05-12 11:00:00.228963+00	\N
b2cbc9c4-b149-43a2-9f1e-fc2cf0995e5c	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 8, "session_ids": []}	2026-05-12 12:00:00.864227+00	\N
feab1d4b-3370-4fe2-b789-cbbda37b4e19	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 9, "session_ids": []}	2026-05-12 13:00:01.130558+00	\N
a4ecb3a8-16a9-4d55-b00e-a39636d51a80	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 110, "session_ids": []}	2026-05-12 14:00:00.861459+00	\N
ecc5629e-18cc-42d9-85b0-ac48f9ecb346	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-12 15:00:01.028012+00	\N
156828da-150b-4f05-815e-55a5f0ba31a3	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 6, "session_ids": []}	2026-05-12 16:00:00.370306+00	\N
612d0c12-ecfb-4f1e-b49e-4dec84219bca	\N	error:unhandled	fatal	\N	2026-05-13 16:25:45.017478+00	You must be logged in
5c165161-523a-42c1-9d7f-7114b73add94	68769d71-b6a1-42e3-95cc-7bf4842e6f17	auth:login	info	\N	2026-05-13 16:26:32.036474+00	alden@gmail.com
95c309bc-b85d-4986-a3e2-b95c81035885	\N	cache:miss	info	\N	2026-05-13 16:27:08.602581+00	leaderboard:scope=global:cursor=:limit=3
9a0a29fc-68cc-486d-8625-127889fca4b9	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-13 16:27:13.295379+00	\N
3b94afec-a2f7-494f-843d-948a6ba4d055	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-13 16:27:15.000214+00	\N
cc398632-47b7-4602-af49-c5eee30e827c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-13 16:27:15.55272+00	\N
e5efaeed-8937-4c9d-9e6b-2a9a8cebb102	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-13 16:27:21.708952+00	\N
ce7acd1b-9358-4f86-9240-2bcc63f8f761	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-13 16:27:26.523293+00	\N
b9a6be29-616f-4372-a491-7d1fb7433dd6	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-13 16:27:30.580609+00	\N
d4566967-c0b1-41a1-ad0d-613f585304ce	\N	cache:hit	info	\N	2026-05-13 16:27:31.548202+00	leaderboard:scope=global:cursor=:limit=3
3ad16fef-cae3-4dde-8b36-f8a576fd3d01	\N	cache:hit	info	\N	2026-05-13 16:27:33.488859+00	leaderboard:scope=global:cursor=:limit=3
78a45c63-40a9-4f8f-816a-7637be24e45a	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-13 16:47:23.653837+00	\N
00f95fd2-5033-4970-b4d8-96620740388b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-13 16:47:46.475934+00	\N
afdffa75-e037-475d-bce8-2ead44b7618c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-13 16:47:47.340095+00	\N
d47bc761-c33a-457c-bdbb-99e196dac66d	\N	error:unhandled	fatal	\N	2026-05-13 16:48:14.328256+00	INSERT has more expressions than target columns
85a8e98d-88ca-4b8c-a816-82d23d91f526	68769d71-b6a1-42e3-95cc-7bf4842e6f17	session:started	info	{"level_id": 1, "session_id": "e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948"}	2026-05-13 16:49:50.629297+00	\N
0c092cfe-40c4-4718-bfbc-8f27c134f6b7	\N	cache:pruned	info	\N	2026-05-13 16:50:25.251829+00	leaderboard:scope=global:
47066341-45a7-4f10-ace7-2da4e7da5418	\N	cache:pruned	info	\N	2026-05-13 16:50:25.265167+00	leaderboard:levelId=1:scope=level:
3c95640b-9b62-4a76-b0f6-d638e4c4179b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	session:ended	info	{"session_id": "e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948"}	2026-05-13 16:50:25.264714+00	\N
1f06ee48-58bc-4968-934a-156c4061297f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	elo:updated	info	{"reason": "session_completed", "session_id": "e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948"}	2026-05-13 16:50:25.26628+00	\N
c89c21be-d3a7-48e0-bd69-6e01d12442bc	\N	cache:miss	info	\N	2026-05-13 16:50:58.602711+00	leaderboard:scope=global:cursor=:limit=3
28a24834-c682-4000-952a-5b56cf4e8f65	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-13 16:51:00.807453+00	\N
f92e8356-367e-46cf-bac4-f13811cf406e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-13 16:51:02.502531+00	\N
519756ce-be07-4a65-ba13-7cb878e7f6bd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-13 16:51:03.147773+00	\N
542a8204-22f2-4b84-b0af-7f935d53302e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-13 16:51:08.731135+00	\N
6a5aa8f7-b769-40b6-ac51-f1d1e1d69ad3	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-13 16:51:09.508464+00	\N
18cc4963-ab9d-4609-bc3e-38218f3f4d2e	\N	cache:hit	info	\N	2026-05-13 16:51:12.97882+00	leaderboard:scope=global:cursor=:limit=3
d71e6c3b-e645-438c-9a76-69f01ff1e7dc	68769d71-b6a1-42e3-95cc-7bf4842e6f17	session:started	info	{"level_id": 1, "session_id": "6bb24d15-d590-4511-984f-a00e142d22a9"}	2026-05-13 16:52:45.435681+00	\N
29b390f2-0e0b-4f67-8ea9-ce7d3dc51d85	\N	cache:hit	info	\N	2026-05-13 16:52:47.477395+00	leaderboard:scope=global:cursor=:limit=3
fe81101b-e9b4-474e-86ce-81e8d8413a00	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-13 16:52:54.354445+00	\N
a84c044a-1f54-424e-a239-6cfe5803ce01	68769d71-b6a1-42e3-95cc-7bf4842e6f17	session:resumed	info	{"session_id": "6bb24d15-d590-4511-984f-a00e142d22a9"}	2026-05-13 16:53:03.135764+00	\N
b52c34a3-5cd6-490b-a0b4-f06022b46ccd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-13 16:53:27.956996+00	\N
19195e8e-a257-4ad6-9dd5-e64eed4b197d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	session:resumed	info	{"session_id": "6bb24d15-d590-4511-984f-a00e142d22a9"}	2026-05-13 16:53:40.209436+00	\N
2ee8f0be-df9d-4f88-868f-24a3becec9f1	\N	cache:pruned	info	\N	2026-05-13 16:54:47.299808+00	leaderboard:scope=global:
c41fdbdc-25ee-4490-bf23-bfab64e0b4ed	\N	cache:pruned	info	\N	2026-05-13 16:54:47.306131+00	leaderboard:levelId=1:scope=level:
564492aa-408f-4234-a27a-c651a0cc7628	68769d71-b6a1-42e3-95cc-7bf4842e6f17	session:ended	info	{"session_id": "6bb24d15-d590-4511-984f-a00e142d22a9"}	2026-05-13 16:54:47.306405+00	\N
326b7604-5512-4aae-9062-d590a752086b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	elo:updated	info	{"reason": "session_completed", "session_id": "6bb24d15-d590-4511-984f-a00e142d22a9"}	2026-05-13 16:54:47.307228+00	\N
af55169b-aa28-473b-95dd-3e065490c5f7	\N	cache:miss	info	\N	2026-05-13 16:55:30.351871+00	leaderboard:scope=global:cursor=:limit=3
781fd94f-f161-4c75-8b91-7d5b9d54ef41	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-13 16:55:31.166256+00	\N
b4e87176-4711-4f16-9336-f239dd971f37	\N	cache:hit	info	\N	2026-05-13 16:57:41.841346+00	leaderboard:scope=global:cursor=:limit=3
06021dcc-f92e-44d2-ae0f-d3b6b6b23bcd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-13 16:57:43.021686+00	\N
814562d2-059f-44f9-bd5e-03cbae227126	\N	cache:hit	info	\N	2026-05-13 16:57:43.735048+00	leaderboard:scope=global:cursor=:limit=3
c856b51b-abf5-46de-bcab-27b5aa322700	\N	cache:miss	info	\N	2026-05-13 16:57:48.406991+00	leaderboard:levelId=1:period=alltime:scope=level:cursor=:limit=3
247edc2e-a91a-427b-a9cd-98ec7cc59fd0	\N	cache:hit	info	\N	2026-05-13 16:57:49.523743+00	leaderboard:scope=global:cursor=:limit=3
74949691-4d55-4a3a-ae04-cb6f784dc7a0	\N	cache:hit	info	\N	2026-05-13 16:57:50.523687+00	leaderboard:levelId=1:period=alltime:scope=level:cursor=:limit=3
935d9113-b362-42ba-a569-298f46417b70	\N	cache:miss	info	\N	2026-05-13 16:57:52.982879+00	leaderboard:levelId=1:period=week:scope=level:cursor=:limit=3
7df9f805-2115-486b-942b-f7a6b7c59c30	\N	cache:hit	info	\N	2026-05-13 16:57:54.089947+00	leaderboard:scope=global:cursor=:limit=3
e1ea6dd6-10a6-4ff8-8192-b740a2ce72d1	\N	cache:miss	info	\N	2026-05-13 16:57:57.265276+00	leaderboard:levelId=1:period=month:scope=level:cursor=:limit=3
ca3756ae-f43e-4fce-af86-2268048aff77	\N	cache:hit	info	\N	2026-05-13 16:57:58.144754+00	leaderboard:levelId=1:period=alltime:scope=level:cursor=:limit=3
f1230999-547d-41a3-8d80-d2f4bdb42cfb	\N	cache:hit	info	\N	2026-05-13 16:57:58.86797+00	leaderboard:levelId=1:period=week:scope=level:cursor=:limit=3
f0b52490-ad3b-4098-823c-1b04d65ded95	\N	cache:hit	info	\N	2026-05-13 16:58:02.279374+00	leaderboard:scope=global:cursor=:limit=3
b3a07fe2-40b2-469d-8823-7cb84c47c892	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 9, "session_ids": []}	2026-05-13 17:00:00.8275+00	\N
cba270e0-5094-4975-a2b2-2d4c2bed4dd6	\N	cache:miss	info	\N	2026-05-13 17:03:37.087892+00	leaderboard:scope=global:cursor=:limit=3
99a978d6-c32d-4026-b176-d8371f87aee8	68769d71-b6a1-42e3-95cc-7bf4842e6f17	session:started	info	{"level_id": 1, "session_id": "2dd947c1-bc93-495e-9adf-bb5108564fd4"}	2026-05-13 17:04:33.592923+00	\N
d38d7baa-4552-48df-8595-9cb16bca5674	\N	cache:pruned	info	\N	2026-05-13 17:04:57.561125+00	leaderboard:levelId=1:scope=level:
87d83554-b4fd-46af-9884-2ce247d9fa0b	\N	cache:pruned	info	\N	2026-05-13 17:04:57.561125+00	leaderboard:scope=global:
e17bce56-ce1f-45cb-9cd2-d1b3c16237ac	68769d71-b6a1-42e3-95cc-7bf4842e6f17	elo:updated	info	{"reason": "session_completed", "session_id": "2dd947c1-bc93-495e-9adf-bb5108564fd4"}	2026-05-13 17:04:57.571041+00	\N
6b96f5a6-877f-40e2-b455-13ca0eb12b0f	68769d71-b6a1-42e3-95cc-7bf4842e6f17	session:ended	info	{"session_id": "2dd947c1-bc93-495e-9adf-bb5108564fd4"}	2026-05-13 17:04:57.57124+00	\N
53d4d196-1638-4ccf-ac4f-71dd1eda071b	\N	cache:miss	info	\N	2026-05-13 17:05:39.508733+00	leaderboard:scope=global:cursor=:limit=3
f11a3d15-1d9d-4735-82ab-d30954a6544c	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-13 17:05:40.241391+00	\N
c633a4b4-c927-48e3-b70f-81335904b679	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-13 17:05:42.513183+00	\N
410193af-508b-4e8e-afab-cd3111d436ff	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-13 17:05:43.612139+00	\N
008db125-f0f6-4ba8-90e8-6762305129e7	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-13 17:05:44.230653+00	\N
c611be9e-2fdd-484e-a90c-2ccbd451d879	68769d71-b6a1-42e3-95cc-7bf4842e6f17	session:started	info	{"level_id": 1, "session_id": "c13ee2aa-bffc-48df-bfcb-a4e71161a911"}	2026-05-13 17:22:46.923391+00	\N
1c327c55-738e-4870-8f1d-c5d75511bba7	\N	cache:pruned	info	\N	2026-05-13 17:23:10.205131+00	leaderboard:levelId=1:scope=level:
4aefc072-c127-4b6f-859f-375d1e2ec06a	\N	cache:pruned	info	\N	2026-05-13 17:23:10.205404+00	leaderboard:scope=global:
3852c339-680b-4a6b-a32a-fd78781d501e	68769d71-b6a1-42e3-95cc-7bf4842e6f17	elo:updated	info	{"reason": "session_completed", "session_id": "c13ee2aa-bffc-48df-bfcb-a4e71161a911"}	2026-05-13 17:23:10.214793+00	\N
9080b491-997e-43be-a825-d4978a60fcf1	68769d71-b6a1-42e3-95cc-7bf4842e6f17	session:ended	info	{"session_id": "c13ee2aa-bffc-48df-bfcb-a4e71161a911"}	2026-05-13 17:23:10.214662+00	\N
31192e63-fe08-4c9f-964e-aed5c28663f5	\N	cache:miss	info	\N	2026-05-13 17:23:28.561822+00	leaderboard:levelId=1:period=alltime:scope=level:cursor=:limit=3
dedb124d-e6c7-4b6b-b829-98828f0db77b	\N	cache:miss	info	\N	2026-05-13 17:23:31.121726+00	leaderboard:scope=global:cursor=:limit=3
3cc3fcb5-da75-4885-9618-5e9def3d0fd5	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-13 17:23:35.110959+00	\N
ac4aa9a0-bb48-4214-b661-c1c3967ac345	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-13 17:25:14.407592+00	\N
d8675d0e-9ed8-4912-b128-badd5c4c225d	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-13 17:25:16.668598+00	\N
e57d815a-9e03-4a58-8744-95e1ffa23c49	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-13 17:25:19.52817+00	\N
fece73f8-bff6-4410-986d-4a437f60bfcd	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": {}}	2026-05-13 17:26:56.011386+00	\N
c1d54677-df79-4ea0-850a-65ece2f92861	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:player_viewed	info	\N	2026-05-13 17:26:56.777483+00	\N
923f00be-9c96-4669-b7ac-1db1dedd57d5	68769d71-b6a1-42e3-95cc-7bf4842e6f17	admin:sessions_viewed	info	{"filter": "active"}	2026-05-13 17:26:57.205303+00	\N
4edd02a0-2e60-4ff7-96b1-b441e7567e0b	68769d71-b6a1-42e3-95cc-7bf4842e6f17	auth:logout	info	\N	2026-05-13 17:27:07.054563+00	\N
8a206bf5-dd76-422e-ae5e-510c52438625	68769d71-b6a1-42e3-95cc-7bf4842e6f17	auth:logout	info	\N	2026-05-13 17:27:07.056208+00	\N
3b9bd216-ebf5-482f-b0bf-e2eb13deddac	\N	error:unhandled	fatal	\N	2026-05-13 17:27:08.348122+00	You must be logged in
9d81d679-6579-47c0-821b-9c7cab7030ff	\N	error:unhandled	fatal	\N	2026-05-13 17:27:15.718936+00	You must be logged in
bb392737-c5f8-4c36-a1f3-e2a1406f085d	\N	error:unhandled	fatal	\N	2026-05-13 17:27:33.135599+00	You must be logged in
ad966255-f5a9-4cdd-9b14-6d4cc4ee6af0	\N	error:unhandled	fatal	\N	2026-05-13 17:27:33.136641+00	You must be logged in
570c78da-c27d-46a2-a865-365a5f10c928	\N	error:unhandled	fatal	\N	2026-05-13 17:27:36.133744+00	You must be logged in
445c9b48-a2a6-400a-a772-94d4c746f09b	\N	error:unhandled	fatal	\N	2026-05-13 17:27:36.135176+00	You must be logged in
62197c12-5fd6-4ff4-a71f-57d2e3fe6504	\N	error:unhandled	fatal	\N	2026-05-13 17:27:38.333565+00	You must be logged in
95271c65-edd5-4a22-a5d2-f9335e11a671	\N	error:unhandled	fatal	\N	2026-05-13 17:27:38.336406+00	You must be logged in
fd83b1b8-04c5-429a-b078-f1b9998fa746	\N	error:unhandled	fatal	\N	2026-05-13 17:27:41.58291+00	You must be logged in
2505ab93-4158-4565-9340-adffc1aac1e7	ee7af00f-63bd-4f1a-9721-329432cbe1ef	auth:login	info	\N	2026-05-13 17:27:49.143514+00	shawn@gmail.com
9bebdb30-259e-4708-b6bf-ce7f69041abe	ee7af00f-63bd-4f1a-9721-329432cbe1ef	session:started	info	{"level_id": 1, "session_id": "0b7e4f0d-dd65-435a-8c9e-937306e12f73"}	2026-05-13 17:28:18.229269+00	\N
76074e83-ca10-460f-9337-dd6658c8d11e	\N	cache:pruned	info	\N	2026-05-13 17:28:36.525739+00	leaderboard:levelId=1:scope=level:
b25c3992-fb9b-40d7-b527-27e062e48b8a	\N	cache:pruned	info	\N	2026-05-13 17:28:36.525711+00	leaderboard:scope=global:
17130020-9a5a-486c-a4e1-0983a949662b	ee7af00f-63bd-4f1a-9721-329432cbe1ef	session:ended	info	{"session_id": "0b7e4f0d-dd65-435a-8c9e-937306e12f73"}	2026-05-13 17:28:36.53448+00	\N
fe5f67e5-1048-4390-8dd3-b6131e56db5e	ee7af00f-63bd-4f1a-9721-329432cbe1ef	elo:updated	info	{"reason": "session_completed", "session_id": "0b7e4f0d-dd65-435a-8c9e-937306e12f73"}	2026-05-13 17:28:36.534345+00	\N
d03cdcc5-72f7-408e-b234-80cd22dce217	\N	cache:miss	info	\N	2026-05-13 17:28:47.892029+00	leaderboard:scope=global:cursor=:limit=3
7f5f449d-45fa-474a-b255-057955a12e6a	\N	cache:miss	info	\N	2026-05-13 17:28:57.292489+00	leaderboard:levelId=1:period=month:scope=level:cursor=:limit=3
a276271a-550c-4255-8318-2b8e79f5f761	\N	cache:miss	info	\N	2026-05-13 17:29:00.495941+00	leaderboard:levelId=1:period=week:scope=level:cursor=:limit=3
934e18ea-c68f-4bc6-a5f2-6efe0d3d12e0	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 6, "session_ids": []}	2026-05-13 18:15:41.07595+00	\N
42505373-93e4-4e63-a3f5-cbbb8c07b3d3	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-13 19:00:00.621138+00	\N
2cdcb33a-22c7-4929-90a1-c530c8233f39	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-13 20:08:26.605958+00	\N
077f59cf-7669-4811-b83a-58da745b2bf3	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-13 21:01:44.003933+00	\N
fd4ccc82-f344-4b3d-9899-8b7659c5c326	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-13 22:02:36.628055+00	\N
f647cafa-fb3f-4c67-a501-812cddf38562	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-13 23:00:00.437741+00	\N
8e1aafa4-6e61-4154-911a-4368a7075fbd	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-14 00:04:08.360516+00	\N
a7328e1e-7ea1-45b0-a2de-c98d446a9f1f	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-14 01:04:41.354332+00	\N
7b596d90-26bc-4977-b26c-6218ae0b3737	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-14 02:00:00.52911+00	\N
96ff6227-2fbb-4f44-a686-2f07586f541b	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 9, "session_ids": []}	2026-05-14 13:04:14.190612+00	\N
18c6a1ac-618e-4f52-b3de-20f8a655b856	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 8, "session_ids": []}	2026-05-14 14:00:00.440556+00	\N
116f7922-4f15-4a72-944d-5d4eb3fc7b4c	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 17, "session_ids": []}	2026-05-14 15:00:00.741734+00	\N
7c61c5c7-26a9-4361-91ec-53049f9d80a7	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 8, "session_ids": []}	2026-05-14 16:07:37.847552+00	\N
facc220d-f2df-49ca-85b1-b19a4457e844	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 6, "session_ids": []}	2026-05-14 18:39:40.550274+00	\N
c38c0ddd-c959-4fe1-ad82-d9859a7d0f63	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 7, "session_ids": []}	2026-05-14 19:00:28.094811+00	\N
d9259aff-b228-4c32-9ebc-bec1a4b6c65e	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 7, "session_ids": []}	2026-05-14 21:02:58.04315+00	\N
f6d4005f-7da1-4ccb-8791-f2f930f022b4	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-14 22:18:45.678636+00	\N
80c55680-bb34-4613-a18e-730a29c162d6	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 7, "session_ids": []}	2026-05-14 23:19:40.762522+00	\N
a41e7103-e216-4ffd-bb4d-36175cbc0196	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 7, "session_ids": []}	2026-05-15 14:00:00.322189+00	\N
cbc233b6-30a2-4fca-ac53-09a25ddb4631	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 8, "session_ids": []}	2026-05-15 15:12:22.270873+00	\N
0abf355a-ada4-460c-923e-38872836a513	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 9, "session_ids": []}	2026-05-15 16:00:00.762473+00	\N
7a3d1041-9404-402e-84cb-f23833ee5526	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-15 17:29:49.635039+00	\N
205969e9-2da7-4a03-8bb9-0cc52217a067	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-15 18:29:54.964526+00	\N
6bfaaf5f-5920-46ef-88a9-fe2d3373fc67	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-15 19:00:59.814557+00	\N
97f9205a-4b31-4570-bad4-a9066ea072b3	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 7, "session_ids": []}	2026-05-15 20:05:35.547881+00	\N
1486ad2f-a59a-4b89-973d-c98788b48955	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-15 21:20:01.79622+00	\N
bee8deea-2cc6-4f6a-8eb3-29605fa76bb3	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-15 22:19:42.668986+00	\N
e805bdc0-408f-4af3-ae1d-b7330f2b8a92	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-15 23:02:50.444404+00	\N
a49d0744-eedb-4ef9-b326-28016b737adf	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 6, "session_ids": []}	2026-05-16 00:07:12.593268+00	\N
b774582f-df34-4282-9b85-6452f1f45163	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 6, "session_ids": []}	2026-05-16 01:19:21.852419+00	\N
839cd51f-a07a-44aa-ae4a-876fd656a82f	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-16 02:03:31.836117+00	\N
1b842c4a-a2e9-42a9-acf6-c0d24e27d054	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 6, "session_ids": []}	2026-05-16 03:23:04.193246+00	\N
791ecd57-13b5-43bb-8958-690033fafe95	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-16 04:06:11.783544+00	\N
8a66472a-dea7-464d-8d00-3f392b64a037	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-16 05:04:54.211974+00	\N
d1e32fce-90f0-46f4-b5a6-e613b4251fd0	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-16 06:24:58.36454+00	\N
a1abf59d-0fe7-497c-af32-95060439672c	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 6, "session_ids": []}	2026-05-16 07:07:53.388254+00	\N
afe6bb33-9cdf-4712-89c0-27b4ad963149	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 6, "session_ids": []}	2026-05-16 08:05:40.812295+00	\N
19d1b7e6-99af-4190-b87a-df5c89006cfa	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-16 09:16:53.687148+00	\N
d10d56db-f7eb-4458-8944-bf4ec7fc8e43	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-16 10:27:48.194901+00	\N
f0982d3b-f791-4c5a-8d0e-554b80368659	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-16 11:12:57.702447+00	\N
04540928-4166-45de-ac54-4195c5ca652f	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 6, "session_ids": []}	2026-05-16 12:12:05.580322+00	\N
52e752da-adb0-441f-bc62-1d2f0d3d2ad1	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-16 13:14:56.124166+00	\N
23b9b3a3-8f14-4932-9b54-4739c579581e	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-16 14:13:33.467677+00	\N
fcedfdf5-d9c0-40b9-ab9a-f253bf13ace3	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-16 15:06:05.337336+00	\N
29daeaaf-d475-409a-a9d3-efe3b2425b4e	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-16 16:01:29.169732+00	\N
2d575f7c-4081-4b2a-b88a-cb2522ce8e3e	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-16 17:05:12.960546+00	\N
e3eec32c-084c-4e40-baa3-3b15d7b76b12	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 6, "session_ids": []}	2026-05-16 18:07:30.927233+00	\N
bc823abe-5256-45dd-80a9-948f626ce1aa	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-16 19:01:33.386178+00	\N
5227e20e-c7bc-48cf-87ab-05d5381183f5	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-16 20:06:12.720577+00	\N
7d347c1f-3ceb-49ec-b9f0-16a5430315f1	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-16 21:00:51.612181+00	\N
e631fc14-e617-4fda-95a2-bfa41a63f913	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-16 22:08:27.557989+00	\N
73aede9f-0629-4184-a608-b5bfa89eb297	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 5, "session_ids": []}	2026-05-16 23:16:29.948948+00	\N
77b21789-fb0d-4ef0-98e7-665b1cbc13e0	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 7, "session_ids": []}	2026-05-17 00:04:51.194278+00	\N
27d90db4-e4c1-4d57-a306-23ef0169f373	\N	cron:game-session-cleanup	info	{"count": 0, "source": "cron", "duration_ms": 6, "session_ids": []}	2026-05-17 01:15:06.638641+00	\N
\.


--
-- Data for Name: log_events_p20260518; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.log_events_p20260518 (id, user_id, event, level, metadata, created_at, description) FROM stdin;
\.


--
-- Data for Name: log_events_p20260525; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.log_events_p20260525 (id, user_id, event, level, metadata, created_at, description) FROM stdin;
\.


--
-- Data for Name: log_events_p20260601; Type: TABLE DATA; Schema: audit; Owner: postgres
--

COPY audit.log_events_p20260601 (id, user_id, event, level, metadata, created_at, description) FROM stdin;
\.


--
-- Data for Name: part_config; Type: TABLE DATA; Schema: partman; Owner: postgres
--

COPY partman.part_config (parent_table, control, time_encoder, time_decoder, partition_interval, partition_type, premake, automatic_maintenance, template_table, retention, retention_schema, retention_keep_index, retention_keep_table, epoch, constraint_cols, optimize_constraint, infinite_time_partitions, datetime_string, jobmon, sub_partition_set_full, undo_in_progress, inherit_privileges, constraint_valid, ignore_default_data, date_trunc_interval, maintenance_order, retention_keep_publication, maintenance_last_run, async_partitioning_in_progress) FROM stdin;
audit.audit_events	created_at	\N	\N	1 week	range	3	on	partman.template_audit_audit_events	\N	\N	t	t	none	\N	30	f	YYYYMMDD	t	f	f	f	t	t	\N	\N	f	2026-05-11 16:11:20.310908+00	\N
audit.log_events	created_at	\N	\N	1 week	range	3	on	partman.template_audit_log_events	\N	\N	t	t	none	\N	30	f	YYYYMMDD	t	f	f	f	t	t	\N	\N	f	2026-05-11 16:11:20.317325+00	\N
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

COPY partman.template_audit_log_events (id, user_id, event, level, metadata, created_at, description) FROM stdin;
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
-- Data for Name: elo_history_p20260420; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.elo_history_p20260420 (id, player_id, session_id, elo_before, elo_after, delta, reason, created_at) FROM stdin;
\.


--
-- Data for Name: elo_history_p20260427; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.elo_history_p20260427 (id, player_id, session_id, elo_before, elo_after, delta, reason, created_at) FROM stdin;
\.


--
-- Data for Name: elo_history_p20260504; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.elo_history_p20260504 (id, player_id, session_id, elo_before, elo_after, delta, reason, created_at) FROM stdin;
\.


--
-- Data for Name: elo_history_p20260511; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.elo_history_p20260511 (id, player_id, session_id, elo_before, elo_after, delta, reason, created_at) FROM stdin;
2	68769d71-b6a1-42e3-95cc-7bf4842e6f17	e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948	0	65	65	session_completed	2026-05-13 16:50:25.216472+00
3	68769d71-b6a1-42e3-95cc-7bf4842e6f17	6bb24d15-d590-4511-984f-a00e142d22a9	65	120	55	session_completed	2026-05-13 16:54:47.294105+00
4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	2dd947c1-bc93-495e-9adf-bb5108564fd4	120	205	85	session_completed	2026-05-13 17:04:57.533085+00
5	68769d71-b6a1-42e3-95cc-7bf4842e6f17	c13ee2aa-bffc-48df-bfcb-a4e71161a911	205	280	75	session_completed	2026-05-13 17:23:10.195494+00
6	ee7af00f-63bd-4f1a-9721-329432cbe1ef	0b7e4f0d-dd65-435a-8c9e-937306e12f73	0	75	75	session_completed	2026-05-13 17:28:36.516379+00
\.


--
-- Data for Name: elo_history_p20260518; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.elo_history_p20260518 (id, player_id, session_id, elo_before, elo_after, delta, reason, created_at) FROM stdin;
\.


--
-- Data for Name: elo_history_p20260525; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.elo_history_p20260525 (id, player_id, session_id, elo_before, elo_after, delta, reason, created_at) FROM stdin;
\.


--
-- Data for Name: elo_history_p20260601; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.elo_history_p20260601 (id, player_id, session_id, elo_before, elo_after, delta, reason, created_at) FROM stdin;
\.


--
-- Data for Name: game_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.game_sessions (id, player_id, level_id, status, score, elo_before, elo_after, elo_delta, correct_count, incorrect_count, max_streak, current_streak, started_at, ended_at, client_ip, user_agent) FROM stdin;
0b7e4f0d-dd65-435a-8c9e-937306e12f73	ee7af00f-63bd-4f1a-9721-329432cbe1ef	1	completed	75	0	75	75	8	1	6	2	2026-05-13 17:28:18.218727+00	2026-05-13 17:28:36.516379+00	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948	68769d71-b6a1-42e3-95cc-7bf4842e6f17	1	completed	65	0	65	65	8	3	6	6	2026-05-13 16:49:50.622628+00	2026-05-13 16:50:25.216472+00	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
6bb24d15-d590-4511-984f-a00e142d22a9	68769d71-b6a1-42e3-95cc-7bf4842e6f17	1	completed	55	65	120	55	11	11	4	4	2026-05-13 16:52:45.428401+00	2026-05-13 16:54:47.294105+00	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
2dd947c1-bc93-495e-9adf-bb5108564fd4	68769d71-b6a1-42e3-95cc-7bf4842e6f17	1	completed	85	120	205	85	9	1	5	5	2026-05-13 17:04:33.58372+00	2026-05-13 17:04:57.533085+00	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
c13ee2aa-bffc-48df-bfcb-a4e71161a911	68769d71-b6a1-42e3-95cc-7bf4842e6f17	1	completed	75	205	280	75	8	1	6	6	2026-05-13 17:22:46.915179+00	2026-05-13 17:23:10.195494+00	::1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36
\.


--
-- Data for Name: levels; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.levels (id, name, description, order_index, child_levels, elo_min, elo_gain_correct, elo_loss_incorrect, time_limit_seconds, enemy_wave_config, question_gen_config, is_active, created_at, updated_at) FROM stdin;
1	Level 1	Practice Addition	1	\N	0	10	5	\N	{"data": null, "schema": 1}	{"data": null, "schema": 1}	t	2026-05-12 04:10:30.588928+00	2026-05-13 16:47:59.334037+00
\.


--
-- Data for Name: levels_unlocked; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.levels_unlocked (player_id, level_id, unlocked_at) FROM stdin;
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

COPY public.players (id, username, display_name, email, avatar_url, role_id, oauth_provider, oauth_id, password_hash, current_elo, total_questions_answered, total_correct, total_incorrect, longest_streak, created_at, updated_at, last_active_at, age, grade, guardian_email) FROM stdin;
68769d71-b6a1-42e3-95cc-7bf4842e6f17	alden	\N	alden@gmail.com	\N	3	\N	\N	$2b$12$cS0jiaSo.J8DJvi/SGDEHejBvGFteMX4EgJYqjYPo97KieFnO5nfi	280	52	36	16	6	2026-05-11 16:12:44.473101+00	2026-05-13 17:23:10.195494+00	2026-05-13 17:23:10.195494+00	9	3	\N
ee7af00f-63bd-4f1a-9721-329432cbe1ef	shawn	\N	shawn@gmail.com	\N	1	\N	\N	$2b$12$.j97jEzrlHYQWjBY14X0l.JlsfhMwJSaa07dytOf49xx31WIshdXu	75	9	8	1	6	2026-05-13 17:27:30.349657+00	2026-05-13 17:28:36.516379+00	2026-05-13 17:28:36.516379+00	9	3	\N
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
cF0s2aUwlEDrKjI1MSOToSMHd2ci7SHL	{"cookie":{"originalMaxAge":604800000,"expires":"2026-05-18T16:14:29.495Z","secure":false,"httpOnly":true,"path":"/","sameSite":"lax"}}	2026-05-18 16:14:30
cP74qh_KicasYAlvaMec878ZAq6Ga72p	{"cookie":{"originalMaxAge":604800000,"expires":"2026-05-18T16:14:51.818Z","secure":false,"httpOnly":true,"path":"/","sameSite":"lax"}}	2026-05-18 16:14:52
tbp05nSxaeO6XG4uXXX88y9iQ1o_Ll1y	{"cookie":{"originalMaxAge":604800000,"expires":"2026-05-18T16:15:48.342Z","secure":false,"httpOnly":true,"path":"/","sameSite":"lax"},"passport":{"user":"68769d71-b6a1-42e3-95cc-7bf4842e6f17"}}	2026-05-19 05:52:10
qYPTCsyl-6str81-wRpHNy4lgvlEYCXz	{"cookie":{"originalMaxAge":604800000,"expires":"2026-05-20T17:27:49.143Z","secure":false,"httpOnly":true,"path":"/","sameSite":"lax"},"passport":{"user":"ee7af00f-63bd-4f1a-9721-329432cbe1ef"}}	2026-05-20 17:29:26
ksTf5xsrg6RWsJCxzt5EucKLKjO-TeQp	{"cookie":{"originalMaxAge":604800000,"expires":"2026-05-20T17:27:07.054Z","secure":false,"httpOnly":true,"path":"/","sameSite":"lax"}}	2026-05-20 17:27:08
\.


--
-- Data for Name: session_answers_default; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session_answers_default (id, session_id, is_correct, elo_delta, time_taken_ms, answered_at) FROM stdin;
\.


--
-- Data for Name: session_answers_p20260420; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session_answers_p20260420 (id, session_id, is_correct, elo_delta, time_taken_ms, answered_at) FROM stdin;
\.


--
-- Data for Name: session_answers_p20260427; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session_answers_p20260427 (id, session_id, is_correct, elo_delta, time_taken_ms, answered_at) FROM stdin;
\.


--
-- Data for Name: session_answers_p20260504; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session_answers_p20260504 (id, session_id, is_correct, elo_delta, time_taken_ms, answered_at) FROM stdin;
\.


--
-- Data for Name: session_answers_p20260511; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session_answers_p20260511 (id, session_id, is_correct, elo_delta, time_taken_ms, answered_at) FROM stdin;
2	e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948	t	10	\N	2026-05-13 16:49:53.947188+00
3	e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948	f	-5	\N	2026-05-13 16:49:56.378061+00
4	e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948	f	-5	\N	2026-05-13 16:49:59.578911+00
5	e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948	t	10	\N	2026-05-13 16:50:02.946303+00
6	e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948	f	-5	\N	2026-05-13 16:50:05.510119+00
7	e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948	t	10	\N	2026-05-13 16:50:11.712851+00
8	e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948	t	10	\N	2026-05-13 16:50:13.671036+00
9	e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948	t	10	\N	2026-05-13 16:50:16.410155+00
10	e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948	t	10	\N	2026-05-13 16:50:19.145179+00
11	e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948	t	10	\N	2026-05-13 16:50:20.7436+00
12	e1b6b7dd-6efd-4f20-a3c1-7c5e908f2948	t	10	\N	2026-05-13 16:50:23.612875+00
13	6bb24d15-d590-4511-984f-a00e142d22a9	t	10	\N	2026-05-13 16:53:14.158589+00
14	6bb24d15-d590-4511-984f-a00e142d22a9	f	-5	\N	2026-05-13 16:53:16.753892+00
15	6bb24d15-d590-4511-984f-a00e142d22a9	f	-5	\N	2026-05-13 16:53:21.687818+00
16	6bb24d15-d590-4511-984f-a00e142d22a9	t	10	\N	2026-05-13 16:53:24.189564+00
17	6bb24d15-d590-4511-984f-a00e142d22a9	f	-5	\N	2026-05-13 16:53:25.885217+00
18	6bb24d15-d590-4511-984f-a00e142d22a9	t	10	\N	2026-05-13 16:53:42.933867+00
19	6bb24d15-d590-4511-984f-a00e142d22a9	f	-5	\N	2026-05-13 16:53:46.262972+00
20	6bb24d15-d590-4511-984f-a00e142d22a9	t	10	\N	2026-05-13 16:53:49.437555+00
21	6bb24d15-d590-4511-984f-a00e142d22a9	t	10	\N	2026-05-13 16:53:50.598229+00
22	6bb24d15-d590-4511-984f-a00e142d22a9	t	10	\N	2026-05-13 16:54:04.665481+00
23	6bb24d15-d590-4511-984f-a00e142d22a9	t	10	\N	2026-05-13 16:54:05.36742+00
24	6bb24d15-d590-4511-984f-a00e142d22a9	f	-5	\N	2026-05-13 16:54:06.067969+00
25	6bb24d15-d590-4511-984f-a00e142d22a9	f	-5	\N	2026-05-13 16:54:08.567157+00
26	6bb24d15-d590-4511-984f-a00e142d22a9	f	-5	\N	2026-05-13 16:54:11.136021+00
27	6bb24d15-d590-4511-984f-a00e142d22a9	f	-5	\N	2026-05-13 16:54:13.700829+00
28	6bb24d15-d590-4511-984f-a00e142d22a9	f	-5	\N	2026-05-13 16:54:16.335425+00
29	6bb24d15-d590-4511-984f-a00e142d22a9	f	-5	\N	2026-05-13 16:54:18.768273+00
30	6bb24d15-d590-4511-984f-a00e142d22a9	f	-5	\N	2026-05-13 16:54:35.370122+00
31	6bb24d15-d590-4511-984f-a00e142d22a9	t	10	\N	2026-05-13 16:54:41.594846+00
32	6bb24d15-d590-4511-984f-a00e142d22a9	t	10	\N	2026-05-13 16:54:42.761368+00
33	6bb24d15-d590-4511-984f-a00e142d22a9	t	10	\N	2026-05-13 16:54:44.260125+00
34	6bb24d15-d590-4511-984f-a00e142d22a9	t	10	\N	2026-05-13 16:54:45.696112+00
35	2dd947c1-bc93-495e-9adf-bb5108564fd4	t	10	\N	2026-05-13 17:04:35.736658+00
36	2dd947c1-bc93-495e-9adf-bb5108564fd4	t	10	\N	2026-05-13 17:04:36.898973+00
37	2dd947c1-bc93-495e-9adf-bb5108564fd4	t	10	\N	2026-05-13 17:04:39.601387+00
38	2dd947c1-bc93-495e-9adf-bb5108564fd4	t	10	\N	2026-05-13 17:04:41.100105+00
39	2dd947c1-bc93-495e-9adf-bb5108564fd4	f	-5	\N	2026-05-13 17:04:43.162842+00
40	2dd947c1-bc93-495e-9adf-bb5108564fd4	t	10	\N	2026-05-13 17:04:46.970356+00
41	2dd947c1-bc93-495e-9adf-bb5108564fd4	t	10	\N	2026-05-13 17:04:49.033601+00
42	2dd947c1-bc93-495e-9adf-bb5108564fd4	t	10	\N	2026-05-13 17:04:49.165688+00
43	2dd947c1-bc93-495e-9adf-bb5108564fd4	t	10	\N	2026-05-13 17:04:55.934419+00
44	2dd947c1-bc93-495e-9adf-bb5108564fd4	t	10	\N	2026-05-13 17:04:57.371173+00
45	c13ee2aa-bffc-48df-bfcb-a4e71161a911	t	10	2128	2026-05-13 17:22:49.0632+00
46	c13ee2aa-bffc-48df-bfcb-a4e71161a911	t	10	2697	2026-05-13 17:22:51.76099+00
47	c13ee2aa-bffc-48df-bfcb-a4e71161a911	f	-5	1166	2026-05-13 17:22:52.927347+00
48	c13ee2aa-bffc-48df-bfcb-a4e71161a911	t	10	2536	2026-05-13 17:22:55.462932+00
49	c13ee2aa-bffc-48df-bfcb-a4e71161a911	t	10	1165	2026-05-13 17:22:56.623032+00
50	c13ee2aa-bffc-48df-bfcb-a4e71161a911	t	10	2269	2026-05-13 17:22:58.896354+00
51	c13ee2aa-bffc-48df-bfcb-a4e71161a911	t	10	2498	2026-05-13 17:23:01.393071+00
52	c13ee2aa-bffc-48df-bfcb-a4e71161a911	t	10	3867	2026-05-13 17:23:05.261873+00
53	c13ee2aa-bffc-48df-bfcb-a4e71161a911	t	10	3334	2026-05-13 17:23:08.595094+00
54	0b7e4f0d-dd65-435a-8c9e-937306e12f73	t	10	1241	2026-05-13 17:28:19.491748+00
55	0b7e4f0d-dd65-435a-8c9e-937306e12f73	t	10	1134	2026-05-13 17:28:20.619736+00
56	0b7e4f0d-dd65-435a-8c9e-937306e12f73	t	10	997	2026-05-13 17:28:21.612611+00
57	0b7e4f0d-dd65-435a-8c9e-937306e12f73	t	10	2070	2026-05-13 17:28:23.687967+00
58	0b7e4f0d-dd65-435a-8c9e-937306e12f73	t	10	1299	2026-05-13 17:28:24.986657+00
59	0b7e4f0d-dd65-435a-8c9e-937306e12f73	t	10	1998	2026-05-13 17:28:26.987178+00
60	0b7e4f0d-dd65-435a-8c9e-937306e12f73	f	-5	1299	2026-05-13 17:28:28.277911+00
61	0b7e4f0d-dd65-435a-8c9e-937306e12f73	t	10	4470	2026-05-13 17:28:32.753215+00
62	0b7e4f0d-dd65-435a-8c9e-937306e12f73	t	10	2165	2026-05-13 17:28:34.915113+00
\.


--
-- Data for Name: session_answers_p20260518; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session_answers_p20260518 (id, session_id, is_correct, elo_delta, time_taken_ms, answered_at) FROM stdin;
\.


--
-- Data for Name: session_answers_p20260525; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session_answers_p20260525 (id, session_id, is_correct, elo_delta, time_taken_ms, answered_at) FROM stdin;
\.


--
-- Data for Name: session_answers_p20260601; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session_answers_p20260601 (id, session_id, is_correct, elo_delta, time_taken_ms, answered_at) FROM stdin;
\.


--
-- Name: patches_id_seq; Type: SEQUENCE SET; Schema: _v; Owner: postgres
--

SELECT pg_catalog.setval('_v.patches_id_seq', 26, true);


--
-- Name: elo_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: partman_user
--

SELECT pg_catalog.setval('public.elo_history_id_seq', 6, true);


--
-- Name: levels_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.levels_id_seq', 1, true);


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

SELECT pg_catalog.setval('public.session_answers_id_seq', 62, true);


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
-- Name: audit_events_p20260420 audit_events_p20260420_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events_p20260420
    ADD CONSTRAINT audit_events_p20260420_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_events_p20260427 audit_events_p20260427_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events_p20260427
    ADD CONSTRAINT audit_events_p20260427_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_events_p20260504 audit_events_p20260504_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events_p20260504
    ADD CONSTRAINT audit_events_p20260504_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_events_p20260511 audit_events_p20260511_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events_p20260511
    ADD CONSTRAINT audit_events_p20260511_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_events_p20260518 audit_events_p20260518_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events_p20260518
    ADD CONSTRAINT audit_events_p20260518_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_events_p20260525 audit_events_p20260525_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events_p20260525
    ADD CONSTRAINT audit_events_p20260525_pkey PRIMARY KEY (id, created_at);


--
-- Name: audit_events_p20260601 audit_events_p20260601_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.audit_events_p20260601
    ADD CONSTRAINT audit_events_p20260601_pkey PRIMARY KEY (id, created_at);


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
-- Name: log_events_p20260420 log_events_p20260420_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events_p20260420
    ADD CONSTRAINT log_events_p20260420_pkey PRIMARY KEY (id, created_at);


--
-- Name: log_events_p20260427 log_events_p20260427_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events_p20260427
    ADD CONSTRAINT log_events_p20260427_pkey PRIMARY KEY (id, created_at);


--
-- Name: log_events_p20260504 log_events_p20260504_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events_p20260504
    ADD CONSTRAINT log_events_p20260504_pkey PRIMARY KEY (id, created_at);


--
-- Name: log_events_p20260511 log_events_p20260511_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events_p20260511
    ADD CONSTRAINT log_events_p20260511_pkey PRIMARY KEY (id, created_at);


--
-- Name: log_events_p20260518 log_events_p20260518_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events_p20260518
    ADD CONSTRAINT log_events_p20260518_pkey PRIMARY KEY (id, created_at);


--
-- Name: log_events_p20260525 log_events_p20260525_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events_p20260525
    ADD CONSTRAINT log_events_p20260525_pkey PRIMARY KEY (id, created_at);


--
-- Name: log_events_p20260601 log_events_p20260601_pkey; Type: CONSTRAINT; Schema: audit; Owner: postgres
--

ALTER TABLE ONLY audit.log_events_p20260601
    ADD CONSTRAINT log_events_p20260601_pkey PRIMARY KEY (id, created_at);


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
-- Name: elo_history_p20260420 elo_history_p20260420_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history_p20260420
    ADD CONSTRAINT elo_history_p20260420_pkey PRIMARY KEY (id, created_at);


--
-- Name: elo_history_p20260427 elo_history_p20260427_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history_p20260427
    ADD CONSTRAINT elo_history_p20260427_pkey PRIMARY KEY (id, created_at);


--
-- Name: elo_history_p20260504 elo_history_p20260504_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history_p20260504
    ADD CONSTRAINT elo_history_p20260504_pkey PRIMARY KEY (id, created_at);


--
-- Name: elo_history_p20260511 elo_history_p20260511_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history_p20260511
    ADD CONSTRAINT elo_history_p20260511_pkey PRIMARY KEY (id, created_at);


--
-- Name: elo_history_p20260518 elo_history_p20260518_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history_p20260518
    ADD CONSTRAINT elo_history_p20260518_pkey PRIMARY KEY (id, created_at);


--
-- Name: elo_history_p20260525 elo_history_p20260525_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history_p20260525
    ADD CONSTRAINT elo_history_p20260525_pkey PRIMARY KEY (id, created_at);


--
-- Name: elo_history_p20260601 elo_history_p20260601_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elo_history_p20260601
    ADD CONSTRAINT elo_history_p20260601_pkey PRIMARY KEY (id, created_at);


--
-- Name: game_sessions game_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_sessions
    ADD CONSTRAINT game_sessions_pkey PRIMARY KEY (id);


--
-- Name: levels levels_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.levels
    ADD CONSTRAINT levels_id_key UNIQUE (id);


--
-- Name: levels levels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.levels
    ADD CONSTRAINT levels_pkey PRIMARY KEY (name);


--
-- Name: levels_unlocked levels_unlocked_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.levels_unlocked
    ADD CONSTRAINT levels_unlocked_pkey PRIMARY KEY (player_id, level_id);


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
-- Name: session_answers_p20260420 session_answers_p20260420_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers_p20260420
    ADD CONSTRAINT session_answers_p20260420_pkey PRIMARY KEY (id, answered_at);


--
-- Name: session_answers_p20260427 session_answers_p20260427_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers_p20260427
    ADD CONSTRAINT session_answers_p20260427_pkey PRIMARY KEY (id, answered_at);


--
-- Name: session_answers_p20260504 session_answers_p20260504_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers_p20260504
    ADD CONSTRAINT session_answers_p20260504_pkey PRIMARY KEY (id, answered_at);


--
-- Name: session_answers_p20260511 session_answers_p20260511_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers_p20260511
    ADD CONSTRAINT session_answers_p20260511_pkey PRIMARY KEY (id, answered_at);


--
-- Name: session_answers_p20260518 session_answers_p20260518_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers_p20260518
    ADD CONSTRAINT session_answers_p20260518_pkey PRIMARY KEY (id, answered_at);


--
-- Name: session_answers_p20260525 session_answers_p20260525_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers_p20260525
    ADD CONSTRAINT session_answers_p20260525_pkey PRIMARY KEY (id, answered_at);


--
-- Name: session_answers_p20260601 session_answers_p20260601_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_answers_p20260601
    ADD CONSTRAINT session_answers_p20260601_pkey PRIMARY KEY (id, answered_at);


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
-- Name: audit_events_p20260420_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260420_created_at_idx ON audit.audit_events_p20260420 USING btree (created_at DESC);


--
-- Name: audit_events_p20260420_status_code_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260420_status_code_idx ON audit.audit_events_p20260420 USING btree (status_code);


--
-- Name: audit_events_p20260420_url_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260420_url_idx ON audit.audit_events_p20260420 USING btree (url);


--
-- Name: audit_events_p20260420_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260420_user_id_idx ON audit.audit_events_p20260420 USING btree (user_id);


--
-- Name: audit_events_p20260427_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260427_created_at_idx ON audit.audit_events_p20260427 USING btree (created_at DESC);


--
-- Name: audit_events_p20260427_status_code_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260427_status_code_idx ON audit.audit_events_p20260427 USING btree (status_code);


--
-- Name: audit_events_p20260427_url_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260427_url_idx ON audit.audit_events_p20260427 USING btree (url);


--
-- Name: audit_events_p20260427_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260427_user_id_idx ON audit.audit_events_p20260427 USING btree (user_id);


--
-- Name: audit_events_p20260504_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260504_created_at_idx ON audit.audit_events_p20260504 USING btree (created_at DESC);


--
-- Name: audit_events_p20260504_status_code_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260504_status_code_idx ON audit.audit_events_p20260504 USING btree (status_code);


--
-- Name: audit_events_p20260504_url_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260504_url_idx ON audit.audit_events_p20260504 USING btree (url);


--
-- Name: audit_events_p20260504_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260504_user_id_idx ON audit.audit_events_p20260504 USING btree (user_id);


--
-- Name: audit_events_p20260511_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260511_created_at_idx ON audit.audit_events_p20260511 USING btree (created_at DESC);


--
-- Name: audit_events_p20260511_status_code_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260511_status_code_idx ON audit.audit_events_p20260511 USING btree (status_code);


--
-- Name: audit_events_p20260511_url_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260511_url_idx ON audit.audit_events_p20260511 USING btree (url);


--
-- Name: audit_events_p20260511_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260511_user_id_idx ON audit.audit_events_p20260511 USING btree (user_id);


--
-- Name: audit_events_p20260518_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260518_created_at_idx ON audit.audit_events_p20260518 USING btree (created_at DESC);


--
-- Name: audit_events_p20260518_status_code_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260518_status_code_idx ON audit.audit_events_p20260518 USING btree (status_code);


--
-- Name: audit_events_p20260518_url_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260518_url_idx ON audit.audit_events_p20260518 USING btree (url);


--
-- Name: audit_events_p20260518_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260518_user_id_idx ON audit.audit_events_p20260518 USING btree (user_id);


--
-- Name: audit_events_p20260525_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260525_created_at_idx ON audit.audit_events_p20260525 USING btree (created_at DESC);


--
-- Name: audit_events_p20260525_status_code_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260525_status_code_idx ON audit.audit_events_p20260525 USING btree (status_code);


--
-- Name: audit_events_p20260525_url_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260525_url_idx ON audit.audit_events_p20260525 USING btree (url);


--
-- Name: audit_events_p20260525_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX audit_events_p20260525_user_id_idx ON audit.audit_events_p20260525 USING btree (user_id);


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
-- Name: log_events_p20260420_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260420_created_at_idx ON audit.log_events_p20260420 USING btree (created_at DESC);


--
-- Name: log_events_p20260420_event_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260420_event_idx ON audit.log_events_p20260420 USING btree (event);


--
-- Name: log_events_p20260420_level_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260420_level_idx ON audit.log_events_p20260420 USING btree (level);


--
-- Name: log_events_p20260420_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260420_user_id_idx ON audit.log_events_p20260420 USING btree (user_id);


--
-- Name: log_events_p20260427_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260427_created_at_idx ON audit.log_events_p20260427 USING btree (created_at DESC);


--
-- Name: log_events_p20260427_event_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260427_event_idx ON audit.log_events_p20260427 USING btree (event);


--
-- Name: log_events_p20260427_level_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260427_level_idx ON audit.log_events_p20260427 USING btree (level);


--
-- Name: log_events_p20260427_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260427_user_id_idx ON audit.log_events_p20260427 USING btree (user_id);


--
-- Name: log_events_p20260504_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260504_created_at_idx ON audit.log_events_p20260504 USING btree (created_at DESC);


--
-- Name: log_events_p20260504_event_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260504_event_idx ON audit.log_events_p20260504 USING btree (event);


--
-- Name: log_events_p20260504_level_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260504_level_idx ON audit.log_events_p20260504 USING btree (level);


--
-- Name: log_events_p20260504_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260504_user_id_idx ON audit.log_events_p20260504 USING btree (user_id);


--
-- Name: log_events_p20260511_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260511_created_at_idx ON audit.log_events_p20260511 USING btree (created_at DESC);


--
-- Name: log_events_p20260511_event_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260511_event_idx ON audit.log_events_p20260511 USING btree (event);


--
-- Name: log_events_p20260511_level_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260511_level_idx ON audit.log_events_p20260511 USING btree (level);


--
-- Name: log_events_p20260511_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260511_user_id_idx ON audit.log_events_p20260511 USING btree (user_id);


--
-- Name: log_events_p20260518_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260518_created_at_idx ON audit.log_events_p20260518 USING btree (created_at DESC);


--
-- Name: log_events_p20260518_event_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260518_event_idx ON audit.log_events_p20260518 USING btree (event);


--
-- Name: log_events_p20260518_level_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260518_level_idx ON audit.log_events_p20260518 USING btree (level);


--
-- Name: log_events_p20260518_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260518_user_id_idx ON audit.log_events_p20260518 USING btree (user_id);


--
-- Name: log_events_p20260525_created_at_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260525_created_at_idx ON audit.log_events_p20260525 USING btree (created_at DESC);


--
-- Name: log_events_p20260525_event_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260525_event_idx ON audit.log_events_p20260525 USING btree (event);


--
-- Name: log_events_p20260525_level_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260525_level_idx ON audit.log_events_p20260525 USING btree (level);


--
-- Name: log_events_p20260525_user_id_idx; Type: INDEX; Schema: audit; Owner: postgres
--

CREATE INDEX log_events_p20260525_user_id_idx ON audit.log_events_p20260525 USING btree (user_id);


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
-- Name: elo_history_p20260420_player_id_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX elo_history_p20260420_player_id_created_at_idx ON public.elo_history_p20260420 USING btree (player_id, created_at DESC);


--
-- Name: elo_history_p20260427_player_id_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX elo_history_p20260427_player_id_created_at_idx ON public.elo_history_p20260427 USING btree (player_id, created_at DESC);


--
-- Name: elo_history_p20260504_player_id_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX elo_history_p20260504_player_id_created_at_idx ON public.elo_history_p20260504 USING btree (player_id, created_at DESC);


--
-- Name: elo_history_p20260511_player_id_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX elo_history_p20260511_player_id_created_at_idx ON public.elo_history_p20260511 USING btree (player_id, created_at DESC);


--
-- Name: elo_history_p20260518_player_id_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX elo_history_p20260518_player_id_created_at_idx ON public.elo_history_p20260518 USING btree (player_id, created_at DESC);


--
-- Name: elo_history_p20260525_player_id_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX elo_history_p20260525_player_id_created_at_idx ON public.elo_history_p20260525 USING btree (player_id, created_at DESC);


--
-- Name: elo_history_p20260601_player_id_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX elo_history_p20260601_player_id_created_at_idx ON public.elo_history_p20260601 USING btree (player_id, created_at DESC);


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
-- Name: idx_levels_unlocked_player; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_levels_unlocked_player ON public.levels_unlocked USING btree (player_id);


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
-- Name: session_answers_p20260420_session_id_answered_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX session_answers_p20260420_session_id_answered_at_idx ON public.session_answers_p20260420 USING btree (session_id, answered_at);


--
-- Name: session_answers_p20260427_session_id_answered_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX session_answers_p20260427_session_id_answered_at_idx ON public.session_answers_p20260427 USING btree (session_id, answered_at);


--
-- Name: session_answers_p20260504_session_id_answered_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX session_answers_p20260504_session_id_answered_at_idx ON public.session_answers_p20260504 USING btree (session_id, answered_at);


--
-- Name: session_answers_p20260511_session_id_answered_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX session_answers_p20260511_session_id_answered_at_idx ON public.session_answers_p20260511 USING btree (session_id, answered_at);


--
-- Name: session_answers_p20260518_session_id_answered_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX session_answers_p20260518_session_id_answered_at_idx ON public.session_answers_p20260518 USING btree (session_id, answered_at);


--
-- Name: session_answers_p20260525_session_id_answered_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX session_answers_p20260525_session_id_answered_at_idx ON public.session_answers_p20260525 USING btree (session_id, answered_at);


--
-- Name: session_answers_p20260601_session_id_answered_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX session_answers_p20260601_session_id_answered_at_idx ON public.session_answers_p20260601 USING btree (session_id, answered_at);


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
-- Name: audit_events_p20260420_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_created_at ATTACH PARTITION audit.audit_events_p20260420_created_at_idx;


--
-- Name: audit_events_p20260420_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.audit_events_pkey ATTACH PARTITION audit.audit_events_p20260420_pkey;


--
-- Name: audit_events_p20260420_status_code_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_status_code ATTACH PARTITION audit.audit_events_p20260420_status_code_idx;


--
-- Name: audit_events_p20260420_url_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_url ATTACH PARTITION audit.audit_events_p20260420_url_idx;


--
-- Name: audit_events_p20260420_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_user_id ATTACH PARTITION audit.audit_events_p20260420_user_id_idx;


--
-- Name: audit_events_p20260427_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_created_at ATTACH PARTITION audit.audit_events_p20260427_created_at_idx;


--
-- Name: audit_events_p20260427_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.audit_events_pkey ATTACH PARTITION audit.audit_events_p20260427_pkey;


--
-- Name: audit_events_p20260427_status_code_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_status_code ATTACH PARTITION audit.audit_events_p20260427_status_code_idx;


--
-- Name: audit_events_p20260427_url_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_url ATTACH PARTITION audit.audit_events_p20260427_url_idx;


--
-- Name: audit_events_p20260427_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_user_id ATTACH PARTITION audit.audit_events_p20260427_user_id_idx;


--
-- Name: audit_events_p20260504_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_created_at ATTACH PARTITION audit.audit_events_p20260504_created_at_idx;


--
-- Name: audit_events_p20260504_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.audit_events_pkey ATTACH PARTITION audit.audit_events_p20260504_pkey;


--
-- Name: audit_events_p20260504_status_code_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_status_code ATTACH PARTITION audit.audit_events_p20260504_status_code_idx;


--
-- Name: audit_events_p20260504_url_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_url ATTACH PARTITION audit.audit_events_p20260504_url_idx;


--
-- Name: audit_events_p20260504_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_user_id ATTACH PARTITION audit.audit_events_p20260504_user_id_idx;


--
-- Name: audit_events_p20260511_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_created_at ATTACH PARTITION audit.audit_events_p20260511_created_at_idx;


--
-- Name: audit_events_p20260511_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.audit_events_pkey ATTACH PARTITION audit.audit_events_p20260511_pkey;


--
-- Name: audit_events_p20260511_status_code_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_status_code ATTACH PARTITION audit.audit_events_p20260511_status_code_idx;


--
-- Name: audit_events_p20260511_url_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_url ATTACH PARTITION audit.audit_events_p20260511_url_idx;


--
-- Name: audit_events_p20260511_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_user_id ATTACH PARTITION audit.audit_events_p20260511_user_id_idx;


--
-- Name: audit_events_p20260518_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_created_at ATTACH PARTITION audit.audit_events_p20260518_created_at_idx;


--
-- Name: audit_events_p20260518_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.audit_events_pkey ATTACH PARTITION audit.audit_events_p20260518_pkey;


--
-- Name: audit_events_p20260518_status_code_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_status_code ATTACH PARTITION audit.audit_events_p20260518_status_code_idx;


--
-- Name: audit_events_p20260518_url_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_url ATTACH PARTITION audit.audit_events_p20260518_url_idx;


--
-- Name: audit_events_p20260518_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_user_id ATTACH PARTITION audit.audit_events_p20260518_user_id_idx;


--
-- Name: audit_events_p20260525_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_created_at ATTACH PARTITION audit.audit_events_p20260525_created_at_idx;


--
-- Name: audit_events_p20260525_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.audit_events_pkey ATTACH PARTITION audit.audit_events_p20260525_pkey;


--
-- Name: audit_events_p20260525_status_code_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_status_code ATTACH PARTITION audit.audit_events_p20260525_status_code_idx;


--
-- Name: audit_events_p20260525_url_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_url ATTACH PARTITION audit.audit_events_p20260525_url_idx;


--
-- Name: audit_events_p20260525_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_audit_events_user_id ATTACH PARTITION audit.audit_events_p20260525_user_id_idx;


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
-- Name: log_events_p20260420_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_created_at ATTACH PARTITION audit.log_events_p20260420_created_at_idx;


--
-- Name: log_events_p20260420_event_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_event ATTACH PARTITION audit.log_events_p20260420_event_idx;


--
-- Name: log_events_p20260420_level_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_level ATTACH PARTITION audit.log_events_p20260420_level_idx;


--
-- Name: log_events_p20260420_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.log_events_pkey ATTACH PARTITION audit.log_events_p20260420_pkey;


--
-- Name: log_events_p20260420_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_user_id ATTACH PARTITION audit.log_events_p20260420_user_id_idx;


--
-- Name: log_events_p20260427_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_created_at ATTACH PARTITION audit.log_events_p20260427_created_at_idx;


--
-- Name: log_events_p20260427_event_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_event ATTACH PARTITION audit.log_events_p20260427_event_idx;


--
-- Name: log_events_p20260427_level_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_level ATTACH PARTITION audit.log_events_p20260427_level_idx;


--
-- Name: log_events_p20260427_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.log_events_pkey ATTACH PARTITION audit.log_events_p20260427_pkey;


--
-- Name: log_events_p20260427_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_user_id ATTACH PARTITION audit.log_events_p20260427_user_id_idx;


--
-- Name: log_events_p20260504_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_created_at ATTACH PARTITION audit.log_events_p20260504_created_at_idx;


--
-- Name: log_events_p20260504_event_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_event ATTACH PARTITION audit.log_events_p20260504_event_idx;


--
-- Name: log_events_p20260504_level_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_level ATTACH PARTITION audit.log_events_p20260504_level_idx;


--
-- Name: log_events_p20260504_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.log_events_pkey ATTACH PARTITION audit.log_events_p20260504_pkey;


--
-- Name: log_events_p20260504_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_user_id ATTACH PARTITION audit.log_events_p20260504_user_id_idx;


--
-- Name: log_events_p20260511_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_created_at ATTACH PARTITION audit.log_events_p20260511_created_at_idx;


--
-- Name: log_events_p20260511_event_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_event ATTACH PARTITION audit.log_events_p20260511_event_idx;


--
-- Name: log_events_p20260511_level_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_level ATTACH PARTITION audit.log_events_p20260511_level_idx;


--
-- Name: log_events_p20260511_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.log_events_pkey ATTACH PARTITION audit.log_events_p20260511_pkey;


--
-- Name: log_events_p20260511_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_user_id ATTACH PARTITION audit.log_events_p20260511_user_id_idx;


--
-- Name: log_events_p20260518_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_created_at ATTACH PARTITION audit.log_events_p20260518_created_at_idx;


--
-- Name: log_events_p20260518_event_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_event ATTACH PARTITION audit.log_events_p20260518_event_idx;


--
-- Name: log_events_p20260518_level_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_level ATTACH PARTITION audit.log_events_p20260518_level_idx;


--
-- Name: log_events_p20260518_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.log_events_pkey ATTACH PARTITION audit.log_events_p20260518_pkey;


--
-- Name: log_events_p20260518_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_user_id ATTACH PARTITION audit.log_events_p20260518_user_id_idx;


--
-- Name: log_events_p20260525_created_at_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_created_at ATTACH PARTITION audit.log_events_p20260525_created_at_idx;


--
-- Name: log_events_p20260525_event_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_event ATTACH PARTITION audit.log_events_p20260525_event_idx;


--
-- Name: log_events_p20260525_level_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_level ATTACH PARTITION audit.log_events_p20260525_level_idx;


--
-- Name: log_events_p20260525_pkey; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.log_events_pkey ATTACH PARTITION audit.log_events_p20260525_pkey;


--
-- Name: log_events_p20260525_user_id_idx; Type: INDEX ATTACH; Schema: audit; Owner: partman_user
--

ALTER INDEX audit.idx_log_events_user_id ATTACH PARTITION audit.log_events_p20260525_user_id_idx;


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
-- Name: elo_history_default_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.elo_history_pkey ATTACH PARTITION public.elo_history_default_pkey;


--
-- Name: elo_history_default_player_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_elo_history_player ATTACH PARTITION public.elo_history_default_player_id_created_at_idx;


--
-- Name: elo_history_p20260420_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.elo_history_pkey ATTACH PARTITION public.elo_history_p20260420_pkey;


--
-- Name: elo_history_p20260420_player_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_elo_history_player ATTACH PARTITION public.elo_history_p20260420_player_id_created_at_idx;


--
-- Name: elo_history_p20260427_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.elo_history_pkey ATTACH PARTITION public.elo_history_p20260427_pkey;


--
-- Name: elo_history_p20260427_player_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_elo_history_player ATTACH PARTITION public.elo_history_p20260427_player_id_created_at_idx;


--
-- Name: elo_history_p20260504_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.elo_history_pkey ATTACH PARTITION public.elo_history_p20260504_pkey;


--
-- Name: elo_history_p20260504_player_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_elo_history_player ATTACH PARTITION public.elo_history_p20260504_player_id_created_at_idx;


--
-- Name: elo_history_p20260511_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.elo_history_pkey ATTACH PARTITION public.elo_history_p20260511_pkey;


--
-- Name: elo_history_p20260511_player_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_elo_history_player ATTACH PARTITION public.elo_history_p20260511_player_id_created_at_idx;


--
-- Name: elo_history_p20260518_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.elo_history_pkey ATTACH PARTITION public.elo_history_p20260518_pkey;


--
-- Name: elo_history_p20260518_player_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_elo_history_player ATTACH PARTITION public.elo_history_p20260518_player_id_created_at_idx;


--
-- Name: elo_history_p20260525_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.elo_history_pkey ATTACH PARTITION public.elo_history_p20260525_pkey;


--
-- Name: elo_history_p20260525_player_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_elo_history_player ATTACH PARTITION public.elo_history_p20260525_player_id_created_at_idx;


--
-- Name: elo_history_p20260601_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.elo_history_pkey ATTACH PARTITION public.elo_history_p20260601_pkey;


--
-- Name: elo_history_p20260601_player_id_created_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_elo_history_player ATTACH PARTITION public.elo_history_p20260601_player_id_created_at_idx;


--
-- Name: session_answers_default_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.session_answers_pkey ATTACH PARTITION public.session_answers_default_pkey;


--
-- Name: session_answers_default_session_id_answered_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_answers_session ATTACH PARTITION public.session_answers_default_session_id_answered_at_idx;


--
-- Name: session_answers_p20260420_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.session_answers_pkey ATTACH PARTITION public.session_answers_p20260420_pkey;


--
-- Name: session_answers_p20260420_session_id_answered_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_answers_session ATTACH PARTITION public.session_answers_p20260420_session_id_answered_at_idx;


--
-- Name: session_answers_p20260427_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.session_answers_pkey ATTACH PARTITION public.session_answers_p20260427_pkey;


--
-- Name: session_answers_p20260427_session_id_answered_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_answers_session ATTACH PARTITION public.session_answers_p20260427_session_id_answered_at_idx;


--
-- Name: session_answers_p20260504_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.session_answers_pkey ATTACH PARTITION public.session_answers_p20260504_pkey;


--
-- Name: session_answers_p20260504_session_id_answered_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_answers_session ATTACH PARTITION public.session_answers_p20260504_session_id_answered_at_idx;


--
-- Name: session_answers_p20260511_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.session_answers_pkey ATTACH PARTITION public.session_answers_p20260511_pkey;


--
-- Name: session_answers_p20260511_session_id_answered_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_answers_session ATTACH PARTITION public.session_answers_p20260511_session_id_answered_at_idx;


--
-- Name: session_answers_p20260518_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.session_answers_pkey ATTACH PARTITION public.session_answers_p20260518_pkey;


--
-- Name: session_answers_p20260518_session_id_answered_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_answers_session ATTACH PARTITION public.session_answers_p20260518_session_id_answered_at_idx;


--
-- Name: session_answers_p20260525_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.session_answers_pkey ATTACH PARTITION public.session_answers_p20260525_pkey;


--
-- Name: session_answers_p20260525_session_id_answered_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_answers_session ATTACH PARTITION public.session_answers_p20260525_session_id_answered_at_idx;


--
-- Name: session_answers_p20260601_pkey; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.session_answers_pkey ATTACH PARTITION public.session_answers_p20260601_pkey;


--
-- Name: session_answers_p20260601_session_id_answered_at_idx; Type: INDEX ATTACH; Schema: public; Owner: partman_user
--

ALTER INDEX public.idx_answers_session ATTACH PARTITION public.session_answers_p20260601_session_id_answered_at_idx;


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
-- Name: levels_unlocked levels_unlocked_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.levels_unlocked
    ADD CONSTRAINT levels_unlocked_level_id_fkey FOREIGN KEY (level_id) REFERENCES public.levels(id) ON DELETE CASCADE;


--
-- Name: levels_unlocked levels_unlocked_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.levels_unlocked
    ADD CONSTRAINT levels_unlocked_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


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
-- Name: TABLE elo_history_p20260420; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.elo_history_p20260420 TO app;
GRANT SELECT ON TABLE public.elo_history_p20260420 TO jas;


--
-- Name: TABLE elo_history_p20260427; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.elo_history_p20260427 TO app;
GRANT SELECT ON TABLE public.elo_history_p20260427 TO jas;


--
-- Name: TABLE elo_history_p20260504; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.elo_history_p20260504 TO app;
GRANT SELECT ON TABLE public.elo_history_p20260504 TO jas;


--
-- Name: TABLE elo_history_p20260511; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.elo_history_p20260511 TO app;
GRANT SELECT ON TABLE public.elo_history_p20260511 TO jas;


--
-- Name: TABLE elo_history_p20260518; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.elo_history_p20260518 TO app;
GRANT SELECT ON TABLE public.elo_history_p20260518 TO jas;


--
-- Name: TABLE elo_history_p20260525; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.elo_history_p20260525 TO app;
GRANT SELECT ON TABLE public.elo_history_p20260525 TO jas;


--
-- Name: TABLE elo_history_p20260601; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.elo_history_p20260601 TO app;
GRANT SELECT ON TABLE public.elo_history_p20260601 TO jas;


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
-- Name: TABLE levels_unlocked; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.levels_unlocked TO app;
GRANT SELECT ON TABLE public.levels_unlocked TO jas;


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
-- Name: TABLE session_answers_p20260420; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.session_answers_p20260420 TO app;
GRANT SELECT ON TABLE public.session_answers_p20260420 TO jas;


--
-- Name: TABLE session_answers_p20260427; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.session_answers_p20260427 TO app;
GRANT SELECT ON TABLE public.session_answers_p20260427 TO jas;


--
-- Name: TABLE session_answers_p20260504; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.session_answers_p20260504 TO app;
GRANT SELECT ON TABLE public.session_answers_p20260504 TO jas;


--
-- Name: TABLE session_answers_p20260511; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.session_answers_p20260511 TO app;
GRANT SELECT ON TABLE public.session_answers_p20260511 TO jas;


--
-- Name: TABLE session_answers_p20260518; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.session_answers_p20260518 TO app;
GRANT SELECT ON TABLE public.session_answers_p20260518 TO jas;


--
-- Name: TABLE session_answers_p20260525; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.session_answers_p20260525 TO app;
GRANT SELECT ON TABLE public.session_answers_p20260525 TO jas;


--
-- Name: TABLE session_answers_p20260601; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.session_answers_p20260601 TO app;
GRANT SELECT ON TABLE public.session_answers_p20260601 TO jas;


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

\unrestrict 6wRlDUQge9QK1RVggxk3KkdZgBW5vu5ew79R2BIUtZVQWoq1fWHYU3z2HUfUUQD

