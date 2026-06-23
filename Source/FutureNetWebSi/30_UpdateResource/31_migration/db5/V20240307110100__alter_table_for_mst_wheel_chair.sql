-- 列の削除
ALTER TABLE mst_wheel_chair
DROP COLUMN IF EXISTS in_hospital_cd_1,
DROP COLUMN IF EXISTS in_hospital_cd_2;

-- 列の追加
ALTER TABLE mst_wheel_chair
ADD COLUMN IF NOT EXISTS in_hospital_cd_1 character varying(20),
ADD COLUMN IF NOT EXISTS in_hospital_cd_2 character varying(20);

-- コメント修正
COMMENT ON COLUMN "mst_wheel_chair"."in_hospital_cd_1" IS E'連携コード1';
COMMENT ON COLUMN "mst_wheel_chair"."in_hospital_cd_2" IS E'連携コード2';
