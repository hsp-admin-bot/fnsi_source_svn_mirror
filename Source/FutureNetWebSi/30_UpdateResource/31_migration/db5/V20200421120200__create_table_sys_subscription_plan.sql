--プラン定義テーブル
DROP TABLE IF EXISTS sys_subscription_plan;
CREATE TABLE sys_subscription_plan
(
    subscription_plan_no bigserial NOT NULL, --申込プラン番号
    subscription_plan_name character varying,  --申込プラン名
    subscription_plan_fnc jsonb,  --申込プラン機能
    subscription_plan_adv jsonb,  --申込プラン拡張機能
    disp_order integer,  --表示順
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    is_disp character varying(1) DEFAULT '1',  --表示設定
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    CONSTRAINT unq_sys_subscription_plan_01 PRIMARY KEY (subscription_plan_no)
);

COMMENT ON TABLE "sys_subscription_plan" IS E'プラン定義';
COMMENT ON COLUMN "sys_subscription_plan"."subscription_plan_no" IS E'申込プラン番号';
COMMENT ON COLUMN "sys_subscription_plan"."subscription_plan_name" IS E'申込プラン名';
COMMENT ON COLUMN "sys_subscription_plan"."subscription_plan_fnc" IS E'申込プラン機能';
COMMENT ON COLUMN "sys_subscription_plan"."subscription_plan_adv" IS E'申込プラン拡張機能';
COMMENT ON COLUMN "sys_subscription_plan"."disp_order" IS E'表示順';
COMMENT ON COLUMN "sys_subscription_plan"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sys_subscription_plan"."up_date" IS E'更新日時';
COMMENT ON COLUMN "sys_subscription_plan"."is_disp" IS E'表示設定';
COMMENT ON COLUMN "sys_subscription_plan"."is_del" IS E'削除フラグ';
