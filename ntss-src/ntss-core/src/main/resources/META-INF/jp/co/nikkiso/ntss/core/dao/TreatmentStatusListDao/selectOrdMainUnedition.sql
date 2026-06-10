select
  A.facility_cd, A.facility_name, A.ord_no, A.pat_id, A.treat_date,
  A.ind_kur_cd, A.ind_kur_name, A.rst_kur_cd, A.rst_kur_name,
  A.ind_bed_cd, A.ind_bed_name, A.rst_bed_cd, A.rst_bed_name, A.rst_machine_no,
  A.rst_start_date, A.rst_end_date, A.rst_charge_user_info, A.rst_puncture_user_info,
  A.rst_return_user_info, A.rst_weight_info,
--   add 10196 by kangjie 20240130 start del
--   A.rst_vital_info,
--   add 10196 by kangjie 20240130 end del
  A.fn_pat_id, A.treat_week,
  A.ind_va_cd, A.ind_treatment_cd, A.ind_treatment_name, A.ind_treat_start_time,
  A.ind_schedule_user_info, A.ind_cond_info, A.ind_medi_info, A.ind_equip_info,
  A.ind_ind_comment_info, A.ind_tare_info, A.ind_off_water_info, A.ind_device_set_info,
  A.rst_fn_dialysis_no, A.rst_relation_dialysis_no, A.rst_edition, A.rst_is_update_edition,
  A.rst_input_class, A.rst_dialysis_state, A.rst_treatment_cd, A.rst_treatment_name,
  A.rst_machine_name, A.rst_cond_send_date, A.rst_accept_date, A.rst_return_home_date,
  A.rst_in_out_class, A.rst_dialysis_cnt, A.rst_ward_cd, A.rst_ward_name, A.rst_course_cd,
  A.rst_course_name, A.rst_blood_circulate_total, A.rst_running_time, A.rst_kt_v,
  A.rec_set_date, A.send_ctl_no, A.blood_purifier_name, A.pull_leave_amount,
  A.rst_cond_info, A.rst_medi_info, A.rst_equip_info, A.rst_ind_comment_info,
  A.rst_tare_info, A.rst_off_water_info,
--   add 10196 by kangjie 20240130 start del
--   A.rst_device_set_info,
--   add 10196 by kangjie 20240130 end del
  A.rst_complaint_info,
  A.rst_treatment_info, A.rst_treat_staff_info, A.rst_rounds_info, A.is_del, A.rst_dw, A.ind_dw, A.weight_scale_no,
  0 as machine_entry,

  A.rst_puncture_user_info ->> 'user_id_1' as rst_puncture_user_id_a,
  A.rst_puncture_user_info ->> 'user_id_2' as rst_puncture_user_id_b,
  A.rst_puncture_user_info ->> 'date_1' as rst_puncture_date_a,
  A.rst_puncture_user_info ->> 'date_2' as rst_puncture_date_b,
  A.rst_puncture_user_info ->> 'date' as rst_puncture_date,
  A.rst_return_user_info ->> 'user_id_1' as rst_return_user_id_a,
  A.rst_return_user_info ->> 'user_id_2' as rst_return_user_id_b,
  A.rst_return_user_info ->> 'date_1' as rst_return_date_A,
  A.rst_return_user_info ->> 'date_2' as rst_return_date_B,
  A.rst_return_user_info ->> 'date' as rst_return_date,
  A.rst_charge_user_info ->> 'user_id_1' as rst_charge_user_id_a,
  A.rst_charge_user_info ->> 'user_id_2' as rst_charge_user_id_b,
  A.rst_charge_user_info ->> 'date_1' as rst_charge_date_a,
  A.rst_charge_user_info ->> 'date_2' as rst_charge_date_b,
  B.va_name as ind_mst_va_name,
  C.treatment_name as ind_mst_treatment_name,
  D.kur_name as ind_mst_kur_name,
  E.bed_name as ind_mst_bed_name,
  F.device_mode as ind_treatment_device_mode,
  G.device_mode as rst_treatment_device_mode,
  H.is_content_changed_for_map as is_content_changed_for_map
from
  ord_main A
  left outer join mst_va B on (A.ind_va_cd = B.va_cd)
  left outer join mst_treatment C on (A.ind_treatment_cd = C.treatment_cd)
  left outer join mst_kur D on (A.ind_kur_cd = D.kur_cd)
  left outer join mst_bed E on (A.ind_bed_cd = E.bed_cd)
  left outer join mst_treatment F on (A.ind_treatment_cd = F.treatment_cd)
  left outer join mst_treatment G on (A.rst_treatment_cd = G.treatment_cd)
  left outer join pat_ind_approve H on (A.ord_no = H.ord_no)
where
  A.facility_cd = /*facilityCd*/'000000'
and
  A.rst_dialysis_state between '4' and '5'
and
  A.rst_edition = 0
and
  A.is_del = '0'
;
