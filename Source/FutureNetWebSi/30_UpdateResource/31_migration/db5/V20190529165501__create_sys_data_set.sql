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
    db_class integer NOT NULL,  --DB種別
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
COMMENT ON COLUMN "sys_data_set"."db_class" IS E'DB種別';
COMMENT ON COLUMN "sys_data_set"."detail" IS E'詳細';
COMMENT ON COLUMN "sys_data_set"."can_repeat" IS E'繰返し可否フラグ';
COMMENT ON COLUMN "sys_data_set"."use_application" IS E'使用用途';
COMMENT ON COLUMN "sys_data_set"."report_class" IS E'帳票種別';
COMMENT ON COLUMN "sys_data_set"."memo" IS E'備考';
COMMENT ON COLUMN "sys_data_set"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sys_data_set"."up_date" IS E'更新日時';
