\set ON_ERROR_STOP on

\echo [init] ensure login role nkk4
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'nkk4') THEN
        CREATE ROLE nkk4 LOGIN PASSWORD 'nkk4';
    ELSE
        ALTER ROLE nkk4 WITH LOGIN PASSWORD 'nkk4';
    END IF;
END
$$;

\echo [init] disconnect sessions for ntss_db4
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'ntss_db4'
  AND pid <> pg_backend_pid();

\echo [init] recreate ntss_db4
DROP DATABASE IF EXISTS ntss_db4;
CREATE DATABASE ntss_db4 OWNER nkk4;

\connect ntss_db4

DROP SCHEMA IF EXISTS ntss CASCADE;
CREATE SCHEMA ntss AUTHORIZATION nkk4;

\echo [init] ntss_db4 complete (database + schema ntss)
