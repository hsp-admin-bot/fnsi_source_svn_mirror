DELETE FROM sys_data_set WHERE sql_cd IN (-1101508);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1101508, 'SELECT
    1
WHERE
    @content::numeric BETWEEN @min::numeric AND @max::numeric;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者プロファイル　身長有効範囲チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);