-- テーブル削除(水質管理)
DROP TABLE IF EXISTS mnt_water_survey;
-- テーブル作成(水質管理)
CREATE TABLE mnt_water_survey
(
    survey_record_no bigserial NOT NULL,  
    survey_point_cd bigint,
    survey_type_cd bigint,
    facility_cd character varying(6),
    inspection_date timestamp(3),
    is_disp character varying(1) DEFAULT '1',  
    is_del character varying(1) DEFAULT '0',  
    reg_date timestamp(3),  
    up_date timestamp(3),  
    plan character varying(1) DEFAULT '0',
    collection_time character varying(5),
    picker_cd integer,
    inspector_cd integer,
    result_value numeric,
    result_text character varying,
    unit character varying,
    CONSTRAINT unq_mnt_water_survey_01 PRIMARY KEY (survey_record_no)
)
WITH (
    OIDS=FALSE
);
-- コメント追加(水質管理)
COMMENT ON TABLE "mnt_water_survey" IS E'水質管理';
COMMENT ON COLUMN "mnt_water_survey"."survey_record_no" IS E'水質調査記録番号';
COMMENT ON COLUMN "mnt_water_survey"."survey_point_cd" IS E'調査箇所コード';
COMMENT ON COLUMN "mnt_water_survey"."survey_type_cd" IS E'水質検査種別コード';
COMMENT ON COLUMN "mnt_water_survey"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mnt_water_survey"."inspection_date" IS E'検査日';
COMMENT ON COLUMN "mnt_water_survey"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mnt_water_survey"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mnt_water_survey"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mnt_water_survey"."up_date" IS E'更新日時';
COMMENT ON COLUMN "mnt_water_survey"."plan" IS E'予定フラグ';
COMMENT ON COLUMN "mnt_water_survey"."collection_time" IS E'採取時刻';
COMMENT ON COLUMN "mnt_water_survey"."picker_cd" IS E'採取者';
COMMENT ON COLUMN "mnt_water_survey"."inspector_cd" IS E'検査者';
COMMENT ON COLUMN "mnt_water_survey"."result_value" IS E'結果値';
COMMENT ON COLUMN "mnt_water_survey"."result_text" IS E'結果文字列番号';
COMMENT ON COLUMN "mnt_water_survey"."unit" IS E'単位';
