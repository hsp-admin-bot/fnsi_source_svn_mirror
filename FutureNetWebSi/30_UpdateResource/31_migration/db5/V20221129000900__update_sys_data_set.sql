delete from ntss.sys_data_set where sql_cd in (1708, 1709, 1710, 1711, 1712, 1713, 1891, 1892, 1893);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1708, 'with state as (select (case when count(1) > 0 then false else true end) as checkStatue
         FROM ord_main
         WHERE is_del = ''0''
           AND rst_edition = 0
           AND pat_id = @patId
           AND facility_cd = ''@facilityCd''
           AND treat_date = TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
           and rst_dialysis_state > ''0''),
     compareDate as (select (case TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') >
                                  TO_DATE(to_char(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS''), ''YYYY-MM-DD HH24:MI:SS'')
                                 when true then ''@dieDate_Date''
                                 else to_char(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS'') end) as die_date)
INSERT 
INTO ord_main_restore( 
  del_date
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
) 
SELECT
  CURRENT_TIMESTAMP AS del_date
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
FROM
  ord_main, state, compareDate
WHERE
  is_del = ''0'' 
  AND rst_edition = 0
  AND rst_treatment_cd is null
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND (treat_date > TO_CHAR(TO_DATE(compareDate.die_date, ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
    OR (treat_date = TO_CHAR(TO_DATE(compareDate.die_date, ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'') AND state.checkStatue))', 2, '[{}]', '0', '{"applications": [4]}', null, '未来日データをコピーする。透析予定(ord_main) → ord_main_restore', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1709, 'with state as (select (case when count(1) > 0 then false else true end) as checkStatue
         FROM ord_main
         WHERE is_del = ''0''
           AND rst_edition = 0
           AND pat_id = @patId
           AND facility_cd = ''@facilityCd''
           AND treat_date = TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
           and rst_dialysis_state > ''0''),
     compareDate as (select (case TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') >
                                  TO_DATE(to_char(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS''), ''YYYY-MM-DD HH24:MI:SS'')
                                 when true then ''@dieDate_Date''
                                 else to_char(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS'') end) as die_date)
INSERT
INTO pat_exam_main_hst( exam_main_cd
                      , pat_id
                      , facility_cd
                      , ord_no
                      , fn_pat_id
                      , reg_exam_date
                      , reg_order_class
                      , exam_status
                      , order_comment
                      , order_exam_set_info
                      , exam_order_info
                      , order_label_info
                      , data_gen_class
                      , result_exam_date
                      , result_comment
                      , exam_result_info
                      , cop_order_no1
                      , cop_order_no2
                      , is_lock
                      , ind_user_id
                      , is_del
                      , reg_date
                      , reg_staff
                      , up_date
                      , up_staff
                      , is_order)
SELECT exam_main_cd
     , pat_id
     , facility_cd
     , ord_no
     , fn_pat_id
     , reg_exam_date
     , reg_order_class
     , exam_status
     , order_comment
     , order_exam_set_info
     , exam_order_info
     , order_label_info
     , data_gen_class
     , result_exam_date
     , result_comment
     , exam_result_info
     , cop_order_no1
     , cop_order_no2
     , is_lock
     , ind_user_id
     , is_del
     , reg_date
     , reg_staff
     , up_date
     , up_staff
     , is_order
FROM pat_exam_main,
     state,
     compareDate
WHERE is_del = ''0''
  AND exam_status = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND (TO_CHAR(reg_exam_date, ''YYYYMMDD'') > TO_CHAR(TO_DATE(compareDate.die_date, ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
    OR (TO_CHAR(reg_exam_date, ''YYYYMMDD'') = TO_CHAR(TO_DATE(compareDate.die_date, ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'') AND
        state.checkStatue))', 2, '[{}]', '0', '{"applications": [4]}', null, '未来日データをコピーする。検査オーダ（pat_exam_main） → pat_exam_main_hst', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1710, 'with state as (select (case when count(1) > 0 then false else true end) as checkStatue
         FROM ord_main
         WHERE is_del = ''0''
           AND rst_edition = 0
           AND pat_id = @patId
           AND facility_cd = ''@facilityCd''
           AND treat_date = TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
           and rst_dialysis_state > ''0''),
     compareDate as (select (case TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') >
                                  TO_DATE(to_char(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS''), ''YYYY-MM-DD HH24:MI:SS'')
                                 when true then ''@dieDate_Date''
                                 else to_char(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS'') end) as die_date)
INSERT
INTO pat_rad_main_hst( rad_result_cd
                     , pat_id
                     , facility_cd
                     , fn_pat_id
                     , reg_rad_date
                     , reg_order_class
                     , rad_status
                     , order_rad_set_info
                     , cop_order_no1
                     , cop_order_no2
                     , is_lock
                     , ind_user_id
                     , is_del
                     , reg_date
                     , reg_staff
                     , up_date
                     , up_staff)
SELECT rad_result_cd
     , pat_id
     , facility_cd
     , fn_pat_id
     , reg_rad_date
     , reg_order_class
     , rad_status
     , order_rad_set_info
     , cop_order_no1
     , cop_order_no2
     , is_lock
     , ind_user_id
     , is_del
     , reg_date
     , reg_staff
     , up_date
     , up_staff
FROM pat_rad_main,
     state,
     compareDate
WHERE is_del = ''0''
  AND rad_status = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND (TO_CHAR(reg_rad_date, ''YYYYMMDD'') > TO_CHAR(TO_DATE(compareDate.die_date, ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
    OR (TO_CHAR(reg_rad_date, ''YYYYMMDD'') = TO_CHAR(TO_DATE(compareDate.die_date, ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'') AND
        state.checkStatue))', 2, '[{}]', '0', '{"applications": [4]}', null, '未来日データをコピーする。一般撮影検査オーダ（pat_rad_main） → pat_rad_main_hst', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1711, 'with compareDate as (select (case TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') >
                                  TO_DATE(to_char(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS''), ''YYYY-MM-DD HH24:MI:SS'')
                                 when true then ''@dieDate_Date''
                                 else to_char(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS'') end) as die_date)
DELETE
FROM
  ord_main 
WHERE
  is_del = ''0'' 
  AND rst_edition = 0
  AND rst_treatment_cd is null
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND (treat_date > TO_CHAR(TO_DATE((select die_date from compareDate), ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
    OR (treat_date = TO_CHAR(TO_DATE((select die_date from compareDate), ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'') 
    AND (select case when count(1) > 0 then false else true end
         FROM ord_main
         WHERE is_del = ''0''
           AND rst_edition = 0
           AND pat_id = @patId
           AND facility_cd = ''@facilityCd''
           AND treat_date = TO_CHAR(TO_DATE((select die_date from compareDate), ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
           and rst_dialysis_state > ''0'')))', 2, '[{}]', '0', '{"applications": [4]}', null, '未来日データを削除する。透析予定(ord_main)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1712, 'with compareDate as (select (case TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') >
                                  TO_DATE(to_char(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS''), ''YYYY-MM-DD HH24:MI:SS'')
                                 when true then ''@dieDate_Date''
                                 else to_char(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS'') end) as die_date)
DELETE
FROM pat_exam_main
WHERE is_del = ''0''
  AND exam_status = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND (TO_CHAR(reg_exam_date, ''YYYYMMDD'') > TO_CHAR(TO_DATE((select die_date from compareDate), ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
    OR (TO_CHAR(reg_exam_date, ''YYYYMMDD'') = TO_CHAR(TO_DATE((select die_date from compareDate), ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'') AND
        (select case when count(1) > 0 then false else true end
         FROM ord_main
         WHERE is_del = ''0''
           AND rst_edition = 0
           AND pat_id = @patId
           AND facility_cd = ''@facilityCd''
           AND treat_date = TO_CHAR(TO_DATE((select die_date from compareDate), ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
           and rst_dialysis_state > ''0'')))', 2, '[{}]', '0', '{"applications": [4]}', null, '未来日データを削除する。検査オーダ（pat_exam_main）', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1713, 'with compareDate as (select (case TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') >
                                  TO_DATE(to_char(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS''), ''YYYY-MM-DD HH24:MI:SS'')
                                 when true then ''@dieDate_Date''
                                 else to_char(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS'') end) as die_date)
DELETE
FROM pat_rad_main
WHERE is_del = ''0''
  AND rad_status = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND (TO_CHAR(reg_rad_date, ''YYYYMMDD'') > TO_CHAR(TO_DATE((select die_date from compareDate), ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
    OR (TO_CHAR(reg_rad_date, ''YYYYMMDD'') = TO_CHAR(TO_DATE((select die_date from compareDate), ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'') AND
        (select case when count(1) > 0 then false else true end
         FROM ord_main
         WHERE is_del = ''0''
           AND rst_edition = 0
           AND pat_id = @patId
           AND facility_cd = ''@facilityCd''
           AND treat_date = TO_CHAR(TO_DATE((select die_date from compareDate), ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
           and rst_dialysis_state > ''0'')))', 2, '[{}]', '0', '{"applications": [4]}', null, '未来日データを削除する。一般撮影検査オーダ（pat_rad_main）', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1891, 'with compareDate as (select (case TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') >
                                  TO_DATE(to_char(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS''), ''YYYY-MM-DD HH24:MI:SS'')
                                 when true then ''@dieDate_Date''
                                 else to_char(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS'') end) as die_date)
DELETE 
FROM
  ord_main 
WHERE
  is_del = ''0'' 
  AND rst_edition = 0
  AND rst_treatment_cd is null
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND (treat_date > TO_CHAR(TO_DATE((select die_date from compareDate), ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
    OR (treat_date = TO_CHAR(TO_DATE((select die_date from compareDate), ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'') 
    AND (select case when count(1) > 0 then false else true end
         FROM ord_main
         WHERE is_del = ''0''
           AND rst_edition = 0
           AND pat_id = @patId
           AND facility_cd = ''@facilityCd''
           AND treat_date = TO_CHAR(TO_DATE((select die_date from compareDate), ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
           and rst_dialysis_state > ''0'')))', 2, '[{}]', '0', '{"applications": [4]}', null, '未来日データを削除する。透析予定(ord_main)', '2022-06-20 11:45:57.587', CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1892, 'with compareDate as (select (case TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') >
                                  TO_DATE(to_char(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS''), ''YYYY-MM-DD HH24:MI:SS'')
                                 when true then ''@dieDate_Date''
                                 else to_char(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS'') end) as die_date)
DELETE
FROM pat_exam_main
WHERE is_del = ''0''
  AND exam_status = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND (TO_CHAR(reg_exam_date, ''YYYYMMDD'') > TO_CHAR(TO_DATE((select die_date from compareDate), ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
    OR (TO_CHAR(reg_exam_date, ''YYYYMMDD'') = TO_CHAR(TO_DATE((select die_date from compareDate), ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'') AND
        (select case when count(1) > 0 then false else true end
         FROM ord_main
         WHERE is_del = ''0''
           AND rst_edition = 0
           AND pat_id = @patId
           AND facility_cd = ''@facilityCd''
           AND treat_date = TO_CHAR(TO_DATE((select die_date from compareDate), ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
           and rst_dialysis_state > ''0'')))', 2, '[{}]', '0', '{"applications": [4]}', null, '未来日データを削除する。検査オーダ（pat_exam_main）', '2022-06-20 11:45:57.853', CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1893, 'with compareDate as (select (case TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') >
                                  TO_DATE(to_char(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS''), ''YYYY-MM-DD HH24:MI:SS'')
                                 when true then ''@dieDate_Date''
                                 else to_char(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS'') end) as die_date)
DELETE
FROM pat_rad_main
WHERE is_del = ''0''
  AND rad_status = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND (TO_CHAR(reg_rad_date, ''YYYYMMDD'') > TO_CHAR(TO_DATE((select die_date from compareDate), ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
    OR (TO_CHAR(reg_rad_date, ''YYYYMMDD'') = TO_CHAR(TO_DATE((select die_date from compareDate), ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'') AND
        (select case when count(1) > 0 then false else true end
         FROM ord_main
         WHERE is_del = ''0''
           AND rst_edition = 0
           AND pat_id = @patId
           AND facility_cd = ''@facilityCd''
           AND treat_date = TO_CHAR(TO_DATE((select die_date from compareDate), ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
           and rst_dialysis_state > ''0'')))', 2, '[{}]', '0', '{"applications": [4]}', null, '未来日データを削除する。一般撮影検査オーダ（pat_rad_main）', '2022-06-20 11:45:57.725', CURRENT_TIMESTAMP, null);
