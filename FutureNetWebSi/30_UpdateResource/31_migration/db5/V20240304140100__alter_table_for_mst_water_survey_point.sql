-- 列の削除
ALTER TABLE mst_water_survey_point
DROP COLUMN IF EXISTS in_hospital_cd_1,
DROP COLUMN IF EXISTS in_hospital_cd_2;

-- 列の追加
ALTER TABLE mst_water_survey_point
ADD COLUMN IF NOT EXISTS in_hospital_cd_1 character varying(20),
ADD COLUMN IF NOT EXISTS in_hospital_cd_2 character varying(20);

-- コメント修正
COMMENT ON COLUMN "mst_water_survey_point"."in_hospital_cd_1" IS E'連携コード1';
COMMENT ON COLUMN "mst_water_survey_point"."in_hospital_cd_2" IS E'連携コード2';
