--
-- PostgreSQL database dump
--

-- Dumped from database version 15rc1 (Debian 15~rc1-1.pgdg110+1)
-- Dumped by pg_dump version 15rc1 (Debian 15~rc1-1.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: mess; Type: SCHEMA; Schema: -; Owner: stan
--

CREATE SCHEMA mess;


ALTER SCHEMA mess OWNER TO stan;

--
-- Name: log_audit(); Type: FUNCTION; Schema: mess; Owner: stan
--

CREATE FUNCTION mess.log_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_WHEN <> 'AFTER' THEN
        RAISE EXCEPTION 'mess.log_audit() may only run as an AFTER trigger';
    END IF;

    IF (TG_OP = 'DELETE') THEN
        insert into mess.log(action, performed, username, id, content)
            select tg_op, now(), user, old.id, old.content;

        RETURN old;
    ELSIF (TG_OP = 'UPDATE') THEN
        insert into mess.log(action, performed, username, id, content)
            select tg_op, now(), user, new.id, new.content;

        RETURN new;
    ELSIF (TG_OP = 'INSERT') THEN
        insert into mess.log(action, performed, username, id, content)
            select tg_op, now(), user, new.id, new.content;

        RETURN new;
    END IF;

    RETURN NULL;
END;
$$;


ALTER FUNCTION mess.log_audit() OWNER TO stan;

--
-- Name: FUNCTION log_audit(); Type: COMMENT; Schema: mess; Owner: stan
--

COMMENT ON FUNCTION mess.log_audit() IS 'Function is responsible for logging changes in trigger for mess.node table';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: log; Type: TABLE; Schema: mess; Owner: stan
--

CREATE TABLE mess.log (
    action text NOT NULL,
    performed timestamp without time zone NOT NULL,
    username text NOT NULL,
    id uuid NOT NULL,
    content xml NOT NULL
);


ALTER TABLE mess.log OWNER TO stan;

--
-- Name: TABLE log; Type: COMMENT; Schema: mess; Owner: stan
--

COMMENT ON TABLE mess.log IS 'Log for actions in mess.node';


--
-- Name: COLUMN log.action; Type: COMMENT; Schema: mess; Owner: stan
--

COMMENT ON COLUMN mess.log.action IS 'Log action (insert, update, ...)';


--
-- Name: COLUMN log.performed; Type: COMMENT; Schema: mess; Owner: stan
--

COMMENT ON COLUMN mess.log.performed IS 'Timestamp, when action was performed';


--
-- Name: COLUMN log.username; Type: COMMENT; Schema: mess; Owner: stan
--

COMMENT ON COLUMN mess.log.username IS 'User who performed an action';


--
-- Name: COLUMN log.id; Type: COMMENT; Schema: mess; Owner: stan
--

COMMENT ON COLUMN mess.log.id IS 'ID of affected mess.node entry';


--
-- Name: COLUMN log.content; Type: COMMENT; Schema: mess; Owner: stan
--

COMMENT ON COLUMN mess.log.content IS 'Content changes';


--
-- Name: node; Type: TABLE; Schema: mess; Owner: stan
--

CREATE TABLE mess.node (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    content xml NOT NULL
);


ALTER TABLE mess.node OWNER TO stan;

--
-- Name: TABLE node; Type: COMMENT; Schema: mess; Owner: stan
--

COMMENT ON TABLE mess.node IS 'Nodes are the fundamental atoms of the mesh. Each node defines incoming relations and description as child and text XML child nodes';


--
-- Name: COLUMN node.id; Type: COMMENT; Schema: mess; Owner: stan
--

COMMENT ON COLUMN mess.node.id IS 'Node ID intentionally uses UUID. URIs will be part of content';


--
-- Name: COLUMN node.content; Type: COMMENT; Schema: mess; Owner: stan
--

COMMENT ON COLUMN mess.node.content IS 'Content is an XML that contains information about incoming relations/edges (constructive paradigm)';


--
-- Name: node node_pkey; Type: CONSTRAINT; Schema: mess; Owner: stan
--

ALTER TABLE ONLY mess.node
    ADD CONSTRAINT node_pkey PRIMARY KEY (id);


--
-- Name: node node_on_log; Type: TRIGGER; Schema: mess; Owner: stan
--

CREATE TRIGGER node_on_log AFTER INSERT OR DELETE OR UPDATE ON mess.node FOR EACH ROW EXECUTE FUNCTION mess.log_audit();


--
-- Name: TRIGGER node_on_log ON node; Type: COMMENT; Schema: mess; Owner: stan
--

COMMENT ON TRIGGER node_on_log ON mess.node IS 'Trigger for logging changes for mess.node table';


--
-- PostgreSQL database dump complete
--

