INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-70, 'SELECT
  rst_start_date AS start_date,
  COALESCE(TO_CHAR( rst_start_date, ''YYYYMMDDHH24MISS'' ), '''') AS start_date14,
  rst_end_date AS end_date,
  COALESCE(TO_CHAR( rst_end_date, ''YYYYMMDDHH24MISS'' ), '''') AS end_date14,
  rst_in_out_class AS in_out_class,
  COALESCE(( CASE rst_in_out_class WHEN ''0'' THEN ''外来'' WHEN ''1'' THEN ''入院'' ELSE NULL END ), '''') AS in_out_name,
  COALESCE(( CASE rst_in_out_class WHEN ''0'' THEN ''1'' WHEN ''1'' THEN ''2'' ELSE NULL END ), '''') AS in_out_f,
  COALESCE(( CASE rst_in_out_class WHEN ''0'' THEN ''1'' WHEN ''1'' THEN ''3'' ELSE NULL END ), '''') AS in_out_s
FROM
    ord_main_restore
WHERE
  ord_no =  @ordNo
AND
	facility_cd = @facilityCd 
AND 
	up_date IS NOT NULL
ORDER BY
  up_date DESC LIMIT 1', 2, '[]', '0', '{"applications": [4]}', NULL, '削除してデータを取得する', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
