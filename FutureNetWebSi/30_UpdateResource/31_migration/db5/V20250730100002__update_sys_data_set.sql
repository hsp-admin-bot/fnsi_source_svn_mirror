DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (
  -1103004,
  -1103005,
  -1103006,
  -1103007,
  -1103008,
  -1103009,
  -1103010,
  -1103011,
  -1103012
);

INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103004, '-- SQL: -1103004 begin
-- これはdummyのSQLです。(SQL作成完了後、このコメントは削除してください)
select  
    ''01'' as detail_id,
    generate_series(1, 5) as rp_no;
-- SQL: -1103004 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 注射実績ファイル_RP番号', '2025-07-16 14:50:48.578', current_timestamp, NULL);

INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103005, '-- SQL: -1103005 begin
select  
''01'' as detail_id,
@fileName AS file_name,
@folderName AS folder_name
-- SQL: -1103005 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 処置実績ファイル_オーダーインデックス', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103006, '-- SQL: -1103006 begin
select  
''01'' as detail_id,
@fileName AS file_name,
@folderName AS folder_name
-- SQL: -1103006 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 処置実績ファイル_処置ヘッダー', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103007, '-- SQL: -1103007 begin
select  
''01'' as detail_id,
@fileName AS file_name,
@folderName AS folder_name
-- SQL: -1103007 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 処置実績ファイル_処置単位', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103008, '-- SQL: -1103008 begin
select  
''01'' as detail_id,
@fileName AS file_name,
@folderName AS folder_name
-- SQL: -1103008 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 処置実績ファイル_処置項目', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103009, '-- SQL: -1103009 begin
select  
''01'' as detail_id,
@fileName AS file_name,
@folderName AS folder_name
-- SQL: -1103009 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 処置実績ファイル_ファイル作成終了', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103010, '-- SQL: -1103010 begin
select  
''01'' as detail_id,
@fileName AS file_name,
@folderName AS folder_name,
@rpNo AS rp_no
-- SQL: -1103010 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 注射実績ファイル_オーダーインデックス', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103011, '-- SQL: -1103011 begin
select  
''01'' as detail_id,
@fileName AS file_name,
@folderName AS folder_name,
@rpNo AS rp_no
-- SQL: -1103011 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 注射実績ファイル_処置項目', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103012, '-- SQL: -1103012 begin
select  
''01'' as detail_id,
@fileName AS file_name,
@folderName AS folder_name
-- SQL: -1103012 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 注射実績ファイル_ファイル作成終了', current_timestamp, current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);