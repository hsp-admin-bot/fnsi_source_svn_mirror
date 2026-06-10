DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2320,-2051)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2320, '-- 【SQL_CD=-2320】
SELECT
    '''' AS hosppatid --患者ID
    ,ntss_db5_pm.pat_id AS patid
    ,ntss_db5_om_pmi_json ->> ''ctl_no'' AS ctlno
    ,ntss_db5_om_pmi_json ->> ''title'' AS title
    ,ntss_db5_om_pmi_json ->> ''content'' AS content
FROM
    pat_main ntss_db5_pm
    CROSS JOIN LATERAL json_array_elements(ntss_db5_pm.pat_memo_info ::json) ntss_db5_om_pmi_json
WHERE
    ntss_db5_pm.facility_cd = @facilityCd
    AND (ntss_db5_om_pmi_json ->> ''title'' IS NOT NULL
        OR ntss_db5_om_pmi_json ->> ''content'' IS NOT NULL);
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);



INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2051, 'SELECT
	hosp_pat_id AS hosppatid,
	pat_id AS patid
FROM
	pat_personal_main 
WHERE facility_cd = @facilityCd;', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
