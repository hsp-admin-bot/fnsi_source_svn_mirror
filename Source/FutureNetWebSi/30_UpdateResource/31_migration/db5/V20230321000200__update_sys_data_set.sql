DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (1708);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1708, 'with compareDate as (select (case TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') >
                                  TO_DATE(to_char(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS''), ''YYYY-MM-DD HH24:MI:SS'')
                                 when true then ''@dieDate_Date''
                                 else to_char(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS'') end) as die_date)
INSERT
INTO ord_main_restore( del_date
                     , ord_no
                     , pat_id
                     , fn_pat_id
                     , treat_date
                     , treat_week
                     , facility_cd
                     , facility_name
                     , ind_va_cd
                     , ind_treatment_cd
                     , ind_treatment_name
                     , ind_kur_cd
                     , ind_kur_name
                     , ind_treat_start_time
                     , ind_bed_cd
                     , ind_bed_name
                     , ind_schedule_user_info
                     , ind_cond_info
                     , ind_medi_info
                     , ind_equip_info
                     , ind_ind_comment_info
                     , ind_tare_info
                     , ind_off_water_info
                     , ind_device_set_info
                     , rst_fn_dialysis_no
                     , rst_relation_dialysis_no
                     , rst_edition
                     , rst_is_update_edition
                     , rst_input_class
                     , rst_dialysis_state
                     , rst_treatment_cd
                     , rst_treatment_name
                     , rst_kur_cd
                     , rst_kur_name
                     , rst_bed_cd
                     , rst_bed_name
                     , rst_machine_no
                     , rst_machine_name
                     , rst_cond_send_date
                     , rst_accept_date
                     , rst_start_date
                     , rst_end_date
                     , rst_return_home_date
                     , rst_in_out_class
                     , rst_dialysis_cnt
                     , rst_ward_cd
                     , rst_ward_name
                     , rst_course_cd
                     , rst_course_name
                     , rst_puncture_user_info
                     , rst_return_user_info
                     , rst_charge_user_info
                     , rst_blood_circulate_total
                     , rst_running_time
                     , rst_kt_v
                     , rec_set_date
                     , send_ctl_no
                     , blood_purifier_name
                     , pull_leave_amount
                     , rst_cond_info
                     , rst_medi_info
                     , rst_equip_info
                     , rst_ind_comment_info
                     , rst_tare_info
                     , rst_off_water_info
                     , rst_device_set_info
                     , rst_weight_info
                     , rst_vital_info
                     , rst_complaint_info
                     , rst_treatment_info
                     , rst_treat_staff_info
                     , rst_rounds_info
                     , is_del
                     , up_date
                     , reg_date
                     , rst_dw
                     , weight_scale_no
                     , treat_type
                     , is_confirm
                     , ind_dw
                     , rst_purification_cnt
                     , addition_info
                     , up_ind_user_id
                     , up_user_id
                     , rst_edition_date
                     , cur_edition_date
                     , fn_plural)
SELECT CURRENT_TIMESTAMP AS del_date
     , ord_no
     , pat_id
     , fn_pat_id
     , treat_date
     , treat_week
     , facility_cd
     , facility_name
     , ind_va_cd
     , ind_treatment_cd
     , ind_treatment_name
     , ind_kur_cd
     , ind_kur_name
     , ind_treat_start_time
     , ind_bed_cd
     , ind_bed_name
     , ind_schedule_user_info
     , ind_cond_info
     , ind_medi_info
     , ind_equip_info
     , ind_ind_comment_info
     , ind_tare_info
     , ind_off_water_info
     , ind_device_set_info
     , rst_fn_dialysis_no
     , rst_relation_dialysis_no
     , rst_edition
     , rst_is_update_edition
     , rst_input_class
     , rst_dialysis_state
     , rst_treatment_cd
     , rst_treatment_name
     , rst_kur_cd
     , rst_kur_name
     , rst_bed_cd
     , rst_bed_name
     , rst_machine_no
     , rst_machine_name
     , rst_cond_send_date
     , rst_accept_date
     , rst_start_date
     , rst_end_date
     , rst_return_home_date
     , rst_in_out_class
     , rst_dialysis_cnt
     , rst_ward_cd
     , rst_ward_name
     , rst_course_cd
     , rst_course_name
     , rst_puncture_user_info
     , rst_return_user_info
     , rst_charge_user_info
     , rst_blood_circulate_total
     , rst_running_time
     , rst_kt_v
     , rec_set_date
     , send_ctl_no
     , blood_purifier_name
     , pull_leave_amount
     , rst_cond_info
     , rst_medi_info
     , rst_equip_info
     , rst_ind_comment_info
     , rst_tare_info
     , rst_off_water_info
     , rst_device_set_info
     , rst_weight_info
     , rst_vital_info
     , rst_complaint_info
     , rst_treatment_info
     , rst_treat_staff_info
     , rst_rounds_info
     , is_del
     , up_date
     , reg_date
     , rst_dw
     , weight_scale_no
     , treat_type
     , is_confirm
     , ind_dw
     , rst_purification_cnt
     , addition_info
     , up_ind_user_id
     , up_user_id
     , rst_edition_date
     , cur_edition_date
     , fn_plural
FROM ord_main,
     compareDate
WHERE is_del = ''0''
  AND rst_edition = 0
  AND rst_treatment_cd is null
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND treat_date >= TO_CHAR(TO_DATE(compareDate.die_date, ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
  AND treat_date not in (select treat_date
                         FROM ord_main, compareDate
                         WHERE is_del = ''0''
                           AND rst_edition = 0
                           AND pat_id = @patId
                           AND facility_cd = ''@facilityCd''
                           AND treat_date >= TO_CHAR(TO_DATE(compareDate.die_date, ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
                           AND rst_dialysis_state > ''0'')', 2, '[{}]', '0', '{"applications": [4]}', NULL, '未来日データをコピーする。透析予定(ord_main) → ord_main_restore', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
