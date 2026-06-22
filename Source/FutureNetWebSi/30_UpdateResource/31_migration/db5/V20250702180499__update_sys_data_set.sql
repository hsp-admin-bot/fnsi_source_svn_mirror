




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
@folderName AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 注射依頼ファイル_ファイル作成終了', '2025-06-26 23:35:08.908', current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
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
@folderName AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 注射依頼ファイル_処置項目', '2025-06-26 23:35:08.908', current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
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
@folderName AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 注射依頼ファイル_実施単位', '2025-06-26 23:35:08.908', current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
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
@folderName AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 注射依頼ファイル_注射ヘッダー', '2025-06-26 23:35:08.908', current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
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
@folderName AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 注射依頼ファイル_オーダーインデックス', '2025-06-26 23:35:08.908', current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
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
@folderName AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 処置依頼ファイル_ファイル作成終了', '2025-06-26 23:35:08.908', current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
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
@folderName AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 処置依頼ファイル_処置項目', '2025-06-26 23:35:08.908', current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
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
@folderName AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 処置依頼ファイル_処置単位', '2025-06-26 23:35:08.908', current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
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
@folderName AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 処置依頼ファイル_処置ヘッダー', '2025-06-26 23:35:08.908', current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
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
@folderName AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 処置依頼ファイル_オーダーインデックス', '2025-06-26 23:35:08.908', current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);


DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1102006;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1100013;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1100010;

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
@folderName AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析指示連携_予約受付のdetail特定', '2025-06-25 16:03:16.883', current_timestamp, '[{"sql_cd": -1100009, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100013, 'WITH forder_name AS (
    SELECT 
        COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS value
    FROM mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info->>''key0'', '''') = @key0
        AND info->>''key1'' = @key1
        AND info->>''key2'' = CASE @fileKind
            WHEN ''treatment'' THEN ''TREAT_FOLDER''
            WHEN ''injection'' THEN ''INJECT_FOLDER''
            WHEN ''schedule'' THEN ''SCHE_FOLDER''
            WHEN ''medical'' THEN ''KARTE_FOLDER''
            ELSE NULL 
        END
)
SELECT value as folder_name
FROM forder_name;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_汎用（連携設定 value取得用）', '2025-07-02 15:36:26.753', current_timestamp, NULL);
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
@folderName AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムのrootからdetail、recordを特定するSQL(カルテ用)', '2025-06-25 16:03:16.883', current_timestamp, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);