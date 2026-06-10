DELETE FROM sys_data_set
WHERE sql_cd = -99992;

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-99992, 'SELECT
  ''DIASCH-'' || 
  RIGHT(journal.coop_ord_no,8)   || ''-'' ||
  TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDDHH24MISS'') ||
  ''.dat'' AS filename
FROM
  sys_coop_journal AS journal 
WHERE
  journal.ctl_no =  @ctlNo
  AND journal.facility_cd = @facilityCd
;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '日機装 透析予約[送信]ファイル名取得', '2022-05-02 13:29:17.807', CURRENT_TIMESTAMP, NULL);