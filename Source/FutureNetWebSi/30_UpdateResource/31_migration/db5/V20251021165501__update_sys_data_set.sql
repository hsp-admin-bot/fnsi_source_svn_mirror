DELETE FROM sys_data_set
WHERE sql_cd IN (-426);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-426, 'WITH pre_ord AS (
    SELECT
        to_number(rst_weight_info->>''weight_after'', ''999.99'') AS pre_weight_after
    FROM
        ord_main
    WHERE
        ord_main.pat_id = @patId
        AND rst_dialysis_state >= ''5''
        AND ord_main.ord_no <> @ordNo
        AND rst_start_date < (SELECT rst_start_date FROM ord_main WHERE ord_no = @ordNo AND is_del = ''0'')
        AND is_del = ''0''
    ORDER BY
        rst_start_date DESC
    LIMIT 1
)
SELECT
    ''体重管理'' AS detail_id,
    trim(to_char(to_number(ord.rst_weight_info->>''weight_before'', ''999.99''), ''990.99'')) AS e01,
    trim(to_char(to_number(ord.rst_weight_info->>''weight_after'', ''999.99''), ''990.99'')) AS e02,
    ord.rst_dw AS e03,
    trim(to_char(COALESCE(pre_weight_after, ''0''), ''990.99'')) AS e04,
    trim(to_char(to_number(COALESCE(ord.rst_cond_info->''3''->>''value'', ''0''), ''999.99''), ''990.99'')) AS e05,
    trim(to_char(to_number(ord.rst_weight_info->>''weight_before'', ''999.99'')-to_number(ord.rst_weight_info->>''weight_after'', ''999.99''), ''990.99'')) AS e06,
    CASE
        WHEN pre_weight_after IS NULL THEN ''''
        ELSE trim(to_char(to_number(ord.rst_weight_info->>''weight_before'', ''999.99'')- pre_weight_after, ''990.99''))
    END AS e07
FROM
    ord_main AS ord
LEFT JOIN pre_ord ON
    TRUE
WHERE
    ord.ord_no = @ordNo
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom)経過情報（体重管理）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);