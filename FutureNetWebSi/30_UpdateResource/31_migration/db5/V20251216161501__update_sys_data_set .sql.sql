INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1103023, '-- SQL: -1103023 begin
WITH memo AS (
    SELECT
        split_part(save_2 ->> ''memo'', ''#'', 3) AS memo
    FROM
        pat_coop_detail AS detail
    WHERE
        facility_cd = @facilityCd
        AND pat_id = @patId
        AND (save_2 ->> ''ord_no'')::integer = @ordNo
        AND (save_2 ->> ''coop_cd'') = @coopCd
    ORDER BY
        up_date DESC
    LIMIT 1
)
SELECT 
    TO_CHAR(
        TO_DATE(
            split_part(memo, ''|'', 2),
            ''YYYYMMDD''
        ), ''YYYY-MM-DD''
    ) AS send_day,
    TO_CHAR(
        TO_TIMESTAMP(
            split_part(memo, ''|'', 3),
            ''HH24MISS''
        ) + make_interval(secs => (@rpNo::integer - 1))
        , ''HH24:MI:SS''
    ) AS seq_no
FROM
    memo
-- SQL: -1103023 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携_注射実績 送信履歴メモから発生日/SEQ番号の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
