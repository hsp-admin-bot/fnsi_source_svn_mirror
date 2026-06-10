DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2260,-2513,-2051)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2260, 'WITH ntss_db5_sys_f AS (
    SELECT
        ntss_db5_sys_f.medical_institution_cd
        , ntss_db5_sys_f.facility_name
    FROM
        sys_facility ntss_db5_sys_f
)
SELECT
    '''' AS hosppatid --患者ID
    ,ntss_db5_pu.pat_id AS patid
    ,ntss_db5_pu_io_json ->> ''ctl_no'' AS ctlno --項目番号
    ,ntss_db5_pu_io_json ->> ''period_start'' AS regdate --入外歴発生日
    ,CASE
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''1'' THEN ''1''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''2'' THEN ''1''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''3'' THEN ''2''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''4'' THEN ''4''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''5'' THEN ''5''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''6'' THEN ''6''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''10'' THEN ''7''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''11'' THEN ''3''
        ELSE NULL
        END AS inoutcd --転入出区分
    ,CASE
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''1''
        OR ntss_db5_pu_io_json ->> ''move_in_out'' = ''2''
        OR ntss_db5_pu_io_json ->> ''move_in_out'' = ''10''
        OR ntss_db5_pu_io_json ->> ''move_in_out'' = ''11''
            THEN CASE
                WHEN ntss_db5_pu_io_json ->> ''facility_is_free'' = ''0'' THEN ntss_db5_sys_f_from.facility_name
                WHEN ntss_db5_pu_io_json ->> ''facility_is_free'' = ''1'' THEN ntss_db5_pu_io_json ->> ''from_facility''
                ELSE NULL
                END
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''3''
            THEN CASE
                WHEN ntss_db5_pu_io_json ->> ''facility_is_free'' = ''0'' THEN ntss_db5_sys_f_to.facility_name
                WHEN ntss_db5_pu_io_json ->> ''facility_is_free'' = ''1'' THEN ntss_db5_pu_io_json ->> ''to_facility''
                ELSE NULL
                END
        ELSE NULL
        END AS facilityname --施設名
    ,CASE
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''1''
        OR ntss_db5_pu_io_json ->> ''move_in_out'' = ''2''
        OR ntss_db5_pu_io_json ->> ''move_in_out'' = ''10''
        OR ntss_db5_pu_io_json ->> ''move_in_out'' = ''11''
            THEN CASE
                WHEN ntss_db5_pu_io_json ->> ''doctor_is_free'' = ''0'' THEN ntss_db5_pu_io_json ->> ''from_doctor''
                ELSE NULL
                END
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''3''
            THEN CASE
                WHEN ntss_db5_pu_io_json ->> ''doctor_is_free'' = ''0'' THEN ntss_db5_pu_io_json ->> ''to_doctor''
                ELSE NULL
                END
        ELSE NULL
        END AS userid
    ,CASE
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''1''
        OR ntss_db5_pu_io_json ->> ''move_in_out'' = ''2''
        OR ntss_db5_pu_io_json ->> ''move_in_out'' = ''10''
        OR ntss_db5_pu_io_json ->> ''move_in_out'' = ''11''
            THEN CASE
                WHEN ntss_db5_pu_io_json ->> ''doctor_is_free'' = ''1'' THEN ntss_db5_pu_io_json ->> ''from_doctor''
                ELSE ''''
                END
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''3''
            THEN CASE
                WHEN ntss_db5_pu_io_json ->> ''doctor_is_free'' = ''1'' THEN ntss_db5_pu_io_json ->> ''to_doctor''
                ELSE ''''
                END
        ELSE NULL
        END AS drname --担当医名
    ,ntss_db5_pu_io_json ->> ''reason'' AS memo --コメント
    ,CASE
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''1'' THEN ''導入''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''2'' THEN ''転入''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''3'' THEN ''転出''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''4'' THEN ''入院''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''5'' THEN ''退院''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''6'' THEN ''外来''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''10'' THEN ''不明''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''11'' THEN ''死亡''
        ELSE NULL
        END AS codename --区分名
FROM
    pat_unique ntss_db5_pu
    CROSS JOIN LATERAL jsonb_array_elements ( ntss_db5_pu.in_out_visit_history_info ) AS ntss_db5_pu_io_json
    LEFT JOIN ntss_db5_sys_f ntss_db5_sys_f_from
    ON ntss_db5_pu_io_json ->> ''from_facility'' ::text = ntss_db5_sys_f_from.medical_institution_cd ::text
    LEFT JOIN ntss_db5_sys_f ntss_db5_sys_f_to
    ON ntss_db5_pu_io_json ->> ''to_facility'' ::text = ntss_db5_sys_f_to.medical_institution_cd ::text
WHERE
    ntss_db5_pu.facility_cd = @facilityCd
    AND ntss_db5_pu_io_json ->> ''move_in_out'' IN(''1'',''2'',''3'',''4'',''5'',''6'',''10'',''11'')
    AND @fromDate <= ntss_db5_pu_io_json ->> ''period_start'' AND ntss_db5_pu_io_json ->> ''period_start'' < @toDate;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2513, 'SELECT
	user_id ::text AS userid
	,CONCAT(personal_info_decrypt(user_last_name), ''　'', personal_info_decrypt(user_first_name)) AS drname --担当医名
FROM
	mst_personal_user
WHERE
	facility_cd = @facilityCd;', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '担当医名　@facilityCd使用 {"Mergekey": ["userid"]}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2051, 'SELECT
	hosp_pat_id AS hosppatid,
	pat_id AS patid
FROM
	pat_personal_main 
WHERE facility_cd = @facilityCd;', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
