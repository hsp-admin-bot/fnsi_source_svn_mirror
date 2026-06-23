DELETE FROM "ntss"."sys_data_set" where sql_cd in (-30);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-30, 'WITH pkg_info AS ( 
    SELECT
        info ->> ''key0'' AS pkg_name 
    FROM
        mst_coop_facility 
        CROSS JOIN LATERAL json_array_elements((common_setting ->> ''coop_ord_cd'') ::json) AS info 
    WHERE
        is_del = ''0''
        AND is_disp = ''1'' 
        AND facility_cd = @facilityCd 
        AND info ->> ''coop_cd'' ::TEXT = ''ini_dial'' 
        AND ( 
            info ->> ''coop_version'' IS NULL 
            OR info ->> ''coop_version'' = @coopVersion
        ) 
    ORDER BY
        order_no ASC 
    LIMIT
        1
) 
, reg_date_info AS ( 
    SELECT
        reg_date 
    FROM
        ord_coop_no 
    WHERE
        ord_no = @ordNo 
        AND ord_no > 0 
        AND facility_cd = @facilityCd 
        AND coop_version = @coopVersion 
        AND pat_id = @patId 
        AND coop_cd = ( 
            SELECT
                coop_cd 
            FROM
                sys_coop_journal 
            WHERE
                ctl_no = @ctlNo
        ) 
    ORDER BY
        reg_date DESC 
    LIMIT
        1
) 
SELECT
    save_2 ->> ''ord_no'' ::TEXT AS ord_no
    , save_2 ->> ''insu_no'' ::TEXT AS insu_no 
FROM
    pat_coop_detail 
WHERE
    pat_id = @patId 
    AND facility_cd = @facilityCd 
    AND coop_version = @coopVersion 
    AND is_disp = ''1'' 
    AND is_del = ''0'' 
    AND save_1 ->> ''pkg'' ::TEXT = (SELECT pkg_name FROM pkg_info) 
    AND ( 
        ( 
            (SELECT reg_date FROM reg_date_info) IS NOT NULL 
            AND reg_date <= (SELECT reg_date FROM reg_date_info)
        ) 
        OR (SELECT reg_date FROM reg_date_info) IS NULL
    ) 
ORDER BY
    reg_date DESC 
LIMIT
    1

', 2, '[{}]', '1', '{"applications": [4]}', NULL, '患者連携情報(受信オーダ番号、保険パターン)取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
