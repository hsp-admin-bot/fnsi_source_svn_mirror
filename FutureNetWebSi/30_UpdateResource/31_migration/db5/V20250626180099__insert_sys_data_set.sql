DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1102025;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1102024;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1102023;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1102022;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1102021;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1102020;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1102019;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1102018;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1102017;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1102016;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102025, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 注射依頼ファイル_ファイル作成終了', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102024, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 注射依頼ファイル_処置項目', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102023, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 注射依頼ファイル_実施単位', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102022, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 注射依頼ファイル_注射ヘッダー', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102021, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 注射依頼ファイル_オーダーインデックス', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102020, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 処置依頼ファイル_ファイル作成終了', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102019, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 処置依頼ファイル_処置項目', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102018, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 処置依頼ファイル_処置単位', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102017, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 処置依頼ファイル_処置ヘッダー', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102016, 'select  
''01'' as detail_id,
@facilityCd AS facility_cd,
@ctlNo AS ctl_no,
@key0 AS key0,
@patId AS pat_id,
@ordNo AS ord_no,
@fileName AS file_name,
'''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 処置依頼ファイル_オーダーインデックス', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}]'::jsonb);