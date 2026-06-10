alter table pat_exam_main drop constraint "unq_pat_exam_main_02";
alter table mst_room_bed_group drop constraint "unq_mst_room_bed_group_02";
alter table ord_main drop constraint "unq_ord_main_02";
alter table mst_self_measure_result drop constraint "unq_mst_self_measure_result_02";
alter table ord_coop_no drop constraint "unq_ord_coop_no_02";
alter table ord_personal_prescription drop constraint "unq_ord_personal_prescription_02";
alter table mnt_water_survey drop constraint "unq_mnt_water_survey_02";
alter table mnt_water_survey drop constraint "unq_bbs_info_02";

ALTER TABLE mst_monitor_graph DROP CONSTRAINT mst_monitor_graph_facility_cd_fkey;




