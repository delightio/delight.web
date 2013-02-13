--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE accounts (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    administrator_id integer
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE accounts_id_seq OWNED BY accounts.id;


--
-- Name: app_sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE app_sessions (
    id integer NOT NULL,
    duration numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    app_id integer,
    app_locale character varying(255),
    app_version character varying(255),
    delight_version character varying(255),
    app_build character varying(255),
    expected_track_count integer,
    tracks_count integer DEFAULT 0,
    app_connectivity character varying(255),
    device_hw_version character varying(255),
    device_os_version character varying(255),
    type character varying(255),
    event_infos_count integer DEFAULT 0
);


--
-- Name: app_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE app_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: app_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE app_sessions_id_seq OWNED BY app_sessions.id;


--
-- Name: apps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE apps (
    id integer NOT NULL,
    name character varying(255),
    token character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id integer
);


--
-- Name: apps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE apps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE apps_id_seq OWNED BY apps.id;


--
-- Name: beta_signups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE beta_signups (
    id integer NOT NULL,
    email character varying(255),
    app_name character varying(255),
    platform character varying(255),
    opengl boolean,
    unity3d boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: beta_signups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE beta_signups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: beta_signups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE beta_signups_id_seq OWNED BY beta_signups.id;


--
-- Name: event_infos; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE event_infos (
    id integer NOT NULL,
    app_session_id integer,
    event_id integer,
    track_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "time" numeric,
    properties hstore
);


--
-- Name: event_infos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE event_infos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE event_infos_id_seq OWNED BY event_infos.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    event_infos_count integer DEFAULT 0
);


--
-- Name: events_funnels; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE events_funnels (
    id integer NOT NULL,
    event_id integer,
    funnel_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: events_funnels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_funnels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_funnels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_funnels_id_seq OWNED BY events_funnels.id;


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: favorites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites (
    id integer NOT NULL,
    user_id integer,
    app_session_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: favorites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: favorites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_id_seq OWNED BY favorites.id;


--
-- Name: funnels; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE funnels (
    id integer NOT NULL,
    name character varying(255),
    app_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: funnels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE funnels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: funnels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE funnels_id_seq OWNED BY funnels.id;


--
-- Name: group_invitations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE group_invitations (
    id integer NOT NULL,
    app_id integer,
    app_session_id integer,
    emails text,
    message text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: group_invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE group_invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE group_invitations_id_seq OWNED BY group_invitations.id;


--
-- Name: invitations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE invitations (
    id integer NOT NULL,
    app_id integer,
    app_session_id integer,
    email character varying(255),
    message text,
    token character varying(255),
    token_expiration timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    group_invitation_id integer
);


--
-- Name: invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE invitations_id_seq OWNED BY invitations.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE permissions (
    id integer NOT NULL,
    viewer_id integer,
    app_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_viewed_at timestamp without time zone
);


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE permissions_id_seq OWNED BY permissions.id;


--
-- Name: properties; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE properties (
    id integer NOT NULL,
    app_session_id integer,
    key character varying(255),
    value character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: properties_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE properties_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: properties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE properties_id_seq OWNED BY properties.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: tracks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tracks (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    app_session_id integer,
    type character varying(255),
    events_count integer DEFAULT 0,
    event_infos_count integer DEFAULT 0
);


--
-- Name: tracks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tracks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tracks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tracks_id_seq OWNED BY tracks.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    account_id integer,
    twitter_id character varying(255),
    github_id character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    type character varying(255),
    nickname character varying(255),
    image_url character varying(255),
    signup_step integer DEFAULT 1,
    twitter_url character varying(255),
    github_url character varying(255)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts ALTER COLUMN id SET DEFAULT nextval('accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY app_sessions ALTER COLUMN id SET DEFAULT nextval('app_sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY apps ALTER COLUMN id SET DEFAULT nextval('apps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY beta_signups ALTER COLUMN id SET DEFAULT nextval('beta_signups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_infos ALTER COLUMN id SET DEFAULT nextval('event_infos_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events_funnels ALTER COLUMN id SET DEFAULT nextval('events_funnels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY funnels ALTER COLUMN id SET DEFAULT nextval('funnels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_invitations ALTER COLUMN id SET DEFAULT nextval('group_invitations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY invitations ALTER COLUMN id SET DEFAULT nextval('invitations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY permissions ALTER COLUMN id SET DEFAULT nextval('permissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY properties ALTER COLUMN id SET DEFAULT nextval('properties_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tracks ALTER COLUMN id SET DEFAULT nextval('tracks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: app_sessions_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY event_infos
    ADD CONSTRAINT app_sessions_events_pkey PRIMARY KEY (id);


--
-- Name: app_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY app_sessions
    ADD CONSTRAINT app_sessions_pkey PRIMARY KEY (id);


--
-- Name: apps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY apps
    ADD CONSTRAINT apps_pkey PRIMARY KEY (id);


--
-- Name: beta_signups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY beta_signups
    ADD CONSTRAINT beta_signups_pkey PRIMARY KEY (id);


--
-- Name: events_funnels_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events_funnels
    ADD CONSTRAINT events_funnels_pkey PRIMARY KEY (id);


--
-- Name: favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (id);


--
-- Name: funnels_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY funnels
    ADD CONSTRAINT funnels_pkey PRIMARY KEY (id);


--
-- Name: group_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY group_invitations
    ADD CONSTRAINT group_invitations_pkey PRIMARY KEY (id);


--
-- Name: invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY invitations
    ADD CONSTRAINT invitations_pkey PRIMARY KEY (id);


--
-- Name: permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: properties_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY properties
    ADD CONSTRAINT properties_pkey PRIMARY KEY (id);


--
-- Name: track_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT track_tags_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: videos_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tracks
    ADD CONSTRAINT videos_pkey PRIMARY KEY (id);


--
-- Name: acct_admin_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX acct_admin_id ON accounts USING btree (administrator_id);


--
-- Name: apps_acct_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX apps_acct_id ON apps USING btree (account_id);


--
-- Name: as_app_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX as_app_id ON app_sessions USING btree (app_id);


--
-- Name: as_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX as_created_at ON app_sessions USING btree (created_at);


--
-- Name: as_duration; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX as_duration ON app_sessions USING btree (duration);


--
-- Name: ase_as_event_track_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ase_as_event_track_id ON event_infos USING btree (app_session_id, event_id, track_id);


--
-- Name: fav_as_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fav_as_id ON favorites USING btree (app_session_id);


--
-- Name: fav_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fav_user_id ON favorites USING btree (user_id);


--
-- Name: index_events_funnels_on_event_id_and_funnel_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_funnels_on_event_id_and_funnel_id ON events_funnels USING btree (event_id, funnel_id);


--
-- Name: index_funnels_on_app_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_funnels_on_app_id ON funnels USING btree (app_id);


--
-- Name: index_permissions_on_viewer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_permissions_on_viewer_id ON permissions USING btree (viewer_id);


--
-- Name: index_tracks_on_track_tags_count; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tracks_on_track_tags_count ON tracks USING btree (events_count);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: perm_app_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX perm_app_id ON permissions USING btree (app_id);


--
-- Name: perm_viewer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX perm_viewer_id ON permissions USING btree (viewer_id);


--
-- Name: tracks_type_as_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tracks_type_as_id ON tracks USING btree (type, app_session_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20120409222858');

INSERT INTO schema_migrations (version) VALUES ('20120409223217');

INSERT INTO schema_migrations (version) VALUES ('20120409223932');

INSERT INTO schema_migrations (version) VALUES ('20120409223952');

INSERT INTO schema_migrations (version) VALUES ('20120409231103');

INSERT INTO schema_migrations (version) VALUES ('20120409231602');

INSERT INTO schema_migrations (version) VALUES ('20120409231711');

INSERT INTO schema_migrations (version) VALUES ('20120410192130');

INSERT INTO schema_migrations (version) VALUES ('20120410194446');

INSERT INTO schema_migrations (version) VALUES ('20120410194822');

INSERT INTO schema_migrations (version) VALUES ('20120410195029');

INSERT INTO schema_migrations (version) VALUES ('20120410195503');

INSERT INTO schema_migrations (version) VALUES ('20120411000622');

INSERT INTO schema_migrations (version) VALUES ('20120412200713');

INSERT INTO schema_migrations (version) VALUES ('20120416074430');

INSERT INTO schema_migrations (version) VALUES ('20120416095315');

INSERT INTO schema_migrations (version) VALUES ('20120416103056');

INSERT INTO schema_migrations (version) VALUES ('20120416105736');

INSERT INTO schema_migrations (version) VALUES ('20120417063248');

INSERT INTO schema_migrations (version) VALUES ('20120417063802');

INSERT INTO schema_migrations (version) VALUES ('20120417064334');

INSERT INTO schema_migrations (version) VALUES ('20120417074832');

INSERT INTO schema_migrations (version) VALUES ('20120418220458');

INSERT INTO schema_migrations (version) VALUES ('20120419073643');

INSERT INTO schema_migrations (version) VALUES ('20120423031814');

INSERT INTO schema_migrations (version) VALUES ('20120424091541');

INSERT INTO schema_migrations (version) VALUES ('20120503051630');

INSERT INTO schema_migrations (version) VALUES ('20120503085816');

INSERT INTO schema_migrations (version) VALUES ('20120504013920');

INSERT INTO schema_migrations (version) VALUES ('20120504085035');

INSERT INTO schema_migrations (version) VALUES ('20120506133521');

INSERT INTO schema_migrations (version) VALUES ('20120508110357');

INSERT INTO schema_migrations (version) VALUES ('20120509090655');

INSERT INTO schema_migrations (version) VALUES ('20120511083636');

INSERT INTO schema_migrations (version) VALUES ('20120511092335');

INSERT INTO schema_migrations (version) VALUES ('20120515041356');

INSERT INTO schema_migrations (version) VALUES ('20120515065824');

INSERT INTO schema_migrations (version) VALUES ('20120521063942');

INSERT INTO schema_migrations (version) VALUES ('20120531000011');

INSERT INTO schema_migrations (version) VALUES ('20120606045010');

INSERT INTO schema_migrations (version) VALUES ('20120718091548');

INSERT INTO schema_migrations (version) VALUES ('20130204015557');

INSERT INTO schema_migrations (version) VALUES ('20130206001742');

INSERT INTO schema_migrations (version) VALUES ('20130206003646');

INSERT INTO schema_migrations (version) VALUES ('20130208001922');

INSERT INTO schema_migrations (version) VALUES ('20130208014754');

INSERT INTO schema_migrations (version) VALUES ('20130211005918');

INSERT INTO schema_migrations (version) VALUES ('20130211010000');

INSERT INTO schema_migrations (version) VALUES ('20130212010015');

INSERT INTO schema_migrations (version) VALUES ('20130213000631');