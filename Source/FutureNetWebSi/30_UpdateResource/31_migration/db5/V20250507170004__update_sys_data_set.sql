DELETE FROM sys_data_set
WHERE sql_cd IN (-205, -600018, -600019);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-205, 'WITH 
journal AS(
    SELECT 
        coop_ord_no,
        reg_date,
        ord_no,
        hosp_pat_id
    FROM
        sys_coop_journal
    WHERE
        ctl_no = @ctlNo
)
,ord_main_switch AS(
(
      SELECT
        ord.ord_no as ord_no,
        ord.rst_fn_dialysis_no,
        ord.rst_edition_date as up_date_switch
    FROM
        ord_main ord
    WHERE
        ord.ord_no = @ordNo
)
UNION
    (
        SELECT
        ord.ord_no as ord_no,
        ord.rst_fn_dialysis_no,
        ord.del_date as up_date_switch
        FROM
            ord_main_restore AS ord,
            journal
        WHERE
            ord.ord_no = @ordNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY
            del_date DESC
        LIMIT 1
    )
ORDER BY
      up_date_switch DESC NULLS LAST
LIMIT 1
)
SELECT 
    CASE WHEN rst_fn_dialysis_no IS NULL -- FNSi
    THEN
    CONCAT(
        CASE
            WHEN LENGTH(trim(journal.hosp_pat_id)) > @digit THEN trim(journal.hosp_pat_id)
            ELSE lpad(trim(journal.hosp_pat_id), @digit, ''0'')
        END, 
        LPAD(ord.ord_no::text, 19, ''0''),
        LPAD(journal.coop_ord_no, 16, ''0'')
    )
    ELSE -- FNW
    CONCAT(
        CASE
            WHEN LENGTH(trim(journal.hosp_pat_id)) > @digit THEN trim(journal.hosp_pat_id)
            ELSE lpad(trim(journal.hosp_pat_id), @digit, ''0'')
        END, 
        lpad(ord.rst_fn_dialysis_no::text, 12, ''0'')
    ) 
    END AS object_uid
FROM
    ord_main_switch ord,
    journal;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC)TAR,XML送信データキー(pat_id,ord_no)', '2020-05-26 16:49:16.583', CURRENT_TIMESTAMP, '[{"sql_cd": -600401, "field_name": "patid_patidfig", "replace_var": "@digit"}]'::jsonb);


INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600018, 'SELECT
    (
    SELECT
        COALESCE(NULLIF(ini_info ->> ''value'', ''''), ini_info ->> ''default_v'')
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL jsonb_array_elements(ini.coop_ini_info) AS ini_info
    WHERE
        ini.is_del = ''0''
        AND ini.is_disp = ''1''
        AND ini.facility_cd = @facilityCd
        AND COALESCE(ini_info->>''key0'', '''') = @key0
        AND TRIM(ini_info ->> ''key1'') = ''NEC''
        AND TRIM(ini_info ->> ''key2'') = ''XMLGEN_DEVICE_NAME'')
        || ''_'' || to_char(journal.up_date, ''YYYYMMDDHH24MISSMS'')
        || ''_'' || journal.hosp_pat_id
        || ''_0.'' || @extension AS filename
FROM
    sys_coop_journal journal
WHERE
    journal.ctl_no = @ctlNo;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'NEC標準(MegaOakHR) 透析レポート', '2025-01-28 18:11:12.244', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600019, 'SELECT
    CASE
        WHEN COALESCE(ord.rst_fn_dialysis_no, 0) = 0 THEN (
        SELECT
            COALESCE(NULLIF(ini_info ->> ''value'', ''''), ini_info ->> ''default_v'')
        FROM
            mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info
        WHERE
            ini.is_del = ''0''
            AND ini.is_disp = ''1''
            AND ini.facility_cd = @facilityCd
            AND COALESCE(ini_info->>''key0'', '''') = @key0
            AND TRIM(ini_info ->> ''key1'') = ''NEC''
            AND TRIM(ini_info ->> ''key2'') = ''XMLGEN_DEVICE_NAME'')
            || ''_'' || to_char(journal.up_date, ''YYYYMMDDHH24MISSMS'')
            || ''_'' || journal.hosp_pat_id || ''_0.pdf''
        ELSE 
        journal.hosp_pat_id
        || lpad(trim(to_char(ord.rst_fn_dialysis_no, ''999999999999'')), 12, ''0'')
        || lpad(trim(to_char(ord.rst_edition, ''9999'')), 4, ''0'') || ''.pdf''
    END AS filename
FROM
    sys_coop_journal journal
INNER JOIN ord_main ord ON
    ord.ord_no = journal.ord_no
WHERE
    journal.ctl_no = @ctlNo;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'NEC標準(MegaOakHR) 透析レポート', '2025-01-28 18:11:12.244', CURRENT_TIMESTAMP, NULL);