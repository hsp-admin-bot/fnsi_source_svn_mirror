-- テーブル削除(水質検査種別マスタ)
DROP TABLE IF EXISTS mst_water_survey_type;
-- テーブル作成(水質検査種別マスタ)
CREATE TABLE mst_water_survey_type
(
    survey_type_cd bigserial NOT NULL,  
    survey_type_name character varying,
	facility_cd character varying(6),
	integer_digits integer,
	decimal_digits integer,
	unit character varying,
	initial_value character varying,
	initial_string character varying,
	upper_threshold integer,
	lower_threshold integer,
	is_show_graph character varying,
	graph_upper_limit integer,
	graph_lower_limit integer,
	is_disp character varying(1) DEFAULT '1',  
    is_del character varying(1) DEFAULT '0',
	reg_date timestamp(3),  
    up_date timestamp(3),
    CONSTRAINT unq_mst_water_survey_type_01 PRIMARY KEY (survey_type_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加(水質検査種別マスタ)
COMMENT ON TABLE "mst_water_survey_type" IS E'水質検査種別マスタ';
COMMENT ON COLUMN "mst_water_survey_type"."survey_type_cd" IS E'水質検査種別コード';
COMMENT ON COLUMN "mst_water_survey_type"."survey_type_name" IS E'水質検査種別名';
COMMENT ON COLUMN "mst_water_survey_type"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_water_survey_type"."integer_digits" IS E'整数部桁数';
COMMENT ON COLUMN "mst_water_survey_type"."decimal_digits" IS E'小数部桁数';
COMMENT ON COLUMN "mst_water_survey_type"."unit" IS E'単位';
COMMENT ON COLUMN "mst_water_survey_type"."initial_value" IS E'結果初期値';
COMMENT ON COLUMN "mst_water_survey_type"."initial_string" IS E'しきい値判断上下区分';
COMMENT ON COLUMN "mst_water_survey_type"."upper_threshold" IS E'閾値上限';
COMMENT ON COLUMN "mst_water_survey_type"."lower_threshold" IS E'閾値下限';
COMMENT ON COLUMN "mst_water_survey_type"."is_show_graph" IS E'グラフ表示';
COMMENT ON COLUMN "mst_water_survey_type"."graph_upper_limit" IS E'グラフ上限';
COMMENT ON COLUMN "mst_water_survey_type"."graph_lower_limit" IS E'グラフ下限';
COMMENT ON COLUMN "mst_water_survey_type"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_water_survey_type"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_water_survey_type"."up_date" IS E'更新日';
COMMENT ON COLUMN "mst_water_survey_type"."reg_date" IS E'登録日';

