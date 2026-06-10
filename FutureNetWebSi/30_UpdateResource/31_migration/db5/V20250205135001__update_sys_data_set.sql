DELETE FROM sys_data_set WHERE sql_cd IN (-600119);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600119, '-- 渡された値が空かYYYYMMDD形式の日付の場合に結果を返す
SELECT
        1
WHERE
     CASE 
       WHEN NULLIF(@dateCheck,'''') IS NULL THEN true
       WHEN @dateCheck ~ ''^(19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])$'' 
            AND (
                 (@dateCheck ~ ''^(19|20)\d{2}02(29)$'' AND SUBSTRING(@dateCheck, 1, 4)::int % 4 = 0 AND (SUBSTRING(@dateCheck, 1, 4)::int % 100 != 0 OR SUBSTRING(@dateCheck, 1, 4)::int % 400 = 0))
                 OR (@dateCheck ~ ''^(19|20)\d{2}(0[13578]|1[02])(0[1-9]|[12]\d|3[01])$'')
                 OR (@dateCheck ~ ''^(19|20)\d{2}(0[469]|11)(0[1-9]|[12]\d|30)$'')
                 OR (@dateCheck ~ ''^(19|20)\d{2}02(0[1-9]|1\d|2[0-8])$'')
            )
       THEN true
       ELSE false
     END;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC標準(MegaOakHR) 日付チェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
