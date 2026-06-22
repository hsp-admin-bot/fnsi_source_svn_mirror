delete from "sys_data_set" where sql_cd in (-1100010,-1100011,-1102006,-1102007,-1102008,-1102009);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102006, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析指示連携_予約受付のdetail特定', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100009, "field_name": "filename", "replace_var": "@fileName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100011, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムのrootからdetail、recordを特定するSQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100007, "field_name": "filename", "replace_var": "@fileName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100010, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムのrootからdetail、recordを特定するSQL(カルテ用)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}]'::jsonb);