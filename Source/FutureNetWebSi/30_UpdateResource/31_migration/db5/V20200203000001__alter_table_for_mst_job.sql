-- 列の追加
ALTER TABLE mst_job 
ADD COLUMN in_hospital_cd_1 character varying(20);

-- コメント修正
COMMENT ON COLUMN "mst_job"."in_hospital_cd_1" IS E'院内コード';