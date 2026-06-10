DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-1105009, -1105008, -1106001);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1105009, 'select  
  CASE @crud
    WHEN ''del'' THEN
      CASE @dumpResult
        WHEN ''1'' THEN ''01''
        ELSE ''02''
      END
    ELSE ''01''
  END AS detail_id,
  @facilityCd AS facility_cd,
  @ctlNo AS ctl_no,
  @key0 AS key0,
  @patId AS pat_id,
  @ordNo AS ord_no,
  @fileName AS file_name,
  '''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの検体検査_検体検査出力', '2025-07-10 11:28:37.471', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}]'::jsonb);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1105008, 'select  
  CASE @crud
    WHEN ''del'' THEN
      CASE @dumpResult
        WHEN ''1'' THEN ''01''
        ELSE ''02''
      END
    ELSE ''01''
  END AS detail_id,
  @facilityCd AS facility_cd,
  @ctlNo AS ctl_no,
  @key0 AS key0,
  @patId AS pat_id,
  @ordNo AS ord_no,
  @fileName AS file_name,
  '''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの検体検査_オーダーインデックス出力', '2025-07-10 11:28:37.471', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}]'::jsonb);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1106001, 'select  
  CASE @crud
    WHEN ''del'' THEN
      CASE @dumpResult
        WHEN ''1'' THEN ''01''
        ELSE ''02''
      END
    ELSE ''01''
  END AS detail_id,
  @facilityCd AS facility_cd,
  @ctlNo AS ctl_no,
  @key0 AS key0,
  @patId AS pat_id,
  @ordNo AS ord_no,
  @fileName AS file_name,
  '''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの放射線オーダー_オーダーインデックスのdetail特定', '2025-06-25 16:30:15.736', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);