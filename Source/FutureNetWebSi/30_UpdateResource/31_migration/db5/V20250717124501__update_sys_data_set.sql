DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-1107007);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1107007, 'SELECT
  RIGHT(
    CASE
      WHEN COALESCE(@defaultDoctorFlag, ''0'') = ''1''
        THEN NULLIF(@staffCd, '''')
      ELSE COALESCE(
             (
               SELECT disp_user_id
               FROM   mst_user_authentication
               WHERE  user_id     = NULLIF(@staffCd, '''')::INT
                 AND  facility_cd = @facilityCd
               LIMIT 1
             ),
             ''''
           )
    END,
    6
  ) AS disp_user_id;
', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム　指示変更履歴　ユーザID取得', '2025-06-22 20:19:53.113', '2025-06-22 20:19:53.113', '[{"sql_cd": -1107000, "field_name": "user_id", "replace_var": "@staffCd"}, {"sql_cd": -1107000, "field_name": "default_doctor_flag", "replace_var": "@defaultDoctorFlag"}]'::jsonb);