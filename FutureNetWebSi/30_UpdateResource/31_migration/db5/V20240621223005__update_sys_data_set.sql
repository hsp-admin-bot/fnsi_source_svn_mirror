DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2507,-2051)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2507, 'SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om.pat_id AS patid
    , to_char(ntss_db5_om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') AS startdate      --開始日時
    , to_char(ntss_db5_mm.occur_date, ''YYYY-MM-DD hh24:mi:ss'') AS occurdate          --発生日時
    , ntss_db5_mm.monitor_data ->> ''90'' AS bpmax                            --最高血圧
    , ntss_db5_mm.monitor_data ->> ''91'' AS bpmin                            --最低血圧
    , ntss_db5_mm.monitor_data ->> ''92'' AS bpave                            --平均血圧
    , ntss_db5_mm.monitor_data ->> ''93'' AS pulse                            --脈拍
    , ntss_db5_mm.monitor_data ->> ''94'' AS temperature                      --体温
    , ntss_db5_mm.monitor_data ->> ''-1'' AS bloodsugarlevel                  --血糖値
    , to_char(ntss_db5_mm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update       --更新日時
    , ntss_db5_om.ord_no AS diadysisno        --透析番号
    , CASE
        WHEN ntss_db5_mm.data_type = ''5'' THEN ''1''
        WHEN ntss_db5_mm.data_type IN (''2'', ''4'') THEN ''0''
        WHEN ntss_db5_mm.data_type = ''6'' THEN ''2''
        END AS bpclass                          --血圧区分
    , ntss_db5_om.ord_no AS ordno               --透析番号
FROM
    ord_main ntss_db5_om
    INNER JOIN mni_monitor ntss_db5_mm
        ON ntss_db5_mm.ord_no = ntss_db5_om.ord_no
        AND ntss_db5_om.facility_cd = ntss_db5_mm.facility_cd
        AND ntss_db5_mm.is_del = ''0''
WHERE
    ntss_db5_om.facility_cd = @facilityCd
    AND ntss_db5_om.rst_dialysis_state BETWEEN ''1'' AND ''5''
    AND ntss_db5_mm.data_type IN (''2'', ''4'', ''5'', ''6'');
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



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
