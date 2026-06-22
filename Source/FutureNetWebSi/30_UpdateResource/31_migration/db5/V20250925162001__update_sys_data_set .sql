DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-1106002);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1106002, 'select
  case @crud
    when ''del'' then
      case @dumpResult
        when ''1'' then ''01''
        else ''02''
      end
    else ''01''
  end as detail_id,
  @facilityCd AS facility_cd,
  @ctlNo AS ctl_no,
  @key0 AS key0,
  @patId AS pat_id,
  @ordNo AS ord_no,
  @fileName AS file_name,
  '''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの放射線オーダー_処方ヘッダーのdetail特定', '2025-06-25 16:30:15.736', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]'::jsonb);
