DELETE FROM sys_data_set WHERE sql_cd IN (-1108000);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1108000, 'WITH
journal_base AS (
    SELECT
        scj.crud
    FROM
        sys_coop_journal AS scj
    WHERE
        ctl_no = @ctlNo
        AND facility_cd = @facilityCd
    LIMIT 1
),
ord AS (
    SELECT
            ord.rst_in_out_class,
            ord.treat_date
    FROM
            ord_main AS ord
    WHERE
            ord.ord_no = @ordNo
        AND ord.facility_cd = @facilityCd
),
get_coop_ini AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
        info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND info ->> ''is_effect'' = ''1''
        AND COALESCE(info ->> ''key0'', '''') = @key0
            AND info ->> ''key1'' = ''SCM_REPORT_SEND''
            AND info ->> ''key2'' IN (
                ''COURSE_CODE'', ''DOCUMENT_CATEGORY'', ''DOCUMENT_TITLE'', ''DISPLAY_SIZE_CLASS''
            )
),
memo AS(
SELECT 
  COALESCE(save_2 ->> ''memo'', '''') AS file_name
FROM pat_coop_detail
WHERE
  save_2 ->> ''ord_no'' = @ordNo::text
  AND save_2 ->> ''coop_cd'' = ''rep_dial''
  AND facility_cd = @facilityCd
  AND pat_id = @patId
  ORDER BY pat_coop_detail.up_date 
  LIMIT 1
)
SELECT
    CASE
        crud
WHEN ''D'' THEN regexp_replace((SELECT file_name FROM memo), ''\.pdf$'', ''.delete'')
        WHEN ''C'' THEN
CONCAT(
    LPAD(RIGHT(@hosp_pat_id, 8), 8, ''0'')::text,
    (SELECT TO_CHAR(treat_date::DATE, ''yymmdd'') FROM ord),
    (SELECT value FROM get_coop_ini WHERE key2 = ''COURSE_CODE''),
    (SELECT value FROM get_coop_ini WHERE key2 = ''DOCUMENT_CATEGORY''),
    (SELECT value FROM get_coop_ini WHERE key2 = ''DOCUMENT_TITLE''),
    ''0'',
    (SELECT value FROM get_coop_ini WHERE key2 = ''DISPLAY_SIZE_CLASS''),
    CASE (SELECT rst_in_out_class FROM ord)
    WHEN ''1'' THEN ''2'' -- 入院
    ELSE ''1'' -- 外来
    END,
    TO_CHAR(CURRENT_TIMESTAMP, ''yyyyMMddHHmmssMS''),
''.pdf''
)
    END AS filename
FROM
    journal_base', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコム　レポート連携 PDFファイル名取得', '2025-07-30 01:19:21.728', CURRENT_TIMESTAMP, '[{"sql_cd": -1100006, "field_name": "hosp_pat_id", "replace_var": "@hosp_pat_id"}]'::jsonb);