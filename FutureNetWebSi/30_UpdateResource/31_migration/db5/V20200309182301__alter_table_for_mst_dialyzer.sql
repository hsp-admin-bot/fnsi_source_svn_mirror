-- 列の削除
ALTER TABLE mst_dialyzer
DROP COLUMN IF EXISTS in_hospital_cd_4;

-- 列の追加
ALTER TABLE mst_dialyzer 
ADD COLUMN IF NOT EXISTS in_hospital_cd_4 character varying(20);

-- コメント修正
COMMENT ON COLUMN "mst_dialyzer"."in_hospital_cd_4" IS E'院内コード4';