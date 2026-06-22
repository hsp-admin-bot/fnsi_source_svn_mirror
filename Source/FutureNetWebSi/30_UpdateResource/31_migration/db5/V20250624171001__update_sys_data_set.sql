delete from "sys_data_set" where sql_cd in (-1102009,-1102006);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102009, 'select 
''カルテ記録_cre'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析指示連携_カルテ記録のdetail特定', '2025-06-23 23:41:19.590', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "generated_filename", "replace_var": "@fileName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102006, 'select  
''予約受付_cre'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析指示連携_予約受付のdetail特定', '2025-06-23 23:41:19.590', CURRENT_TIMESTAMP, '[{"sql_cd": -1100009, "field_name": "filename", "replace_var": "@fileName"}]'::jsonb);