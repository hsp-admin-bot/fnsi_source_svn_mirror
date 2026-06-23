--投薬支援マスタ
DROP TABLE IF EXISTS mst_medicine_support;

CREATE TABLE mst_medicine_support (
  medicine_support_cd bigserial NOT NULL,
  facility_cd character varying(6),
  medicine_support_name character varying,
  target_inspection numeric(8,0),
  detail_info jsonb,
  is_disp character varying(1) DEFAULT '1',
  is_del character varying(1) DEFAULT '0',
  reg_date timestamp(3),
  up_date timestamp(3),
  CONSTRAINT unq_medicine_support_01 PRIMARY KEY (medicine_support_cd)
);

COMMENT ON TABLE "mst_medicine_support" IS E'投薬支援マスタ';
COMMENT ON COLUMN "mst_medicine_support"."medicine_support_cd" IS E'投薬支援コード';
COMMENT ON COLUMN "mst_medicine_support"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_medicine_support"."medicine_support_name" IS E'投薬支援パターン名';
COMMENT ON COLUMN "mst_medicine_support"."target_inspection" IS E'目標検査値';
COMMENT ON COLUMN "mst_medicine_support"."detail_info" IS E'詳細';
COMMENT ON COLUMN "mst_medicine_support"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_medicine_support"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_medicine_support"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_medicine_support"."up_date" IS E'更新日時';
