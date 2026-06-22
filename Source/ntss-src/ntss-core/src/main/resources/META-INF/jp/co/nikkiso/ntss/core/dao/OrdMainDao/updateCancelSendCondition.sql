update ord_main
set
  -- add #9586 患者情報画面/新規患者登録の表示が遅い。 2023-09-20 by liumx --start
  rst_input_class = null,
  -- add #9586 患者情報画面/新規患者登録の表示が遅い。 2023-09-20 by liumx --end
  rst_dialysis_state = '0',
  rst_cond_send_date = null,
  rst_treatment_cd = null,
  rst_treatment_name = null,
  rst_kur_cd = null,
  rst_kur_name = null,
  rst_bed_cd = null,
  rst_bed_name = null,
  rst_machine_no = null,
  rst_machine_name = null,
  rst_accept_date = null,
  rst_start_date = null,
  rst_end_date = null,
  rst_return_home_date = null,
  rst_in_out_class = null,
  rst_dialysis_cnt = null,
  rst_ward_cd = null,
  rst_ward_name = null,
  rst_course_cd = null,
  rst_course_name = null,
  rst_dw = null,
  rst_puncture_user_info = null,
  rst_return_user_info = null,
  rst_charge_user_info = null,
  rst_blood_circulate_total = null,
  rst_running_time = null,
  rst_kt_v = null,
  rec_set_date = null,
  send_ctl_no = null,
  blood_purifier_name = null,
  pull_leave_amount = null,
  rst_cond_info = null,
  rst_medi_info = null,
  rst_equip_info = null,
  rst_ind_comment_info = null,
  rst_tare_info = null,
  rst_off_water_info = null,
--   add 10196 by kangjie 20240130 start del
--   rst_device_set_info = null,
--   add 10196 by kangjie 20240130 end del
  weight_scale_no = null,
  rst_weight_info = null,
--   add 10196 by kangjie 20240130 start del
--   rst_vital_info = null,
--   add 10196 by kangjie 20240130 end del
  rst_complaint_info = null,
  rst_treatment_info = null,
  rst_treat_staff_info = null,
  rst_rounds_info = null,
  ind_dw = null,
  --add #10443 身体情報・DW・目標体重バグ全体見直し対応 朴 start
  ind_dw_user_info = null,
  --add #10443 身体情報・DW・目標体重バグ全体見直し対応 朴 end
  up_date = /*upDate*/null,
  rst_purification_cnt = null
-- modify by chamaojia 2024-01-26 [10196] Add modified content  --start
  , ind_treatment_name = null
  , ind_kur_name = null
  , ind_bed_name = null
  , ind_device_mode = null
  , addition_info = null
/*%if ordMain.indMediInfo != null */
  , ind_medi_info = /*ordMain.indMediInfo*/null
/*%end*/
/*%if ordMain.indEquipInfo != null */
  , ind_equip_info = /*ordMain.indEquipInfo*/null
/*%end*/
/*%if ordMain.indCondInfo != null */
  , ind_cond_info = /*ordMain.indCondInfo*/null
/*%end*/
  -- modify by chamaojia 2025-01-16 [11467] add and modify content --start
  , is_confirm = '0'
  , rst_edition_date = null
  , cur_edition_date = null
  , bvms_path = null
  , rst_device_mode = null
  -- modify by chamaojia 2025-01-16 [11467] add and modify content --end
where
  ord_no = /*ordMain.ordNo*/0
-- modify by chamaojia 2024-01-26 [10196] Add modified content  --end
;
