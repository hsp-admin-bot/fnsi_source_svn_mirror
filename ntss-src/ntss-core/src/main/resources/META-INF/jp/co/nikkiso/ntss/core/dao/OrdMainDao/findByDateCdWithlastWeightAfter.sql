with ord_main_old as (
select
	*
from
	(
	select
		ord.ord_no,
		ord.rst_weight_info,
		s.rst_weight_info,
		s.rst_weight_info ->> 'weight_after' as last_weight_after,
		row_number() over (partition by ord.ord_no order by s.rst_start_date desc) rowId
	from
		ord_main as ord
	left outer join ord_main s on (
    	ord.ord_no <> s.ord_no
		and ord.pat_id = s.pat_id
		and ord.facility_cd = s.facility_cd
		and ord.rst_start_date > s.rst_start_date
		and s.is_del = '0'
  	)
	where
	/*%if pat_id != null */
		and ord.pat_id = /*pat_id*/1
        and
        ord.treat_date >= /*dialysis_date_from*/'20180220'
        and
        ord.treat_date <= /*dialysis_date_to*/'20180226'
    /*%end*/
    /*%if null != facility_cd */
		and ord.facility_cd = /*facility_cd*/'000000'
    /*%end*/
    /*%if weeksArry.get(0) != 0 */
        and ord.treat_week in /* weeksArry */( 1, 2, 3, 4, 5, 6, 7 )
    /*%end*/
		and ord.is_del = '0'
		and ord.rst_dialysis_state > '0'
) ord_main
where
ord_main.rowId = 1
)
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
--  ,B.rst_device_set_info
--   add 10196 by kangjie 20240130 end del
  ,B.rst_dw
  ,B.treat_type
  ,B.ind_dw
  ,B.rst_purification_cnt
  ,B.addition_info
--   add 8574 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
  ,ord_main_old.last_weight_after
--   add 8574 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
from
  ord_main B
  left outer join mst_kur on (B.ind_kur_cd = mst_kur.kur_cd and B.facility_cd = mst_kur.facility_cd and mst_kur.is_del = '0')
  left outer join mst_treatment on (B.ind_treatment_cd = mst_treatment.treatment_cd and B.facility_cd = mst_treatment.facility_cd and mst_treatment.is_del = '0')
  --   add 8574 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
    LEFT OUTER JOIN ord_main_old ON ( B.ord_no = ord_main_old.ord_no )
    --   add 8574 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
 where
/*%if pat_id != null */
  B.pat_id = /*pat_id*/1
 and
  B.treat_date >= /*dialysis_date_from*/'20180220'
 and
  B.treat_date <= /*dialysis_date_to*/'20180226'
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
