DELETE FROM "ntss"."sys_data_set" where "sql_cd" IN (-99992);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-99992, 'SELECT
  ''DIASCH-'' || 
  coop_ord_no || ''-'' ||
  TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDDHH24MISS'') ||
  ''.dat'' AS filename
FROM
  sys_coop_journal AS journal 
WHERE
  journal.ctl_no = @ctlNo', 2, '[]', '0', '{"applications": [4]}', NULL, '日機装 透析予約[送信]ファイル名取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
