DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2041,-2051,-2042)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2041, 'SELECT
    '''' AS hosppatid --患者ID
    ,ntss_db5_pu.pat_id AS patid
    ,ntss_db5_pu_mhi_json ->> ''ctl_no'' AS ctlno --管理番号
    ,to_char(ntss_db5_pu.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    ,ntss_db5_pu_mst_d.in_hospital_cd_1 AS diseasecd --病名コード
    ,ntss_db5_pu_mst_d.disease_name AS diseasename --病名
    ,CASE 
        WHEN LENGTH(ntss_db5_pu_mhi_json ->> ''disease_date'') = 8
        THEN to_char(to_timestamp(ntss_db5_pu_mhi_json ->> ''disease_date'', ''YYYYMMDD''), ''YYYY-MM-DD hh24:mi:ss'')  
        ELSE NULL
    END AS diseasedate --発症日
    ,CASE 
      WHEN ntss_db5_pu_mhi_json ->> ''out_come'' IN (''3'', ''5'') THEN to_char(to_timestamp(ntss_db5_pu_mhi_json ->> ''out_come_date'', ''YYYYMMDD''), ''YYYY-MM-DD hh24:mi:ss'')
      ELSE null
    END AS recoverdate --治癒日
    ,ntss_db5_pu_mhi_json ->> ''is_main_disease'' AS maindisease --主病名
    ,CASE ntss_db5_pu_mhi_json ->> ''out_come''
      WHEN ''1'' THEN ''3'' 
      WHEN ''2'' THEN ''8''
      WHEN ''3'' THEN ''0''
      WHEN ''8'' THEN ''2''
      WHEN ''10'' THEN ''1''
      ELSE ntss_db5_pu_mhi_json ->> ''out_come''
    END AS status --転帰
    ,ntss_db5_pu_mhi_json ->> ''is_notice'' AS noticeflg --告知有無
    ,CASE WHEN
        ntss_db5_pu_mhi_json ->> ''diagnostician_is_free'' = ''1'' THEN ntss_db5_pu_mhi_json ->> ''diagnostician_cd''
      ELSE ''''
      END AS doctorname --診断医
     ,CASE WHEN
        ntss_db5_pu_mhi_json ->> ''diagnostician_is_free'' = ''0'' THEN cast(ntss_db5_pu_mhi_json ->> ''diagnostician_cd'' AS int8)
    END AS userid --Mergekey
    ,ntss_db5_pu_mhi_json ->> ''memo'' AS memo --メモ
FROM
    ntss.pat_unique ntss_db5_pu
    CROSS JOIN LATERAL jsonb_array_elements(ntss_db5_pu.medical_hst_info::jsonb) ntss_db5_pu_mhi_json
    LEFT JOIN ntss.mst_disease ntss_db5_pu_mst_d
   ON ntss_db5_pu_mst_d.disease_cd :: TEXT = ntss_db5_pu_mhi_json ->> ''disease_cd''
WHERE
    ntss_db5_pu.is_del != ''1''
    AND ntss_db5_pu.facility_cd = @facilityCd
    AND ntss_db5_pu.medical_hst_info IS NOT NULL
    AND ntss_db5_pu.medical_hst_info <> ''[]''
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', current_timestamp, NULL);



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
VALUES(-2042, 'SELECT
      user_id AS userid
      ,CONCAT(personal_info_decrypt(user_last_name), ''　'', personal_info_decrypt(user_first_name))  AS doctorname --診断医
    FROM
      mst_personal_user
    WHERE
      facility_cd = @facilityCd;
', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["userid"]}', '2021-02-26 17:51:54.726', current_timestamp, NULL);
