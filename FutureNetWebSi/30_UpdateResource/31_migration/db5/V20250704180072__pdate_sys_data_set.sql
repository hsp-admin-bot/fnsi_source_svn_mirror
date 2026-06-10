DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-1202009,-1202010);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1202009, 'WITH replacement_info_byte AS (
    -- 置換バイト位置
    SELECT coalesce(nullif(info->>''value'', ''''), info->>''default_v'') AS value
    FROM mst_coop_ini AS ini
        CROSS JOIN lateral json_array_elements(ini.coop_ini_info::json) info
    WHERE facility_cd = @facilityCd
        AND is_del = ''0''
        AND coalesce(info->>''key0'', '''') = @key0
        AND info->>''key1'' = ''REPLACEMENT_INFO''
        AND info->>''key2'' = ''BYTE''
),
replacement_info_key AS (
    -- 置換値
    SELECT coalesce(nullif(info->>''value'', ''''), info->>''default_v'') AS value
    FROM mst_coop_ini AS ini
        CROSS JOIN lateral json_array_elements(ini.coop_ini_info::json) info
    WHERE facility_cd = @facilityCd
        AND is_del = ''0''
        AND coalesce(info->>''key0'', '''') = @key0
        AND info->>''key1'' = ''REPLACEMENT_INFO''
        AND info->>''key2'' = ''KEY''
)
SELECT
    convert_from(substring(overlay(scj.dump placing (SELECT value ::bytea FROM replacement_info_key) FROM (SELECT value ::int FROM replacement_info_byte)) FROM 1 FOR 258), ''shift-jis'') AS value
FROM sys_coop_journal AS scj
WHERE
    pat_id = @patId
    AND facility_cd = @facilityCd
    AND crud IN (''C'',''U'')
    AND ord_no = @ordNo
    AND coop_cd = ''exam_ord''
    AND key0 = @key0
    AND coop_result IN (''9'',''8'',''1'',''0'')
    ORDER BY scj.up_date DESC
LIMIT 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_血液検査依頼削除レイアウト用データ取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1202010, 'WITH dump_data AS (
    SELECT
        scj.dump AS dump
        , octet_length(scj.dump) / 258 AS quotient
    FROM sys_coop_journal AS scj
    WHERE
        pat_id = @patId
        AND facility_cd = @facilityCd
        AND crud IN (''C'',''U'')
        AND ord_no = @ordNo
        AND coop_cd = ''exam_ord''
        AND key0 = @key0
        AND coop_result IN (''9'',''8'',''1'',''0'')
        ORDER BY scj.up_date DESC
    LIMIT 1
)
SELECT
    t.row_no
    , ''検査項目_削除'' AS detail_id
    , convert_from(substring(dump_data.dump, 258 * (t.row_no) + 1, 258), ''shift-jis'') AS data
FROM generate_series(1, (SELECT quotient FROM dump_data) - 1) AS t(row_no)
, dump_data', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_血液検査依頼削除レイアウト詳細用データ取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
