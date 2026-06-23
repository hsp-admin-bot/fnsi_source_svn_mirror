DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (-16);
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (-112);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-16, 'select 
  1 AS  ctl_no, 
	diff->>''dial_diff_cd'' as cd
from
	pat_personal_main as ppm,
	json_array_elements (ppm.dial_diff_com_info :: json) diff
where
	diff->>''is_main'' = ''1'' and 
	ppm.pat_id = @patId
UNION
SELECT
 2 AS  ctl_no, 
	''-1'' AS cd
	ORDER BY ctl_no ASC
	LIMIT 1', 3, '[{}]', '0', '{"applications": [4]}', NULL, '主たる透析困難コメントコード', '2020-04-10 14:35:26.747', CURRENT_TIMESTAMP, NULL);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-112, 'select case  when @code = 1 THEN @userId ELSE (select disp_user_id AS disp_user_id
FROM 
    mst_user_authentication 
WHERE 
    user_id::TEXT = @userId
		and @code = 0
		) END;', 1, '[]', '0', '{"applications": [4]}', '{"classes": []}', NULL, '2022-06-11 14:01:34', CURRENT_TIMESTAMP, '[{"sql_cd": -109, "field_name": "staff_cd", "replace_var": "@userId"}, {"sql_cd": -109, "field_name": "code", "replace_var": "@code"}]');


