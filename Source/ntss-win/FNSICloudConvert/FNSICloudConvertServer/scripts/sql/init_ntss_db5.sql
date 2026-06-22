\set ON_ERROR_STOP on

\echo [init] ensure login role nkk5
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'nkk5') THEN
        CREATE ROLE nkk5 LOGIN PASSWORD 'nkk5';
    ELSE
        ALTER ROLE nkk5 WITH LOGIN PASSWORD 'nkk5';
    END IF;
END
$$;

\echo [init] disconnect sessions for ntss_db5
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'ntss_db5'
  AND pid <> pg_backend_pid();

\echo [init] recreate ntss_db5
DROP DATABASE IF EXISTS ntss_db5;
CREATE DATABASE ntss_db5 OWNER nkk5;

\connect ntss_db5

DROP SCHEMA IF EXISTS ntss CASCADE;
CREATE SCHEMA ntss AUTHORIZATION nkk5;

\echo [init] ntss_db5 complete (database + schema ntss)
