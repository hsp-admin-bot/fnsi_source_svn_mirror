delete from ntss.sys_data_set where sql_cd = '-68';
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (-68, 'select (case
            when @userId::text ~ ''^([0-9]?[0-9]*|[0-9]+)$'' then (SELECT disp_user_id AS disp_user_id
                                                             FROM mst_user_authentication
                                                             WHERE user_id::text = @userId::text)
            else @userId::text end) as disp_user_id', 1, '[{}]', '0', '{"applications": [4]}', null, '富士通）透析レポート：施設内職員ID取得', '2022-08-25 06:50:20.979', CURRENT_TIMESTAMP, '[{"sql_cd": -61, "field_name": "staff_cd_comm", "replace_var": "@userId"}]');
