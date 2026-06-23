-- テーブル削除(水質管理)
DROP TABLE IF EXISTS mnt_water_survey;
-- テーブル作成(水質管理)
CREATE TABLE mnt_water_survey
(
    survey_record_no bigserial NOT NULL,  
    facility_cd character varying(6) NOT NULL,
    inspection_date timestamp(3),
    survey_data jsonb,
    is_disp character varying(1) DEFAULT '1',  
    is_del character varying(1) DEFAULT '0',  
    reg_date timestamp(3),  
    up_date timestamp(3),
    CONSTRAINT unq_mnt_water_survey_01 PRIMARY KEY (survey_record_no)
)
WITH (
    OIDS=FALSE
);
-- コメント追加(水質管理)
COMMENT ON TABLE "mnt_water_survey" IS E'水質管理';
COMMENT ON COLUMN "mnt_water_survey"."survey_record_no" IS E'水質調査記録番号';
COMMENT ON COLUMN "mnt_water_survey"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mnt_water_survey"."inspection_date" IS E'検査日';
COMMENT ON COLUMN "mnt_water_survey"."survey_data" IS E'水質データ';
COMMENT ON COLUMN "mnt_water_survey"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mnt_water_survey"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mnt_water_survey"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mnt_water_survey"."up_date" IS E'更新日時';
