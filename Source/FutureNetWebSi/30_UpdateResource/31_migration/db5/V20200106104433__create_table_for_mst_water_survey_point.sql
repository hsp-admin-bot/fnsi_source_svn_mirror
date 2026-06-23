-- テーブル削除(水質検査箇所マスタ)
DROP TABLE IF EXISTS mst_water_survey_point;
-- テーブル作成(水質検査箇所マスタ)
CREATE TABLE mst_water_survey_point
(
    survey_point_cd bigserial NOT NULL,  
    point_name character varying(64),
    facility_cd character varying(6),  
    machine_no bigint,  
    survey_type_list jsonb,
    is_disp character varying(1) DEFAULT '1',  
    is_del character varying(1) DEFAULT '0',  
    reg_date timestamp(3),  
    up_date timestamp(3),
    CONSTRAINT unq_mst_water_survey_point_01 PRIMARY KEY (survey_point_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加(水質検査箇所マスタ)
COMMENT ON TABLE "mst_water_survey_point" IS E'水質検査箇所マスタ';
COMMENT ON COLUMN "mst_water_survey_point"."survey_point_cd" IS E'水質検査箇所コード';
COMMENT ON COLUMN "mst_water_survey_point"."point_name" IS E'水質検査箇所名';
COMMENT ON COLUMN "mst_water_survey_point"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_water_survey_point"."machine_no" IS E'対象装置';
COMMENT ON COLUMN "mst_water_survey_point"."survey_type_list" IS E'水質調査種別';
COMMENT ON COLUMN "mst_water_survey_point"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_water_survey_point"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_water_survey_point"."reg_date" IS E'登録日';
COMMENT ON COLUMN "mst_water_survey_point"."up_date" IS E'更新日';