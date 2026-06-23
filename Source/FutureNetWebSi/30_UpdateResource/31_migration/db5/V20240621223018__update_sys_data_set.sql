DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-2150,-2051)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2051, 'SELECT
	hosp_pat_id AS hosppatid,
	pat_id AS patid
FROM
	pat_personal_main 
WHERE facility_cd = @facilityCd;', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2150, '-- 【SQL_CD=-2150】
    SELECT
        '''' AS hosppatid                             --患者ID
        , ntss_db5_om.pat_id AS patid
        , ntss_db5_om.treat_date AS dialysisdate    --透析日
        , ntss_db5_om.ord_no AS dialysisno          --透析番号
        , ROW_NUMBER() OVER (PARTITION BY ntss_db5_om.ord_no ORDER BY (ntss_db5_om_iic_json ->> ''no'')::int ASC) AS ctlno
        , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
        , ''0'' AS effectflg                          --実施フラグ
        , '''' AS effectdate --実施日時
        , ntss_db5_om_iic_json ->> ''content'' AS addition --補足指示内容
        , '''' AS staffcd                           --実施者コード
        , '''' AS staffname                              --実施者名
    FROM
        ord_main ntss_db5_om
        CROSS JOIN LATERAL jsonb_array_elements(ntss_db5_om.rst_ind_comment_info ::jsonb) ntss_db5_om_iic_json
    WHERE
        ntss_db5_om.is_del = ''0''
        AND ntss_db5_om.facility_cd = @facilityCd
        AND ntss_db5_om.pat_id IS NOT NULL
        AND @fromDate <= ntss_db5_om.treat_date AND ntss_db5_om.treat_date < @toDate;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);