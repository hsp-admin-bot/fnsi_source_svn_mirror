DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2050,-2051)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2050, '-- 【SQL_CD=-2050】
SELECT
    '''' AS hosppatid --患者ID
    ,ntss_db5_mst_mi.in_hospital_cd_1 AS infectioncd --感染症コード
    ,ntss_db5_mst_mi.infection_name AS infectionname --感染症名
    ,TO_CHAR(TO_TIMESTAMP(ntss_db5_pm_json ->> ''up_date'', ''YYYYMMDD''), ''YYYY-MM-DD HH24:MI:SS'') AS update --更新日時
    , CASE ntss_db5_pm_json ->> ''infect'' 
    WHEN ''1'' THEN ''0'' 
    WHEN ''2'' THEN ''1'' 
    ELSE ''-''
    END AS infect --結果コード
    ,ntss_db5_pm.pat_id AS patid
FROM
    pat_main ntss_db5_pm
    CROSS JOIN LATERAL jsonb_array_elements(ntss_db5_pm.infect_info ::jsonb) ntss_db5_pm_json
    INNER JOIN mst_infection ntss_db5_mst_mi
    ON ntss_db5_mst_mi.infection_cd ::text = ntss_db5_pm_json ->> ''infection_cd''
WHERE
    ntss_db5_pm.is_del != ''1''
    AND ntss_db5_pm.facility_cd = @facilityCd
    AND ntss_db5_mst_mi.in_hospital_cd_1 IS NOT null;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);



INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2051, 'SELECT
	hosp_pat_id AS hosppatid,
	pat_id AS patid
FROM
	pat_personal_main 
WHERE facility_cd = @facilityCd;', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
