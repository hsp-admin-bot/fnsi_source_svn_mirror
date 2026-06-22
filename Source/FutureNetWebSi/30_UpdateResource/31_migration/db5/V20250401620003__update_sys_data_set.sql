DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-317019);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317019, '
WITH send_change_flag_info AS (
    SELECT
        UNNEST(string_to_array(COALESCE(
                    NULLIF(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) AS SEND_CHANGE_FLAG
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(
                ini.coop_ini_info::json
            ) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''ELAPSED_INFO''
    AND info ->> ''key2'' = ''SEND_CHANGE_FLAG''
)
SELECT
    CASE SEND_CHANGE_FLAG
        WHEN ''0'' THEN null
        WHEN ''1'' THEN ''1''
    END
FROM
    send_change_flag_info', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携修正連携スキップ用SQL', '2023-11-21 23:54:57.716', '2023-11-21 23:54:57.716', NULL);
