delete from ntss.sys_data_set where sql_cd = '1601';
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1601, e'SELECT pu.pat_id,
       medical_hst_info,
       in_out_visit_history_info,
       physical_info,
       is_del,
       up_date,
       reg_date,
       facility_cd,
       old_up_date_unique
FROM pat_unique pu
WHERE pu.pat_id = @patId
  AND is_del = \'0\'', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)富士通の患者プロファイル_固有情報取得', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": 1604, "field_name": "pat_id", "replace_var": "@pat_id"}]');
