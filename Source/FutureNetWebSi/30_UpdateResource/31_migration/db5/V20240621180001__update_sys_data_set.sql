DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-99991)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-99991, 'SELECT
  ''DIAJSK-'' || 
  TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDDHH24MISSMS'') ||
  ''.dat'' AS filename
FROM
  sys_coop_journal AS journal 
WHERE
  journal.ctl_no = @ctlNo', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '日機装 透析実績[送信]ファイル名取得(標準)', '2021-04-20 09:19:08.001', CURRENT_TIMESTAMP, NULL);
