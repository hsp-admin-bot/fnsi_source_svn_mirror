-- mod #12120 by zhangruixue 2025-08-06 start
-- select
--   A.facility_cd, A.facility_name, A.ord_no, A.pat_id, A.treat_date,
--   A.ind_kur_cd as ind_kur_cd,
--   A.ind_kur_name, A.rst_kur_cd, A.rst_kur_name,
--   A.ind_bed_cd, A.ind_bed_name, A.rst_bed_cd, A.rst_bed_name, A.rst_machine_no,
--   A.rst_start_date, A.rst_end_date, A.rst_charge_user_info, A.rst_puncture_user_info,
--   A.rst_return_user_info, A.rst_weight_info,
--   A.fn_pat_id, A.treat_week,
--   A.ind_va_cd, A.ind_treatment_cd, A.ind_treatment_name, A.ind_treat_start_time,
--   A.ind_schedule_user_info, A.ind_cond_info, A.ind_medi_info, A.ind_equip_info,
--   A.ind_ind_comment_info, A.ind_tare_info, A.ind_off_water_info, A.ind_device_set_info,
--   A.rst_fn_dialysis_no, A.rst_relation_dialysis_no, A.rst_edition, A.rst_is_update_edition,
--   A.rst_input_class, A.rst_dialysis_state, A.rst_treatment_cd, A.rst_treatment_name,
--   A.rst_machine_name, A.rst_cond_send_date, A.rst_accept_date, A.rst_return_home_date,
--   A.rst_in_out_class, A.rst_dialysis_cnt, A.rst_ward_cd, A.rst_ward_name, A.rst_course_cd,
--   A.rst_course_name, A.rst_blood_circulate_total, A.rst_running_time, A.rst_kt_v,
--   A.rec_set_date, A.send_ctl_no, A.blood_purifier_name, A.pull_leave_amount,
--   A.rst_cond_info, A.rst_medi_info, A.rst_equip_info, A.rst_ind_comment_info,
--   A.rst_tare_info, A.rst_off_water_info,
--   A.rst_complaint_info,
--   A.rst_treatment_info, A.rst_treat_staff_info, A.rst_rounds_info, A.is_del, A.rst_dw, A.ind_dw, A.weight_scale_no,
--   B.va_name as ind_mst_va_name,
--   C.treatment_name as ind_mst_treatment_name,
--   D.kur_name as ind_mst_kur_name,
--   E.bed_name as ind_mst_bed_name,
--   H.is_content_changed_for_map as is_content_changed_for_map,
--   I.is_dummy as is_dummy,
--   M.machine_type_cd as machine_type_cd,
--   M.machine_serial as machine_serial
-- from
--   ord_main A
--   inner join ord_schedule I on (A.ord_no = I.ord_no)
--   left outer join mst_va B on (A.ind_bed_cd = B.va_cd)
--   left outer join mst_treatment C on (A.ind_treatment_cd = C.treatment_cd)
--   left outer join mst_kur D on (A.ind_kur_cd = D.kur_cd)
--   left outer join mst_bed E on (A.ind_bed_cd = E.bed_cd)
--   left outer join mst_machine M on (E.machine_no = M.machine_no)
--   left outer join pat_ind_approve H on (A.ord_no = H.ord_no)
-- where
--     A.facility_cd = /*facilityCd*/''
--   and
--   -- modify by chamaojia 2024-10-24 [9312] table change corresponding to the queried column (A -> I)  --start
--     I.treat_date = /*treatDate*/''
--   -- modify by chamaojia 2024-10-24 [9312] table change corresponding to the queried column (A -> I)  --end
--   and
--     A.pat_id is not null
--   and
--     I.kur_cd = /*kurCd*/''
-- /*%if bedCdList != null && bedCdList.size() > 0 */
--   and
--     I.bed_cd in /*bedCdList*/(NULL)
-- /*%end */
--   and
--     A.is_del = '0'
-- ;
with filtered_ord_schedule as (
 select * from ord_schedule
 where
         facility_cd = /*facilityCd*/''
   and treat_date = /*treatDate*/''
   and kur_cd = /*kurCd*/0
     /*%if bedCdList != null && bedCdList.size() > 0 */
   and bed_cd in /*bedCdList*/(NULL)
 /*%end */
),
filtered_ord_main as (
    select * from ord_main
    where facility_cd = /*facilityCd*/''
      and ord_no in (
            select ord_no
            from filtered_ord_schedule
      )
      and pat_id > 0
      and is_del = '0'
)
select
    A.facility_cd, A.facility_name, A.ord_no, A.pat_id, A.treat_date,
    I.kur_cd as ind_kur_cd,
    A.ind_kur_name, A.rst_kur_cd, A.rst_kur_name,
    A.ind_bed_cd, A.ind_bed_name, A.rst_bed_cd, A.rst_bed_name, A.rst_machine_no,
    A.rst_start_date, A.rst_end_date, A.rst_charge_user_info, A.rst_puncture_user_info,
    A.rst_return_user_info, A.rst_weight_info,
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
    A.rst_complaint_info,
    A.rst_treatment_info, A.rst_treat_staff_info, A.rst_rounds_info, A.is_del, A.rst_dw, A.ind_dw, A.weight_scale_no,
    B.va_name as ind_mst_va_name,
    C.treatment_name as ind_mst_treatment_name,
    D.kur_name as ind_mst_kur_name,
    E.bed_name as ind_mst_bed_name,
    H.is_content_changed_for_map as is_content_changed_for_map,
    I.is_dummy as is_dummy,
    M.machine_type_cd as machine_type_cd,
    M.machine_serial as machine_serial
from filtered_ord_main A
inner join filtered_ord_schedule I on A.ord_no = I.ord_no
left outer join mst_va B on (A.ind_va_cd = B.va_cd)
left outer join mst_treatment C on (A.ind_treatment_cd = C.treatment_cd)
left outer join mst_kur D on (A.ind_kur_cd = D.kur_cd)
left outer join mst_bed E on (A.ind_bed_cd = E.bed_cd)
left outer join mst_machine M on (E.machine_no = M.machine_no)
left outer join pat_ind_approve H on (A.ord_no = H.ord_no)
-- mod #12120 by zhangruixue 2025-08-06 end
