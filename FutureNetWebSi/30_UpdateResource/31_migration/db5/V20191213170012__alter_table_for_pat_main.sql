-- 患者基本情報
-- 項目追加
ALTER TABLE pat_main ADD COLUMN medical_care_info jsonb DEFAULT E'{"main_course_cd":null, "dialysis_course_cd":null, "ward_cd":null, "dialysis_count":null, "purification_count":null, "other_dialysis_count":null, "facility_cd":null, "dialysis_start_date":null, "hospital_start_date":null}';  --共通診療情報
-- コメント追加
COMMENT ON COLUMN "pat_main"."medical_care_info" IS E'共通診療情報';
