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
  A.machine_entry,

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
  -- 装置状態のord_noと一致する治療記録を取得
  (select
    ord_main.facility_cd, ord_main.facility_name, ord_main.ord_no, ord_main.pat_id, ord_main.treat_date,
    ord_main.ind_kur_cd, ord_main.ind_kur_name, ord_main.rst_kur_cd, ord_main.rst_kur_name,
    ord_main.ind_bed_cd, ord_main.ind_bed_name, ord_main.rst_bed_cd, ord_main.rst_bed_name, ord_main.rst_machine_no,
    ord_main.rst_start_date, ord_main.rst_end_date, ord_main.rst_charge_user_info, ord_main.rst_puncture_user_info,
    ord_main.rst_return_user_info, ord_main.rst_weight_info,
--   add 10196 by kangjie 20240130 start del
--     ord_main.rst_vital_info,
--   add 10196 by kangjie 20240130 end del
    ord_main.fn_pat_id, ord_main.treat_week,
    ord_main.ind_va_cd, ord_main.ind_treatment_cd, ord_main.ind_treatment_name, ord_main.ind_treat_start_time,
    ord_main.ind_schedule_user_info, ord_main.ind_cond_info, ord_main.ind_medi_info, ord_main.ind_equip_info,
    ord_main.ind_ind_comment_info, ord_main.ind_tare_info, ord_main.ind_off_water_info, ord_main.ind_device_set_info,
    ord_main.rst_fn_dialysis_no, ord_main.rst_relation_dialysis_no, ord_main.rst_edition, ord_main.rst_is_update_edition,
    ord_main.rst_input_class, ord_main.rst_dialysis_state, ord_main.rst_treatment_cd, ord_main.rst_treatment_name,
    ord_main.rst_machine_name, ord_main.rst_cond_send_date, ord_main.rst_accept_date, ord_main.rst_return_home_date,
    ord_main.rst_in_out_class, ord_main.rst_dialysis_cnt, ord_main.rst_ward_cd, ord_main.rst_ward_name, ord_main.rst_course_cd,
    ord_main.rst_course_name, ord_main.rst_blood_circulate_total, ord_main.rst_running_time, ord_main.rst_kt_v,
    ord_main.rec_set_date, ord_main.send_ctl_no, ord_main.blood_purifier_name, ord_main.pull_leave_amount,
    ord_main.rst_cond_info, ord_main.rst_medi_info, ord_main.rst_equip_info, ord_main.rst_ind_comment_info,
    ord_main.rst_tare_info, ord_main.rst_off_water_info,
--   add 10196 by kangjie 20240130 start del
--     ord_main.rst_device_set_info,
--   add 10196 by kangjie 20240130 end del
    ord_main.rst_complaint_info,

    ord_main.rst_treatment_info, ord_main.rst_treat_staff_info, ord_main.rst_rounds_info, ord_main.is_del, ord_main.rst_dw, ord_main.ind_dw, ord_main.weight_scale_no,
    2 as machine_entry
  from ord_main
    inner join
      -- 装置情報のord_noから治療中のord_no取得
      (select
        ord_no,
        next_ord_no
      from
        mnt_machine_state
      where
        facility_cd = /*facilityCd*/'999900'
      and
        -- ord_no の値があるもの
        (ord_no is not null)
      ) mnt_machine_state
    on (ord_main.ord_no = mnt_machine_state.ord_no)
  where
    -- 条件送信済み～透析中
    ord_main.rst_dialysis_state <= '3'
  or
    -- 前体重入力待ち、または版確定まちで次患者がいない場合
    (( ord_main.rst_dialysis_state = '4' or ord_main.rst_dialysis_state = '5' )
      and ( mnt_machine_state.ord_no = mnt_machine_state.next_ord_no or mnt_machine_state.next_ord_no is null))

  union
  -- 装置状態のnext_ord_noと一致する治療記録を取得
  select
    ord_main.facility_cd, ord_main.facility_name, ord_main.ord_no, ord_main.pat_id, ord_main.treat_date,
    ord_main.ind_kur_cd, ord_main.ind_kur_name, ord_main.rst_kur_cd, ord_main.rst_kur_name,
    ord_main.ind_bed_cd, ord_main.ind_bed_name, ord_main.rst_bed_cd, ord_main.rst_bed_name, ord_main.rst_machine_no,
    ord_main.rst_start_date, ord_main.rst_end_date, ord_main.rst_charge_user_info, ord_main.rst_puncture_user_info,
    ord_main.rst_return_user_info, ord_main.rst_weight_info,
--   add 10196 by kangjie 20240130 start del
--     ord_main.rst_vital_info,
--   add 10196 by kangjie 20240130 end del
    ord_main.fn_pat_id, ord_main.treat_week,
    ord_main.ind_va_cd, ord_main.ind_treatment_cd, ord_main.ind_treatment_name, ord_main.ind_treat_start_time,
    ord_main.ind_schedule_user_info, ord_main.ind_cond_info, ord_main.ind_medi_info, ord_main.ind_equip_info,
    ord_main.ind_ind_comment_info, ord_main.ind_tare_info, ord_main.ind_off_water_info, ord_main.ind_device_set_info,
    ord_main.rst_fn_dialysis_no, ord_main.rst_relation_dialysis_no, ord_main.rst_edition, ord_main.rst_is_update_edition,
    ord_main.rst_input_class, ord_main.rst_dialysis_state, ord_main.rst_treatment_cd, ord_main.rst_treatment_name,
    ord_main.rst_machine_name, ord_main.rst_cond_send_date, ord_main.rst_accept_date, ord_main.rst_return_home_date,
    ord_main.rst_in_out_class, ord_main.rst_dialysis_cnt, ord_main.rst_ward_cd, ord_main.rst_ward_name, ord_main.rst_course_cd,
    ord_main.rst_course_name, ord_main.rst_blood_circulate_total, ord_main.rst_running_time, ord_main.rst_kt_v,
    ord_main.rec_set_date, ord_main.send_ctl_no, ord_main.blood_purifier_name, ord_main.pull_leave_amount,
    ord_main.rst_cond_info, ord_main.rst_medi_info, ord_main.rst_equip_info, ord_main.rst_ind_comment_info,
    ord_main.rst_tare_info, ord_main.rst_off_water_info,
--   add 10196 by kangjie 20240130 start del
--     ord_main.rst_device_set_info,
--   add 10196 by kangjie 20240130 end del
    ord_main.rst_complaint_info,
    ord_main.rst_treatment_info, ord_main.rst_treat_staff_info, ord_main.rst_rounds_info, ord_main.is_del, ord_main.rst_dw, ord_main.ind_dw, ord_main.weight_scale_no,
    1 as machine_entry
  from ord_main
    inner join
      -- 装置情報から治療中のnext_ord_no取得
      (select
        next_ord_no as ord_no
      from
        mnt_machine_state
      where
        facility_cd = /*facilityCd*/'999900'
      and
        -- next_ord_noがord_noと一致しないものとord_noが空でnext_ord_noがあるもの
        ((ord_no is not null and next_ord_no is not null and ord_no != next_ord_no) or (ord_no is null and next_ord_no is not null ))
      ) mnt_machine_state
    on (ord_main.ord_no = mnt_machine_state.ord_no)
  where
    is_del = '0'
  ) A
  left outer join mst_va B on (A.ind_va_cd = B.va_cd)
  left outer join mst_treatment C on (A.ind_treatment_cd = C.treatment_cd)
  left outer join mst_kur D on (A.ind_kur_cd = D.kur_cd)
  left outer join mst_bed E on (A.ind_bed_cd = E.bed_cd)
  left outer join mst_treatment F on (A.ind_treatment_cd = F.treatment_cd)
  left outer join mst_treatment G on (A.rst_treatment_cd = G.treatment_cd)
  left outer join pat_ind_approve H on (A.ord_no = H.ord_no)
  order by machine_entry desc, ord_no
;
