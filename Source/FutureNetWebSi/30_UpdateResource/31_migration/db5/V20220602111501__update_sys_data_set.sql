DELETE FROM sys_data_set WHERE sql_cd = -106;

INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-106, 'SELECT
CASE
	
WHEN
	rst_in_out_class = 0 THEN
	2 
WHEN rst_in_out_class = 1 THEN
1 
END AS in_out_class 
FROM
	ord_main 
WHERE
ord_no = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', '{"classes": []}', '透析実績：入外区分取得', '2022-06-02 11:22:26', CURRENT_TIMESTAMP, NULL);
