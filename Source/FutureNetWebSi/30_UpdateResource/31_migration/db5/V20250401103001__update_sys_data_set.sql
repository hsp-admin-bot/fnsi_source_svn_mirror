DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-309001, -309002);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-309001, 'SELECT
	1
WHERE
	@regExamDate_Date = ''''', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)Medicomの検査結果', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-309002, 'WITH center_codes AS (
    SELECT
        UNNEST(
            STRING_TO_ARRAY(
                COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v''),
                '',''
            )
        ) AS val
    FROM
        mst_coop_ini AS ini
    CROSS JOIN
    LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND is_disp = ''1''
        AND info ->> ''key0'' = @key0
        AND info ->> ''key1'' = ''SNY_EXAM_ORDER_INFO''
        AND info ->> ''key2'' = ''CENTER_CODE''
)
SELECT
    1
FROM
    center_codes
WHERE
    TRIM(BOTH '' 　'' FROM val) = @centerCode;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)Medicomの検査結果 センターコードチェック', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);