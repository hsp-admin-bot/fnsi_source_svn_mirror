-- 設定値読み込み履歴テーブル削除
DROP TABLE IF EXISTS ord_treat_condition;
-- 設定値読み込み履歴テーブル作成
CREATE TABLE ord_treat_condition
(
    condition_cd bigserial NOT NULL,  --治療条件管理番号
    ord_no bigint,  --オーダー番号
    facility_cd character varying(6) NOT NULL,  --施設コード
    machine_no bigint NOT NULL,  --装置番号
    receive_date timestamp(3),  --条件取得日時
    treat_condition jsonb,  --治療条件
    treat_class smallint,  --区分
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時


    CONSTRAINT unq_ord_treat_condition_01 PRIMARY KEY (condition_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "ord_treat_condition" IS E'設定値読み込み履歴';
COMMENT ON COLUMN "ord_treat_condition"."condition_cd" IS E'治療条件管理番号';
COMMENT ON COLUMN "ord_treat_condition"."ord_no" IS E'オーダー番号';
COMMENT ON COLUMN "ord_treat_condition"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "ord_treat_condition"."machine_no" IS E'装置番号';
COMMENT ON COLUMN "ord_treat_condition"."receive_date" IS E'条件取得日時';
COMMENT ON COLUMN "ord_treat_condition"."treat_condition" IS E'治療条件';
COMMENT ON COLUMN "ord_treat_condition"."treat_class" IS E'区分';
COMMENT ON COLUMN "ord_treat_condition"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "ord_treat_condition"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "ord_treat_condition"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "ord_treat_condition"."up_date" IS E'更新日時';
