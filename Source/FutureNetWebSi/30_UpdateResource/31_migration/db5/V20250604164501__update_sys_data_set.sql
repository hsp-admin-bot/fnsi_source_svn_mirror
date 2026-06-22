DELETE FROM sys_data_set WHERE sql_cd IN 
(-1201020);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1201020, 'SELECT
  ''DIAJSK-'' || 
  coalesce(journal.coop_ord_no, '''')  ||
  ''-'' ||
  TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDDHH24MISS'') ||
  ''.dat'' AS filename
FROM
  sys_coop_journal AS journal 
WHERE
  journal.ctl_no = @ctlNo', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_透析実績[送信]ファイル名取得', '2025-05-30 16:50:14.617', CURRENT_TIMESTAMP, NULL);

