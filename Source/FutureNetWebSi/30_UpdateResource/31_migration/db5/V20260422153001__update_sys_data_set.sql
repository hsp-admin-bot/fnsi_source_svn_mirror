DELETE FROM ntss.sys_data_set
WHERE sql_cd=-607002;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-607002, 'SELECT
  personal_info_decrypt(job_cd) as job_cd
  FROM mst_personal_user
  WHERE user_id = @userId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'MIRAIs_rst_dial_医師フラグ取得事前SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -610901, "field_name": "user_id", "replace_var": "@userId"}]'::jsonb);