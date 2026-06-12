\set ON_ERROR_STOP on

\echo [init] ensure login role nkk
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'nkk') THEN
        CREATE ROLE nkk LOGIN PASSWORD 'nkk';
    ELSE
        ALTER ROLE nkk WITH LOGIN PASSWORD 'nkk';
    END IF;
END
$$;

\echo [init] disconnect sessions for convert_db
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'convert_db'
  AND pid <> pg_backend_pid();

\echo [init] recreate convert_db
DROP DATABASE IF EXISTS convert_db;
CREATE DATABASE convert_db OWNER nkk;

\connect convert_db

SET ROLE nkk;

\echo [init] apply convert_db core schema (V1)
\ir convert_db/V1__create_core_tables.sql

\echo [init] apply convert_db pg fk config (V2)
\ir convert_db/V2__insert_fk_migration_config.sql

\echo [init] apply convert_db mongo fk config (V3)
\ir convert_db/V3__insert_fk_mongo_migration_config.sql

RESET ROLE;

\echo [init] convert_db complete
