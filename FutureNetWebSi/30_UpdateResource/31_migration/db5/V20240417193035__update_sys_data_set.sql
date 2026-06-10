DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2506,-2051)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2506, 'SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om.pat_id AS patid
    , ntss_db5_om.treat_date AS dialysisdate    --透析日
    , ntss_db5_om.ord_no AS dialysisno          --透析番号
    , ROW_NUMBER() OVER (PARTITION BY ntss_db5_om.ord_no ORDER BY CAST(ntss_db5_om_di_json1 ->> ''cd'' AS int) ASC) AS ctlno --項目番号
    , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    , ''1'' AS division                           --レセプトメモ区分
    , ntss_db5_mst_a.in_hospital_cd_3 AS code   --コード
    , to_char(ntss_db5_mst_a.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS codeupdate --コード更新日時
    , ''1'' AS addflg                             --加算有無
    , ntss_db5_om_di_json1 ->> ''name'' AS itemname  --項目名称
    , '''' AS maindialdiff                        --主たる透析困難
    , ntss_db5_mst_a.in_hospital_cd_1 AS inhospitalcd --院内コード
    , ntss_db5_mst_a.in_hospital_cd_2 AS inhospitalcd2 --院内コード２
FROM
    ord_main ntss_db5_om
    CROSS JOIN LATERAL json_array_elements(ntss_db5_om.addition_info ::json) ntss_db5_om_di_json1
    INNER JOIN mst_addition ntss_db5_mst_a
        ON ntss_db5_mst_a.addition_cd :: text = ntss_db5_om_di_json1 ->> ''cd''
WHERE
    ntss_db5_om.is_del = ''0''
    AND ntss_db5_om.facility_cd = @facilityCd
    AND ntss_db5_om.rst_dialysis_state IN (''1'',''2'',''3'',''4'',''5'')
    AND ntss_db5_om.addition_info IS NOT NULL
    AND ntss_db5_om.addition_info <> ''[]''
    AND ntss_db5_om.pat_id IS NOT NULL;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2051, 'SELECT
	hosp_pat_id AS hosppatid,
	pat_id AS patid
FROM
	pat_personal_main 
WHERE facility_cd = @facilityCd;', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);

