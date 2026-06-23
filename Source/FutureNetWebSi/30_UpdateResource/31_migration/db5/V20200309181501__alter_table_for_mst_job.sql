-- 列の削除
ALTER TABLE mst_job
DROP COLUMN IF EXISTS in_hospital_cd_1;

-- 列の追加
ALTER TABLE mst_job 
ADD COLUMN IF NOT EXISTS in_hospital_cd_1 character varying(20);

-- コメント修正
COMMENT ON COLUMN "mst_job"."in_hospital_cd_1" IS E'院内コード1';