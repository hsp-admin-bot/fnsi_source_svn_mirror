DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1102027;

DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1100013;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100013, 'WITH forder_name AS (
    SELECT 
        COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS value
    FROM mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info->>''key0'', '''') = @key0
        AND info->>''key1'' = @key1
        AND info->>''key2'' = CASE @fileKind
            WHEN ''treatment'' THEN ''TREAT_FOLDER''
            WHEN ''injection'' THEN ''INJECT_FOLDER''
            WHEN ''schedule'' THEN ''SCHE_FOLDER''
            WHEN ''medical'' THEN ''KARTE_FOLDER''
            ELSE NULL 
        END
)
SELECT COALESCE(
  (SELECT value FROM forder_name LIMIT 1),
  ''''
) AS folder_name;
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_汎用（連携設定 フォルダ名取得用）', '2025-07-02 15:36:26.753', current_timestamp, NULL);