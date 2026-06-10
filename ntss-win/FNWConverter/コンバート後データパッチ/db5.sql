--Å°AlterColumn _ DropColumn

--mst_job
ALTER TABLE mst_job DROP COLUMN fn_job_class_cd;

--ord_main
ALTER TABLE ord_main DROP COLUMN fn_plural;

--mst_machine
ALTER TABLE mst_machine DROP COLUMN fn_device_no;
--mst_disease
ALTER TABLE mst_disease DROP COLUMN is_die;

--mst_com_fixed_phrase
ALTER TABLE mst_com_fixed_phrase DROP COLUMN fn_addition_cd;

--mst_pat_event_category
ALTER TABLE mst_pat_event_category DROP COLUMN fn_event_category_cd_1;

--mst_pat_event_sub_category
ALTER TABLE mst_pat_event_sub_category DROP COLUMN fn_event_category_cd_2;

--mst_spitz
ALTER TABLE mst_spitz DROP COLUMN fn_exam_set_cd;

--mst_comp_treatment
ALTER TABLE mst_comp_treatment DROP COLUMN fn_comp_treatment_cd;

--mst_complaint
ALTER TABLE mst_complaint DROP COLUMN fn_complaint_cd;

--mst_water_survey_point
ALTER TABLE mst_water_survey_point DROP COLUMN fn_survey_point_cd;

--mst_water_survey_type
ALTER TABLE mst_water_survey_type DROP COLUMN fn_survey_type_cd;

ALTER TABLE pat_unique DROP COLUMN medical_care_info;
