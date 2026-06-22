select
  A.ord_no,
  A.pat_id,
  A.fn_pat_id,
  A.treat_date,
  A.treat_week,
  A.facility_cd,
  A.facility_name,
  A.ind_va_cd,
  A.ind_treatment_cd,
  A.ind_treatment_name,
  A.ind_kur_cd,
  A.ind_kur_name,
  A.ind_treat_start_time,
  A.ind_bed_cd,
  A.ind_bed_name,
  A.ind_schedule_user_info,
  A.ind_cond_info,
  A.ind_medi_info,
  A.ind_equip_info,
  A.ind_ind_comment_info,
  A.ind_tare_info,
  A.ind_off_water_info,
  A.ind_device_set_info,
  A.rst_fn_dialysis_no,
  A.rst_relation_dialysis_no,
  A.rst_edition,
  A.rst_is_update_edition,
  A.rst_input_class,
  A.rst_dialysis_state,
  A.rst_treatment_cd,
  A.rst_treatment_name,
  A.rst_kur_cd,
  A.rst_kur_name,
  A.rst_bed_cd,
  A.rst_bed_name,
  A.rst_machine_no,
  A.rst_machine_name,
  A.rst_cond_send_date,
  A.rst_accept_date,
  A.rst_start_date,
  A.rst_end_date,
  A.rst_return_home_date,
  A.rst_in_out_class,
  A.rst_dialysis_cnt,
  A.rst_ward_cd,
  A.rst_ward_name,
  A.rst_course_cd,
  A.rst_course_name,
  A.rst_dw,
  A.rst_puncture_user_info,
  A.rst_return_user_info,
  A.rst_charge_user_info,
  A.rst_blood_circulate_total,
  A.rst_running_time,
  A.rst_kt_v,
  A.rec_set_date,
  A.send_ctl_no,
  A.blood_purifier_name,
  A.pull_leave_amount,
  A.rst_cond_info,
  A.rst_medi_info,
  A.rst_equip_info,
  A.rst_ind_comment_info,
  A.rst_tare_info,
  A.rst_off_water_info,
--   add 10196 by kangjie 20240130 start del
--   A.rst_device_set_info,
--   add 10196 by kangjie 20240130 end del
  A.weight_scale_no,
  A.rst_weight_info,
--   add 10196 by kangjie 20240130 start del
--   A.rst_vital_info,
--   add 10196 by kangjie 20240130 end del
  A.rst_complaint_info,
  A.rst_treatment_info,
  A.rst_treat_staff_info,
  A.rst_rounds_info,
  A.is_del,
  A.up_date,
  A.reg_date,
  A.rst_purification_cnt
-- add by chamaojia 2025-02-28 [11471] Add the return value of 【rst_device_mode】 --start
  , A.rst_device_mode as device_mode
-- add by chamaojia 2025-02-28 [11471] Add the return value of 【rst_device_mode】 --end
from
  ord_main A
where
/*%if pat_id != null */
  A.pat_id = /*pat_id*/'000000000001'
  /*%if null !=  treat_date_from */
and
  A.treat_date >= /*treat_date_from*/'20180220'
  /*%end*/
  /*%if null != treat_date_to */
and
  A.treat_date <= /*treat_date_to*/'20180226'
  /*%end*/
/*%elseif null != ord_no */
  A.ord_no = /*ord_no*/1
/*%end*/
/*%if null != edition */
and
  A.rst_edition = /*edition*/1
/*%end*/
/*%if null != is_del */
and
  A.is_del = /*is_del*/'0'
/*%end*/
order by
  A.treat_date,
  A.rst_edition,
  A.rst_start_date;
