DROP TABLE IF EXISTS mst_medicine_group;

CREATE TABLE mst_medicine_group (
  medicine_group_cd bigserial NOT NULL,
  facility_cd character varying(6),
  medicine_group_name character varying,
  reg_medicine_info jsonb,
  medicine_group_unit character varying,
  week_flg character varying(1),
  graph_upper numeric(8,2),
  graph_lower numeric(8,2),
  is_disp character varying(1) DEFAULT '1',
  is_del character varying(1) DEFAULT '0',
  reg_date timestamp(3),
  up_date timestamp(3),
  CONSTRAINT unq_medicine_group_01 PRIMARY KEY (medicine_group_cd)
);

COMMENT ON TABLE "mst_medicine_group" IS E'薬剤グループマスタ';
COMMENT ON COLUMN "mst_medicine_group"."medicine_group_cd" IS E'薬剤グループコード';
COMMENT ON COLUMN "mst_medicine_group"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_medicine_group"."medicine_group_name" IS E'薬剤グループ名';
COMMENT ON COLUMN "mst_medicine_group"."reg_medicine_info" IS E'登録薬剤情報';
COMMENT ON COLUMN "mst_medicine_group"."medicine_group_unit" IS E'単位';
COMMENT ON COLUMN "mst_medicine_group"."week_flg" IS E'週間投与フラグ';
COMMENT ON COLUMN "mst_medicine_group"."graph_upper" IS E'グラフ上限';
COMMENT ON COLUMN "mst_medicine_group"."graph_lower" IS E'グラフ下限';
COMMENT ON COLUMN "mst_medicine_group"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_medicine_group"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_medicine_group"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_medicine_group"."up_date" IS E'更新日時';
