-- テーブルの追加列の変更（水質検査ポイントマスター）
ALTER TABLE mst_water_survey_point
ADD COLUMN IF NOT EXISTS survey_type_cd bigint,
DROP COLUMN IF EXISTS survey_type_list;
-- コメント追加(水質検査箇所マスタ)
COMMENT ON COLUMN "mst_water_survey_point"."survey_type_cd" IS E'水質検査種別コード';