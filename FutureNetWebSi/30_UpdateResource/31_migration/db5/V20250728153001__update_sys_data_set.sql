DELETE FROM sys_data_set
WHERE sql_cd IN (-310009);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310009, 'WITH disp_user AS (
    SELECT
        disp_user_id
    FROM
        mst_user_authentication
    WHERE
        user_id = @staffCd
)
SELECT
    CASE
        @isConv WHEN 1 THEN (
            SELECT
                disp_user_id
            FROM
                disp_user
        )
        ELSE @staffCd::text
    END AS staff_cd', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom検査オーダ担当医取得SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, '[{"sql_cd": -310008, "field_name": "staff_cd", "replace_var": "@staffCd"}, {"sql_cd": -310008, "field_name": "is_conv", "replace_var": "@isConv"}]'::jsonb);