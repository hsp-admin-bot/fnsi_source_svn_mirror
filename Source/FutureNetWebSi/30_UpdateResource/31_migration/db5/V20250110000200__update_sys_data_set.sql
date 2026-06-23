DELETE FROM "ntss"."sys_data_set" where sql_cd in (223);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (223, 'SELECT  
	ord_prescription_no
FROM 
	ord_prescription AS op
WHERE    
	op.pat_id = @patId 
AND 
	op.is_del = ''0'' 
AND 
	issue_date between 
							TO_CHAR(DATE_TRUNC(''day'', (CAST(@fromDate AS TIMESTAMP) - INTERVAL ''1 year'')), ''yyyymmdd'')
						 AND 
						  TO_CHAR(DATE_TRUNC(''day'', CAST(@fromDate AS TIMESTAMP)), ''yyyymmdd'')
and op.prescription_type in (@prescriptionClassList)
ORDER BY 
	op.issue_date DESC, ord_prescription_no DESC
LIMIT 1', 2, '[]', '0', '{"applications": [1]}', '{"classes": [1, 2, 9]}', '処方(最新)：@patId  @fromDate  使用', '2024-05-07 11:53:11.892', CURRENT_TIMESTAMP, NULL);


