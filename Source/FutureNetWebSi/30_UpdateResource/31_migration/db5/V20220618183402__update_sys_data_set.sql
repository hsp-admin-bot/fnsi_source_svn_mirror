DELETE FROM "ntss"."sys_data_set" where "sql_cd" IN (7108);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7108, 'UPDATE pat_personal_main ppm1
 SET
  in_out_class = 2
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND	is_del = ''0''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の修正', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 7106, "field_name": "is_main", "replace_var": "@is_main"}, {"sql_cd": 7104, "field_name": "dialysis_difficulty_cd", "replace_var": "@dialysis_difficulty_cd"}]');
