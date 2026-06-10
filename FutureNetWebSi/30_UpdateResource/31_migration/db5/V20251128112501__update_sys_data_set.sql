DELETE FROM ntss.sys_data_set
WHERE sql_cd=-600401;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600401, 'SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') as patid_patidfig
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        1 = 1
        AND is_del = ''0''
        AND facility_cd = @facilityCd
        AND info->>''key0'' = @key0
        AND info->>''key1'' = ''NEC''
        AND info->>''key2'' = ''PATID_PATIDFIG''
        AND (info->>''value'' IS NOT NULL OR info->>''default_v'' IS NOT NULL)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '汎用）患者ID桁数設定値取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
