DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307079;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307079, 'select
  coalesce((
    select personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
    from mst_personal_user
    where user_id = cast(nullif(@staffCd, '''') as int)
  ), '''') as user_name', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '担当スタッフ情報取得用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307078, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);