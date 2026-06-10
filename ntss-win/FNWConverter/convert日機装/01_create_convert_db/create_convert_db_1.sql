--存在時オブジェクトを削除する
--DROP DATABASE IF EXISTS convert_db;
--DROP TABLESPACE IF EXISTS convert_db;
--DROP TABLESPACE IF EXISTS convert_index;
--DROP ROLE IF EXISTS "convert";

--スキーマの作成
--CREATE SCHEMA ntss;
--オブジェクト作成
--ロール
CREATE ROLE "convert" LOGIN PASSWORD 'convert' NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
ALTER ROLE "convert" SET search_path = ntss, public;

--GRANT
GRANT "convert" TO "dbuser";

--DB ERROR:  must be member of role "convert"
CREATE DATABASE convert_db
  WITH OWNER = convert
       TEMPLATE = template0
       ENCODING = 'UTF8'
       LC_COLLATE = 'C'
       LC_CTYPE = 'C'
       CONNECTION LIMIT = -1;
--ログアウト
\q
