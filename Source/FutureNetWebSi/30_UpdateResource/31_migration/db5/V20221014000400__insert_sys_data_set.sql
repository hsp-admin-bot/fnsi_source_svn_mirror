DELETE  FROM "ntss"."sys_data_set" WHERE sql_cd IN (-79);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-79, 'WITH  dial_diff_cd_info AS(
SELECT order_no,cd FROM(
select 
  1 AS order_no,
	diff->>''dial_diff_cd'' as cd
from
	pat_personal_main as ppm,
	json_array_elements (ppm.dial_diff_com_info :: json) diff
where
	ppm.pat_id = @patId
	AND diff->>''is_main''= ''1''
	AND diff->>''is_dial_diff''= ''1''
UNION
select 
  2 AS order_no,
	diff->>''dial_diff_cd'' as cd
from
	pat_personal_main as ppm,
	json_array_elements (ppm.dial_diff_com_info :: json) diff
where
	ppm.pat_id = @patId
	AND diff->>''is_main''<> ''1''
	AND diff->>''is_dial_diff''= ''1''
	) as T 
	ORDER BY order_no

)
SELECT  string_agg(cd, '','')  AS dial_diff_cd FROM dial_diff_cd_info ', 3, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'GX連携 rst_dial連携で送信する項目情報部 障害者加算', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
