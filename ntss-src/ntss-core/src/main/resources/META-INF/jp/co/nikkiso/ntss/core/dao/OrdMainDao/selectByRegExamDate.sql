select
  ord.ord_no,
  ord.pat_id,
  ord.fn_pat_id,
  ord.treat_date,
  ord.treat_week,
  ord.facility_cd,
  ord.facility_name,
  ord.ind_va_cd,
  ord.ind_treatment_cd,
  ord.ind_treatment_name,
  ord.ind_kur_cd,
  ord.ind_kur_name,
  ord.ind_treat_start_time,
  ord.ind_bed_cd,
  ord.ind_bed_name,
  ord.ind_schedule_user_info,
  ord.ind_cond_info,
  ord.ind_medi_info,
  ord.ind_equip_info,
  ord.ind_ind_comment_info,
  ord.ind_tare_info,
  ord.ind_off_water_info,
  ord.rst_fn_dialysis_no,
  ord.rst_relation_dialysis_no,
  ord.rst_edition,
  ord.rst_is_update_edition,
  ord.rst_input_class,
  ord.rst_dialysis_state,
  ord.rst_treatment_cd,
  ord.rst_treatment_name,
  ord.rst_kur_cd,
  ord.rst_kur_name,
  ord.rst_bed_cd,
  ord.rst_bed_name,
  ord.rst_machine_no,
  ord.rst_machine_name,
  ord.rst_cond_send_date,
  ord.rst_accept_date,
  ord.rst_start_date,
  ord.rst_end_date,
  ord.rst_return_home_date,
  ord.rst_in_out_class,
  ord.rst_dialysis_cnt,
  ord.rst_ward_cd,
  ord.rst_ward_name,
  ord.rst_course_cd,
  ord.rst_course_name,
  ord.rst_puncture_user_info,
  ord.rst_return_user_info,
  ord.rst_charge_user_info,
  ord.rst_blood_circulate_total,
  ord.rst_running_time,
  ord.rst_kt_v,
  ord.rec_set_date,
  ord.send_ctl_no,
  ord.blood_purifier_name,
  ord.pull_leave_amount,
  ord.rst_cond_info,
  ord.rst_medi_info,
  ord.rst_equip_info,
  ord.rst_ind_comment_info,
  ord.rst_tare_info,
  ord.rst_off_water_info,
  ord.rst_weight_info,
--   add 10196 by kangjie 20240130 start del
--   ord.rst_vital_info,
--   add 10196 by kangjie 20240130 end del
  ord.rst_complaint_info,
  ord.rst_treatment_info,
  ord.rst_treat_staff_info,
  ord.rst_rounds_info,
  ord.is_del,
  ord.up_date,
  ord.ind_device_set_info,
--   add 10196 by kangjie 20240130 start del
--   ord.rst_device_set_info,
--   add 10196 by kangjie 20240130 end del
  ord.rst_dw,
  ord.treat_type
from
  ord_main ord left outer join pat_exam_main pat on ord.ord_no = pat.ord_no
where
  ord.pat_id = /* pat_id */null
and
  ord.facility_cd = /* facility_cd */null
and
  ord.ord_no = pat.ord_no
/*%if start_date != null */
and
  ord.treat_date >= /* start_date */null
/*%end */
/*%if end_date != null */
and
  ord.treat_date <= /* end_date */null
/*%end */
/*%if weeksArry.get(0) != 0 */
and
  ord.treat_week in /* weeksArry */()
/*%end */
/*%if null != is_del */
and
  ord.is_del = /* is_del */'0'
/*%end*/
/*%if reg_order_class.size() != 0 */
and
  pat.reg_order_class in /* reg_order_class */()
/*%end*/
order by
  ord.treat_date, ord.rst_start_date
;