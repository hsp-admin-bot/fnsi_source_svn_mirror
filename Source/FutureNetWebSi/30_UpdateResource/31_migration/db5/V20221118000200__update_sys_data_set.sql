delete from ntss.sys_data_set where sql_cd in (1709, 1710);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1709, 'with state as (select (case when count(1) > 0 then false else true end) as checkStatue
         FROM ord_main
         WHERE is_del = ''0''
           AND rst_edition = 0
           AND pat_id = @patId
           AND facility_cd = ''@facilityCd''
           AND treat_date = TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
           and rst_dialysis_state > ''0'')
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
     state
WHERE is_del = ''0''
  AND exam_status = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND (TO_CHAR(reg_exam_date, ''YYYYMMDD'') > TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
    OR (TO_CHAR(reg_exam_date, ''YYYYMMDD'') = TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'') AND
        state.checkStatue))', 2, '[{}]', '0', '{"applications": [4]}', null, '未来日データをコピーする。検査オーダ（pat_exam_main） → pat_exam_main_hst', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1710, 'with state as (select (case when count(1) > 0 then false else true end) as checkStatue
         FROM ord_main
         WHERE is_del = ''0''
           AND rst_edition = 0
           AND pat_id = @patId
           AND facility_cd = ''@facilityCd''
           AND treat_date = TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
           and rst_dialysis_state > ''0'')
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
     state
WHERE is_del = ''0''
  AND rad_status = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND (TO_CHAR(reg_rad_date, ''YYYYMMDD'') > TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')
    OR (TO_CHAR(reg_rad_date, ''YYYYMMDD'') = TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'') AND
        state.checkStatue))', 2, '[{}]', '0', '{"applications": [4]}', null, '未来日データをコピーする。一般撮影検査オーダ（pat_rad_main） → pat_rad_main_hst', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, null);
