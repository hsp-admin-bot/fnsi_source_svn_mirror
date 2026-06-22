select
  B.ord_no
  ,B.pat_id
  ,B.fn_pat_id
  ,B.treat_date
  ,B.treat_week
  ,B.facility_cd
  ,B.facility_name
  ,B.ind_va_cd
  ,B.ind_treatment_cd
  ,B.ind_treatment_name
  ,B.ind_kur_cd
  ,B.ind_kur_name
  ,B.ind_treat_start_time
  ,B.ind_bed_cd
  ,B.ind_bed_name
  ,B.ind_schedule_user_info
  ,B.ind_cond_info
  ,B.ind_medi_info
  ,B.ind_equip_info
  ,B.ind_ind_comment_info
  ,B.ind_tare_info
  ,B.ind_off_water_info
  ,B.rst_fn_dialysis_no
  ,B.rst_relation_dialysis_no
  ,B.rst_edition
  ,B.rst_is_update_edition
  ,B.rst_input_class
  ,B.rst_dialysis_state
  ,B.rst_treatment_cd
  ,B.rst_treatment_name
  ,B.rst_kur_cd
  ,B.rst_kur_name
  ,B.rst_bed_cd
  ,B.rst_bed_name
  ,B.rst_machine_no
  ,B.rst_machine_name
  ,B.rst_cond_send_date
  ,B.rst_accept_date
  ,B.rst_start_date
  ,B.rst_end_date
  ,B.rst_return_home_date
  ,B.rst_in_out_class
  ,B.rst_dialysis_cnt
  ,B.rst_ward_cd
  ,B.rst_ward_name
  ,B.rst_course_cd
  ,B.rst_course_name
  ,B.rst_puncture_user_info
  ,B.rst_return_user_info
  ,B.rst_charge_user_info
  ,B.rst_blood_circulate_total
  ,B.rst_running_time
  ,B.rst_kt_v
  ,B.rec_set_date
  ,B.send_ctl_no
  ,B.blood_purifier_name
  ,B.pull_leave_amount
  ,B.rst_cond_info
  ,B.rst_medi_info
  ,B.rst_equip_info
  ,B.rst_ind_comment_info
  ,B.rst_tare_info
  ,B.rst_off_water_info
  ,B.rst_weight_info
--   add 10196 by kangjie 20240130 start del
--   ,B.rst_vital_info
--   add 10196 by kangjie 20240130 end del
  ,B.rst_complaint_info
  ,B.rst_treatment_info
  ,B.rst_treat_staff_info
  ,B.rst_rounds_info
  ,B.is_del
  ,B.up_date
  ,B.ind_device_set_info
--   add 10196 by kangjie 20240130 start del
--   ,B.rst_device_set_info
--   add 10196 by kangjie 20240130 end del
  ,B.rst_dw
  ,B.treat_type
  ,B.ind_dw
  ,B.rst_purification_cnt
from
  ord_main B
  left outer join mst_kur on (B.ind_kur_cd = mst_kur.kur_cd)
  left outer join mst_treatment on (B.ind_treatment_cd = mst_treatment.treatment_cd)
 where
/*%if pat_id != null */
  B.pat_id = /*pat_id*/1
 and
  B.treat_date >= /*dialysis_date_from*/'20180220'
/*%if null != facility_cd */
and
  B.facility_cd = /*facility_cd*/'000000'
/*%end*/
/*%elseif null != ord_no */
  B.ord_no = /*ord_no*/1
/*%end*/
/*%if weeksArry.get(0) != 0 */
 and
  B.treat_week in /* weeksArry */(1,2,3)
/*%end */
/*%if null != is_del */
 and
  B.is_del = /*is_del*/'0'
/*%end*/
 order by
  B.treat_date,
  mst_kur.kur_start_time nulls first,
  mst_treatment.device_mode,
  B.ord_no
;
