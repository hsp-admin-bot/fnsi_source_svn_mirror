-- ============================================================
-- bbs_info
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."bbs_info" DROP CONSTRAINT IF EXISTS "unq_bbs_info_01";

-- ----------------------------
-- 2. bbs_ctl_no のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."bbs_info" ALTER COLUMN "bbs_ctl_no" DROP DEFAULT;
ALTER TABLE "ntss"."bbs_info" ALTER COLUMN "bbs_ctl_no" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."bbs_info_bbs_ctl_no_seq";

-- ============================================================
-- mni_monitor
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mni_monitor" DROP CONSTRAINT IF EXISTS "unq_mni_monitor_01";

-- ----------------------------
-- 2. bio_moni_ctl_no のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mni_monitor" ALTER COLUMN "bio_moni_ctl_no" DROP DEFAULT;
ALTER TABLE "ntss"."mni_monitor" ALTER COLUMN "bio_moni_ctl_no" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mni_monitor_bio_moni_ctl_no_seq";

-- ============================================================
-- mnt_mainte_main
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mnt_mainte_main" DROP CONSTRAINT IF EXISTS "unq_mainte_main_01";

-- ----------------------------
-- 2. mainte_no のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mnt_mainte_main" ALTER COLUMN "mainte_no" DROP DEFAULT;
ALTER TABLE "ntss"."mnt_mainte_main" ALTER COLUMN "mainte_no" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mnt_mainte_main_mainte_no_seq";

-- ============================================================
-- mnt_motion_record
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mnt_motion_record" DROP CONSTRAINT IF EXISTS "unq_mnt_motion_record_01";

-- ----------------------------
-- 2. motion_record_no のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mnt_motion_record" ALTER COLUMN "motion_record_no" DROP DEFAULT;
ALTER TABLE "ntss"."mnt_motion_record" ALTER COLUMN "motion_record_no" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mnt_motion_record_motion_record_no_seq";

-- ============================================================
-- mnt_water_survey
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mnt_water_survey" DROP CONSTRAINT IF EXISTS "unq_mnt_water_survey_01";

-- ----------------------------
-- 2. survey_record_no のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mnt_water_survey" ALTER COLUMN "survey_record_no" DROP DEFAULT;
ALTER TABLE "ntss"."mnt_water_survey" ALTER COLUMN "survey_record_no" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mnt_water_survey_survey_record_no_seq";

-- ============================================================
-- mst_add_monitor
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_add_monitor" DROP CONSTRAINT IF EXISTS "unq_mst_add_monitor_01";

-- ----------------------------
-- 2. vital_monitor_item_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_add_monitor" ALTER COLUMN "vital_monitor_item_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_add_monitor" ALTER COLUMN "vital_monitor_item_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_add_monitor_vital_monitor_item_cd_seq";

-- ============================================================
-- mst_addition
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_addition" DROP CONSTRAINT IF EXISTS "unq_mst_addition_01";

-- ----------------------------
-- 2. addition_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_addition" ALTER COLUMN "addition_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_addition" ALTER COLUMN "addition_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_addition_addition_cd_seq";

-- ============================================================
-- mst_bbs_kind
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_bbs_kind" DROP CONSTRAINT IF EXISTS "unq_mst_bbs_kind_01";

-- ----------------------------
-- 2. kind_no のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_bbs_kind" ALTER COLUMN "kind_no" DROP DEFAULT;
ALTER TABLE "ntss"."mst_bbs_kind" ALTER COLUMN "kind_no" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_bbs_kind_kind_no_seq";

-- ============================================================
-- mst_bed
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_bed" DROP CONSTRAINT IF EXISTS "unq_mst_bed_01";

-- ----------------------------
-- 2. bed_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_bed" ALTER COLUMN "bed_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_bed" ALTER COLUMN "bed_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_bed_bed_cd_seq";

-- ============================================================
-- mst_checklist
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_checklist" DROP CONSTRAINT IF EXISTS "unq_mst_checklist_01";

-- ----------------------------
-- 2. checklist_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_checklist" ALTER COLUMN "checklist_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_checklist" ALTER COLUMN "checklist_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_checklist_checklist_cd_seq";

-- ============================================================
-- mst_com_fixed_phrase
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_com_fixed_phrase" DROP CONSTRAINT IF EXISTS "unq_mst_com_fixed_phrase_01";

-- ----------------------------
-- 2. com_fixed_phrase_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_com_fixed_phrase" ALTER COLUMN "com_fixed_phrase_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_com_fixed_phrase" ALTER COLUMN "com_fixed_phrase_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_com_fixed_phrase_com_fixed_phrase_cd_seq";

-- ============================================================
-- mst_comp_treatment
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_comp_treatment" DROP CONSTRAINT IF EXISTS "unq_mst_comp_treatment_01";

-- ----------------------------
-- 2. comp_treatment_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_comp_treatment" ALTER COLUMN "comp_treatment_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_comp_treatment" ALTER COLUMN "comp_treatment_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_comp_treatment_comp_treatment_cd_seq";

-- ============================================================
-- mst_complaint
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_complaint" DROP CONSTRAINT IF EXISTS "unq_mst_complaint_01";

-- ----------------------------
-- 2. complaint_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_complaint" ALTER COLUMN "complaint_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_complaint" ALTER COLUMN "complaint_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_complaint_complaint_cd_seq";

-- ============================================================
-- mst_comsv_setting
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_comsv_setting" DROP CONSTRAINT IF EXISTS "unq_mst_comsv_setting_01";

-- ----------------------------
-- 2. comsv_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_comsv_setting" ALTER COLUMN "comsv_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_comsv_setting" ALTER COLUMN "comsv_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_comsv_setting_comsv_cd_seq";

-- ============================================================
-- mst_course
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_course" DROP CONSTRAINT IF EXISTS "unq_mst_course_01";

-- ----------------------------
-- 2. course_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_course" ALTER COLUMN "course_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_course" ALTER COLUMN "course_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_course_course_cd_seq";

-- ============================================================
-- mst_dialysis_difficulty
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_dialysis_difficulty" DROP CONSTRAINT IF EXISTS "unq_mst_dialysis_difficulty_01";

-- ----------------------------
-- 2. dialysis_difficulty_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_dialysis_difficulty" ALTER COLUMN "dialysis_difficulty_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_dialysis_difficulty" ALTER COLUMN "dialysis_difficulty_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_dialysis_difficulty_dialysis_difficulty_cd_seq";

-- ============================================================
-- mst_dialyzer
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_dialyzer" DROP CONSTRAINT IF EXISTS "unq_mst_dialyzer_01";

-- ----------------------------
-- 2. dialyzer_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_dialyzer" ALTER COLUMN "dialyzer_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_dialyzer" ALTER COLUMN "dialyzer_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_dialyzer_dialyzer_cd_seq";

-- ============================================================
-- mst_disease
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_disease" DROP CONSTRAINT IF EXISTS "unq_mst_disease_01";

-- ----------------------------
-- 2. disease_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_disease" ALTER COLUMN "disease_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_disease" ALTER COLUMN "disease_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_disease_disease_cd_seq";

-- ============================================================
-- mst_equipment
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_equipment" DROP CONSTRAINT IF EXISTS "unq_mst_equipment_01";

-- ----------------------------
-- 2. equipment_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_equipment" ALTER COLUMN "equipment_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_equipment" ALTER COLUMN "equipment_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_equipment_equipment_cd_seq";

-- ============================================================
-- mst_equipment_class
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_equipment_class" DROP CONSTRAINT IF EXISTS "unq_mst_equipment_class_01";

-- ----------------------------
-- 2. class_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_equipment_class" ALTER COLUMN "class_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_equipment_class" ALTER COLUMN "class_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_equipment_class_class_cd_seq";

-- ============================================================
-- mst_exam_item
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_exam_item" DROP CONSTRAINT IF EXISTS "unq_mst_exam_item_01";

-- ----------------------------
-- 2. exam_item_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_exam_item" ALTER COLUMN "exam_item_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_exam_item" ALTER COLUMN "exam_item_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_exam_item_exam_item_cd_seq";

-- ============================================================
-- mst_exam_set
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_exam_set" DROP CONSTRAINT IF EXISTS "unq_mst_exam_set_01";

-- ----------------------------
-- 2. exam_set_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_exam_set" ALTER COLUMN "exam_set_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_exam_set" ALTER COLUMN "exam_set_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_exam_set_exam_set_cd_seq";

-- ============================================================
-- mst_favorite_facility
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_favorite_facility" DROP CONSTRAINT IF EXISTS "unq_mst_favorite_facility_01";

-- ----------------------------
-- 2. master_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_favorite_facility" ALTER COLUMN "master_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_favorite_facility" ALTER COLUMN "master_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_favorite_facility_master_cd_seq";

-- ============================================================
-- mst_holiday
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_holiday" DROP CONSTRAINT IF EXISTS "mst_holiday_pkey";

-- ----------------------------
-- 2. holiday_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_holiday" ALTER COLUMN "holiday_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_holiday" ALTER COLUMN "holiday_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_holiday_holiday_cd_seq";

-- ============================================================
-- mst_infection
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_infection" DROP CONSTRAINT IF EXISTS "unq_mst_infection_01";

-- ----------------------------
-- 2. infection_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_infection" ALTER COLUMN "infection_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_infection" ALTER COLUMN "infection_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_infection_infection_cd_seq";

-- ============================================================
-- mst_job
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_job" DROP CONSTRAINT IF EXISTS "unq_mst_job_01";

-- ----------------------------
-- 2. job_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_job" ALTER COLUMN "job_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_job" ALTER COLUMN "job_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_job_job_cd_seq";

-- ============================================================
-- mst_kur
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_kur" DROP CONSTRAINT IF EXISTS "unq_mst_kur_01";

-- ----------------------------
-- 2. kur_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_kur" ALTER COLUMN "kur_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_kur" ALTER COLUMN "kur_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_kur_kur_cd_seq";

-- ============================================================
-- mst_machine
-- ============================================================
-- 1. mst_machine のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_machine" ALTER COLUMN "machine_no" DROP DEFAULT;
ALTER TABLE "ntss"."mst_machine" ALTER COLUMN "machine_no" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_machine_machine_no_seq";

-- ============================================================
-- mst_mainte_category
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_mainte_category" DROP CONSTRAINT IF EXISTS "unq_mst_mainte_category_01";

-- ----------------------------
-- 2. mainte_category_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_mainte_category" ALTER COLUMN "mainte_category_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_mainte_category" ALTER COLUMN "mainte_category_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_mainte_category_mainte_category_cd_seq";

-- ============================================================
-- mst_mainte_detail
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_mainte_detail" DROP CONSTRAINT IF EXISTS "unq_mst_mainte_detail_01";

-- ----------------------------
-- 2. mainte_detail_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_mainte_detail" ALTER COLUMN "mainte_detail_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_mainte_detail" ALTER COLUMN "mainte_detail_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_mainte_detail_mainte_detail_cd_seq";

-- ============================================================
-- mst_mainte_layout
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_mainte_layout" DROP CONSTRAINT IF EXISTS "unq_mst_mainte_layout_01";

-- ----------------------------
-- 2. mainte_layout_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_mainte_layout" ALTER COLUMN "mainte_layout_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_mainte_layout" ALTER COLUMN "mainte_layout_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_mainte_layout_mainte_layout_cd_seq";

-- ============================================================
-- mst_mainte_layout_group
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_mainte_layout_group" DROP CONSTRAINT IF EXISTS "unq_mst_mainte_layout_group_01";

-- ----------------------------
-- 2. mainte_layout_group_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_mainte_layout_group" ALTER COLUMN "mainte_layout_group_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_mainte_layout_group" ALTER COLUMN "mainte_layout_group_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_mainte_layout_group_mainte_layout_group_cd_seq";

-- ============================================================
-- mst_medicate_timing
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_medicate_timing" DROP CONSTRAINT IF EXISTS "unq_mst_medicate_timing_01";

-- ----------------------------
-- 2. medicate_timing_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_medicate_timing" ALTER COLUMN "medicate_timing_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_medicate_timing" ALTER COLUMN "medicate_timing_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_medicate_timing_medicate_timing_cd_seq";

-- ============================================================
-- mst_medicine
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_medicine" DROP CONSTRAINT IF EXISTS "unq_mst_medicine_01";

-- ----------------------------
-- 2. medicine_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_medicine" ALTER COLUMN "medicine_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_medicine" ALTER COLUMN "medicine_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_medicine_medicine_cd_seq";

-- ============================================================
-- mst_medicine_class
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_medicine_class" DROP CONSTRAINT IF EXISTS "unq_mst_medicine_class_01";

-- ----------------------------
-- 2. class_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_medicine_class" ALTER COLUMN "class_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_medicine_class" ALTER COLUMN "class_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_medicine_class_class_cd_seq";

-- ============================================================
-- mst_medicine_group
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_medicine_group" DROP CONSTRAINT IF EXISTS "unq_medicine_group_01";

-- ----------------------------
-- 2. medicine_group_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_medicine_group" ALTER COLUMN "medicine_group_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_medicine_group" ALTER COLUMN "medicine_group_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_medicine_group_medicine_group_cd_seq";

-- ============================================================
-- mst_medicine_mix
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_medicine_mix" DROP CONSTRAINT IF EXISTS "unq_mst_medicine_mix_01";

-- ----------------------------
-- 2. medicine_mix_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_medicine_mix" ALTER COLUMN "medicine_mix_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_medicine_mix" ALTER COLUMN "medicine_mix_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_medicine_mix_medicine_mix_cd_seq";

-- ============================================================
-- mst_medicine_support
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_medicine_support" DROP CONSTRAINT IF EXISTS "unq_medicine_support_01";

-- ----------------------------
-- 2. medicine_support_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_medicine_support" ALTER COLUMN "medicine_support_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_medicine_support" ALTER COLUMN "medicine_support_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_medicine_support_medicine_support_cd_seq";

-- ============================================================
-- mst_monitor_graph
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_monitor_graph" DROP CONSTRAINT IF EXISTS "unq_mst_monitor_graph_01";

-- ----------------------------
-- 2. monitor_graph_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_monitor_graph" ALTER COLUMN "monitor_graph_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_monitor_graph" ALTER COLUMN "monitor_graph_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_monitor_graph_monitor_graph_cd_seq";

-- ============================================================
-- mst_pat_calendar_layout
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_pat_calendar_layout" DROP CONSTRAINT IF EXISTS "unq_mst_pat_calendar_layout_01";

-- ----------------------------
-- 2. pat_calendar_layout_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_pat_calendar_layout" ALTER COLUMN "pat_calendar_layout_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_pat_calendar_layout" ALTER COLUMN "pat_calendar_layout_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_pat_calendar_layout_pat_calendar_layout_cd_seq";

-- ============================================================
-- mst_pat_event_category
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_pat_event_category" DROP CONSTRAINT IF EXISTS "unq_mst_pat_event_category_01";

-- ----------------------------
-- 2. category_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_pat_event_category" ALTER COLUMN "category_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_pat_event_category" ALTER COLUMN "category_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_pat_event_category_category_cd_seq";

-- ============================================================
-- mst_pat_event_data_template
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_pat_event_data_template" DROP CONSTRAINT IF EXISTS "unq_mst_pat_event_data_template_01";

-- ----------------------------
-- 2. template_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_pat_event_data_template" ALTER COLUMN "template_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_pat_event_data_template" ALTER COLUMN "template_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_pat_event_data_template_template_cd_seq";

-- ============================================================
-- mst_pat_event_sub_category
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_pat_event_sub_category" DROP CONSTRAINT IF EXISTS "unq_mst_pat_event_sub_category_01";

-- ----------------------------
-- 2. sub_category_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_pat_event_sub_category" ALTER COLUMN "sub_category_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_pat_event_sub_category" ALTER COLUMN "sub_category_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_pat_event_sub_category_sub_category_cd_seq";

-- ============================================================
-- mst_pat_list_layout
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_pat_list_layout" DROP CONSTRAINT IF EXISTS "unq_mst_pat_list_layout_01";

-- ----------------------------
-- 2. pat_list_layout_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_pat_list_layout" ALTER COLUMN "pat_list_layout_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_pat_list_layout" ALTER COLUMN "pat_list_layout_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_pat_list_layout_pat_list_layout_cd_seq";

-- ============================================================
-- mst_pat_viewer_layout
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_pat_viewer_layout" DROP CONSTRAINT IF EXISTS "unq_mst_pat_viewer_layout_01";

-- ----------------------------
-- 2. layout_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_pat_viewer_layout" ALTER COLUMN "layout_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_pat_viewer_layout" ALTER COLUMN "layout_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_pat_viewer_layout_layout_cd_seq";

-- ============================================================
-- mst_procedure
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_procedure" DROP CONSTRAINT IF EXISTS "unq_mst_procedure_01";

-- ----------------------------
-- 2. procedure_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_procedure" ALTER COLUMN "procedure_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_procedure" ALTER COLUMN "procedure_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_procedure_procedure_cd_seq";

-- ============================================================
-- mst_rad_set
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_rad_set" DROP CONSTRAINT IF EXISTS "unq_mst_rad_set_01";

-- ----------------------------
-- 2. rad_set_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_rad_set" ALTER COLUMN "rad_set_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_rad_set" ALTER COLUMN "rad_set_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_rad_set_rad_set_cd_seq";

-- ============================================================
-- mst_room_bed_group
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_room_bed_group" DROP CONSTRAINT IF EXISTS "unq_mst_room_bed_group_01";

-- ----------------------------
-- 2. room_bed_group_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_room_bed_group" ALTER COLUMN "room_bed_group_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_room_bed_group" ALTER COLUMN "room_bed_group_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_room_bed_group_room_bed_group_cd_seq";

-- ============================================================
-- mst_self_measure_result
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_self_measure_result" DROP CONSTRAINT IF EXISTS "unq_mst_self_measure_result_01";

-- ----------------------------
-- 2. self_measure_result_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_self_measure_result" ALTER COLUMN "self_measure_result_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_self_measure_result" ALTER COLUMN "self_measure_result_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_self_measure_result_self_measure_result_cd_seq";

-- ============================================================
-- mst_severity
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_severity" DROP CONSTRAINT IF EXISTS "unq_mst_severity_01";

-- ----------------------------
-- 2. severity_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_severity" ALTER COLUMN "severity_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_severity" ALTER COLUMN "severity_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_severity_severity_cd_seq";

-- ============================================================
-- mst_taboo_allergy
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_taboo_allergy" DROP CONSTRAINT IF EXISTS "unq_mst_taboo_allergy_01";

-- ----------------------------
-- 2. taboo_allergy_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_taboo_allergy" ALTER COLUMN "taboo_allergy_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_taboo_allergy" ALTER COLUMN "taboo_allergy_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_taboo_allergy_taboo_allergy_cd_seq";

-- ============================================================
-- mst_take_medicine
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_take_medicine" DROP CONSTRAINT IF EXISTS "unq_mst_take_medicine_01";

-- ----------------------------
-- 2. take_medicine_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_take_medicine" ALTER COLUMN "take_medicine_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_take_medicine" ALTER COLUMN "take_medicine_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_take_medicine_take_medicine_cd_seq";

-- ============================================================
-- mst_transport
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_transport" DROP CONSTRAINT IF EXISTS "unq_mst_transport_01";

-- ----------------------------
-- 2. transport_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_transport" ALTER COLUMN "transport_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_transport" ALTER COLUMN "transport_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_transport_transport_cd_seq";

-- ============================================================
-- mst_treatment
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_treatment" DROP CONSTRAINT IF EXISTS "unq_mst_treatment_01";

-- ----------------------------
-- 2. treatment_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_treatment" ALTER COLUMN "treatment_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_treatment" ALTER COLUMN "treatment_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_treatment_treatment_cd_seq";

-- ============================================================
-- mst_treatment_set
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_treatment_set" DROP CONSTRAINT IF EXISTS "unq_mst_treatment_set_01";

-- ----------------------------
-- 2. treatment_set_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_treatment_set" ALTER COLUMN "treatment_set_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_treatment_set" ALTER COLUMN "treatment_set_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_treatment_set_treatment_set_cd_seq";

-- ============================================================
-- mst_treatment_status_layout
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_treatment_status_layout" DROP CONSTRAINT IF EXISTS "unq_mst_treatment_status_layout_01";

-- ----------------------------
-- 2. layout_no のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_treatment_status_layout" ALTER COLUMN "layout_no" DROP DEFAULT;
ALTER TABLE "ntss"."mst_treatment_status_layout" ALTER COLUMN "layout_no" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_treatment_status_layout_layout_no_seq";

-- ============================================================
-- mst_trend_graph_monitor_set
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_trend_graph_monitor_set" DROP CONSTRAINT IF EXISTS "unq_mst_trend_graph_monitor_set_01";

-- ----------------------------
-- 2. monitor_set_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_trend_graph_monitor_set" ALTER COLUMN "monitor_set_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_trend_graph_monitor_set" ALTER COLUMN "monitor_set_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_trend_graph_monitor_set_monitor_set_cd_seq";

-- ============================================================
-- mst_trend_graph_template
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_trend_graph_template" DROP CONSTRAINT IF EXISTS "unq_mst_trend_graph_template_01";

-- ----------------------------
-- 2. template_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_trend_graph_template" ALTER COLUMN "template_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_trend_graph_template" ALTER COLUMN "template_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_trend_graph_template_template_cd_seq";

-- ============================================================
-- mst_va
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_va" DROP CONSTRAINT IF EXISTS "unq_mst_va_01";

-- ----------------------------
-- 2. va_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_va" ALTER COLUMN "va_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_va" ALTER COLUMN "va_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_va_va_cd_seq";

-- ============================================================
-- mst_vital_graph
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_vital_graph" DROP CONSTRAINT IF EXISTS "unq_mst_vital_graph_01";

-- ----------------------------
-- 2. vital_graph_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_vital_graph" ALTER COLUMN "vital_graph_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_vital_graph" ALTER COLUMN "vital_graph_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_vital_graph_vital_graph_cd_seq";

-- ============================================================
-- mst_ward
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_ward" DROP CONSTRAINT IF EXISTS "unq_mst_ward_01";

-- ----------------------------
-- 2. ward_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_ward" ALTER COLUMN "ward_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_ward" ALTER COLUMN "ward_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_ward_ward_cd_seq";

-- ============================================================
-- mst_water_survey_point
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_water_survey_point" DROP CONSTRAINT IF EXISTS "unq_mst_water_survey_point_01";

-- ----------------------------
-- 2. survey_point_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_water_survey_point" ALTER COLUMN "survey_point_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_water_survey_point" ALTER COLUMN "survey_point_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_water_survey_point_survey_point_cd_seq";

-- ============================================================
-- mst_water_survey_type
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_water_survey_type" DROP CONSTRAINT IF EXISTS "unq_mst_water_survey_type_01";

-- ----------------------------
-- 2. survey_type_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_water_survey_type" ALTER COLUMN "survey_type_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_water_survey_type" ALTER COLUMN "survey_type_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_water_survey_type_survey_type_cd_seq";

-- ============================================================
-- mst_weight
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_weight" DROP CONSTRAINT IF EXISTS "unq_mst_weight_01";

-- ----------------------------
-- 2. weight_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_weight" ALTER COLUMN "weight_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_weight" ALTER COLUMN "weight_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_weight_weight_cd_seq";

-- ============================================================
-- mst_weight_scale
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_weight_scale" DROP CONSTRAINT IF EXISTS "unq_mst_weight_scale_01";

-- ----------------------------
-- 2. weight_scale_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_weight_scale" ALTER COLUMN "weight_scale_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_weight_scale" ALTER COLUMN "weight_scale_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_weight_scale_weight_scale_cd_seq";

-- ============================================================
-- mst_wheel_chair
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_wheel_chair" DROP CONSTRAINT IF EXISTS "unq_mst_wheel_chair_01";

-- ----------------------------
-- 2. wheel_chair_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_wheel_chair" ALTER COLUMN "wheel_chair_cd" DROP DEFAULT;
ALTER TABLE "ntss"."mst_wheel_chair" ALTER COLUMN "wheel_chair_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_wheel_chair_wheel_chair_cd_seq";

-- ============================================================
-- ord_checklist
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_checklist" DROP CONSTRAINT IF EXISTS "unq_ord_checklist_01";

-- ----------------------------
-- 2. checklist_ctl_no のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_checklist" ALTER COLUMN "checklist_ctl_no" DROP DEFAULT;
ALTER TABLE "ntss"."ord_checklist" ALTER COLUMN "checklist_ctl_no" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."ord_checklist_checklist_ctl_no_seq";

-- ============================================================
-- ord_coop_no
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_coop_no" DROP CONSTRAINT IF EXISTS "unq_ord_coop_no_01";

-- ----------------------------
-- 2. ctl_no のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_coop_no" ALTER COLUMN "ctl_no" DROP DEFAULT;
ALTER TABLE "ntss"."ord_coop_no" ALTER COLUMN "ctl_no" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."ord_coop_no_ctl_no_seq";

-- ============================================================
-- ord_exception_period
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_exception_period" DROP CONSTRAINT IF EXISTS "unq_ord_exception_period_01";

-- ----------------------------
-- 2. exception_period_no のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_exception_period" ALTER COLUMN "exception_period_no" DROP DEFAULT;
ALTER TABLE "ntss"."ord_exception_period" ALTER COLUMN "exception_period_no" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."ord_exception_period_exception_period_no_seq";

-- ============================================================
-- ord_main
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_main" DROP CONSTRAINT IF EXISTS "unq_ord_main_01";

-- ----------------------------
-- 2. ord_no のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_main" ALTER COLUMN "ord_no" DROP DEFAULT;
ALTER TABLE "ntss"."ord_main" ALTER COLUMN "ord_no" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."ord_main_ord_no_seq";

-- ============================================================
-- ord_material_save
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_material_save" DROP CONSTRAINT IF EXISTS "pk_ord_material_save_01";

-- ----------------------------
-- 2. ord_material_save_no のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_material_save" ALTER COLUMN "ord_material_save_no" DROP DEFAULT;
ALTER TABLE "ntss"."ord_material_save" ALTER COLUMN "ord_material_save_no" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."ord_material_save_seq";

-- ============================================================
-- ord_prescription
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_prescription" DROP CONSTRAINT IF EXISTS "unq_ord_prescription_01";

-- ----------------------------
-- 2. ord_prescription_no のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_prescription" ALTER COLUMN "ord_prescription_no" DROP DEFAULT;
ALTER TABLE "ntss"."ord_prescription" ALTER COLUMN "ord_prescription_no" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."ord_prescription_ord_prescription_no_seq";

-- ============================================================
-- ord_treat_condition
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_treat_condition" DROP CONSTRAINT IF EXISTS "unq_ord_treat_condition_01";

-- ----------------------------
-- 2. condition_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_treat_condition" ALTER COLUMN "condition_cd" DROP DEFAULT;
ALTER TABLE "ntss"."ord_treat_condition" ALTER COLUMN "condition_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."ord_treat_condition_condition_cd_seq";

-- ============================================================
-- ord_weight_scale
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_weight_scale" DROP CONSTRAINT IF EXISTS "unq_ord_weight_scale_01";

-- ----------------------------
-- 2. weight_scale_no のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."ord_weight_scale" ALTER COLUMN "weight_scale_no" DROP DEFAULT;
ALTER TABLE "ntss"."ord_weight_scale" ALTER COLUMN "weight_scale_no" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."ord_weight_scale_weight_scale_no_seq";

-- ============================================================
-- pat_coop_detail
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."pat_coop_detail" DROP CONSTRAINT IF EXISTS "unq_pat_coop_detail_01";

-- ----------------------------
-- 2. coop_save_no のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."pat_coop_detail" ALTER COLUMN "coop_save_no" DROP DEFAULT;
ALTER TABLE "ntss"."pat_coop_detail" ALTER COLUMN "coop_save_no" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."pat_coop_detail_coop_save_no_seq";

-- ============================================================
-- pat_event
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."pat_event" DROP CONSTRAINT IF EXISTS "unq_pat_event_01";

-- ----------------------------
-- 2. pat_event_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."pat_event" ALTER COLUMN "pat_event_cd" DROP DEFAULT;
ALTER TABLE "ntss"."pat_event" ALTER COLUMN "pat_event_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."pat_event_pat_event_cd_seq";

-- ============================================================
-- pat_exam_main
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."pat_exam_main" DROP CONSTRAINT IF EXISTS "unq_pat_exam_main_01";

-- ----------------------------
-- 2. exam_main_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."pat_exam_main" ALTER COLUMN "exam_main_cd" DROP DEFAULT;
ALTER TABLE "ntss"."pat_exam_main" ALTER COLUMN "exam_main_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."pat_exam_main_exam_main_cd_seq";

-- ============================================================
-- pat_group  (主キー制約なし; シーケンスあり)
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約なし、スキップ
-- ----------------------------

-- ----------------------------
-- 2. pat_group_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."pat_group" ALTER COLUMN "pat_group_cd" DROP DEFAULT;
ALTER TABLE "ntss"."pat_group" ALTER COLUMN "pat_group_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."pat_group_pat_group_cd_seq";

-- ============================================================
-- pat_ind_approve_history
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."pat_ind_approve_history" DROP CONSTRAINT IF EXISTS "pat_ind_approve_history_pkey";

-- ----------------------------
-- 2. ind_approve_history_no のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."pat_ind_approve_history" ALTER COLUMN "ind_approve_history_no" DROP DEFAULT;
ALTER TABLE "ntss"."pat_ind_approve_history" ALTER COLUMN "ind_approve_history_no" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."pat_ind_approve_history_ind_approve_history_no_seq";

-- ============================================================
-- pat_rad_main
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."pat_rad_main" DROP CONSTRAINT IF EXISTS "unq_pat_rad_main_01";

-- ----------------------------
-- 2. rad_result_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."pat_rad_main" ALTER COLUMN "rad_result_cd" DROP DEFAULT;
ALTER TABLE "ntss"."pat_rad_main" ALTER COLUMN "rad_result_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."pat_rad_main_rad_result_cd_seq";

-- ============================================================
-- mst_personal_user
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_personal_user" DROP CONSTRAINT IF EXISTS "unq_mst_personal_user_01";

-- ----------------------------
-- 2. user_id のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."mst_personal_user" ALTER COLUMN "user_id" DROP DEFAULT;
ALTER TABLE "ntss"."mst_personal_user" ALTER COLUMN "user_id" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."mst_personal_user_user_id_seq";

-- ============================================================
-- pat_insurance
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."pat_insurance" DROP CONSTRAINT IF EXISTS "unq_insurance_01";

-- ----------------------------
-- 2. insurance_cd のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."pat_insurance" ALTER COLUMN "insurance_cd" DROP DEFAULT;
ALTER TABLE "ntss"."pat_insurance" ALTER COLUMN "insurance_cd" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."pat_insurance_insurance_cd_seq";

-- ============================================================
-- pat_personal_main
-- ============================================================
-- ----------------------------
-- 1. 既存の主キー制約を削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."pat_personal_main" DROP CONSTRAINT IF EXISTS "unq_pat_personal_main_01";

-- ----------------------------
-- 2. pat_id のデフォルト値（seq参照）・NOT NULL制約を削除し、シーケンスを削除（冪等）
-- ----------------------------
ALTER TABLE "ntss"."pat_personal_main" ALTER COLUMN "pat_id" DROP DEFAULT;
ALTER TABLE "ntss"."pat_personal_main" ALTER COLUMN "pat_id" DROP NOT NULL;
DROP SEQUENCE IF EXISTS "ntss"."pat_personal_main_pat_id_seq";
