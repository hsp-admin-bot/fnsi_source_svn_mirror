--テーブル（水質検査マスター）
ALTER TABLE mst_water_survey_type
ALTER COLUMN graph_upper_limit TYPE decimal,
ALTER COLUMN graph_lower_limit TYPE decimal,
ALTER COLUMN upper_threshold TYPE decimal,
ALTER COLUMN lower_threshold TYPE decimal;

-- コメント追加(水質検査種別マスタ)
COMMENT ON COLUMN "mst_water_survey_type"."upper_threshold" IS E'閾値上限';
COMMENT ON COLUMN "mst_water_survey_type"."lower_threshold" IS E'閾値下限';
COMMENT ON COLUMN "mst_water_survey_type"."graph_upper_limit" IS E'グラフ上限';
COMMENT ON COLUMN "mst_water_survey_type"."graph_lower_limit" IS E'グラフ下限';