DELETE FROM "ntss"."sys_data_set" where "sql_cd" = -99993;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-99993, 'SELECT
  ''PatientRequest_'' || 
  TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDDHH24MISSMS_'') ||
  CASE WHEN LENGTH(journal.hosp_pat_id) >= 12 THEN journal.hosp_pat_id ELSE LPAD(journal.hosp_pat_id, 12, ''0'') END ||
  ''.xml'' AS filename
  , CASE WHEN LENGTH(journal.hosp_pat_id) >= 12 THEN journal.hosp_pat_id ELSE LPAD(journal.hosp_pat_id, 12, ''0'') END AS hosp_pat_id
FROM
  sys_coop_journal AS journal 
WHERE
  journal.ctl_no = @ctlNo', 2, '[]', '0', '{"applications": [4]}', NULL, '日機装 患者情報（XML）[送信]ファイル名取得', '2021-04-20 09:19:08.001', CURRENT_TIMESTAMP, NULL);
