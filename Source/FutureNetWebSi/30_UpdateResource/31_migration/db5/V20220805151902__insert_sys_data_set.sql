DELETE FROM sys_data_set WHERE sql_cd in(7407);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7407, 'SELECT
 COALESCE ( NULLIF ( info ->> ''item_cd'', '''' )) AS item_cd
FROM
	pat_exam_main as pem
	CROSS JOIN LATERAL json_array_elements (pem.exam_result_info :: json ) info 
WHERE
	pat_id = @patId 
	AND facility_cd = @facilityCd
	AND is_del = ''0''
	AND info ->> ''item_cd'' = @examResultInfo.itemCd :: text
	AND reg_exam_date = to_timestamp( @regExamDate_Date, ''yyyy-MM-dd hh24:mi:ss'' )
	union
select ''0'' as item_cd
order by item_cd desc nulls last
limit 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の検査結果(SELECT)',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, NULL);
