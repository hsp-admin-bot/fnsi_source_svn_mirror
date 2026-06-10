-- 列の削除
ALTER TABLE mst_bed
DROP COLUMN IF EXISTS in_hospital_cd_1,
DROP COLUMN IF EXISTS in_hospital_cd_2;

-- 列の追加
ALTER TABLE mst_bed
ADD COLUMN IF NOT EXISTS in_hospital_cd_1 character varying(20),
ADD COLUMN IF NOT EXISTS in_hospital_cd_2 character varying(20);

-- コメント修正
COMMENT ON COLUMN "mst_bed"."in_hospital_cd_1" IS E'院内コード1';
COMMENT ON COLUMN "mst_bed"."in_hospital_cd_2" IS E'院内コード2';