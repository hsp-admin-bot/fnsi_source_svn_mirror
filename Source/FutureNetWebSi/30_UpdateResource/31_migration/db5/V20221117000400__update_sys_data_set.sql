delete from ntss.sys_data_set where sql_cd in (-112,-2201);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2201, 'SELECT COALESCE
           (NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS header_mode
FROM mst_coop_ini AS ini
         CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
WHERE facility_cd = @facilityCd

  AND is_del = ''0''
  AND info ->> ''key1'' = ''DIALYSISSEND''
  AND info ->> ''key2'' = ''HEADER_MODE''', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', NULL, '2022-06-11 14:01:34', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-112, 'SELECT CASE
           WHEN @header_mode = 1 THEN
               (SELECT CASE
                           WHEN @code = 1 THEN @userId
                           ELSE (SELECT disp_user_id AS user_id
                                 FROM mst_user_authentication
                                 WHERE user_id::TEXT = @userId
                                   and @code = 0
                           ) END)
           ELSE ''          '' END AS user_id;', 1, '[]', '0', '{"applications": [4]}', '{"classes": []}', NULL, '2022-06-11 14:01:34', CURRENT_TIMESTAMP, '[{"sql_cd": -109, "field_name": "staff_cd", "replace_var": "@userId"}, {"sql_cd": -109, "field_name": "code", "replace_var": "@code"}, {"sql_cd": -2201, "field_name": "header_mode", "replace_var": "@header_mode"}]');
