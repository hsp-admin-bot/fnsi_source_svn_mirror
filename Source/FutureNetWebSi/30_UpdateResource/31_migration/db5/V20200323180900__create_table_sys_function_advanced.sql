CREATE TABLE IF NOT EXISTS sys_function_advanced
(
    function_adv_cd character varying(6) NOT NULL,  --拡張機能コード
    function_adv_name character varying(40) NOT NULL,  --拡張機能名称
    disp_order numeric(5),  --表示順
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_sys_function_advanced_01 PRIMARY KEY (function_adv_cd)
);

COMMENT ON TABLE "sys_function_advanced" IS E'拡張機能';
COMMENT ON COLUMN "sys_function_advanced"."function_adv_cd" IS E'拡張機能コード';
COMMENT ON COLUMN "sys_function_advanced"."function_adv_name" IS E'拡張機能名称';
COMMENT ON COLUMN "sys_function_advanced"."disp_order" IS E'表示順';
COMMENT ON COLUMN "sys_function_advanced"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "sys_function_advanced"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "sys_function_advanced"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sys_function_advanced"."up_date" IS E'更新日時';
