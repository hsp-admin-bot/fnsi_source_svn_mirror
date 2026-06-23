DELETE FROM sys_data_set
WHERE sql_cd IN (-317142);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317142, 'WITH ini_info AS(
  SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL jsonb_array_elements(ini.coop_ini_info) info
WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''is_effect'' = ''1''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''KARTE_ORD_SEND''
    AND info ->> ''key2'' = ''ADMISSION_SUPPORTED''
)
SELECT
    CASE
        WHEN (SELECT value FROM ini_info) = ''1'' THEN rst_in_out_class
        ELSE NULL
    END in_out_class
FROM
    ord_main
WHERE
    facility_cd = @facilityCd
    AND ord_no = @ordNo;', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携 入外フラグ', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);