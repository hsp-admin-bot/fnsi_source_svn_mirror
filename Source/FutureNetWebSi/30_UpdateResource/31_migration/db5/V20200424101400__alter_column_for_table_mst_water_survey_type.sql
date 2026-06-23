--テーブル（水質検査マスター）
ALTER TABLE mst_water_survey_type
  ALTER COLUMN graph_upper_limit TYPE numeric,
  ALTER COLUMN graph_lower_limit TYPE numeric,
  ALTER COLUMN upper_threshold TYPE numeric,
  ALTER COLUMN lower_threshold TYPE numeric;