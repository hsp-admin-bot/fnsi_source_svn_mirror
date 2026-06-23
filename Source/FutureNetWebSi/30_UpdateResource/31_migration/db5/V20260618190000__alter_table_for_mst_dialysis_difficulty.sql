--------------------------------------------------
-- 透析困難症
-- 院内コード3,4を追加
--------------------------------------------------
-- カラム追加
ALTER TABLE mst_dialysis_difficulty 
  ADD COLUMN in_hospital_cd_3 character varying(20),
  ADD COLUMN in_hospital_cd_4 character varying(20);

-- コメント追加
COMMENT ON COLUMN "mst_dialysis_difficulty"."in_hospital_cd_3" IS E'院内コード3';
COMMENT ON COLUMN "mst_dialysis_difficulty"."in_hospital_cd_4" IS E'院内コード4';
