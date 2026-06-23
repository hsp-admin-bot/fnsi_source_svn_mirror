DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2060,-2051)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2060, '-- 【SQL_CD=-2060】
with ntss_db5_mst_add as (
    SELECT
        ntss_db5_mst_add.addition_cd
        ,ntss_db5_mst_add.addition_name
        ,ntss_db5_mst_add.in_hospital_cd_1
        ,ntss_db5_mst_add.in_hospital_cd_2
        ,ntss_db5_mst_add.in_hospital_cd_3
        ,ntss_db5_mst_add.reg_date
        ,ntss_db5_mst_add.up_date
    FROM
        mst_addition ntss_db5_mst_add
    WHERE
        ntss_db5_mst_add.facility_cd = @facilityCd
)
SELECT
    ntss_db5_pm.pat_id AS patid
    ,'''' AS hosppatid --患者ID
    ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    ,''1'' AS division -- レセプトメモ区分
    ,ntss_db5_mst_add.in_hospital_cd_3 AS code --コード
    ,to_char(ntss_db5_mst_add.reg_date, ''YYYY-MM-DD hh24:mi:ss'') AS codeupdate --コード更新日時
    ,ntss_db5_pm_json ->> ''is_enable'' AS addflg -- 加算有無
    ,ntss_db5_mst_add.addition_name AS itemname --項目名称
    ,'''' AS maindialdiff --主たる透析困難
    ,ntss_db5_mst_add.in_hospital_cd_1 AS inhospitalcd --院内コード
    ,ntss_db5_mst_add.in_hospital_cd_2 AS inhospitalcd2 --院内コード２
FROM
    pat_main ntss_db5_pm
    CROSS JOIN LATERAL json_array_elements(ntss_db5_pm.addition_info ::json) ntss_db5_pm_json
    LEFT JOIN ntss_db5_mst_add
    ON ntss_db5_mst_add.addition_cd ::text = ntss_db5_pm_json ->> ''cd''
WHERE
    ntss_db5_pm.facility_cd = @facilityCd
    AND ntss_db5_pm.is_del = ''0''
    AND ntss_db5_pm.addition_info <> ''[]'';
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);



INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2051, 'SELECT
	hosp_pat_id AS hosppatid,
	pat_id AS patid
FROM
	pat_personal_main 
WHERE facility_cd = @facilityCd;', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
