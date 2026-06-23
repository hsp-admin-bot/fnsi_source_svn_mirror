-- データリストカテゴリ詳細
DROP TABLE IF EXISTS sys_data_list_detail;
-- データリストカテゴリ詳細
CREATE TABLE sys_data_list_detail
(
    data_list_detail_cd bigserial NOT NULL, --データリスト詳細コード
    disp_order integer, --表示順
    category_cd bigint NOT NULL,  --カテゴリコード
    master_display_name character varying,  --マスタ表示パターン
    master_display_type character varying(1) NOT NULL, --マスタ表示区分
    master_display_sql character varying,  --master_display_sql
    function_display_name character varying,  --一覧表示パターン
    function_display_type character varying(1) NOT NULL, --一覧表示区分
    function_display_sql character varying,  --一覧表示SQL
    data_set jsonb, --データセット
    cell_display character varying, --セル表示パターン
    CONSTRAINT unq_sys_data_list_detail_01 PRIMARY KEY (data_list_detail_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "sys_data_list_detail" IS E'データリストカテゴリ詳細';
COMMENT ON COLUMN "sys_data_list_detail"."data_list_detail_cd" IS E'データリスト詳細コード';
COMMENT ON COLUMN "sys_data_list_detail"."disp_order" IS E'表示順';
COMMENT ON COLUMN "sys_data_list_detail"."category_cd" IS E'カテゴリコード';
COMMENT ON COLUMN "sys_data_list_detail"."master_display_name" IS E'マスタ表示パターン';
COMMENT ON COLUMN "sys_data_list_detail"."master_display_type" IS E'マスタ表示区分';
COMMENT ON COLUMN "sys_data_list_detail"."master_display_sql" IS E'マスタデータ取得SQL';
COMMENT ON COLUMN "sys_data_list_detail"."function_display_name" IS E'一覧表示パターン';
COMMENT ON COLUMN "sys_data_list_detail"."function_display_type" IS E'一覧表示区分';
COMMENT ON COLUMN "sys_data_list_detail"."function_display_sql" IS E'一覧データ取得SQL';
COMMENT ON COLUMN "sys_data_list_detail"."data_set" IS E'データセット';
COMMENT ON COLUMN "sys_data_list_detail"."cell_display" IS E'セル表示パターン';
