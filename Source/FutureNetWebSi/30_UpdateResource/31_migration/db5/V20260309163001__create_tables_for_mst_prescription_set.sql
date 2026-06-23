-- #11318 処方セットマスタ
-- テーブル作成
CREATE TABLE IF NOT EXISTS mst_prescription_set
(
  prescription_set_cd bigserial NOT NULL,  --処方セットコード
  facility_cd character varying(6) NOT NULL,  --施設コード
  prescription_set_name character varying(256) NOT NULL,  --処方セット名
  set_info jsonb NOT NULL DEFAULT '[]'::jsonb, --セット情報
  in_hospital_cd_1 character varying(20), --連携コード1
  in_hospital_cd_2 character varying(20), --連携コード2
  is_disp character varying(1) DEFAULT '1',  --表示フラグ
  is_del character varying(1) DEFAULT '0',  --削除フラグ
  reg_date timestamp(3),  --登録日時
  up_date timestamp(3),  --更新日時
  CONSTRAINT unq_mst_prescription_set_01 PRIMARY KEY (prescription_set_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_prescription_set" IS E'処方セットマスタ';
COMMENT ON COLUMN "mst_prescription_set"."prescription_set_cd" IS E'システムで管理する一意な処方セットコード';
COMMENT ON COLUMN "mst_prescription_set"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_prescription_set"."prescription_set_name" IS E'処方セット名';
COMMENT ON COLUMN "mst_prescription_set"."set_info" IS E'セット情報';
COMMENT ON COLUMN "mst_prescription_set"."in_hospital_cd_1" IS E'連携コード1';
COMMENT ON COLUMN "mst_prescription_set"."in_hospital_cd_2" IS E'連携コード2';
COMMENT ON COLUMN "mst_prescription_set"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_prescription_set"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_prescription_set"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_prescription_set"."up_date" IS E'更新日時';
