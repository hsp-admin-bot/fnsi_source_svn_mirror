--オプション申込テーブル
DROP TABLE IF EXISTS sal_subscription_manage;
CREATE TABLE sal_subscription_manage
(
    subscription_no bigserial NOT NULL, --申込管理番号
    facility_cd character varying(6) NOT NULL,  --施設コード
    is_first character varying(1),  --初回申込フラグ
    subscription_plan_name character varying,  --初回申込プラン名
    subscription_fnc jsonb,  --申込機能
    subscription_adv jsonb,  --申込拡張機能
    subscription_status character varying,  --申込ステータス
    applicant bigint,  --申込者
    receptionist bigint, --受付担当者
    reception_date timestamp(3),  --受付日時
    completer bigint,  --完了担当者
    complete_date timestamp(3), --完了日時
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    CONSTRAINT unq_sal_subscription_manage_01 PRIMARY KEY (subscription_no)
);

COMMENT ON TABLE "sal_subscription_manage" IS E'オプション申込';
COMMENT ON COLUMN "sal_subscription_manage"."subscription_no" IS E'申込管理番号';
COMMENT ON COLUMN "sal_subscription_manage"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "sal_subscription_manage"."is_first" IS E'初回申込フラグ';
COMMENT ON COLUMN "sal_subscription_manage"."subscription_plan_name" IS E'初回申込プラン名';
COMMENT ON COLUMN "sal_subscription_manage"."subscription_fnc" IS E'申込機能';
COMMENT ON COLUMN "sal_subscription_manage"."subscription_adv" IS E'申込拡張機能';
COMMENT ON COLUMN "sal_subscription_manage"."subscription_status" IS E'申込ステータス';
COMMENT ON COLUMN "sal_subscription_manage"."applicant" IS E'申込者';
COMMENT ON COLUMN "sal_subscription_manage"."receptionist" IS E'受付担当者';
COMMENT ON COLUMN "sal_subscription_manage"."reception_date" IS E'受付日時';
COMMENT ON COLUMN "sal_subscription_manage"."completer" IS E'完了担当者';
COMMENT ON COLUMN "sal_subscription_manage"."complete_date" IS E'完了日時';
COMMENT ON COLUMN "sal_subscription_manage"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sal_subscription_manage"."up_date" IS E'更新日時';
COMMENT ON COLUMN "sal_subscription_manage"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "sal_subscription_manage"."is_del" IS E'削除フラグ';
