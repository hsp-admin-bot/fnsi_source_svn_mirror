-- データリストカテゴリ
DROP TABLE IF EXISTS sys_data_list_category;
-- データリストカテゴリ
CREATE TABLE sys_data_list_category
(
    category_cd bigserial NOT NULL,  --カテゴリコード
    category_name character varying NOT NULL,  --カテゴリ名
    template_cd integer NOT NULL, --テンプレートコード
    disp_order integer, --表示順
    CONSTRAINT unq_sys_data_list_category_01 PRIMARY KEY (category_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "sys_data_list_category" IS E'データリストカテゴリ';
COMMENT ON COLUMN "sys_data_list_category"."category_cd" IS E'カテゴリコード';
COMMENT ON COLUMN "sys_data_list_category"."category_name" IS E'カテゴリ名';
COMMENT ON COLUMN "sys_data_list_category"."template_cd" IS E'テンプレートコード';
COMMENT ON COLUMN "sys_data_list_category"."disp_order" IS E'表示順';
