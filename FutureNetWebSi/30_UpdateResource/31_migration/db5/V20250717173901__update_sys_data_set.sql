DELETE FROM ntss.sys_data_set
WHERE sql_cd = -1100006;

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100006, 'WITH coop_ini_info AS (
    -- 連携設定取得(pre_sqlにて取得)
    SELECT coop_info->>''key1'' AS key1,
        coop_info->>''key2'' AS key2,
        coop_info->>''value'' AS value
    FROM json_array_elements(@coopIniInfo::json) coop_info
)
, converted_in_out_class AS (
    -- in_out_class変換値の取得（なければ''1''をデフォルトにする）
    SELECT ppm.pat_id,
        ppm.hosp_pat_id,
        ppm.in_out_class,
        COALESCE((  
            SELECT value
            FROM coop_ini_info
            WHERE key1 = ''CONV_INOUT_TO_KARTE''
                AND key2 = CASE
                    WHEN ppm.in_out_class::text = ''3'' THEN ''0''
                    ELSE ppm.in_out_class::text
                END
            LIMIT 1
        ), ''1'') AS converted_in_out_class
    FROM pat_personal_main ppm
    WHERE ppm.pat_id = @patId
        AND ppm.is_del = ''0''
)
, ini_value AS (
    -- 患者ID桁数の取得
    SELECT (
            SELECT CASE 
            WHEN value::int > 12 THEN ''12''
            ELSE value
            END
            FROM coop_ini_info
            WHERE key1 = ''SCM_COMMON''
                AND key2 = ''PATID_LEN''
            LIMIT 1
        ) AS patid_len
)
SELECT LPAD(
    RIGHT(converted.hosp_pat_id::text, ini_value.patid_len::integer),
    ini_value.patid_len::integer,''0'') AS hosp_pat_id,
    converted.converted_in_out_class AS in_out_class
FROM converted_in_out_class converted
    CROSS JOIN ini_value;', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_汎用（表示用患者ID、患者個人情報.入外区分取得）', '2025-05-27 13:22:20.351', CURRENT_TIMESTAMP, '[{"sql_cd": -1100005, "field_name": "coop_ini_info", "replace_var": "@coopIniInfo"}]'::jsonb);