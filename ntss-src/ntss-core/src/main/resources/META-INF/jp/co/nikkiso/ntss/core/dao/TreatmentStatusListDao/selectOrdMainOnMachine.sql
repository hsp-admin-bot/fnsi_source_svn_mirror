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

  C.va_name as ind_mst_va_name,
  D.treatment_name as ind_mst_treatment_name,
  E.kur_name as ind_mst_kur_name,
  F.bed_name as ind_mst_bed_name,
  H.is_content_changed_for_map as is_content_changed_for_map
from
  (
  select
    *
  from
    ord_main
  where
    facility_cd = /*facilityCd*/'000000'
  ) as A
  inner join
  (
    select
        coalesce (ord_no, next_ord_no) as ord_no
    from
      mnt_machine_state
    where
      facility_cd = /*facilityCd*/'000000'
    and
      model ~ '00[45]'
    and (
        ord_no is not null
      or
        next_ord_no is not null
    )
  ) as B
  on
    A.ord_no = B.ord_no
  left outer join mst_va C on (A.ind_bed_cd = C.va_cd)
  left outer join mst_treatment D on (A.ind_treatment_cd = D.treatment_cd)
  left outer join mst_kur E on (A.ind_kur_cd = E.kur_cd)
  left outer join mst_bed F on (A.ind_bed_cd = F.bed_cd)
  left outer join pat_ind_approve H on (A.ord_no = H.ord_no)
;
