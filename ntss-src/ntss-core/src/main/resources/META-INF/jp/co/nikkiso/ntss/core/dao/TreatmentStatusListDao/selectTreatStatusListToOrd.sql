WITH mss_bed AS (
select
            mss.facility_cd, ms.*, row_number() over() as ord_index
        from
            mst_selector mss
        cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
        (
            code bigint,
            name text
        )
        where
            master_physical_name = 'mst_bed'
            AND facility_cd = /*facilityCd*/''
)
SELECT 
    facility_cd,
    facility_name,
    ord_no,
    pat_id,
    treat_date,
    ind_kur_cd,
    ind_kur_name,
    rst_kur_cd,
    rst_kur_name,
    ind_bed_cd,
    ind_bed_name,
    rst_bed_cd,
    rst_bed_name,
    rst_machine_no,
    rst_start_date,
    rst_end_date,
    rst_charge_user_info,
    rst_puncture_user_info,
    rst_return_user_info,
    rst_weight_info,
    fn_pat_id,
    treat_week,
    ind_va_cd,
    ind_treatment_cd,
    ind_treatment_name,
    ind_treat_start_time,
    ind_schedule_user_info,
    ind_cond_info,
    ind_medi_info,
    ind_equip_info,
    ind_ind_comment_info,
    ind_tare_info,
    ind_off_water_info,
    ind_device_set_info,
    rst_fn_dialysis_no,
    rst_relation_dialysis_no,
    rst_edition,
    rst_is_update_edition,
    rst_input_class,
    rst_dialysis_state,
    rst_treatment_cd,
    rst_treatment_name,
    rst_machine_name,
    rst_cond_send_date,
    rst_accept_date,
    rst_return_home_date,
    rst_in_out_class,
    rst_dialysis_cnt,
    rst_ward_cd,
    rst_ward_name,
    rst_course_cd,
    rst_course_name,
    rst_blood_circulate_total,
    rst_running_time,
    rst_kt_v,
    rec_set_date,
    send_ctl_no,
    blood_purifier_name,
    pull_leave_amount,
    rst_cond_info,
    rst_medi_info,
    rst_equip_info,
    rst_ind_comment_info,
    rst_tare_info,
    rst_off_water_info,
    rst_complaint_info,
    rst_treatment_info,
    rst_treat_staff_info,
    rst_rounds_info,
    is_del,
    rst_dw,
    ind_dw,
    weight_scale_no,
    machine_entry,
    rst_puncture_user_id_a,
    rst_puncture_user_id_b,
    rst_puncture_date_a,
    rst_puncture_date_b,
    rst_puncture_date,
    rst_return_user_id_a,
    rst_return_user_id_b,
    rst_return_date_A,
    rst_return_date_B,
    rst_return_date,
    rst_charge_user_id_a,
    rst_charge_user_id_b,
    rst_charge_date_a,
    rst_charge_date_b,
    ind_mst_va_name,
    ind_mst_treatment_name,
    ind_mst_kur_name,
    ind_mst_bed_name,
    ind_treatment_device_mode,
    rst_treatment_device_mode,
    is_content_changed_for_map,
    ord_index,
    kur_start_time
 FROM (
    select
        A.facility_cd,
        A.facility_name,
        A.ord_no,
        A.pat_id,
        A.treat_date,
        A.ind_kur_cd,
        A.ind_kur_name,
        A.rst_kur_cd,
        A.rst_kur_name,
        A.ind_bed_cd,
        A.ind_bed_name,
        A.rst_bed_cd,
        A.rst_bed_name,
        A.rst_machine_no,
        A.rst_start_date,
        A.rst_end_date,
        A.rst_charge_user_info,
        A.rst_puncture_user_info,
        A.rst_return_user_info,
        A.rst_weight_info,
        A.fn_pat_id,
        A.treat_week,
        A.ind_va_cd,
        A.ind_treatment_cd,
        A.ind_treatment_name,
        A.ind_treat_start_time,
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
        A.rst_machine_name,
        A.rst_cond_send_date,
        A.rst_accept_date,
        A.rst_return_home_date,
        A.rst_in_out_class,
        A.rst_dialysis_cnt,
        A.rst_ward_cd,
        A.rst_ward_name,
        A.rst_course_cd,
        A.rst_course_name,
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
        A.rst_complaint_info,
        A.rst_treatment_info,
        A.rst_treat_staff_info,
        A.rst_rounds_info,
        A.is_del,
        A.rst_dw,
        A.ind_dw,
        A.weight_scale_no,
        case when mms.ord_no is null then 0 else 2 end as machine_entry,
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
        H.is_content_changed_for_map as is_content_changed_for_map,
        I.ord_index as ord_index,
        J.kur_start_time as kur_start_time
    from
        ord_main A
        left outer join mnt_machine_state mms on
        (A.ord_no = mms.ord_no)    
        left outer join mst_va B on
        (A.ind_va_cd = B.va_cd)
        left outer join mst_treatment C on
        (A.ind_treatment_cd = C.treatment_cd)
        left outer join mst_kur D on
        (A.ind_kur_cd = D.kur_cd)
        left outer join mst_bed E on
        (A.ind_bed_cd = E.bed_cd)
        left outer join mst_treatment F on
        (A.ind_treatment_cd = F.treatment_cd)
        left outer join mst_treatment G on
        (A.rst_treatment_cd = G.treatment_cd)
        left outer join pat_ind_approve H on
        (A.ord_no = H.ord_no)
        left outer join mss_bed I on
        (A.rst_bed_cd = I.code)
        left outer join mst_kur J on
        (A.rst_kur_cd = J.kur_cd)
    where
        A.facility_cd = /*facilityCd*/''
      and
        A.rst_dialysis_state in ('1', '2', '3', '4', '5')
      and 
        A.pat_id is not null
    /*%if bedCdList != null && bedCdList.size() > 0 */
      and
        A.rst_bed_cd in /*bedCdList*/(NULL)
    /*%end */
    /*%if kurCdList != null && kurCdList.size() > 0 */
      and
        A.rst_kur_cd in /*kurCdList*/(NULL)
    /*%end */
      and
        A.is_del = '0'
    union all
    -- ????patient queries (pat_id is null)
    select
        A.facility_cd,
        A.facility_name,
        A.ord_no,
        A.pat_id,
        A.treat_date,
        A.ind_kur_cd,
        A.ind_kur_name,
        A.rst_kur_cd,
        A.rst_kur_name,
        A.ind_bed_cd,
        A.ind_bed_name,
        A.rst_bed_cd,
        A.rst_bed_name,
        A.rst_machine_no,
        A.rst_start_date,
        A.rst_end_date,
        A.rst_charge_user_info,
        A.rst_puncture_user_info,
        A.rst_return_user_info,
        A.rst_weight_info,
        A.fn_pat_id,
        A.treat_week,
        A.ind_va_cd,
        A.ind_treatment_cd,
        A.ind_treatment_name,
        A.ind_treat_start_time,
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
        A.rst_machine_name,
        A.rst_cond_send_date,
        A.rst_accept_date,
        A.rst_return_home_date,
        A.rst_in_out_class,
        A.rst_dialysis_cnt,
        A.rst_ward_cd,
        A.rst_ward_name,
        A.rst_course_cd,
        A.rst_course_name,
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
        A.rst_complaint_info,
        A.rst_treatment_info,
        A.rst_treat_staff_info,
        A.rst_rounds_info,
        A.is_del,
        A.rst_dw,
        A.ind_dw,
        A.weight_scale_no,
        case when mms.ord_no is null then 0 else 2 end as machine_entry,
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
        H.is_content_changed_for_map as is_content_changed_for_map,
        I.ord_index as ord_index,
        J.kur_start_time as kur_start_time
    from
        ord_main A
        left outer join mnt_machine_state mms on
        (A.ord_no = mms.ord_no)
        left outer join mst_va B on
        (A.ind_va_cd = B.va_cd)
        left outer join mst_treatment C on
        (A.ind_treatment_cd = C.treatment_cd)
        left outer join mst_kur D on
        (A.ind_kur_cd = D.kur_cd)
        left outer join mst_bed E on
        (A.ind_bed_cd = E.bed_cd)
        left outer join mst_treatment F on
        (A.ind_treatment_cd = F.treatment_cd)
        left outer join mst_treatment G on
        (A.rst_treatment_cd = G.treatment_cd)
        left outer join pat_ind_approve H on
        (A.ord_no = H.ord_no)
        left outer join mss_bed I on
        (A.rst_bed_cd = I.code)
        left outer join mst_kur J on
        (A.rst_kur_cd = J.kur_cd)
    where
        A.facility_cd = /*facilityCd*/''
      and
        A.rst_dialysis_state in ('1', '2', '3', '4', '5')
      and
        A.pat_id is null
    /*%if bedCdList != null && bedCdList.size() > 0 */
      and
        A.rst_bed_cd in /*bedCdList*/(NULL)
    /*%end */
    /*%if kurCdList != null && kurCdList.size() > 0 */
      and
        A.rst_kur_cd in /*kurCdList*/(NULL)
    /*%end */
      and
        A.is_del = '0'
    ) AS T
    order by ord_index ASC, treat_date ASC, kur_start_time ASC
;
