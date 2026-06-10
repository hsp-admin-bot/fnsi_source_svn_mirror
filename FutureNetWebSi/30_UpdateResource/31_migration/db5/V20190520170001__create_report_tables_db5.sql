--------------------------------------------------
-- 帳票マスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_report;
-- テーブル作成
CREATE TABLE mst_report
(
    report_cd bigserial NOT NULL,  --レポートCD
    facility_cd character varying(6) NOT NULL REFERENCES mst_facility(facility_cd),  --施設コード
    report_name character varying(20),  --帳票名
    report_path jsonb,  --3ファイルのフルパス
    report_class integer,  --帳票種別
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_report_01 PRIMARY KEY (report_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_report" IS E'帳票マスタ';
COMMENT ON COLUMN "mst_report"."report_cd" IS E'レポートCD';
COMMENT ON COLUMN "mst_report"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_report"."report_name" IS E'帳票名';
COMMENT ON COLUMN "mst_report"."report_path" IS E'3ファイルのフルパス';
COMMENT ON COLUMN "mst_report"."report_class" IS E'帳票種別';
COMMENT ON COLUMN "mst_report"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_report"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_report"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_report"."up_date" IS E'更新日時';

--------------------------------------------------
-- データセット
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS sys_data_set;
-- テーブル作成
CREATE TABLE sys_data_set
(
    sql_cd bigserial NOT NULL,  --SQLCD
    sql character varying(2048) NOT NULL,  --SQL
    detail jsonb NOT NULL,  --詳細
    can_repeat character varying(1),  --繰返し可否フラグ
    use_application jsonb,  --使用用途
    report_class jsonb,  --帳票種別
    memo character varying(256),  --備考
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_sys_data_set_01 PRIMARY KEY (sql_cd)
);
-- コメント追加
COMMENT ON TABLE "sys_data_set" IS E'データセット';
COMMENT ON COLUMN "sys_data_set"."sql_cd" IS E'SQLCD';
COMMENT ON COLUMN "sys_data_set"."sql" IS E'SQL';
COMMENT ON COLUMN "sys_data_set"."detail" IS E'詳細';
COMMENT ON COLUMN "sys_data_set"."can_repeat" IS E'繰返し可否フラグ';
COMMENT ON COLUMN "sys_data_set"."use_application" IS E'使用用途';
COMMENT ON COLUMN "sys_data_set"."report_class" IS E'帳票種別';
COMMENT ON COLUMN "sys_data_set"."memo" IS E'備考';
COMMENT ON COLUMN "sys_data_set"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sys_data_set"."up_date" IS E'更新日時';
