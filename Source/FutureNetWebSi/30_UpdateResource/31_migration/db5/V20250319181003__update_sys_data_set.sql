DELETE FROM ntss.sys_data_set
WHERE sql_cd=-600303;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600303, 'WITH IND_ORDER_NO_HEADER_cd AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS ind_header_cd
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC''
        AND info ->> ''key2'' = ''IND_ORDER_NO_HEADER''
)
, DIALYSIS_ORDER_NO_HEADER_cd AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS dialysis_header_cd
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC''
        AND info ->> ''key2'' = ''DIALYSIS_ORDER_NO_HEADER''
)
, ind_dial_journal AS (
    SELECT
        CASE
            WHEN LENGTH(coop_ord_no) <= 11
            THEN concat((SELECT ind_header_cd FROM IND_ORDER_NO_HEADER_cd)
                , to_char(to_number(coop_ord_no, ''FM00000000000''), ''FM00000000000'')
                , ''000'')
            ELSE coop_ord_no
            END AS coop_ord_no
    FROM sys_coop_journal
    WHERE
        ord_no = @ordNo
        AND facility_cd = @facilityCd
        AND is_del = ''0''
        AND coop_cd = ''ind_dial''
        AND ana_result = ''9''
        AND coop_result = ''9''
    ORDER BY out_reg_date DESC
    LIMIT 1
)
, rst_dial_journal AS (
    SELECT
        CASE
            WHEN LENGTH(coop_ord_no) <= 11
            THEN concat((SELECT dialysis_header_cd FROM DIALYSIS_ORDER_NO_HEADER_cd)
                , to_char(to_number(coop_ord_no, ''FM00000000000''), ''FM00000000000'')
                , ''000'')
            ELSE coop_ord_no
        END AS coop_ord_no
    FROM sys_coop_journal
    WHERE
        ctl_no = @ctlNo
)
, rst_ord AS (
    SELECT ord.rst_dw AS rst_dw
    FROM ord_main ord
    WHERE ord.ord_no =  @ordNo
    AND ord.facility_cd = @facilityCd
)
SELECT
    CASE
        WHEN (SELECT coop_ord_no FROM ind_dial_journal) IS NOT NULL
        THEN (SELECT coop_ord_no FROM ind_dial_journal)
        ELSE ''0000000000000000''
        END AS ind_ord_no,
    (SELECT coop_ord_no FROM rst_dial_journal) AS rst_ord_no,
    TO_CHAR(COALESCE((SELECT rst_dw FROM rst_ord), 0), ''FM000V9'') AS dw', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC)オーダ番号・DW', '2025-03-18 11:34:58.308', CURRENT_TIMESTAMP, NULL);
