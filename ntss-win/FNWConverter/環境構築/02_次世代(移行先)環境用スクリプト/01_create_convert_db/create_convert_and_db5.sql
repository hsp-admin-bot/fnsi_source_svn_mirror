UPDATE "ntss"."sys_master_define" SET  "combo_data" = '{"combos": [{"values": [{"text": "’†‹ó…", "value": "0"}, {"text": "Ï‘w", "value": "1"}], "physical_name": "dialyzer_type"}, {"values": [{"text": "‚v‚d‚s", "value": "1"}, {"text": "‚c‚q‚x", "value": "2"}, {"text": "•s–¾", "value": "0"}], "physical_name": "wetdry"}, {"values": [{"text": "g—p‚µ‚È‚¢", "value": "0"}, {"text": "g—p‚·‚é", "value": "1"}], "physical_name": "membrane_wash"}]}' WHERE "master_physical_name" = 'mst_dialyzer';

ALTER table mst_take_medicine ADD COLUMN fn_take_medicine_cd varchar(3) DEFAULT null;

alter table pat_exam_main drop constraint "unq_pat_exam_main_02";

alter table mst_room_bed_group drop constraint "unq_mst_room_bed_group_02";

alter table ord_main drop constraint "unq_ord_main_02";



alter table mst_room_bed_group drop constraint "unq_mst_room_bed_group_02";
alter table mst_self_measure_result drop constraint "unq_mst_self_measure_result_02";



