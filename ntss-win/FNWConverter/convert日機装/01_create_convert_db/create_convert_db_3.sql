--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--
COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';

-- CONSTRAINT
ALTER TABLE ntss.mst_addition ADD CONSTRAINT unq_mst_addition_02 UNIQUE(fn_add_cd,facility_cd);
ALTER TABLE ntss.mst_bbs_kind ADD CONSTRAINT unq_mst_bbs_kind_02 UNIQUE(fn_category_id,facility_cd);
ALTER TABLE ntss.mst_bed ADD CONSTRAINT unq_mst_bed_02 UNIQUE(fn_bed_no,facility_cd);
ALTER TABLE ntss.mst_com_fixed_phrase ADD CONSTRAINT unq_mst_com_fixed_phrase_02 UNIQUE(fn_addition_cd,facility_cd);
ALTER TABLE ntss.mst_disease ADD CONSTRAINT unq_mst_disease_02 UNIQUE(fn_disease_cd,facility_cd);
ALTER TABLE ntss.mst_dialysis_difficulty ADD CONSTRAINT unq_mst_dialysis_difficulty_02 UNIQUE(fn_dialysis_difficulty_cd,facility_cd);
ALTER TABLE ntss.mst_severity ADD CONSTRAINT unq_mst_severity_02 UNIQUE(fn_severity_cd,facility_cd);
ALTER TABLE ntss.mst_transport ADD CONSTRAINT unq_mst_transport_02 UNIQUE(fn_transport_cd,facility_cd);
ALTER TABLE ntss.mst_course ADD CONSTRAINT unq_mst_course_02 UNIQUE(fn_course_cd,facility_cd);
ALTER TABLE ntss.mst_ward ADD CONSTRAINT unq_mst_ward_02 UNIQUE(fn_ward_cd,facility_cd);
ALTER TABLE ntss.mst_medicine_class ADD CONSTRAINT unq_mst_medicine_class_02 UNIQUE(fn_class_cd,facility_cd);
ALTER TABLE ntss.mst_medicine_mix ADD CONSTRAINT unq_mst_medicine_mix_02 UNIQUE(fn_set_medicine_cd,facility_cd);
ALTER TABLE ntss.mst_equipment_class ADD CONSTRAINT unq_mst_equipment_class_02 UNIQUE(fn_class_cd,facility_cd);
ALTER TABLE ntss.mst_equipment ADD CONSTRAINT unq_mst_equipment_02 UNIQUE(fn_equipment_cd,facility_cd);
ALTER TABLE ntss.mst_dialyzer ADD CONSTRAINT unq_mst_dialyzer_02 UNIQUE(fn_dialyzer_cd,facility_cd);
ALTER TABLE ntss.mst_taboo_allergy ADD CONSTRAINT unq_mst_taboo_allergy_02 UNIQUE(fn_taboo_allergy_cd,facility_cd);
ALTER TABLE ntss.mst_infection ADD CONSTRAINT unq_mst_infection_02 UNIQUE(fn_infection_cd,facility_cd);
ALTER TABLE ntss.mst_treatment ADD CONSTRAINT unq_mst_treatment_02 UNIQUE(fn_treatment_cd,facility_cd);
ALTER TABLE ntss.mst_va ADD CONSTRAINT unq_mst_va_02 UNIQUE(fn_va_cd,facility_cd);
ALTER TABLE ntss.mst_procedure ADD CONSTRAINT unq_mst_procedure_02 UNIQUE(fn_procedure_cd,facility_cd);
ALTER TABLE ntss.mst_medicate_timing ADD CONSTRAINT unq_mst_medicate_timing_02 UNIQUE(fn_medicate_timing_cd,facility_cd);
ALTER TABLE ntss.mst_kur ADD CONSTRAINT unq_mst_kur_02 UNIQUE(fn_kur_cd,facility_cd);
ALTER TABLE ntss.mst_machine ADD CONSTRAINT unq_mst_machine_02 UNIQUE(fn_device_no,machine_type_cd,machine_serial,facility_cd);
ALTER TABLE ntss.mst_room_bed_group ADD CONSTRAINT unq_mst_room_bed_group_02 UNIQUE(fn_room_bed_group_no,facility_cd);
ALTER TABLE ntss.mst_job ADD CONSTRAINT unq_mst_job_02 UNIQUE(fn_job_class_cd,facility_cd);
ALTER TABLE ntss.mst_complaint ADD CONSTRAINT unq_mst_complaint_02 UNIQUE(fn_complaint_cd,facility_cd);
ALTER TABLE ntss.mst_comp_treatment ADD CONSTRAINT unq_mst_comp_treatment_02 UNIQUE(fn_comp_treatment_cd,facility_cd);
ALTER TABLE ntss.mst_water_survey_point ADD CONSTRAINT unq_mst_water_survey_point_02 UNIQUE(fn_survey_point_cd,facility_cd);
ALTER TABLE ntss.mst_water_survey_type ADD CONSTRAINT unq_mst_water_survey_type_02 UNIQUE(fn_survey_type_cd,facility_cd);
ALTER TABLE ntss.mst_personal_user ADD CONSTRAINT unq_mst_personal_user_02 UNIQUE(fn_staff_cd,facility_cd);
ALTER TABLE ntss.mst_wheel_chair ADD CONSTRAINT unq_mst_wheel_chair_02 UNIQUE(fn_wheel_chair_cd,facility_cd);
ALTER TABLE ntss.mst_exam_item ADD CONSTRAINT unq_mst_exam_item_02 UNIQUE(fn_exam_item_cd,facility_cd);
ALTER TABLE ntss.mst_exam_set ADD CONSTRAINT unq_mst_exam_set_02 UNIQUE(fn_exam_set_cd,facility_cd);
ALTER TABLE ntss.mst_rad_set ADD CONSTRAINT unq_mst_rad_set_02 UNIQUE(fn_exam_set_cd,facility_cd);
ALTER TABLE ntss.mst_spitz ADD CONSTRAINT unq_mst_spitz_02 UNIQUE(fn_exam_set_cd,facility_cd);
ALTER TABLE ntss.mst_pat_event_category ADD CONSTRAINT unq_mst_pat_event_category_02 UNIQUE(fn_event_category_cd_1,facility_cd);
ALTER TABLE ntss.mst_pat_event_sub_category ADD CONSTRAINT unq_mst_pat_event_sub_category_02 UNIQUE(fn_event_category_cd_2,facility_cd);
ALTER TABLE ntss.mst_obs_kind ADD CONSTRAINT unq_mst_obs_kind_02 UNIQUE(fn_kind_id,facility_cd);
ALTER TABLE ntss.mst_user ADD CONSTRAINT unq_mst_user_02 UNIQUE(pat_id,facility_cd);
ALTER TABLE ntss.mst_weight ADD CONSTRAINT unq_mst_weight_02 UNIQUE(weight_no,facility_cd);
ALTER TABLE ntss.ord_main ADD CONSTRAINT unq_ord_main_02 UNIQUE(rst_fn_dialysis_no,fn_pat_id,treat_date,fn_plural,facility_cd);
ALTER TABLE ntss.pat_personal_main ADD CONSTRAINT unq_pat_personal_main_02 UNIQUE(fn_pat_id,facility_cd);
ALTER TABLE ntss.bbs_info ADD CONSTRAINT unq_bbs_info_02 UNIQUE(fn_seq_id,facility_cd);
ALTER TABLE ntss.pat_obs_rec ADD CONSTRAINT unq_pat_obs_rec_02 UNIQUE(fn_seq_id,facility_cd);
ALTER TABLE ntss.pat_rad_main ADD CONSTRAINT unq_pat_rad_main_02 UNIQUE(fn_pat_id,reg_rad_date,facility_cd);
ALTER TABLE ntss.mst_treatment_status_layout ADD CONSTRAINT unq_mst_treatment_status_layout_02 UNIQUE(layout_name,facility_cd);
ALTER TABLE ntss.mst_treatment_set ADD CONSTRAINT unq_mst_treatment_set_02 UNIQUE(treatment_set_name,facility_cd);
ALTER TABLE ntss.mst_self_measure_result ADD CONSTRAINT unq_mst_self_measure_result_02 UNIQUE(facility_cd,disp_machine_name);
ALTER TABLE ntss.mst_monitor_graph ADD CONSTRAINT unq_mst_monitor_graph_02 UNIQUE(facility_cd,monitor_graph_name);
ALTER TABLE ntss.pat_ind_approve ADD CONSTRAINT unq_pat_ind_approve_02 UNIQUE(facility_cd,ord_no);