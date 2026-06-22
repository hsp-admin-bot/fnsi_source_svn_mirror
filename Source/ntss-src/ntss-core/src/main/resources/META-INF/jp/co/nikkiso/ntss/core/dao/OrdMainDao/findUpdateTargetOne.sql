-- add 9664 by kangjie 20240513 start
SELECT
  t.ord_no
     ,t.pat_id
     ,t.fn_pat_id
     ,t.treat_date
     ,t.treat_week
     ,t.facility_cd
     ,t.facility_name
     ,t.ind_va_cd
     ,t.ind_treatment_cd
     ,t.ind_treatment_name
     ,t.ind_kur_cd
     ,t.ind_kur_name
     ,t.ind_treat_start_time
     ,t.ind_bed_cd
     ,t.ind_bed_name
     ,t.ind_schedule_user_info
     ,t.ind_cond_info
     ,t.ind_medi_info
     ,t.ind_equip_info
     ,t.ind_ind_comment_info
     ,t.ind_tare_info
     ,t.ind_off_water_info
     ,t.rst_fn_dialysis_no
     ,t.rst_relation_dialysis_no
     ,t.rst_edition
     ,t.rst_is_update_edition
     ,t.rst_input_class
     ,t.rst_dialysis_state
     ,t.rst_treatment_cd
     ,t.rst_treatment_name
     ,t.rst_kur_cd
     ,t.rst_kur_name
     ,t.rst_bed_cd
     ,t.rst_bed_name
     ,t.rst_machine_no
     ,t.rst_machine_name
     ,t.rst_cond_send_date
     ,t.rst_accept_date
     ,t.rst_start_date
     ,t.rst_end_date
     ,t.rst_return_home_date
     ,t.rst_in_out_class
     ,t.rst_dialysis_cnt
     ,t.rst_ward_cd
     ,t.rst_ward_name
     ,t.rst_course_cd
     ,t.rst_course_name
     ,t.rst_puncture_user_info
     ,t.rst_return_user_info
     ,t.rst_charge_user_info
     ,t.rst_blood_circulate_total
     ,t.rst_running_time
     ,t.rst_kt_v
     ,t.rec_set_date
     ,t.send_ctl_no
     ,t.blood_purifier_name
     ,t.pull_leave_amount
     ,t.rst_cond_info
     ,t.rst_medi_info
     ,t.rst_equip_info
     ,t.rst_ind_comment_info
     ,t.rst_tare_info
     ,t.rst_off_water_info
     ,t.rst_weight_info
     ,t.rst_complaint_info
     ,t.rst_treatment_info
     ,t.rst_treat_staff_info
     ,t.rst_rounds_info
     ,t.is_del
     ,t.up_date
     ,t.ind_device_set_info
     ,t.rst_purification_cnt
     ,t.reg_date
     ,treatment.device_mode as ind_device_mode
     ,treatment.treatment_condition_setting as treatment_condition_setting
FROM
  ord_main t
    left join mst_treatment treatment on treatment.treatment_cd = t.ind_treatment_cd
WHERE
  t.is_del = '0'
  AND
  t.rst_dialysis_state = '0'
/*%if null != patId*/
AND
  t.pat_id = /*patId*/0
/*%end*/
-- mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関
/*%if null != facilityCd*/
AND
  t.facility_cd = /*facilityCd*/'000000'
/*%end*/
AND
  t.treat_date >= /*treatDateFrom*/'00000000'
/*%if null != treatDateTo*/
AND
  t.treat_date <= /*treatDateTo*/'00000000'
/*%end*/
/*%if 0 != weeks.get(0)*/
AND
  t.treat_week in /*weeks*/(0)
/*%end*/
/*%if 0 != treats.size()*/
AND
  t.ind_treatment_cd in /*treats*/(0)
/*%end*/
/*%if 0 != kurs.size()*/
AND
  t.ind_kur_cd in /*kurs*/(0)
/*%end*/

ORDER BY t.treat_date asc, t.ord_no asc
limit 1
-- add 9664 by kangjie 20240513 end
