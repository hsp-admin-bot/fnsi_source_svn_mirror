DELETE FROM sys_data_set
WHERE sql_cd IN (-1001,-306105);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1001, 'WITH sch_start_time AS (
    SELECT 
        COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS v
    FROM 
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE 
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info->>''key0'', '''') = @key0
        AND info->>''key1'' = ''COOP_CONFIG''
        AND info->>''key2'' = ''SCH_START_TIME''
)
SELECT 
    COALESCE(
        ord_main.treat_date,
        TO_CHAR(ord_main.rst_start_date::TIMESTAMP, ''YYYYMMDD''),
        ''''
    ) AS treat_date,
    CASE 
        WHEN (SELECT v FROM sch_start_time) = ''0'' 
            THEN COALESCE(
                LEFT(mst_kur.kur_standard_start_time, 4),
                TO_CHAR(ord_main.rst_start_date::TIMESTAMP, ''HH24MI''),
                ''''
            )
        WHEN (SELECT v FROM sch_start_time) = ''1'' 
            THEN COALESCE(
                ord_main.ind_treat_start_time,
                TO_CHAR(ord_main.rst_start_date::TIMESTAMP, ''HH24MI''),
                ''''
            )
        ELSE ''''
    END AS ind_treat_start_time
FROM 
    ord_main
JOIN 
    mst_kur ON COALESCE(ord_main.rst_kur_cd, ord_main.ind_kur_cd) = mst_kur.kur_cd
WHERE 
    ord_main.ord_no = @ordNo', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2020-03-17 16:17:08.001', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-306105, 'WITH is_today_only AS (
    SELECT 
        COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS v
    FROM 
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE 
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND info->>''is_effect'' = ''1''
        AND COALESCE(info->>''key0'', '''') = @key0
        AND info->>''key1'' = ''ACCEPT_SEND''
        AND info->>''key2'' = ''DAY_SENDING_FLAG''
),
is_cooperated AS (
    SELECT
        scj.base_date
    FROM
        sys_coop_journal AS scj
    LEFT JOIN sys_coop_journal AS scj2
        ON scj.facility_cd = scj2.facility_cd
        AND scj.pat_id = scj2.pat_id
        AND scj.base_date = scj2.base_date
        AND scj2.coop_cd = ''accept''
    LEFT JOIN ord_coop_no ocn
        ON scj2.facility_cd = ocn.facility_cd
        AND scj2.coop_cd = ocn.coop_cd
        AND scj2.pat_id = ocn.pat_id
        AND scj2.coop_ord_no = ocn.coop_ord_no
        AND ocn.status = ''1''
        AND ocn.is_disp = ''1''
        AND ocn.is_del = ''0''
    WHERE
        scj.ctl_no = @ctlNo
        AND ocn.ctl_no IS NULL
    LIMIT 1
)
SELECT
    1
FROM
    is_cooperated
WHERE
    NOT (
        COALESCE((SELECT v FROM is_today_only), ''0'') = ''1''
        AND base_date::DATE < CURRENT_DATE
    )', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom受付情報の実行可否判定', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);