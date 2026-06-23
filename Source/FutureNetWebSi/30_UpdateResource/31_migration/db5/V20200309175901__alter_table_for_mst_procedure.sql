-- 列の削除
ALTER TABLE mst_procedure
DROP COLUMN IF EXISTS in_hosp_a_startdate,
DROP COLUMN IF EXISTS in_hosp_b_startdate,
DROP COLUMN IF EXISTS in_hospital_cd_1,
DROP COLUMN IF EXISTS in_hospital_cd_2,
DROP COLUMN IF EXISTS in_hospital_cd_a1,
DROP COLUMN IF EXISTS in_hospital_cd_a2,
DROP COLUMN IF EXISTS in_hospital_cd_b1,
DROP COLUMN IF EXISTS in_hospital_cd_b2;


-- 列の追加
ALTER TABLE mst_procedure
ADD COLUMN IF NOT EXISTS in_hosp_a_startdate TIMESTAMP(3),
ADD COLUMN IF NOT EXISTS in_hospital_cd_a1 character varying(20),
ADD COLUMN IF NOT EXISTS in_hospital_cd_a2 character varying(20),
ADD COLUMN IF NOT EXISTS in_hosp_b_startdate TIMESTAMP(3),
ADD COLUMN IF NOT EXISTS in_hospital_cd_b1 character varying(20),
ADD COLUMN IF NOT EXISTS in_hospital_cd_b2 character varying(20);


-- コメント修正
COMMENT ON COLUMN "mst_procedure"."in_hosp_a_startdate" IS E'利用開始日A';
COMMENT ON COLUMN "mst_procedure"."in_hospital_cd_a1" IS E'院内コードA1';
COMMENT ON COLUMN "mst_procedure"."in_hospital_cd_a2" IS E'院内コードA2';
COMMENT ON COLUMN "mst_procedure"."in_hosp_b_startdate" IS E'利用開始日B';
COMMENT ON COLUMN "mst_procedure"."in_hospital_cd_b1" IS E'院内コードB1';
COMMENT ON COLUMN "mst_procedure"."in_hospital_cd_b2" IS E'院内コードB2';

