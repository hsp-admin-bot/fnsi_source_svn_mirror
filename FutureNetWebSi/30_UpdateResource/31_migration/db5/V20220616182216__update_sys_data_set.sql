delete from ntss.sys_data_set where sql_cd in ('-99992');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-99992, 'SELECT
  ''DIASCH-'' || 
  RIGHT(ordCoopNo.coop_ord_no,8)   || ''-'' ||
  TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDDHH24MISS'') ||
  ''.dat'' AS filename
FROM
  ord_coop_no AS ordCoopNo ,sys_coop_journal AS journal 
WHERE
  ordCoopNo.ord_no = journal.ord_no and 
  journal.ctl_no =  @ctlNo;', 2, '[]', '0', '{"applications": [4]}', NULL, '日機装 透析予約[送信]ファイル名取得', '2022-05-02 13:29:17.807', current_timestamp, NULL);
