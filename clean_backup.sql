--
-- PostgreSQL database dump
--

\restrict EUdXtk4EVCl9MdOKLWzK4aEctzNzDntwy3LWjzBMuFov6Ye4RfvFArBsMjcHhbY

-- Dumped from database version 17.4
-- Dumped by pg_dump version 18.2

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
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA extensions;


--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql;


--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql_public;


--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgbouncer;


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA realtime;


--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA storage;


--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA vault;


--
-- Name: hypopg; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hypopg WITH SCHEMA extensions;


--
-- Name: EXTENSION hypopg; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hypopg IS 'Hypothetical indexes for PostgreSQL';


--
-- Name: index_advisor; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS index_advisor WITH SCHEMA extensions;


--
-- Name: EXTENSION index_advisor; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION index_advisor IS 'Query index advisor';


--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_graphql WITH SCHEMA graphql;


--
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


--
-- Name: oauth_authorization_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_authorization_status AS ENUM (
    'pending',
    'approved',
    'denied',
    'expired'
);


--
-- Name: oauth_client_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_client_type AS ENUM (
    'public',
    'confidential'
);


--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


--
-- Name: oauth_response_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_response_type AS ENUM (
    'code'
);


--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


--
-- Name: action; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


--
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: -
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS',
    'VECTOR'
);


--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: -
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $_$
  BEGIN
      RAISE DEBUG 'PgBouncer auth request: %', p_usename;

      RETURN QUERY
      SELECT
          rolname::text,
          CASE WHEN rolvaliduntil < now()
              THEN null
              ELSE rolpassword::text
          END
      FROM pg_authid
      WHERE rolname=$1 and rolcanlogin;
  END;
  $_$;


--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  insert into public.profiles (id, email, full_name, created_at, updated_at)
  values (
    new.id,
    new.email,
    -- use raw_user_meta_data which exists in this Supabase version
    new.raw_user_meta_data->>'full_name',
    now(), now()
  )
  on conflict (id) do update
  set
    email = excluded.email,
    full_name = coalesce(excluded.full_name, public.profiles.full_name),
    updated_at = now();
  return new;
end;
$$;


--
-- Name: handle_update_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_update_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  update public.profiles
  set
    email = new.email,
    full_name = coalesce(new.raw_user_meta_data->>'full_name', public.profiles.full_name),
    updated_at = now()
  where id = new.id;
  return new;
end;
$$;


--
-- Name: sync_profile_avatar_url_to_forum(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sync_profile_avatar_url_to_forum() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF TG_OP = 'UPDATE' AND (OLD.avatar_url IS NOT DISTINCT FROM NEW.avatar_url) THEN
    RETURN NEW;
  END IF;

  IF NEW.avatar_url IS NOT NULL THEN
    UPDATE public.forum_threads
      SET author_avatar_url = NEW.avatar_url
     WHERE author_id = NEW.id;

    UPDATE public.forum_posts
      SET author_avatar_url = NEW.avatar_url
     WHERE author_id = NEW.id;
  ELSE
    UPDATE public.forum_threads
      SET author_avatar_url = NULL
     WHERE author_id = NEW.id;

    UPDATE public.forum_posts
      SET author_avatar_url = NULL
     WHERE author_id = NEW.id;
  END IF;

  RETURN NEW;
END;
$$;


--
-- Name: trigger_set_timestamp(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_set_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new.updated_at = now();
  return new;
end;
$$;


--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_
        -- Filter by action early - only get subscriptions interested in this action
        -- action_filter column can be: '*' (all), 'INSERT', 'UPDATE', or 'DELETE'
        and (subs.action_filter = '*' or subs.action_filter = action::text);

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
  final_payload jsonb;
BEGIN
  BEGIN
    -- Generate a new UUID for the id
    generated_id := gen_random_uuid();

    -- Check if payload has an 'id' key, if not, add the generated UUID
    IF payload ? 'id' THEN
      final_payload := payload;
    ELSE
      final_payload := jsonb_set(payload, '{id}', to_jsonb(generated_id));
    END IF;

    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (id, payload, event, topic, private, extension)
    VALUES (generated_id, final_payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      RAISE WARNING 'ErrorSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


--
-- Name: delete_leaf_prefixes(text[], text[]); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.delete_leaf_prefixes(bucket_ids text[], names text[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_rows_deleted integer;
BEGIN
    LOOP
        WITH candidates AS (
            SELECT DISTINCT
                t.bucket_id,
                unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        ),
        uniq AS (
             SELECT
                 bucket_id,
                 name,
                 storage.get_level(name) AS level
             FROM candidates
             WHERE name <> ''
             GROUP BY bucket_id, name
        ),
        leaf AS (
             SELECT
                 p.bucket_id,
                 p.name,
                 p.level
             FROM storage.prefixes AS p
                  JOIN uniq AS u
                       ON u.bucket_id = p.bucket_id
                           AND u.name = p.name
                           AND u.level = p.level
             WHERE NOT EXISTS (
                 SELECT 1
                 FROM storage.objects AS o
                 WHERE o.bucket_id = p.bucket_id
                   AND o.level = p.level + 1
                   AND o.name COLLATE "C" LIKE p.name || '/%'
             )
             AND NOT EXISTS (
                 SELECT 1
                 FROM storage.prefixes AS c
                 WHERE c.bucket_id = p.bucket_id
                   AND c.level = p.level + 1
                   AND c.name COLLATE "C" LIKE p.name || '/%'
             )
        )
        DELETE
        FROM storage.prefixes AS p
            USING leaf AS l
        WHERE p.bucket_id = l.bucket_id
          AND p.name = l.name
          AND p.level = l.level;

        GET DIAGNOSTICS v_rows_deleted = ROW_COUNT;
        EXIT WHEN v_rows_deleted = 0;
    END LOOP;
END;
$$;


--
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    SELECT string_to_array(name, '/') INTO _parts;
    SELECT _parts[array_length(_parts,1)] INTO _filename;
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


--
-- Name: get_common_prefix(text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_common_prefix(p_key text, p_prefix text, p_delimiter text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
SELECT CASE
    WHEN position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)) > 0
    THEN left(p_key, length(p_prefix) + position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)))
    ELSE NULL
END;
$$;


--
-- Name: get_level(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_level(name text) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
SELECT array_length(string_to_array("name", '/'), 1);
$$;


--
-- Name: get_prefix(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_prefix(name text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
SELECT
    CASE WHEN strpos("name", '/') > 0 THEN
             regexp_replace("name", '[\/]{1}[^\/]+\/?$', '')
         ELSE
             ''
        END;
$_$;


--
-- Name: get_prefixes(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_prefixes(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
DECLARE
    parts text[];
    prefixes text[];
    prefix text;
BEGIN
    -- Split the name into parts by '/'
    parts := string_to_array("name", '/');
    prefixes := '{}';

    -- Construct the prefixes, stopping one level below the last part
    FOR i IN 1..array_length(parts, 1) - 1 LOOP
            prefix := array_to_string(parts[1:i], '/');
            prefixes := array_append(prefixes, prefix);
    END LOOP;

    RETURN prefixes;
END;
$$;


--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_objects_with_delimiter(_bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;

    -- Configuration
    v_is_asc BOOLEAN;
    v_prefix TEXT;
    v_start TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_is_asc := lower(coalesce(sort_order, 'asc')) = 'asc';
    v_prefix := coalesce(prefix_param, '');
    v_start := CASE WHEN coalesce(next_token, '') <> '' THEN next_token ELSE coalesce(start_after, '') END;
    v_file_batch_size := LEAST(GREATEST(max_keys * 2, 100), 1000);

    -- Calculate upper bound for prefix filtering (bytewise, using COLLATE "C")
    IF v_prefix = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix, 1) = delimiter_param THEN
        v_upper_bound := left(v_prefix, -1) || chr(ascii(delimiter_param) + 1);
    ELSE
        v_upper_bound := left(v_prefix, -1) || chr(ascii(right(v_prefix, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'AND o.name COLLATE "C" < $3 ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'AND o.name COLLATE "C" >= $3 ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- ========================================================================
    -- SEEK INITIALIZATION: Determine starting position
    -- ========================================================================
    IF v_start = '' THEN
        IF v_is_asc THEN
            v_next_seek := v_prefix;
        ELSE
            -- DESC without cursor: find the last item in range
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;

            IF v_next_seek IS NOT NULL THEN
                v_next_seek := v_next_seek || delimiter_param;
            ELSE
                RETURN;
            END IF;
        END IF;
    ELSE
        -- Cursor provided: determine if it refers to a folder or leaf
        IF EXISTS (
            SELECT 1 FROM storage.objects o
            WHERE o.bucket_id = _bucket_id
              AND o.name COLLATE "C" LIKE v_start || delimiter_param || '%'
            LIMIT 1
        ) THEN
            -- Cursor refers to a folder
            IF v_is_asc THEN
                v_next_seek := v_start || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_start || delimiter_param;
            END IF;
        ELSE
            -- Cursor refers to a leaf object
            IF v_is_asc THEN
                v_next_seek := v_start || delimiter_param;
            ELSE
                v_next_seek := v_start;
            END IF;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= max_keys;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(v_peek_name, v_prefix, delimiter_param);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Emit and skip to next folder (no heap access needed)
            name := rtrim(v_common_prefix, delimiter_param);
            id := NULL;
            updated_at := NULL;
            created_at := NULL;
            last_accessed_at := NULL;
            metadata := NULL;
            RETURN NEXT;
            v_count := v_count + 1;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := left(v_common_prefix, -1) || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_common_prefix;
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query USING _bucket_id, v_next_seek,
                CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix) ELSE v_prefix END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(v_current.name, v_prefix, delimiter_param);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := v_current.name;
                    EXIT;
                END IF;

                -- Emit file
                name := v_current.name;
                id := v_current.id;
                updated_at := v_current.updated_at;
                created_at := v_current.created_at;
                last_accessed_at := v_current.last_accessed_at;
                metadata := v_current.metadata;
                RETURN NEXT;
                v_count := v_count + 1;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := v_current.name || delimiter_param;
                ELSE
                    v_next_seek := v_current.name;
                END IF;

                EXIT WHEN v_count >= max_keys;
            END LOOP;
        END IF;
    END LOOP;
END;
$_$;


--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


--
-- Name: protect_delete(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.protect_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if storage.allow_delete_query is set to 'true'
    IF COALESCE(current_setting('storage.allow_delete_query', true), 'false') != 'true' THEN
        RAISE EXCEPTION 'Direct deletion from storage tables is not allowed. Use the Storage API instead.'
            USING HINT = 'This prevents accidental data loss from orphaned objects.',
                  ERRCODE = '42501';
    END IF;
    RETURN NULL;
END;
$$;


--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;
    v_delimiter CONSTANT TEXT := '/';

    -- Configuration
    v_limit INT;
    v_prefix TEXT;
    v_prefix_lower TEXT;
    v_is_asc BOOLEAN;
    v_order_by TEXT;
    v_sort_order TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;
    v_skipped INT := 0;
BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_limit := LEAST(coalesce(limits, 100), 1500);
    v_prefix := coalesce(prefix, '') || coalesce(search, '');
    v_prefix_lower := lower(v_prefix);
    v_is_asc := lower(coalesce(sortorder, 'asc')) = 'asc';
    v_file_batch_size := LEAST(GREATEST(v_limit * 2, 100), 1000);

    -- Validate sort column
    CASE lower(coalesce(sortcolumn, 'name'))
        WHEN 'name' THEN v_order_by := 'name';
        WHEN 'updated_at' THEN v_order_by := 'updated_at';
        WHEN 'created_at' THEN v_order_by := 'created_at';
        WHEN 'last_accessed_at' THEN v_order_by := 'last_accessed_at';
        ELSE v_order_by := 'name';
    END CASE;

    v_sort_order := CASE WHEN v_is_asc THEN 'asc' ELSE 'desc' END;

    -- ========================================================================
    -- NON-NAME SORTING: Use path_tokens approach (unchanged)
    -- ========================================================================
    IF v_order_by != 'name' THEN
        RETURN QUERY EXECUTE format(
            $sql$
            WITH folders AS (
                SELECT path_tokens[$1] AS folder
                FROM storage.objects
                WHERE objects.name ILIKE $2 || '%%'
                  AND bucket_id = $3
                  AND array_length(objects.path_tokens, 1) <> $1
                GROUP BY folder
                ORDER BY folder %s
            )
            (SELECT folder AS "name",
                   NULL::uuid AS id,
                   NULL::timestamptz AS updated_at,
                   NULL::timestamptz AS created_at,
                   NULL::timestamptz AS last_accessed_at,
                   NULL::jsonb AS metadata FROM folders)
            UNION ALL
            (SELECT path_tokens[$1] AS "name",
                   id, updated_at, created_at, last_accessed_at, metadata
             FROM storage.objects
             WHERE objects.name ILIKE $2 || '%%'
               AND bucket_id = $3
               AND array_length(objects.path_tokens, 1) = $1
             ORDER BY %I %s)
            LIMIT $4 OFFSET $5
            $sql$, v_sort_order, v_order_by, v_sort_order
        ) USING levels, v_prefix, bucketname, v_limit, offsets;
        RETURN;
    END IF;

    -- ========================================================================
    -- NAME SORTING: Hybrid skip-scan with batch optimization
    -- ========================================================================

    -- Calculate upper bound for prefix filtering
    IF v_prefix_lower = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix_lower, 1) = v_delimiter THEN
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(v_delimiter) + 1);
    ELSE
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(right(v_prefix_lower, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'AND lower(o.name) COLLATE "C" < $3 ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'AND lower(o.name) COLLATE "C" >= $3 ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- Initialize seek position
    IF v_is_asc THEN
        v_next_seek := v_prefix_lower;
    ELSE
        -- DESC: find the last item in range first (static SQL)
        IF v_upper_bound IS NOT NULL THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower AND lower(o.name) COLLATE "C" < v_upper_bound
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSIF v_prefix_lower <> '' THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSE
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        END IF;

        IF v_peek_name IS NOT NULL THEN
            v_next_seek := lower(v_peek_name) || v_delimiter;
        ELSE
            RETURN;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= v_limit;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix_lower <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(lower(v_peek_name), v_prefix_lower, v_delimiter);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Handle offset, emit if needed, skip to next folder
            IF v_skipped < offsets THEN
                v_skipped := v_skipped + 1;
            ELSE
                name := split_part(rtrim(storage.get_common_prefix(v_peek_name, v_prefix, v_delimiter), v_delimiter), v_delimiter, levels);
                id := NULL;
                updated_at := NULL;
                created_at := NULL;
                last_accessed_at := NULL;
                metadata := NULL;
                RETURN NEXT;
                v_count := v_count + 1;
            END IF;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := lower(left(v_common_prefix, -1)) || chr(ascii(v_delimiter) + 1);
            ELSE
                v_next_seek := lower(v_common_prefix);
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix_lower is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query
                USING bucketname, v_next_seek,
                    CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix_lower) ELSE v_prefix_lower END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(lower(v_current.name), v_prefix_lower, v_delimiter);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := lower(v_current.name);
                    EXIT;
                END IF;

                -- Handle offset skipping
                IF v_skipped < offsets THEN
                    v_skipped := v_skipped + 1;
                ELSE
                    -- Emit file
                    name := split_part(v_current.name, v_delimiter, levels);
                    id := v_current.id;
                    updated_at := v_current.updated_at;
                    created_at := v_current.created_at;
                    last_accessed_at := v_current.last_accessed_at;
                    metadata := v_current.metadata;
                    RETURN NEXT;
                    v_count := v_count + 1;
                END IF;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := lower(v_current.name) || v_delimiter;
                ELSE
                    v_next_seek := lower(v_current.name);
                END IF;

                EXIT WHEN v_count >= v_limit;
            END LOOP;
        END IF;
    END LOOP;
END;
$_$;


--
-- Name: search_by_timestamp(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_by_timestamp(p_prefix text, p_bucket_id text, p_limit integer, p_level integer, p_start_after text, p_sort_order text, p_sort_column text, p_sort_column_after text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_cursor_op text;
    v_query text;
    v_prefix text;
BEGIN
    v_prefix := coalesce(p_prefix, '');

    IF p_sort_order = 'asc' THEN
        v_cursor_op := '>';
    ELSE
        v_cursor_op := '<';
    END IF;

    v_query := format($sql$
        WITH raw_objects AS (
            SELECT
                o.name AS obj_name,
                o.id AS obj_id,
                o.updated_at AS obj_updated_at,
                o.created_at AS obj_created_at,
                o.last_accessed_at AS obj_last_accessed_at,
                o.metadata AS obj_metadata,
                storage.get_common_prefix(o.name, $1, '/') AS common_prefix
            FROM storage.objects o
            WHERE o.bucket_id = $2
              AND o.name COLLATE "C" LIKE $1 || '%%'
        ),
        -- Aggregate common prefixes (folders)
        -- Both created_at and updated_at use MIN(obj_created_at) to match the old prefixes table behavior
        aggregated_prefixes AS (
            SELECT
                rtrim(common_prefix, '/') AS name,
                NULL::uuid AS id,
                MIN(obj_created_at) AS updated_at,
                MIN(obj_created_at) AS created_at,
                NULL::timestamptz AS last_accessed_at,
                NULL::jsonb AS metadata,
                TRUE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NOT NULL
            GROUP BY common_prefix
        ),
        leaf_objects AS (
            SELECT
                obj_name AS name,
                obj_id AS id,
                obj_updated_at AS updated_at,
                obj_created_at AS created_at,
                obj_last_accessed_at AS last_accessed_at,
                obj_metadata AS metadata,
                FALSE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NULL
        ),
        combined AS (
            SELECT * FROM aggregated_prefixes
            UNION ALL
            SELECT * FROM leaf_objects
        ),
        filtered AS (
            SELECT *
            FROM combined
            WHERE (
                $5 = ''
                OR ROW(
                    date_trunc('milliseconds', %I),
                    name COLLATE "C"
                ) %s ROW(
                    COALESCE(NULLIF($6, '')::timestamptz, 'epoch'::timestamptz),
                    $5
                )
            )
        )
        SELECT
            split_part(name, '/', $3) AS key,
            name,
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
        FROM filtered
        ORDER BY
            COALESCE(date_trunc('milliseconds', %I), 'epoch'::timestamptz) %s,
            name COLLATE "C" %s
        LIMIT $4
    $sql$,
        p_sort_column,
        v_cursor_op,
        p_sort_column,
        p_sort_order,
        p_sort_order
    );

    RETURN QUERY EXECUTE v_query
    USING v_prefix, p_bucket_id, p_level, p_limit, p_start_after, p_sort_column_after;
END;
$_$;


--
-- Name: search_legacy_v1(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_legacy_v1(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select path_tokens[$1] as folder
           from storage.objects
             where objects.name ilike $2 || $3 || ''%''
               and bucket_id = $4
               and array_length(objects.path_tokens, 1) <> $1
           group by folder
           order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


--
-- Name: search_v2(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_sort_col text;
    v_sort_ord text;
    v_limit int;
BEGIN
    -- Cap limit to maximum of 1500 records
    v_limit := LEAST(coalesce(limits, 100), 1500);

    -- Validate and normalize sort_order
    v_sort_ord := lower(coalesce(sort_order, 'asc'));
    IF v_sort_ord NOT IN ('asc', 'desc') THEN
        v_sort_ord := 'asc';
    END IF;

    -- Validate and normalize sort_column
    v_sort_col := lower(coalesce(sort_column, 'name'));
    IF v_sort_col NOT IN ('name', 'updated_at', 'created_at') THEN
        v_sort_col := 'name';
    END IF;

    -- Route to appropriate implementation
    IF v_sort_col = 'name' THEN
        -- Use list_objects_with_delimiter for name sorting (most efficient: O(k * log n))
        RETURN QUERY
        SELECT
            split_part(l.name, '/', levels) AS key,
            l.name AS name,
            l.id,
            l.updated_at,
            l.created_at,
            l.last_accessed_at,
            l.metadata
        FROM storage.list_objects_with_delimiter(
            bucket_name,
            coalesce(prefix, ''),
            '/',
            v_limit,
            start_after,
            '',
            v_sort_ord
        ) l;
    ELSE
        -- Use aggregation approach for timestamp sorting
        -- Not efficient for large datasets but supports correct pagination
        RETURN QUERY SELECT * FROM storage.search_by_timestamp(
            prefix, bucket_name, v_limit, levels, start_after,
            v_sort_ord, v_sort_col, sort_column_after
        );
    END IF;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text,
    code_challenge_method auth.code_challenge_method,
    code_challenge text,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone,
    invite_token text,
    referrer text,
    oauth_client_state_id uuid,
    linking_target_id uuid,
    email_optional boolean DEFAULT false NOT NULL
);


--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.flow_state IS 'Stores metadata for all OAuth/SSO login flows';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid,
    last_webauthn_challenge_data jsonb
);


--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: COLUMN mfa_factors.last_webauthn_challenge_data; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.mfa_factors.last_webauthn_challenge_data IS 'Stores the latest WebAuthn challenge data including attestation/assertion for customer verification';


--
-- Name: oauth_authorizations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_authorizations (
    id uuid NOT NULL,
    authorization_id text NOT NULL,
    client_id uuid NOT NULL,
    user_id uuid,
    redirect_uri text NOT NULL,
    scope text NOT NULL,
    state text,
    resource text,
    code_challenge text,
    code_challenge_method auth.code_challenge_method,
    response_type auth.oauth_response_type DEFAULT 'code'::auth.oauth_response_type NOT NULL,
    status auth.oauth_authorization_status DEFAULT 'pending'::auth.oauth_authorization_status NOT NULL,
    authorization_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:03:00'::interval) NOT NULL,
    approved_at timestamp with time zone,
    nonce text,
    CONSTRAINT oauth_authorizations_authorization_code_length CHECK ((char_length(authorization_code) <= 255)),
    CONSTRAINT oauth_authorizations_code_challenge_length CHECK ((char_length(code_challenge) <= 128)),
    CONSTRAINT oauth_authorizations_expires_at_future CHECK ((expires_at > created_at)),
    CONSTRAINT oauth_authorizations_nonce_length CHECK ((char_length(nonce) <= 255)),
    CONSTRAINT oauth_authorizations_redirect_uri_length CHECK ((char_length(redirect_uri) <= 2048)),
    CONSTRAINT oauth_authorizations_resource_length CHECK ((char_length(resource) <= 2048)),
    CONSTRAINT oauth_authorizations_scope_length CHECK ((char_length(scope) <= 4096)),
    CONSTRAINT oauth_authorizations_state_length CHECK ((char_length(state) <= 4096))
);


--
-- Name: oauth_client_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_client_states (
    id uuid NOT NULL,
    provider_type text NOT NULL,
    code_verifier text,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: TABLE oauth_client_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.oauth_client_states IS 'Stores OAuth states for third-party provider authentication flows where Supabase acts as the OAuth client.';


--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_secret_hash text,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    client_type auth.oauth_client_type DEFAULT 'confidential'::auth.oauth_client_type NOT NULL,
    token_endpoint_auth_method text NOT NULL,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048)),
    CONSTRAINT oauth_clients_token_endpoint_auth_method_check CHECK ((token_endpoint_auth_method = ANY (ARRAY['client_secret_basic'::text, 'client_secret_post'::text, 'none'::text])))
);


--
-- Name: oauth_consents; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_consents (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    client_id uuid NOT NULL,
    scopes text NOT NULL,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_at timestamp with time zone,
    CONSTRAINT oauth_consents_revoked_after_granted CHECK (((revoked_at IS NULL) OR (revoked_at >= granted_at))),
    CONSTRAINT oauth_consents_scopes_length CHECK ((char_length(scopes) <= 2048)),
    CONSTRAINT oauth_consents_scopes_not_empty CHECK ((char_length(TRIM(BOTH FROM scopes)) > 0))
);


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: -
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: -
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text,
    oauth_client_id uuid,
    refresh_token_hmac_key text,
    refresh_token_counter bigint,
    scopes text,
    CONSTRAINT sessions_scopes_length CHECK ((char_length(scopes) <= 4096))
);


--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: COLUMN sessions.refresh_token_hmac_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_hmac_key IS 'Holds a HMAC-SHA256 key used to sign refresh tokens for this session.';


--
-- Name: COLUMN sessions.refresh_token_counter; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_counter IS 'Holds the ID (counter) of the last issued refresh token.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    title text NOT NULL,
    description text,
    user_agent text,
    ip text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone,
    metadata jsonb
);


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contacts (
    id bigint NOT NULL,
    first_name text,
    last_name text,
    email text NOT NULL,
    message text,
    file_name text,
    file_url text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone
);


--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contacts_id_seq
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
-- Name: forum_posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_posts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    thread_id uuid NOT NULL,
    content text NOT NULL,
    author_id uuid,
    author_display text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone,
    author_avatar_url text,
    pinned boolean DEFAULT false
);


--
-- Name: forum_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_reports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    reporter_id uuid,
    target_type text NOT NULL,
    thread_id uuid,
    post_id uuid,
    reason text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone,
    CONSTRAINT forum_reports_target_type_check CHECK ((target_type = ANY (ARRAY['thread'::text, 'post'::text])))
);


--
-- Name: forum_threads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_threads (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title text NOT NULL,
    content text,
    author_id uuid,
    author_display text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone,
    author_avatar_url text,
    pinned boolean DEFAULT false
);


--
-- Name: notifications_sent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications_sent (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    subject text,
    body text,
    sent_by text,
    recipients_count integer DEFAULT 0,
    sent_count integer DEFAULT 0,
    failed_count integer DEFAULT 0,
    dry_run boolean DEFAULT false,
    meta jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


--
-- Name: password_reset_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password_reset_attempts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text NOT NULL,
    ip text,
    user_agent text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profiles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text NOT NULL,
    full_name text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    avatar_url text,
    preferences jsonb DEFAULT '{}'::jsonb,
    avatar_path text,
    username text
);


--
-- Name: trusted_devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trusted_devices (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    token_hash text NOT NULL,
    name text,
    user_agent text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    last_seen timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
)
PARTITION BY RANGE (inserted_at);


--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    action_filter text DEFAULT '*'::text,
    CONSTRAINT subscription_action_filter_check CHECK ((action_filter = ANY (ARRAY['*'::text, 'INSERT'::text, 'UPDATE'::text, 'DELETE'::text])))
);


--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: -
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL
);


--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_analytics (
    name text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: buckets_vectors; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_vectors (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'VECTOR'::storage.buckettype NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: objects; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb
);


--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb
);


--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: vector_indexes; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.vector_indexes (
    id text DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    bucket_id text NOT NULL,
    data_type text NOT NULL,
    dimension integer NOT NULL,
    distance_metric text NOT NULL,
    metadata_configuration jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
00000000-0000-0000-0000-000000000000	708ffc99-5b22-4b60-b973-fb3e6fb7b354	{"action":"user_confirmation_requested","actor_id":"8a6c78ba-d475-4282-9fd4-7948a425f819","actor_username":"fbechar@outlook.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-06 01:42:43.858849+00	
00000000-0000-0000-0000-000000000000	ed4b51b2-1dea-414c-bef1-16f92e6e6562	{"action":"user_confirmation_requested","actor_id":"b4b2ac29-3c92-4ffc-9cb5-d6ec2673ef2f","actor_username":"f.bechar@outlook.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-06 04:01:57.413315+00	
00000000-0000-0000-0000-000000000000	83f798d0-45f2-414e-8ab2-fdf98b99f311	{"action":"user_signedup","actor_id":"b4b2ac29-3c92-4ffc-9cb5-d6ec2673ef2f","actor_username":"f.bechar@outlook.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-06 04:03:55.283216+00	
00000000-0000-0000-0000-000000000000	90d3902e-cc04-403b-8963-616223580fc1	{"action":"user_repeated_signup","actor_id":"b4b2ac29-3c92-4ffc-9cb5-d6ec2673ef2f","actor_username":"f.bechar@outlook.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-06 04:40:21.412985+00	
00000000-0000-0000-0000-000000000000	7b715be4-f202-49f0-a798-7d36bd7ffe5e	{"action":"user_confirmation_requested","actor_id":"72754664-5af0-4bb6-9d53-54a9c5795798","actor_username":"fouad.bashaar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-06 04:42:09.088943+00	
00000000-0000-0000-0000-000000000000	4902d0b0-8efd-455e-a6c8-4bbaa0a664ad	{"action":"user_signedup","actor_id":"72754664-5af0-4bb6-9d53-54a9c5795798","actor_username":"fouad.bashaar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-06 04:42:19.522314+00	
00000000-0000-0000-0000-000000000000	baceda8e-dc33-4a52-a9ad-5a8da76f3190	{"action":"login","actor_id":"b4b2ac29-3c92-4ffc-9cb5-d6ec2673ef2f","actor_username":"f.bechar@outlook.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-06 04:54:39.178392+00	
00000000-0000-0000-0000-000000000000	8acb61b8-c4ea-4f64-9917-78e458c3fae1	{"action":"user_repeated_signup","actor_id":"b4b2ac29-3c92-4ffc-9cb5-d6ec2673ef2f","actor_username":"f.bechar@outlook.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-06 13:23:07.681528+00	
00000000-0000-0000-0000-000000000000	cbcbecc1-4dac-4cb1-b33b-e59f5e4b9527	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"f.bechar@outlook.com","user_id":"b4b2ac29-3c92-4ffc-9cb5-d6ec2673ef2f","user_phone":""}}	2025-10-06 13:30:40.122868+00	
00000000-0000-0000-0000-000000000000	eecc47a5-942e-4277-b796-e27a7ff5ec68	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fbechar@outlook.com","user_id":"8a6c78ba-d475-4282-9fd4-7948a425f819","user_phone":""}}	2025-10-06 13:30:40.123088+00	
00000000-0000-0000-0000-000000000000	5212844c-da4f-47b8-af6c-6584d20bd3f2	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouad.bashaar@gmail.com","user_id":"72754664-5af0-4bb6-9d53-54a9c5795798","user_phone":""}}	2025-10-06 13:30:40.124425+00	
00000000-0000-0000-0000-000000000000	674c229d-9e16-48e8-8950-7e3475367b8f	{"action":"user_confirmation_requested","actor_id":"3252535c-0753-416e-bbca-1f62719aa8ca","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-06 14:30:41.662521+00	
00000000-0000-0000-0000-000000000000	b8c6d1ee-0fce-402d-965d-fddc038db6ea	{"action":"user_signedup","actor_id":"3252535c-0753-416e-bbca-1f62719aa8ca","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-06 14:41:46.51938+00	
00000000-0000-0000-0000-000000000000	73497ef6-8d42-42d6-a872-d6ff6f7c6d5f	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"3252535c-0753-416e-bbca-1f62719aa8ca","user_phone":""}}	2025-10-06 14:45:39.530629+00	
00000000-0000-0000-0000-000000000000	b993b819-2f0c-4a63-96d1-3077869a39fb	{"action":"user_confirmation_requested","actor_id":"df8f7906-80bb-499b-82d3-04dea8732b44","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-06 14:46:44.753138+00	
00000000-0000-0000-0000-000000000000	9dbf1ee6-3d24-40bd-a688-b939824abd3b	{"action":"user_signedup","actor_id":"df8f7906-80bb-499b-82d3-04dea8732b44","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-06 14:46:58.463377+00	
00000000-0000-0000-0000-000000000000	f88f1763-f898-4417-909d-38d0c57b2cc6	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"df8f7906-80bb-499b-82d3-04dea8732b44","user_phone":""}}	2025-10-06 14:55:17.790363+00	
00000000-0000-0000-0000-000000000000	9203f907-b4d0-4661-bdaa-d7bcb1f839ce	{"action":"user_confirmation_requested","actor_id":"59154f78-96ee-4d0f-b44a-79673aacbedd","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-06 15:40:35.779625+00	
00000000-0000-0000-0000-000000000000	42caaac8-0206-4d5c-a449-540c5b744524	{"action":"user_signedup","actor_id":"59154f78-96ee-4d0f-b44a-79673aacbedd","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-06 15:42:01.474743+00	
00000000-0000-0000-0000-000000000000	3d4bfccb-0cf7-4055-8c27-df738ee10d79	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"59154f78-96ee-4d0f-b44a-79673aacbedd","user_phone":""}}	2025-10-06 16:17:36.974109+00	
00000000-0000-0000-0000-000000000000	ec807156-f600-4757-affa-bd07642e321b	{"action":"user_confirmation_requested","actor_id":"1355c5b1-81ee-4eaa-a330-63c04da38ec6","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-06 16:20:14.852535+00	
00000000-0000-0000-0000-000000000000	b8d13ba9-b58f-49ab-957d-ff3937a2cef9	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"1355c5b1-81ee-4eaa-a330-63c04da38ec6","user_phone":""}}	2025-10-06 17:03:26.419944+00	
00000000-0000-0000-0000-000000000000	da289ad5-43ce-45fc-8972-138a4434db41	{"action":"user_confirmation_requested","actor_id":"8f4292ed-c4f3-4bf1-b681-2125d4c11132","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-06 17:08:37.597074+00	
00000000-0000-0000-0000-000000000000	62d39f0d-7829-4fcc-8089-885944ff7d0a	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"8f4292ed-c4f3-4bf1-b681-2125d4c11132","user_phone":""}}	2025-10-06 17:17:11.484924+00	
00000000-0000-0000-0000-000000000000	809d2fa5-228a-47b7-b28b-b12c85e77630	{"action":"user_confirmation_requested","actor_id":"8a4d148b-f2eb-4b45-aa35-4ae2f833fad0","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-06 18:07:31.762719+00	
00000000-0000-0000-0000-000000000000	cfb64b3a-7e63-4e25-bfbc-33924eddd74f	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"8a4d148b-f2eb-4b45-aa35-4ae2f833fad0","user_phone":""}}	2025-10-06 18:12:44.807789+00	
00000000-0000-0000-0000-000000000000	cbc26fb6-a3ba-4132-84d9-77970c43fc5c	{"action":"user_confirmation_requested","actor_id":"3bc111b8-7b05-4367-83a4-b16d14481d43","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-06 18:26:51.013527+00	
00000000-0000-0000-0000-000000000000	367da761-75bc-4f49-abb9-6a75d78b715f	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"3bc111b8-7b05-4367-83a4-b16d14481d43","user_phone":""}}	2025-10-06 18:28:49.320365+00	
00000000-0000-0000-0000-000000000000	5ac031a8-77ff-44ab-bfb9-1a5152206a17	{"action":"user_confirmation_requested","actor_id":"fbd4691c-332a-46c7-a702-3904b202a768","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-06 18:31:49.585814+00	
00000000-0000-0000-0000-000000000000	6bb07333-814b-4494-979f-5a43e63ba5c4	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"fbd4691c-332a-46c7-a702-3904b202a768","user_phone":""}}	2025-10-06 18:43:29.930074+00	
00000000-0000-0000-0000-000000000000	016f08ff-38af-4627-941b-da7b9aff2e0e	{"action":"user_confirmation_requested","actor_id":"f82ad56a-43ac-407c-9040-b35d60aeaa5c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-06 18:50:43.251589+00	
00000000-0000-0000-0000-000000000000	ec057604-1a1a-4f0f-8536-a860a48b54ba	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"f82ad56a-43ac-407c-9040-b35d60aeaa5c","user_phone":""}}	2025-10-06 19:04:44.206104+00	
00000000-0000-0000-0000-000000000000	fd49ca85-9fec-44ff-9712-3caf5e2f51be	{"action":"user_confirmation_requested","actor_id":"4ef9bba9-4f7d-4c24-b48d-8b87a96a68fb","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-06 19:05:59.078851+00	
00000000-0000-0000-0000-000000000000	9349e243-98fa-4e5f-8f5a-66dec32f923a	{"action":"logout","actor_id":"b1c7abfd-6a48-4a2b-bcc1-641b699659dd","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-13 11:56:46.995755+00	
00000000-0000-0000-0000-000000000000	811587d2-fea1-4f14-8cb8-509d935e93c3	{"action":"login","actor_id":"b1c7abfd-6a48-4a2b-bcc1-641b699659dd","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-13 11:57:46.747495+00	
00000000-0000-0000-0000-000000000000	a4319a32-ef2a-4f53-883a-a9ac9c0d51b5	{"action":"logout","actor_id":"b1c7abfd-6a48-4a2b-bcc1-641b699659dd","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-14 12:39:02.449692+00	
00000000-0000-0000-0000-000000000000	b027e8bd-1773-4c49-8f10-1ec961e7881a	{"action":"user_confirmation_requested","actor_id":"4ef9bba9-4f7d-4c24-b48d-8b87a96a68fb","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-06 19:29:19.256595+00	
00000000-0000-0000-0000-000000000000	cc4041a9-109b-4c23-afd6-64e014e5db70	{"action":"user_recovery_requested","actor_id":"4ef9bba9-4f7d-4c24-b48d-8b87a96a68fb","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-06 19:47:08.346298+00	
00000000-0000-0000-0000-000000000000	16f700a1-d785-4024-ba5a-bce54113fe4c	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"4ef9bba9-4f7d-4c24-b48d-8b87a96a68fb","user_phone":""}}	2025-10-06 19:47:33.815777+00	
00000000-0000-0000-0000-000000000000	a11679d9-f96f-4b23-8586-1d3210ff3f6a	{"action":"user_confirmation_requested","actor_id":"a7d1b932-869d-457c-8516-33ec09769535","actor_username":"f.bechar@outlook.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-06 19:55:33.41249+00	
00000000-0000-0000-0000-000000000000	01daad3c-c174-48e7-9977-9cb82cbc9e76	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765658095712@example.test","user_id":"39bc6d84-4000-48ca-bc38-6e5b7102faea","user_phone":""}}	2025-12-14 12:50:40.662547+00	
00000000-0000-0000-0000-000000000000	d9b49b71-50df-444e-a133-7476d42e16cc	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765657968558@example.test","user_id":"2b7b0105-7056-43f6-8d29-1c670b260eb8","user_phone":""}}	2025-12-14 12:50:40.679497+00	
00000000-0000-0000-0000-000000000000	3287cd08-ee80-4c1f-b720-2e9f4346ed8e	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"f.bechar@outlook.com","user_id":"a7d1b932-869d-457c-8516-33ec09769535","user_phone":""}}	2025-10-06 20:23:34.689879+00	
00000000-0000-0000-0000-000000000000	dcff154a-2b10-43dd-ae56-11ea97f92f8e	{"action":"user_confirmation_requested","actor_id":"3137d216-c879-414b-b471-465a622acd4f","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-06 20:24:31.801653+00	
00000000-0000-0000-0000-000000000000	83e8bd2f-9054-429d-b10a-5c4bca7affd6	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"3137d216-c879-414b-b471-465a622acd4f","user_phone":""}}	2025-10-06 20:27:02.139639+00	
00000000-0000-0000-0000-000000000000	bd7d2c1e-6622-41d9-99ca-927449167970	{"action":"user_confirmation_requested","actor_id":"7322c78c-7085-4d02-8837-b3d8baf0c839","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-06 20:28:55.108783+00	
00000000-0000-0000-0000-000000000000	5a9d2951-cf15-40c7-9568-f4c97a55b8a5	{"action":"user_signedup","actor_id":"7322c78c-7085-4d02-8837-b3d8baf0c839","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-06 20:30:24.407385+00	
00000000-0000-0000-0000-000000000000	b1798e61-2b9d-4407-aeaf-e635e1e1cffb	{"action":"login","actor_id":"7322c78c-7085-4d02-8837-b3d8baf0c839","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-06 20:31:11.036583+00	
00000000-0000-0000-0000-000000000000	77fabd96-b18f-45ae-acaf-e202683b2c1a	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"7322c78c-7085-4d02-8837-b3d8baf0c839","user_phone":""}}	2025-10-07 02:09:32.308452+00	
00000000-0000-0000-0000-000000000000	a41e53fb-04a1-4621-9786-2a7df76102fa	{"action":"user_confirmation_requested","actor_id":"565f2520-94f0-4f61-aa15-e6db6978fd4a","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-07 02:10:26.886243+00	
00000000-0000-0000-0000-000000000000	e8d310e3-30fc-4b30-9a16-12904579465e	{"action":"user_signedup","actor_id":"565f2520-94f0-4f61-aa15-e6db6978fd4a","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-07 02:12:53.693459+00	
00000000-0000-0000-0000-000000000000	f225ea09-4ab2-46ab-bd77-19410b359b36	{"action":"login","actor_id":"565f2520-94f0-4f61-aa15-e6db6978fd4a","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-07 02:13:28.582286+00	
00000000-0000-0000-0000-000000000000	3bc090d6-c17a-439a-aa68-f62b034bdd1f	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"565f2520-94f0-4f61-aa15-e6db6978fd4a","user_phone":""}}	2025-10-07 02:14:44.339743+00	
00000000-0000-0000-0000-000000000000	816be572-89e2-4c4d-a5ea-3bc9c537d3f4	{"action":"user_confirmation_requested","actor_id":"25e6f81b-3a64-4f59-bdab-ca33ead96dd1","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-07 02:45:19.50108+00	
00000000-0000-0000-0000-000000000000	64255ef3-c715-4b8e-bd81-3250c28e59e3	{"action":"user_signedup","actor_id":"25e6f81b-3a64-4f59-bdab-ca33ead96dd1","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-07 02:50:20.022904+00	
00000000-0000-0000-0000-000000000000	223c8aa5-4681-479b-b548-3bf294e1f51c	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"25e6f81b-3a64-4f59-bdab-ca33ead96dd1","user_phone":""}}	2025-10-07 04:21:33.249579+00	
00000000-0000-0000-0000-000000000000	6d1caee4-1c7a-4da2-9104-e2adecacb494	{"action":"user_confirmation_requested","actor_id":"065786a3-ff4a-4621-8668-b1b181b85a87","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-07 04:47:49.917291+00	
00000000-0000-0000-0000-000000000000	da8c1eaa-4ac3-434d-9cc8-e35fc1d2c188	{"action":"user_signedup","actor_id":"065786a3-ff4a-4621-8668-b1b181b85a87","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-07 04:49:36.293489+00	
00000000-0000-0000-0000-000000000000	15dd7556-394f-4ddf-a92a-db67ce6e32d0	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"065786a3-ff4a-4621-8668-b1b181b85a87","user_phone":""}}	2025-10-07 04:50:47.392126+00	
00000000-0000-0000-0000-000000000000	130398bc-451c-4181-a970-0bdf6c50cb3e	{"action":"user_confirmation_requested","actor_id":"a2819af9-7ba7-48c0-8ade-acc7460bf5e8","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-07 04:54:55.420902+00	
00000000-0000-0000-0000-000000000000	707e1805-64e1-4376-9a33-750277a4a9a8	{"action":"user_signedup","actor_id":"a2819af9-7ba7-48c0-8ade-acc7460bf5e8","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-07 04:56:42.37051+00	
00000000-0000-0000-0000-000000000000	8a016a8a-54bd-4c0a-9422-6fc0b3513beb	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"a2819af9-7ba7-48c0-8ade-acc7460bf5e8","user_phone":""}}	2025-10-07 04:57:15.770822+00	
00000000-0000-0000-0000-000000000000	4113cef0-4baa-47cc-b351-74b928ca5dfb	{"action":"user_confirmation_requested","actor_id":"372f03ea-6ba0-4803-acd6-480154cbec2e","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-07 05:00:14.554441+00	
00000000-0000-0000-0000-000000000000	8e13f3ce-903a-4fa9-bde7-f04a78465af8	{"action":"user_signedup","actor_id":"372f03ea-6ba0-4803-acd6-480154cbec2e","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-07 05:00:36.522097+00	
00000000-0000-0000-0000-000000000000	a8ef8559-aaae-44b9-942e-1f2d9d67860d	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"372f03ea-6ba0-4803-acd6-480154cbec2e","user_phone":""}}	2025-10-07 05:01:57.09849+00	
00000000-0000-0000-0000-000000000000	d0f1f483-217d-477f-b3a4-7516f44e3d34	{"action":"user_confirmation_requested","actor_id":"47851300-18b6-43f9-8148-f6c835833c2a","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-07 09:26:01.499685+00	
00000000-0000-0000-0000-000000000000	43793447-a213-423c-aa13-1dcf3a3368c9	{"action":"user_signedup","actor_id":"47851300-18b6-43f9-8148-f6c835833c2a","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-07 09:27:04.969583+00	
00000000-0000-0000-0000-000000000000	0f4eeaa6-e8b8-4967-9297-9cfb0da53dcd	{"action":"user_repeated_signup","actor_id":"47851300-18b6-43f9-8148-f6c835833c2a","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-07 12:45:08.581123+00	
00000000-0000-0000-0000-000000000000	7d6ee65d-2a12-4b4e-92da-1ed959d37049	{"action":"user_confirmation_requested","actor_id":"855ed4a7-7045-4ace-8b0f-d5553546571c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-07 12:50:24.660457+00	
00000000-0000-0000-0000-000000000000	f21f2762-8420-4a75-afa7-07943f9355bb	{"action":"user_confirmation_requested","actor_id":"855ed4a7-7045-4ace-8b0f-d5553546571c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-07 14:14:30.68462+00	
00000000-0000-0000-0000-000000000000	2a2202d6-90e4-4822-9a0a-1b2ae8af452f	{"action":"user_confirmation_requested","actor_id":"919f3f01-3b73-4344-9a4d-0db10b67d1a0","actor_username":"bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-07 14:15:12.143969+00	
00000000-0000-0000-0000-000000000000	7f986032-0da2-4126-aa35-f8f53169bad8	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"47851300-18b6-43f9-8148-f6c835833c2a","user_phone":""}}	2025-10-07 14:22:43.72597+00	
00000000-0000-0000-0000-000000000000	467b3ac2-179b-4740-909e-481eff093512	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"855ed4a7-7045-4ace-8b0f-d5553546571c","user_phone":""}}	2025-10-07 14:22:43.723875+00	
00000000-0000-0000-0000-000000000000	1e2be55c-8af1-4299-ac6c-512d9f31b4e7	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"bechar@gmail.com","user_id":"919f3f01-3b73-4344-9a4d-0db10b67d1a0","user_phone":""}}	2025-10-07 14:22:43.727372+00	
00000000-0000-0000-0000-000000000000	ce2f9987-ca07-42eb-a8c3-92f58e383f49	{"action":"user_confirmation_requested","actor_id":"9e6f2bd2-5792-426e-a42b-daa6bcff1c6b","actor_name":"ahemd","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-07 20:57:58.131344+00	
00000000-0000-0000-0000-000000000000	2c788edf-863c-4fd5-8991-ebdc236e1090	{"action":"user_signedup","actor_id":"9e6f2bd2-5792-426e-a42b-daa6bcff1c6b","actor_name":"ahemd","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-07 21:27:04.966722+00	
00000000-0000-0000-0000-000000000000	408567c4-5598-4469-b776-a6e0b708edbb	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"9e6f2bd2-5792-426e-a42b-daa6bcff1c6b","user_phone":""}}	2025-10-07 21:48:30.01892+00	
00000000-0000-0000-0000-000000000000	753b1526-ee4f-4123-a926-98fe4f4840a1	{"action":"user_confirmation_requested","actor_id":"b22b1bfc-6160-48cc-b39e-0e32d7869a53","actor_name":"ahmed","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-07 21:49:50.820057+00	
00000000-0000-0000-0000-000000000000	0a38a7db-b80e-4722-a597-a23e3b9f42cb	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"b22b1bfc-6160-48cc-b39e-0e32d7869a53","user_phone":""}}	2025-10-07 23:09:58.095444+00	
00000000-0000-0000-0000-000000000000	c299a90d-c985-440c-9a88-8c69fecf15c9	{"action":"user_confirmation_requested","actor_id":"aa404b49-75fc-4f54-8734-fa6365e7cd6a","actor_name":"ahmed","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-07 23:11:31.987058+00	
00000000-0000-0000-0000-000000000000	cfe4c05a-307c-40d2-b77a-e85331ef7f75	{"action":"user_signedup","actor_id":"aa404b49-75fc-4f54-8734-fa6365e7cd6a","actor_name":"ahmed","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-07 23:13:29.334144+00	
00000000-0000-0000-0000-000000000000	3b8ca2a4-b615-4abe-84bc-6daca5c0860f	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"aa404b49-75fc-4f54-8734-fa6365e7cd6a","user_phone":""}}	2025-10-08 21:53:40.939745+00	
00000000-0000-0000-0000-000000000000	759b62a2-c98b-4761-abff-e5156ddf56d3	{"action":"user_recovery_requested","actor_id":"dcc6a8af-9c79-44f4-9125-fa2fa9ccabee","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-09 06:11:14.163214+00	
00000000-0000-0000-0000-000000000000	cba67272-242b-4ffb-a4b5-5e21e3fe9873	{"action":"user_recovery_requested","actor_id":"dcc6a8af-9c79-44f4-9125-fa2fa9ccabee","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-09 06:14:12.890976+00	
00000000-0000-0000-0000-000000000000	bbf9c823-eede-4804-95dc-b6ce08f0f57a	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"dcc6a8af-9c79-44f4-9125-fa2fa9ccabee","user_phone":""}}	2025-10-09 08:32:41.427712+00	
00000000-0000-0000-0000-000000000000	05e1e9b5-ce8c-4fd1-b9b7-a037f7e6d27c	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouad.bashaar@gmail.com","user_id":"6133fd06-697c-4382-af27-eace931c067d","user_phone":""}}	2025-10-09 08:32:41.436647+00	
00000000-0000-0000-0000-000000000000	e81df0ae-ae4f-46f1-9b9b-f32d37638292	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"265bdd60-c451-4e63-959a-8517e1ddc28d","user_phone":""}}	2025-10-09 08:32:41.446217+00	
00000000-0000-0000-0000-000000000000	13a19762-c34e-4e9f-a021-076ea7a2447d	{"action":"user_recovery_requested","actor_id":"4d950d15-12a3-4197-8cbb-6d7cd6aef025","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-10 07:16:11.720013+00	
00000000-0000-0000-0000-000000000000	e5ce9a91-6327-4d9c-82dc-80d18e9cfb66	{"action":"user_confirmation_requested","actor_id":"4d950d15-12a3-4197-8cbb-6d7cd6aef025","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-11 03:06:55.077019+00	
00000000-0000-0000-0000-000000000000	ad4cdd76-83cd-4c3a-b47b-e75e4a4dbcaa	{"action":"user_signedup","actor_id":"c92c210d-931c-4a29-b00a-5de18cba2313","actor_username":"fbechar@outlook.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-11 17:00:28.333641+00	
00000000-0000-0000-0000-000000000000	64c88ae0-a726-45d7-be6d-71d06aeedfe5	{"action":"logout","actor_id":"c92c210d-931c-4a29-b00a-5de18cba2313","actor_username":"fbechar@outlook.com","actor_via_sso":false,"log_type":"account"}	2025-10-11 17:04:57.626716+00	
00000000-0000-0000-0000-000000000000	f1dee86e-b4cc-4b23-9100-ae443722eb0d	{"action":"user_recovery_requested","actor_id":"c92c210d-931c-4a29-b00a-5de18cba2313","actor_username":"fbechar@outlook.com","actor_via_sso":false,"log_type":"user"}	2025-10-11 17:05:20.000606+00	
00000000-0000-0000-0000-000000000000	0f76c9c0-1165-4ad5-9404-f501ef615ede	{"action":"login","actor_id":"c92c210d-931c-4a29-b00a-5de18cba2313","actor_username":"fbechar@outlook.com","actor_via_sso":false,"log_type":"account"}	2025-10-11 17:06:44.832234+00	
00000000-0000-0000-0000-000000000000	1ccb4f9f-2eb6-4119-8809-1f4d2930d4bf	{"action":"user_updated_password","actor_id":"c92c210d-931c-4a29-b00a-5de18cba2313","actor_username":"fbechar@outlook.com","actor_via_sso":false,"log_type":"user"}	2025-10-11 17:06:55.196717+00	
00000000-0000-0000-0000-000000000000	ef342aa2-3170-41c7-b6e3-508920ecac3b	{"action":"user_modified","actor_id":"c92c210d-931c-4a29-b00a-5de18cba2313","actor_username":"fbechar@outlook.com","actor_via_sso":false,"log_type":"user"}	2025-10-11 17:06:55.19812+00	
00000000-0000-0000-0000-000000000000	05ad8580-53de-4192-b956-e7c3eb183fb8	{"action":"logout","actor_id":"c92c210d-931c-4a29-b00a-5de18cba2313","actor_username":"fbechar@outlook.com","actor_via_sso":false,"log_type":"account"}	2025-10-11 17:06:56.279687+00	
00000000-0000-0000-0000-000000000000	0bdc973c-ac73-4525-891c-21146fcb3ec3	{"action":"login","actor_id":"c92c210d-931c-4a29-b00a-5de18cba2313","actor_username":"fbechar@outlook.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-11 17:07:04.162638+00	
00000000-0000-0000-0000-000000000000	856dfbd8-28b2-4be1-a236-a3f77ee21293	{"action":"logout","actor_id":"c92c210d-931c-4a29-b00a-5de18cba2313","actor_username":"fbechar@outlook.com","actor_via_sso":false,"log_type":"account"}	2025-10-11 17:08:48.401305+00	
00000000-0000-0000-0000-000000000000	e8221679-7143-499e-aae5-c027796e4b19	{"action":"user_signedup","actor_id":"32f65f3c-1172-45fc-b089-b855a12ffb5d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-12 20:59:04.623024+00	
00000000-0000-0000-0000-000000000000	30729479-470b-4bb5-9d3b-b681bba8c8a4	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fbechar@outlook.com","user_id":"c92c210d-931c-4a29-b00a-5de18cba2313","user_phone":""}}	2025-10-13 01:05:49.257597+00	
00000000-0000-0000-0000-000000000000	f3b81871-b368-4100-b25d-d27479f6e913	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"32f65f3c-1172-45fc-b089-b855a12ffb5d","user_phone":""}}	2025-10-13 01:05:49.257432+00	
00000000-0000-0000-0000-000000000000	e896d653-958a-4d2e-aaa5-80e7467ce555	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"b76f3f9f-4d56-45c8-aea8-0b708838fa1c","user_phone":""}}	2025-10-13 01:05:49.502251+00	
00000000-0000-0000-0000-000000000000	0c834b59-85aa-4980-aa32-1ccbc5316553	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"4d950d15-12a3-4197-8cbb-6d7cd6aef025","user_phone":""}}	2025-10-13 01:05:49.525622+00	
00000000-0000-0000-0000-000000000000	4009545e-3373-4905-973e-d0a365606223	{"action":"user_signedup","actor_id":"9245ac93-4f17-49a2-a702-a536ae8f1d06","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-13 02:44:18.257207+00	
00000000-0000-0000-0000-000000000000	7ac9a3f3-072a-45c1-a14f-630d9c34d33a	{"action":"user_signedup","actor_id":"eab4b204-6537-497d-94b9-c6d497af7977","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-13 03:45:28.543438+00	
00000000-0000-0000-0000-000000000000	53dbf210-6dd9-4f29-a7c7-6e26a3ce277e	{"action":"logout","actor_id":"eab4b204-6537-497d-94b9-c6d497af7977","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-13 03:47:40.463899+00	
00000000-0000-0000-0000-000000000000	edc9981c-db9a-45f2-a507-0be24aaed788	{"action":"login","actor_id":"eab4b204-6537-497d-94b9-c6d497af7977","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-13 03:47:45.07683+00	
00000000-0000-0000-0000-000000000000	b98676b1-cfc7-4bc4-8a88-1ac656c29608	{"action":"logout","actor_id":"eab4b204-6537-497d-94b9-c6d497af7977","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-13 03:47:48.096302+00	
00000000-0000-0000-0000-000000000000	a3d886fe-32b9-43f3-bdd3-ea13bcfa2883	{"action":"user_recovery_requested","actor_id":"eab4b204-6537-497d-94b9-c6d497af7977","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-13 03:47:56.60323+00	
00000000-0000-0000-0000-000000000000	cccbbe8b-6e1c-44dc-bfe7-aac8c0e77373	{"action":"login","actor_id":"eab4b204-6537-497d-94b9-c6d497af7977","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-13 03:48:32.370802+00	
00000000-0000-0000-0000-000000000000	a434b858-8643-42ef-91d5-d68eafcc047a	{"action":"user_updated_password","actor_id":"eab4b204-6537-497d-94b9-c6d497af7977","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-13 03:48:42.050379+00	
00000000-0000-0000-0000-000000000000	cadc48f6-0059-43e6-8f98-0adf4c2e0864	{"action":"user_modified","actor_id":"eab4b204-6537-497d-94b9-c6d497af7977","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-13 03:48:42.051435+00	
00000000-0000-0000-0000-000000000000	52d0d257-d8e2-48fb-aec9-4a090b9d3dce	{"action":"logout","actor_id":"eab4b204-6537-497d-94b9-c6d497af7977","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-13 03:48:42.828453+00	
00000000-0000-0000-0000-000000000000	4140b462-fe6e-4953-8a4b-d884a5e562df	{"action":"login","actor_id":"eab4b204-6537-497d-94b9-c6d497af7977","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-13 03:48:51.162206+00	
00000000-0000-0000-0000-000000000000	2a030815-78fc-441e-9428-6b5a188761dc	{"action":"logout","actor_id":"eab4b204-6537-497d-94b9-c6d497af7977","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-13 04:08:25.330584+00	
00000000-0000-0000-0000-000000000000	16a1c8e5-a10f-41fb-a271-2cb2b96a4848	{"action":"login","actor_id":"eab4b204-6537-497d-94b9-c6d497af7977","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-13 04:08:28.973303+00	
00000000-0000-0000-0000-000000000000	960705d2-8f25-4ed1-8408-b991c3a65a0d	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"9245ac93-4f17-49a2-a702-a536ae8f1d06","user_phone":""}}	2025-10-13 10:23:22.430755+00	
00000000-0000-0000-0000-000000000000	f0a8bb56-eecd-4657-ae74-9523421db502	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"eab4b204-6537-497d-94b9-c6d497af7977","user_phone":""}}	2025-10-13 10:23:22.454958+00	
00000000-0000-0000-0000-000000000000	bfa62e01-c72f-4853-892b-77a61c169720	{"action":"user_signedup","actor_id":"cda8819f-f291-4400-b722-6d1db1312f24","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-13 10:24:25.405745+00	
00000000-0000-0000-0000-000000000000	285140ca-a218-4a49-b6f9-5a61d606cd1f	{"action":"logout","actor_id":"cda8819f-f291-4400-b722-6d1db1312f24","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-13 11:02:51.41193+00	
00000000-0000-0000-0000-000000000000	b71e8736-1c05-415d-9842-94fd773d357e	{"action":"user_signedup","actor_id":"fabc6b5d-4648-424e-8736-997ad9531442","actor_username":"f.bechar@outlook.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-17 06:58:01.527703+00	
00000000-0000-0000-0000-000000000000	926a51ce-04c0-4c8e-8359-f9ad4502e6cc	{"action":"logout","actor_id":"fabc6b5d-4648-424e-8736-997ad9531442","actor_username":"f.bechar@outlook.com","actor_via_sso":false,"log_type":"account"}	2025-10-17 06:59:17.426124+00	
00000000-0000-0000-0000-000000000000	8da629ec-9570-4fdb-b55c-a890b8b8e938	{"action":"user_signedup","actor_id":"156e8a8b-c80e-43ca-a980-f6ca6e040cbf","actor_username":"fouad.bashaar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-17 20:27:30.037034+00	
00000000-0000-0000-0000-000000000000	f3bbf3b7-2f7d-4280-b1a7-a6a191c00434	{"action":"logout","actor_id":"156e8a8b-c80e-43ca-a980-f6ca6e040cbf","actor_username":"fouad.bashaar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-17 20:28:30.43777+00	
00000000-0000-0000-0000-000000000000	2bb8275d-1080-4d5b-9025-4f6035900042	{"action":"login","actor_id":"156e8a8b-c80e-43ca-a980-f6ca6e040cbf","actor_username":"fouad.bashaar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-18 07:34:46.30785+00	
00000000-0000-0000-0000-000000000000	2c8de93e-5f3a-4f87-b221-389935f2ab35	{"action":"logout","actor_id":"156e8a8b-c80e-43ca-a980-f6ca6e040cbf","actor_username":"fouad.bashaar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-18 07:34:58.986719+00	
00000000-0000-0000-0000-000000000000	68252185-d604-4ba9-a2bf-e912e3d8be73	{"action":"login","actor_id":"156e8a8b-c80e-43ca-a980-f6ca6e040cbf","actor_username":"fouad.bashaar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-18 07:49:06.354428+00	
00000000-0000-0000-0000-000000000000	e0c2b633-cbfe-462d-a0f9-7c503ee8807a	{"action":"logout","actor_id":"156e8a8b-c80e-43ca-a980-f6ca6e040cbf","actor_username":"fouad.bashaar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-18 07:49:42.931549+00	
00000000-0000-0000-0000-000000000000	a157e974-b7ff-47f7-9ef6-4a403e92b37b	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"f.bechar@outlook.com","user_id":"fabc6b5d-4648-424e-8736-997ad9531442","user_phone":""}}	2025-10-20 11:30:17.707413+00	
00000000-0000-0000-0000-000000000000	575011bf-b953-42fd-805d-bbf87071e843	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouad.bashaar@gmail.com","user_id":"156e8a8b-c80e-43ca-a980-f6ca6e040cbf","user_phone":""}}	2025-10-20 11:30:17.777745+00	
00000000-0000-0000-0000-000000000000	0860ab9d-38c4-44da-9408-b2f995d68193	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"cda8819f-f291-4400-b722-6d1db1312f24","user_phone":""}}	2025-10-20 11:30:17.900235+00	
00000000-0000-0000-0000-000000000000	7832dc15-c1a6-47a2-877e-ea303d6c2542	{"action":"user_signedup","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-24 07:40:35.841547+00	
00000000-0000-0000-0000-000000000000	bce15e2d-ab71-422b-a4f7-5145de12626e	{"action":"logout","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-24 07:41:26.765003+00	
00000000-0000-0000-0000-000000000000	bdcaff2e-fdab-4d11-b8fa-a4dea78d391b	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-24 07:42:16.101955+00	
00000000-0000-0000-0000-000000000000	cb9259f9-f98f-4269-9fff-8760b8fd3db7	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-24 07:42:38.615496+00	
00000000-0000-0000-0000-000000000000	6d822a24-0631-4421-9011-165a54b3c8b2	{"action":"logout","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-24 07:43:11.73526+00	
00000000-0000-0000-0000-000000000000	4ecce923-ab0b-43d3-852e-5de60e21ad57	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-26 01:19:04.593934+00	
00000000-0000-0000-0000-000000000000	d8df83f9-d703-478c-b7e3-602d139bd9e6	{"action":"logout","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-26 01:19:23.906698+00	
00000000-0000-0000-0000-000000000000	5e5340da-23b1-43ef-a332-dfcdadcdc196	{"action":"user_recovery_requested","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-26 01:58:25.080981+00	
00000000-0000-0000-0000-000000000000	e2922e85-dfc8-4088-bd22-86d599beaa45	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-26 01:59:12.159701+00	
00000000-0000-0000-0000-000000000000	e45a955d-099b-4aca-a9ac-972f49179211	{"action":"user_updated_password","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-26 02:00:15.332972+00	
00000000-0000-0000-0000-000000000000	89de5524-5a3c-4e9b-990a-1bb63d94773f	{"action":"user_modified","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-26 02:00:15.334075+00	
00000000-0000-0000-0000-000000000000	6fa6cbb7-fbf0-43f9-8074-ffddef32606a	{"action":"logout","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-26 02:00:16.499948+00	
00000000-0000-0000-0000-000000000000	fc6a2559-aa89-4be0-8d30-2557eb35f4ba	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-26 02:00:40.761705+00	
00000000-0000-0000-0000-000000000000	9f7ab193-dbf9-4f2d-bebe-81d683cd984d	{"action":"logout","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-26 02:00:48.007996+00	
00000000-0000-0000-0000-000000000000	73c4a0cb-e22f-49ec-b405-c21f2b2a23f1	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-26 02:00:57.024035+00	
00000000-0000-0000-0000-000000000000	07db09f6-ccec-43be-a207-a3555869842f	{"action":"logout","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-26 02:01:01.473439+00	
00000000-0000-0000-0000-000000000000	2d41ed85-e4c5-4038-802e-6e73212f7ada	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-26 09:43:35.220969+00	
00000000-0000-0000-0000-000000000000	6a06ca6b-05f1-4ac0-b984-727337e3170a	{"action":"logout","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-26 09:44:04.736541+00	
00000000-0000-0000-0000-000000000000	06643bc0-b554-4667-b305-bdc81ae56e48	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-26 09:44:08.91373+00	
00000000-0000-0000-0000-000000000000	0caf5b8c-ad8c-447c-b64b-e53eba0fb16d	{"action":"logout","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-26 09:44:11.691591+00	
00000000-0000-0000-0000-000000000000	f6fdd2d1-bad1-4a24-a4e8-203255728ab9	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-26 10:04:27.651185+00	
00000000-0000-0000-0000-000000000000	f26b3cce-d3e0-49c6-9d5a-12d85cadd072	{"action":"logout","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-26 10:04:34.014799+00	
00000000-0000-0000-0000-000000000000	e78ce731-c454-4b99-a604-313888095500	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-26 10:26:58.074456+00	
00000000-0000-0000-0000-000000000000	695dc4a5-0bef-40b1-9c4b-ffcf786b75a9	{"action":"logout","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-26 10:27:11.960191+00	
00000000-0000-0000-0000-000000000000	9ca791ad-c84b-42dd-af52-0ed7fcab7ec2	{"action":"user_recovery_requested","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-26 15:54:55.03148+00	
00000000-0000-0000-0000-000000000000	753466d8-42de-4fbe-b880-0f64c4e8da53	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-26 15:57:17.710493+00	
00000000-0000-0000-0000-000000000000	0fb609cc-5894-4038-bb7d-cb4a6143ab52	{"action":"user_updated_password","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-26 15:57:35.260782+00	
00000000-0000-0000-0000-000000000000	2be2ae79-d322-4f13-b6ee-4f781c653657	{"action":"user_modified","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-26 15:57:35.26179+00	
00000000-0000-0000-0000-000000000000	4eb4346a-d37d-4f39-b5bb-eebbac09e1e4	{"action":"logout","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-26 15:57:36.610686+00	
00000000-0000-0000-0000-000000000000	d1b38f5a-b62d-4528-84f2-e57cf63397d2	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-26 15:58:04.175714+00	
00000000-0000-0000-0000-000000000000	c4ee7dfc-5948-4ab6-9b3d-35aa3f9cca97	{"action":"logout","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-26 15:58:46.079941+00	
00000000-0000-0000-0000-000000000000	400d64b0-5f04-423a-89d2-679942aa3a41	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-26 15:59:00.915784+00	
00000000-0000-0000-0000-000000000000	41cc0077-ae0e-424a-b229-f19b693832cf	{"action":"user_recovery_requested","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-26 19:34:13.980738+00	
00000000-0000-0000-0000-000000000000	0969ce44-e5b9-4838-a460-65d8e4e8f6f5	{"action":"user_recovery_requested","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-26 19:36:00.761531+00	
00000000-0000-0000-0000-000000000000	9c3df7cd-5933-4d00-afa5-c3b1e7fc452c	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-26 19:37:18.029265+00	
00000000-0000-0000-0000-000000000000	bf5107e6-9883-4e37-b7b8-bcc4b696e49f	{"action":"logout","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-26 20:08:59.922559+00	
00000000-0000-0000-0000-000000000000	5c964d9b-e4e8-4a7a-a2c4-9454a513f6e7	{"action":"user_recovery_requested","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-26 20:09:29.570149+00	
00000000-0000-0000-0000-000000000000	275664d2-6f7f-4adb-946b-4cdbd307324c	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-26 20:10:33.480007+00	
00000000-0000-0000-0000-000000000000	aba2a003-c9b5-49e4-a002-be832fa78895	{"action":"user_updated_password","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-26 20:15:15.726568+00	
00000000-0000-0000-0000-000000000000	e7f0a382-cb9a-4189-92af-a6f2ccc614f8	{"action":"user_modified","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-26 20:15:15.736069+00	
00000000-0000-0000-0000-000000000000	054838cc-48fc-4ad4-9bf7-609be895908f	{"action":"logout","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-26 20:15:19.55407+00	
00000000-0000-0000-0000-000000000000	44408beb-d69e-4fb7-acb7-ba528b037bb7	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-26 20:21:50.410228+00	
00000000-0000-0000-0000-000000000000	73f5c21a-3107-4055-b7bf-e4008bc40199	{"action":"logout","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-26 21:16:36.590728+00	
00000000-0000-0000-0000-000000000000	01368883-6636-49fd-aaae-1a494e0d17bd	{"action":"user_recovery_requested","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-27 15:26:47.264391+00	
00000000-0000-0000-0000-000000000000	db580d93-e474-46f2-accd-63664c25ba6f	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-27 15:28:32.50072+00	
00000000-0000-0000-0000-000000000000	466c85eb-8799-47ba-9c8d-27a28b811e9d	{"action":"user_updated_password","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-27 15:29:54.40049+00	
00000000-0000-0000-0000-000000000000	b806c0ce-2c37-4dac-ae4d-ea97c989768e	{"action":"user_modified","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-27 15:29:54.401488+00	
00000000-0000-0000-0000-000000000000	f56a36d8-294e-485d-b093-c70441a56f51	{"action":"logout","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-27 15:29:55.505724+00	
00000000-0000-0000-0000-000000000000	22ed5248-4e8e-4d89-a8dc-19841a05a9ec	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-27 15:30:08.088506+00	
00000000-0000-0000-0000-000000000000	b0e68768-9c2d-40e9-ac48-29541dd371a8	{"action":"logout","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-27 15:32:16.762129+00	
00000000-0000-0000-0000-000000000000	ab32e578-7e58-47c1-92bc-18ffb47e73ce	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-27 15:32:25.325523+00	
00000000-0000-0000-0000-000000000000	b8f1fb68-d178-41a1-be64-f00ca78eaca8	{"action":"logout","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-27 15:37:21.132925+00	
00000000-0000-0000-0000-000000000000	efbdb742-6fa1-487d-b9b6-f283ea49614f	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-28 02:38:03.543512+00	
00000000-0000-0000-0000-000000000000	4d8278a4-36d3-4da9-93af-b32efe6c5c93	{"action":"logout","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-28 02:38:10.653384+00	
00000000-0000-0000-0000-000000000000	c5f6d107-33a4-4af9-bb39-f0a216945ad5	{"action":"user_signedup","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-28 02:40:10.792042+00	
00000000-0000-0000-0000-000000000000	a3adcdd5-df0d-4672-af87-791a56252e2b	{"action":"logout","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-28 02:41:20.62224+00	
00000000-0000-0000-0000-000000000000	6f86af1e-fc4e-4dd4-98a4-963bff6c1db7	{"action":"login","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-28 15:16:43.062701+00	
00000000-0000-0000-0000-000000000000	64efa807-93f1-438c-a8b0-209d49192236	{"action":"logout","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-28 15:16:53.155765+00	
00000000-0000-0000-0000-000000000000	a1bb7583-fb4c-4f23-9b16-9069e4a2fca9	{"action":"login","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-29 11:30:05.427142+00	
00000000-0000-0000-0000-000000000000	fae5afaf-c29f-4d39-a59f-56309bb6bc7a	{"action":"logout","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-29 11:30:54.791737+00	
00000000-0000-0000-0000-000000000000	923416f9-912c-4485-8b55-35bff5873465	{"action":"login","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-30 05:54:01.886081+00	
00000000-0000-0000-0000-000000000000	216ea187-40b9-4dc7-a4d3-ebf494b65c77	{"action":"logout","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-30 05:55:10.032342+00	
00000000-0000-0000-0000-000000000000	ea97e40a-e73b-4a00-aa53-e750baf617e0	{"action":"login","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-30 19:59:49.8709+00	
00000000-0000-0000-0000-000000000000	b16a320b-3deb-4f57-ae93-62dd3dafaf04	{"action":"token_refreshed","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-30 21:13:36.952621+00	
00000000-0000-0000-0000-000000000000	aa02ca9a-faa5-4e13-bf25-548d4e4aa37c	{"action":"token_revoked","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-30 21:13:36.972345+00	
00000000-0000-0000-0000-000000000000	ecfba94c-e7a3-4c24-b36d-f7ea8e4c4607	{"action":"token_refreshed","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-30 21:13:41.613912+00	
00000000-0000-0000-0000-000000000000	d05005ad-3b5f-4fc8-99ae-3c300a9e5578	{"action":"token_refreshed","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-30 22:05:28.70615+00	
00000000-0000-0000-0000-000000000000	2039dbb6-d8c8-4781-b636-89542f9f89ae	{"action":"token_refreshed","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-30 22:28:50.252916+00	
00000000-0000-0000-0000-000000000000	9bd4481b-555c-45c5-9aeb-81c5d26bdd3d	{"action":"token_refreshed","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-30 22:29:01.006529+00	
00000000-0000-0000-0000-000000000000	326c5dbf-973f-4434-b3e3-8de1ec9baa6a	{"action":"token_refreshed","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-31 03:13:14.367223+00	
00000000-0000-0000-0000-000000000000	3fe73bef-3c57-4104-b8a4-46e4476e91e5	{"action":"logout","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-31 03:16:12.408443+00	
00000000-0000-0000-0000-000000000000	5818557b-48f5-4cd5-b1f1-dfb188678557	{"action":"login","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-31 03:16:24.48996+00	
00000000-0000-0000-0000-000000000000	ebbf3e89-2a29-42a9-a9b8-121a6e19bb3f	{"action":"logout","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-31 03:22:13.129611+00	
00000000-0000-0000-0000-000000000000	a1562627-c28b-41f3-a537-05909ea98dc0	{"action":"login","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-31 22:26:28.309297+00	
00000000-0000-0000-0000-000000000000	43d57f5a-df4f-4698-b2eb-633b702c74bf	{"action":"logout","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-31 22:26:33.969418+00	
00000000-0000-0000-0000-000000000000	c4af8c66-ad0c-444e-a401-77df6ceb4f15	{"action":"user_signedup","actor_id":"07b0135d-1ab5-44ce-9926-5fc199ad4aff","actor_username":"fouad.bechar@outlook.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-31 22:37:35.92671+00	
00000000-0000-0000-0000-000000000000	09ef3793-323d-460b-8544-84bdf16601f8	{"action":"logout","actor_id":"07b0135d-1ab5-44ce-9926-5fc199ad4aff","actor_username":"fouad.bechar@outlook.com","actor_via_sso":false,"log_type":"account"}	2025-10-31 22:37:41.13851+00	
00000000-0000-0000-0000-000000000000	5295ee37-bc1b-4117-a020-1f6be0d362ef	{"action":"user_recovery_requested","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-31 22:52:12.66259+00	
00000000-0000-0000-0000-000000000000	6f72ec83-a8a0-4f96-b377-bef8baaa6a1d	{"action":"login","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-31 22:53:10.600314+00	
00000000-0000-0000-0000-000000000000	a22160f2-19c5-4f95-ba64-4a8c4fb6c54a	{"action":"user_updated_password","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-31 22:53:18.381438+00	
00000000-0000-0000-0000-000000000000	26c5ab51-367a-42fe-ad6c-9f7f8b992562	{"action":"user_modified","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-31 22:53:18.382586+00	
00000000-0000-0000-0000-000000000000	e7bbf3cc-d5e3-4b66-987d-423783ee8f87	{"action":"logout","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-31 22:53:19.449861+00	
00000000-0000-0000-0000-000000000000	6a301bf1-fd90-46fc-8f6d-489c5962ad90	{"action":"login","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-31 22:54:38.293434+00	
00000000-0000-0000-0000-000000000000	0da1fa00-f8fa-4cc5-a9d7-d15c829e2e28	{"action":"token_refreshed","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-01 07:21:11.727758+00	
00000000-0000-0000-0000-000000000000	0b97b913-0893-48ba-bdfd-f17504630934	{"action":"token_revoked","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-01 07:21:11.752892+00	
00000000-0000-0000-0000-000000000000	9146b71a-8754-4589-9ad6-31f183785c87	{"action":"logout","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-01 07:21:52.724388+00	
00000000-0000-0000-0000-000000000000	54596955-c713-475a-a124-69ba28906dbc	{"action":"login","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-01 07:22:00.930893+00	
00000000-0000-0000-0000-000000000000	35d74f5e-d297-49b1-831e-195ba0108e5e	{"action":"logout","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-01 07:26:04.781989+00	
00000000-0000-0000-0000-000000000000	edee4841-4601-4066-8efe-17932bbb35c0	{"action":"login","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-02 01:15:19.330656+00	
00000000-0000-0000-0000-000000000000	31ad11d4-9812-4432-ab02-9b41a298d1ca	{"action":"logout","actor_id":"97893766-3092-4729-b797-de5330cc076c","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-02 01:21:46.087428+00	
00000000-0000-0000-0000-000000000000	53aadea8-457f-4b3c-8121-ae1eb4266467	{"action":"user_recovery_requested","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-02 02:06:12.852166+00	
00000000-0000-0000-0000-000000000000	ad240515-b8ce-457b-9661-89c8068f910d	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-02 02:07:14.185142+00	
00000000-0000-0000-0000-000000000000	eee9581e-acf4-45bf-a67c-79f3246fcdc8	{"action":"user_updated_password","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-02 02:07:26.197667+00	
00000000-0000-0000-0000-000000000000	4480398a-4836-41f2-8ce0-a9c080576b7e	{"action":"user_modified","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-02 02:07:26.198989+00	
00000000-0000-0000-0000-000000000000	9080a6f2-aa31-485d-9d9b-515f0226f38b	{"action":"logout","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-02 02:07:27.429434+00	
00000000-0000-0000-0000-000000000000	8fdc2c40-6703-42ab-8e2c-7487fadf9032	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-02 02:07:36.396761+00	
00000000-0000-0000-0000-000000000000	af25cc4f-48ee-41d3-a34f-b7682f04c98a	{"action":"logout","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-02 02:10:32.969757+00	
00000000-0000-0000-0000-000000000000	74b40234-097d-47b3-80ab-c79a13cbd061	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-02 02:10:42.387853+00	
00000000-0000-0000-0000-000000000000	fd966b6f-49fe-46c1-b599-ce509dba8411	{"action":"logout","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-02 02:12:16.494501+00	
00000000-0000-0000-0000-000000000000	6953b882-753f-4569-86ce-a0c5f4f5b913	{"action":"login","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-02 02:12:47.472945+00	
00000000-0000-0000-0000-000000000000	0fb28cad-14d7-4382-802d-056409373e60	{"action":"logout","actor_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-02 02:12:52.125253+00	
00000000-0000-0000-0000-000000000000	747e5956-786f-4d33-946b-c89fa409ad55	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"97893766-3092-4729-b797-de5330cc076c","user_phone":""}}	2025-11-02 03:50:00.887568+00	
00000000-0000-0000-0000-000000000000	224d9527-6c1b-468b-b175-10205d181c12	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"8426c657-c6d7-4d7f-b384-381bba8a1d23","user_phone":""}}	2025-11-02 03:50:00.904092+00	
00000000-0000-0000-0000-000000000000	9790ee94-7a80-4d6c-9088-518f8924d020	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouad.bechar@outlook.com","user_id":"07b0135d-1ab5-44ce-9926-5fc199ad4aff","user_phone":""}}	2025-11-02 03:50:00.904567+00	
00000000-0000-0000-0000-000000000000	fc33c0b5-d231-4862-8e97-4e80d6334867	{"action":"user_signedup","actor_id":"c7bcf0bc-f75f-4ec2-a27e-829b08795e76","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-02 03:50:43.670389+00	
00000000-0000-0000-0000-000000000000	c6b7dc14-7c9f-4c19-9c1a-e2ec67ef2930	{"action":"logout","actor_id":"c7bcf0bc-f75f-4ec2-a27e-829b08795e76","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-02 03:58:12.085138+00	
00000000-0000-0000-0000-000000000000	1a82bd6c-27a3-457c-a5d5-d29b83fd34aa	{"action":"login","actor_id":"c7bcf0bc-f75f-4ec2-a27e-829b08795e76","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-02 03:58:21.403065+00	
00000000-0000-0000-0000-000000000000	95f3cd87-1b34-4e62-a64a-faad2648f182	{"action":"token_refreshed","actor_id":"c7bcf0bc-f75f-4ec2-a27e-829b08795e76","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-02 06:10:17.44749+00	
00000000-0000-0000-0000-000000000000	bd8847b3-2c11-4c07-bd71-bcdf3f47de53	{"action":"token_revoked","actor_id":"c7bcf0bc-f75f-4ec2-a27e-829b08795e76","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-02 06:10:17.456974+00	
00000000-0000-0000-0000-000000000000	5c8f3637-e8df-4d0c-92c5-9dd48a55217e	{"action":"token_refreshed","actor_id":"c7bcf0bc-f75f-4ec2-a27e-829b08795e76","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-02 06:21:15.584045+00	
00000000-0000-0000-0000-000000000000	365dc897-f2ed-4b25-855d-05b1db32cca6	{"action":"token_refreshed","actor_id":"c7bcf0bc-f75f-4ec2-a27e-829b08795e76","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-02 17:11:47.954873+00	
00000000-0000-0000-0000-000000000000	0102e3bb-d20e-49df-9be6-1fbb5039b16e	{"action":"token_revoked","actor_id":"c7bcf0bc-f75f-4ec2-a27e-829b08795e76","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-02 17:11:47.97907+00	
00000000-0000-0000-0000-000000000000	6f48c6ca-4935-4ce1-862d-c630b4d8c460	{"action":"token_refreshed","actor_id":"c7bcf0bc-f75f-4ec2-a27e-829b08795e76","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-02 18:10:08.021185+00	
00000000-0000-0000-0000-000000000000	49b39da0-8854-4719-abc3-f16b0f4adfad	{"action":"token_revoked","actor_id":"c7bcf0bc-f75f-4ec2-a27e-829b08795e76","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-02 18:10:08.03853+00	
00000000-0000-0000-0000-000000000000	67ef2f7c-0a47-4787-9f6b-0944a96a4088	{"action":"token_refreshed","actor_id":"c7bcf0bc-f75f-4ec2-a27e-829b08795e76","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-02 19:20:30.44996+00	
00000000-0000-0000-0000-000000000000	3d4183fd-ccc0-4d41-b3b4-1af31e6cf3d1	{"action":"token_revoked","actor_id":"c7bcf0bc-f75f-4ec2-a27e-829b08795e76","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-02 19:20:30.468885+00	
00000000-0000-0000-0000-000000000000	a8525b39-3a2c-4f24-9dd0-7378b3f842e7	{"action":"token_refreshed","actor_id":"c7bcf0bc-f75f-4ec2-a27e-829b08795e76","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-02 20:26:49.298778+00	
00000000-0000-0000-0000-000000000000	89045a91-270d-4d70-ae76-a6b7c6c16c32	{"action":"token_revoked","actor_id":"c7bcf0bc-f75f-4ec2-a27e-829b08795e76","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-02 20:26:49.319608+00	
00000000-0000-0000-0000-000000000000	9bf73bd3-d913-4633-8d71-f57c04975202	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"c7bcf0bc-f75f-4ec2-a27e-829b08795e76","user_phone":""}}	2025-11-03 01:57:51.013725+00	
00000000-0000-0000-0000-000000000000	87ccbce9-a484-4898-a196-1333d34f4656	{"action":"user_signedup","actor_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-03 03:41:27.222638+00	
00000000-0000-0000-0000-000000000000	3cffbc10-27f9-4910-810c-4d1bf87b275a	{"action":"logout","actor_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-03 03:46:49.6587+00	
00000000-0000-0000-0000-000000000000	79283fc3-fc52-4e66-85b9-2c054ebf90bd	{"action":"login","actor_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-03 03:47:00.093762+00	
00000000-0000-0000-0000-000000000000	a6d22bd2-5a37-4f97-b9af-7c7904fe19fe	{"action":"logout","actor_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-03 03:50:52.162364+00	
00000000-0000-0000-0000-000000000000	3ed5b2f1-4bc2-434e-9028-01ea1cb59147	{"action":"login","actor_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-03 03:52:12.267963+00	
00000000-0000-0000-0000-000000000000	7cf262ec-d5e5-4124-9b7e-9b550a489c62	{"action":"logout","actor_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-03 03:58:40.930252+00	
00000000-0000-0000-0000-000000000000	ba891a83-4f47-4320-9209-94098d68a497	{"action":"user_signedup","actor_id":"4a17dd7d-aca7-4e77-ae92-4234e79a9615","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-03 04:00:02.397087+00	
00000000-0000-0000-0000-000000000000	e017c33d-0fcb-4c92-8f23-4b1e6e20069e	{"action":"logout","actor_id":"4a17dd7d-aca7-4e77-ae92-4234e79a9615","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-03 04:04:24.86406+00	
00000000-0000-0000-0000-000000000000	3eece126-1959-4814-8273-0b204dff508d	{"action":"login","actor_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-03 04:04:42.868748+00	
00000000-0000-0000-0000-000000000000	c4257a7c-b466-4f41-b9e5-5798123a7fd2	{"action":"logout","actor_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-03 04:05:24.863303+00	
00000000-0000-0000-0000-000000000000	2309a8a3-080d-48ca-8427-2652e7d02909	{"action":"login","actor_id":"4a17dd7d-aca7-4e77-ae92-4234e79a9615","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-03 04:05:32.891374+00	
00000000-0000-0000-0000-000000000000	c1a3cdfb-b81d-4c74-bcd2-43a5e858b84b	{"action":"logout","actor_id":"4a17dd7d-aca7-4e77-ae92-4234e79a9615","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-03 04:06:47.503061+00	
00000000-0000-0000-0000-000000000000	c3db79ba-5cb1-4b63-94ba-1dde7afb754c	{"action":"login","actor_id":"4a17dd7d-aca7-4e77-ae92-4234e79a9615","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-03 04:07:00.802491+00	
00000000-0000-0000-0000-000000000000	aa154c6a-cacb-4a87-8bd6-587e997cf5d3	{"action":"token_refreshed","actor_id":"4a17dd7d-aca7-4e77-ae92-4234e79a9615","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-03 06:18:02.304552+00	
00000000-0000-0000-0000-000000000000	95314b87-cccf-404f-ac3c-fcfca53ac677	{"action":"token_revoked","actor_id":"4a17dd7d-aca7-4e77-ae92-4234e79a9615","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-03 06:18:02.326998+00	
00000000-0000-0000-0000-000000000000	6741d521-4429-4fce-9083-fc6c0b9e78f8	{"action":"logout","actor_id":"4a17dd7d-aca7-4e77-ae92-4234e79a9615","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-03 06:20:13.108159+00	
00000000-0000-0000-0000-000000000000	85fb44b1-cf22-4586-a882-8594dc9ee040	{"action":"login","actor_id":"4a17dd7d-aca7-4e77-ae92-4234e79a9615","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-03 06:20:34.79613+00	
00000000-0000-0000-0000-000000000000	120c36e8-2c96-4f86-826d-76d8caeea272	{"action":"logout","actor_id":"4a17dd7d-aca7-4e77-ae92-4234e79a9615","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-03 06:21:22.77836+00	
00000000-0000-0000-0000-000000000000	abd49604-85f5-45ee-b2bd-0f3b423d6b02	{"action":"login","actor_id":"4a17dd7d-aca7-4e77-ae92-4234e79a9615","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-03 22:36:37.368587+00	
00000000-0000-0000-0000-000000000000	e8b9e2cc-0bd8-4324-96c9-5342181bcd08	{"action":"logout","actor_id":"4a17dd7d-aca7-4e77-ae92-4234e79a9615","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-03 22:44:19.890606+00	
00000000-0000-0000-0000-000000000000	0679047f-2143-4861-96ac-0a1077a7152b	{"action":"login","actor_id":"4a17dd7d-aca7-4e77-ae92-4234e79a9615","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-03 22:44:39.41956+00	
00000000-0000-0000-0000-000000000000	ec824e52-6c38-4d21-8a3c-98e56598041a	{"action":"logout","actor_id":"4a17dd7d-aca7-4e77-ae92-4234e79a9615","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-03 22:48:40.055797+00	
00000000-0000-0000-0000-000000000000	09fe1061-e869-42c8-85e2-64ed094f9381	{"action":"login","actor_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-03 22:48:51.389381+00	
00000000-0000-0000-0000-000000000000	349ddc01-207f-43dd-a5cb-801a1a10b8b9	{"action":"logout","actor_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-03 22:50:27.762189+00	
00000000-0000-0000-0000-000000000000	fdfff69b-1326-41a3-bc4e-6293a6e73c95	{"action":"login","actor_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-03 22:50:32.855472+00	
00000000-0000-0000-0000-000000000000	549ef280-02b1-4455-b22a-b89757c52e46	{"action":"token_refreshed","actor_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-04 00:29:52.328362+00	
00000000-0000-0000-0000-000000000000	cdf71120-c799-4ac9-b9c5-9f25840fefe0	{"action":"token_revoked","actor_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-04 00:29:52.342153+00	
00000000-0000-0000-0000-000000000000	ac212774-e43d-4507-821a-0a6d36349e58	{"action":"token_refreshed","actor_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-04 00:29:55.649169+00	
00000000-0000-0000-0000-000000000000	5e24af88-3ef7-48fa-9f6b-c750af76cbbc	{"action":"token_refreshed","actor_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-04 00:29:57.053391+00	
00000000-0000-0000-0000-000000000000	073aeddd-6d14-4105-8d21-8fd789895633	{"action":"token_refreshed","actor_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-04 02:08:06.19264+00	
00000000-0000-0000-0000-000000000000	7ee6884e-3341-4831-ab08-5208f0aecdf4	{"action":"token_revoked","actor_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-04 02:08:06.206524+00	
00000000-0000-0000-0000-000000000000	22e98398-857a-45bf-b71e-78edadd32993	{"action":"logout","actor_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-04 02:23:48.253068+00	
00000000-0000-0000-0000-000000000000	85de0ba9-16ff-4764-8521-2174b05037b8	{"action":"login","actor_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-04 02:23:55.042266+00	
00000000-0000-0000-0000-000000000000	8a506216-b792-48c6-8d27-cfbaf5a29ecb	{"action":"logout","actor_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-04 02:25:38.723568+00	
00000000-0000-0000-0000-000000000000	59b445aa-9553-44a1-90cb-20d6cf6316da	{"action":"login","actor_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-04 02:26:26.994679+00	
00000000-0000-0000-0000-000000000000	b5405691-678d-4f35-9c2d-dedeab476a52	{"action":"logout","actor_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-04 02:26:43.982795+00	
00000000-0000-0000-0000-000000000000	5aedbbb6-bdc6-4d98-9d1c-39ac6181019a	{"action":"user_signedup","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-04 02:28:45.952448+00	
00000000-0000-0000-0000-000000000000	b501de44-0761-49c5-a3d0-3485b51fe867	{"action":"logout","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-04 02:29:05.968848+00	
00000000-0000-0000-0000-000000000000	d053b0d5-0205-4e90-87ef-01a056bd5441	{"action":"login","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-04 02:58:13.188476+00	
00000000-0000-0000-0000-000000000000	ab84aa69-6106-45fd-b61a-e812fd383396	{"action":"logout","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-04 03:02:08.239364+00	
00000000-0000-0000-0000-000000000000	949e4dce-348c-4646-b4e0-bd2f77ce4d1e	{"action":"login","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-04 03:12:04.067933+00	
00000000-0000-0000-0000-000000000000	9ab48b36-3192-4b07-975b-220f6c3a292e	{"action":"token_refreshed","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-04 04:17:49.610381+00	
00000000-0000-0000-0000-000000000000	d46da8a7-f4a0-4db2-a24e-6fc2066a256c	{"action":"token_revoked","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-04 04:17:49.644166+00	
00000000-0000-0000-0000-000000000000	d9c5b443-bdca-47cc-a938-5b8f8a3383fe	{"action":"logout","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-04 04:26:00.133624+00	
00000000-0000-0000-0000-000000000000	a5b1dffd-7a7a-4432-aebc-94b03b9196e3	{"action":"login","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-04 05:59:51.497245+00	
00000000-0000-0000-0000-000000000000	273d631c-f569-4a23-a845-0d894b11523c	{"action":"logout","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-04 06:03:13.877216+00	
00000000-0000-0000-0000-000000000000	1a5a6e7f-6c56-440a-b4cd-36fd9b543ad5	{"action":"login","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-04 06:03:47.226265+00	
00000000-0000-0000-0000-000000000000	86874cb6-e07f-4718-b4bc-363a9b3caa3f	{"action":"token_refreshed","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-04 07:24:11.244035+00	
00000000-0000-0000-0000-000000000000	2c09d458-e66c-4561-a6d4-c776e5924f77	{"action":"token_revoked","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-04 07:24:11.274045+00	
00000000-0000-0000-0000-000000000000	e4c4bb33-e6fe-4388-aebb-0a3713970cba	{"action":"logout","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-04 07:24:29.874578+00	
00000000-0000-0000-0000-000000000000	74bed2ff-f5d3-4d78-9934-a9bdb9a0d522	{"action":"login","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-04 07:24:36.719065+00	
00000000-0000-0000-0000-000000000000	b7eff4d2-bd7b-422d-acf2-77b0865fb358	{"action":"logout","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-04 07:28:37.378906+00	
00000000-0000-0000-0000-000000000000	1af646c6-fae9-4f06-a549-240786300606	{"action":"login","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-04 07:28:46.680201+00	
00000000-0000-0000-0000-000000000000	c6a2d783-0cab-4078-beb7-f9e221ea2351	{"action":"logout","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-04 08:06:46.79758+00	
00000000-0000-0000-0000-000000000000	fc030c1a-bb9f-46b8-836b-771e977f87df	{"action":"login","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-04 21:46:56.782343+00	
00000000-0000-0000-0000-000000000000	7793834d-f63c-4e77-9e37-b3fe3716da25	{"action":"login","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-04 21:47:45.128174+00	
00000000-0000-0000-0000-000000000000	6035f152-53fb-4b70-8d08-a9616e1b3b85	{"action":"user_updated_password","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-04 21:47:45.581327+00	
00000000-0000-0000-0000-000000000000	a6cc7a5b-e7d6-4ac6-a824-0d83c86c2655	{"action":"user_modified","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-04 21:47:45.582824+00	
00000000-0000-0000-0000-000000000000	7ca3c11e-c663-4d10-bb6c-b3ac60bd27b5	{"action":"logout","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-04 21:50:05.510945+00	
00000000-0000-0000-0000-000000000000	a0022feb-0d69-45d3-99e8-04d3b39f088e	{"action":"login","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-04 21:50:11.954483+00	
00000000-0000-0000-0000-000000000000	49a9ad66-eeec-4e33-96ae-4acb500b7f14	{"action":"token_refreshed","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-04 23:09:51.307205+00	
00000000-0000-0000-0000-000000000000	d9b1ad2a-c7ce-4fce-87a5-8247efc2cb2a	{"action":"token_revoked","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-04 23:09:51.326372+00	
00000000-0000-0000-0000-000000000000	798792b9-cccc-4504-8719-ad16b2f213dd	{"action":"logout","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-04 23:10:16.463572+00	
00000000-0000-0000-0000-000000000000	eb4c0ef2-0045-42d3-83de-44b55c3f76e6	{"action":"login","actor_id":"e8756436-339f-461e-88fc-b830cfa19ea9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-04 23:10:25.566637+00	
00000000-0000-0000-0000-000000000000	1aa6dc2c-7a85-41d4-942c-4ee807169d0c	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"e8756436-339f-461e-88fc-b830cfa19ea9","user_phone":""}}	2025-11-04 23:10:54.437305+00	
00000000-0000-0000-0000-000000000000	9d7d1c6f-4977-458d-8847-97939f762e8a	{"action":"login","actor_id":"4a17dd7d-aca7-4e77-ae92-4234e79a9615","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-04 23:11:23.60198+00	
00000000-0000-0000-0000-000000000000	c357895e-f9f5-4bda-93e1-1f14d2ab6db5	{"action":"logout","actor_id":"4a17dd7d-aca7-4e77-ae92-4234e79a9615","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-04 23:19:49.522621+00	
00000000-0000-0000-0000-000000000000	611c2d63-4cac-4a87-861d-e4b429fec5f2	{"action":"login","actor_id":"4a17dd7d-aca7-4e77-ae92-4234e79a9615","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-05 00:46:13.593981+00	
00000000-0000-0000-0000-000000000000	17888602-600d-4f8d-9d6b-86a097d03818	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"4a17dd7d-aca7-4e77-ae92-4234e79a9615","user_phone":""}}	2025-11-05 00:47:40.889391+00	
00000000-0000-0000-0000-000000000000	8e31a847-acac-4dfd-9c9b-b531c504735f	{"action":"login","actor_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-05 00:50:12.054549+00	
00000000-0000-0000-0000-000000000000	004ba9ff-8387-4029-aa14-6577d216e23a	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"2de8c340-e0d9-46c7-95a9-16860cfee66a","user_phone":""}}	2025-11-05 00:51:46.798353+00	
00000000-0000-0000-0000-000000000000	8b2672df-8873-4329-940a-9203a692de0e	{"action":"user_signedup","actor_id":"d83f701d-2a18-4f03-a92c-75652c0ebf18","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-05 02:15:46.054353+00	
00000000-0000-0000-0000-000000000000	691f051a-fb87-4079-8556-b1274ac976c6	{"action":"logout","actor_id":"d83f701d-2a18-4f03-a92c-75652c0ebf18","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-05 02:19:04.668436+00	
00000000-0000-0000-0000-000000000000	25643cb7-456a-4bcb-a0e5-c6c1cba3695b	{"action":"login","actor_id":"d83f701d-2a18-4f03-a92c-75652c0ebf18","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-05 02:19:10.581798+00	
00000000-0000-0000-0000-000000000000	04285c9d-df80-43d2-8bed-255918d5328f	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"d83f701d-2a18-4f03-a92c-75652c0ebf18","user_phone":""}}	2025-11-05 02:19:42.675091+00	
00000000-0000-0000-0000-000000000000	018906f9-dcbb-441a-9f62-030a51d45bb4	{"action":"user_signedup","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-05 02:20:40.01846+00	
00000000-0000-0000-0000-000000000000	4084bc80-d627-428f-9763-f7dbc04adfc1	{"action":"logout","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-05 02:21:45.097696+00	
00000000-0000-0000-0000-000000000000	93fb4c8b-8727-4200-9a61-eb44776bf4c0	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-05 02:21:49.865982+00	
00000000-0000-0000-0000-000000000000	8da981f0-e9fb-46a5-824d-b30da8c2cf4c	{"action":"logout","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-05 02:39:46.794489+00	
00000000-0000-0000-0000-000000000000	81e4bf7e-2eff-4e86-b9af-80a56f1e151c	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-05 09:35:03.826264+00	
00000000-0000-0000-0000-000000000000	0adb91b4-5122-4177-8a44-6b386b7e5b40	{"action":"logout","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-05 09:47:12.329709+00	
00000000-0000-0000-0000-000000000000	209a4efa-2874-4cde-9d0a-86ef8abd8a22	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-05 09:47:23.326204+00	
00000000-0000-0000-0000-000000000000	12bf1bcd-f568-4bbc-b6e3-a080f07677ac	{"action":"logout","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-05 09:47:29.84886+00	
00000000-0000-0000-0000-000000000000	bc14bf19-6cb8-48e3-95e3-92fb317fbcca	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-05 09:48:14.298208+00	
00000000-0000-0000-0000-000000000000	af50a9d7-ef10-4868-9553-e491d190a78f	{"action":"logout","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-05 09:48:30.962352+00	
00000000-0000-0000-0000-000000000000	12f8205c-fc9b-4849-a622-0422c1f8be62	{"action":"user_recovery_requested","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-05 09:51:08.091056+00	
00000000-0000-0000-0000-000000000000	2def2d6a-f609-4bac-8ba6-f9eb7a09249d	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-05 09:52:16.861646+00	
00000000-0000-0000-0000-000000000000	90e6a5aa-693d-4be7-a46e-18219b7e0527	{"action":"user_updated_password","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-05 09:52:41.598868+00	
00000000-0000-0000-0000-000000000000	51a8f28a-6dbb-40d6-bf34-2418c071465b	{"action":"user_modified","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-05 09:52:41.608305+00	
00000000-0000-0000-0000-000000000000	e3f76c2f-3858-404f-8b36-2e7517a48981	{"action":"logout","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-05 09:52:42.779214+00	
00000000-0000-0000-0000-000000000000	e05fd5ae-d0e1-4e60-a5fb-ac11840fcb70	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-05 09:52:54.107203+00	
00000000-0000-0000-0000-000000000000	b69d4140-c0fb-4602-9897-7140aabc6b53	{"action":"logout","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-05 09:59:21.493483+00	
00000000-0000-0000-0000-000000000000	3537e0b4-9586-46fa-b470-cfd1f538de83	{"action":"user_recovery_requested","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-05 21:09:21.260392+00	
00000000-0000-0000-0000-000000000000	e75ff00e-5cb3-441c-ab56-98fe4912dd0c	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-05 21:10:54.984513+00	
00000000-0000-0000-0000-000000000000	50eb0ed8-982b-4099-807a-274fb30272a6	{"action":"user_updated_password","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-05 21:11:09.329365+00	
00000000-0000-0000-0000-000000000000	79b16d39-7131-4d77-bff3-13b57beac944	{"action":"user_modified","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-05 21:11:09.331242+00	
00000000-0000-0000-0000-000000000000	6504cb61-e545-4350-863a-922e61b8ecf1	{"action":"logout","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-05 21:11:15.714078+00	
00000000-0000-0000-0000-000000000000	95e6883d-d80b-4010-9f39-67c7d9424955	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-05 21:13:18.550361+00	
00000000-0000-0000-0000-000000000000	3bd8827e-6a2b-4a67-9c5a-407ddf68b181	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-05 21:33:27.476459+00	
00000000-0000-0000-0000-000000000000	bcf721ff-62e5-49d9-9d39-f6a31d398290	{"action":"logout","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-05 22:27:16.477686+00	
00000000-0000-0000-0000-000000000000	babb5df0-bc1b-4053-8312-40f7443cbf06	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-05 22:28:09.358916+00	
00000000-0000-0000-0000-000000000000	efa6552e-1a27-4f67-beb3-94143b06683c	{"action":"logout","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-05 22:46:45.361382+00	
00000000-0000-0000-0000-000000000000	3c80c033-8672-4a47-a3b4-eed47b82e614	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-05 23:02:58.433833+00	
00000000-0000-0000-0000-000000000000	fd1988bd-ffb6-486b-8d47-77480786d86b	{"action":"user_recovery_requested","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-06 02:23:38.01637+00	
00000000-0000-0000-0000-000000000000	186dc4e9-e413-418a-86d7-579837c2e17a	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-06 02:25:25.878684+00	
00000000-0000-0000-0000-000000000000	f5fe04ab-35fe-4051-a6f9-3197309848bb	{"action":"user_updated_password","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-06 02:26:08.778804+00	
00000000-0000-0000-0000-000000000000	9987777a-840b-4a30-b9c4-f16e90d2a535	{"action":"user_modified","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-06 02:26:08.782001+00	
00000000-0000-0000-0000-000000000000	fdbeaca9-e891-445f-bf74-d33a0aa2bfb8	{"action":"logout","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-06 02:26:09.941126+00	
00000000-0000-0000-0000-000000000000	e3c51173-b893-4497-a8d2-8e9b5b687c0e	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-06 02:26:19.335033+00	
00000000-0000-0000-0000-000000000000	3f9fd6e8-9378-40fd-827d-a99bc355e9ad	{"action":"user_recovery_requested","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-06 03:52:47.034887+00	
00000000-0000-0000-0000-000000000000	948997e6-0419-4053-8efd-0bf00edf6845	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-06 03:55:18.445409+00	
00000000-0000-0000-0000-000000000000	8c3a07d6-8061-49ce-b171-c20c2d18425a	{"action":"user_updated_password","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-06 03:55:35.455057+00	
00000000-0000-0000-0000-000000000000	9813c15c-9469-468c-9533-a498234c6e2d	{"action":"user_modified","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-06 03:55:35.462952+00	
00000000-0000-0000-0000-000000000000	6b9b0075-fb0b-4760-93a9-05b128a2334c	{"action":"logout","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-06 03:55:36.668941+00	
00000000-0000-0000-0000-000000000000	7c883cba-8843-49cc-8689-52264dc2720d	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-06 03:55:48.151181+00	
00000000-0000-0000-0000-000000000000	c8c56f09-dad5-431b-98a7-1337cda806e5	{"action":"token_refreshed","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-06 13:09:46.579939+00	
00000000-0000-0000-0000-000000000000	92a6df25-4ed5-470b-a303-77464dfcbe16	{"action":"token_revoked","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-06 13:09:46.606144+00	
00000000-0000-0000-0000-000000000000	417fca2b-d2ea-46c0-9b1d-b2649c133654	{"action":"token_refreshed","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-06 13:09:49.480939+00	
00000000-0000-0000-0000-000000000000	dab31270-0f72-43fb-9264-9236cb75a8c2	{"action":"token_refreshed","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-06 13:12:30.654049+00	
00000000-0000-0000-0000-000000000000	57484f88-eae7-4c94-9e37-7c0a2f9063c5	{"action":"token_refreshed","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-06 13:12:32.175088+00	
00000000-0000-0000-0000-000000000000	51b3a5ea-5111-4c03-82ea-a2ce44adc1af	{"action":"token_refreshed","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-06 13:18:19.796256+00	
00000000-0000-0000-0000-000000000000	d64d5717-a1bd-4b87-942f-abaa8d762f08	{"action":"token_refreshed","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-06 14:35:05.317113+00	
00000000-0000-0000-0000-000000000000	b27a2bc0-e3a8-427c-9bdd-1381fcefa755	{"action":"token_revoked","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-06 14:35:05.337414+00	
00000000-0000-0000-0000-000000000000	df83b87b-6d5c-4407-a8eb-c4e709c5fdee	{"action":"token_refreshed","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-06 14:35:23.161735+00	
00000000-0000-0000-0000-000000000000	792d52f6-7c27-4f1c-8004-47071e8496dc	{"action":"token_refreshed","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-06 14:38:38.066013+00	
00000000-0000-0000-0000-000000000000	cb48ca96-df0d-44b2-a3d2-c5e55e4d0a78	{"action":"token_refreshed","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-06 14:38:44.071051+00	
00000000-0000-0000-0000-000000000000	85d5a0f1-f6e2-4c7c-839a-2c1200e2f4c9	{"action":"token_refreshed","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-06 19:43:06.087631+00	
00000000-0000-0000-0000-000000000000	4859d724-86e1-4179-aa23-6cfc1f5c15e5	{"action":"token_refreshed","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-06 19:43:24.486698+00	
00000000-0000-0000-0000-000000000000	b18dcb1d-7932-46c3-a3bf-8328752450df	{"action":"token_refreshed","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-06 22:02:27.24726+00	
00000000-0000-0000-0000-000000000000	719f22f6-19e2-46a1-9c05-27444acbbac2	{"action":"logout","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-06 22:05:21.002863+00	
00000000-0000-0000-0000-000000000000	d1572ee5-32ae-4220-bc69-2e60ece0484f	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-06 22:10:57.881176+00	
00000000-0000-0000-0000-000000000000	9cec2950-ea15-44cb-8c5f-627c8151479c	{"action":"logout","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-06 22:12:09.75601+00	
00000000-0000-0000-0000-000000000000	ede9ebc7-3b3b-4fbf-aba9-91f5efb1841f	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-06 22:12:33.228218+00	
00000000-0000-0000-0000-000000000000	63638d3d-d04b-4d2b-b381-0931716afdb9	{"action":"logout","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-06 22:13:50.718605+00	
00000000-0000-0000-0000-000000000000	07e565b7-a7ec-4a69-886e-cc6a0c6867f4	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-06 22:13:57.340434+00	
00000000-0000-0000-0000-000000000000	69f1b05f-20d1-4b19-b2fd-ccab875f4dd3	{"action":"logout","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-06 22:14:11.115825+00	
00000000-0000-0000-0000-000000000000	d0ce22af-c5b2-41b1-a775-226f78e0f0aa	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-06 22:16:03.459547+00	
00000000-0000-0000-0000-000000000000	a780ebee-8bf2-487e-902c-219d4672c21e	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-07 02:14:23.400647+00	
00000000-0000-0000-0000-000000000000	1bed18dc-b696-4a2b-937f-62e6df501d89	{"action":"token_refreshed","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-07 02:20:41.042955+00	
00000000-0000-0000-0000-000000000000	f6b14d42-155f-4162-a940-87717edf02fe	{"action":"token_revoked","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-07 02:20:41.047871+00	
00000000-0000-0000-0000-000000000000	086ce70e-9562-4c09-9995-1d230f5ba05e	{"action":"logout","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-07 02:24:19.515846+00	
00000000-0000-0000-0000-000000000000	1efe3ea4-5dc1-4dc6-917d-c3c534743044	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-07 02:24:34.579963+00	
00000000-0000-0000-0000-000000000000	6bd475ed-c8ed-4d26-ab97-c59277a54a7f	{"action":"logout","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-07 02:25:00.964277+00	
00000000-0000-0000-0000-000000000000	78fdae06-e29e-4a3d-bc8f-8d60bc84fb2f	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-07 02:26:30.331002+00	
00000000-0000-0000-0000-000000000000	87d1f385-31f0-432f-85d6-6e884d9671c5	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-07 02:44:18.973918+00	
00000000-0000-0000-0000-000000000000	8542bbc6-573b-43b3-ab3f-e99dc3e7e9b6	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 03:09:05.552677+00	
00000000-0000-0000-0000-000000000000	05716c22-5cd9-4eb0-a163-60fb85fff4a4	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 03:28:12.833623+00	
00000000-0000-0000-0000-000000000000	7e79a13d-1bd3-40ac-9f32-bca34c6291bc	{"action":"logout","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 03:30:02.110388+00	
00000000-0000-0000-0000-000000000000	4ce51bd4-ae31-4b38-8f4f-9a7c1ba07f6d	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 06:04:28.24698+00	
00000000-0000-0000-0000-000000000000	f09a8774-2b3c-480d-ae4a-1c06f4d52c2d	{"action":"logout","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 06:16:24.064022+00	
00000000-0000-0000-0000-000000000000	60e32eaa-a858-4029-982f-9b3cd4b21c90	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 06:16:33.09265+00	
00000000-0000-0000-0000-000000000000	81ae06aa-d177-4537-97b7-46c1235fe327	{"action":"logout","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 06:16:49.785997+00	
00000000-0000-0000-0000-000000000000	4360e403-7f25-42a5-a80e-204569cee4d9	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 06:16:54.99005+00	
00000000-0000-0000-0000-000000000000	02c69798-8c52-439d-a763-820c54a6c9b7	{"action":"logout","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 06:17:02.279079+00	
00000000-0000-0000-0000-000000000000	ee44d115-620f-463f-8875-eee57f5f29b7	{"action":"login","actor_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 06:17:13.517966+00	
00000000-0000-0000-0000-000000000000	5ebbdf7f-4991-4f97-9a4f-3307dca7038d	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"498a0b09-295a-41b0-b852-b4f00f49e5bf","user_phone":""}}	2025-11-08 06:20:45.10718+00	
00000000-0000-0000-0000-000000000000	83e5a1e4-7f1d-452c-97df-206362d5e438	{"action":"user_signedup","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-08 06:22:21.81313+00	
00000000-0000-0000-0000-000000000000	bc00d108-1b97-4282-b529-0a514807a5c2	{"action":"logout","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 06:29:20.806665+00	
00000000-0000-0000-0000-000000000000	ed5f422c-a92d-4517-ba0f-74d99271c39c	{"action":"login","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 06:29:27.846824+00	
00000000-0000-0000-0000-000000000000	aad17784-a753-49da-bf35-bc60dbd5030c	{"action":"logout","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 06:30:04.256807+00	
00000000-0000-0000-0000-000000000000	84cba4eb-f78e-4865-858e-73b78e5609bc	{"action":"login","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 06:36:36.738012+00	
00000000-0000-0000-0000-000000000000	0f4caf5c-3507-4c5b-8fba-82db99ebffc0	{"action":"logout","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 06:36:53.202772+00	
00000000-0000-0000-0000-000000000000	fe32b2ec-daf0-405a-8f54-b6a6b77da39d	{"action":"login","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 06:36:58.014982+00	
00000000-0000-0000-0000-000000000000	2c71f416-3662-4cc6-936a-2a26499eab44	{"action":"logout","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 06:39:40.505137+00	
00000000-0000-0000-0000-000000000000	dbc6671e-3356-4e60-9130-81c43023a40a	{"action":"login","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 06:39:46.842506+00	
00000000-0000-0000-0000-000000000000	256c2c5e-7ed3-47f0-a08e-aad3af255735	{"action":"logout","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 07:08:45.936897+00	
00000000-0000-0000-0000-000000000000	7483f447-5aa7-41a5-b473-c27ef0aa2666	{"action":"login","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 08:59:37.530004+00	
00000000-0000-0000-0000-000000000000	09e7ec82-0ee3-4ee8-aa5e-73687b715ecb	{"action":"logout","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 09:00:03.037986+00	
00000000-0000-0000-0000-000000000000	87ff44ad-8090-4553-9589-1de4af5c2dfa	{"action":"login","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 09:00:07.727597+00	
00000000-0000-0000-0000-000000000000	19d3941e-3674-45be-892e-c2a22c0d1241	{"action":"logout","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 09:03:24.100691+00	
00000000-0000-0000-0000-000000000000	537710e0-f21b-469f-9557-ac4d4671fd67	{"action":"login","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 09:03:54.583176+00	
00000000-0000-0000-0000-000000000000	8b36a534-4c2d-4dc1-9a1b-5ed6ccf31394	{"action":"logout","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 09:04:08.482208+00	
00000000-0000-0000-0000-000000000000	e34e5045-20a7-4e48-8e89-479ae22d5ff6	{"action":"login","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 09:04:12.995092+00	
00000000-0000-0000-0000-000000000000	4f47fe33-c8c9-4683-b751-2ece508c27cc	{"action":"logout","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 09:05:08.978901+00	
00000000-0000-0000-0000-000000000000	f37fdc28-1f0b-40f4-84b4-4a6bbdcfca27	{"action":"login","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 09:05:14.375116+00	
00000000-0000-0000-0000-000000000000	6492b06c-af82-49b1-9482-4d0cb6399c00	{"action":"logout","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 09:06:41.281498+00	
00000000-0000-0000-0000-000000000000	fcbe093e-21b4-4ad2-8a97-3a29b45984af	{"action":"login","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 09:06:58.370993+00	
00000000-0000-0000-0000-000000000000	74674970-b61a-4d20-9b39-45203135c2aa	{"action":"logout","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 09:07:48.374451+00	
00000000-0000-0000-0000-000000000000	d142408a-3d05-4efb-9b5d-86b8f3409df4	{"action":"user_signedup","actor_id":"164c6c82-69d5-413c-a536-ae799d3bcb33","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-08 09:09:47.610696+00	
00000000-0000-0000-0000-000000000000	1e9f09ed-305a-4264-90f9-819d02b2b509	{"action":"user_recovery_requested","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-08 13:42:20.345733+00	
00000000-0000-0000-0000-000000000000	b67c72dd-7f2a-48ef-bdd4-c1657439d6e6	{"action":"login","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 13:43:11.124051+00	
00000000-0000-0000-0000-000000000000	6a4dcc65-d04c-49d3-bb2c-d8cee92af860	{"action":"user_updated_password","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-08 13:43:34.852867+00	
00000000-0000-0000-0000-000000000000	41a0ffdd-3ac7-4c99-8406-5613c9934146	{"action":"user_modified","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-08 13:43:34.854111+00	
00000000-0000-0000-0000-000000000000	b25fd2a7-6ebd-4071-9cc3-b08ce7d55626	{"action":"logout","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 13:43:36.511605+00	
00000000-0000-0000-0000-000000000000	32862111-ad00-4803-a757-205025652b02	{"action":"login","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 13:43:50.595198+00	
00000000-0000-0000-0000-000000000000	49c9ec0b-f568-4ec8-87f3-f2da8bee4383	{"action":"token_refreshed","actor_id":"164c6c82-69d5-413c-a536-ae799d3bcb33","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-08 14:25:50.877544+00	
00000000-0000-0000-0000-000000000000	9acbe5db-d796-4484-901b-bb2a04b1d83f	{"action":"token_revoked","actor_id":"164c6c82-69d5-413c-a536-ae799d3bcb33","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-08 14:25:50.901702+00	
00000000-0000-0000-0000-000000000000	90bca9a3-077b-43ff-aeb2-2202d4320fcc	{"action":"token_refreshed","actor_id":"164c6c82-69d5-413c-a536-ae799d3bcb33","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-08 14:25:58.347772+00	
00000000-0000-0000-0000-000000000000	4bfd9e17-c5e5-4103-9ac3-95026a40632c	{"action":"token_refreshed","actor_id":"164c6c82-69d5-413c-a536-ae799d3bcb33","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-08 14:26:02.281362+00	
00000000-0000-0000-0000-000000000000	3cd01599-b388-4954-8d48-d6832c48b1fe	{"action":"logout","actor_id":"164c6c82-69d5-413c-a536-ae799d3bcb33","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 14:27:21.861302+00	
00000000-0000-0000-0000-000000000000	934d1001-ffd3-467b-9e5d-f7f90579e553	{"action":"login","actor_id":"164c6c82-69d5-413c-a536-ae799d3bcb33","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 14:27:33.120289+00	
00000000-0000-0000-0000-000000000000	241cb180-0082-45c1-8d64-d9b99e314ca9	{"action":"logout","actor_id":"164c6c82-69d5-413c-a536-ae799d3bcb33","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 14:30:51.554884+00	
00000000-0000-0000-0000-000000000000	8d98c74a-5888-4352-b371-abe304ea09c4	{"action":"login","actor_id":"164c6c82-69d5-413c-a536-ae799d3bcb33","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 14:30:57.458141+00	
00000000-0000-0000-0000-000000000000	23cd596b-b8d0-41b6-a8ec-7953f3ebcf9d	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"164c6c82-69d5-413c-a536-ae799d3bcb33","user_phone":""}}	2025-11-08 14:34:21.442749+00	
00000000-0000-0000-0000-000000000000	93d75f70-8e30-41c3-9204-2c5687c4314c	{"action":"user_recovery_requested","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-08 14:37:18.26115+00	
00000000-0000-0000-0000-000000000000	fb7251a5-0fc3-45bc-85d5-f847ad254170	{"action":"login","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 14:38:03.918872+00	
00000000-0000-0000-0000-000000000000	de6c1b37-9f4c-4c86-866f-ba23b73ca5b7	{"action":"user_updated_password","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-08 14:38:21.522201+00	
00000000-0000-0000-0000-000000000000	d3b397dc-8b88-4561-bb28-7f8a110e02c0	{"action":"user_modified","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-08 14:38:21.523029+00	
00000000-0000-0000-0000-000000000000	eaeb4956-ffa3-4b93-b4b5-73a9f942da3f	{"action":"logout","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 14:38:22.769069+00	
00000000-0000-0000-0000-000000000000	4dab3515-cddb-4840-8151-01b4baa7f7ef	{"action":"login","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 14:38:33.364258+00	
00000000-0000-0000-0000-000000000000	ef7c8862-b144-41a7-a468-346519f8fa2e	{"action":"logout","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 14:39:26.474979+00	
00000000-0000-0000-0000-000000000000	99b2c8b1-0518-4b51-a5dd-9a475e0e559b	{"action":"login","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 14:39:31.596612+00	
00000000-0000-0000-0000-000000000000	abe4ffd3-d274-4f7e-81af-5f1f6fcfac96	{"action":"logout","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 14:40:10.075078+00	
00000000-0000-0000-0000-000000000000	02de5d4b-84a5-4710-9ae1-2adfad02633f	{"action":"login","actor_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 14:40:15.880781+00	
00000000-0000-0000-0000-000000000000	8e66c3c3-32b4-4ccf-adea-1aa045ee4bf5	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"bad8d8bd-a7ab-4566-aab9-34bb5080eb60","user_phone":""}}	2025-11-08 14:41:25.042754+00	
00000000-0000-0000-0000-000000000000	8e768b0f-b95d-43b7-bb49-5a802ac9b122	{"action":"user_signedup","actor_id":"7fdc5536-211c-4d4c-8091-9c4932c16c36","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-08 14:43:04.464255+00	
00000000-0000-0000-0000-000000000000	17ae7f2e-6e93-4bb1-8bff-66bb3e09a4b6	{"action":"logout","actor_id":"7fdc5536-211c-4d4c-8091-9c4932c16c36","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 14:44:19.198164+00	
00000000-0000-0000-0000-000000000000	0878b52b-e046-4727-b797-4a60bf136cda	{"action":"login","actor_id":"7fdc5536-211c-4d4c-8091-9c4932c16c36","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 14:44:33.885014+00	
00000000-0000-0000-0000-000000000000	c3495c93-af1f-41ee-bd14-a14cb3535e98	{"action":"logout","actor_id":"7fdc5536-211c-4d4c-8091-9c4932c16c36","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 14:46:18.918162+00	
00000000-0000-0000-0000-000000000000	cab1c0b6-91d9-49ba-b518-fbee1d065a26	{"action":"login","actor_id":"7fdc5536-211c-4d4c-8091-9c4932c16c36","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 14:46:24.523496+00	
00000000-0000-0000-0000-000000000000	6e844cc3-cef7-404a-8a71-5a834457f356	{"action":"logout","actor_id":"7fdc5536-211c-4d4c-8091-9c4932c16c36","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 14:47:32.7752+00	
00000000-0000-0000-0000-000000000000	40767cf7-c66f-45eb-81de-8557d5ca9e86	{"action":"login","actor_id":"7fdc5536-211c-4d4c-8091-9c4932c16c36","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 14:47:46.427758+00	
00000000-0000-0000-0000-000000000000	b6fd9ade-f98d-490a-ba84-ea6844d737a9	{"action":"logout","actor_id":"7fdc5536-211c-4d4c-8091-9c4932c16c36","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-08 14:48:17.553084+00	
00000000-0000-0000-0000-000000000000	7a6f6a8a-ae48-4032-857c-d148f6d1b4ab	{"action":"login","actor_id":"7fdc5536-211c-4d4c-8091-9c4932c16c36","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 14:48:47.283716+00	
00000000-0000-0000-0000-000000000000	9565aa1c-c873-4aac-accc-eaa59422bd96	{"action":"login","actor_id":"7fdc5536-211c-4d4c-8091-9c4932c16c36","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-08 14:56:04.390885+00	
00000000-0000-0000-0000-000000000000	925c5e25-fbba-470a-8cdb-49ef2982fefd	{"action":"token_refreshed","actor_id":"7fdc5536-211c-4d4c-8091-9c4932c16c36","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-09 09:19:33.018969+00	
00000000-0000-0000-0000-000000000000	aee2b463-34e7-4447-8291-8dc3ea9517da	{"action":"token_revoked","actor_id":"7fdc5536-211c-4d4c-8091-9c4932c16c36","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-09 09:19:33.045354+00	
00000000-0000-0000-0000-000000000000	d2df3561-7f3c-438f-aa3d-2770996804ef	{"action":"logout","actor_id":"7fdc5536-211c-4d4c-8091-9c4932c16c36","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-09 09:20:25.26393+00	
00000000-0000-0000-0000-000000000000	dd881d7c-df55-4f1b-a060-0680aeeae3d8	{"action":"login","actor_id":"7fdc5536-211c-4d4c-8091-9c4932c16c36","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-09 09:20:34.118691+00	
00000000-0000-0000-0000-000000000000	5d031895-a414-435b-8b2e-7d5917fadc44	{"action":"logout","actor_id":"7fdc5536-211c-4d4c-8091-9c4932c16c36","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-09 09:21:33.381487+00	
00000000-0000-0000-0000-000000000000	f72e249f-a8e4-4cfd-b1d0-47cca68924c0	{"action":"login","actor_id":"7fdc5536-211c-4d4c-8091-9c4932c16c36","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-09 09:22:01.445796+00	
00000000-0000-0000-0000-000000000000	31c7d2fe-9b73-49d4-94b2-8d7955900769	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"7fdc5536-211c-4d4c-8091-9c4932c16c36","user_phone":""}}	2025-11-09 09:23:18.734814+00	
00000000-0000-0000-0000-000000000000	efa54c65-1128-4185-b49a-fc7efebc2432	{"action":"user_signedup","actor_id":"4e49f491-5892-4ad4-8468-ef211f3963af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-09 09:41:49.716279+00	
00000000-0000-0000-0000-000000000000	4f03c3e7-e035-4d72-8333-069d2575ecaf	{"action":"logout","actor_id":"4e49f491-5892-4ad4-8468-ef211f3963af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-09 09:47:54.405734+00	
00000000-0000-0000-0000-000000000000	b59ac20f-f47d-4261-82c3-b9d84590e6f0	{"action":"login","actor_id":"4e49f491-5892-4ad4-8468-ef211f3963af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-09 09:48:03.694383+00	
00000000-0000-0000-0000-000000000000	92264357-aff4-4c4b-809c-69bbf0fc4f8f	{"action":"logout","actor_id":"4e49f491-5892-4ad4-8468-ef211f3963af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-09 09:49:35.316058+00	
00000000-0000-0000-0000-000000000000	4cd553ae-9530-4746-8acb-51527d5a6fb7	{"action":"login","actor_id":"4e49f491-5892-4ad4-8468-ef211f3963af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-09 09:49:55.234569+00	
00000000-0000-0000-0000-000000000000	290f5793-55c3-4712-a093-8d66f097b0b1	{"action":"logout","actor_id":"4e49f491-5892-4ad4-8468-ef211f3963af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-09 09:50:53.693212+00	
00000000-0000-0000-0000-000000000000	f42fe791-01a1-47d0-8d22-b60f1fb1106d	{"action":"user_recovery_requested","actor_id":"4e49f491-5892-4ad4-8468-ef211f3963af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-09 20:16:09.194454+00	
00000000-0000-0000-0000-000000000000	9ddd6712-faf3-4538-aec9-f2f26064d312	{"action":"login","actor_id":"4e49f491-5892-4ad4-8468-ef211f3963af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-09 20:17:19.547619+00	
00000000-0000-0000-0000-000000000000	1ec1de89-2162-4ba4-b1bc-7926c0b8330e	{"action":"user_updated_password","actor_id":"4e49f491-5892-4ad4-8468-ef211f3963af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-09 20:17:30.600024+00	
00000000-0000-0000-0000-000000000000	c533122f-d305-4011-9922-397190acf152	{"action":"user_modified","actor_id":"4e49f491-5892-4ad4-8468-ef211f3963af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-09 20:17:30.602286+00	
00000000-0000-0000-0000-000000000000	dcd349d0-4e4c-4dc7-800f-37b7eff6f15f	{"action":"logout","actor_id":"4e49f491-5892-4ad4-8468-ef211f3963af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-09 20:17:31.706792+00	
00000000-0000-0000-0000-000000000000	3c12a153-3cf8-4ce6-a28a-20edf69e74e5	{"action":"login","actor_id":"4e49f491-5892-4ad4-8468-ef211f3963af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-09 20:17:43.136505+00	
00000000-0000-0000-0000-000000000000	95a64901-aeea-40ce-9f9d-8bba8c7e76c0	{"action":"logout","actor_id":"4e49f491-5892-4ad4-8468-ef211f3963af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-09 20:20:55.780181+00	
00000000-0000-0000-0000-000000000000	c5ec4d08-e59f-4c46-b063-6658222d02d6	{"action":"user_recovery_requested","actor_id":"4e49f491-5892-4ad4-8468-ef211f3963af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-12 00:00:49.072736+00	
00000000-0000-0000-0000-000000000000	c6d4f5d9-564e-4135-8ac7-02ab0a299272	{"action":"login","actor_id":"4e49f491-5892-4ad4-8468-ef211f3963af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-12 00:01:09.626187+00	
00000000-0000-0000-0000-000000000000	38ab6228-3f68-44f0-a66d-cdb16e97f0cd	{"action":"user_updated_password","actor_id":"4e49f491-5892-4ad4-8468-ef211f3963af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-12 00:01:42.584073+00	
00000000-0000-0000-0000-000000000000	6732a858-6c4a-45e4-a562-34d0af82604b	{"action":"user_modified","actor_id":"4e49f491-5892-4ad4-8468-ef211f3963af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-12 00:01:42.585222+00	
00000000-0000-0000-0000-000000000000	319beb23-5aba-4c58-97b6-2bdc60035608	{"action":"logout","actor_id":"4e49f491-5892-4ad4-8468-ef211f3963af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-12 00:01:43.708393+00	
00000000-0000-0000-0000-000000000000	0e603357-0025-469a-abe7-01a5986d48bb	{"action":"login","actor_id":"4e49f491-5892-4ad4-8468-ef211f3963af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-12 00:01:51.527258+00	
00000000-0000-0000-0000-000000000000	ccd6259f-c609-4137-86fe-03b27c6f446c	{"action":"logout","actor_id":"4e49f491-5892-4ad4-8468-ef211f3963af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-12 00:04:59.883066+00	
00000000-0000-0000-0000-000000000000	be1d747b-fff7-4697-898f-9aa2853d190e	{"action":"user_signedup","actor_id":"9684c367-70ce-466f-92fc-e4a01a6640a9","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-12 00:07:02.650509+00	
00000000-0000-0000-0000-000000000000	42f090c6-8aab-46b1-9ec3-44aceba8dbda	{"action":"logout","actor_id":"9684c367-70ce-466f-92fc-e4a01a6640a9","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-12 00:16:44.162791+00	
00000000-0000-0000-0000-000000000000	bbe6de8e-d36e-494e-bb01-abcde45565d4	{"action":"login","actor_id":"9684c367-70ce-466f-92fc-e4a01a6640a9","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-12 05:03:47.43479+00	
00000000-0000-0000-0000-000000000000	775aa290-12d3-4a12-b02a-43799b90c3bb	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"9684c367-70ce-466f-92fc-e4a01a6640a9","user_phone":""}}	2025-11-12 05:06:35.895245+00	
00000000-0000-0000-0000-000000000000	bb6d8fd2-1210-422f-9487-47afd14e2246	{"action":"login","actor_id":"4e49f491-5892-4ad4-8468-ef211f3963af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-12 05:06:51.213912+00	
00000000-0000-0000-0000-000000000000	3123a73d-9425-4585-858f-e4dbad7de80b	{"action":"logout","actor_id":"4e49f491-5892-4ad4-8468-ef211f3963af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-12 05:10:00.842674+00	
00000000-0000-0000-0000-000000000000	0fbe739f-e5a6-42f7-9136-9b78901b8625	{"action":"user_signedup","actor_id":"232621ff-fc41-40af-98af-eac89597fdf8","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-12 19:32:25.138354+00	
00000000-0000-0000-0000-000000000000	ce77fb04-5438-4ed2-b31d-4e9834f8f367	{"action":"logout","actor_id":"232621ff-fc41-40af-98af-eac89597fdf8","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-12 19:32:58.41201+00	
00000000-0000-0000-0000-000000000000	048e1ad1-9d7f-4e13-b68d-851947f9a893	{"action":"user_signedup","actor_id":"6ecefa61-b5e7-4636-93c0-c83e9b275d4e","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-12 19:36:40.867661+00	
00000000-0000-0000-0000-000000000000	02d828c2-b80a-4bd2-9a2a-306842086971	{"action":"logout","actor_id":"6ecefa61-b5e7-4636-93c0-c83e9b275d4e","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-12 19:37:03.355064+00	
00000000-0000-0000-0000-000000000000	8d40a020-08b0-4b58-9251-01fb37548733	{"action":"login","actor_id":"6ecefa61-b5e7-4636-93c0-c83e9b275d4e","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-12 19:38:46.421399+00	
00000000-0000-0000-0000-000000000000	4003cf17-b132-47d5-aab0-c96adc2f74d2	{"action":"logout","actor_id":"6ecefa61-b5e7-4636-93c0-c83e9b275d4e","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-12 19:39:01.930719+00	
00000000-0000-0000-0000-000000000000	5f2cf680-271d-4769-9776-1efdcc1868f4	{"action":"login","actor_id":"6ecefa61-b5e7-4636-93c0-c83e9b275d4e","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-12 19:40:06.04679+00	
00000000-0000-0000-0000-000000000000	632bdc72-0e37-46ff-af24-e9842c9f62e4	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"6ecefa61-b5e7-4636-93c0-c83e9b275d4e","user_phone":""}}	2025-11-12 19:41:01.501219+00	
00000000-0000-0000-0000-000000000000	c0168177-7173-4db9-a4cb-91585debd7d1	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"232621ff-fc41-40af-98af-eac89597fdf8","user_phone":""}}	2025-11-12 19:45:39.196652+00	
00000000-0000-0000-0000-000000000000	8cfb8ec4-4451-4ac4-b5d8-7951eeee26a3	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"4e49f491-5892-4ad4-8468-ef211f3963af","user_phone":""}}	2025-11-12 19:45:39.388742+00	
00000000-0000-0000-0000-000000000000	2cd70491-78bc-4a5a-87b5-6db89313ef98	{"action":"user_signedup","actor_id":"554510f9-9b95-4664-a0b6-17e40c649bf4","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-12 19:48:53.649776+00	
00000000-0000-0000-0000-000000000000	bd27d974-5f53-4512-9379-f8d4e7a519de	{"action":"logout","actor_id":"554510f9-9b95-4664-a0b6-17e40c649bf4","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-12 19:49:59.285814+00	
00000000-0000-0000-0000-000000000000	c31b1a57-1956-42a8-be15-f466ef8e2d3b	{"action":"user_signedup","actor_id":"1a9445f0-baa1-4a4b-8c74-70a25a054cfc","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-12 19:51:49.624267+00	
00000000-0000-0000-0000-000000000000	3e443329-71b9-4ef4-9336-c6798a8e148f	{"action":"logout","actor_id":"1a9445f0-baa1-4a4b-8c74-70a25a054cfc","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-12 19:53:17.318521+00	
00000000-0000-0000-0000-000000000000	c872da70-ff49-4947-93e3-4cc0eb893f69	{"action":"login","actor_id":"1a9445f0-baa1-4a4b-8c74-70a25a054cfc","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-12 23:58:28.056768+00	
00000000-0000-0000-0000-000000000000	c8b381dd-3e6c-4cd8-9f14-25f58c92a238	{"action":"logout","actor_id":"1a9445f0-baa1-4a4b-8c74-70a25a054cfc","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-12 23:59:20.959479+00	
00000000-0000-0000-0000-000000000000	9ace3a6e-00c8-46b7-ab1c-6bf503c6981a	{"action":"user_recovery_requested","actor_id":"554510f9-9b95-4664-a0b6-17e40c649bf4","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-13 00:00:24.988955+00	
00000000-0000-0000-0000-000000000000	b188939e-6f98-4681-b32e-e427840acaf5	{"action":"login","actor_id":"554510f9-9b95-4664-a0b6-17e40c649bf4","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-13 00:01:50.290546+00	
00000000-0000-0000-0000-000000000000	b8d6a457-f01a-46d0-98e8-f1001ddeff25	{"action":"user_updated_password","actor_id":"554510f9-9b95-4664-a0b6-17e40c649bf4","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-13 00:02:10.353816+00	
00000000-0000-0000-0000-000000000000	ba075360-673d-470c-a43b-f07f7539ed99	{"action":"user_modified","actor_id":"554510f9-9b95-4664-a0b6-17e40c649bf4","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-13 00:02:10.354529+00	
00000000-0000-0000-0000-000000000000	d4c9b090-d32f-42d2-8c99-7a5472d61c7c	{"action":"logout","actor_id":"554510f9-9b95-4664-a0b6-17e40c649bf4","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-13 00:02:11.221254+00	
00000000-0000-0000-0000-000000000000	4c5610f5-c70f-4493-8dd6-4dd9af66fa86	{"action":"login","actor_id":"554510f9-9b95-4664-a0b6-17e40c649bf4","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-13 00:02:33.011193+00	
00000000-0000-0000-0000-000000000000	70a89f8e-ef7c-4f6f-a5c5-38dff704560e	{"action":"logout","actor_id":"554510f9-9b95-4664-a0b6-17e40c649bf4","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-13 00:03:47.711932+00	
00000000-0000-0000-0000-000000000000	0bcca819-7e4e-4d67-bd18-88f44d6c3233	{"action":"login","actor_id":"554510f9-9b95-4664-a0b6-17e40c649bf4","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-13 00:06:58.278946+00	
00000000-0000-0000-0000-000000000000	8f1e677e-1a7a-4dff-9f06-a262169d5652	{"action":"token_refreshed","actor_id":"554510f9-9b95-4664-a0b6-17e40c649bf4","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-13 04:51:30.032847+00	
00000000-0000-0000-0000-000000000000	30e95bd1-718b-42bf-8e2a-3e760e1ec7cd	{"action":"token_revoked","actor_id":"554510f9-9b95-4664-a0b6-17e40c649bf4","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-13 04:51:30.044637+00	
00000000-0000-0000-0000-000000000000	24a03cf0-e3c4-4b32-96f0-d6d18895bf53	{"action":"logout","actor_id":"554510f9-9b95-4664-a0b6-17e40c649bf4","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-13 04:53:12.084104+00	
00000000-0000-0000-0000-000000000000	834f52bc-43de-4893-8316-f31e3c11ec69	{"action":"login","actor_id":"554510f9-9b95-4664-a0b6-17e40c649bf4","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-13 04:55:09.875535+00	
00000000-0000-0000-0000-000000000000	73058b7c-d476-4de8-aad9-688a02245c58	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"554510f9-9b95-4664-a0b6-17e40c649bf4","user_phone":""}}	2025-11-13 04:56:10.298222+00	
00000000-0000-0000-0000-000000000000	cee26b89-1435-4746-ab79-8653684977dd	{"action":"login","actor_id":"1a9445f0-baa1-4a4b-8c74-70a25a054cfc","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-13 04:56:29.911534+00	
00000000-0000-0000-0000-000000000000	0cc30afb-a58c-4fe8-96e9-51b33f111b8d	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"1a9445f0-baa1-4a4b-8c74-70a25a054cfc","user_phone":""}}	2025-11-13 04:56:54.241727+00	
00000000-0000-0000-0000-000000000000	268bd598-982d-4949-88a6-8541f5813a79	{"action":"user_signedup","actor_id":"71a08f95-59e9-444f-9fd8-e078e56ccd0e","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-13 06:12:06.148705+00	
00000000-0000-0000-0000-000000000000	76267265-2fc0-4883-97b0-84809032f6df	{"action":"logout","actor_id":"71a08f95-59e9-444f-9fd8-e078e56ccd0e","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-13 06:13:37.102794+00	
00000000-0000-0000-0000-000000000000	e2651650-7e8d-451a-8e8c-69f395d3b6b7	{"action":"login","actor_id":"71a08f95-59e9-444f-9fd8-e078e56ccd0e","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-13 06:15:52.230617+00	
00000000-0000-0000-0000-000000000000	1f8908ff-6724-4cdf-bc7d-e985240f1c36	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"71a08f95-59e9-444f-9fd8-e078e56ccd0e","user_phone":""}}	2025-11-13 06:16:11.353393+00	
00000000-0000-0000-0000-000000000000	0fcd8ca6-abfa-459e-8c8a-a10497d95266	{"action":"user_signedup","actor_id":"269da948-2082-4305-ba91-7342be0a424f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-13 06:18:49.532414+00	
00000000-0000-0000-0000-000000000000	9f12c985-c8d4-498e-94be-ff8a986a6f8a	{"action":"logout","actor_id":"269da948-2082-4305-ba91-7342be0a424f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-13 06:21:57.817427+00	
00000000-0000-0000-0000-000000000000	ecfe23c0-49d4-4b23-b5de-2c253f788cbb	{"action":"user_signedup","actor_id":"f7096a59-2992-49f7-b63c-ac7f88534626","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-13 06:26:23.604629+00	
00000000-0000-0000-0000-000000000000	4fd884ef-7816-4313-a84d-2178313d86bd	{"action":"logout","actor_id":"f7096a59-2992-49f7-b63c-ac7f88534626","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-13 06:26:31.968046+00	
00000000-0000-0000-0000-000000000000	51795aa2-f6f9-4f04-a7ab-f9e4509816f7	{"action":"user_signedup","actor_id":"e31810f2-f4e0-4fe3-9418-da1c6cb17a33","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-13 06:42:13.441743+00	
00000000-0000-0000-0000-000000000000	c388b560-9dfa-49f6-86e0-8e84fad49420	{"action":"logout","actor_id":"e31810f2-f4e0-4fe3-9418-da1c6cb17a33","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-13 06:52:49.61087+00	
00000000-0000-0000-0000-000000000000	dd1b11c4-b773-4489-9bbb-d15c91a967a3	{"action":"login","actor_id":"269da948-2082-4305-ba91-7342be0a424f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-13 06:53:34.966648+00	
00000000-0000-0000-0000-000000000000	bc9acfeb-71a4-49c3-927f-6fc2665043da	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"269da948-2082-4305-ba91-7342be0a424f","user_phone":""}}	2025-11-13 06:54:04.490517+00	
00000000-0000-0000-0000-000000000000	81be57da-7822-4e71-85cb-db6c31a8fe15	{"action":"user_signedup","actor_id":"950aa210-c549-4f92-9edb-fb76a004d230","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-13 06:55:51.109426+00	
00000000-0000-0000-0000-000000000000	3214b1f5-5ec1-4975-9ab8-086336c77d7c	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"f7096a59-2992-49f7-b63c-ac7f88534626","user_phone":""}}	2025-11-13 06:59:02.247202+00	
00000000-0000-0000-0000-000000000000	bddcf6c4-d705-4e80-b26c-aa668714e1f5	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"e31810f2-f4e0-4fe3-9418-da1c6cb17a33","user_phone":""}}	2025-11-13 06:59:02.248455+00	
00000000-0000-0000-0000-000000000000	2ccd484c-98ba-42bc-9edc-0b2f24b2b783	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"950aa210-c549-4f92-9edb-fb76a004d230","user_phone":""}}	2025-11-13 06:59:02.249794+00	
00000000-0000-0000-0000-000000000000	77c39005-211a-4fad-8524-6a28caf36597	{"action":"user_signedup","actor_id":"0b3e5f06-be90-444d-a201-0e6b47bf0171","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-13 07:07:08.37494+00	
00000000-0000-0000-0000-000000000000	1f6f5050-4fde-478e-9cba-27fd1d3d0fbd	{"action":"logout","actor_id":"0b3e5f06-be90-444d-a201-0e6b47bf0171","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-13 07:41:34.903992+00	
00000000-0000-0000-0000-000000000000	e8892191-51c0-4b20-a144-0499f3c47fc7	{"action":"user_signedup","actor_id":"adc0806a-f6fe-4f6d-b323-ab38f3cc76ec","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-13 19:35:05.938031+00	
00000000-0000-0000-0000-000000000000	00ff0232-3d66-497e-9e47-2ad7ff547df6	{"action":"logout","actor_id":"adc0806a-f6fe-4f6d-b323-ab38f3cc76ec","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-13 19:37:47.932221+00	
00000000-0000-0000-0000-000000000000	ec6ccad8-5d45-4d9a-aebb-a8cdbfd06747	{"action":"user_signedup","actor_id":"5a2978cc-e135-4fb4-b780-b57123e922e1","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-13 19:39:27.907391+00	
00000000-0000-0000-0000-000000000000	684ecfa5-6281-4324-b720-96f4dae8b2e5	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"5a2978cc-e135-4fb4-b780-b57123e922e1","user_phone":""}}	2025-11-13 19:45:18.468743+00	
00000000-0000-0000-0000-000000000000	a616a1bf-7419-4ede-93db-36829e2798a4	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"adc0806a-f6fe-4f6d-b323-ab38f3cc76ec","user_phone":""}}	2025-11-13 19:45:18.664422+00	
00000000-0000-0000-0000-000000000000	b58f1c2c-93c4-4aa7-a200-e8e8154668ad	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"0b3e5f06-be90-444d-a201-0e6b47bf0171","user_phone":""}}	2025-11-13 19:45:18.673479+00	
00000000-0000-0000-0000-000000000000	148aeb03-f83d-432c-8b7e-d278e2dcf6b3	{"action":"user_signedup","actor_id":"73e3a545-6a50-402c-93c4-ba9e1a1bfef1","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-13 20:01:49.490357+00	
00000000-0000-0000-0000-000000000000	5d89746b-e3aa-4a83-8551-1e2f58723b32	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"73e3a545-6a50-402c-93c4-ba9e1a1bfef1","user_phone":""}}	2025-11-13 20:07:40.143349+00	
00000000-0000-0000-0000-000000000000	87fb9996-44ea-49fa-84cb-49341a338273	{"action":"user_signedup","actor_id":"72629408-9920-4db0-83f0-5160392668b9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-13 21:59:38.77551+00	
00000000-0000-0000-0000-000000000000	d4365b0b-c5c2-4d42-91c9-006a50c1372c	{"action":"logout","actor_id":"72629408-9920-4db0-83f0-5160392668b9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-13 22:05:08.778984+00	
00000000-0000-0000-0000-000000000000	624af775-aeb2-40ba-a4e3-bbd6fddf28f5	{"action":"login","actor_id":"72629408-9920-4db0-83f0-5160392668b9","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-13 22:06:43.751337+00	
00000000-0000-0000-0000-000000000000	09f355ab-c904-444a-98b1-24119078a8a0	{"action":"user_signedup","actor_id":"10ab3a3f-11dd-42ac-a531-0de85fcc294b","actor_username":"fouad.bashaar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-14 08:12:26.17744+00	
00000000-0000-0000-0000-000000000000	b973f7f9-6b16-4dcd-ab81-5b938921bf93	{"action":"logout","actor_id":"10ab3a3f-11dd-42ac-a531-0de85fcc294b","actor_username":"fouad.bashaar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-14 08:13:51.906172+00	
00000000-0000-0000-0000-000000000000	35eca266-0b55-44cb-99d5-6f8f2aa0b6af	{"action":"user_recovery_requested","actor_id":"4f0daf5f-73e4-44e6-ba56-aba7cf38472d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-14 09:53:37.542126+00	
00000000-0000-0000-0000-000000000000	ece2ac36-07b0-40e5-9878-ed44edb2bccf	{"action":"user_signedup","actor_id":"4f0daf5f-73e4-44e6-ba56-aba7cf38472d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-14 09:54:00.925929+00	
00000000-0000-0000-0000-000000000000	0c7a542b-77d7-40b1-8cef-b8353ecb0acc	{"action":"user_updated_password","actor_id":"4f0daf5f-73e4-44e6-ba56-aba7cf38472d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-14 09:55:26.496441+00	
00000000-0000-0000-0000-000000000000	7ed5000b-4ad1-4f07-a0bf-ed0f63e58d45	{"action":"user_modified","actor_id":"4f0daf5f-73e4-44e6-ba56-aba7cf38472d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-14 09:55:26.497223+00	
00000000-0000-0000-0000-000000000000	a1511c86-d87f-4e12-ac4d-f8bf938aa2a4	{"action":"logout","actor_id":"4f0daf5f-73e4-44e6-ba56-aba7cf38472d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-14 09:55:27.720798+00	
00000000-0000-0000-0000-000000000000	de8b0f1a-e991-4a76-a56d-5893a12472ee	{"action":"login","actor_id":"4f0daf5f-73e4-44e6-ba56-aba7cf38472d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-14 09:55:37.147629+00	
00000000-0000-0000-0000-000000000000	9bac1a00-60fb-43be-ad35-21e78f7d23d9	{"action":"logout","actor_id":"4f0daf5f-73e4-44e6-ba56-aba7cf38472d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-14 10:03:52.480853+00	
00000000-0000-0000-0000-000000000000	b704b916-097e-4708-ae26-954df6dba000	{"action":"login","actor_id":"4f0daf5f-73e4-44e6-ba56-aba7cf38472d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-14 10:03:58.735544+00	
00000000-0000-0000-0000-000000000000	ba6b20d3-0106-4539-b7d4-39f56a57fa92	{"action":"logout","actor_id":"4f0daf5f-73e4-44e6-ba56-aba7cf38472d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-14 10:05:39.064308+00	
00000000-0000-0000-0000-000000000000	ac05d01c-a100-4967-8b1c-99d4b0e94f73	{"action":"login","actor_id":"4f0daf5f-73e4-44e6-ba56-aba7cf38472d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-14 10:06:04.237319+00	
00000000-0000-0000-0000-000000000000	b0b94b56-8818-4ae2-bbdb-7d377412230a	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"4f0daf5f-73e4-44e6-ba56-aba7cf38472d","user_phone":""}}	2025-11-14 10:06:28.588942+00	
00000000-0000-0000-0000-000000000000	e9d2e924-450e-4650-9ba1-8f0708b1cda9	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouad.bashaar@gmail.com","user_id":"10ab3a3f-11dd-42ac-a531-0de85fcc294b","user_phone":""}}	2025-11-14 10:11:21.219771+00	
00000000-0000-0000-0000-000000000000	5d711a90-25ee-4567-abe9-9fae4b0c4794	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"72629408-9920-4db0-83f0-5160392668b9","user_phone":""}}	2025-11-14 10:11:21.226663+00	
00000000-0000-0000-0000-000000000000	adaf2da7-f355-4cff-9181-3da68d7c8763	{"action":"user_signedup","actor_id":"5d5fb5fb-e575-4700-91cb-f3b4d8cce020","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-14 10:14:56.04659+00	
00000000-0000-0000-0000-000000000000	4751215e-faf2-4b25-8e97-6f7882b1b70f	{"action":"logout","actor_id":"5d5fb5fb-e575-4700-91cb-f3b4d8cce020","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-14 10:20:25.115799+00	
00000000-0000-0000-0000-000000000000	a7de0fd6-c07e-4b83-b7c0-a8619f875f14	{"action":"user_signedup","actor_id":"e1eacbca-a9ce-4f76-9c47-764aa19896ac","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-14 11:35:16.44302+00	
00000000-0000-0000-0000-000000000000	27c6b904-4f19-43cd-85a3-17e47c3d9ea3	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"e1eacbca-a9ce-4f76-9c47-764aa19896ac","user_phone":""}}	2025-11-14 11:39:36.510089+00	
00000000-0000-0000-0000-000000000000	344017da-2b81-40c7-a863-4e4573c72477	{"action":"user_signedup","actor_id":"d187a663-f904-4e67-b1ee-285658b09f0e","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-14 11:41:03.21635+00	
00000000-0000-0000-0000-000000000000	c8eafaf2-9d7c-45dd-9da4-564c7f2f3b99	{"action":"logout","actor_id":"d187a663-f904-4e67-b1ee-285658b09f0e","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-14 11:43:18.319644+00	
00000000-0000-0000-0000-000000000000	935b0fc5-56db-4933-a9b7-3d09aa13245a	{"action":"login","actor_id":"d187a663-f904-4e67-b1ee-285658b09f0e","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-14 11:43:26.099468+00	
00000000-0000-0000-0000-000000000000	dd35da2f-140c-44f2-b9e7-81b8e3092e4b	{"action":"logout","actor_id":"d187a663-f904-4e67-b1ee-285658b09f0e","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-14 11:44:04.652454+00	
00000000-0000-0000-0000-000000000000	233bd9cb-dacf-454a-aa48-630f16f6ccea	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"d187a663-f904-4e67-b1ee-285658b09f0e","user_phone":""}}	2025-11-14 12:17:39.968421+00	
00000000-0000-0000-0000-000000000000	ea955c0d-0a09-4aae-9648-91bc656b5105	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"5d5fb5fb-e575-4700-91cb-f3b4d8cce020","user_phone":""}}	2025-11-14 12:17:40.125002+00	
00000000-0000-0000-0000-000000000000	ff02e8c7-90c0-4b0d-bc08-47d5acd90303	{"action":"user_signedup","actor_id":"617060e2-982d-40b7-87c7-4cb6df9812d2","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-14 12:32:19.174686+00	
00000000-0000-0000-0000-000000000000	142d776f-8e70-4cdb-8b76-14bc5b6dfbdf	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"617060e2-982d-40b7-87c7-4cb6df9812d2","user_phone":""}}	2025-11-14 13:04:59.530876+00	
00000000-0000-0000-0000-000000000000	40b8acbb-fa67-46c9-8330-74d4a5137036	{"action":"user_signedup","actor_id":"811023dd-7c7b-4c41-8d39-785280cf21ed","actor_username":"fouad.bashaar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-14 13:07:33.899532+00	
00000000-0000-0000-0000-000000000000	3274dc8d-1e4a-4c05-af24-7388ed1ea417	{"action":"logout","actor_id":"811023dd-7c7b-4c41-8d39-785280cf21ed","actor_username":"fouad.bashaar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-14 13:10:42.399652+00	
00000000-0000-0000-0000-000000000000	98423758-02b6-4ab1-a328-071efd8f47e6	{"action":"login","actor_id":"811023dd-7c7b-4c41-8d39-785280cf21ed","actor_username":"fouad.bashaar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-15 02:18:57.422083+00	
00000000-0000-0000-0000-000000000000	53499a37-1c00-44b1-9f45-e921cca2766f	{"action":"logout","actor_id":"811023dd-7c7b-4c41-8d39-785280cf21ed","actor_username":"fouad.bashaar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-15 02:20:33.394095+00	
00000000-0000-0000-0000-000000000000	166270b6-97ff-4925-9d4b-3b270a90fa56	{"action":"login","actor_id":"811023dd-7c7b-4c41-8d39-785280cf21ed","actor_username":"fouad.bashaar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-15 02:22:10.360985+00	
00000000-0000-0000-0000-000000000000	d73434a4-dbf4-45d4-85d8-868bd7638e17	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouad.bashaar@gmail.com","user_id":"811023dd-7c7b-4c41-8d39-785280cf21ed","user_phone":""}}	2025-11-15 02:23:09.859613+00	
00000000-0000-0000-0000-000000000000	e681f730-c607-404d-876a-c7c17459a944	{"action":"user_signedup","actor_id":"3f7d1a50-b46d-48cc-b64c-40b02cb75ea5","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-15 05:00:37.939865+00	
00000000-0000-0000-0000-000000000000	c2d54a36-048f-40df-bf2c-3bf86dbd885a	{"action":"user_recovery_requested","actor_id":"3f7d1a50-b46d-48cc-b64c-40b02cb75ea5","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-15 07:33:43.572777+00	
00000000-0000-0000-0000-000000000000	f8666fb2-b954-4116-8a36-0b89db089803	{"action":"login","actor_id":"3f7d1a50-b46d-48cc-b64c-40b02cb75ea5","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-15 07:41:41.80609+00	
00000000-0000-0000-0000-000000000000	53b9cdf9-9512-4626-916a-636877944f50	{"action":"user_updated_password","actor_id":"3f7d1a50-b46d-48cc-b64c-40b02cb75ea5","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-15 07:42:11.359292+00	
00000000-0000-0000-0000-000000000000	205d2c70-79fe-4ce8-b469-0b3da33fb9de	{"action":"user_modified","actor_id":"3f7d1a50-b46d-48cc-b64c-40b02cb75ea5","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-15 07:42:11.362676+00	
00000000-0000-0000-0000-000000000000	dd3dda07-0c87-4082-be06-01d1a5d5109e	{"action":"logout","actor_id":"3f7d1a50-b46d-48cc-b64c-40b02cb75ea5","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-15 07:42:13.883565+00	
00000000-0000-0000-0000-000000000000	ec6d522b-333b-42bf-b34b-a10470b7149b	{"action":"login","actor_id":"3f7d1a50-b46d-48cc-b64c-40b02cb75ea5","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-15 07:42:46.412627+00	
00000000-0000-0000-0000-000000000000	777f7a41-62c1-4f87-be01-f606fe63cdb2	{"action":"logout","actor_id":"3f7d1a50-b46d-48cc-b64c-40b02cb75ea5","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-15 07:44:31.695622+00	
00000000-0000-0000-0000-000000000000	2112951f-35ed-4e23-890d-8d600aa6655e	{"action":"login","actor_id":"3f7d1a50-b46d-48cc-b64c-40b02cb75ea5","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-15 07:44:43.676908+00	
00000000-0000-0000-0000-000000000000	e47e5a72-527d-4fc8-9229-186861d3e0a1	{"action":"logout","actor_id":"3f7d1a50-b46d-48cc-b64c-40b02cb75ea5","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-15 08:22:46.570899+00	
00000000-0000-0000-0000-000000000000	d174a028-f333-4026-82ad-53004c51f0b0	{"action":"login","actor_id":"3f7d1a50-b46d-48cc-b64c-40b02cb75ea5","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-15 08:24:22.52102+00	
00000000-0000-0000-0000-000000000000	1b291ad2-3491-41e0-b730-322bd611c520	{"action":"logout","actor_id":"3f7d1a50-b46d-48cc-b64c-40b02cb75ea5","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-15 08:24:35.528153+00	
00000000-0000-0000-0000-000000000000	7d154cae-b0bf-49dc-b188-2d0211c8d960	{"action":"login","actor_id":"3f7d1a50-b46d-48cc-b64c-40b02cb75ea5","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-15 08:25:37.235079+00	
00000000-0000-0000-0000-000000000000	03cc6e44-895d-4363-8974-b8af69c153b5	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"3f7d1a50-b46d-48cc-b64c-40b02cb75ea5","user_phone":""}}	2025-11-15 08:26:33.187739+00	
00000000-0000-0000-0000-000000000000	7995e452-49e0-49b4-99f1-53ffe79306b2	{"action":"user_signedup","actor_id":"e5893d6c-063f-4ef2-89cf-5ae8ed78e93d","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-15 08:30:16.433309+00	
00000000-0000-0000-0000-000000000000	815a405d-bf34-4182-9004-a9ea63eaee89	{"action":"logout","actor_id":"e5893d6c-063f-4ef2-89cf-5ae8ed78e93d","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-15 08:30:22.786503+00	
00000000-0000-0000-0000-000000000000	df2859d4-d79c-43c7-b5e7-d44ded187bbc	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"e5893d6c-063f-4ef2-89cf-5ae8ed78e93d","user_phone":""}}	2025-11-16 09:45:00.304908+00	
00000000-0000-0000-0000-000000000000	3fbace97-4cd5-4956-91db-7f69ff5520f9	{"action":"user_signedup","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-16 09:47:32.958927+00	
00000000-0000-0000-0000-000000000000	a435386e-c57d-4bce-bc96-65e2fbba323b	{"action":"logout","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-16 10:00:53.83231+00	
00000000-0000-0000-0000-000000000000	1a8501d2-9f79-4726-91bc-b717ed804759	{"action":"login","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-16 10:01:15.263726+00	
00000000-0000-0000-0000-000000000000	8da645a4-73a4-4683-b56a-f999b427df5c	{"action":"logout","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-16 10:02:27.872998+00	
00000000-0000-0000-0000-000000000000	2268e687-e8b7-49f8-a0d1-13b50f20c9b6	{"action":"user_recovery_requested","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-16 21:41:15.877376+00	
00000000-0000-0000-0000-000000000000	acb97e66-179d-4e50-acd6-4442f479eae4	{"action":"login","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-16 21:42:36.842863+00	
00000000-0000-0000-0000-000000000000	6470b3bb-00de-41c6-a2a6-a589f9390a73	{"action":"user_updated_password","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-16 21:42:48.729697+00	
00000000-0000-0000-0000-000000000000	7e7e6c87-8400-4936-a428-d3cc38be6e0c	{"action":"user_modified","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-16 21:42:48.73109+00	
00000000-0000-0000-0000-000000000000	dda92302-5f89-45f8-80f2-833ba6e350e3	{"action":"logout","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-16 21:42:49.56056+00	
00000000-0000-0000-0000-000000000000	df0b9362-a34d-418f-adc9-21cb2b73b53b	{"action":"login","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-16 21:43:07.811296+00	
00000000-0000-0000-0000-000000000000	124927cf-0ed5-4ed2-abaa-1790ca8d713a	{"action":"logout","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-16 21:44:03.916836+00	
00000000-0000-0000-0000-000000000000	78e95118-5af3-4851-9bbf-205287e385ef	{"action":"login","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-16 21:44:15.4347+00	
00000000-0000-0000-0000-000000000000	0ad5f9de-7ce1-4700-b1a3-1a48da29b98f	{"action":"token_refreshed","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-16 23:04:57.194537+00	
00000000-0000-0000-0000-000000000000	8fb646a8-5a36-4041-8443-38f34103bd94	{"action":"token_revoked","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-16 23:04:57.209682+00	
00000000-0000-0000-0000-000000000000	7e382114-e559-44c2-bc81-9920a0bb112f	{"action":"token_refreshed","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-16 23:05:15.57243+00	
00000000-0000-0000-0000-000000000000	f4684336-e923-45c6-9344-187fbfcb9fd1	{"action":"token_refreshed","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-16 23:05:20.936167+00	
00000000-0000-0000-0000-000000000000	0d9a9e73-964e-4754-8c6a-287c448cf432	{"action":"logout","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-16 23:05:33.574704+00	
00000000-0000-0000-0000-000000000000	ae27624e-5ee1-46b6-95ac-f5757fff5913	{"action":"user_signedup","actor_id":"71c5268f-bcdd-401a-94e1-6d266e79fcd6","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-16 23:08:38.651956+00	
00000000-0000-0000-0000-000000000000	a4e75628-3f97-4f70-9bb8-f496370496e7	{"action":"logout","actor_id":"71c5268f-bcdd-401a-94e1-6d266e79fcd6","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-16 23:09:43.284358+00	
00000000-0000-0000-0000-000000000000	254d2add-3a7c-4acb-8fcb-a0723541fe29	{"action":"login","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-16 23:09:54.306258+00	
00000000-0000-0000-0000-000000000000	5e66bb80-d634-45eb-9962-5fdcf01e7cd2	{"action":"logout","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-16 23:12:07.224394+00	
00000000-0000-0000-0000-000000000000	aa8bf1ab-da99-4d34-b606-43c45dc89929	{"action":"login","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-16 23:14:16.700405+00	
00000000-0000-0000-0000-000000000000	8a01826d-39da-4228-a70f-be8696194649	{"action":"logout","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-16 23:14:44.242041+00	
00000000-0000-0000-0000-000000000000	1f12df40-4ced-488b-b7b6-a57786e28c41	{"action":"login","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-17 00:30:50.253684+00	
00000000-0000-0000-0000-000000000000	ba634733-2d48-46dc-918e-a6968f129c10	{"action":"logout","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 00:34:37.536328+00	
00000000-0000-0000-0000-000000000000	5aa24ff4-e6f9-44d7-97b2-a658017fcbf3	{"action":"login","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-17 00:35:31.698534+00	
00000000-0000-0000-0000-000000000000	f1e418b7-62eb-4e42-9276-c65bd155c6b6	{"action":"logout","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 01:21:51.383995+00	
00000000-0000-0000-0000-000000000000	7584452c-0579-4ff2-91df-61b22116e686	{"action":"login","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-17 01:22:16.102295+00	
00000000-0000-0000-0000-000000000000	54babc30-9774-44ca-b3bb-aba80c051406	{"action":"logout","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 01:24:11.307497+00	
00000000-0000-0000-0000-000000000000	0e44fdbd-4dae-432d-9140-d78470bf0784	{"action":"login","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-17 01:25:59.859168+00	
00000000-0000-0000-0000-000000000000	218fec36-f657-4a63-8de0-710ffd521d3b	{"action":"logout","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 01:26:33.023156+00	
00000000-0000-0000-0000-000000000000	80064ac1-d19c-4b31-addb-eb72b88b128e	{"action":"login","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-17 01:26:51.703131+00	
00000000-0000-0000-0000-000000000000	530d49ce-eafe-4500-9f92-250670cf1937	{"action":"logout","actor_id":"2f360df5-3757-4f6e-a781-6cf69026373f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 01:27:20.133798+00	
00000000-0000-0000-0000-000000000000	9c85a7db-0653-4926-a576-dab270d29009	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"2f360df5-3757-4f6e-a781-6cf69026373f","user_phone":""}}	2025-11-17 01:54:45.945749+00	
00000000-0000-0000-0000-000000000000	8c68819b-7552-49ff-af83-307121485cbb	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"71c5268f-bcdd-401a-94e1-6d266e79fcd6","user_phone":""}}	2025-11-17 01:54:45.943979+00	
00000000-0000-0000-0000-000000000000	fbdc42d6-772f-49b7-9c06-20a9066402cd	{"action":"user_signedup","actor_id":"1dce69e0-e847-4a13-b20b-4a43ec3699a0","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-17 01:57:43.753539+00	
00000000-0000-0000-0000-000000000000	e8fc2e0f-62a4-408f-915d-41b2cc283640	{"action":"logout","actor_id":"1dce69e0-e847-4a13-b20b-4a43ec3699a0","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 02:08:20.301344+00	
00000000-0000-0000-0000-000000000000	917cc630-4aec-46b0-8936-a6a36c82a990	{"action":"login","actor_id":"1dce69e0-e847-4a13-b20b-4a43ec3699a0","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-17 05:58:19.412225+00	
00000000-0000-0000-0000-000000000000	f4d4d4ec-7152-4acc-83f6-4ef17ba8a80d	{"action":"logout","actor_id":"1dce69e0-e847-4a13-b20b-4a43ec3699a0","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 06:56:27.864067+00	
00000000-0000-0000-0000-000000000000	f07a5c75-daf3-4a38-ae45-86dd8638d00e	{"action":"login","actor_id":"1dce69e0-e847-4a13-b20b-4a43ec3699a0","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-17 06:56:39.089521+00	
00000000-0000-0000-0000-000000000000	b55297f3-c851-4f14-b9ef-be7eff5af694	{"action":"logout","actor_id":"1dce69e0-e847-4a13-b20b-4a43ec3699a0","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 07:17:51.000579+00	
00000000-0000-0000-0000-000000000000	278972a4-fd88-4cd8-8d1c-aa61016ce0b0	{"action":"login","actor_id":"1dce69e0-e847-4a13-b20b-4a43ec3699a0","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-17 07:17:57.695262+00	
00000000-0000-0000-0000-000000000000	a21b30f4-85bd-45c6-ab3c-0f6c040d82ea	{"action":"logout","actor_id":"1dce69e0-e847-4a13-b20b-4a43ec3699a0","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 07:18:23.443984+00	
00000000-0000-0000-0000-000000000000	486ee746-9ce6-4962-b200-ae85fd53cce5	{"action":"user_signedup","actor_id":"3522cd30-8650-4091-a278-fc566c6df72e","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-17 07:20:21.950692+00	
00000000-0000-0000-0000-000000000000	0e1ac8e7-6874-43b9-924d-b47a5401acd6	{"action":"logout","actor_id":"3522cd30-8650-4091-a278-fc566c6df72e","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 07:23:52.274343+00	
00000000-0000-0000-0000-000000000000	8d58efcb-8644-4c83-8673-dbdf527576ec	{"action":"login","actor_id":"3522cd30-8650-4091-a278-fc566c6df72e","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-17 07:23:58.707107+00	
00000000-0000-0000-0000-000000000000	0a4a0425-202a-4274-8780-5a1149757a06	{"action":"logout","actor_id":"3522cd30-8650-4091-a278-fc566c6df72e","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 07:25:00.325856+00	
00000000-0000-0000-0000-000000000000	cf8580e7-2a71-4e0f-a9bf-3ff159101938	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"3522cd30-8650-4091-a278-fc566c6df72e","user_phone":""}}	2025-11-17 07:29:18.0553+00	
00000000-0000-0000-0000-000000000000	c477b0b9-e530-4d6e-aa52-e0bec9a907e6	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"1dce69e0-e847-4a13-b20b-4a43ec3699a0","user_phone":""}}	2025-11-17 07:29:18.055994+00	
00000000-0000-0000-0000-000000000000	493ea0fa-815a-4c05-b4be-dbb2f68b9864	{"action":"user_signedup","actor_id":"90cd6ad4-befb-4183-a095-25228766db53","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-17 07:31:19.78969+00	
00000000-0000-0000-0000-000000000000	c8c19609-8376-4186-a279-400971ed6853	{"action":"logout","actor_id":"90cd6ad4-befb-4183-a095-25228766db53","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 08:09:28.293511+00	
00000000-0000-0000-0000-000000000000	f46ca737-7b3b-4fbe-869b-728ee309828f	{"action":"login","actor_id":"90cd6ad4-befb-4183-a095-25228766db53","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-17 08:09:58.720132+00	
00000000-0000-0000-0000-000000000000	aaa8d82a-e9fe-4e4b-acc6-8bf7466b796e	{"action":"logout","actor_id":"90cd6ad4-befb-4183-a095-25228766db53","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 08:10:20.842084+00	
00000000-0000-0000-0000-000000000000	ecaf7884-efad-445b-90f9-cf60516e3005	{"action":"user_signedup","actor_id":"a230525b-2ad8-4013-8451-5b98e9ba6ea6","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-17 08:12:54.695509+00	
00000000-0000-0000-0000-000000000000	e60bde6e-528e-44ff-84c9-ae55b51e8716	{"action":"login","actor_id":"90cd6ad4-befb-4183-a095-25228766db53","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-17 08:59:48.589871+00	
00000000-0000-0000-0000-000000000000	b7f4d630-f992-48f1-aff5-7b634468d692	{"action":"token_refreshed","actor_id":"90cd6ad4-befb-4183-a095-25228766db53","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-17 12:42:22.774534+00	
00000000-0000-0000-0000-000000000000	9d1ac00f-17da-4a39-9123-01c895ce3840	{"action":"token_revoked","actor_id":"90cd6ad4-befb-4183-a095-25228766db53","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-17 12:42:22.801506+00	
00000000-0000-0000-0000-000000000000	e018a35d-ea33-4191-9dbf-a3f4855b2552	{"action":"token_refreshed","actor_id":"90cd6ad4-befb-4183-a095-25228766db53","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-17 12:42:39.838492+00	
00000000-0000-0000-0000-000000000000	445c4411-1e58-41a6-89d7-02bc6d95e974	{"action":"token_refreshed","actor_id":"90cd6ad4-befb-4183-a095-25228766db53","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-17 12:42:47.32771+00	
00000000-0000-0000-0000-000000000000	3687772f-d029-4335-a667-cf0a4af6688b	{"action":"logout","actor_id":"90cd6ad4-befb-4183-a095-25228766db53","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 13:13:00.750986+00	
00000000-0000-0000-0000-000000000000	8a05cbf3-3edb-438d-bbe3-e6916621f548	{"action":"user_recovery_requested","actor_id":"90cd6ad4-befb-4183-a095-25228766db53","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-17 13:15:45.329199+00	
00000000-0000-0000-0000-000000000000	4d334b35-d094-47ae-8205-662e0f66bcec	{"action":"login","actor_id":"90cd6ad4-befb-4183-a095-25228766db53","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 13:17:45.787328+00	
00000000-0000-0000-0000-000000000000	84a3ed33-5e12-4de2-af6c-d6ed1065b387	{"action":"user_updated_password","actor_id":"90cd6ad4-befb-4183-a095-25228766db53","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-17 13:18:31.948556+00	
00000000-0000-0000-0000-000000000000	70a6e4c4-7b2e-4ded-9f23-4a762b972437	{"action":"user_modified","actor_id":"90cd6ad4-befb-4183-a095-25228766db53","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-17 13:18:31.953216+00	
00000000-0000-0000-0000-000000000000	5d659cf8-08a4-4663-b91d-b1490b25957e	{"action":"logout","actor_id":"90cd6ad4-befb-4183-a095-25228766db53","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 13:18:33.10949+00	
00000000-0000-0000-0000-000000000000	1319d0b6-3531-4b8c-a7b2-5e718cc18be2	{"action":"login","actor_id":"90cd6ad4-befb-4183-a095-25228766db53","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-17 13:18:56.750673+00	
00000000-0000-0000-0000-000000000000	cfc1a73f-b8d2-4431-b00e-9b4132db1d45	{"action":"logout","actor_id":"90cd6ad4-befb-4183-a095-25228766db53","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 13:20:06.358745+00	
00000000-0000-0000-0000-000000000000	ad62176a-9482-4935-babf-9876d14c0745	{"action":"user_signedup","actor_id":"0d5ebf64-fb6a-4bed-9d77-a073d18742b7","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-17 17:35:08.47671+00	
00000000-0000-0000-0000-000000000000	79c2768a-aa40-4704-a17a-484c5247b866	{"action":"logout","actor_id":"0d5ebf64-fb6a-4bed-9d77-a073d18742b7","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 17:36:31.577032+00	
00000000-0000-0000-0000-000000000000	ff35b5cb-7d6f-4c80-afbd-eee5980bee31	{"action":"login","actor_id":"0d5ebf64-fb6a-4bed-9d77-a073d18742b7","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-17 17:36:46.766982+00	
00000000-0000-0000-0000-000000000000	f7567930-5067-4be7-aab5-0db292b44ba9	{"action":"logout","actor_id":"0d5ebf64-fb6a-4bed-9d77-a073d18742b7","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 17:43:12.501176+00	
00000000-0000-0000-0000-000000000000	d6ada5dd-4db1-4b3f-89ec-9b48b2c07f37	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"a230525b-2ad8-4013-8451-5b98e9ba6ea6","user_phone":""}}	2025-11-17 18:16:51.732958+00	
00000000-0000-0000-0000-000000000000	0b5b48c2-cd5a-4bfc-afef-8b1817af227d	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"0d5ebf64-fb6a-4bed-9d77-a073d18742b7","user_phone":""}}	2025-11-17 18:16:51.851521+00	
00000000-0000-0000-0000-000000000000	d6c14401-c37a-4b2b-a5ca-5764a8285df2	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"90cd6ad4-befb-4183-a095-25228766db53","user_phone":""}}	2025-11-17 18:16:51.870292+00	
00000000-0000-0000-0000-000000000000	250ffbd6-c83f-4599-b22e-8069b2a838df	{"action":"user_signedup","actor_id":"ee5c49e7-308c-4f06-b836-8027419f9c60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-17 18:25:14.649739+00	
00000000-0000-0000-0000-000000000000	2e340374-f445-4d0e-906c-8c378562af69	{"action":"token_refreshed","actor_id":"ee5c49e7-308c-4f06-b836-8027419f9c60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-17 19:39:38.992898+00	
00000000-0000-0000-0000-000000000000	8570d63a-0157-44f0-9863-23c7bdc703f0	{"action":"token_revoked","actor_id":"ee5c49e7-308c-4f06-b836-8027419f9c60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-17 19:39:39.011642+00	
00000000-0000-0000-0000-000000000000	0d2d284d-2b23-4c10-b1c5-f4ef3bdea263	{"action":"logout","actor_id":"ee5c49e7-308c-4f06-b836-8027419f9c60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 19:50:13.433823+00	
00000000-0000-0000-0000-000000000000	fb896216-314d-46af-9e45-204f93d24f2f	{"action":"login","actor_id":"ee5c49e7-308c-4f06-b836-8027419f9c60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-17 19:51:19.84132+00	
00000000-0000-0000-0000-000000000000	0cb95bf5-247b-45a2-beb5-8a89cb5e52a2	{"action":"token_refreshed","actor_id":"ee5c49e7-308c-4f06-b836-8027419f9c60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-17 21:18:50.065554+00	
00000000-0000-0000-0000-000000000000	f582c228-1fc2-48cb-9b4c-68a82c6c9331	{"action":"token_revoked","actor_id":"ee5c49e7-308c-4f06-b836-8027419f9c60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-17 21:18:50.086733+00	
00000000-0000-0000-0000-000000000000	03eb5989-71ff-4366-9284-6aa0f9003ef5	{"action":"logout","actor_id":"ee5c49e7-308c-4f06-b836-8027419f9c60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 21:19:12.311395+00	
00000000-0000-0000-0000-000000000000	bcab66f8-004d-459d-8511-e1f3e02cc886	{"action":"login","actor_id":"ee5c49e7-308c-4f06-b836-8027419f9c60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-17 21:19:18.835702+00	
00000000-0000-0000-0000-000000000000	a317d2bc-6263-4dde-88c8-383a34c48893	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"ee5c49e7-308c-4f06-b836-8027419f9c60","user_phone":""}}	2025-11-17 21:21:48.54201+00	
00000000-0000-0000-0000-000000000000	81e11701-b2cb-419f-8f3e-fe86a0495b8f	{"action":"user_signedup","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-17 22:39:40.804444+00	
00000000-0000-0000-0000-000000000000	b8e2c68a-4770-40db-b6ca-d91261e566bb	{"action":"logout","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 22:41:31.671152+00	
00000000-0000-0000-0000-000000000000	6f3a3859-628e-4087-aac6-5cac544df3f5	{"action":"login","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-17 22:44:02.231072+00	
00000000-0000-0000-0000-000000000000	0970c98b-236e-461e-810c-64a5ef4d7c44	{"action":"logout","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 22:47:51.994492+00	
00000000-0000-0000-0000-000000000000	b8831250-076d-4dc2-8166-e6d30d5858ed	{"action":"login","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-17 23:33:04.508331+00	
00000000-0000-0000-0000-000000000000	b7f2d0ed-8c64-4f70-a3ad-ed275d2a046c	{"action":"logout","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-17 23:52:55.48131+00	
00000000-0000-0000-0000-000000000000	3e48c906-54f8-4de1-b7c6-02bb1aae393d	{"action":"user_recovery_requested","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-18 07:47:04.951559+00	
00000000-0000-0000-0000-000000000000	7233ff98-f2e7-4104-8b78-cdaaf2fecb40	{"action":"login","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-18 07:48:45.63507+00	
00000000-0000-0000-0000-000000000000	22e280ac-c4ef-442c-9ce6-b06964282723	{"action":"user_updated_password","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-18 07:49:08.232245+00	
00000000-0000-0000-0000-000000000000	15fbc821-1511-4242-b233-7eb6d3190352	{"action":"user_modified","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-18 07:49:08.23498+00	
00000000-0000-0000-0000-000000000000	4e364a92-7124-4bdb-b8dc-294efd3e3e8d	{"action":"logout","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-18 07:49:09.708815+00	
00000000-0000-0000-0000-000000000000	6c6f5e8d-1ac4-45c7-8c41-b6e780478d9f	{"action":"login","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-18 07:49:19.784957+00	
00000000-0000-0000-0000-000000000000	662b7b50-9f5d-40d3-8e61-4f644918c527	{"action":"logout","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-18 07:52:05.242675+00	
00000000-0000-0000-0000-000000000000	124ab4de-5c7c-4a9e-85e5-b11c80df37bc	{"action":"login","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-18 07:52:15.98676+00	
00000000-0000-0000-0000-000000000000	c0cdaa08-030a-485f-9017-bbc25da8781b	{"action":"logout","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-18 07:52:51.010225+00	
00000000-0000-0000-0000-000000000000	4d7760e5-6080-4511-a51a-78340e806f77	{"action":"login","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-18 07:54:03.078245+00	
00000000-0000-0000-0000-000000000000	c9e90d1c-e3cd-4816-ae87-2f996442e778	{"action":"logout","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-18 08:42:29.696939+00	
00000000-0000-0000-0000-000000000000	223345b3-45b7-4aba-923e-dbd2f3b9e59a	{"action":"login","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-18 08:42:51.178166+00	
00000000-0000-0000-0000-000000000000	d04cfeaa-1cd3-49cc-b7bd-9b081660d398	{"action":"token_refreshed","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-18 10:29:46.030226+00	
00000000-0000-0000-0000-000000000000	639663b2-6582-4d12-bb15-dd80ea57924e	{"action":"token_revoked","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-18 10:29:46.051929+00	
00000000-0000-0000-0000-000000000000	1f769bc3-ef64-48c2-a7c2-7bccaef2b7ba	{"action":"token_refreshed","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-18 13:32:21.3678+00	
00000000-0000-0000-0000-000000000000	c020111e-3244-4a76-bfb5-0c2441ad86da	{"action":"token_revoked","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-18 13:32:21.390239+00	
00000000-0000-0000-0000-000000000000	0ab33901-6cfb-427e-b9e4-a3adcf134150	{"action":"logout","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-18 13:33:05.574193+00	
00000000-0000-0000-0000-000000000000	9cc327b3-25e0-436c-8beb-ca3f7946ec61	{"action":"login","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-18 13:33:22.054935+00	
00000000-0000-0000-0000-000000000000	e3780369-1815-4118-9226-3bd7e5f0b40e	{"action":"logout","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-18 13:34:00.457268+00	
00000000-0000-0000-0000-000000000000	e42af436-14a4-4324-b261-1af53bd66020	{"action":"login","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-18 13:35:01.427016+00	
00000000-0000-0000-0000-000000000000	d766e8a9-cf45-4ae6-86c1-4361400c5818	{"action":"logout","actor_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-18 13:36:26.899325+00	
00000000-0000-0000-0000-000000000000	6479377c-8274-4b7d-843e-5edde518c6c4	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"fc592b08-6bcf-4c34-b7ff-0d83f7e89327","user_phone":""}}	2025-11-18 13:48:26.917043+00	
00000000-0000-0000-0000-000000000000	6d84cdc3-9580-47c2-866d-18d81bf59c90	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"27a4bba0-4266-49dd-a439-87984259439d","user_phone":""}}	2025-11-18 13:48:26.934213+00	
00000000-0000-0000-0000-000000000000	b401358a-9fa4-4cd4-97d0-064aaaab5e21	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouad.bashaar@gmail.com","user_id":"64944bb1-1b52-43e8-82b2-e9d89cf435de","user_phone":""}}	2025-11-18 13:48:27.128217+00	
00000000-0000-0000-0000-000000000000	d1ea5ea1-26c7-4359-a785-ba8baacb17ad	{"action":"user_signedup","actor_id":"b70303a1-e12d-4048-a6c6-336fa25396d5","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-18 19:45:29.045038+00	
00000000-0000-0000-0000-000000000000	426d6744-2d34-4ed3-8ebc-02faba2d83c4	{"action":"logout","actor_id":"b70303a1-e12d-4048-a6c6-336fa25396d5","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-18 19:51:16.408521+00	
00000000-0000-0000-0000-000000000000	2fc6df22-1905-4513-a686-a7701094dc35	{"action":"login","actor_id":"b70303a1-e12d-4048-a6c6-336fa25396d5","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-18 19:51:32.324039+00	
00000000-0000-0000-0000-000000000000	aeab04cd-3528-474b-aa95-64c97b94d39e	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"b70303a1-e12d-4048-a6c6-336fa25396d5","user_phone":""}}	2025-11-18 20:05:48.526356+00	
00000000-0000-0000-0000-000000000000	40c0a267-cf04-472c-a073-7246b6344d22	{"action":"user_signedup","actor_id":"92c17dd2-91f6-4f22-9528-d50f1c2875ae","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-18 20:08:30.450841+00	
00000000-0000-0000-0000-000000000000	d3f21d73-4861-4e3e-8cb9-88c41d20690d	{"action":"token_refreshed","actor_id":"92c17dd2-91f6-4f22-9528-d50f1c2875ae","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-18 22:15:39.302912+00	
00000000-0000-0000-0000-000000000000	85d599fa-399c-475c-90df-e948eaef148f	{"action":"token_revoked","actor_id":"92c17dd2-91f6-4f22-9528-d50f1c2875ae","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-18 22:15:39.323071+00	
00000000-0000-0000-0000-000000000000	95b65cb8-d9a7-40d0-a46b-6774cc0f305f	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"92c17dd2-91f6-4f22-9528-d50f1c2875ae","user_phone":""}}	2025-11-18 22:26:49.710003+00	
00000000-0000-0000-0000-000000000000	e436a66e-28fe-46a1-a113-1af1a0c79484	{"action":"user_signedup","actor_id":"a29d3c07-5b9e-47b4-8bf8-0f14421b472b","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-18 22:31:43.607297+00	
00000000-0000-0000-0000-000000000000	b06a2aaf-8c93-444d-8d52-4e26b475610b	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"a29d3c07-5b9e-47b4-8bf8-0f14421b472b","user_phone":""}}	2025-11-18 23:15:41.293418+00	
00000000-0000-0000-0000-000000000000	8eb3d1f5-0665-4324-aaf4-a8821a7f9b4a	{"action":"user_signedup","actor_id":"894d62b1-345c-43b5-8a85-ebe5da3cb550","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-19 00:12:57.557197+00	
00000000-0000-0000-0000-000000000000	ef0a8938-da68-45bc-a6d8-8ce08fc76b76	{"action":"logout","actor_id":"894d62b1-345c-43b5-8a85-ebe5da3cb550","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-19 00:23:38.135306+00	
00000000-0000-0000-0000-000000000000	7c7487ab-d7ed-453e-a248-39874ae3888b	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"894d62b1-345c-43b5-8a85-ebe5da3cb550","user_phone":""}}	2025-11-19 00:26:39.709244+00	
00000000-0000-0000-0000-000000000000	8609e20b-58ca-4e60-a935-6c3bb1de3e08	{"action":"user_signedup","actor_id":"3b554133-5e1e-48e2-b25f-3863d045a0af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-19 00:30:01.998349+00	
00000000-0000-0000-0000-000000000000	8cc134bf-3b1d-4711-98ec-e397b664d7b3	{"action":"logout","actor_id":"3b554133-5e1e-48e2-b25f-3863d045a0af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-19 00:36:01.643516+00	
00000000-0000-0000-0000-000000000000	a42c0af0-13c7-45de-99bb-11d40dec7862	{"action":"login","actor_id":"3b554133-5e1e-48e2-b25f-3863d045a0af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-19 00:37:28.708556+00	
00000000-0000-0000-0000-000000000000	1e28aa3e-946e-45b9-9ebe-a0193c49088d	{"action":"logout","actor_id":"3b554133-5e1e-48e2-b25f-3863d045a0af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-19 00:46:31.761644+00	
00000000-0000-0000-0000-000000000000	9664698b-3382-4e09-9052-b35914cb1f2c	{"action":"login","actor_id":"3b554133-5e1e-48e2-b25f-3863d045a0af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-19 00:47:48.743701+00	
00000000-0000-0000-0000-000000000000	d2381fea-214b-48b3-8137-e435ad321e72	{"action":"logout","actor_id":"3b554133-5e1e-48e2-b25f-3863d045a0af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-19 00:58:44.239515+00	
00000000-0000-0000-0000-000000000000	0a2ab42d-d470-41af-a5c4-a0ce7459a206	{"action":"login","actor_id":"3b554133-5e1e-48e2-b25f-3863d045a0af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-19 02:50:54.218057+00	
00000000-0000-0000-0000-000000000000	3e94b95c-b47e-45cb-8f96-390e8b872474	{"action":"logout","actor_id":"3b554133-5e1e-48e2-b25f-3863d045a0af","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-19 02:55:10.329419+00	
00000000-0000-0000-0000-000000000000	fcb0a39d-74d7-42cb-8a82-62a6d84f8797	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"3b554133-5e1e-48e2-b25f-3863d045a0af","user_phone":""}}	2025-11-19 03:14:24.198489+00	
00000000-0000-0000-0000-000000000000	2ef25e19-f1d2-496a-b331-11a8ca5f65fd	{"action":"user_signedup","actor_id":"4b6130a5-d529-4804-9ae0-bd34c3573c52","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-19 03:25:29.195056+00	
00000000-0000-0000-0000-000000000000	bb69e7b3-f43c-41d6-a36c-75d026b6477c	{"action":"logout","actor_id":"4b6130a5-d529-4804-9ae0-bd34c3573c52","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-19 03:25:38.99337+00	
00000000-0000-0000-0000-000000000000	81bddcba-f91d-48a5-b9fd-617855275ee6	{"action":"login","actor_id":"4b6130a5-d529-4804-9ae0-bd34c3573c52","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-19 03:25:48.402266+00	
00000000-0000-0000-0000-000000000000	9f119c9f-3fd5-4a19-b6f4-93d00ad43341	{"action":"token_refreshed","actor_id":"4b6130a5-d529-4804-9ae0-bd34c3573c52","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-19 06:02:27.431454+00	
00000000-0000-0000-0000-000000000000	668d1012-ccc5-47ed-80cb-97f74e4975c9	{"action":"token_revoked","actor_id":"4b6130a5-d529-4804-9ae0-bd34c3573c52","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-19 06:02:27.458303+00	
00000000-0000-0000-0000-000000000000	cfe50b8a-a163-42a9-b2da-d0f9d8a45321	{"action":"logout","actor_id":"4b6130a5-d529-4804-9ae0-bd34c3573c52","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-19 06:03:21.00752+00	
00000000-0000-0000-0000-000000000000	8d28ee89-7b05-46cb-b1bd-9a769f0f8676	{"action":"login","actor_id":"4b6130a5-d529-4804-9ae0-bd34c3573c52","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-19 06:03:37.227172+00	
00000000-0000-0000-0000-000000000000	df3343cf-ba3b-448d-8c16-a69ba6d4b527	{"action":"logout","actor_id":"4b6130a5-d529-4804-9ae0-bd34c3573c52","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-19 06:06:10.92581+00	
00000000-0000-0000-0000-000000000000	63fd9cd2-f8f6-4dc0-9cae-307c5864276e	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"4b6130a5-d529-4804-9ae0-bd34c3573c52","user_phone":""}}	2025-11-19 06:10:11.168058+00	
00000000-0000-0000-0000-000000000000	ac14e9d7-80fe-4b85-9a75-60f90159edb9	{"action":"user_signedup","actor_id":"d828f362-594a-4b10-bd0d-ef67c0cd9705","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-19 06:13:10.876456+00	
00000000-0000-0000-0000-000000000000	0c2ab362-ee6d-4e59-8b6a-b51146f17496	{"action":"logout","actor_id":"d828f362-594a-4b10-bd0d-ef67c0cd9705","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-19 06:23:17.321075+00	
00000000-0000-0000-0000-000000000000	3b870530-42f7-4ba5-886e-0514238b9ae8	{"action":"login","actor_id":"d828f362-594a-4b10-bd0d-ef67c0cd9705","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-19 07:18:55.33014+00	
00000000-0000-0000-0000-000000000000	e216ee99-d884-43e1-bc72-316952f76027	{"action":"logout","actor_id":"d828f362-594a-4b10-bd0d-ef67c0cd9705","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-19 07:20:24.235565+00	
00000000-0000-0000-0000-000000000000	7ce59c4d-ad3a-4180-870b-c2f40823086a	{"action":"user_signedup","actor_id":"2bfdf2cb-4742-4eb9-aa14-cf52543c8f3c","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-19 07:24:42.684028+00	
00000000-0000-0000-0000-000000000000	48f95506-c9d2-42c6-b27a-9f6bb75fe87f	{"action":"logout","actor_id":"2bfdf2cb-4742-4eb9-aa14-cf52543c8f3c","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-19 07:28:00.621833+00	
00000000-0000-0000-0000-000000000000	4ed1e097-9420-4f2a-9f37-9822f4bcfdf3	{"action":"login","actor_id":"2bfdf2cb-4742-4eb9-aa14-cf52543c8f3c","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-19 10:42:26.896893+00	
00000000-0000-0000-0000-000000000000	dbd1dada-6160-4277-bda8-777cb61cf8ed	{"action":"logout","actor_id":"2bfdf2cb-4742-4eb9-aa14-cf52543c8f3c","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-19 11:04:45.707167+00	
00000000-0000-0000-0000-000000000000	7978d2f9-a59e-48c9-8145-fee5bb671631	{"action":"login","actor_id":"1d727f21-abd0-4e6a-a7f3-ca76c3cc73f1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-23 06:57:38.482119+00	
00000000-0000-0000-0000-000000000000	7a0812d0-0cdc-46c8-ad6d-6ca7735879a4	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"2bfdf2cb-4742-4eb9-aa14-cf52543c8f3c","user_phone":""}}	2025-11-19 11:55:23.743795+00	
00000000-0000-0000-0000-000000000000	c6ab1b15-8220-4751-b177-11b2dc5a8755	{"action":"token_refreshed","actor_id":"b1c7abfd-6a48-4a2b-bcc1-641b699659dd","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-13 18:52:11.615301+00	
00000000-0000-0000-0000-000000000000	3704fce6-bbe9-46e5-816d-78f4d1513edd	{"action":"token_revoked","actor_id":"b1c7abfd-6a48-4a2b-bcc1-641b699659dd","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-13 18:52:11.646718+00	
00000000-0000-0000-0000-000000000000	13aa35b6-0b39-44f3-a7e3-015ea4e41320	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765658893084@example.test","user_id":"70960100-61d7-4cb4-828e-d4fa531477ef","user_phone":""}}	2025-12-14 12:50:40.66267+00	
00000000-0000-0000-0000-000000000000	45c5e8fc-b051-491e-99ab-ee53b2807412	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765659128978@example.test","user_id":"e4501d93-6963-4a6d-962e-d39117e10c2d","user_phone":""}}	2025-12-14 12:50:40.673647+00	
00000000-0000-0000-0000-000000000000	4abbf32e-bc4a-48e4-aa65-eaa243a23e44	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765659255845@example.test","user_id":"5b7acba0-fe57-4d07-84cb-43ee3b5ca347","user_phone":""}}	2025-12-14 12:50:40.680778+00	
00000000-0000-0000-0000-000000000000	b8c8f9e7-9deb-431d-b178-35f841e74fe9	{"action":"logout","actor_id":"137348ed-caa1-4528-8c16-68065c8ac13e","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-14 17:46:10.068756+00	
00000000-0000-0000-0000-000000000000	1828dadb-3412-4e02-a220-58605371f28a	{"action":"login","actor_id":"137348ed-caa1-4528-8c16-68065c8ac13e","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-14 17:46:16.532789+00	
00000000-0000-0000-0000-000000000000	f6685a91-ec1a-4614-a3fe-5e33e0ab9d23	{"action":"logout","actor_id":"137348ed-caa1-4528-8c16-68065c8ac13e","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-14 19:50:45.631539+00	
00000000-0000-0000-0000-000000000000	58519000-6353-44f8-aa32-bfebf3b364f9	{"action":"login","actor_id":"137348ed-caa1-4528-8c16-68065c8ac13e","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-14 19:50:57.789648+00	
00000000-0000-0000-0000-000000000000	1539505c-6265-45d4-9331-5caed5cc2755	{"action":"logout","actor_id":"137348ed-caa1-4528-8c16-68065c8ac13e","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-14 19:51:03.158837+00	
00000000-0000-0000-0000-000000000000	9d34b7a5-2390-4b69-b80f-f93504a32bbe	{"action":"user_signedup","actor_id":"b80f29c4-460a-4dd4-a40f-54bb19702061","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-12-14 19:52:25.107416+00	
00000000-0000-0000-0000-000000000000	bf8a396d-1c61-448e-b576-d0149683479a	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"137348ed-caa1-4528-8c16-68065c8ac13e","user_phone":""}}	2025-12-14 21:54:03.689139+00	
00000000-0000-0000-0000-000000000000	aa2aff0a-cc55-4f25-aac1-e4bc9a3c8459	{"action":"user_signedup","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-12-14 21:55:33.869214+00	
00000000-0000-0000-0000-000000000000	064dc930-4d73-4d15-9608-7392f1bc3fa1	{"action":"token_refreshed","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-14 23:59:14.441783+00	
00000000-0000-0000-0000-000000000000	ca57395d-223c-4f13-9919-c4fd10360529	{"action":"token_refreshed","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-14 23:59:17.576597+00	
00000000-0000-0000-0000-000000000000	b073d1ee-ef91-4688-82a9-bc81555c7403	{"action":"token_refreshed","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-15 01:52:41.762567+00	
00000000-0000-0000-0000-000000000000	dc5c628e-b07b-42c1-99ad-aac7efebe564	{"action":"token_revoked","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-15 01:52:41.769912+00	
00000000-0000-0000-0000-000000000000	e92ab9cf-ab18-4279-aaf1-c5441e0ac842	{"action":"logout","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-15 02:11:09.40888+00	
00000000-0000-0000-0000-000000000000	2be513a6-e69f-4048-8e85-4f6d45fb30e4	{"action":"logout","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-15 21:08:41.708989+00	
00000000-0000-0000-0000-000000000000	418e4ae3-9c2f-46e6-9bfa-c9a460b7d6ba	{"action":"logout","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-15 22:50:35.347989+00	
00000000-0000-0000-0000-000000000000	1bc43818-0397-4f75-b663-8d72239c8262	{"action":"logout","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-16 15:02:06.445332+00	
00000000-0000-0000-0000-000000000000	dcdb935f-c12a-4876-b8b2-9384f4ed9143	{"action":"token_refreshed","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-16 16:34:24.941951+00	
00000000-0000-0000-0000-000000000000	ab5c3163-d9ef-42e6-9f90-326dfdcbac7c	{"action":"token_revoked","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-16 16:34:24.962615+00	
00000000-0000-0000-0000-000000000000	5ef508b4-4784-44be-b4bb-b9c24da080f2	{"action":"logout","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-16 16:34:26.383157+00	
00000000-0000-0000-0000-000000000000	db6583cc-6672-4c0a-a9f6-d8eece8579df	{"action":"logout","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-16 16:38:31.55365+00	
00000000-0000-0000-0000-000000000000	585e26dd-a11c-482a-ba8c-37d85b0e3bbb	{"action":"token_refreshed","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-17 00:00:16.394315+00	
00000000-0000-0000-0000-000000000000	cbf2c2d8-e3c0-4f70-addb-9f2173abd9ec	{"action":"token_revoked","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-17 00:00:16.423087+00	
00000000-0000-0000-0000-000000000000	b77cc412-ee97-4342-84d7-ff88d79a71c8	{"action":"logout","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-17 01:19:38.759005+00	
00000000-0000-0000-0000-000000000000	2d70e450-6e3f-4a9f-b426-fce752e2303e	{"action":"logout","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-17 01:44:43.774607+00	
00000000-0000-0000-0000-000000000000	c8864d48-f804-471f-889b-8a709d59794b	{"action":"logout","actor_id":"e8f48b20-2208-41cf-bb36-211abc62dc82","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-17 19:37:59.937059+00	
00000000-0000-0000-0000-000000000000	ee92f0ed-85d5-4019-8171-4cd912d94727	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"d828f362-594a-4b10-bd0d-ef67c0cd9705","user_phone":""}}	2025-11-19 11:55:23.743694+00	
00000000-0000-0000-0000-000000000000	d0f19669-5481-4fcf-80f0-214622fadc41	{"action":"logout","actor_id":"b1c7abfd-6a48-4a2b-bcc1-641b699659dd","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-13 18:53:25.504887+00	
00000000-0000-0000-0000-000000000000	5f91601b-dcc0-4fbd-8081-5baf291a7b05	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765659192391@example.test","user_id":"1363cd53-c160-4b80-9cbb-355eb85b7af5","user_phone":""}}	2025-12-14 12:50:40.663217+00	
00000000-0000-0000-0000-000000000000	67e8ca48-c659-4cc5-8e06-b8080a5a01a2	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765658828656@example.test","user_id":"df163dfe-61ce-41c2-874d-6993928c039c","user_phone":""}}	2025-12-14 12:50:40.67221+00	
00000000-0000-0000-0000-000000000000	cd0b0da0-f955-453d-a6ba-10cd76786011	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765658032093@example.test","user_id":"add3efc8-2437-44ad-b644-4fa93df0f3b0","user_phone":""}}	2025-12-14 12:50:40.685395+00	
00000000-0000-0000-0000-000000000000	0b9cc3e6-b12e-497d-a565-94a6dc6009ae	{"action":"token_refreshed","actor_id":"137348ed-caa1-4528-8c16-68065c8ac13e","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-14 19:47:04.884909+00	
00000000-0000-0000-0000-000000000000	9324b6e0-0bf1-443c-95e5-06b7607d6c47	{"action":"token_revoked","actor_id":"137348ed-caa1-4528-8c16-68065c8ac13e","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-14 19:47:04.912046+00	
00000000-0000-0000-0000-000000000000	61093075-ecce-460a-8117-07d9e3b888b5	{"action":"logout","actor_id":"137348ed-caa1-4528-8c16-68065c8ac13e","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-14 19:47:48.32215+00	
00000000-0000-0000-0000-000000000000	f4ddeb87-aefd-4efc-af27-c056d884a6fc	{"action":"logout","actor_id":"b80f29c4-460a-4dd4-a40f-54bb19702061","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-14 20:15:54.022091+00	
00000000-0000-0000-0000-000000000000	6dba49bd-5886-4d02-af37-2efe41216322	{"action":"token_refreshed","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-14 23:01:50.7564+00	
00000000-0000-0000-0000-000000000000	d3a9690f-42d8-4218-ad57-76037e0d586b	{"action":"token_revoked","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-14 23:01:50.78769+00	
00000000-0000-0000-0000-000000000000	e57d7337-fbf8-4361-80df-876ac684f715	{"action":"token_refreshed","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-14 23:01:53.856759+00	
00000000-0000-0000-0000-000000000000	b9a3df37-5a01-4865-bb98-3f75bd02ff96	{"action":"token_refreshed","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-15 00:28:38.547974+00	
00000000-0000-0000-0000-000000000000	e21ca7d6-28a3-4e9c-b1bd-11890e05abd6	{"action":"token_refreshed","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-15 00:28:39.902329+00	
00000000-0000-0000-0000-000000000000	16bd7043-08bb-4d39-98a9-68b477010884	{"action":"logout","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-15 02:07:51.777332+00	
00000000-0000-0000-0000-000000000000	ff554433-a201-477c-89ee-2d2c224f79c4	{"action":"login","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-15 02:08:13.283329+00	
00000000-0000-0000-0000-000000000000	42b8ebfd-e621-4282-beb2-9330c1fb4cc7	{"action":"login","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-15 21:05:27.224667+00	
00000000-0000-0000-0000-000000000000	f359c616-e948-4007-9c46-d8040f4576ba	{"action":"login","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-15 22:46:23.574919+00	
00000000-0000-0000-0000-000000000000	7d948549-1529-4513-a6ee-9af8be13591f	{"action":"login","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-16 14:27:44.632297+00	
00000000-0000-0000-0000-000000000000	2e153dba-4d7d-463e-b6a3-1fe524150fc7	{"action":"login","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-16 15:32:12.722601+00	
00000000-0000-0000-0000-000000000000	9c81a39a-f304-49e1-b1cd-ead8e74e0e0c	{"action":"login","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-16 16:35:45.57198+00	
00000000-0000-0000-0000-000000000000	cdb285d8-48ac-4384-bb97-e1070f620ee3	{"action":"login","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-16 21:40:56.370505+00	
00000000-0000-0000-0000-000000000000	4f41b55d-57c1-43a9-be2a-dd484944c883	{"action":"token_refreshed","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-17 01:16:33.870336+00	
00000000-0000-0000-0000-000000000000	0a7d0022-66f7-4357-b78a-7cd1ba46166a	{"action":"token_revoked","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-17 01:16:33.885652+00	
00000000-0000-0000-0000-000000000000	1c559c23-a797-4248-8d14-601bac368305	{"action":"login","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-17 01:44:12.586942+00	
00000000-0000-0000-0000-000000000000	5ac56f10-121e-4214-ad90-5294cf17c9d8	{"action":"user_signedup","actor_id":"e8f48b20-2208-41cf-bb36-211abc62dc82","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-12-17 19:07:18.374611+00	
00000000-0000-0000-0000-000000000000	382feeb8-6086-45c5-a917-33f1b1c3c64e	{"action":"login","actor_id":"e8f48b20-2208-41cf-bb36-211abc62dc82","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-17 19:38:25.307227+00	
00000000-0000-0000-0000-000000000000	8ce4785c-1b9e-432e-88f8-10b17a04ae1d	{"action":"logout","actor_id":"e8f48b20-2208-41cf-bb36-211abc62dc82","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-17 19:39:12.589577+00	
00000000-0000-0000-0000-000000000000	773d8de3-201b-4f4b-9f7e-7a386bd64e09	{"action":"login","actor_id":"e8f48b20-2208-41cf-bb36-211abc62dc82","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-17 19:39:18.407448+00	
00000000-0000-0000-0000-000000000000	78697d4f-7a69-4ba9-b199-c56de884ad98	{"action":"logout","actor_id":"e8f48b20-2208-41cf-bb36-211abc62dc82","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-17 19:40:22.12556+00	
00000000-0000-0000-0000-000000000000	b5dcebb2-1746-4cf7-9104-1a07b09e5a8f	{"action":"user_signedup","actor_id":"5f28dfae-08bb-4784-8c75-b8856322e15c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-19 12:09:49.316904+00	
00000000-0000-0000-0000-000000000000	1c17c078-9839-4f0b-98c0-05bba681d416	{"action":"logout","actor_id":"5f28dfae-08bb-4784-8c75-b8856322e15c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-19 12:14:23.716174+00	
00000000-0000-0000-0000-000000000000	7673369f-5e9d-4161-8421-9abe566ff64a	{"action":"login","actor_id":"5f28dfae-08bb-4784-8c75-b8856322e15c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-19 12:14:32.185336+00	
00000000-0000-0000-0000-000000000000	db524a50-7649-4c1c-abf0-7a755e81aa60	{"action":"logout","actor_id":"5f28dfae-08bb-4784-8c75-b8856322e15c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-19 12:14:53.859715+00	
00000000-0000-0000-0000-000000000000	b0e2f7f3-7f5b-4864-802b-960409da2e1c	{"action":"login","actor_id":"5f28dfae-08bb-4784-8c75-b8856322e15c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-19 12:14:58.896827+00	
00000000-0000-0000-0000-000000000000	3650cece-9a88-41f5-a286-a8df835ab92b	{"action":"logout","actor_id":"5f28dfae-08bb-4784-8c75-b8856322e15c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-19 12:23:35.571485+00	
00000000-0000-0000-0000-000000000000	b9deaf8a-7b9b-4bfa-a1dc-682e0019d10f	{"action":"login","actor_id":"5f28dfae-08bb-4784-8c75-b8856322e15c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-19 14:31:05.166542+00	
00000000-0000-0000-0000-000000000000	5dbc18fb-7c06-4e5e-8b8b-4e14dc3cc73d	{"action":"logout","actor_id":"5f28dfae-08bb-4784-8c75-b8856322e15c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-19 14:33:26.148097+00	
00000000-0000-0000-0000-000000000000	053680dc-d921-46fa-8da1-f0db1ee6b478	{"action":"login","actor_id":"5f28dfae-08bb-4784-8c75-b8856322e15c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-19 23:24:53.443524+00	
00000000-0000-0000-0000-000000000000	838ed515-b213-4fe9-af48-73891537daf7	{"action":"logout","actor_id":"5f28dfae-08bb-4784-8c75-b8856322e15c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-19 23:26:11.285841+00	
00000000-0000-0000-0000-000000000000	cd9ede93-c797-45f3-82af-e8b7bba87b6b	{"action":"login","actor_id":"5f28dfae-08bb-4784-8c75-b8856322e15c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-19 23:26:16.053885+00	
00000000-0000-0000-0000-000000000000	ba251a55-02f1-4aaa-a181-a88eccc3795a	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"5f28dfae-08bb-4784-8c75-b8856322e15c","user_phone":""}}	2025-11-19 23:27:42.273484+00	
00000000-0000-0000-0000-000000000000	a22c49ca-0b09-4e33-8a61-a599f46a3ce2	{"action":"user_signedup","actor_id":"7be0854b-b630-4e18-9e9c-46d07c4f2773","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-19 23:30:46.721361+00	
00000000-0000-0000-0000-000000000000	e68b8e3b-4a00-4011-881c-c44aea588af2	{"action":"token_refreshed","actor_id":"7be0854b-b630-4e18-9e9c-46d07c4f2773","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-20 02:33:31.89067+00	
00000000-0000-0000-0000-000000000000	cb999fe2-6165-4602-bf33-3157f52f09a9	{"action":"token_revoked","actor_id":"7be0854b-b630-4e18-9e9c-46d07c4f2773","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-20 02:33:31.916542+00	
00000000-0000-0000-0000-000000000000	849db8f4-50e6-4acd-b04c-3d007f4c5619	{"action":"token_refreshed","actor_id":"7be0854b-b630-4e18-9e9c-46d07c4f2773","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-20 02:33:36.973043+00	
00000000-0000-0000-0000-000000000000	3be83310-3b8f-4ec0-8404-75b00ee91bc6	{"action":"logout","actor_id":"7be0854b-b630-4e18-9e9c-46d07c4f2773","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-20 02:35:08.108788+00	
00000000-0000-0000-0000-000000000000	5e4c7a56-db36-4ad1-9b53-3b9a74c32635	{"action":"user_recovery_requested","actor_id":"7be0854b-b630-4e18-9e9c-46d07c4f2773","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-20 05:29:22.914526+00	
00000000-0000-0000-0000-000000000000	aaab5760-6e4b-4c53-9420-102f004b0154	{"action":"login","actor_id":"7be0854b-b630-4e18-9e9c-46d07c4f2773","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-20 05:31:07.46702+00	
00000000-0000-0000-0000-000000000000	3e87cf55-3d64-4061-90cf-bc6e64ceed2e	{"action":"user_updated_password","actor_id":"7be0854b-b630-4e18-9e9c-46d07c4f2773","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-20 05:31:29.463257+00	
00000000-0000-0000-0000-000000000000	5187b9df-c0b6-4807-a394-1cdc0fc1284b	{"action":"user_modified","actor_id":"7be0854b-b630-4e18-9e9c-46d07c4f2773","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-20 05:31:29.466505+00	
00000000-0000-0000-0000-000000000000	631872b1-8cac-4815-82f9-5eb5682d5a37	{"action":"logout","actor_id":"7be0854b-b630-4e18-9e9c-46d07c4f2773","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-20 05:31:30.53215+00	
00000000-0000-0000-0000-000000000000	f6d96f67-679c-4676-87cc-39d5dcabf060	{"action":"login","actor_id":"7be0854b-b630-4e18-9e9c-46d07c4f2773","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-20 05:31:46.53103+00	
00000000-0000-0000-0000-000000000000	82d54d81-9220-493c-9907-2e30f60695b4	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"7be0854b-b630-4e18-9e9c-46d07c4f2773","user_phone":""}}	2025-11-20 05:35:05.755354+00	
00000000-0000-0000-0000-000000000000	3f2fc2cc-3b1e-4a76-91b2-e27f61facf40	{"action":"user_signedup","actor_id":"9d590bb8-8337-4b32-bb84-a99274ff4782","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-20 05:36:58.55725+00	
00000000-0000-0000-0000-000000000000	20c754b5-72fe-4ba4-9247-0de8082cf7e3	{"action":"logout","actor_id":"9d590bb8-8337-4b32-bb84-a99274ff4782","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-20 05:38:53.953606+00	
00000000-0000-0000-0000-000000000000	90073a84-95e4-4178-b036-c1620f4c3c3f	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"9d590bb8-8337-4b32-bb84-a99274ff4782","user_phone":""}}	2025-11-20 06:03:43.642283+00	
00000000-0000-0000-0000-000000000000	54496a90-5d3b-4f04-b754-0c4775eb0d5c	{"action":"user_signedup","actor_id":"39d21249-a0c0-4b58-a324-2b1255a5d584","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-20 06:05:45.423432+00	
00000000-0000-0000-0000-000000000000	a81007eb-523c-4dfc-b50d-beb5e4f4158c	{"action":"logout","actor_id":"39d21249-a0c0-4b58-a324-2b1255a5d584","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-20 06:47:25.421204+00	
00000000-0000-0000-0000-000000000000	47e7cc47-a47f-4d03-8268-7ed7237a2c15	{"action":"login","actor_id":"39d21249-a0c0-4b58-a324-2b1255a5d584","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-20 06:47:53.748163+00	
00000000-0000-0000-0000-000000000000	72e9cba1-561b-4e0b-9e3a-187508b26fc4	{"action":"logout","actor_id":"39d21249-a0c0-4b58-a324-2b1255a5d584","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-20 06:50:08.528152+00	
00000000-0000-0000-0000-000000000000	530a3618-ffb2-4b38-92ec-334d43b388ab	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"39d21249-a0c0-4b58-a324-2b1255a5d584","user_phone":""}}	2025-11-20 06:54:10.699353+00	
00000000-0000-0000-0000-000000000000	d1e9b809-a2c7-421c-a444-ef3b3ceaa75c	{"action":"user_signedup","actor_id":"87cfbf7f-e5e7-43c0-ad80-a8c9b6b8c249","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-20 06:56:18.625093+00	
00000000-0000-0000-0000-000000000000	83a9eb75-b85b-4ba5-8ed2-b85810cd1fc2	{"action":"logout","actor_id":"87cfbf7f-e5e7-43c0-ad80-a8c9b6b8c249","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-20 07:12:08.617436+00	
00000000-0000-0000-0000-000000000000	2f40c660-49c4-488c-ac5d-0190d6a9db81	{"action":"login","actor_id":"87cfbf7f-e5e7-43c0-ad80-a8c9b6b8c249","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-20 07:12:41.981935+00	
00000000-0000-0000-0000-000000000000	cce11f02-af07-4488-be85-fd0e0eb3502c	{"action":"logout","actor_id":"87cfbf7f-e5e7-43c0-ad80-a8c9b6b8c249","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-20 07:13:21.065066+00	
00000000-0000-0000-0000-000000000000	6ef00891-aa7b-427a-94d7-418c4774e3d0	{"action":"login","actor_id":"87cfbf7f-e5e7-43c0-ad80-a8c9b6b8c249","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-20 07:13:30.391042+00	
00000000-0000-0000-0000-000000000000	9e615ccc-3475-435c-8172-970179d97fec	{"action":"logout","actor_id":"87cfbf7f-e5e7-43c0-ad80-a8c9b6b8c249","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-20 07:15:09.235211+00	
00000000-0000-0000-0000-000000000000	c507e23c-e629-4686-ab9c-2849264fcba6	{"action":"user_signedup","actor_id":"5376c380-c4e3-4f07-b9ee-a011f4bd7bf4","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-20 07:17:25.506807+00	
00000000-0000-0000-0000-000000000000	309a4dff-a279-4b90-96fa-68fa3ef94851	{"action":"logout","actor_id":"5376c380-c4e3-4f07-b9ee-a011f4bd7bf4","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-20 07:18:58.816519+00	
00000000-0000-0000-0000-000000000000	6c0eb665-a856-4938-bf68-bdc96ace17c9	{"action":"login","actor_id":"87cfbf7f-e5e7-43c0-ad80-a8c9b6b8c249","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-20 07:19:08.090518+00	
00000000-0000-0000-0000-000000000000	8f564844-9c94-4241-8a0b-5354b02cdfd6	{"action":"logout","actor_id":"87cfbf7f-e5e7-43c0-ad80-a8c9b6b8c249","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-20 07:19:49.783687+00	
00000000-0000-0000-0000-000000000000	bb19269b-bd49-46c3-8a75-e0a285a3792d	{"action":"login","actor_id":"5376c380-c4e3-4f07-b9ee-a011f4bd7bf4","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-20 07:20:00.785194+00	
00000000-0000-0000-0000-000000000000	318b8726-0106-4d57-b7d2-3e5b399a9e0f	{"action":"user_recovery_requested","actor_id":"87cfbf7f-e5e7-43c0-ad80-a8c9b6b8c249","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-20 09:18:43.418443+00	
00000000-0000-0000-0000-000000000000	919162e4-08c1-4234-a835-cccd8a5c2191	{"action":"login","actor_id":"87cfbf7f-e5e7-43c0-ad80-a8c9b6b8c249","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-20 09:19:34.571999+00	
00000000-0000-0000-0000-000000000000	2640b6e6-da35-4e2f-a239-448803bb3546	{"action":"user_updated_password","actor_id":"87cfbf7f-e5e7-43c0-ad80-a8c9b6b8c249","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-20 09:19:48.999982+00	
00000000-0000-0000-0000-000000000000	73caba26-902c-4391-adac-8e2cb5e0a8ea	{"action":"user_modified","actor_id":"87cfbf7f-e5e7-43c0-ad80-a8c9b6b8c249","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-20 09:19:49.000978+00	
00000000-0000-0000-0000-000000000000	2de9a0c9-55a3-4664-9e81-a8f19551e99d	{"action":"logout","actor_id":"87cfbf7f-e5e7-43c0-ad80-a8c9b6b8c249","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-20 09:19:49.980542+00	
00000000-0000-0000-0000-000000000000	ba3256aa-3a23-423f-9b15-39af49af46a4	{"action":"login","actor_id":"87cfbf7f-e5e7-43c0-ad80-a8c9b6b8c249","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-20 09:19:56.758382+00	
00000000-0000-0000-0000-000000000000	ae810526-0170-47a0-85b6-fe6e4e923584	{"action":"logout","actor_id":"87cfbf7f-e5e7-43c0-ad80-a8c9b6b8c249","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-20 09:24:31.685341+00	
00000000-0000-0000-0000-000000000000	f0ab7c0f-1ed5-4df3-81dd-26a9ec7c4a57	{"action":"login","actor_id":"87cfbf7f-e5e7-43c0-ad80-a8c9b6b8c249","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-20 09:59:16.01523+00	
00000000-0000-0000-0000-000000000000	96e97c3b-8f8b-43e5-ba24-a5aaded878bd	{"action":"logout","actor_id":"87cfbf7f-e5e7-43c0-ad80-a8c9b6b8c249","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-20 10:02:18.146396+00	
00000000-0000-0000-0000-000000000000	5f214ac2-eda9-473a-b8a5-a856316b1b1c	{"action":"token_refreshed","actor_id":"5376c380-c4e3-4f07-b9ee-a011f4bd7bf4","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-20 17:58:23.217002+00	
00000000-0000-0000-0000-000000000000	4e4ab39d-2a6e-4976-b7ba-8d929cc1738d	{"action":"token_revoked","actor_id":"5376c380-c4e3-4f07-b9ee-a011f4bd7bf4","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-20 17:58:23.243367+00	
00000000-0000-0000-0000-000000000000	e7af5cd6-8e40-404f-9cc6-39e22df4d457	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"5376c380-c4e3-4f07-b9ee-a011f4bd7bf4","user_phone":""}}	2025-11-20 18:04:23.464852+00	
00000000-0000-0000-0000-000000000000	a90f5746-c6d6-4e96-a288-d01e9e0134f5	{"action":"user_signedup","actor_id":"03ad2d25-ea2e-4811-9793-c0e9d869327e","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-20 18:07:01.242721+00	
00000000-0000-0000-0000-000000000000	7f7b2e40-8efc-4dad-80b4-47060ed62058	{"action":"token_refreshed","actor_id":"03ad2d25-ea2e-4811-9793-c0e9d869327e","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-20 22:11:05.113984+00	
00000000-0000-0000-0000-000000000000	113a5f23-bdd0-42c5-9822-4462243426a7	{"action":"token_revoked","actor_id":"03ad2d25-ea2e-4811-9793-c0e9d869327e","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-20 22:11:05.144753+00	
00000000-0000-0000-0000-000000000000	5143d8ab-06eb-4916-9ad9-10d1ae1b69ca	{"action":"token_refreshed","actor_id":"03ad2d25-ea2e-4811-9793-c0e9d869327e","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-20 22:11:14.062622+00	
00000000-0000-0000-0000-000000000000	70c9350d-0dee-4e4e-8bd5-85af9600963e	{"action":"token_refreshed","actor_id":"03ad2d25-ea2e-4811-9793-c0e9d869327e","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-20 22:14:34.076296+00	
00000000-0000-0000-0000-000000000000	f5357d94-984b-4f86-9348-edc367be260b	{"action":"token_refreshed","actor_id":"03ad2d25-ea2e-4811-9793-c0e9d869327e","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-20 22:14:43.315204+00	
00000000-0000-0000-0000-000000000000	b3395bf7-078a-4830-a159-557b2d55fea4	{"action":"token_refreshed","actor_id":"03ad2d25-ea2e-4811-9793-c0e9d869327e","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-20 22:23:14.159336+00	
00000000-0000-0000-0000-000000000000	6ae66e92-3e9f-48da-9a66-6ca167cf2881	{"action":"token_refreshed","actor_id":"03ad2d25-ea2e-4811-9793-c0e9d869327e","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-20 22:23:26.334299+00	
00000000-0000-0000-0000-000000000000	d0425239-3615-408f-ac6c-3d8fab3267a7	{"action":"login","actor_id":"87cfbf7f-e5e7-43c0-ad80-a8c9b6b8c249","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-21 03:19:29.657648+00	
00000000-0000-0000-0000-000000000000	cbc6e174-ff11-4f0b-b7b7-d8ba84679968	{"action":"logout","actor_id":"87cfbf7f-e5e7-43c0-ad80-a8c9b6b8c249","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-21 03:23:09.888365+00	
00000000-0000-0000-0000-000000000000	530e206e-511a-4145-99fe-f7d74f73d69b	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"03ad2d25-ea2e-4811-9793-c0e9d869327e","user_phone":""}}	2025-11-21 03:35:17.773025+00	
00000000-0000-0000-0000-000000000000	4ae07267-c5a3-49fb-b872-ef29d35e35c5	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"87cfbf7f-e5e7-43c0-ad80-a8c9b6b8c249","user_phone":""}}	2025-11-21 03:35:17.77025+00	
00000000-0000-0000-0000-000000000000	0377d4e4-96ed-4ddc-9f1a-578d21d39059	{"action":"user_signedup","actor_id":"88e69fbb-c8c2-4c5a-9545-e7ac97acd5ef","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-21 03:39:08.546997+00	
00000000-0000-0000-0000-000000000000	6b8c1e9d-6e55-4d90-8485-7c6d10571226	{"action":"logout","actor_id":"88e69fbb-c8c2-4c5a-9545-e7ac97acd5ef","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-21 03:40:55.589099+00	
00000000-0000-0000-0000-000000000000	a7ab82ea-3bf2-44c1-9e2f-15a3504b2978	{"action":"user_recovery_requested","actor_id":"88e69fbb-c8c2-4c5a-9545-e7ac97acd5ef","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-21 12:03:16.65494+00	
00000000-0000-0000-0000-000000000000	2174106c-394a-4008-94cd-28245f84f086	{"action":"login","actor_id":"88e69fbb-c8c2-4c5a-9545-e7ac97acd5ef","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-21 12:06:34.143403+00	
00000000-0000-0000-0000-000000000000	2320cdf9-4236-472d-801c-2d8091a7a67f	{"action":"user_updated_password","actor_id":"88e69fbb-c8c2-4c5a-9545-e7ac97acd5ef","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-21 12:06:47.581611+00	
00000000-0000-0000-0000-000000000000	3edc290e-2f29-47d2-b325-887e901b3b8a	{"action":"user_modified","actor_id":"88e69fbb-c8c2-4c5a-9545-e7ac97acd5ef","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-21 12:06:47.58394+00	
00000000-0000-0000-0000-000000000000	7712b93f-4bb9-43aa-bffd-ba782e552a82	{"action":"logout","actor_id":"88e69fbb-c8c2-4c5a-9545-e7ac97acd5ef","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-21 12:06:52.719736+00	
00000000-0000-0000-0000-000000000000	1348f2da-7619-461a-8e53-c0ed366c01f2	{"action":"login","actor_id":"88e69fbb-c8c2-4c5a-9545-e7ac97acd5ef","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-21 12:07:07.698903+00	
00000000-0000-0000-0000-000000000000	023431fb-512b-4ef7-b711-c1a36ff394b3	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"88e69fbb-c8c2-4c5a-9545-e7ac97acd5ef","user_phone":""}}	2025-11-21 14:20:42.095646+00	
00000000-0000-0000-0000-000000000000	7198582b-b606-467d-9065-7e1aac2c4019	{"action":"user_signedup","actor_id":"8d11be17-8d73-4fc4-815d-f5971e7e8d8f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-21 14:23:36.076892+00	
00000000-0000-0000-0000-000000000000	c2a19948-44ff-46de-adcb-c726b3d06fb1	{"action":"logout","actor_id":"8d11be17-8d73-4fc4-815d-f5971e7e8d8f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-21 14:29:34.979634+00	
00000000-0000-0000-0000-000000000000	3afe0bfb-54df-45ab-9dab-c6cf01ec876f	{"action":"login","actor_id":"8d11be17-8d73-4fc4-815d-f5971e7e8d8f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-21 14:29:44.384988+00	
00000000-0000-0000-0000-000000000000	9690f455-27b7-4ae4-8c38-fb56b628a6e5	{"action":"logout","actor_id":"8d11be17-8d73-4fc4-815d-f5971e7e8d8f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-21 14:43:27.244347+00	
00000000-0000-0000-0000-000000000000	4a167efc-a2aa-4552-abe5-ca0d13855091	{"action":"login","actor_id":"8d11be17-8d73-4fc4-815d-f5971e7e8d8f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-21 14:45:56.712117+00	
00000000-0000-0000-0000-000000000000	505e0ad1-35df-4efb-9d8a-7f5b943782f3	{"action":"logout","actor_id":"8d11be17-8d73-4fc4-815d-f5971e7e8d8f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-21 15:02:50.785538+00	
00000000-0000-0000-0000-000000000000	6cdf61d9-c370-4119-a437-2b8ecfb391a5	{"action":"login","actor_id":"8d11be17-8d73-4fc4-815d-f5971e7e8d8f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-21 15:03:05.338042+00	
00000000-0000-0000-0000-000000000000	5e2f61ce-ea76-461a-9cbe-745d0ad4e098	{"action":"logout","actor_id":"8d11be17-8d73-4fc4-815d-f5971e7e8d8f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-21 15:33:49.103033+00	
00000000-0000-0000-0000-000000000000	0e9b89f7-ed67-4be1-97d5-006dd666fc0c	{"action":"user_signedup","actor_id":"fab60b11-c2a4-484f-a226-8ced22a87254","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-21 15:36:00.399342+00	
00000000-0000-0000-0000-000000000000	3a222724-0f93-4537-983d-d42331f6411f	{"action":"logout","actor_id":"fab60b11-c2a4-484f-a226-8ced22a87254","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-21 15:41:55.911319+00	
00000000-0000-0000-0000-000000000000	5cb13418-daa7-463d-aa57-8d66da94436d	{"action":"login","actor_id":"fab60b11-c2a4-484f-a226-8ced22a87254","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-21 15:42:15.354433+00	
00000000-0000-0000-0000-000000000000	734c3799-ed4c-41e7-92e1-50206856291a	{"action":"logout","actor_id":"fab60b11-c2a4-484f-a226-8ced22a87254","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-21 15:42:24.407468+00	
00000000-0000-0000-0000-000000000000	5d414da4-9ce9-427d-ae60-b089ec33c654	{"action":"login","actor_id":"fab60b11-c2a4-484f-a226-8ced22a87254","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-21 15:42:29.144354+00	
00000000-0000-0000-0000-000000000000	41d63f7f-66c7-4675-8c32-f82ff0366596	{"action":"logout","actor_id":"fab60b11-c2a4-484f-a226-8ced22a87254","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-21 15:51:22.378546+00	
00000000-0000-0000-0000-000000000000	3c22543a-596d-4fcb-ae99-f38dc9f36d00	{"action":"login","actor_id":"fab60b11-c2a4-484f-a226-8ced22a87254","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-21 15:51:52.574838+00	
00000000-0000-0000-0000-000000000000	966d3e4b-c0b3-4efa-862c-cff44fc9b683	{"action":"logout","actor_id":"fab60b11-c2a4-484f-a226-8ced22a87254","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-21 15:54:17.817917+00	
00000000-0000-0000-0000-000000000000	4b64e6f5-ef34-411f-ac03-960eb86a778e	{"action":"login","actor_id":"fab60b11-c2a4-484f-a226-8ced22a87254","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-22 01:15:45.792304+00	
00000000-0000-0000-0000-000000000000	a55780c3-42d9-4e55-a671-54f16fc4fcd8	{"action":"logout","actor_id":"fab60b11-c2a4-484f-a226-8ced22a87254","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-22 01:49:57.244124+00	
00000000-0000-0000-0000-000000000000	0836081f-c48c-4af4-805c-5a79d1ac0db4	{"action":"login","actor_id":"fab60b11-c2a4-484f-a226-8ced22a87254","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-22 01:50:35.001915+00	
00000000-0000-0000-0000-000000000000	f15c6aa8-a8f2-4cc1-b3d7-11fb4bcc1b61	{"action":"logout","actor_id":"fab60b11-c2a4-484f-a226-8ced22a87254","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-22 02:00:47.747099+00	
00000000-0000-0000-0000-000000000000	3986745f-1437-4c8e-aa67-ce320fb87290	{"action":"login","actor_id":"fab60b11-c2a4-484f-a226-8ced22a87254","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-22 02:00:59.669203+00	
00000000-0000-0000-0000-000000000000	f91e9722-8733-43e8-a12a-5c74d8cea226	{"action":"logout","actor_id":"fab60b11-c2a4-484f-a226-8ced22a87254","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-22 02:01:18.429939+00	
00000000-0000-0000-0000-000000000000	5efbc70f-cba0-4d02-a92a-e4ea44c73158	{"action":"login","actor_id":"fab60b11-c2a4-484f-a226-8ced22a87254","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-22 02:01:23.330348+00	
00000000-0000-0000-0000-000000000000	b9d1e395-498f-46bf-b823-bb27a2acf545	{"action":"logout","actor_id":"fab60b11-c2a4-484f-a226-8ced22a87254","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-22 02:01:41.965638+00	
00000000-0000-0000-0000-000000000000	a6541199-f016-4e87-90c2-f0ccded63887	{"action":"login","actor_id":"fab60b11-c2a4-484f-a226-8ced22a87254","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-22 02:01:50.411445+00	
00000000-0000-0000-0000-000000000000	6163c80a-d3c8-4b47-b006-ed5eda41297a	{"action":"logout","actor_id":"fab60b11-c2a4-484f-a226-8ced22a87254","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-22 02:11:04.82823+00	
00000000-0000-0000-0000-000000000000	1f972b5b-94ea-4487-bfa9-0eafd881ad28	{"action":"login","actor_id":"fab60b11-c2a4-484f-a226-8ced22a87254","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-22 03:01:44.689427+00	
00000000-0000-0000-0000-000000000000	342ecab3-039f-4d6e-a74b-bce4f8cdb6b4	{"action":"logout","actor_id":"fab60b11-c2a4-484f-a226-8ced22a87254","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-22 03:03:20.883357+00	
00000000-0000-0000-0000-000000000000	ee311671-fe12-454e-8afe-052d17140a8b	{"action":"login","actor_id":"fab60b11-c2a4-484f-a226-8ced22a87254","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-22 03:03:31.849062+00	
00000000-0000-0000-0000-000000000000	c6bd1fa2-3a72-43ca-8d67-b66971e77110	{"action":"logout","actor_id":"fab60b11-c2a4-484f-a226-8ced22a87254","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-22 03:05:20.055048+00	
00000000-0000-0000-0000-000000000000	e38d5c40-2cec-4e2b-821f-4d6de5b682ae	{"action":"login","actor_id":"fab60b11-c2a4-484f-a226-8ced22a87254","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-22 03:05:24.860483+00	
00000000-0000-0000-0000-000000000000	896cdf4c-9979-421f-b7de-72fb46449d30	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"8d11be17-8d73-4fc4-815d-f5971e7e8d8f","user_phone":""}}	2025-11-22 03:10:53.734971+00	
00000000-0000-0000-0000-000000000000	87398c77-e640-4988-87e0-c2fc6420ad89	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"fab60b11-c2a4-484f-a226-8ced22a87254","user_phone":""}}	2025-11-22 03:10:53.735249+00	
00000000-0000-0000-0000-000000000000	ca330f66-c4ef-4254-9ac2-546059e444a2	{"action":"user_signedup","actor_id":"4098eb90-c4e9-46cd-bcb4-205695741b60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-22 03:14:52.536728+00	
00000000-0000-0000-0000-000000000000	0c4bb8d7-4344-4b09-b178-62267b1f83cf	{"action":"logout","actor_id":"4098eb90-c4e9-46cd-bcb4-205695741b60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-22 03:17:46.061736+00	
00000000-0000-0000-0000-000000000000	35bf1325-9453-4381-9f18-d9103a2b92aa	{"action":"login","actor_id":"4098eb90-c4e9-46cd-bcb4-205695741b60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-22 03:17:56.462124+00	
00000000-0000-0000-0000-000000000000	516546c2-fef9-47ec-8613-83dfb7aa1c90	{"action":"logout","actor_id":"4098eb90-c4e9-46cd-bcb4-205695741b60","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-22 03:20:24.609582+00	
00000000-0000-0000-0000-000000000000	53d3ad24-d145-4906-bbbe-4802a88a70eb	{"action":"user_signedup","actor_id":"71247e48-5878-437b-aff3-24e79061fa6e","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-22 03:21:49.314686+00	
00000000-0000-0000-0000-000000000000	857d9530-3f82-419b-9a2a-a7f48e8ccc02	{"action":"token_refreshed","actor_id":"71247e48-5878-437b-aff3-24e79061fa6e","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-22 04:22:11.422812+00	
00000000-0000-0000-0000-000000000000	34d1168f-dbfe-43ab-8960-1afbd6e5c0d1	{"action":"token_revoked","actor_id":"71247e48-5878-437b-aff3-24e79061fa6e","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-22 04:22:11.453916+00	
00000000-0000-0000-0000-000000000000	d53fe11b-273f-4604-a6dd-87ae50088367	{"action":"logout","actor_id":"71247e48-5878-437b-aff3-24e79061fa6e","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-22 04:27:07.172789+00	
00000000-0000-0000-0000-000000000000	38e937c5-fa8a-4766-bf71-20c7ce0e278d	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"71247e48-5878-437b-aff3-24e79061fa6e","user_phone":""}}	2025-11-22 04:29:54.137473+00	
00000000-0000-0000-0000-000000000000	85ead3d6-b0e0-41ad-845b-1e2d1a6d5f9e	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"4098eb90-c4e9-46cd-bcb4-205695741b60","user_phone":""}}	2025-11-22 04:29:54.137641+00	
00000000-0000-0000-0000-000000000000	5d3ac766-9fe6-493a-9109-a6acdc308e26	{"action":"user_signedup","actor_id":"7d958451-c97b-4569-a302-8adf5dec5d20","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-22 04:36:14.952451+00	
00000000-0000-0000-0000-000000000000	fe0e9e53-7e01-4266-b206-34e66362a443	{"action":"logout","actor_id":"7d958451-c97b-4569-a302-8adf5dec5d20","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-22 04:41:09.455336+00	
00000000-0000-0000-0000-000000000000	f659a91c-19d0-4af4-8d0d-2e427317fd26	{"action":"login","actor_id":"7d958451-c97b-4569-a302-8adf5dec5d20","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-22 04:41:42.521778+00	
00000000-0000-0000-0000-000000000000	eba10780-68d5-459b-9640-d81c7f853e54	{"action":"token_refreshed","actor_id":"7d958451-c97b-4569-a302-8adf5dec5d20","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-22 05:40:15.821638+00	
00000000-0000-0000-0000-000000000000	967cbf2f-5e6e-49a9-8d48-0b34f6934843	{"action":"token_revoked","actor_id":"7d958451-c97b-4569-a302-8adf5dec5d20","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-22 05:40:15.85358+00	
00000000-0000-0000-0000-000000000000	3117eb6f-cabb-442a-a427-03e6bc0c6ec8	{"action":"logout","actor_id":"7d958451-c97b-4569-a302-8adf5dec5d20","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-22 05:44:29.760282+00	
00000000-0000-0000-0000-000000000000	8594deaa-ef5b-4bca-8657-9c661dc5786e	{"action":"login","actor_id":"7d958451-c97b-4569-a302-8adf5dec5d20","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-22 05:44:52.621997+00	
00000000-0000-0000-0000-000000000000	b16c6c25-4144-4718-ab04-200fec0cd40e	{"action":"logout","actor_id":"7d958451-c97b-4569-a302-8adf5dec5d20","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-22 05:46:41.126461+00	
00000000-0000-0000-0000-000000000000	e877675a-4ed6-4903-abeb-db6fc816313f	{"action":"login","actor_id":"7d958451-c97b-4569-a302-8adf5dec5d20","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-22 09:09:27.367845+00	
00000000-0000-0000-0000-000000000000	2d6a7c28-a7c5-4db1-9db2-c1e4f6eb84fd	{"action":"token_refreshed","actor_id":"7d958451-c97b-4569-a302-8adf5dec5d20","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-22 10:16:37.401191+00	
00000000-0000-0000-0000-000000000000	e15fcf41-8d9b-4bf4-8025-c4a9e6b1a221	{"action":"token_revoked","actor_id":"7d958451-c97b-4569-a302-8adf5dec5d20","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-22 10:16:37.421371+00	
00000000-0000-0000-0000-000000000000	121586aa-5e0d-4748-b877-8f3df7c86340	{"action":"logout","actor_id":"7d958451-c97b-4569-a302-8adf5dec5d20","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-22 10:16:41.727983+00	
00000000-0000-0000-0000-000000000000	1ae5e677-fccb-4394-9e0d-3e410ce14b8a	{"action":"login","actor_id":"7d958451-c97b-4569-a302-8adf5dec5d20","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-22 10:17:43.348039+00	
00000000-0000-0000-0000-000000000000	94e0f608-900d-493b-b60b-08ec2d2b9c06	{"action":"logout","actor_id":"7d958451-c97b-4569-a302-8adf5dec5d20","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-22 10:18:37.670377+00	
00000000-0000-0000-0000-000000000000	ec945182-39cf-43b3-ba5f-c34d1311b6fd	{"action":"login","actor_id":"7d958451-c97b-4569-a302-8adf5dec5d20","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-22 10:18:42.975151+00	
00000000-0000-0000-0000-000000000000	1734dd1a-6e1f-49bb-9877-2b401fc6c7bd	{"action":"logout","actor_id":"7d958451-c97b-4569-a302-8adf5dec5d20","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-22 10:19:12.810311+00	
00000000-0000-0000-0000-000000000000	bcdda41a-a4b5-4584-bdf8-9d3e9fa221c3	{"action":"login","actor_id":"7d958451-c97b-4569-a302-8adf5dec5d20","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-22 10:35:30.781787+00	
00000000-0000-0000-0000-000000000000	aec05df1-ed8a-4804-ab15-a29e98034caa	{"action":"logout","actor_id":"7d958451-c97b-4569-a302-8adf5dec5d20","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-22 10:36:04.395865+00	
00000000-0000-0000-0000-000000000000	55528df2-de9e-4e96-97a1-0f0734109962	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"7d958451-c97b-4569-a302-8adf5dec5d20","user_phone":""}}	2025-11-22 10:38:05.234851+00	
00000000-0000-0000-0000-000000000000	2a615146-74e4-4b51-ba9b-9ac8c51ceba4	{"action":"user_signedup","actor_id":"53ca037a-b85d-4805-88e9-f57d62a39cc3","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-22 10:40:31.318005+00	
00000000-0000-0000-0000-000000000000	370a26b2-282b-40fa-ac57-fc8c2ba66e50	{"action":"logout","actor_id":"53ca037a-b85d-4805-88e9-f57d62a39cc3","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-22 11:00:28.898444+00	
00000000-0000-0000-0000-000000000000	6f3fd251-26d3-41e9-9c99-e9e8b2f333b3	{"action":"login","actor_id":"53ca037a-b85d-4805-88e9-f57d62a39cc3","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-22 11:00:40.333751+00	
00000000-0000-0000-0000-000000000000	135ec92b-2e5d-43d4-9f04-e205d4a9d0bd	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"53ca037a-b85d-4805-88e9-f57d62a39cc3","user_phone":""}}	2025-11-22 13:43:42.791322+00	
00000000-0000-0000-0000-000000000000	39589086-b476-4c4b-bfe5-b8e3781a4e0a	{"action":"user_signedup","actor_id":"1d727f21-abd0-4e6a-a7f3-ca76c3cc73f1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-22 13:45:35.081445+00	
00000000-0000-0000-0000-000000000000	70f2a604-fee2-4680-918d-b4f200f3d4cf	{"action":"logout","actor_id":"1d727f21-abd0-4e6a-a7f3-ca76c3cc73f1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-22 13:48:47.151814+00	
00000000-0000-0000-0000-000000000000	7289e414-bc57-4e56-b76b-e6727deab412	{"action":"login","actor_id":"1d727f21-abd0-4e6a-a7f3-ca76c3cc73f1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-22 13:48:55.247897+00	
00000000-0000-0000-0000-000000000000	f5bf94d1-76aa-4aa6-8c8b-28a420d16f29	{"action":"logout","actor_id":"1d727f21-abd0-4e6a-a7f3-ca76c3cc73f1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-22 13:49:20.604516+00	
00000000-0000-0000-0000-000000000000	c920a985-12ef-4fa5-a981-f334d11afde3	{"action":"user_signedup","actor_id":"ea905355-d6a3-469f-8bd6-4bee14d23287","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-22 13:50:53.906231+00	
00000000-0000-0000-0000-000000000000	9b89afc7-2d5e-4537-8ec0-28ee834ba2d1	{"action":"logout","actor_id":"ea905355-d6a3-469f-8bd6-4bee14d23287","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-22 13:53:15.07471+00	
00000000-0000-0000-0000-000000000000	d3a69d60-ca40-4169-a181-2d1176538859	{"action":"login","actor_id":"1d727f21-abd0-4e6a-a7f3-ca76c3cc73f1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-22 13:53:31.231862+00	
00000000-0000-0000-0000-000000000000	e40b46dc-bc2b-42c7-aaf0-ec71057c1413	{"action":"logout","actor_id":"1d727f21-abd0-4e6a-a7f3-ca76c3cc73f1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-22 14:06:38.021433+00	
00000000-0000-0000-0000-000000000000	798204da-e799-473e-a4c1-055e4a289770	{"action":"login","actor_id":"1d727f21-abd0-4e6a-a7f3-ca76c3cc73f1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-23 04:07:48.233961+00	
00000000-0000-0000-0000-000000000000	7a8e99a4-dd9c-48c6-ae33-36be3bb51efe	{"action":"token_refreshed","actor_id":"1d727f21-abd0-4e6a-a7f3-ca76c3cc73f1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-23 05:18:41.417659+00	
00000000-0000-0000-0000-000000000000	6e1364b1-acb1-4a48-8bfb-f92975f2cab0	{"action":"token_revoked","actor_id":"1d727f21-abd0-4e6a-a7f3-ca76c3cc73f1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-23 05:18:41.425584+00	
00000000-0000-0000-0000-000000000000	5aa2d69f-dcd2-40a3-9120-2b8c055260e0	{"action":"logout","actor_id":"1d727f21-abd0-4e6a-a7f3-ca76c3cc73f1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-23 05:18:42.301822+00	
00000000-0000-0000-0000-000000000000	0f2af852-ebd7-4472-9014-f907d5a878a4	{"action":"login","actor_id":"1d727f21-abd0-4e6a-a7f3-ca76c3cc73f1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-23 05:18:59.683477+00	
00000000-0000-0000-0000-000000000000	0d80f746-82b3-465a-9a18-8a4b83d3f7ea	{"action":"user_recovery_requested","actor_id":"1d727f21-abd0-4e6a-a7f3-ca76c3cc73f1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-23 06:56:56.141069+00	
00000000-0000-0000-0000-000000000000	7935713e-1a41-4bb9-9309-15d9e4b77a76	{"action":"user_updated_password","actor_id":"1d727f21-abd0-4e6a-a7f3-ca76c3cc73f1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-23 06:57:55.188338+00	
00000000-0000-0000-0000-000000000000	410e409e-ef1d-4ca8-ab63-3f4a9207bfcf	{"action":"user_modified","actor_id":"1d727f21-abd0-4e6a-a7f3-ca76c3cc73f1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-23 06:57:55.192392+00	
00000000-0000-0000-0000-000000000000	305210c7-2472-4dcd-9e4a-bc2eec5cad4f	{"action":"logout","actor_id":"1d727f21-abd0-4e6a-a7f3-ca76c3cc73f1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-23 06:57:56.43697+00	
00000000-0000-0000-0000-000000000000	aee10afe-121f-4fbd-90af-3d333a185b82	{"action":"login","actor_id":"1d727f21-abd0-4e6a-a7f3-ca76c3cc73f1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-23 06:58:11.464693+00	
00000000-0000-0000-0000-000000000000	870dd00c-2c14-4292-a713-bd29c6ed3fab	{"action":"logout","actor_id":"1d727f21-abd0-4e6a-a7f3-ca76c3cc73f1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-23 07:01:24.515336+00	
00000000-0000-0000-0000-000000000000	074285f5-55d5-4472-ac0d-6abcfb3236b9	{"action":"login","actor_id":"1d727f21-abd0-4e6a-a7f3-ca76c3cc73f1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-23 07:27:01.103251+00	
00000000-0000-0000-0000-000000000000	3d3aa362-149e-48a4-986e-81a2073ef5e0	{"action":"login","actor_id":"ea905355-d6a3-469f-8bd6-4bee14d23287","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-23 09:50:12.578619+00	
00000000-0000-0000-0000-000000000000	17b0edef-8887-42ba-8986-1118d6a3d593	{"action":"token_refreshed","actor_id":"ea905355-d6a3-469f-8bd6-4bee14d23287","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-23 18:06:51.826346+00	
00000000-0000-0000-0000-000000000000	21493eb3-1157-4115-9c54-e86f9cd616b8	{"action":"token_revoked","actor_id":"ea905355-d6a3-469f-8bd6-4bee14d23287","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-23 18:06:51.847643+00	
00000000-0000-0000-0000-000000000000	6098400a-01a6-422b-b5bb-0d2819f46a8e	{"action":"token_refreshed","actor_id":"ea905355-d6a3-469f-8bd6-4bee14d23287","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-23 18:06:55.394811+00	
00000000-0000-0000-0000-000000000000	7f535683-c16e-4c31-9c91-87d9ce284e87	{"action":"token_refreshed","actor_id":"ea905355-d6a3-469f-8bd6-4bee14d23287","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-23 20:29:12.441383+00	
00000000-0000-0000-0000-000000000000	04240cdd-ec15-4efb-9d65-015ad032430d	{"action":"token_refreshed","actor_id":"ea905355-d6a3-469f-8bd6-4bee14d23287","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-23 20:29:30.364819+00	
00000000-0000-0000-0000-000000000000	3b03914d-d429-4157-ac6d-2f7031acec1d	{"action":"token_refreshed","actor_id":"ea905355-d6a3-469f-8bd6-4bee14d23287","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-24 04:40:43.107479+00	
00000000-0000-0000-0000-000000000000	1e78e000-bdfa-490d-8df2-e2dad4ccf3cf	{"action":"token_refreshed","actor_id":"ea905355-d6a3-469f-8bd6-4bee14d23287","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-24 08:52:14.635611+00	
00000000-0000-0000-0000-000000000000	c59fa870-681a-4183-8e5f-119f3eb0e766	{"action":"token_revoked","actor_id":"ea905355-d6a3-469f-8bd6-4bee14d23287","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-24 08:52:14.662444+00	
00000000-0000-0000-0000-000000000000	702b005c-48bd-474b-89f1-9b8ba25dcb38	{"action":"logout","actor_id":"ea905355-d6a3-469f-8bd6-4bee14d23287","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-24 08:52:37.570746+00	
00000000-0000-0000-0000-000000000000	20ab2432-ea49-496c-83ca-14483b1e5ca9	{"action":"login","actor_id":"ea905355-d6a3-469f-8bd6-4bee14d23287","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-24 08:52:53.11218+00	
00000000-0000-0000-0000-000000000000	c5cc7493-ad2e-4df0-9e76-eb2d74db02c6	{"action":"logout","actor_id":"ea905355-d6a3-469f-8bd6-4bee14d23287","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-24 09:16:42.99621+00	
00000000-0000-0000-0000-000000000000	1b2c587e-ef4e-424f-9ac8-7cd6565bb86a	{"action":"user_signedup","actor_id":"ce3402df-944f-4f27-8313-02d1ea8d60be","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-24 09:58:17.225909+00	
00000000-0000-0000-0000-000000000000	5ae67699-1460-44aa-9af5-f851319c3386	{"action":"logout","actor_id":"ce3402df-944f-4f27-8313-02d1ea8d60be","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-24 10:02:54.326782+00	
00000000-0000-0000-0000-000000000000	8d472d2a-c7f8-4e2e-81a4-e8be385ac383	{"action":"login","actor_id":"ce3402df-944f-4f27-8313-02d1ea8d60be","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-24 10:03:36.61398+00	
00000000-0000-0000-0000-000000000000	3bd96d3e-ce2a-43c1-9a75-68abdc5a713b	{"action":"logout","actor_id":"ce3402df-944f-4f27-8313-02d1ea8d60be","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-24 10:03:43.796039+00	
00000000-0000-0000-0000-000000000000	345422f4-afae-400d-b304-edca11a514cd	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"ce3402df-944f-4f27-8313-02d1ea8d60be","user_phone":""}}	2025-11-24 10:50:05.722811+00	
00000000-0000-0000-0000-000000000000	03211fc1-61da-4552-a344-66b1681ffd8c	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"1d727f21-abd0-4e6a-a7f3-ca76c3cc73f1","user_phone":""}}	2025-11-24 10:50:05.725218+00	
00000000-0000-0000-0000-000000000000	7672ce5d-4292-442b-9ac0-d623c08576e8	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"ea905355-d6a3-469f-8bd6-4bee14d23287","user_phone":""}}	2025-11-24 10:50:05.876736+00	
00000000-0000-0000-0000-000000000000	257e0517-68bb-478a-bf3d-cff62d044741	{"action":"user_signedup","actor_id":"8d681e75-b43b-41b6-a287-5bbf5fd311a7","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-24 10:54:55.340465+00	
00000000-0000-0000-0000-000000000000	0e5e0db5-56b6-4ffe-a89b-da14aba7f0fd	{"action":"logout","actor_id":"8d681e75-b43b-41b6-a287-5bbf5fd311a7","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-24 10:59:29.025841+00	
00000000-0000-0000-0000-000000000000	8848fd5b-e2e8-4367-b92c-306ed81256d3	{"action":"user_signedup","actor_id":"087a8572-3181-4e0a-8476-68710a37df29","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-24 11:00:43.705998+00	
00000000-0000-0000-0000-000000000000	17d99854-ee9c-4f90-ac3d-9e4594704a8a	{"action":"logout","actor_id":"087a8572-3181-4e0a-8476-68710a37df29","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-24 11:03:02.381376+00	
00000000-0000-0000-0000-000000000000	ab8b4fcc-c6a4-475b-baea-b4ea49ff0ec2	{"action":"login","actor_id":"8d681e75-b43b-41b6-a287-5bbf5fd311a7","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-25 02:13:17.624095+00	
00000000-0000-0000-0000-000000000000	956f6af2-da35-4c93-af9a-71670b5ce5dc	{"action":"logout","actor_id":"8d681e75-b43b-41b6-a287-5bbf5fd311a7","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-25 02:17:55.425525+00	
00000000-0000-0000-0000-000000000000	aa6b3a96-de98-4511-9016-41baaf819258	{"action":"login","actor_id":"8d681e75-b43b-41b6-a287-5bbf5fd311a7","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-25 02:18:00.812942+00	
00000000-0000-0000-0000-000000000000	c181a1a1-9e6c-444c-a7ab-21185e68363f	{"action":"logout","actor_id":"8d681e75-b43b-41b6-a287-5bbf5fd311a7","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-25 02:19:19.840188+00	
00000000-0000-0000-0000-000000000000	cf1916d0-099d-4df2-90c8-065ba9def322	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"087a8572-3181-4e0a-8476-68710a37df29","user_phone":""}}	2025-11-25 02:20:27.552569+00	
00000000-0000-0000-0000-000000000000	b2ec1ac7-25d6-4d00-a4e6-e95b49815a1b	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"8d681e75-b43b-41b6-a287-5bbf5fd311a7","user_phone":""}}	2025-11-25 02:20:27.76207+00	
00000000-0000-0000-0000-000000000000	af9c0c56-476b-4278-b064-2ff97d389191	{"action":"user_signedup","actor_id":"82b26860-3162-48c5-9edc-14c06780dbac","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-25 02:23:45.099386+00	
00000000-0000-0000-0000-000000000000	7c63c6ba-64da-49e7-b5f2-50c2c762fe0c	{"action":"logout","actor_id":"82b26860-3162-48c5-9edc-14c06780dbac","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-25 02:27:04.158099+00	
00000000-0000-0000-0000-000000000000	29a61967-cebb-419d-a6e9-a2002c694698	{"action":"login","actor_id":"82b26860-3162-48c5-9edc-14c06780dbac","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-25 02:27:10.43311+00	
00000000-0000-0000-0000-000000000000	9cf5e5f3-9112-4432-97f9-2682450886da	{"action":"logout","actor_id":"82b26860-3162-48c5-9edc-14c06780dbac","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-25 02:31:24.061745+00	
00000000-0000-0000-0000-000000000000	9971121d-e840-4b26-a1e6-435afa9dbe96	{"action":"login","actor_id":"82b26860-3162-48c5-9edc-14c06780dbac","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-25 02:31:29.498942+00	
00000000-0000-0000-0000-000000000000	7d96abd8-170f-4e2b-b92b-4a50464c29c6	{"action":"logout","actor_id":"82b26860-3162-48c5-9edc-14c06780dbac","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-25 02:32:15.694591+00	
00000000-0000-0000-0000-000000000000	7cbd43b0-5b96-404e-b3e7-b622f7eac064	{"action":"login","actor_id":"82b26860-3162-48c5-9edc-14c06780dbac","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-25 06:56:45.702503+00	
00000000-0000-0000-0000-000000000000	dd456b9d-66e1-4ec5-86a0-9c73e4e2f7b4	{"action":"login","actor_id":"82b26860-3162-48c5-9edc-14c06780dbac","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-25 06:58:18.296827+00	
00000000-0000-0000-0000-000000000000	bdb2e626-6248-46b4-aa55-057a5b313ca0	{"action":"login","actor_id":"82b26860-3162-48c5-9edc-14c06780dbac","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-25 06:58:41.428259+00	
00000000-0000-0000-0000-000000000000	efa06191-9872-4e69-97c7-ccef73d9b322	{"action":"logout","actor_id":"82b26860-3162-48c5-9edc-14c06780dbac","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-25 07:13:39.799801+00	
00000000-0000-0000-0000-000000000000	ef6b71fc-ef7c-4cf7-9c01-afbf2a7b6e3d	{"action":"login","actor_id":"82b26860-3162-48c5-9edc-14c06780dbac","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-25 07:47:14.376002+00	
00000000-0000-0000-0000-000000000000	b9c287e5-6388-45d3-9876-074d86c020d8	{"action":"token_refreshed","actor_id":"82b26860-3162-48c5-9edc-14c06780dbac","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-25 08:47:21.169601+00	
00000000-0000-0000-0000-000000000000	49564d7f-ddbc-46f7-868d-6358ad34dc6f	{"action":"token_revoked","actor_id":"82b26860-3162-48c5-9edc-14c06780dbac","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-25 08:47:21.18982+00	
00000000-0000-0000-0000-000000000000	85f1cdc5-aab6-4fc2-867a-0762f2eef512	{"action":"logout","actor_id":"82b26860-3162-48c5-9edc-14c06780dbac","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-25 08:47:32.73071+00	
00000000-0000-0000-0000-000000000000	5d68f5f3-afc3-4ae5-99ba-132d566a36f9	{"action":"login","actor_id":"82b26860-3162-48c5-9edc-14c06780dbac","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-25 08:47:40.752909+00	
00000000-0000-0000-0000-000000000000	199f13bd-7d9d-4608-bb77-fb8071fbe919	{"action":"logout","actor_id":"82b26860-3162-48c5-9edc-14c06780dbac","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-25 08:48:05.009942+00	
00000000-0000-0000-0000-000000000000	e7970187-8673-4da2-affe-7f4e254f95dd	{"action":"login","actor_id":"82b26860-3162-48c5-9edc-14c06780dbac","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-25 09:44:52.189371+00	
00000000-0000-0000-0000-000000000000	47ed7efe-0fb9-47ec-bb34-a812308c85ee	{"action":"logout","actor_id":"82b26860-3162-48c5-9edc-14c06780dbac","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-25 09:46:32.739925+00	
00000000-0000-0000-0000-000000000000	7e36c29c-63c9-4dbc-bfa8-0db32764f2a7	{"action":"login","actor_id":"82b26860-3162-48c5-9edc-14c06780dbac","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-25 09:47:16.297602+00	
00000000-0000-0000-0000-000000000000	ba072d69-54f4-4560-b580-8478ae2b68c3	{"action":"logout","actor_id":"82b26860-3162-48c5-9edc-14c06780dbac","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-25 09:48:00.779394+00	
00000000-0000-0000-0000-000000000000	18f4e96b-9e8f-45e5-8338-0e5640efb4a3	{"action":"login","actor_id":"82b26860-3162-48c5-9edc-14c06780dbac","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-25 20:27:07.01477+00	
00000000-0000-0000-0000-000000000000	ef9502b3-7de5-4ebe-b376-c0464ed6ca42	{"action":"logout","actor_id":"82b26860-3162-48c5-9edc-14c06780dbac","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-25 20:29:37.565596+00	
00000000-0000-0000-0000-000000000000	cebd9dcf-27dc-49d1-981e-8f7ee8ea7a46	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"82b26860-3162-48c5-9edc-14c06780dbac","user_phone":""}}	2025-11-25 20:31:10.258219+00	
00000000-0000-0000-0000-000000000000	786116d8-3071-4983-9e3a-69269f127b5b	{"action":"user_signedup","actor_id":"aaf4a325-fce9-46db-8794-244e995f2449","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-25 20:37:01.38605+00	
00000000-0000-0000-0000-000000000000	ecaa774e-f78b-43a4-91e0-e7281aef3fb3	{"action":"token_refreshed","actor_id":"aaf4a325-fce9-46db-8794-244e995f2449","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-26 02:10:50.34154+00	
00000000-0000-0000-0000-000000000000	6c138ca4-2355-47bd-8b2d-f33b6e3a0bf4	{"action":"token_revoked","actor_id":"aaf4a325-fce9-46db-8794-244e995f2449","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-26 02:10:50.36339+00	
00000000-0000-0000-0000-000000000000	404f1d4c-353d-48cf-9c18-ceb4abfad29b	{"action":"token_refreshed","actor_id":"aaf4a325-fce9-46db-8794-244e995f2449","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-26 03:10:38.94419+00	
00000000-0000-0000-0000-000000000000	9d223dac-0e4b-49a7-bff5-482b3cab7556	{"action":"token_revoked","actor_id":"aaf4a325-fce9-46db-8794-244e995f2449","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-26 03:10:38.970566+00	
00000000-0000-0000-0000-000000000000	ba8df6fa-fff0-4e1f-9d39-b62820a720c5	{"action":"logout","actor_id":"aaf4a325-fce9-46db-8794-244e995f2449","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-26 03:15:23.99454+00	
00000000-0000-0000-0000-000000000000	f88308b2-5a4e-43f6-bdbd-2e16516728a8	{"action":"login","actor_id":"aaf4a325-fce9-46db-8794-244e995f2449","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-26 03:40:02.214093+00	
00000000-0000-0000-0000-000000000000	5f7511b2-3e3f-4d14-b424-3f0012403832	{"action":"logout","actor_id":"aaf4a325-fce9-46db-8794-244e995f2449","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-26 03:41:07.480748+00	
00000000-0000-0000-0000-000000000000	e5f216ed-a545-47c2-acef-ad982cf9bc2c	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"aaf4a325-fce9-46db-8794-244e995f2449","user_phone":""}}	2025-11-26 03:44:24.033987+00	
00000000-0000-0000-0000-000000000000	b091b27f-74a4-4768-89df-41b0b5924758	{"action":"user_signedup","actor_id":"56e91720-d8e9-4e79-843e-5cc774e7905e","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-26 03:47:12.241919+00	
00000000-0000-0000-0000-000000000000	a3aad5d3-394d-45e0-8f91-d8b08f371f91	{"action":"token_refreshed","actor_id":"56e91720-d8e9-4e79-843e-5cc774e7905e","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-26 06:08:09.784302+00	
00000000-0000-0000-0000-000000000000	f1efd676-7202-490f-a0a0-0b2f65f91c0d	{"action":"token_revoked","actor_id":"56e91720-d8e9-4e79-843e-5cc774e7905e","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-11-26 06:08:09.81218+00	
00000000-0000-0000-0000-000000000000	1788511b-7869-469f-97e3-737f4b7fb1bd	{"action":"logout","actor_id":"56e91720-d8e9-4e79-843e-5cc774e7905e","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-26 06:09:26.030066+00	
00000000-0000-0000-0000-000000000000	000f5d6b-71e6-443e-913c-836ea0ceece7	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"56e91720-d8e9-4e79-843e-5cc774e7905e","user_phone":""}}	2025-11-26 06:12:06.285891+00	
00000000-0000-0000-0000-000000000000	88b1d0d3-fbb7-4f61-b46e-51a580033e22	{"action":"user_signedup","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-26 06:18:22.544783+00	
00000000-0000-0000-0000-000000000000	2fdeaa10-281f-43b9-bb68-26b6bb56ebbf	{"action":"logout","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-26 06:19:55.042054+00	
00000000-0000-0000-0000-000000000000	02ba0193-c481-4354-bb1d-4b24479e7f0e	{"action":"login","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-26 06:30:16.581876+00	
00000000-0000-0000-0000-000000000000	1f587efa-6c72-433c-bbd1-9d39b519553d	{"action":"logout","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-26 06:35:13.379931+00	
00000000-0000-0000-0000-000000000000	5b05a331-aeba-47fe-882f-653bbdb91233	{"action":"user_signedup","actor_id":"386f8c30-c461-4cdd-bf3b-57e1234b78a9","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-26 12:13:34.973381+00	
00000000-0000-0000-0000-000000000000	90274ea7-0989-436c-8e3b-666a2decb9c0	{"action":"login","actor_id":"386f8c30-c461-4cdd-bf3b-57e1234b78a9","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-26 12:14:00.802799+00	
00000000-0000-0000-0000-000000000000	fddb2d1d-5e16-4915-bc72-fefa05d944b0	{"action":"login","actor_id":"386f8c30-c461-4cdd-bf3b-57e1234b78a9","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-26 12:14:31.817354+00	
00000000-0000-0000-0000-000000000000	d9d563c3-aeb1-4524-ad71-5bc9518269d4	{"action":"login","actor_id":"386f8c30-c461-4cdd-bf3b-57e1234b78a9","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-26 12:26:51.917957+00	
00000000-0000-0000-0000-000000000000	3daa16bb-814e-46f4-a711-ff54752d9333	{"action":"user_recovery_requested","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-26 12:54:36.520687+00	
00000000-0000-0000-0000-000000000000	7adf9e89-ab74-46bb-8e1d-7aabbeff60eb	{"action":"login","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-26 12:57:08.575005+00	
00000000-0000-0000-0000-000000000000	4eb7254f-cd59-4249-96ae-f5ef6c05299f	{"action":"user_updated_password","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-26 12:57:36.043958+00	
00000000-0000-0000-0000-000000000000	53a306da-16e3-4976-b8f5-82c0bcafa5e0	{"action":"user_modified","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-26 12:57:36.045102+00	
00000000-0000-0000-0000-000000000000	fd79f925-08ad-4668-871e-77e72e69bcb2	{"action":"logout","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-26 12:57:37.329149+00	
00000000-0000-0000-0000-000000000000	42273f90-4fcd-49cf-88d0-42c252356368	{"action":"login","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-26 12:58:19.268231+00	
00000000-0000-0000-0000-000000000000	83dcd089-6f41-4b77-94aa-7565f9a692ea	{"action":"login","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-26 12:59:38.590247+00	
00000000-0000-0000-0000-000000000000	0a94958b-cdec-4d60-a721-69a2e9cb9bc4	{"action":"login","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-26 13:00:24.215046+00	
00000000-0000-0000-0000-000000000000	c30a7d0b-dced-4ca9-a129-93edd43445cf	{"action":"login","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-26 13:56:27.616656+00	
00000000-0000-0000-0000-000000000000	9ecab79d-acdf-40b7-81a6-b40d9b67675e	{"action":"logout","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-26 13:57:02.099367+00	
00000000-0000-0000-0000-000000000000	ec6bd102-c0de-4a68-95fd-8e89ddde2513	{"action":"login","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-26 13:57:27.152985+00	
00000000-0000-0000-0000-000000000000	93c79bd5-03db-4c69-8abb-fbbf3b1a10ac	{"action":"logout","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-26 13:57:41.672338+00	
00000000-0000-0000-0000-000000000000	c78cba5f-d3af-429a-9413-8b648ebe4c82	{"action":"user_recovery_requested","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-26 18:12:46.622769+00	
00000000-0000-0000-0000-000000000000	85712f57-a492-44e4-b459-b0dcda1651c1	{"action":"login","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-26 18:13:50.157342+00	
00000000-0000-0000-0000-000000000000	18d33476-2a82-445c-a577-8e4abf0cb682	{"action":"user_updated_password","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-26 18:14:07.43071+00	
00000000-0000-0000-0000-000000000000	08170757-3f9d-4f8e-9d07-a79f7316e830	{"action":"user_modified","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-26 18:14:07.433362+00	
00000000-0000-0000-0000-000000000000	65123a0b-04c0-464f-b4a4-1e3b9f3c6734	{"action":"logout","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-26 18:14:08.5929+00	
00000000-0000-0000-0000-000000000000	2f6727a7-95f3-405b-b113-d71936a336fb	{"action":"login","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-26 18:14:23.817167+00	
00000000-0000-0000-0000-000000000000	d6b1d6cc-cf70-4e3d-982d-58642db28856	{"action":"logout","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-26 18:24:13.06898+00	
00000000-0000-0000-0000-000000000000	79f87758-c953-4a0b-9ff5-f09487f36466	{"action":"login","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-26 18:26:21.930814+00	
00000000-0000-0000-0000-000000000000	f8d1dc0d-6dcb-4634-80fd-220a6e2d6b38	{"action":"login","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-26 18:32:42.29391+00	
00000000-0000-0000-0000-000000000000	8e1b682c-b965-43c6-a798-20880b1928c6	{"action":"user_updated_password","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-26 18:32:42.69249+00	
00000000-0000-0000-0000-000000000000	620cf614-ed73-4584-95d4-76ae76ad8ba9	{"action":"user_modified","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-26 18:32:42.693189+00	
00000000-0000-0000-0000-000000000000	bcd9ef06-ec9d-47db-b0ab-7d63357f7e2f	{"action":"logout","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-26 18:34:12.981456+00	
00000000-0000-0000-0000-000000000000	cda51460-93d7-4a4c-9742-539d806c2c2f	{"action":"user_signedup","actor_id":"5bb8a7af-1a92-4110-b7dc-b169820389ac","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-26 22:32:31.081411+00	
00000000-0000-0000-0000-000000000000	a8d4de0c-ab0e-4af1-a30f-09b674c9c923	{"action":"user_recovery_requested","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-27 08:09:24.456187+00	
00000000-0000-0000-0000-000000000000	37caa856-f30c-480b-98f8-c3e16948af0a	{"action":"login","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-27 08:11:01.952521+00	
00000000-0000-0000-0000-000000000000	929a4ddf-43ee-400e-940f-d1638280967c	{"action":"user_updated_password","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-27 08:11:18.536577+00	
00000000-0000-0000-0000-000000000000	91793ab6-00ce-484e-980a-189db14afda6	{"action":"user_modified","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-11-27 08:11:18.538306+00	
00000000-0000-0000-0000-000000000000	09bb5928-bef9-43cc-8ba9-16a35a97a29b	{"action":"logout","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-27 08:11:19.583887+00	
00000000-0000-0000-0000-000000000000	666dac7e-f85e-4fbe-9143-62927399a7b4	{"action":"login","actor_id":"8c86921c-67f9-415a-8153-ed9959b053e1","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-27 08:11:26.812377+00	
00000000-0000-0000-0000-000000000000	1aefcf7a-0238-411e-b281-e0f67e7eef7d	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"8c86921c-67f9-415a-8153-ed9959b053e1","user_phone":""}}	2025-11-27 08:13:00.665148+00	
00000000-0000-0000-0000-000000000000	9eab285e-cec2-4cd0-8983-42a0ec0f7cc4	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"5bb8a7af-1a92-4110-b7dc-b169820389ac","user_phone":""}}	2025-11-27 08:16:57.944614+00	
00000000-0000-0000-0000-000000000000	1251ead4-e209-4ae2-9157-0b13b3a9f198	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"386f8c30-c461-4cdd-bf3b-57e1234b78a9","user_phone":""}}	2025-11-27 08:16:57.945053+00	
00000000-0000-0000-0000-000000000000	6c263d3d-c355-491a-a883-e33787ad7d8d	{"action":"user_signedup","actor_id":"c5811b5f-8da5-4cea-9fe8-3029b0bb1f00","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-27 08:20:42.529061+00	
00000000-0000-0000-0000-000000000000	50da5ef4-0192-4e68-aacb-ef3fce693066	{"action":"logout","actor_id":"c5811b5f-8da5-4cea-9fe8-3029b0bb1f00","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-27 08:22:00.959328+00	
00000000-0000-0000-0000-000000000000	13d7398d-cbf7-46e3-a57d-f817d00a5397	{"action":"login","actor_id":"c5811b5f-8da5-4cea-9fe8-3029b0bb1f00","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-27 08:22:15.819982+00	
00000000-0000-0000-0000-000000000000	ec6d0aef-5197-435e-a066-29d99690c8cd	{"action":"logout","actor_id":"c5811b5f-8da5-4cea-9fe8-3029b0bb1f00","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-27 08:22:53.202895+00	
00000000-0000-0000-0000-000000000000	9585ee72-51a9-43d0-a1b4-28b0d6b9b108	{"action":"user_signedup","actor_id":"9da08e41-76c1-49b2-b3d1-270d6a1a6dcd","actor_username":"fouad.bashaar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-27 11:40:38.743624+00	
00000000-0000-0000-0000-000000000000	828b7eea-0a93-422f-a6f3-01f3f07f9bb4	{"action":"logout","actor_id":"9da08e41-76c1-49b2-b3d1-270d6a1a6dcd","actor_username":"fouad.bashaar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-27 11:41:19.065227+00	
00000000-0000-0000-0000-000000000000	e325b58e-b0de-48fa-8b79-1cb2e95ba5f9	{"action":"user_signedup","actor_id":"8bd4c1a5-c884-43fe-bb4f-d5ce6bf974d3","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-27 23:30:22.684725+00	
00000000-0000-0000-0000-000000000000	644c0e83-d6a7-4ebf-b5ae-1e77ddfbaf97	{"action":"logout","actor_id":"8bd4c1a5-c884-43fe-bb4f-d5ce6bf974d3","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-27 23:30:33.298388+00	
00000000-0000-0000-0000-000000000000	741aed4e-8f63-4b4d-ae11-7d91842154be	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouad.bashaar@gmail.com","user_id":"9da08e41-76c1-49b2-b3d1-270d6a1a6dcd","user_phone":""}}	2025-11-28 11:13:30.890073+00	
00000000-0000-0000-0000-000000000000	3d31f82d-b83d-4f53-9df8-6cb64191304b	{"action":"login","actor_id":"a1975b4c-99ca-49f6-9694-647289088e36","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-01 14:36:17.62935+00	
00000000-0000-0000-0000-000000000000	e099a012-e4dd-4702-af56-534e528b796d	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"c5811b5f-8da5-4cea-9fe8-3029b0bb1f00","user_phone":""}}	2025-11-28 11:13:30.961421+00	
00000000-0000-0000-0000-000000000000	7b32f217-db85-4e34-9d05-adfad9f55d9e	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"8bd4c1a5-c884-43fe-bb4f-d5ce6bf974d3","user_phone":""}}	2025-11-28 11:13:30.976595+00	
00000000-0000-0000-0000-000000000000	df3a01d7-730e-44cf-8c8c-50212d50dd0d	{"action":"user_signedup","actor_id":"a5b5a668-879d-46e2-adc6-bfd811d9bd9d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-28 11:16:36.999039+00	
00000000-0000-0000-0000-000000000000	65674485-305f-4c08-aa85-71a20d1e641f	{"action":"logout","actor_id":"a5b5a668-879d-46e2-adc6-bfd811d9bd9d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-28 11:17:02.973778+00	
00000000-0000-0000-0000-000000000000	4af557ed-9a89-4fb6-b962-8ac5503bf194	{"action":"login","actor_id":"a5b5a668-879d-46e2-adc6-bfd811d9bd9d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-28 11:20:45.648448+00	
00000000-0000-0000-0000-000000000000	503af9aa-3efc-40b4-9170-b5646a8898eb	{"action":"logout","actor_id":"a5b5a668-879d-46e2-adc6-bfd811d9bd9d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-28 11:27:21.313978+00	
00000000-0000-0000-0000-000000000000	e5412191-e7f1-4556-8297-0f4a291dbfc3	{"action":"user_signedup","actor_id":"9b2b815b-5b16-49cc-b992-1345930567af","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-28 12:38:38.568505+00	
00000000-0000-0000-0000-000000000000	1915f7bd-4469-4948-83b0-deea32fe4b8f	{"action":"logout","actor_id":"9b2b815b-5b16-49cc-b992-1345930567af","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-28 12:40:18.73769+00	
00000000-0000-0000-0000-000000000000	1b268e97-e9ac-4dcb-9ba0-442204a2170e	{"action":"login","actor_id":"9b2b815b-5b16-49cc-b992-1345930567af","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-29 03:42:22.424496+00	
00000000-0000-0000-0000-000000000000	addd41c9-f952-454d-bf4c-49718a3d55a1	{"action":"logout","actor_id":"9b2b815b-5b16-49cc-b992-1345930567af","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-29 03:49:30.520986+00	
00000000-0000-0000-0000-000000000000	dd74e779-0242-4cfd-a72c-cd5dbcec12b6	{"action":"login","actor_id":"9b2b815b-5b16-49cc-b992-1345930567af","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-29 03:49:56.696396+00	
00000000-0000-0000-0000-000000000000	ff8f4a83-f6fd-4fcd-aa9f-f26d4edee762	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"9b2b815b-5b16-49cc-b992-1345930567af","user_phone":""}}	2025-11-29 03:50:46.587061+00	
00000000-0000-0000-0000-000000000000	b6ba8465-bf94-4287-acfc-461a1fc41d6d	{"action":"user_signedup","actor_id":"b22e9dab-4b00-4265-8856-e1b82f2f57d6","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-30 03:46:17.450534+00	
00000000-0000-0000-0000-000000000000	cee3365f-c035-47e5-8277-5eecbea3d7a4	{"action":"logout","actor_id":"b22e9dab-4b00-4265-8856-e1b82f2f57d6","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-30 03:47:11.533795+00	
00000000-0000-0000-0000-000000000000	b13138c3-d20f-4eab-9419-7be7608b7d5c	{"action":"login","actor_id":"b22e9dab-4b00-4265-8856-e1b82f2f57d6","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-11-30 03:48:08.270139+00	
00000000-0000-0000-0000-000000000000	49b77bd5-7b45-4abb-bde7-0f4929d22ee0	{"action":"logout","actor_id":"b22e9dab-4b00-4265-8856-e1b82f2f57d6","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-30 03:48:45.461621+00	
00000000-0000-0000-0000-000000000000	b503dac2-f5ba-4eea-b0b1-911e8e5ab864	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"b22e9dab-4b00-4265-8856-e1b82f2f57d6","user_phone":""}}	2025-11-30 03:58:31.140787+00	
00000000-0000-0000-0000-000000000000	ec7b9172-7549-4950-b3a5-b976087b8059	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"a5b5a668-879d-46e2-adc6-bfd811d9bd9d","user_phone":""}}	2025-11-30 03:58:31.140577+00	
00000000-0000-0000-0000-000000000000	2407ae22-f1c3-44f3-ac3f-a0c2bac1db13	{"action":"user_signedup","actor_id":"7b6ce38b-44ce-44dd-a2f3-3d75b90c1cbd","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-30 04:00:18.619607+00	
00000000-0000-0000-0000-000000000000	ed27c797-e390-40a9-907f-5c960e4bdac3	{"action":"logout","actor_id":"7b6ce38b-44ce-44dd-a2f3-3d75b90c1cbd","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-30 04:00:25.527804+00	
00000000-0000-0000-0000-000000000000	8c048bc9-3047-4331-a2ee-5646bc12ae43	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"7b6ce38b-44ce-44dd-a2f3-3d75b90c1cbd","user_phone":""}}	2025-11-30 12:41:30.903068+00	
00000000-0000-0000-0000-000000000000	91bd8761-75e9-4096-81c2-65cf662716de	{"action":"user_signedup","actor_id":"a6a50760-c12a-4f38-ad6c-3871d66c22ad","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-30 14:42:00.888585+00	
00000000-0000-0000-0000-000000000000	179d2249-20e9-4100-aa7a-224349e069f7	{"action":"logout","actor_id":"a6a50760-c12a-4f38-ad6c-3871d66c22ad","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-30 14:43:17.287754+00	
00000000-0000-0000-0000-000000000000	45460461-077f-4560-b90b-040b858826f9	{"action":"user_signedup","actor_id":"52db1643-6992-4b64-9448-65e9a6d5a5ac","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-11-30 14:47:59.583982+00	
00000000-0000-0000-0000-000000000000	c2f4464a-3c2d-4522-89ae-fb78325985ab	{"action":"logout","actor_id":"52db1643-6992-4b64-9448-65e9a6d5a5ac","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-11-30 14:48:17.853165+00	
00000000-0000-0000-0000-000000000000	f04aade0-2ea9-4168-a3c2-b5d8581b2c32	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"52db1643-6992-4b64-9448-65e9a6d5a5ac","user_phone":""}}	2025-12-01 13:21:52.852925+00	
00000000-0000-0000-0000-000000000000	baa2ba6e-d568-4d80-a24d-799fd33fd007	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"a6a50760-c12a-4f38-ad6c-3871d66c22ad","user_phone":""}}	2025-12-01 13:21:52.94378+00	
00000000-0000-0000-0000-000000000000	2ab28eac-0998-4f7e-83cf-67ccaa8f3500	{"action":"user_signedup","actor_id":"a1975b4c-99ca-49f6-9694-647289088e36","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-12-01 14:08:41.803106+00	
00000000-0000-0000-0000-000000000000	d7d93a42-871c-4ceb-9506-228f313ba6fc	{"action":"logout","actor_id":"a1975b4c-99ca-49f6-9694-647289088e36","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-01 14:36:12.578657+00	
00000000-0000-0000-0000-000000000000	67a650d5-3a5e-4550-96e3-6bea64e72061	{"action":"logout","actor_id":"a1975b4c-99ca-49f6-9694-647289088e36","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-01 14:36:37.366934+00	
00000000-0000-0000-0000-000000000000	074a6552-50ab-4f14-9b4b-38044b100fd0	{"action":"user_recovery_requested","actor_id":"a1975b4c-99ca-49f6-9694-647289088e36","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-12-01 14:36:45.675432+00	
00000000-0000-0000-0000-000000000000	12fc2e35-dbe3-426e-a915-23d5ac6c9707	{"action":"login","actor_id":"a1975b4c-99ca-49f6-9694-647289088e36","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-01 14:37:07.194409+00	
00000000-0000-0000-0000-000000000000	3c813832-ecb2-40fb-b3e4-3707fb26e736	{"action":"user_updated_password","actor_id":"a1975b4c-99ca-49f6-9694-647289088e36","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-12-01 14:37:32.685305+00	
00000000-0000-0000-0000-000000000000	d82da676-288a-4b70-8b52-a77cdae44380	{"action":"user_modified","actor_id":"a1975b4c-99ca-49f6-9694-647289088e36","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-12-01 14:37:32.686808+00	
00000000-0000-0000-0000-000000000000	eaa17d1d-240c-4563-a990-a22edaa06b80	{"action":"logout","actor_id":"a1975b4c-99ca-49f6-9694-647289088e36","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-01 14:37:33.447895+00	
00000000-0000-0000-0000-000000000000	140b204f-e3cc-409f-9015-120ad7f3df16	{"action":"login","actor_id":"a1975b4c-99ca-49f6-9694-647289088e36","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-01 14:37:47.417196+00	
00000000-0000-0000-0000-000000000000	18e64951-1419-4e45-9656-b5f4c428b5c7	{"action":"logout","actor_id":"a1975b4c-99ca-49f6-9694-647289088e36","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-01 14:37:53.576083+00	
00000000-0000-0000-0000-000000000000	1a9cbd2d-9fd6-4fea-9287-ddfeaf55010a	{"action":"user_signedup","actor_id":"342f77c2-ec52-47f5-9aa4-305a9a202c64","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-12-01 16:50:04.558247+00	
00000000-0000-0000-0000-000000000000	b41d5e7a-ffba-4bc7-9877-bb549a94ddb0	{"action":"logout","actor_id":"342f77c2-ec52-47f5-9aa4-305a9a202c64","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-01 16:50:46.614967+00	
00000000-0000-0000-0000-000000000000	19dd26cf-5ea4-4efc-8970-42b7da844972	{"action":"login","actor_id":"342f77c2-ec52-47f5-9aa4-305a9a202c64","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-01 16:51:10.401803+00	
00000000-0000-0000-0000-000000000000	ece8934c-797a-4340-9db5-dcaa557e19b2	{"action":"user_recovery_requested","actor_id":"a1975b4c-99ca-49f6-9694-647289088e36","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-12-01 17:52:43.280612+00	
00000000-0000-0000-0000-000000000000	fb9a7455-56c8-403b-9fea-038c2ea8c3d1	{"action":"login","actor_id":"a1975b4c-99ca-49f6-9694-647289088e36","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-01 17:53:32.275338+00	
00000000-0000-0000-0000-000000000000	b7ddb7a2-54b5-421c-88ef-f6c601671c89	{"action":"user_updated_password","actor_id":"a1975b4c-99ca-49f6-9694-647289088e36","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-12-01 17:53:50.010962+00	
00000000-0000-0000-0000-000000000000	e01e22ee-ab1e-4313-ba4d-4e8fb23b31f0	{"action":"user_modified","actor_id":"a1975b4c-99ca-49f6-9694-647289088e36","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-12-01 17:53:50.013072+00	
00000000-0000-0000-0000-000000000000	9a3a939c-b481-4575-a2b9-e9972b86f93c	{"action":"logout","actor_id":"a1975b4c-99ca-49f6-9694-647289088e36","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-01 17:53:51.559131+00	
00000000-0000-0000-0000-000000000000	b943eb06-3e99-41b0-9e20-dfd47a052884	{"action":"login","actor_id":"a1975b4c-99ca-49f6-9694-647289088e36","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-01 17:54:03.049901+00	
00000000-0000-0000-0000-000000000000	1495d33d-79a2-40cb-a8e1-c72a797356ef	{"action":"token_refreshed","actor_id":"a1975b4c-99ca-49f6-9694-647289088e36","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-01 18:59:17.659709+00	
00000000-0000-0000-0000-000000000000	972433ba-1b2c-4e6d-9b3a-26a850e38274	{"action":"token_revoked","actor_id":"a1975b4c-99ca-49f6-9694-647289088e36","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-01 18:59:17.678851+00	
00000000-0000-0000-0000-000000000000	ed601277-e68e-45d4-8254-026c525b8835	{"action":"logout","actor_id":"a1975b4c-99ca-49f6-9694-647289088e36","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-01 18:59:18.69621+00	
00000000-0000-0000-0000-000000000000	72725914-256f-4bcb-b2d7-4cb8b24e2ee5	{"action":"token_refreshed","actor_id":"342f77c2-ec52-47f5-9aa4-305a9a202c64","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-02 12:37:06.513964+00	
00000000-0000-0000-0000-000000000000	893ed51b-1ab2-4512-8c3c-bc9721f69911	{"action":"token_revoked","actor_id":"342f77c2-ec52-47f5-9aa4-305a9a202c64","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-02 12:37:06.538163+00	
00000000-0000-0000-0000-000000000000	e69db5b5-76f3-48dc-85a2-753899015e3f	{"action":"logout","actor_id":"342f77c2-ec52-47f5-9aa4-305a9a202c64","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-02 12:37:35.726139+00	
00000000-0000-0000-0000-000000000000	f316d76b-e99f-49ff-8374-68692bbe121b	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"a1975b4c-99ca-49f6-9694-647289088e36","user_phone":""}}	2025-12-02 12:53:57.86891+00	
00000000-0000-0000-0000-000000000000	e908faee-e821-4f0f-94a2-c05ff003b79f	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"342f77c2-ec52-47f5-9aa4-305a9a202c64","user_phone":""}}	2025-12-02 12:53:58.020038+00	
00000000-0000-0000-0000-000000000000	fccd34ec-e50a-4fab-8686-549e67db8ed3	{"action":"user_signedup","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-12-02 13:00:08.74417+00	
00000000-0000-0000-0000-000000000000	e2938105-92a3-479a-9bea-24a1e59cd55d	{"action":"logout","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-02 13:00:23.770375+00	
00000000-0000-0000-0000-000000000000	0ae3e27f-c66e-406b-ac65-96f9993f8aaa	{"action":"user_signedup","actor_id":"eb0d78f3-6047-49af-a19d-29c898d7de3d","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-12-02 17:51:50.825545+00	
00000000-0000-0000-0000-000000000000	14838b29-3e8b-40ce-89b2-1b32dfe74621	{"action":"logout","actor_id":"eb0d78f3-6047-49af-a19d-29c898d7de3d","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-02 17:54:48.744369+00	
00000000-0000-0000-0000-000000000000	166f5088-918f-4772-a093-2ab581930ba0	{"action":"user_recovery_requested","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-12-02 17:55:15.161287+00	
00000000-0000-0000-0000-000000000000	38876f48-329b-4a6b-a612-84fbcfcd3b54	{"action":"login","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-02 17:56:34.42501+00	
00000000-0000-0000-0000-000000000000	8f58ad8f-1350-4bbc-a85d-53eb8f83e745	{"action":"user_updated_password","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-12-02 17:57:09.557976+00	
00000000-0000-0000-0000-000000000000	aef28d08-3f7c-4271-9550-64f72e3c5ffd	{"action":"user_modified","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-12-02 17:57:09.559884+00	
00000000-0000-0000-0000-000000000000	6b490fa6-89a6-4df5-b132-77b288e5b45a	{"action":"logout","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-02 17:57:10.565963+00	
00000000-0000-0000-0000-000000000000	4297e29c-f0bd-4f6d-9ebc-729095f47b27	{"action":"login","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-02 17:58:10.807393+00	
00000000-0000-0000-0000-000000000000	bb93721c-be4d-4f01-9c39-3290470bd008	{"action":"login","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-02 18:01:58.78158+00	
00000000-0000-0000-0000-000000000000	6532d98a-2556-4817-83a2-cbcdb8de525f	{"action":"user_updated_password","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-12-02 18:01:59.20062+00	
00000000-0000-0000-0000-000000000000	1ce3bd84-b95b-4400-a9eb-34ee3f158fcf	{"action":"user_modified","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-12-02 18:01:59.201429+00	
00000000-0000-0000-0000-000000000000	5d471506-648e-4c00-965e-8985b74edbc0	{"action":"token_refreshed","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-02 19:03:31.144988+00	
00000000-0000-0000-0000-000000000000	72d78e88-fd4b-43d9-8575-fc54b52bcbc4	{"action":"token_revoked","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-02 19:03:31.167854+00	
00000000-0000-0000-0000-000000000000	810a5c71-f6cf-4550-abe1-ae68580bd8ce	{"action":"token_refreshed","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-02 19:03:35.08957+00	
00000000-0000-0000-0000-000000000000	16fde705-9adb-4072-9a8b-17a80d26578c	{"action":"token_refreshed","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-02 19:15:23.767601+00	
00000000-0000-0000-0000-000000000000	c2ffdc96-4476-423e-acc0-a6a85fa6ca18	{"action":"token_refreshed","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-02 19:15:31.247513+00	
00000000-0000-0000-0000-000000000000	f997994a-367a-4e8e-b8ed-0a76c913be63	{"action":"token_refreshed","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-02 19:20:09.848875+00	
00000000-0000-0000-0000-000000000000	6c4151d0-00f9-4d77-89b9-844dc12c4488	{"action":"token_refreshed","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-02 19:20:15.912168+00	
00000000-0000-0000-0000-000000000000	53939b8e-1be3-48a8-bbc6-92512b0c4da1	{"action":"token_refreshed","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-02 19:23:36.501205+00	
00000000-0000-0000-0000-000000000000	0cab43f4-01b3-4dcd-ba9a-aaa8bb930a93	{"action":"token_refreshed","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-03 08:05:02.717203+00	
00000000-0000-0000-0000-000000000000	152df1d7-3673-4ab8-9a6f-a4116c2ecde3	{"action":"token_revoked","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-03 08:05:02.744613+00	
00000000-0000-0000-0000-000000000000	28925827-7da8-41a1-9c70-4e4b05417ba6	{"action":"token_refreshed","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-03 08:05:04.112115+00	
00000000-0000-0000-0000-000000000000	4afac883-96f4-4eff-91ae-69bfc5a7a3bf	{"action":"token_refreshed","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-03 08:05:21.55337+00	
00000000-0000-0000-0000-000000000000	60ef50e2-5c23-444e-9114-0ac6c1e5e4c6	{"action":"logout","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-03 08:06:40.740456+00	
00000000-0000-0000-0000-000000000000	95d8af7d-e731-4d22-8570-74bd815836d8	{"action":"login","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-03 10:57:14.329701+00	
00000000-0000-0000-0000-000000000000	06e7b9c2-e578-41a9-932f-e39e31375044	{"action":"user_recovery_requested","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-12-03 16:30:02.550332+00	
00000000-0000-0000-0000-000000000000	a47de06f-f400-4be3-bb68-46cfc63ea221	{"action":"login","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-03 16:32:46.570175+00	
00000000-0000-0000-0000-000000000000	e47ac4c9-d001-4e94-bcb3-0ca01e3e0c25	{"action":"user_updated_password","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-12-03 16:33:06.025394+00	
00000000-0000-0000-0000-000000000000	928748b9-f951-42e4-b0df-76b02a8bbeab	{"action":"user_modified","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-12-03 16:33:06.027968+00	
00000000-0000-0000-0000-000000000000	6494081b-b201-409f-a0c9-9acc29b6a29a	{"action":"logout","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-03 16:33:07.60823+00	
00000000-0000-0000-0000-000000000000	a25830aa-2dae-4ff3-964c-0237e489400a	{"action":"login","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-03 16:33:21.606677+00	
00000000-0000-0000-0000-000000000000	4393a80e-b1aa-47fe-a980-6724e3aa74df	{"action":"user_signedup","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-12-03 21:02:28.070755+00	
00000000-0000-0000-0000-000000000000	2121142d-a81d-4b29-aa6a-7a4604ddcb71	{"action":"logout","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-03 21:56:39.412483+00	
00000000-0000-0000-0000-000000000000	dcd225e1-0877-45cf-b87a-6e83cf2dfb23	{"action":"login","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-03 21:56:54.478509+00	
00000000-0000-0000-0000-000000000000	0b8f452e-d68e-42c8-98c2-c70fb865739a	{"action":"logout","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-03 21:56:59.463697+00	
00000000-0000-0000-0000-000000000000	103f9e91-2885-4020-9ea1-61b659fbb521	{"action":"login","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-03 21:58:07.545359+00	
00000000-0000-0000-0000-000000000000	c3e8671b-10e8-4351-a953-0313d9f48d5f	{"action":"logout","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-03 22:12:37.926953+00	
00000000-0000-0000-0000-000000000000	16c62023-f224-49dc-89ab-7844e5b899aa	{"action":"user_recovery_requested","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-12-03 22:12:54.158891+00	
00000000-0000-0000-0000-000000000000	49bb1d13-a90f-47c1-956c-f58dc553ea03	{"action":"login","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-03 22:14:25.381833+00	
00000000-0000-0000-0000-000000000000	df44df24-8f11-4689-b8cc-298ff10141ef	{"action":"user_updated_password","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-12-03 22:14:41.894544+00	
00000000-0000-0000-0000-000000000000	7f6d13a8-1609-453b-b20d-2e8f38d0c0cf	{"action":"user_modified","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-12-03 22:14:41.914832+00	
00000000-0000-0000-0000-000000000000	7ec8f29c-150d-4ad2-81d5-0d00834ad21c	{"action":"logout","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-03 22:14:43.455983+00	
00000000-0000-0000-0000-000000000000	104552dc-f098-40cb-a5ea-7952b34d96fd	{"action":"login","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-03 22:15:01.217794+00	
00000000-0000-0000-0000-000000000000	bb9964c2-8fc4-4a85-b91f-37c7a381c304	{"action":"logout","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-03 22:17:22.282858+00	
00000000-0000-0000-0000-000000000000	bf779697-9828-443b-a1ff-3072c8873b7f	{"action":"login","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-04 13:19:35.854452+00	
00000000-0000-0000-0000-000000000000	6a30498e-871c-4dd1-9334-f35a9b1a7cae	{"action":"logout","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-04 13:40:37.532083+00	
00000000-0000-0000-0000-000000000000	4e87a93d-0386-4e62-917f-4497c0c57579	{"action":"login","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-04 17:55:36.798365+00	
00000000-0000-0000-0000-000000000000	b60be970-20c7-4e8a-9754-cf2d0c05348e	{"action":"logout","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-04 18:10:24.410878+00	
00000000-0000-0000-0000-000000000000	75b7c401-deea-4374-83b8-a3cdef53a43c	{"action":"login","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-05 16:46:16.209825+00	
00000000-0000-0000-0000-000000000000	99c1da76-61a6-4edd-a8a5-712673dcfe1b	{"action":"logout","actor_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-05 16:52:28.84423+00	
00000000-0000-0000-0000-000000000000	779ae73d-4f10-4b97-860b-6dbcad8f0fed	{"action":"login","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-07 09:36:14.53467+00	
00000000-0000-0000-0000-000000000000	bef27a49-7d40-47e1-825c-ee6b2eca9572	{"action":"logout","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-07 09:37:38.164082+00	
00000000-0000-0000-0000-000000000000	34f7d556-8d3b-4756-b1e0-403be8455ab1	{"action":"login","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-07 09:37:49.442382+00	
00000000-0000-0000-0000-000000000000	b2a54c84-fc97-41b9-b10b-0b69e5b2bd96	{"action":"token_refreshed","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-07 11:30:42.813616+00	
00000000-0000-0000-0000-000000000000	f78666bd-2710-47c3-b417-653e1b9a1782	{"action":"token_revoked","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-07 11:30:42.840457+00	
00000000-0000-0000-0000-000000000000	2ea023ba-f1d1-4f80-be03-c4e938f3b458	{"action":"token_refreshed","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-07 11:30:48.132923+00	
00000000-0000-0000-0000-000000000000	23ac7897-335b-4335-b311-6269e8d26e15	{"action":"token_refreshed","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-07 11:33:01.224576+00	
00000000-0000-0000-0000-000000000000	afe4f4df-7c3d-42f8-9661-5d8cc4438ac5	{"action":"token_refreshed","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-07 11:33:24.917406+00	
00000000-0000-0000-0000-000000000000	cbba1aff-c463-4ad4-840c-225100a69e64	{"action":"token_refreshed","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-09 07:46:10.831306+00	
00000000-0000-0000-0000-000000000000	afe40ea9-85c8-4b7e-8bae-ad0138d3b659	{"action":"token_refreshed","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-09 07:46:16.125932+00	
00000000-0000-0000-0000-000000000000	352f57d9-ea6e-4d1b-9a73-a69e9f841baa	{"action":"token_refreshed","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-09 07:46:23.485134+00	
00000000-0000-0000-0000-000000000000	502f3525-5c54-4c3a-aa11-63d3ae38837c	{"action":"token_refreshed","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-09 11:13:03.177853+00	
00000000-0000-0000-0000-000000000000	cc980d56-6c35-4ca9-bbff-b5374453f7c1	{"action":"token_revoked","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-09 11:13:03.197989+00	
00000000-0000-0000-0000-000000000000	b569ceb8-db9e-42b3-ab28-5ee94f7d850a	{"action":"logout","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-09 11:18:58.84579+00	
00000000-0000-0000-0000-000000000000	0bdafdf1-569d-42d6-a752-02c9305ea8a0	{"action":"login","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-10 17:53:26.748007+00	
00000000-0000-0000-0000-000000000000	44fe8669-9e38-406d-9cb0-a30c6396d420	{"action":"logout","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-10 18:32:57.39613+00	
00000000-0000-0000-0000-000000000000	a89351ce-ad52-42db-b875-a8e7f2f61a77	{"action":"login","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-11 16:09:08.735733+00	
00000000-0000-0000-0000-000000000000	0a486bc5-ae8e-482e-be32-d1cec1830be1	{"action":"logout","actor_id":"3812901c-a566-4a8b-8504-d7936abde9c8","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-11 16:11:19.44229+00	
00000000-0000-0000-0000-000000000000	9a984056-6a84-4728-b8cd-a666fe562b07	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"098ec835-1fc9-4bdb-a6c6-36586756f992","user_phone":""}}	2025-12-11 16:25:49.940783+00	
00000000-0000-0000-0000-000000000000	4269a6a0-a0dc-47ab-8ab4-68b0ba490179	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"3812901c-a566-4a8b-8504-d7936abde9c8","user_phone":""}}	2025-12-11 16:25:50.232329+00	
00000000-0000-0000-0000-000000000000	c5c2ab49-6c33-47ae-b1cf-3f5b5055a706	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"eb0d78f3-6047-49af-a19d-29c898d7de3d","user_phone":""}}	2025-12-11 16:25:50.265203+00	
00000000-0000-0000-0000-000000000000	a2a16602-5cc2-4b04-b382-40647b18d678	{"action":"user_signedup","actor_id":"038952d6-943a-4517-afe2-d94709637b3f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-12-11 16:33:19.682607+00	
00000000-0000-0000-0000-000000000000	ab26f9e2-0e32-4f8a-852a-667aaa68e6bf	{"action":"logout","actor_id":"038952d6-943a-4517-afe2-d94709637b3f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-11 16:37:39.055833+00	
00000000-0000-0000-0000-000000000000	1ce3bc7f-d3fa-493a-8695-0c1c36f71970	{"action":"user_signedup","actor_id":"ffc6ffcf-0a9b-4719-bb5e-c85a6fd13fcf","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-12-11 16:39:05.257814+00	
00000000-0000-0000-0000-000000000000	cac6ff33-8f34-49ba-a79c-d5c41dd26104	{"action":"logout","actor_id":"ffc6ffcf-0a9b-4719-bb5e-c85a6fd13fcf","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-11 16:40:26.05495+00	
00000000-0000-0000-0000-000000000000	12cb6626-6bdf-43a3-85cf-4ffdadd9a670	{"action":"login","actor_id":"ffc6ffcf-0a9b-4719-bb5e-c85a6fd13fcf","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-11 16:41:03.191943+00	
00000000-0000-0000-0000-000000000000	3a762456-3fe2-41b4-a606-37376faf7e62	{"action":"token_refreshed","actor_id":"ffc6ffcf-0a9b-4719-bb5e-c85a6fd13fcf","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-11 18:03:49.221846+00	
00000000-0000-0000-0000-000000000000	bbc1cf05-9691-4b91-9b80-c673b1167e6b	{"action":"token_revoked","actor_id":"ffc6ffcf-0a9b-4719-bb5e-c85a6fd13fcf","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-11 18:03:49.244941+00	
00000000-0000-0000-0000-000000000000	1597abab-a1ef-4c3c-99b6-5d7c0c7c4f46	{"action":"token_refreshed","actor_id":"ffc6ffcf-0a9b-4719-bb5e-c85a6fd13fcf","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-11 18:04:01.416991+00	
00000000-0000-0000-0000-000000000000	5346a81b-bc97-42cf-8838-68feb238c7bb	{"action":"token_refreshed","actor_id":"ffc6ffcf-0a9b-4719-bb5e-c85a6fd13fcf","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-11 18:09:02.671413+00	
00000000-0000-0000-0000-000000000000	17ab06a9-adfc-4837-9a4b-1c91ba5a16b2	{"action":"token_refreshed","actor_id":"ffc6ffcf-0a9b-4719-bb5e-c85a6fd13fcf","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-11 18:09:07.237314+00	
00000000-0000-0000-0000-000000000000	15598040-2526-4560-a857-5933ca99f4c3	{"action":"token_refreshed","actor_id":"ffc6ffcf-0a9b-4719-bb5e-c85a6fd13fcf","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-11 18:09:28.111129+00	
00000000-0000-0000-0000-000000000000	80249de6-5605-4d7a-b17b-cd735d3f5ec3	{"action":"token_refreshed","actor_id":"ffc6ffcf-0a9b-4719-bb5e-c85a6fd13fcf","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-11 18:09:32.395696+00	
00000000-0000-0000-0000-000000000000	845f6725-7f37-40e3-a3e1-903af79a2974	{"action":"token_refreshed","actor_id":"ffc6ffcf-0a9b-4719-bb5e-c85a6fd13fcf","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-11 19:14:05.672151+00	
00000000-0000-0000-0000-000000000000	d0a6c507-0ba8-4cd8-960f-18d2ae5dfdf8	{"action":"token_refreshed","actor_id":"ffc6ffcf-0a9b-4719-bb5e-c85a6fd13fcf","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-11 19:14:09.019762+00	
00000000-0000-0000-0000-000000000000	a6f4a503-dab6-4bc8-aeb9-fa3d61974b66	{"action":"token_refreshed","actor_id":"ffc6ffcf-0a9b-4719-bb5e-c85a6fd13fcf","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-11 19:27:18.466384+00	
00000000-0000-0000-0000-000000000000	5005075f-983b-4a58-9140-6b7022033865	{"action":"logout","actor_id":"ffc6ffcf-0a9b-4719-bb5e-c85a6fd13fcf","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-11 19:27:34.816436+00	
00000000-0000-0000-0000-000000000000	14caa82d-1bf9-4a0d-b94d-577c8212727b	{"action":"login","actor_id":"ffc6ffcf-0a9b-4719-bb5e-c85a6fd13fcf","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-12 00:15:21.604871+00	
00000000-0000-0000-0000-000000000000	47dec07c-ce2b-4d11-8347-e67bb077d79a	{"action":"token_refreshed","actor_id":"ffc6ffcf-0a9b-4719-bb5e-c85a6fd13fcf","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-12 02:21:38.824797+00	
00000000-0000-0000-0000-000000000000	96ab0651-3dd6-48de-b0f7-0a4334923051	{"action":"token_revoked","actor_id":"ffc6ffcf-0a9b-4719-bb5e-c85a6fd13fcf","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-12 02:21:38.847553+00	
00000000-0000-0000-0000-000000000000	9433563e-26a7-4b85-aee9-174bea990942	{"action":"token_refreshed","actor_id":"ffc6ffcf-0a9b-4719-bb5e-c85a6fd13fcf","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-12 03:44:28.868049+00	
00000000-0000-0000-0000-000000000000	d71d16d0-1a90-4e5c-b158-17f537d5db5c	{"action":"token_revoked","actor_id":"ffc6ffcf-0a9b-4719-bb5e-c85a6fd13fcf","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-12 03:44:28.879471+00	
00000000-0000-0000-0000-000000000000	ced2ce0b-159b-44a5-8868-5d4aa5b76577	{"action":"logout","actor_id":"ffc6ffcf-0a9b-4719-bb5e-c85a6fd13fcf","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-12 03:46:22.661985+00	
00000000-0000-0000-0000-000000000000	0393fe31-9654-498d-b311-24e9d1074731	{"action":"login","actor_id":"ffc6ffcf-0a9b-4719-bb5e-c85a6fd13fcf","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-12 03:46:35.287155+00	
00000000-0000-0000-0000-000000000000	3e910596-d99f-4a7c-a865-11a67514951c	{"action":"logout","actor_id":"ffc6ffcf-0a9b-4719-bb5e-c85a6fd13fcf","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-12 03:46:50.991378+00	
00000000-0000-0000-0000-000000000000	0c79f064-7cbe-4362-8952-9753cbefa52f	{"action":"login","actor_id":"038952d6-943a-4517-afe2-d94709637b3f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-12 03:47:20.891228+00	
00000000-0000-0000-0000-000000000000	538dbef5-0b0c-47a0-9c19-a6e8ecc08bc3	{"action":"logout","actor_id":"038952d6-943a-4517-afe2-d94709637b3f","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-12 03:48:00.85851+00	
00000000-0000-0000-0000-000000000000	4da2ac5c-1bb5-4e5e-bd79-48dd3bb3a1b3	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"038952d6-943a-4517-afe2-d94709637b3f","user_phone":""}}	2025-12-12 19:58:41.481461+00	
00000000-0000-0000-0000-000000000000	5d6c1165-13d5-4cce-a40d-265131ad639a	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"ffc6ffcf-0a9b-4719-bb5e-c85a6fd13fcf","user_phone":""}}	2025-12-12 19:58:41.481661+00	
00000000-0000-0000-0000-000000000000	852547fe-ca16-4801-8dce-40455999869b	{"action":"user_signedup","actor_id":"2d17bcee-fb47-40fa-9237-396c52d5d23c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-12-12 20:08:06.082887+00	
00000000-0000-0000-0000-000000000000	e91f836d-3bf8-4fb6-916a-79768aec89e4	{"action":"logout","actor_id":"2d17bcee-fb47-40fa-9237-396c52d5d23c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-12 20:08:36.063942+00	
00000000-0000-0000-0000-000000000000	da0a7cd2-b978-490f-b93e-f533fe587794	{"action":"login","actor_id":"2d17bcee-fb47-40fa-9237-396c52d5d23c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-12 20:12:34.282781+00	
00000000-0000-0000-0000-000000000000	d2f9dfc0-364e-45a7-9c31-a520b83f1c94	{"action":"logout","actor_id":"2d17bcee-fb47-40fa-9237-396c52d5d23c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-12 20:23:16.255941+00	
00000000-0000-0000-0000-000000000000	7360b0f8-7d09-4db1-942e-dcf72465a990	{"action":"user_recovery_requested","actor_id":"2d17bcee-fb47-40fa-9237-396c52d5d23c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-12-12 20:43:24.706437+00	
00000000-0000-0000-0000-000000000000	ce235297-cd5a-4f0b-b51a-714f341c8138	{"action":"login","actor_id":"2d17bcee-fb47-40fa-9237-396c52d5d23c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-12 20:44:12.194665+00	
00000000-0000-0000-0000-000000000000	54ae894e-6568-4bdb-a723-1885e3db71ec	{"action":"user_updated_password","actor_id":"2d17bcee-fb47-40fa-9237-396c52d5d23c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-12-12 20:44:30.26789+00	
00000000-0000-0000-0000-000000000000	0171cd6d-ecb4-4c21-8fbc-0925d6dc7420	{"action":"user_modified","actor_id":"2d17bcee-fb47-40fa-9237-396c52d5d23c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-12-12 20:44:30.268714+00	
00000000-0000-0000-0000-000000000000	45919dde-abaa-4dc5-9156-e6e471c0f71a	{"action":"logout","actor_id":"2d17bcee-fb47-40fa-9237-396c52d5d23c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-12 20:44:32.456079+00	
00000000-0000-0000-0000-000000000000	a8cbf792-a576-4e12-aa73-a381ded35e99	{"action":"login","actor_id":"2d17bcee-fb47-40fa-9237-396c52d5d23c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-12 20:44:58.771844+00	
00000000-0000-0000-0000-000000000000	0419c426-7924-4423-9a01-54b7b233059e	{"action":"logout","actor_id":"2d17bcee-fb47-40fa-9237-396c52d5d23c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-12 20:53:26.903321+00	
00000000-0000-0000-0000-000000000000	f914dd5a-505c-47bf-a2e8-3ea1e9d0e8b5	{"action":"user_recovery_requested","actor_id":"2d17bcee-fb47-40fa-9237-396c52d5d23c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-12-13 11:19:41.73468+00	
00000000-0000-0000-0000-000000000000	9adeb111-dbeb-47ed-8c38-e5ee01bcfceb	{"action":"login","actor_id":"2d17bcee-fb47-40fa-9237-396c52d5d23c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-13 11:20:07.02984+00	
00000000-0000-0000-0000-000000000000	2a4706d6-7f2b-45a3-b712-4a9756136dff	{"action":"user_updated_password","actor_id":"2d17bcee-fb47-40fa-9237-396c52d5d23c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-12-13 11:20:22.546036+00	
00000000-0000-0000-0000-000000000000	6ac4c2ca-1c82-443d-a037-0724a230e411	{"action":"user_modified","actor_id":"2d17bcee-fb47-40fa-9237-396c52d5d23c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-12-13 11:20:22.54944+00	
00000000-0000-0000-0000-000000000000	893af802-df3b-4815-a1d1-d543a262ce50	{"action":"logout","actor_id":"2d17bcee-fb47-40fa-9237-396c52d5d23c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-13 11:20:23.772951+00	
00000000-0000-0000-0000-000000000000	f836ffc4-9412-4c1f-8089-17a7f6f341fc	{"action":"login","actor_id":"2d17bcee-fb47-40fa-9237-396c52d5d23c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-13 11:20:29.655298+00	
00000000-0000-0000-0000-000000000000	dd029c56-a993-4df7-ae7d-dd0691b3b0eb	{"action":"logout","actor_id":"2d17bcee-fb47-40fa-9237-396c52d5d23c","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-13 11:34:28.281403+00	
00000000-0000-0000-0000-000000000000	b71911d1-3810-4240-992d-f598fb614b67	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"2d17bcee-fb47-40fa-9237-396c52d5d23c","user_phone":""}}	2025-12-13 11:35:56.602719+00	
00000000-0000-0000-0000-000000000000	54c049eb-8037-426b-9e18-847386649e4c	{"action":"user_signedup","actor_id":"b1c7abfd-6a48-4a2b-bcc1-641b699659dd","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-12-13 11:46:29.479603+00	
00000000-0000-0000-0000-000000000000	82bc331a-b45f-4b80-8139-2100467a8c4b	{"action":"login","actor_id":"b1c7abfd-6a48-4a2b-bcc1-641b699659dd","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-14 12:34:37.551582+00	
00000000-0000-0000-0000-000000000000	46535c25-7d74-48f6-8324-b7de06758fb4	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765658764315@example.test","user_id":"10116a8b-94f4-41cf-9d71-79132895dd64","user_phone":""}}	2025-12-14 12:50:40.66189+00	
00000000-0000-0000-0000-000000000000	01fb341a-7d50-4b7f-ae26-3381c313cd35	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"b1c7abfd-6a48-4a2b-bcc1-641b699659dd","user_phone":""}}	2025-12-14 12:50:40.673138+00	
00000000-0000-0000-0000-000000000000	102cb031-d384-45a6-8c83-95a1b76159a2	{"action":"user_signedup","actor_id":"137348ed-caa1-4528-8c16-68065c8ac13e","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-12-14 17:41:29.430451+00	
00000000-0000-0000-0000-000000000000	fa0dceb5-1327-4cd5-991e-585543119dfc	{"action":"login","actor_id":"137348ed-caa1-4528-8c16-68065c8ac13e","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-14 19:50:31.471823+00	
00000000-0000-0000-0000-000000000000	f014d1ca-3ce1-41f1-849f-409b260e7b38	{"action":"login","actor_id":"137348ed-caa1-4528-8c16-68065c8ac13e","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-14 21:46:00.860319+00	
00000000-0000-0000-0000-000000000000	512f17cb-1d5e-4928-aafe-d8db647c39d0	{"action":"logout","actor_id":"137348ed-caa1-4528-8c16-68065c8ac13e","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-14 21:48:29.992142+00	
00000000-0000-0000-0000-000000000000	3af74b1e-014b-4aaf-bc92-4e93fb235595	{"action":"login","actor_id":"b80f29c4-460a-4dd4-a40f-54bb19702061","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-14 21:49:09.921073+00	
00000000-0000-0000-0000-000000000000	2cbf8371-2a70-43bd-996a-d23167c231d7	{"action":"logout","actor_id":"b80f29c4-460a-4dd4-a40f-54bb19702061","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-14 21:50:46.553213+00	
00000000-0000-0000-0000-000000000000	92eeccb4-095a-4e74-8ffe-a63423859195	{"action":"login","actor_id":"137348ed-caa1-4528-8c16-68065c8ac13e","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-14 21:52:08.818+00	
00000000-0000-0000-0000-000000000000	2c7dba46-7f5b-44e5-8ffc-d01287878795	{"action":"token_refreshed","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-14 23:06:35.553766+00	
00000000-0000-0000-0000-000000000000	dfea8e1f-6237-4b3d-a062-5c7625d6ca5b	{"action":"token_refreshed","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-14 23:06:37.921442+00	
00000000-0000-0000-0000-000000000000	0fd14d0e-73ac-4a8e-95df-0a52107f8c56	{"action":"token_refreshed","actor_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-15 00:37:04.794943+00	
00000000-0000-0000-0000-000000000000	9bf7c429-c4a3-4053-abb0-d3928cee2b95	{"action":"login","actor_id":"e8f48b20-2208-41cf-bb36-211abc62dc82","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-17 19:41:52.211663+00	
00000000-0000-0000-0000-000000000000	39585ff7-a0c1-4006-aa5b-a027ea2366a5	{"action":"logout","actor_id":"e8f48b20-2208-41cf-bb36-211abc62dc82","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-17 19:42:21.657825+00	
00000000-0000-0000-0000-000000000000	24e57a84-3a11-44c0-87db-74dd138d8dcd	{"action":"login","actor_id":"e8f48b20-2208-41cf-bb36-211abc62dc82","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-17 19:42:38.804435+00	
00000000-0000-0000-0000-000000000000	8b3ca92e-0f7f-4a1f-838d-85cb99f08f66	{"action":"logout","actor_id":"e8f48b20-2208-41cf-bb36-211abc62dc82","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-17 19:44:17.980946+00	
00000000-0000-0000-0000-000000000000	f8644aeb-71e1-4c4f-9cb3-e00608728387	{"action":"login","actor_id":"e8f48b20-2208-41cf-bb36-211abc62dc82","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-17 19:44:25.160089+00	
00000000-0000-0000-0000-000000000000	0a1d2839-7f71-42c8-a14c-1fff509ab422	{"action":"token_refreshed","actor_id":"e8f48b20-2208-41cf-bb36-211abc62dc82","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-17 20:54:43.981692+00	
00000000-0000-0000-0000-000000000000	4eecc7ac-cdab-4f69-821e-8d9d528f61ab	{"action":"token_revoked","actor_id":"e8f48b20-2208-41cf-bb36-211abc62dc82","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-17 20:54:44.006549+00	
00000000-0000-0000-0000-000000000000	3b57628c-23ec-4a5c-bc14-a4e2a3f30029	{"action":"token_refreshed","actor_id":"e8f48b20-2208-41cf-bb36-211abc62dc82","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-17 20:54:47.659014+00	
00000000-0000-0000-0000-000000000000	9ad842db-3907-493c-8693-eaf3dd28967a	{"action":"token_refreshed","actor_id":"e8f48b20-2208-41cf-bb36-211abc62dc82","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-12-17 21:25:42.000824+00	
00000000-0000-0000-0000-000000000000	7689c508-6948-46bf-a991-6f80c0a61593	{"action":"logout","actor_id":"e8f48b20-2208-41cf-bb36-211abc62dc82","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-17 21:41:20.151075+00	
00000000-0000-0000-0000-000000000000	229735a9-e432-454c-a786-1065bbb84a17	{"action":"login","actor_id":"e8f48b20-2208-41cf-bb36-211abc62dc82","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-17 21:49:48.972742+00	
00000000-0000-0000-0000-000000000000	93814ed5-1b48-4b6e-b2e5-698fdb0f5e65	{"action":"logout","actor_id":"e8f48b20-2208-41cf-bb36-211abc62dc82","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-17 22:30:50.67466+00	
00000000-0000-0000-0000-000000000000	5a68b4ce-6550-4754-8206-66df5260f02c	{"action":"login","actor_id":"e8f48b20-2208-41cf-bb36-211abc62dc82","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-17 22:31:03.358825+00	
00000000-0000-0000-0000-000000000000	c4ca2bf7-541b-4d00-864d-efe61f0c411c	{"action":"logout","actor_id":"e8f48b20-2208-41cf-bb36-211abc62dc82","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-17 22:32:33.84537+00	
00000000-0000-0000-0000-000000000000	9aeb051e-6b72-46b4-9848-c32206cbb5d3	{"action":"login","actor_id":"e8f48b20-2208-41cf-bb36-211abc62dc82","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-24 00:00:40.323523+00	
00000000-0000-0000-0000-000000000000	f0c15117-cebe-4c08-bf54-b0b69f0aa58c	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"e8f48b20-2208-41cf-bb36-211abc62dc82","user_phone":""}}	2025-12-24 00:02:47.782934+00	
00000000-0000-0000-0000-000000000000	b1c8d4fb-3696-44fd-aece-9bee80470a39	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765742467236@example.test","user_id":"c9db52e1-2147-4b05-bf90-e26cff7e8e98","user_phone":""}}	2025-12-24 00:16:21.561666+00	
00000000-0000-0000-0000-000000000000	4ed20740-29bb-4bf5-918b-6aca38303468	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765896280651@example.test","user_id":"8ca64374-03ba-4e68-9c9f-3c84f292f11e","user_phone":""}}	2025-12-24 00:16:21.582599+00	
00000000-0000-0000-0000-000000000000	fee0f809-f1f3-41e7-abad-53dbfff399c9	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765741799574@example.test","user_id":"13ebae97-69cf-4d36-ba89-4aed358cabaa","user_phone":""}}	2025-12-24 00:16:21.771021+00	
00000000-0000-0000-0000-000000000000	222c78be-2183-4c64-813d-217746ce648d	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765898930362@example.test","user_id":"13642873-16e9-4394-956c-e0bd9a57146c","user_phone":""}}	2025-12-24 00:16:21.775622+00	
00000000-0000-0000-0000-000000000000	6edce13e-da91-41f4-b4ae-7e1cab548499	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765742595981@example.test","user_id":"873728e6-f030-43ef-bdd0-71170b2d7577","user_phone":""}}	2025-12-24 00:16:21.78035+00	
00000000-0000-0000-0000-000000000000	46700d5c-2599-4304-9721-1462286b29b1	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765742531675@example.test","user_id":"7861b38a-14d1-4635-beaa-00b324a9cc04","user_phone":""}}	2025-12-24 00:16:21.781494+00	
00000000-0000-0000-0000-000000000000	2754b123-92d8-4346-97d7-beb53a88060f	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765742833615@example.test","user_id":"e8e500b4-e19f-4c83-aa06-aca85646db87","user_phone":""}}	2025-12-24 00:16:21.79554+00	
00000000-0000-0000-0000-000000000000	f80f14cf-c017-4460-8781-e181c2a29c99	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765899597166@example.test","user_id":"3d316780-ac23-492b-adb4-3ed3f575b1df","user_phone":""}}	2025-12-24 00:16:21.799323+00	
00000000-0000-0000-0000-000000000000	c1a96819-9c40-497b-8265-15e3f7e562c0	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765899661546@example.test","user_id":"f86acfb4-fad3-4ad9-9e88-c6df90b856af","user_phone":""}}	2025-12-24 00:16:21.820519+00	
00000000-0000-0000-0000-000000000000	072ce8c2-5103-42a0-b9ab-14365df035e2	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765742896891@example.test","user_id":"db7ae5bd-844c-4cef-8efa-cb01f9869bca","user_phone":""}}	2025-12-24 00:16:21.819829+00	
00000000-0000-0000-0000-000000000000	e3027389-0766-412c-979c-1a0c978f2e27	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765896344039@example.test","user_id":"1afb9ce3-a5f2-4133-946f-01f5d0641050","user_phone":""}}	2025-12-24 00:16:21.821683+00	
00000000-0000-0000-0000-000000000000	89f4bbbd-2a6a-4859-9cf8-4628c135cb40	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765741672441@example.test","user_id":"eb956f73-a91b-43cf-973a-7b3e8cf3f32a","user_phone":""}}	2025-12-24 00:16:21.834512+00	
00000000-0000-0000-0000-000000000000	9ae3f160-6a08-4e10-8d23-1e7301903b61	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765898803151@example.test","user_id":"fbff5156-f3a4-41a1-9b1d-b40bf6e8aedb","user_phone":""}}	2025-12-24 00:16:22.240983+00	
00000000-0000-0000-0000-000000000000	48c3ad0f-93e0-4dfb-b128-49104e046be0	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765741736068@example.test","user_id":"0a76fa00-6500-4d97-9081-62184a82dee4","user_phone":""}}	2025-12-24 00:16:28.104421+00	
00000000-0000-0000-0000-000000000000	6018ca66-e246-4b00-8f73-adfe9326542b	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765748285893@example.test","user_id":"1319fae5-2ad2-4d96-a9f1-e394322232ab","user_phone":""}}	2025-12-24 00:18:11.821474+00	
00000000-0000-0000-0000-000000000000	edbbad7d-2446-4a4d-90ff-2e6e7dd5dad6	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765748222394@example.test","user_id":"dadf3ecd-91a7-4f2a-987e-e1ef0852f855","user_phone":""}}	2025-12-24 00:18:11.828707+00	
00000000-0000-0000-0000-000000000000	a9458e04-1e47-4137-aba4-3138d5652ca0	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765749083854@example.test","user_id":"6d195b9d-5ed0-4e36-bfd6-c5a8f7628076","user_phone":""}}	2025-12-24 00:18:11.837801+00	
00000000-0000-0000-0000-000000000000	7c9b9d62-06aa-405a-80d3-0fea79e34a30	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765749019559@example.test","user_id":"1faae2a4-1839-4899-8d07-e5897f81c412","user_phone":""}}	2025-12-24 00:18:11.841625+00	
00000000-0000-0000-0000-000000000000	01988ef6-9d10-43e5-801a-e6b74c73a06d	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765748158867@example.test","user_id":"caa1224b-46cf-4657-9ff4-f3a5669b4d09","user_phone":""}}	2025-12-24 00:18:11.848739+00	
00000000-0000-0000-0000-000000000000	bfd90a02-095a-4379-9b6f-51615f9b1ed6	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765748955149@example.test","user_id":"a8bbdb5f-3dc6-44c2-a1ad-0989205762bf","user_phone":""}}	2025-12-24 00:18:11.849596+00	
00000000-0000-0000-0000-000000000000	297a3eb5-a564-4438-b263-fe9755d10255	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765749320045@example.test","user_id":"fe7b85c2-dbd1-42d4-9113-86f6c7078c7d","user_phone":""}}	2025-12-24 00:18:11.85376+00	
00000000-0000-0000-0000-000000000000	5c354c4d-1572-43f9-8f45-0bc867f09910	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765742960197@example.test","user_id":"01002186-df8a-4f67-b7dc-ba91b8812a58","user_phone":""}}	2025-12-24 00:18:12.045654+00	
00000000-0000-0000-0000-000000000000	abe2b8e3-ad01-4799-ae55-86ef838d9fbc	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765764700903@example.test","user_id":"92ef1051-7ce5-493b-96a2-5cfffca2c830","user_phone":""}}	2025-12-24 00:18:39.148155+00	
00000000-0000-0000-0000-000000000000	fb1eff89-0c76-4ccf-a2aa-b91cbdd38c87	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765749383374@example.test","user_id":"31befba2-f5df-4342-b7ab-fc6f36f21842","user_phone":""}}	2025-12-24 00:18:39.147794+00	
00000000-0000-0000-0000-000000000000	8bd5d695-7ecf-4225-84d2-77acafecc13f	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765764462688@example.test","user_id":"1df93792-cd78-4d8e-833a-b52b81c45794","user_phone":""}}	2025-12-24 00:18:39.153747+00	
00000000-0000-0000-0000-000000000000	5d2551e8-796e-4ce7-b814-9177ba55ad57	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765832600111@example.test","user_id":"f99dbc4e-f3cf-4643-9880-3a52f57fd422","user_phone":""}}	2025-12-24 00:18:39.157713+00	
00000000-0000-0000-0000-000000000000	58f40814-3959-4345-bbef-56fda907b8c8	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765764827650@example.test","user_id":"b8aa2755-2b6c-49c3-8dd3-65bd8b464983","user_phone":""}}	2025-12-24 00:18:39.162266+00	
00000000-0000-0000-0000-000000000000	f84fd9cd-cfd3-4884-924a-4dc7c4ce9049	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765764398285@example.test","user_id":"c526b9a2-11af-4151-bbb7-24103be27a6f","user_phone":""}}	2025-12-24 00:18:39.171981+00	
00000000-0000-0000-0000-000000000000	9cfc1e9f-10f0-43b8-954d-78e04db9f702	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765763604023@example.test","user_id":"2370d27f-69fe-48f0-8f90-eb71032f3881","user_phone":""}}	2025-12-24 00:18:39.170203+00	
00000000-0000-0000-0000-000000000000	6d04f553-3614-4bd4-823c-1c347ed4f6bf	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765763667619@example.test","user_id":"d0102471-b088-4c89-8f49-2f0d979cef8e","user_phone":""}}	2025-12-24 00:18:39.177215+00	
00000000-0000-0000-0000-000000000000	373e4e87-3ee8-4067-9178-4c5ba69feb34	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765749446695@example.test","user_id":"037aea7d-2412-4294-97aa-1d0a69352408","user_phone":""}}	2025-12-24 00:18:39.177354+00	
00000000-0000-0000-0000-000000000000	b46c6d16-f688-4efc-8726-8a235e4a72ce	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765832663587@example.test","user_id":"41372bf9-96c5-436c-9188-1728fe6f0a36","user_phone":""}}	2025-12-24 00:18:39.180107+00	
00000000-0000-0000-0000-000000000000	efbb8c97-06b5-4252-bb2c-784af482a209	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765764764267@example.test","user_id":"7178aab2-e970-4277-92da-8ecdbc18e87a","user_phone":""}}	2025-12-24 00:18:39.18247+00	
00000000-0000-0000-0000-000000000000	0f35b1bc-92d3-4e1c-9417-3046ec7b1fcc	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765763540454@example.test","user_id":"9ac49bbb-59b6-4879-9522-73e706cac112","user_phone":""}}	2025-12-24 00:18:39.189313+00	
00000000-0000-0000-0000-000000000000	88a94e8e-9d55-426e-80aa-13e7bebbdd7b	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765764333923@example.test","user_id":"2f6a8f24-9dce-414d-87cc-555f97103adb","user_phone":""}}	2025-12-24 00:18:39.408347+00	
00000000-0000-0000-0000-000000000000	6ebd3d6e-a026-42a6-9198-763dd2d8ac47	{"action":"user_signedup","actor_id":"60d3c5b0-558a-4e24-ab05-d93192989d38","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2026-02-19 23:42:00.00314+00	
00000000-0000-0000-0000-000000000000	d400bbfa-a05f-433e-9fc5-350b42001085	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765832727199@example.test","user_id":"bde4ba89-3255-4f49-9fc4-c15d059a8d38","user_phone":""}}	2025-12-24 00:18:39.415661+00	
00000000-0000-0000-0000-000000000000	8359bcb1-809d-46b3-988b-ce862e2456e6	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765900028941@example.test","user_id":"bfa1dc01-d569-435a-9486-3f68d854e437","user_phone":""}}	2025-12-24 00:19:40.739547+00	
00000000-0000-0000-0000-000000000000	6463e475-1b37-48c5-9caf-81d59f14817a	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765895120207@example.test","user_id":"e1c234a2-4ca1-4494-a001-d4dc3c164fb1","user_phone":""}}	2025-12-24 00:19:40.740505+00	
00000000-0000-0000-0000-000000000000	fd2bace1-5d1e-41cd-8bb7-438f98508d20	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765895978319@example.test","user_id":"eec49dc1-bd95-4a4f-8657-4a7a6c5c4187","user_phone":""}}	2025-12-24 00:19:40.743562+00	
00000000-0000-0000-0000-000000000000	9d76f899-0948-4752-9d52-0a50b159d92e	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765896217341@example.test","user_id":"e20b6540-4b80-4154-9eec-35b92b74b901","user_phone":""}}	2025-12-24 00:19:40.744474+00	
00000000-0000-0000-0000-000000000000	ab0442a3-b2ea-45ec-afcf-6d8e0d0ffe0e	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765895914001@example.test","user_id":"7a86ea89-f951-453f-a995-188247e4e6b2","user_phone":""}}	2025-12-24 00:19:40.748985+00	
00000000-0000-0000-0000-000000000000	fc978f47-19f3-46c8-824e-1b9d69cc5112	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765895849734@example.test","user_id":"ec0697fa-84a0-491b-95f0-ceef41d1b601","user_phone":""}}	2025-12-24 00:19:40.752703+00	
00000000-0000-0000-0000-000000000000	791e2564-1764-46c8-b8e5-a66342618cc4	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765899965576@example.test","user_id":"12456460-7013-40c1-a13c-c034e53070ed","user_phone":""}}	2025-12-24 00:19:40.755515+00	
00000000-0000-0000-0000-000000000000	d1964b98-7014-4190-b74d-8d8de07aae84	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765899726143@example.test","user_id":"9f491d46-3543-424c-8aa4-dcb210b2a1e6","user_phone":""}}	2025-12-24 00:19:40.755626+00	
00000000-0000-0000-0000-000000000000	28ae2f44-a356-4dec-a0fb-76cf597f1080	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765903002652@example.test","user_id":"731422d3-0e5d-4a71-93d9-8f3f9fd35ad9","user_phone":""}}	2025-12-24 00:19:40.755399+00	
00000000-0000-0000-0000-000000000000	8823090e-705f-4e14-afe3-55eed767c5de	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765895183894@example.test","user_id":"91400512-9369-46f1-ac24-09dd0020bdff","user_phone":""}}	2025-12-24 00:19:40.764629+00	
00000000-0000-0000-0000-000000000000	ba661474-97bd-4b54-84d9-4ec4dac2df31	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765898866760@example.test","user_id":"47bef956-abe8-4e24-accc-bdb849d2fd0d","user_phone":""}}	2025-12-24 00:19:40.770328+00	
00000000-0000-0000-0000-000000000000	9dcdfb37-a3d7-4ffb-b0df-3bbcc3e88d7d	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765903794967@example.test","user_id":"72ed60fc-f651-48fc-af7e-f303392b9a8a","user_phone":""}}	2025-12-24 00:19:40.776789+00	
00000000-0000-0000-0000-000000000000	01e3c6c3-1dae-4ee4-b081-0ae226c43457	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765903066227@example.test","user_id":"46ddc92f-5514-41e1-a751-98fec2fb3878","user_phone":""}}	2025-12-24 00:19:40.77669+00	
00000000-0000-0000-0000-000000000000	30a3ff24-d6a2-4b8e-80a6-a0c3455540d6	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765904165909@example.test","user_id":"e2ecf4a6-b7da-4a04-b227-7bead6d5efa5","user_phone":""}}	2025-12-24 00:19:40.776876+00	
00000000-0000-0000-0000-000000000000	f3c41e8c-f7c2-4c31-b48f-3a922392d6c1	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765903730447@example.test","user_id":"73f33b14-8552-41bb-bc7d-067387e1424d","user_phone":""}}	2025-12-24 00:19:40.777106+00	
00000000-0000-0000-0000-000000000000	15c5a80e-d0b9-4fcd-81dd-f38963bb6cb4	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765900092313@example.test","user_id":"bf5b0deb-392d-4b3a-8c28-e0ea747256e1","user_phone":""}}	2025-12-24 00:19:40.777287+00	
00000000-0000-0000-0000-000000000000	819c37e4-9018-4a46-a627-2d24e73d662b	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765895056589@example.test","user_id":"7e3b9089-60e7-4e9c-b50e-b8e86c695dc8","user_phone":""}}	2025-12-24 00:19:40.777968+00	
00000000-0000-0000-0000-000000000000	3cbe17de-6f1d-432f-93df-11c3caf5a2f9	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765904102572@example.test","user_id":"d9f7b65c-fd12-4b7a-bb83-e0c7db5aca00","user_phone":""}}	2025-12-24 00:19:40.779177+00	
00000000-0000-0000-0000-000000000000	fc0974d1-0b01-4335-8f89-cda57d80138d	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765903859464@example.test","user_id":"91e7a4df-5401-4032-a0c6-1c03154a6d88","user_phone":""}}	2025-12-24 00:19:40.970555+00	
00000000-0000-0000-0000-000000000000	cc7c9a5b-4890-40a7-af06-2ba012f0181f	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765902939189@example.test","user_id":"67df5127-b2ee-4569-bcb9-36e71865de7d","user_phone":""}}	2025-12-24 00:19:41.068034+00	
00000000-0000-0000-0000-000000000000	82fe1bad-6fde-4bea-964d-5d1f5cf3e3f6	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765946580848@example.test","user_id":"9ad7da58-ac9c-4647-bfcd-fb050939956c","user_phone":""}}	2025-12-24 00:20:53.619387+00	
00000000-0000-0000-0000-000000000000	26e0ed91-c574-4730-8190-43d75316553d	{"action":"logout","actor_id":"60d3c5b0-558a-4e24-ab05-d93192989d38","actor_username":"fouadbechar9@gmail.com","actor_via_sso":false,"log_type":"account"}	2026-02-20 00:02:35.411766+00	
00000000-0000-0000-0000-000000000000	ffd1139c-98aa-4d8e-bdcc-344e60c741ce	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765922054151@example.test","user_id":"45e3d227-df99-449b-aa07-bf8f495f876f","user_phone":""}}	2025-12-24 00:20:53.622114+00	
00000000-0000-0000-0000-000000000000	1c73475f-445e-4f98-b615-0d3359bff1fa	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765947439250@example.test","user_id":"e950f109-b3df-435b-b353-ee666c833225","user_phone":""}}	2025-12-24 00:20:53.654311+00	
00000000-0000-0000-0000-000000000000	f9f9bc07-8313-4dd1-8c55-e700f0dacff4	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765943896534@example.test","user_id":"ad599ca9-697d-4b33-8457-e4695b0043ad","user_phone":""}}	2025-12-24 00:21:27.911355+00	
00000000-0000-0000-0000-000000000000	4b23fc4b-cdf0-4a50-82a5-7047ed7879a9	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765947503609@example.test","user_id":"09ba0e7e-253d-4a8c-bf91-33dc708bae0f","user_phone":""}}	2025-12-24 00:21:28.082931+00	
00000000-0000-0000-0000-000000000000	f50d148e-0593-4b42-a4c8-13919a2d19a9	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766074099551@example.test","user_id":"2ba1299f-adc2-42ea-a78d-9a4982d6b8a4","user_phone":""}}	2025-12-24 00:22:08.721695+00	
00000000-0000-0000-0000-000000000000	7daf2b6a-fb51-4f57-9734-f08157915f5a	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766077860781@example.test","user_id":"2578abf6-b51b-43f4-ab5c-6c67bc1df523","user_phone":""}}	2025-12-24 00:22:08.742505+00	
00000000-0000-0000-0000-000000000000	43512d55-6d55-4706-8886-461d8d18f794	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766264926789@example.test","user_id":"3309c71b-0ff7-41d7-a5ee-e1d1a556d299","user_phone":""}}	2025-12-24 00:23:03.155193+00	
00000000-0000-0000-0000-000000000000	8dbfaa29-660c-4f42-96a3-fdb70c583f7f	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766017656709@example.test","user_id":"951d1236-6d8e-49d0-a1dc-1a75f726e78e","user_phone":""}}	2025-12-24 00:23:03.166292+00	
00000000-0000-0000-0000-000000000000	757a8b78-998d-4d90-9914-516687af8660	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"52621b81-72ae-4ebd-b19b-61e68374f50d","user_phone":""}}	2025-12-24 00:23:26.346916+00	
00000000-0000-0000-0000-000000000000	2edf74da-17d4-4473-9f29-0956d73499ef	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"b80f29c4-460a-4dd4-a40f-54bb19702061","user_phone":""}}	2025-12-24 00:23:26.353076+00	
00000000-0000-0000-0000-000000000000	957a653b-58ec-4f62-aef6-335fbffbaa1e	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766266087982@example.test","user_id":"540777d6-76d6-4a7a-912a-c239969919ae","user_phone":""}}	2025-12-24 00:23:42.997932+00	
00000000-0000-0000-0000-000000000000	9470b0f9-a7f7-4519-8c51-97a43f501291	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765942672097@example.test","user_id":"dfa607e9-134c-42d3-b8e9-6a69dc0aa31d","user_phone":""}}	2025-12-24 00:20:53.623256+00	
00000000-0000-0000-0000-000000000000	7a246243-85f2-4c11-97a2-a35920198477	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765833763248@example.test","user_id":"379fef03-689d-4c23-b06a-afa361c00c29","user_phone":""}}	2025-12-24 00:20:53.625031+00	
00000000-0000-0000-0000-000000000000	f22d8905-590c-4803-92f0-a7ca764df9f3	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765921989865@example.test","user_id":"43c84745-d499-4f95-a0cf-e230bc852ffc","user_phone":""}}	2025-12-24 00:20:53.626794+00	
00000000-0000-0000-0000-000000000000	9d1a9f04-d70d-46cd-9d3e-0f68ea45bea0	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765922419607@example.test","user_id":"6b78c60a-b564-46dd-bfcc-8b334b25aad3","user_phone":""}}	2025-12-24 00:20:53.62901+00	
00000000-0000-0000-0000-000000000000	229e5cbe-3032-420e-a742-0f35eca68932	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765922482962@example.test","user_id":"638b4b43-bb7e-465f-b0ea-e53ba3af941c","user_phone":""}}	2025-12-24 00:20:53.630157+00	
00000000-0000-0000-0000-000000000000	5d081664-0b08-455f-adc6-d282f59c7c76	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765921258287@example.test","user_id":"6b26410e-eb32-40a1-bc93-cededef99486","user_phone":""}}	2025-12-24 00:20:53.636638+00	
00000000-0000-0000-0000-000000000000	86eb4a49-ea93-4197-8e20-a667ed9d4961	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765833397769@example.test","user_id":"3fe42f41-ac6a-46be-9263-3801000a5f5a","user_phone":""}}	2025-12-24 00:20:53.638717+00	
00000000-0000-0000-0000-000000000000	46cc1b84-ddad-4122-9313-7e47644ea178	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765833462179@example.test","user_id":"07335884-86c0-4cdf-bc77-a8642125b12e","user_phone":""}}	2025-12-24 00:20:53.640557+00	
00000000-0000-0000-0000-000000000000	699d5574-bf7d-4b71-8086-c7d7b6b57bd1	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765833889886@example.test","user_id":"15e3c24b-e58c-43e3-b98d-392e58c613a3","user_phone":""}}	2025-12-24 00:20:53.656663+00	
00000000-0000-0000-0000-000000000000	92fda44f-ed61-4de4-9d3f-4dac4bdd212a	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765946708040@example.test","user_id":"73c7a902-c7aa-4db5-8a1d-7c2380bda80c","user_phone":""}}	2025-12-24 00:20:53.659957+00	
00000000-0000-0000-0000-000000000000	d6cbb73a-8323-43c6-aa16-0d39533c79d0	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765833826591@example.test","user_id":"48b7bde5-7bae-4c43-a47d-54f4225801ee","user_phone":""}}	2025-12-24 00:20:53.660609+00	
00000000-0000-0000-0000-000000000000	7da75e3f-7cfc-48db-b048-414d982785d8	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765833526628@example.test","user_id":"f0573c0a-bbfb-4997-8a1d-da2c37ec4ebb","user_phone":""}}	2025-12-24 00:20:53.66312+00	
00000000-0000-0000-0000-000000000000	89ab156c-7edb-4662-a635-6e75d4460d2e	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765921321895@example.test","user_id":"d1bfada3-7227-4aa0-a5ad-81d41d5e8cc2","user_phone":""}}	2025-12-24 00:20:53.789787+00	
00000000-0000-0000-0000-000000000000	f4710eea-cb9f-47f3-9971-fbcbc4e3d4e7	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765922356256@example.test","user_id":"e53538e7-1967-4c08-a24e-f312f2fecadd","user_phone":""}}	2025-12-24 00:20:53.795684+00	
00000000-0000-0000-0000-000000000000	9d063fd4-c1b0-4e12-b17f-c035c3e40354	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765943959920@example.test","user_id":"dd955bcb-9512-407a-a3b2-24c760074c8e","user_phone":""}}	2025-12-24 00:20:53.797256+00	
00000000-0000-0000-0000-000000000000	867c89a8-7660-4031-8290-aa001d4d0dd7	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765904229282@example.test","user_id":"0cf8d005-1b04-49ed-b194-da3e52358b04","user_phone":""}}	2025-12-24 00:21:27.905305+00	
00000000-0000-0000-0000-000000000000	e6b1663b-e4b0-4a02-a89a-adaf1426dff4	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765943530445@example.test","user_id":"0e63027d-1af0-4e58-a4b7-e22e07d09d3f","user_phone":""}}	2025-12-24 00:21:27.907542+00	
00000000-0000-0000-0000-000000000000	290a8632-3936-41d2-b057-fff618b44438	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765946644503@example.test","user_id":"220dde9b-bbda-4059-b8c2-0d9d844fc9e1","user_phone":""}}	2025-12-24 00:21:27.915342+00	
00000000-0000-0000-0000-000000000000	808aac6c-7898-44ad-b212-11c1833dc981	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766016730903@example.test","user_id":"71b5a801-3346-4f54-8070-8535d5a46d8f","user_phone":""}}	2025-12-24 00:21:27.907652+00	
00000000-0000-0000-0000-000000000000	797f86ca-e4ab-4570-a1d9-05c82b82a111	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765947745426@example.test","user_id":"803cb702-aee7-47ad-8489-5da2ef78864e","user_phone":""}}	2025-12-24 00:21:27.907327+00	
00000000-0000-0000-0000-000000000000	c04a9add-a4c8-435c-a90a-8c96d2c43404	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765943594845@example.test","user_id":"feddaea0-0c6e-4dbc-9218-6cd67c77087b","user_phone":""}}	2025-12-24 00:21:27.915145+00	
00000000-0000-0000-0000-000000000000	775e3a7d-00c3-4c24-b0d0-db77053e8a95	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765943833172@example.test","user_id":"eec12588-5caf-4642-81ac-88e79ba8eb1e","user_phone":""}}	2025-12-24 00:21:27.913761+00	
00000000-0000-0000-0000-000000000000	6ed5f12b-36a9-4a9b-96d6-9611fac6298e	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765947374803@example.test","user_id":"2b710f69-b467-466c-b37c-255875d75cff","user_phone":""}}	2025-12-24 00:20:53.647074+00	
00000000-0000-0000-0000-000000000000	56c1398e-c784-4c47-adec-27bf5ba718ad	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765922118380@example.test","user_id":"403fe413-62af-47d5-90ea-d921c22888c8","user_phone":""}}	2025-12-24 00:20:53.659483+00	
00000000-0000-0000-0000-000000000000	f81bd3f4-a491-4dba-8197-19b6369f1888	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766016794373@example.test","user_id":"28087092-d379-4b49-9670-62320ef0d49c","user_phone":""}}	2025-12-24 00:21:27.909831+00	
00000000-0000-0000-0000-000000000000	66e7b07a-ec07-4c72-b3aa-11029c619eda	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765947872256@example.test","user_id":"50802fe6-8ea5-49f4-babd-0a106b599ea5","user_phone":""}}	2025-12-24 00:21:28.046405+00	
00000000-0000-0000-0000-000000000000	e2ec24e1-122e-4b25-a251-960aca250e1e	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766099037599@example.test","user_id":"36f4445a-23ab-48ab-b07b-e343a7bf9c3d","user_phone":""}}	2025-12-24 00:22:08.696145+00	
00000000-0000-0000-0000-000000000000	0acbcd0a-dc22-4a7a-94a6-42ca6241bcd5	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766073730828@example.test","user_id":"0d8d0768-3baf-41e7-bec6-e4b3995b2838","user_phone":""}}	2025-12-24 00:22:08.734794+00	
00000000-0000-0000-0000-000000000000	a9aa0442-9946-43a2-9324-baccdf858565	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766017892358@example.test","user_id":"cdee0c7b-4416-4321-892e-85d0d83b0422","user_phone":""}}	2025-12-24 00:23:03.16272+00	
00000000-0000-0000-0000-000000000000	c81f3690-9416-4192-b936-ff6a48fb2b99	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766535063077@example.test","user_id":"62ffb936-ea35-4230-a0cc-9596943210d3","user_phone":""}}	2025-12-24 00:23:26.345467+00	
00000000-0000-0000-0000-000000000000	3c779f0c-0672-49d4-aaff-cc9bbe718ba4	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766527808405@example.test","user_id":"b80275bb-574c-4e90-b542-be82e65e1135","user_phone":""}}	2025-12-24 00:23:43.00002+00	
00000000-0000-0000-0000-000000000000	821ec00b-1af7-4686-aea4-b346373b5117	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766527871941@example.test","user_id":"9978e64c-2e7e-4468-a9be-8c87f1148d73","user_phone":""}}	2025-12-24 00:23:43.015923+00	
00000000-0000-0000-0000-000000000000	e2a2efef-6699-477d-9f01-ebfad6a170b4	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765942799142@example.test","user_id":"49a87988-8ee8-4161-9e67-b85bfe0e1b53","user_phone":""}}	2025-12-24 00:21:27.926086+00	
00000000-0000-0000-0000-000000000000	009c06af-8287-421d-ae42-ac08fe83a69b	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765943466133@example.test","user_id":"b3759936-867c-4c47-aa47-9e3fee716acf","user_phone":""}}	2025-12-24 00:21:28.082667+00	
00000000-0000-0000-0000-000000000000	3dfd2e2b-a411-453f-abaf-87e175b40c64	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766073972733@example.test","user_id":"2e4f7dd4-b61e-4d8f-bd46-6bf691a913be","user_phone":""}}	2025-12-24 00:22:08.612384+00	
00000000-0000-0000-0000-000000000000	54747437-1609-40b1-b70e-700e69250502	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766077987515@example.test","user_id":"285df727-d6ee-4428-aece-064009654411","user_phone":""}}	2025-12-24 00:22:08.722897+00	
00000000-0000-0000-0000-000000000000	5df2b98f-fb6a-4ceb-a03c-bcb5f3028533	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766077924178@example.test","user_id":"5d84d267-fa8b-42e9-ab47-bfadfe066256","user_phone":""}}	2025-12-24 00:22:08.740899+00	
00000000-0000-0000-0000-000000000000	3673b751-a552-4f84-90e7-fc5d57f3d59b	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766264863125@example.test","user_id":"77b3e141-0ab9-4aec-ac4c-3245aaad298d","user_phone":""}}	2025-12-24 00:23:03.154454+00	
00000000-0000-0000-0000-000000000000	f06baebd-8062-441b-9472-084866b7c3ae	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766017528256@example.test","user_id":"db905614-bce3-4007-aa75-23e0024c5855","user_phone":""}}	2025-12-24 00:23:03.170442+00	
00000000-0000-0000-0000-000000000000	e670c56d-f760-4c80-9e0d-ef38d3ec6e34	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766017955752@example.test","user_id":"2b3cb98e-2e88-4014-a4b8-9410ba9f91db","user_phone":""}}	2025-12-24 00:23:03.178256+00	
00000000-0000-0000-0000-000000000000	c69128c2-ceb5-4d13-8925-41dc8b9d27f7	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766100326706@example.test","user_id":"3a787e4e-b7f6-4d5e-87ef-96610d969f0b","user_phone":""}}	2025-12-24 00:23:03.361774+00	
00000000-0000-0000-0000-000000000000	4cd52b55-b66a-4956-8c12-5593e2b81ee0	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766265593316@example.test","user_id":"2cf19f61-f315-4a5f-9248-e04ca409f7fd","user_phone":""}}	2025-12-24 00:23:03.365154+00	
00000000-0000-0000-0000-000000000000	af1f28b8-0c77-4c11-9469-6f0cab5875cf	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766265657650@example.test","user_id":"b5a0f5bf-94f6-4f48-b945-2c50095db6b1","user_phone":""}}	2025-12-24 00:23:03.384751+00	
00000000-0000-0000-0000-000000000000	ac54f381-fd30-4c34-a0e1-19263ac2f4f8	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766534998680@example.test","user_id":"f2e302a7-7087-4349-8486-aec6fed4ca8d","user_phone":""}}	2025-12-24 00:23:26.326398+00	
00000000-0000-0000-0000-000000000000	8cfa9663-0d26-4fb1-90d3-c7e211dc2474	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766535302397@example.test","user_id":"ef1ae65a-321d-41d4-bb2f-5d252436692c","user_phone":""}}	2025-12-24 00:23:26.342417+00	
00000000-0000-0000-0000-000000000000	c89c719f-584a-4391-86bf-fe97873e7ff5	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766534267839@example.test","user_id":"60029095-19b4-4981-9ec1-390bad4cfee4","user_phone":""}}	2025-12-24 00:23:43.00378+00	
00000000-0000-0000-0000-000000000000	0fa59324-5c73-4c24-8ee3-e832bbc37f7a	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766527935494@example.test","user_id":"715fe01c-1a5d-4606-ac76-340f44783d3d","user_phone":""}}	2025-12-24 00:23:43.013251+00	
00000000-0000-0000-0000-000000000000	4b68ea94-8ea8-4e6a-b224-abeda3785617	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766534204150@example.test","user_id":"b71d135b-c452-456d-a02c-3dd85c90abcb","user_phone":""}}	2025-12-24 00:23:43.018568+00	
00000000-0000-0000-0000-000000000000	e947312f-352f-4f61-af29-14190a487b12	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766265961305@example.test","user_id":"8e9b8743-d818-427c-906b-4a2e756a0e03","user_phone":""}}	2025-12-24 00:23:43.026008+00	
00000000-0000-0000-0000-000000000000	e55af7de-383a-4e09-bcfc-856254a4d9f7	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765942735630@example.test","user_id":"974074a9-80ca-49c7-acdc-39fdc34dc1a7","user_phone":""}}	2025-12-24 00:21:28.070331+00	
00000000-0000-0000-0000-000000000000	5715b40d-f990-4408-ac1a-3db524355b19	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766076828909@example.test","user_id":"c0e9e1d3-6d38-46de-87bf-31d4c1922c00","user_phone":""}}	2025-12-24 00:22:08.699226+00	
00000000-0000-0000-0000-000000000000	bc1f9d80-ab4c-49b6-9ff5-cf916906e2b7	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766072936416@example.test","user_id":"9d11a6b6-e084-430f-a2f7-4cfc0133d0e8","user_phone":""}}	2025-12-24 00:22:08.735696+00	
00000000-0000-0000-0000-000000000000	a92c7a4d-0c73-4aa6-a1c7-4a169b9c0f74	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766099833318@example.test","user_id":"cdac1846-5a68-42d2-9378-3645a0c16268","user_phone":""}}	2025-12-24 00:23:03.159623+00	
00000000-0000-0000-0000-000000000000	a3ae9e18-60d2-4760-abfb-e2544b1b7c6e	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765921194721@example.test","user_id":"bb9a7286-615a-41bb-8967-4a2040a77f28","user_phone":""}}	2025-12-24 00:21:28.067864+00	
00000000-0000-0000-0000-000000000000	f192fd6a-dc77-4d32-b3ea-b14a71e61763	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766077493306@example.test","user_id":"fab56297-ec9f-43be-a18b-7dc9e29e7355","user_phone":""}}	2025-12-24 00:22:08.739139+00	
00000000-0000-0000-0000-000000000000	41f817f1-fc8b-4801-930d-3808d4da04cc	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766099897615@example.test","user_id":"638e64ff-e2e8-4bc0-8a6f-8a6481ff031c","user_phone":""}}	2025-12-24 00:23:03.150365+00	
00000000-0000-0000-0000-000000000000	195f3ccd-a95d-4dd0-b8c7-36f832910e2b	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766100199928@example.test","user_id":"4a0fc9bd-79ca-42f8-852f-403aa2911c56","user_phone":""}}	2025-12-24 00:23:03.164922+00	
00000000-0000-0000-0000-000000000000	a75a2821-3788-41d2-b79b-aabb51c2ce79	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1765947808831@example.test","user_id":"504f49f7-7290-47ec-b4e2-e00a39a24d4a","user_phone":""}}	2025-12-24 00:21:28.084666+00	
00000000-0000-0000-0000-000000000000	e9d5f093-3c46-42ad-a730-9d3fe8c174a3	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766072872719@example.test","user_id":"088759e1-daa1-4cf3-b853-12aabaf673e0","user_phone":""}}	2025-12-24 00:22:08.60718+00	
00000000-0000-0000-0000-000000000000	f1b7e743-52fe-40eb-9df4-9298837fbeb0	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766099101292@example.test","user_id":"40fb6722-ecfd-4715-8cc8-8fa8c72dc48c","user_phone":""}}	2025-12-24 00:22:08.723228+00	
00000000-0000-0000-0000-000000000000	aa145921-5165-47b6-b393-89010ff2c101	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766074036173@example.test","user_id":"bd521c2f-d1e2-433f-acc1-f11fc5d84565","user_phone":""}}	2025-12-24 00:22:08.73512+00	
00000000-0000-0000-0000-000000000000	7f09945e-175f-42bf-abe9-223dd612d3a3	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766076765178@example.test","user_id":"70d2ff0a-262f-4211-8d1a-c65140857249","user_phone":""}}	2025-12-24 00:22:08.745679+00	
00000000-0000-0000-0000-000000000000	d5ada877-918a-447b-855d-980ac4cf0fbc	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766529032724@example.test","user_id":"44c6d21c-96b0-42b7-8127-20b5e168ec12","user_phone":""}}	2025-12-24 00:22:23.945337+00	
00000000-0000-0000-0000-000000000000	18cc797a-3f9f-4f20-ad15-12e21e077a54	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766529096033@example.test","user_id":"8df209e5-2514-493e-b433-c0214a0cfbcf","user_phone":""}}	2025-12-24 00:22:23.96765+00	
00000000-0000-0000-0000-000000000000	907a0a2a-2421-417e-a189-9b1cfeea8d79	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766534140563@example.test","user_id":"98f7beb9-c2c8-434e-8001-a8e821c390f1","user_phone":""}}	2025-12-24 00:22:24.143808+00	
00000000-0000-0000-0000-000000000000	1e11a02f-1dc8-4fc8-a793-3a88670dec46	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766017592452@example.test","user_id":"d6c40299-72bb-4e9e-a998-e71382d07f98","user_phone":""}}	2025-12-24 00:23:03.155803+00	
00000000-0000-0000-0000-000000000000	d68b1c54-5439-4f0d-9cfc-5e000bdec6a5	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766265722117@example.test","user_id":"96ccb259-b6a4-4dd0-90ae-1bbc96642c77","user_phone":""}}	2025-12-24 00:23:03.166064+00	
00000000-0000-0000-0000-000000000000	ef116704-ab87-4562-ae15-514839e44ace	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766535365780@example.test","user_id":"6e347f8e-d87f-4a43-a514-81f1e6d1bcb3","user_phone":""}}	2025-12-24 00:23:26.325936+00	
00000000-0000-0000-0000-000000000000	0ca25647-6e13-4838-bb82-d4e52afd1150	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766535429245@example.test","user_id":"a1d1355f-2caf-4f8b-99c0-9a2dbde17b18","user_phone":""}}	2025-12-24 00:23:26.33059+00	
00000000-0000-0000-0000-000000000000	db425f65-4b64-48aa-96b2-0eec24027b4e	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766534934307@example.test","user_id":"2ef0c906-f43c-43db-9c5e-c2656948ff4d","user_phone":""}}	2025-12-24 00:23:26.342907+00	
00000000-0000-0000-0000-000000000000	c5347081-88ba-42c8-96b7-16077a51a7b0	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766266024622@example.test","user_id":"343d68ef-0ad3-47df-a135-7e1358deb1b9","user_phone":""}}	2025-12-24 00:23:43.000422+00	
00000000-0000-0000-0000-000000000000	dbb6546b-ffbb-4dee-9467-9f1886c19a7d	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766077557470@example.test","user_id":"631babe1-4592-4b13-ade7-541295a33f38","user_phone":""}}	2025-12-24 00:22:08.694186+00	
00000000-0000-0000-0000-000000000000	2c18066d-28d4-4ef1-b4b4-bfb1ee55a121	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766073602050@example.test","user_id":"9dbae3e1-9c01-4ec5-8be2-cc51e8b2ce00","user_phone":""}}	2025-12-24 00:22:08.738331+00	
00000000-0000-0000-0000-000000000000	1e6c8281-7e05-4426-8a8d-e888d4be0ec1	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766018019140@example.test","user_id":"1bc68e41-c94c-49af-8e57-dab96d9dc39d","user_phone":""}}	2025-12-24 00:23:03.15681+00	
00000000-0000-0000-0000-000000000000	8807766c-7dc1-47fa-b1ee-c4246cf14e02	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766076701540@example.test","user_id":"7420e552-7d5a-4565-b8ee-1b871727febf","user_phone":""}}	2025-12-24 00:22:08.696946+00	
00000000-0000-0000-0000-000000000000	fe955a84-a40a-45fb-ab20-56d2d797d992	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766099165014@example.test","user_id":"1c43f2e6-1fa8-4ada-b129-69594eed6ea7","user_phone":""}}	2025-12-24 00:22:08.733839+00	
00000000-0000-0000-0000-000000000000	a4029717-7357-4fad-b3ad-f78fad1a2d55	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766016858003@example.test","user_id":"646695bf-4b69-4d1f-ad38-38f4ef166e6e","user_phone":""}}	2025-12-24 00:23:03.149924+00	
00000000-0000-0000-0000-000000000000	f265126f-f0a2-4314-9687-c7871f015749	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766072809081@example.test","user_id":"b5709e01-6cbf-4a5a-8ce1-e4913cbaa800","user_phone":""}}	2025-12-24 00:23:03.166178+00	
00000000-0000-0000-0000-000000000000	673be01b-b11e-4dad-9b05-0c930d7de753	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766077621629@example.test","user_id":"be3f923a-3c80-44a2-bc7f-beab42853cdf","user_phone":""}}	2025-12-24 00:22:08.720597+00	
00000000-0000-0000-0000-000000000000	2073333e-62ad-461b-ae64-0b246022e69b	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766100263307@example.test","user_id":"402d46c9-11c9-427f-9a67-56a9c358dbbc","user_phone":""}}	2025-12-24 00:23:03.16156+00	
00000000-0000-0000-0000-000000000000	67772edc-20a3-42e0-b4f2-4d5d1778539c	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766073666542@example.test","user_id":"11a9cf43-65ca-4d08-85aa-ac976c45df0a","user_phone":""}}	2025-12-24 00:22:08.738718+00	
00000000-0000-0000-0000-000000000000	0ba0cc75-950a-477b-a7f6-e8fbd11dfbb8	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766528667219@example.test","user_id":"7c8fc835-9af5-4a12-beae-43b09b286f3e","user_phone":""}}	2025-12-24 00:22:23.949586+00	
00000000-0000-0000-0000-000000000000	84a87518-e623-4773-b72d-b90b2cfe77b0	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766528602964@example.test","user_id":"ee08639a-f56e-45a9-a4a7-83a9c2cb155b","user_phone":""}}	2025-12-24 00:22:23.956219+00	
00000000-0000-0000-0000-000000000000	840e761d-97b6-454a-a295-d4094f17b7fc	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766528969338@example.test","user_id":"0b39d833-dca5-4915-8048-fbf5d13ede54","user_phone":""}}	2025-12-24 00:22:23.959563+00	
00000000-0000-0000-0000-000000000000	972d3ba2-8b27-43d1-8402-69fc8b68d511	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766528731583@example.test","user_id":"c4241a23-461d-4816-a71f-2a8c9c172ac3","user_phone":""}}	2025-12-24 00:22:23.965698+00	
00000000-0000-0000-0000-000000000000	18a69392-eeec-4d74-9a3b-f35b2e5b9a5d	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766264799602@example.test","user_id":"a9a9c266-8b5a-474d-b71f-eef8b5c45cb3","user_phone":""}}	2025-12-24 00:23:03.150893+00	
00000000-0000-0000-0000-000000000000	c6ec4af6-edb4-4fa0-a3db-4631db006e06	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"e2e+1766099961851@example.test","user_id":"09c7f2e2-44d3-4c91-8853-ba047d51b395","user_phone":""}}	2025-12-24 00:23:03.161485+00	
00000000-0000-0000-0000-000000000000	a466b544-40aa-45ce-a180-ef27fb775494	{"action":"user_signedup","actor_id":"23681b71-e78c-4f50-a107-a288ea0a6e4b","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-12-24 00:28:49.818663+00	
00000000-0000-0000-0000-000000000000	7fc16b0d-0050-4feb-ac7e-33451c51c50c	{"action":"logout","actor_id":"23681b71-e78c-4f50-a107-a288ea0a6e4b","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-24 00:29:30.089997+00	
00000000-0000-0000-0000-000000000000	ed1bdaed-3d52-419d-926f-45d99fd3e175	{"action":"login","actor_id":"23681b71-e78c-4f50-a107-a288ea0a6e4b","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-24 00:30:12.106663+00	
00000000-0000-0000-0000-000000000000	fa043b6d-cf7c-4840-a02d-333d09807a18	{"action":"logout","actor_id":"23681b71-e78c-4f50-a107-a288ea0a6e4b","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-24 00:36:12.071386+00	
00000000-0000-0000-0000-000000000000	205456dc-b289-4351-8eb6-ef22f84d4734	{"action":"user_signedup","actor_id":"b943a685-c363-4b80-8e40-cf17ee62ee50","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-12-24 02:26:27.396194+00	
00000000-0000-0000-0000-000000000000	93ebbbc7-6809-4ef5-ac02-960c5a6d5501	{"action":"logout","actor_id":"b943a685-c363-4b80-8e40-cf17ee62ee50","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-24 02:34:58.477406+00	
00000000-0000-0000-0000-000000000000	a8148f8f-20be-4ae6-b692-e6d1cbf1395e	{"action":"login","actor_id":"23681b71-e78c-4f50-a107-a288ea0a6e4b","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-24 02:35:49.358979+00	
00000000-0000-0000-0000-000000000000	91be2b23-610c-4519-8b73-07fa0f7d142b	{"action":"logout","actor_id":"23681b71-e78c-4f50-a107-a288ea0a6e4b","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-24 02:36:28.429203+00	
00000000-0000-0000-0000-000000000000	c1eebcf9-8a8b-431d-957e-05005091171f	{"action":"login","actor_id":"23681b71-e78c-4f50-a107-a288ea0a6e4b","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-24 02:39:14.975943+00	
00000000-0000-0000-0000-000000000000	cc50575b-8f80-4ee8-a99f-535b9cab48d6	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"23681b71-e78c-4f50-a107-a288ea0a6e4b","user_phone":""}}	2025-12-24 02:39:38.023182+00	
00000000-0000-0000-0000-000000000000	8276e388-30b1-44fa-83bd-539928c90e4b	{"action":"login","actor_id":"b943a685-c363-4b80-8e40-cf17ee62ee50","actor_username":"email.bechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-12-24 02:39:54.121405+00	
00000000-0000-0000-0000-000000000000	ac6e761c-cbaa-4b29-8a09-b62bd3a9306b	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"email.bechar@gmail.com","user_id":"b943a685-c363-4b80-8e40-cf17ee62ee50","user_phone":""}}	2025-12-24 02:41:15.849826+00	
00000000-0000-0000-0000-000000000000	9854a1c9-f8c0-4f83-b419-fa8732fa02fb	{"action":"user_signedup","actor_id":"2983776e-361c-45a2-bc58-1f4d570b3d68","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-12-24 02:44:25.519581+00	
00000000-0000-0000-0000-000000000000	b593e30e-b745-4b43-acd0-43ee8a36dc6a	{"action":"logout","actor_id":"2983776e-361c-45a2-bc58-1f4d570b3d68","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-12-24 02:46:53.272104+00	
00000000-0000-0000-0000-000000000000	e1c3032c-0d7c-48e9-a78a-d8b699588d06	{"action":"login","actor_id":"2983776e-361c-45a2-bc58-1f4d570b3d68","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2026-01-07 12:05:20.136595+00	
00000000-0000-0000-0000-000000000000	6b9b5fc7-dec4-4ac0-93ea-bfc37e6f0f56	{"action":"token_refreshed","actor_id":"2983776e-361c-45a2-bc58-1f4d570b3d68","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2026-01-07 21:09:44.047861+00	
00000000-0000-0000-0000-000000000000	bf6d7ddb-afae-4a9e-a889-178fd10faccb	{"action":"token_revoked","actor_id":"2983776e-361c-45a2-bc58-1f4d570b3d68","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2026-01-07 21:09:44.067746+00	
00000000-0000-0000-0000-000000000000	ab3018ed-2c41-4168-8162-e15fc977fbb4	{"action":"logout","actor_id":"2983776e-361c-45a2-bc58-1f4d570b3d68","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2026-01-07 21:10:05.751651+00	
00000000-0000-0000-0000-000000000000	3d4e53d8-1b30-4d53-9ffd-4cdee14d1afd	{"action":"login","actor_id":"2983776e-361c-45a2-bc58-1f4d570b3d68","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2026-01-07 21:10:14.388231+00	
00000000-0000-0000-0000-000000000000	a4457861-951f-4c5c-a0d5-46a9e776a290	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"2983776e-361c-45a2-bc58-1f4d570b3d68","user_phone":""}}	2026-01-07 21:18:55.757245+00	
00000000-0000-0000-0000-000000000000	e0853324-5cdc-4b54-82ea-ffe5757cb73f	{"action":"user_signedup","actor_id":"3694044e-aafd-42f9-a0fa-b38501024508","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2026-01-07 21:20:24.088995+00	
00000000-0000-0000-0000-000000000000	9010ec79-efaa-485e-aa97-1ec299e54f25	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"3694044e-aafd-42f9-a0fa-b38501024508","user_phone":""}}	2026-01-07 21:25:03.260767+00	
00000000-0000-0000-0000-000000000000	7066c160-ec2b-4b92-871e-46fbabcbd342	{"action":"user_signedup","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2026-01-07 21:31:35.531388+00	
00000000-0000-0000-0000-000000000000	1ec00fe8-14e5-4435-bf50-f6941f2ecdf1	{"action":"logout","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2026-01-07 21:33:39.455286+00	
00000000-0000-0000-0000-000000000000	671a0a6e-b25d-49b7-b18b-ff8339f176e9	{"action":"login","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2026-01-08 07:43:54.436285+00	
00000000-0000-0000-0000-000000000000	4fc6f2ed-e3bb-4355-b15d-4aef5174ad62	{"action":"token_refreshed","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2026-01-08 09:56:59.208463+00	
00000000-0000-0000-0000-000000000000	ac8c674a-bd97-48d7-8bdd-99a09893a1ea	{"action":"token_revoked","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2026-01-08 09:56:59.224091+00	
00000000-0000-0000-0000-000000000000	d90a32e4-0602-44d8-94a4-03221fcdf6dd	{"action":"logout","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2026-01-08 09:58:05.935127+00	
00000000-0000-0000-0000-000000000000	9496f7e8-a276-4e67-97aa-3f1226149207	{"action":"login","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2026-01-08 09:58:18.50695+00	
00000000-0000-0000-0000-000000000000	5eddb2cf-b9fa-441a-a4fd-899c515cfbce	{"action":"logout","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2026-01-08 10:05:29.902995+00	
00000000-0000-0000-0000-000000000000	f69ac819-333e-4ae5-9564-fcf6ec59954d	{"action":"login","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2026-01-24 01:45:33.618993+00	
00000000-0000-0000-0000-000000000000	97dbb55a-c4bb-4463-a33f-d6249476218f	{"action":"token_refreshed","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2026-01-24 04:49:26.502139+00	
00000000-0000-0000-0000-000000000000	f9fa1bbd-c021-4562-acf4-93d2360ee88f	{"action":"token_revoked","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2026-01-24 04:49:26.525606+00	
00000000-0000-0000-0000-000000000000	42f4a755-6a02-4c6e-b3b7-af654b9dad6d	{"action":"token_refreshed","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2026-01-24 04:49:34.051589+00	
00000000-0000-0000-0000-000000000000	22cf20e7-7494-48ad-bf49-8849bca0631f	{"action":"token_refreshed","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2026-01-24 20:15:49.010844+00	
00000000-0000-0000-0000-000000000000	94a86495-4b36-422b-9a47-c4fad87a4307	{"action":"token_refreshed","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"token"}	2026-01-24 20:15:57.824194+00	
00000000-0000-0000-0000-000000000000	63f27a74-1316-44d7-991b-96842e3a3dfa	{"action":"login","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2026-01-30 11:53:12.37952+00	
00000000-0000-0000-0000-000000000000	0410e9a2-3a44-4902-a760-cb86d0a928df	{"action":"logout","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2026-01-30 11:59:38.983657+00	
00000000-0000-0000-0000-000000000000	aa32acf0-2dc0-4ba7-851a-1ea4c2fab2d3	{"action":"user_recovery_requested","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2026-02-15 21:25:23.105+00	
00000000-0000-0000-0000-000000000000	ef23d34b-83e4-4a6b-8475-18811b7da9da	{"action":"login","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2026-02-15 21:27:43.106805+00	
00000000-0000-0000-0000-000000000000	a0be0175-978d-4b81-9b4c-f4c37272babe	{"action":"user_updated_password","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2026-02-15 21:28:06.12004+00	
00000000-0000-0000-0000-000000000000	38b5247a-fa36-40ef-a5af-9bf52b7e59f7	{"action":"user_modified","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"user"}	2026-02-15 21:28:06.121199+00	
00000000-0000-0000-0000-000000000000	0097949d-7fb7-4ef1-b5b7-ca2816d42b77	{"action":"logout","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2026-02-15 21:28:08.910409+00	
00000000-0000-0000-0000-000000000000	aabf30bb-40d2-4b0b-a0e0-f08c2c4af3e8	{"action":"login","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2026-02-15 21:28:29.082196+00	
00000000-0000-0000-0000-000000000000	7bf90249-b5a4-438e-913f-b244163fe9f0	{"action":"logout","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2026-02-15 21:51:40.126378+00	
00000000-0000-0000-0000-000000000000	457b6199-0be4-4879-ab30-0450a4cdd58b	{"action":"login","actor_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2026-02-15 21:52:03.55059+00	
00000000-0000-0000-0000-000000000000	be524087-38e1-4fb7-b0d2-45a8677f9fad	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"965fc489-75fa-4815-b1cb-4dfbe7373660","user_phone":""}}	2026-02-15 21:52:36.662382+00	
00000000-0000-0000-0000-000000000000	42f064f1-0a63-4590-a9df-8451bb0c072c	{"action":"user_signedup","actor_id":"b4b9c980-6aa4-4a78-9ef6-0b0eda58cb68","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2026-02-15 22:08:38.158639+00	
00000000-0000-0000-0000-000000000000	57f60602-1006-4220-9a95-045ec2d1cc7d	{"action":"logout","actor_id":"b4b9c980-6aa4-4a78-9ef6-0b0eda58cb68","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2026-02-15 23:01:12.777794+00	
00000000-0000-0000-0000-000000000000	7fc1beee-936b-458a-a077-cbfd832b1fd3	{"action":"login","actor_id":"b4b9c980-6aa4-4a78-9ef6-0b0eda58cb68","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2026-02-19 21:28:57.635055+00	
00000000-0000-0000-0000-000000000000	b6d8a7fe-3357-4729-8982-17ee0f40be4d	{"action":"logout","actor_id":"b4b9c980-6aa4-4a78-9ef6-0b0eda58cb68","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2026-02-19 21:31:59.385369+00	
00000000-0000-0000-0000-000000000000	8f26ed8a-7881-4b1f-bdfd-d6118b7df59b	{"action":"login","actor_id":"b4b9c980-6aa4-4a78-9ef6-0b0eda58cb68","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2026-02-19 23:35:33.384373+00	
00000000-0000-0000-0000-000000000000	e71d03ff-967e-4e6a-8add-2cba510ecc2e	{"action":"logout","actor_id":"b4b9c980-6aa4-4a78-9ef6-0b0eda58cb68","actor_username":"fuadbechar@gmail.com","actor_via_sso":false,"log_type":"account"}	2026-02-19 23:38:33.868568+00	
00000000-0000-0000-0000-000000000000	54bfa9f4-fa85-4a17-974c-96ad1e32ecf8	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fouadbechar9@gmail.com","user_id":"60d3c5b0-558a-4e24-ab05-d93192989d38","user_phone":""}}	2026-02-22 12:05:14.98282+00	
00000000-0000-0000-0000-000000000000	817c0f70-fdd9-4a85-ba8c-5a08ecf95a71	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"fuadbechar@gmail.com","user_id":"b4b9c980-6aa4-4a78-9ef6-0b0eda58cb68","user_phone":""}}	2026-02-22 12:05:14.983105+00	
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at, invite_token, referrer, oauth_client_state_id, linking_target_id, email_optional) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid, last_webauthn_challenge_data) FROM stdin;
\.


--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_authorizations (id, authorization_id, client_id, user_id, redirect_uri, scope, state, resource, code_challenge, code_challenge_method, response_type, status, authorization_code, created_at, expires_at, approved_at, nonce) FROM stdin;
\.


--
-- Data for Name: oauth_client_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_client_states (id, provider_type, code_verifier, created_at) FROM stdin;
\.


--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_clients (id, client_secret_hash, registration_type, redirect_uris, grant_types, client_name, client_uri, logo_uri, created_at, updated_at, deleted_at, client_type, token_endpoint_auth_method) FROM stdin;
\.


--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_consents (id, user_id, client_id, scopes, granted_at, revoked_at) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
20250717082212
20250731150234
20250804100000
20250901200500
20250903112500
20250904133000
20250925093508
20251007112900
20251104100000
20251111201300
20251201000000
20260115000000
20260121000000
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag, oauth_client_id, refresh_token_hmac_key, refresh_token_counter, scopes) FROM stdin;
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at, disabled) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
\.


--
-- Data for Name: activities; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.activities (id, user_id, title, description, user_agent, ip, created_at, updated_at, metadata) FROM stdin;
\.


--
-- Data for Name: contacts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.contacts (id, first_name, last_name, email, message, file_name, file_url, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: forum_posts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.forum_posts (id, thread_id, content, author_id, author_display, created_at, updated_at, author_avatar_url, pinned) FROM stdin;
\.


--
-- Data for Name: forum_reports; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.forum_reports (id, reporter_id, target_type, thread_id, post_id, reason, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: forum_threads; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.forum_threads (id, title, content, author_id, author_display, created_at, updated_at, author_avatar_url, pinned) FROM stdin;
\.


--
-- Data for Name: notifications_sent; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notifications_sent (id, subject, body, sent_by, recipients_count, sent_count, failed_count, dry_run, meta, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: password_reset_attempts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.password_reset_attempts (id, email, ip, user_agent, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profiles (id, email, full_name, created_at, updated_at, avatar_url, preferences, avatar_path, username) FROM stdin;
\.


--
-- Data for Name: trusted_devices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.trusted_devices (id, user_id, token_hash, name, user_agent, created_at, last_seen) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2025-08-13 11:44:53
20211116045059	2025-08-13 11:44:56
20211116050929	2025-08-13 11:44:58
20211116051442	2025-08-13 11:44:59
20211116212300	2025-08-13 11:45:00
20211116213355	2025-08-13 11:45:01
20211116213934	2025-08-13 11:45:02
20211116214523	2025-08-13 11:45:04
20211122062447	2025-08-13 11:45:05
20211124070109	2025-08-13 11:45:06
20211202204204	2025-08-13 11:45:07
20211202204605	2025-08-13 11:45:08
20211210212804	2025-08-13 11:45:11
20211228014915	2025-08-13 11:45:13
20220107221237	2025-08-13 11:45:14
20220228202821	2025-08-13 11:45:15
20220312004840	2025-08-13 11:45:16
20220603231003	2025-08-13 11:45:18
20220603232444	2025-08-13 11:45:19
20220615214548	2025-08-13 11:45:20
20220712093339	2025-08-13 11:45:22
20220908172859	2025-08-13 11:45:23
20220916233421	2025-08-13 11:45:24
20230119133233	2025-08-13 11:45:25
20230128025114	2025-08-13 11:45:27
20230128025212	2025-08-13 11:45:28
20230227211149	2025-08-13 11:45:29
20230228184745	2025-08-13 11:45:30
20230308225145	2025-08-13 11:45:32
20230328144023	2025-08-13 11:45:33
20231018144023	2025-08-13 11:45:34
20231204144023	2025-08-13 11:45:36
20231204144024	2025-08-13 11:45:37
20231204144025	2025-08-13 11:45:38
20240108234812	2025-08-13 11:45:40
20240109165339	2025-08-13 11:45:41
20240227174441	2025-08-13 11:45:43
20240311171622	2025-08-13 11:45:44
20240321100241	2025-08-13 11:45:47
20240401105812	2025-08-13 11:45:49
20240418121054	2025-08-13 11:45:51
20240523004032	2025-08-13 11:45:54
20240618124746	2025-08-13 11:45:56
20240801235015	2025-08-13 11:45:57
20240805133720	2025-08-13 11:45:59
20240827160934	2025-08-13 11:46:00
20240919163303	2025-08-13 11:46:02
20240919163305	2025-08-13 11:46:03
20241019105805	2025-08-13 11:46:04
20241030150047	2025-08-13 11:46:08
20241108114728	2025-08-13 11:46:10
20241121104152	2025-08-13 11:46:11
20241130184212	2025-08-13 11:46:13
20241220035512	2025-08-13 11:46:14
20241220123912	2025-08-13 11:46:16
20241224161212	2025-08-13 11:46:17
20250107150512	2025-08-13 11:46:19
20250110162412	2025-08-13 11:46:20
20250123174212	2025-08-13 11:46:21
20250128220012	2025-08-13 11:46:23
20250506224012	2025-08-13 11:46:24
20250523164012	2025-08-13 11:46:25
20250714121412	2025-08-13 11:46:27
20250905041441	2025-10-05 00:52:32
20251103001201	2025-11-12 05:13:07
20251120212548	2026-02-09 22:18:26
20251120215549	2026-02-09 22:18:26
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at, action_filter) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id, type) FROM stdin;
avatars	avatars	\N	2025-11-03 00:09:05.998957+00	2025-11-03 00:09:05.998957+00	t	f	\N	\N	\N	STANDARD
contacts	contacts	\N	2025-10-24 06:50:51.040698+00	2025-10-24 06:50:51.040698+00	t	f	\N	\N	\N	STANDARD
exports	exports	\N	2025-12-13 06:24:38.664401+00	2025-12-13 06:24:38.664401+00	t	f	\N	\N	\N	STANDARD
\.


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets_analytics (name, type, format, created_at, updated_at, id, deleted_at) FROM stdin;
\.


--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets_vectors (id, type, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2025-08-13 11:44:53.498968
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2025-08-13 11:44:53.506423
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2025-08-13 11:44:53.537965
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2025-08-13 11:44:53.600997
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2025-08-13 11:44:53.610195
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2025-08-13 11:44:53.620665
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2025-08-13 11:44:53.624646
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2025-08-13 11:44:53.639748
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2025-08-13 11:44:53.645219
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2025-08-13 11:44:53.648329
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2025-08-13 11:44:53.651908
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2025-08-13 11:44:53.68027
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2025-08-13 11:44:53.684207
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2025-08-13 11:44:53.687749
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2025-08-13 11:44:53.691926
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2025-08-13 11:44:53.698765
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2025-08-13 11:44:53.701918
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2025-08-13 11:44:53.708114
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2025-08-13 11:44:53.721136
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2025-08-13 11:44:53.737131
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2025-08-13 11:44:53.7404
25	custom-metadata	d974c6057c3db1c1f847afa0e291e6165693b990	2025-08-13 11:44:53.744504
37	add-bucket-name-length-trigger	3944135b4e3e8b22d6d4cbb568fe3b0b51df15c1	2025-08-14 09:25:13.20361
44	vector-bucket-type	99c20c0ffd52bb1ff1f32fb992f3b351e3ef8fb3	2025-11-17 18:17:04.94313
45	vector-buckets	049e27196d77a7cb76497a85afae669d8b230953	2025-11-17 18:17:04.958332
46	buckets-objects-grants	fedeb96d60fefd8e02ab3ded9fbde05632f84aed	2025-11-17 18:17:05.008433
47	iceberg-table-metadata	649df56855c24d8b36dd4cc1aeb8251aa9ad42c2	2025-11-17 18:17:05.011075
49	buckets-objects-grants-postgres	072b1195d0d5a2f888af6b2302a1938dd94b8b3d	2025-12-24 00:00:45.936406
2	storage-schema	f6a1fa2c93cbcd16d4e487b362e45fca157a8dbd	2025-08-13 11:44:53.511204
6	change-column-name-in-get-size	ded78e2f1b5d7e616117897e6443a925965b30d2	2025-08-13 11:44:53.616276
9	fix-search-function	af597a1b590c70519b464a4ab3be54490712796b	2025-08-13 11:44:53.629348
10	search-files-search-function	b595f05e92f7e91211af1bbfe9c6a13bb3391e16	2025-08-13 11:44:53.633245
26	objects-prefixes	215cabcb7f78121892a5a2037a09fedf9a1ae322	2025-08-14 09:25:13.041062
27	search-v2	859ba38092ac96eb3964d83bf53ccc0b141663a6	2025-08-14 09:25:13.119036
28	object-bucket-name-sorting	c73a2b5b5d4041e39705814fd3a1b95502d38ce4	2025-08-14 09:25:13.13178
29	create-prefixes	ad2c1207f76703d11a9f9007f821620017a66c21	2025-08-14 09:25:13.141464
30	update-object-levels	2be814ff05c8252fdfdc7cfb4b7f5c7e17f0bed6	2025-08-14 09:25:13.149625
31	objects-level-index	b40367c14c3440ec75f19bbce2d71e914ddd3da0	2025-08-14 09:25:13.157301
32	backward-compatible-index-on-objects	e0c37182b0f7aee3efd823298fb3c76f1042c0f7	2025-08-14 09:25:13.167686
33	backward-compatible-index-on-prefixes	b480e99ed951e0900f033ec4eb34b5bdcb4e3d49	2025-08-14 09:25:13.175456
34	optimize-search-function-v1	ca80a3dc7bfef894df17108785ce29a7fc8ee456	2025-08-14 09:25:13.17762
35	add-insert-trigger-prefixes	458fe0ffd07ec53f5e3ce9df51bfdf4861929ccc	2025-08-14 09:25:13.186171
36	optimise-existing-functions	6ae5fca6af5c55abe95369cd4f93985d1814ca8f	2025-08-14 09:25:13.191184
38	iceberg-catalog-flag-on-buckets	02716b81ceec9705aed84aa1501657095b32e5c5	2025-08-14 09:25:13.209183
39	add-search-v2-sort-support	6706c5f2928846abee18461279799ad12b279b78	2025-10-05 00:50:56.849922
40	fix-prefix-race-conditions-optimized	7ad69982ae2d372b21f48fc4829ae9752c518f6b	2025-10-05 00:50:56.920309
41	add-object-level-update-trigger	07fcf1a22165849b7a029deed059ffcde08d1ae0	2025-10-05 00:50:56.942029
42	rollback-prefix-triggers	771479077764adc09e2ea2043eb627503c034cd4	2025-10-05 00:50:56.946605
43	fix-object-level	84b35d6caca9d937478ad8a797491f38b8c2979f	2025-10-05 00:50:56.9529
48	iceberg-catalog-ids	e0e8b460c609b9999ccd0df9ad14294613eed939	2025-11-17 18:17:05.013201
50	search-v2-optimised	6323ac4f850aa14e7387eb32102869578b5bd478	2026-02-10 19:38:37.088202
51	index-backward-compatible-search	2ee395d433f76e38bcd3856debaf6e0e5b674011	2026-02-10 19:38:37.201928
52	drop-not-used-indexes-and-functions	5cc44c8696749ac11dd0dc37f2a3802075f3a171	2026-02-10 19:38:37.203824
53	drop-index-lower-name	d0cb18777d9e2a98ebe0bc5cc7a42e57ebe41854	2026-02-10 19:38:37.32679
54	drop-index-object-level	6289e048b1472da17c31a7eba1ded625a6457e67	2026-02-10 19:38:37.329608
55	prevent-direct-deletes	262a4798d5e0f2e7c8970232e03ce8be695d5819	2026-02-10 19:38:37.331467
56	fix-optimized-search-function	cb58526ebc23048049fd5bf2fd148d18b04a2073	2026-02-10 19:38:37.340616
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata) FROM stdin;
be9e82db-a44a-4602-addd-892f80526ca0	avatars	avatars/.emptyFolderPlaceholder	\N	2025-11-19 23:28:06.068748+00	2025-11-19 23:28:06.068748+00	2025-11-19 23:28:06.068748+00	{"eTag": "\\"d41d8cd98f00b204e9800998ecf8427e\\"", "size": 0, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2025-11-19T23:28:06.070Z", "contentLength": 0, "httpStatusCode": 200}	7d166c54-72af-4223-881b-cc7f4099026c	\N	{}
6d7e258b-1057-449b-bfdc-10738c0b8b19	contacts	.emptyFolderPlaceholder	\N	2025-11-16 09:46:00.642908+00	2025-11-16 09:46:00.642908+00	2025-11-16 09:46:00.642908+00	{"eTag": "\\"d41d8cd98f00b204e9800998ecf8427e\\"", "size": 0, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2025-11-16T09:46:00.644Z", "contentLength": 0, "httpStatusCode": 200}	24936522-e4d0-485a-9cdb-bea10e510db2	\N	{}
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.vector_indexes (id, name, bucket_id, data_type, dimension, distance_metric, metadata_configuration, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: -
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: -
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 539, true);


--
-- Name: contacts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.contacts_id_seq', 10, true);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: -
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_code_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_code_key UNIQUE (authorization_code);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_id_key UNIQUE (authorization_id);


--
-- Name: oauth_authorizations oauth_authorizations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_pkey PRIMARY KEY (id);


--
-- Name: oauth_client_states oauth_client_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_client_states
    ADD CONSTRAINT oauth_client_states_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_user_client_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_client_unique UNIQUE (user_id, client_id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: forum_posts forum_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_posts
    ADD CONSTRAINT forum_posts_pkey PRIMARY KEY (id);


--
-- Name: forum_reports forum_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_reports
    ADD CONSTRAINT forum_reports_pkey PRIMARY KEY (id);


--
-- Name: forum_threads forum_threads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_threads
    ADD CONSTRAINT forum_threads_pkey PRIMARY KEY (id);


--
-- Name: notifications_sent notifications_sent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications_sent
    ADD CONSTRAINT notifications_sent_pkey PRIMARY KEY (id);


--
-- Name: password_reset_attempts password_reset_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_attempts
    ADD CONSTRAINT password_reset_attempts_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_email_key UNIQUE (email);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: trusted_devices trusted_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trusted_devices
    ADD CONSTRAINT trusted_devices_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: buckets_vectors buckets_vectors_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_vectors
    ADD CONSTRAINT buckets_vectors_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: vector_indexes vector_indexes_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_pkey PRIMARY KEY (id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_oauth_client_states_created_at; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_oauth_client_states_created_at ON auth.oauth_client_states USING btree (created_at);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: oauth_auth_pending_exp_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- Name: oauth_consents_active_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_active_user_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_user_order_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_oauth_client_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: idx_activities_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_activities_created_at ON public.activities USING btree (created_at);


--
-- Name: idx_activities_metadata_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_activities_metadata_gin ON public.activities USING gin (metadata);


--
-- Name: idx_activities_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_activities_user_id ON public.activities USING btree (user_id);


--
-- Name: idx_contacts_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_contacts_email ON public.contacts USING btree (email);


--
-- Name: idx_forum_posts_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_forum_posts_author_id ON public.forum_posts USING btree (author_id);


--
-- Name: idx_forum_posts_thread_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_forum_posts_thread_id ON public.forum_posts USING btree (thread_id);


--
-- Name: idx_forum_reports_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_forum_reports_post_id ON public.forum_reports USING btree (post_id);


--
-- Name: idx_forum_reports_thread_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_forum_reports_thread_id ON public.forum_reports USING btree (thread_id);


--
-- Name: idx_forum_threads_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_forum_threads_author_id ON public.forum_threads USING btree (author_id);


--
-- Name: idx_forum_threads_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_forum_threads_created_at ON public.forum_threads USING btree (created_at DESC);


--
-- Name: idx_notifications_sent_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_sent_created_at ON public.notifications_sent USING btree (created_at);


--
-- Name: idx_notifications_sent_sent_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_sent_sent_by ON public.notifications_sent USING btree (sent_by);


--
-- Name: idx_password_reset_attempts_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_password_reset_attempts_created_at ON public.password_reset_attempts USING btree (created_at);


--
-- Name: idx_password_reset_attempts_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_password_reset_attempts_email ON public.password_reset_attempts USING btree (email);


--
-- Name: idx_password_reset_attempts_ip; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_password_reset_attempts_ip ON public.password_reset_attempts USING btree (ip);


--
-- Name: idx_profiles_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_profiles_id ON public.profiles USING btree (id);


--
-- Name: idx_profiles_preferences; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_profiles_preferences ON public.profiles USING gin (preferences);


--
-- Name: idx_profiles_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_profiles_username ON public.profiles USING btree (username);


--
-- Name: idx_trusted_devices_token_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_trusted_devices_token_hash ON public.trusted_devices USING btree (token_hash);


--
-- Name: idx_trusted_devices_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_trusted_devices_user_id ON public.trusted_devices USING btree (user_id);


--
-- Name: profiles_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX profiles_created_idx ON public.profiles USING btree (created_at);


--
-- Name: profiles_email_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX profiles_email_idx ON public.profiles USING btree (email);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: subscription_subscription_id_entity_filters_action_filter_key; Type: INDEX; Schema: realtime; Owner: -
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_action_filter_key ON realtime.subscription USING btree (subscription_id, entity, filters, action_filter);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: buckets_analytics_unique_name_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX buckets_analytics_unique_name_idx ON storage.buckets_analytics USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: idx_objects_bucket_id_name_lower; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name_lower ON storage.objects USING btree (bucket_id, lower(name) COLLATE "C");


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: vector_indexes_name_bucket_id_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX vector_indexes_name_bucket_id_idx ON storage.vector_indexes USING btree (name, bucket_id);


--
-- Name: users auth_user_insert; Type: TRIGGER; Schema: auth; Owner: -
--

CREATE TRIGGER auth_user_insert AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


--
-- Name: users auth_user_update; Type: TRIGGER; Schema: auth; Owner: -
--

CREATE TRIGGER auth_user_update AFTER UPDATE ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_update_user();


--
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: -
--

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


--
-- Name: profiles trg_profiles_sync_avatar_url; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_profiles_sync_avatar_url AFTER INSERT OR UPDATE OF avatar_url ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.sync_profile_avatar_url_to_forum();


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: -
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- Name: buckets protect_buckets_delete; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_buckets_delete BEFORE DELETE ON storage.buckets FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- Name: objects protect_objects_delete; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_objects_delete BEFORE DELETE ON storage.objects FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_oauth_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_oauth_client_id_fkey FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: forum_posts forum_posts_thread_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_posts
    ADD CONSTRAINT forum_posts_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES public.forum_threads(id) ON DELETE CASCADE;


--
-- Name: forum_reports forum_reports_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_reports
    ADD CONSTRAINT forum_reports_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.forum_posts(id) ON DELETE CASCADE;


--
-- Name: forum_reports forum_reports_reporter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_reports
    ADD CONSTRAINT forum_reports_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES public.profiles(id);


--
-- Name: forum_reports forum_reports_thread_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_reports
    ADD CONSTRAINT forum_reports_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES public.forum_threads(id) ON DELETE CASCADE;


--
-- Name: trusted_devices trusted_devices_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trusted_devices
    ADD CONSTRAINT trusted_devices_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: vector_indexes vector_indexes_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_vectors(id);


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: activities; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;

--
-- Name: contacts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.contacts ENABLE ROW LEVEL SECURITY;

--
-- Name: forum_posts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.forum_posts ENABLE ROW LEVEL SECURITY;

--
-- Name: forum_reports; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.forum_reports ENABLE ROW LEVEL SECURITY;

--
-- Name: forum_threads; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.forum_threads ENABLE ROW LEVEL SECURITY;

--
-- Name: notifications_sent; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.notifications_sent ENABLE ROW LEVEL SECURITY;

--
-- Name: password_reset_attempts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.password_reset_attempts ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles profiles_delete_none; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY profiles_delete_none ON public.profiles FOR DELETE TO authenticated USING (false);


--
-- Name: profiles profiles_insert_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY profiles_insert_own ON public.profiles FOR INSERT TO authenticated WITH CHECK ((( SELECT auth.uid() AS uid) = id));


--
-- Name: profiles profiles_select_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY profiles_select_own ON public.profiles FOR SELECT TO authenticated USING ((( SELECT auth.uid() AS uid) = id));


--
-- Name: profiles profiles_update_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY profiles_update_own ON public.profiles FOR UPDATE TO authenticated USING ((( SELECT auth.uid() AS uid) = id)) WITH CHECK ((( SELECT auth.uid() AS uid) = id));


--
-- Name: trusted_devices; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.trusted_devices ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_vectors; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_vectors ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: vector_indexes; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.vector_indexes ENABLE ROW LEVEL SECURITY;

--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


--
-- PostgreSQL database dump complete
--

\unrestrict EUdXtk4EVCl9MdOKLWzK4aEctzNzDntwy3LWjzBMuFov6Ye4RfvFArBsMjcHhbY

