--スキーマの作成
CREATE SCHEMA ntss;

--カレントスキーマの設定
alter user convert set search_path TO ntss,public;

-- テーブル作成
CREATE TABLE batch_convert_status
(
  convert_proc_id serial NOT NULL,
  facility_cd character varying(6),
  status character varying(10),
  job_instance_id bigint,
  job_name character varying(100) NOT NULL,
  reg_date timestamp(3) without time zone,
  up_date timestamp(3) without time zone,
  CONSTRAINT unq_batch_convert_status_01 PRIMARY KEY (convert_proc_id)
-- USING INDEX TABLESPACE convert_index
)
WITH (
  OIDS=FALSE
);
--   tablespace convert_db;
-- ユーザ設定
ALTER TABLE batch_convert_status OWNER TO convert;

-- テーブル作成
CREATE TABLE batch_convert_table_status
(
  order_no bigserial NOT NULL,
  convert_proc_id integer NOT NULL,
  job_instance_id bigint,
  table_name character varying(100),
  sql_file_path character varying(200),
  status character varying(10),
  proc_name character varying(100),
  content character varying(200),
  reg_date timestamp(3) without time zone,
  CONSTRAINT unq_batch_convert_table_status_01 PRIMARY KEY (order_no)
--   USING INDEX TABLESPACE convert_index
)
WITH (
  OIDS=FALSE
);
--   tablespace convert_db;
-- ユーザ設定
ALTER TABLE batch_convert_table_status OWNER TO convert;

-- Table: ntss.convert_queue

-- DROP TABLE ntss.convert_queue;

CREATE TABLE ntss.convert_queue
(
    facility_cd character varying(6) COLLATE pg_catalog."default" NOT NULL,
    status bigint,
    inputfilepath text COLLATE pg_catalog."default",
    reg_date timestamp(3) without time zone,
    CONSTRAINT facility_cd UNIQUE (facility_cd)
--         USING INDEX TABLESPACE convert_db
)
WITH (
    OIDS = FALSE
);
-- TABLESPACE convert_db;

ALTER TABLE ntss.convert_queue
    OWNER to "convert";

COMMENT ON TABLE ntss.convert_queue
    IS 'コンバート実行順序を管理';

COMMENT ON COLUMN ntss.convert_queue.status
    IS '0 : 未実行
1 : 実行中
2 : 実行済';

COMMENT ON COLUMN ntss.convert_queue.reg_date
    IS '登録日時';

--一旦ログアウト
\q
