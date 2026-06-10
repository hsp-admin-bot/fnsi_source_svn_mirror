-- テーブル削除
DROP TABLE IF EXISTS mst_take_medicine;
-- テーブル削除
CREATE TABLE mst_take_medicine (
  take_medicine_cd bigserial NOT NULL,  --用法用語マスタコード
  facility_cd character varying(6) NOT NULL, --施設コード
  list_class character varying(2) NOT NULL, --リスト種別
  list_name character varying,  --リスト名
  list_details character varying, --リスト選択肢
  is_disp character varying(1) DEFAULT '1',  --表示フラグ
  is_del character varying(1) DEFAULT '0',  --削除フラグ
  reg_date timestamp(3),  --登録日時
  up_date timestamp(3),  --更新日時
  CONSTRAINT unq_mst_take_medicine_01 PRIMARY KEY (take_medicine_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_take_medicine" IS E'用法・用語マスタ';
COMMENT ON COLUMN "mst_take_medicine"."take_medicine_cd" IS E'用法用語マスタコード';
COMMENT ON COLUMN "mst_take_medicine"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_take_medicine"."list_class" IS E'リスト種別';
COMMENT ON COLUMN "mst_take_medicine"."list_name" IS E'リスト名';
COMMENT ON COLUMN "mst_take_medicine"."list_details" IS E'リスト選択肢';
COMMENT ON COLUMN "mst_take_medicine"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_take_medicine"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_take_medicine"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_take_medicine"."up_date" IS E'更新日時';