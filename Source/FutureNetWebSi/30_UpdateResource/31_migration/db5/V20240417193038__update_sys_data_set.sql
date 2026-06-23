DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2270,-2051)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2270, 'SELECT
    '''' AS hosppatid --患者ID
    ,ntss_db5_pxm.pat_id AS patid
    ,to_char(ntss_db5_pxm.result_exam_date, ''YYYY-MM-DD hh24:mi:ss'') AS examdate --検査日時
    , CASE
        when ntss_db5_pxm.reg_order_class = ''0''
        then ''その他''
        WHEN ntss_db5_pxm.reg_order_class = ''1''
        THEN ''透析前''
        WHEN ntss_db5_pxm.reg_order_class = ''2''
        THEN ''透析後''
        ELSE NULL
        END AS orderclass --検査区分
    ,REPLACE(ntss_db5_om_eri_json ->> ''result_date'', ''/'', ''-'') AS itemupdate --検査結果更新日時
    ,ntss_db5_mst_e.in_hospital_cd1 AS examitemcode --検査項目コード(院内コード1)
    ,ntss_db5_mst_e.in_hospital_cd2 AS examitemcode2 --検査項目コード(院内コード2)
    ,ntss_db5_mst_e.in_hospital_cd3 AS examitemcode3 --検査項目コード(院内コード3)
    ,ntss_db5_om_eri_json ->> ''item_name'' AS examitemname --検査項目名
    ,ntss_db5_om_eri_json ->> ''result'' AS examrst --検査結果値
    ,ntss_db5_om_eri_json ->> ''hl'' AS examclassrst --検査結果形態
    ,ntss_db5_om_eri_json ->> ''freememo'' AS comments --コメント
FROM
    pat_exam_main ntss_db5_pxm
    CROSS JOIN LATERAL json_array_elements(ntss_db5_pxm.exam_result_info::json) ntss_db5_om_eri_json
    LEFT JOIN mst_exam_item ntss_db5_mst_e
    ON ntss_db5_mst_e.exam_item_cd :: text = ntss_db5_om_eri_json ->> ''item_cd''
WHERE
    ntss_db5_pxm.facility_cd = @facilityCd
    AND @fromDate <= ntss_db5_pxm.result_exam_date AND ntss_db5_pxm.result_exam_date < @toDate
    AND ntss_db5_pxm.exam_result_info IS NOT NULL;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);



INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2051, '-- 【SQL_CD=-2051】
SELECT
	ntss_db6_ppm.hosp_pat_id AS hosppatid,
	ntss_db6_ppm.pat_id AS patid
FROM
	pat_personal_main ntss_db6_ppm
WHERE ntss_db6_ppm.is_del = ''0''
	AND ntss_db6_ppm.facility_cd = @facilityCd;
', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
