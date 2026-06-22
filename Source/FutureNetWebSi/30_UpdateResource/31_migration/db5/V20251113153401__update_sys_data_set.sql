DELETE FROM sys_data_set
WHERE sql_cd IN (-306105);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-306105, '-- sql_cd = -306105
WITH is_today_only AS (
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
        AND ocn.ctl_no IS NOT NULL
    LIMIT 1
)
SELECT
    1
WHERE
    (SELECT count(*) FROM is_cooperated) = 0
    AND 
        CASE COALESCE((SELECT v FROM is_today_only), ''0'')
            WHEN ''1'' THEN (SELECT base_date::DATE = CURRENT_DATE FROM sys_coop_journal WHERE facility_cd = @facilityCd AND ctl_no = @ctlNo)
            ELSE TRUE
        END', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom受付情報の実行可否判定', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);