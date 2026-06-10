-- 列の追加
ALTER TABLE ntss.mst_equipment
ADD COLUMN in_hospital_cd_4 character varying(20);

-- コメント修正
COMMENT ON COLUMN "mst_equipment"."in_hospital_cd_4" IS E'院内コード4';
