-- Disallow new connections
UPDATE pg_database SET datallowconn = 'false' WHERE datname = 'convert_db';

ALTER DATABASE convert_db CONNECTION LIMIT 1;

--存在時オブジェクトを削除する
DROP DATABASE IF EXISTS convert_db;

--DROP TABLESPACE IF EXISTS convert_db;

--DROP TABLESPACE IF EXISTS convert_index;

DROP ROLE IF EXISTS "convert";

DROP SCHEMA IF EXISTS ntss CASCADE;
