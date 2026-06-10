DELETE FROM "ntss"."sys_data_set" where "sql_cd" IN (7109,7110);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7109, 'UPDATE pat_personal_main ppm1
 SET
  dial_diff_com_info = 
	CASE
    ''@dialDiffComInfo.dialDiffCd'' 
    WHEN '''' THEN
    ''@dialDiffComInfoValue''
ELSE	jsonb_set(dial_diff_com_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_personal_main ppm2, jsonb_array_elements(dial_diff_com_info) WITH

ORDINALITY WHERE ppm1.pat_id = ppm2.pat_id AND value->>''dial_diff_cd'' = ''@dial_diff_cd'')::text, ''reg_date''::text], ''"@dialDiffComInfo.regDate"'') 
 END
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND	is_del = ''0''
	AND @dial_diff_cd != ''0''
	AND ''@dialDiffComInfo.regDate'' != ''''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の修正',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, '[{"sql_cd": 7110, "field_name": "dial_diff_cd", "replace_var": "@dial_diff_cd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7110, 'select
COALESCE ( NULLIF ( info ->> ''dial_diff_cd'', '''' )) AS dial_diff_cd 
from
pat_personal_main AS ppm
 CROSS JOIN LATERAL json_array_elements ( ppm.dial_diff_com_info :: json ) info 
where
     facility_cd = @facilityCd
AND  pat_id = @patId 
AND is_del = ''0''
AND info ->> ''is_dial_diff'' = ''0''
AND  info ->> ''dial_diff_cd'' = @dialysis_difficulty_cd :: text
union
select ''0'' as dial_diff_cd
order by dial_diff_cd desc nulls last
limit 1', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の取得', CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, '[{"sql_cd": 7104, "field_name": "dialysis_difficulty_cd_no", "replace_var": "@dialysis_difficulty_cd"}]');

