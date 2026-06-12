\set ON_ERROR_STOP on

\echo [init] ensure login role nkk6
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'nkk6') THEN
        CREATE ROLE nkk6 LOGIN PASSWORD 'nkk6';
    ELSE
        ALTER ROLE nkk6 WITH LOGIN PASSWORD 'nkk6';
    END IF;
END
$$;

\echo [init] disconnect sessions for ntss_db6
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'ntss_db6'
  AND pid <> pg_backend_pid();

\echo [init] recreate ntss_db6
DROP DATABASE IF EXISTS ntss_db6;
CREATE DATABASE ntss_db6 OWNER nkk6;

\connect ntss_db6

DROP SCHEMA IF EXISTS ntss CASCADE;
CREATE SCHEMA ntss AUTHORIZATION nkk6;

\echo [init] ntss_db6 complete (database + schema ntss)
