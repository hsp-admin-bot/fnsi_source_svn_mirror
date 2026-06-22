WITH updatesAll AS (
    select
        /*%expand "A" */*
    from
        ord_main A
    WHERE
            A.is_del = '0'
      AND A.facility_cd = /*facilityCd*/'000000'
        /*%if personalMainList != null && personalMainList.size() != 0*/
      AND (
        /*%for pat : personalMainList*/
        (A.pat_id = /*pat.pat_id*/0 AND TO_DATE(A.treat_date, 'YYYYMMDD') >= CAST(/*pat.die_date*/'' AS DATE))
        /*%if pat_has_next */
        /*# "or" */
        /*%end*/
        /*%end*/
        )
        /*%end*/
      AND A.rst_dialysis_state = '0'
),
     updates AS (SELECT facility_cd, ord_no FROM updatesAll),
     inserted_data AS (
INSERT INTO ord_main_restore (
                              ord_no
                             ,del_date
                             ,pat_id
                             ,fn_pat_id
                             ,treat_date
                             ,treat_week
                             ,facility_cd
                             ,facility_name
                             ,ind_va_cd
                             ,ind_treatment_cd
                             ,ind_treatment_name
                             ,ind_kur_cd
                             ,ind_kur_name
                             ,ind_treat_start_time
                             ,ind_bed_cd
                             ,ind_bed_name
                             ,ind_schedule_user_info
                             ,ind_cond_info
                             ,ind_medi_info
                             ,ind_equip_info
                             ,ind_ind_comment_info
                             ,ind_tare_info
                             ,ind_off_water_info
                             ,ind_device_set_info
                             ,rst_fn_dialysis_no
                             ,rst_relation_dialysis_no
                             ,rst_edition
                             ,rst_is_update_edition
                             ,rst_input_class
                             ,rst_dialysis_state
                             ,rst_treatment_cd
                             ,rst_treatment_name
                             ,rst_kur_cd
                             ,rst_kur_name
                             ,rst_bed_cd
                             ,rst_bed_name
                             ,rst_machine_no
                             ,rst_machine_name
                             ,rst_cond_send_date
                             ,rst_accept_date
                             ,rst_start_date
                             ,rst_end_date
                             ,rst_return_home_date
                             ,rst_in_out_class
                             ,rst_dialysis_cnt
                             ,rst_ward_cd
                             ,rst_ward_name
                             ,rst_course_cd
                             ,rst_course_name
                             ,rst_puncture_user_info
                             ,rst_return_user_info
                             ,rst_charge_user_info
                             ,rst_blood_circulate_total
                             ,rst_running_time
                             ,rst_kt_v
                             ,rec_set_date
                             ,send_ctl_no
                             ,blood_purifier_name
                             ,pull_leave_amount
                             ,rst_cond_info
                             ,rst_medi_info
                             ,rst_equip_info
                             ,rst_ind_comment_info
                             ,rst_tare_info
                             ,rst_off_water_info
                             ,rst_weight_info
                             ,rst_complaint_info
                             ,rst_treatment_info
                             ,rst_treat_staff_info
                             ,rst_rounds_info
                             ,is_del
                             ,up_date
                             ,up_ind_user_id
                             ,up_user_id
                             ,reg_date
                             ,treat_type
                             ,rst_purification_cnt
                             ,rst_dw
                             ,weight_scale_no
                             ,fn_plural
                             ,is_confirm
                             ,ind_dw
                             ,addition_info
                             ,rst_edition_date
                             ,cur_edition_date
                             ,bvms_path
)
SELECT
    om.ord_no
     ,CURRENT_TIMESTAMP
     ,om.pat_id
     ,om.fn_pat_id
     ,om.treat_date
     ,om.treat_week
     ,om.facility_cd
     ,om.facility_name
     ,om.ind_va_cd
     ,om.ind_treatment_cd
     ,om.ind_treatment_name
     ,om.ind_kur_cd
     ,om.ind_kur_name
     ,om.ind_treat_start_time
     ,om.ind_bed_cd
     ,om.ind_bed_name
     ,om.ind_schedule_user_info
     ,om.ind_cond_info
     ,om.ind_medi_info
     ,om.ind_equip_info
     ,om.ind_ind_comment_info
     ,om.ind_tare_info
     ,om.ind_off_water_info
     ,om.ind_device_set_info
     ,om.rst_fn_dialysis_no
     ,om.rst_relation_dialysis_no
     ,om.rst_edition
     ,om.rst_is_update_edition
     ,om.rst_input_class
     ,om.rst_dialysis_state
     ,om.rst_treatment_cd
     ,om.rst_treatment_name
     ,om.rst_kur_cd
     ,om.rst_kur_name
     ,om.rst_bed_cd
     ,om.rst_bed_name
     ,om.rst_machine_no
     ,om.rst_machine_name
     ,om.rst_cond_send_date
     ,om.rst_accept_date
     ,om.rst_start_date
     ,om.rst_end_date
     ,om.rst_return_home_date
     ,om.rst_in_out_class
     ,om.rst_dialysis_cnt
     ,om.rst_ward_cd
     ,om.rst_ward_name
     ,om.rst_course_cd
     ,om.rst_course_name
     ,om.rst_puncture_user_info
     ,om.rst_return_user_info
     ,om.rst_charge_user_info
     ,om.rst_blood_circulate_total
     ,om.rst_running_time
     ,om.rst_kt_v
     ,om.rec_set_date
     ,om.send_ctl_no
     ,om.blood_purifier_name
     ,om.pull_leave_amount
     ,om.rst_cond_info
     ,om.rst_medi_info
     ,om.rst_equip_info
     ,om.rst_ind_comment_info
     ,om.rst_tare_info
     ,om.rst_off_water_info
     ,om.rst_weight_info
     ,om.rst_complaint_info
     ,om.rst_treatment_info
     ,om.rst_treat_staff_info
     ,om.rst_rounds_info
     ,om.is_del
     ,om.up_date
     ,om.up_ind_user_id
     ,om.up_user_id
     ,om.reg_date
     ,om.treat_type
     ,om.rst_purification_cnt
     ,om.rst_dw
     ,om.weight_scale_no
     ,om.fn_plural
     ,om.is_confirm
     ,om.ind_dw
     ,om.addition_info
     ,om.rst_edition_date
     ,om.cur_edition_date
     ,om.bvms_path
FROM ord_main om, updates AS u
WHERE
        om.facility_cd = /*facilityCd*/null AND
        om.facility_cd = u.facility_cd AND
        om.ord_no = u.ord_no)
DELETE FROM ord_main
    USING updates u
WHERE
    ord_main.facility_cd = /*facilityCd*/null AND
    ord_main.ord_no = u.ord_no AND
    ord_main.ord_no = u.ord_no
    RETURNING ord_main.*
