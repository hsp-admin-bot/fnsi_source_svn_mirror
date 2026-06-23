-- テーブル削除
DROP TABLE IF EXISTS mst_add_monitor;
-- テーブル作成
CREATE TABLE mst_add_monitor
(
    vital_monitor_item_cd bigserial NOT NULL,  --システムで管理する一意なバイタル・モニタ項目コード
    facility_cd character varying(6) NOT NULL,  --施設コード
    vital_monitor_class character varying(1),  --バイタル・モニタ区分
    vital_monitor_item_name character varying,  --バイタルモニタ項目名称
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_add_monitor_01 PRIMARY KEY (vital_monitor_item_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mst_add_monitor" IS E'バイタル・モニタ項目追加マスタ';
COMMENT ON COLUMN "mst_add_monitor"."vital_monitor_item_cd" IS E'システムで管理する一意なバイタル・モニタ項目コード';
COMMENT ON COLUMN "mst_add_monitor"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_add_monitor"."vital_monitor_class" IS E'バイタル・モニタ区分';
COMMENT ON COLUMN "mst_add_monitor"."vital_monitor_item_name" IS E'バイタルモニタ項目名称';
COMMENT ON COLUMN "mst_add_monitor"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_add_monitor"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_add_monitor"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_add_monitor"."up_date" IS E'更新日時';
