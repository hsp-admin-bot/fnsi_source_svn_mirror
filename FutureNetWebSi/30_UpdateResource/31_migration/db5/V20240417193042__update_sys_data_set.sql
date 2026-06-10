DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2310,-2311,-2312,-2514)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2310, 'WITH ntss_db5_mst_pesc AS (
    SELECT
        ntss_db5_mst_pesc.sub_category_cd
        , ntss_db5_mst_pesc.sub_category_name
    FROM
        mst_pat_event_sub_category ntss_db5_mst_pesc
    WHERE
        ntss_db5_mst_pesc.facility_cd = @facilityCd
)
, result_params_temp AS (
    SELECT
        pe.pat_event_cd
        , json_rp ->> ''result_value'' AS result_value
        , idx AS rp_idx
    FROM
        pat_event pe
    CROSS JOIN lateral jsonb_array_elements(pe.result_params) with ordinality AS tmp(json_rp, idx)
    WHERE
        pe.facility_cd = @facilityCd
        AND @fromDate <= pe.event_start_date AND pe.event_start_date < @toDate
        AND pe.result_params <> ''null''
        AND pe.result_params <> ''[]''
)
SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_pe.pat_id AS patid
    , to_char(ntss_db5_pe.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    , '''' AS name                                --氏名
    , '''' AS namekana                            --患者名(かな）
    , ntss_db5_pe.event_start_date AS regdate --起票日
    , '''' AS regtime --起票時刻
    , CASE
        WHEN ntss_db5_mst_pesc.sub_category_name = ''SOAP'' THEN ''0''
        WHEN ntss_db5_mst_pesc.sub_category_name = ''看護メモ'' THEN ''1''
        WHEN ntss_db5_mst_pesc.sub_category_name = ''問診記録'' THEN ''2''
        ELSE NULL
        END AS kindid                           --種別ID
    , ntss_db5_pe.sub_category_name AS kindname --種別名
    , '''' AS staffcd                             --起票者ID
    , ntss_db5_pe.reg_staff_info #>> ''{reg_staff_cd}'' AS staffid
    , ntss_db5_pe.reg_staff_info #>> ''{reg_staff_name}'' AS staffname --起票者名
    , '''' AS editcd                              --編集者ID
    , ntss_db5_pe.up_staff_info #>> ''{up_staff_cd}'' AS editid
    , ntss_db5_pe.up_staff_info #>> ''{up_staff_name}'' AS editname --編集者名
    , MAX(CASE
        WHEN ntss_db5_mst_pesc.sub_category_name = ''SOAP''
        AND json_ip ->> ''field_name'' = ''S''
            THEN result_params_temp.result_value
        WHEN (ntss_db5_mst_pesc.sub_category_name = ''看護メモ''
            OR ntss_db5_mst_pesc.sub_category_name = ''問診記録'')
        AND idx = 1
            THEN result_params_temp.result_value
        ELSE NULL
        END) AS detail1 --内容1
    , MAX(CASE
        WHEN ntss_db5_mst_pesc.sub_category_name = ''SOAP''
        AND json_ip ->> ''field_name'' = ''O''
            THEN result_params_temp.result_value
        ELSE NULL
        END) AS detail2 --内容2
    , MAX(CASE
        WHEN ntss_db5_mst_pesc.sub_category_name = ''SOAP''
        AND json_ip ->> ''field_name'' = ''A''
            THEN result_params_temp.result_value
        ELSE NULL
        END) AS detail3 --内容3
    , MAX(CASE
        WHEN ntss_db5_mst_pesc.sub_category_name = ''SOAP''
        AND json_ip ->> ''field_name'' = ''P''
            THEN result_params_temp.result_value
        ELSE NULL
        END) AS detail4 --内容4
    ,CASE
        WHEN ntss_db5_pe.ord_no = 0 THEN NULL
        ELSE ntss_db5_pe.ord_no
        END AS dialysisno --透析番号
FROM
    pat_event ntss_db5_pe
    LEFT JOIN ntss_db5_mst_pesc
        ON ntss_db5_mst_pesc.sub_category_cd = ntss_db5_pe.sub_category_cd
    CROSS JOIN LATERAL jsonb_array_elements(ntss_db5_pe.input_params) WITH ordinality AS tmp(json_ip, idx)
    LEFT JOIN result_params_temp
    ON result_params_temp.pat_event_cd = ntss_db5_pe.pat_event_cd
    AND result_params_temp.rp_idx = idx
WHERE
    ntss_db5_pe.facility_cd = @facilityCd
    AND @fromDate <= ntss_db5_pe.event_start_date AND ntss_db5_pe.event_start_date < @toDate
    AND ntss_db5_pe.is_del = ''0''
    AND ntss_db5_pe.input_params IS NOT NULL
    AND ntss_db5_pe.input_params <> ''null''
    AND ntss_db5_pe.input_params <> ''[]''
    AND ntss_db5_mst_pesc.sub_category_name IN (''SOAP'',''看護メモ'',''問診記録'')
GROUP BY
    ntss_db5_pe.pat_event_cd
    , ntss_db5_mst_pesc.sub_category_name;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,staffid,editid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2311, '-- 【SQL_CD=-2311】
SELECT
	hosp_pat_id AS hosppatid --患者ID
	, pat_id AS patid
	, CONCAT(personal_info_decrypt(pat_last_name), ''　'', personal_info_decrypt(pat_first_name)) AS name --氏名
	, CONCAT(personal_info_decrypt(pat_last_name_kana), ''　'', personal_info_decrypt(pat_first_name_kana)) AS namekana --患者名(かな)
FROM
	pat_personal_main
WHERE
	facility_cd = @facilityCd;', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);




INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2312, '-- 【SQL_CD=-2312】
SELECT
	CAST(user_id AS VARCHAR) AS staffid
	, disp_user_id AS staffcd --起票者ID
FROM
	mst_user_authentication
WHERE
	facility_cd = @facilityCd;', 1, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["staffid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);



INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2514, '-- 【SQL_CD=-2514】
SELECT
	CAST(user_id AS VARCHAR) AS editid
	, disp_user_id AS editcd --編集者ID
FROM
	mst_user_authentication
WHERE
	facility_cd = @facilityCd;', 1, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["editid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
