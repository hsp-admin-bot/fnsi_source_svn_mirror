DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307077;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307079;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307077, 'SELECT
    COALESCE(
        (SELECT disp_user_id
         FROM mst_user_authentication
         WHERE user_id::text = @staffCd
         LIMIT 1),
        ''''
    ) AS disp_user_id;', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '担当スタッフ情報取得用', '2025-04-21 13:31:56.626', current_timestamp, '[{"sql_cd": -307078, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307079, 'SELECT
    COALESCE(
        (
            SELECT 
                personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
            FROM 
                mst_personal_user
            WHERE 
                user_id::text = @staffCd
            LIMIT 1
        ),
        ''''
    ) AS user_name;
', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '担当スタッフ情報取得用', '2025-04-21 13:31:56.626', current_timestamp, '[{"sql_cd": -307078, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);