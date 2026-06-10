DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2280,-2281,-2051,-2042,-2509,-2510,-2511,-2512)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2280, 'WITH om AS(
     SELECT
         treat_date
        ,ind_treat_start_time
        ,ind_cond_info_value
        ,ord_no
        ,pat_id
    FROM
        (
             SELECT
                 om.treat_date
                ,om.ind_treat_start_time
                ,om.ind_cond_info -> ''1'' ->> ''value'' AS ind_cond_info_value
                ,om.ord_no
                ,om.pat_id
                ,ROW_NUMBER() OVER(PARTITION BY om.facility_cd, om.pat_id, om.treat_date ORDER BY COALESCE(om.ind_treat_start_time, ''9999'') ASC) AS num
            FROM
                ord_main om
            WHERE
                om.facility_cd = @facilityCd
            AND @fromDate <= om.treat_date
            AND om.treat_date < @toDate
            AND ind_treat_start_time IS NOT NULL
        ) AS date_data
    WHERE
        num = 1
)
SELECT
     '''' AS hosppatid --患者ID
    ,pem.pat_id AS patid
    ,to_char(pem.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    ,to_char(pem.reg_exam_date, ''YYYYMMDD'') AS examdate --検査予定日
    ,
     CASE pem.reg_order_class
         WHEN ''0'' THEN (CASE WHEN om.ord_no IS NOT NULL THEN om.ind_treat_start_time ELSE NULL END)
         WHEN ''1'' THEN (CASE WHEN om.ord_no IS NOT NULL THEN to_char((
                         om.ind_treat_start_time::time + (ind_cond_info_value || '' minutes'')::interval
                     ), ''HH24MI'') ELSE NULL END)
         WHEN ''2'' THEN pem_mst_ei.other_exam_time
         ELSE NULL
     END AS examtime --検査予定時刻
    ,pem_mst_ei.in_hospital_cd1 AS examsetcd --検査セットNo(院内コード)
    ,pem_oesi_json ->> ''set_name'' AS examsetname --検査セット名称
    ,CASE pem.reg_order_class
        WHEN ''1'' THEN ''0''
        WHEN ''2'' THEN ''1''
        ELSE ''2''
    END AS examdivision --検査予定区分
    ,''1'' AS examproccd --検査実施予定コード
    ,pem.ind_user_id AS userid
    ,'''' AS doctorcode --指示者
    ,'''' AS doctorname --指示者名
    ,pem.reg_staff AS regstaff
    ,'''' AS orderstaff --スタッフコード
    ,'''' AS ordername
    ,pem.up_staff AS upstaff
    ,'''' AS updatecode
    ,'''' AS updatename
    ,pem.exam_main_cd AS examno --依頼番号
    FROM
        pat_exam_main pem
        CROSS JOIN LATERAL jsonb_array_elements(pem.order_exam_set_info::jsonb) pem_oesi_json
        LEFT JOIN om
        ON  to_char(pem.reg_exam_date, ''YYYYMMDD'') = om.treat_date
        AND pem.pat_id = om.pat_id
        LEFT JOIN
            mst_exam_set pem_mst_ei
        ON  pem_mst_ei.exam_set_cd = cast(pem_oesi_json ->> ''set_cd'' AS integer)
    WHERE
        pem.facility_cd = @facilityCd
    AND @fromDate <= pem.reg_exam_date AND pem.reg_exam_date < @toDate
    AND pem.order_exam_set_info IS NOT NULL
    AND pem.order_exam_set_info <> ''[]''', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid,regstaff,upstaff"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2281, 'SELECT
	ntss_db4_mst_ua.user_id AS userid
	,ntss_db4_mst_ua.disp_user_id AS doctorcode
FROM
	mst_user_authentication ntss_db4_mst_ua
WHERE ntss_db4_mst_ua.facility_cd = @facilityCd;', 1, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["userid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);

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
      facility_cd = @facilityCd', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["userid"]}', '2021-02-26 17:51:54.726', current_timestamp, NULL);



INSERT INTO
  ntss.sys_data_set (
    sql_cd,
    "sql",
    db_class,
    detail,
    can_repeat,
    use_application,
    report_class,
    memo,
    reg_date,
    up_date,
    pre_sql_info
  )
VALUES
  (
    -2509,
    'SELECT
       user_id AS regstaff
       ,CONCAT(personal_info_decrypt(user_last_name), ''　'' , personal_info_decrypt(user_first_name)) AS ordername --オーダー入力者名
FROM
            mst_personal_user
WHERE
            facility_cd = @facilityCd;',
    3,
    '[{}]'::jsonb,
    '1',
    '{"applications": [5]}'::jsonb,
    '{"classes": []}'::jsonb,
    '患者病歴情報　@facilityCd使用 {"Mergekey": ["regstaff"]}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    NULL
  );

INSERT INTO
  ntss.sys_data_set (
    sql_cd,
    "sql",
    db_class,
    detail,
    can_repeat,
    use_application,
    report_class,
    memo,
    reg_date,
    up_date,
    pre_sql_info
  )
VALUES
  (
    -2510,
    'SELECT
    user_id AS regstaff
  ,disp_user_id AS orderstaff
FROM
    mst_user_authentication
WHERE facility_cd = @facilityCd;',
    1,
    '[{}]'::jsonb,
    '1',
    '{"applications": [5]}'::jsonb,
    '{"classes": []}'::jsonb,
    '患者病歴情報　@facilityCd使用 {"Mergekey": ["regstaff"]}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    NULL
  );


INSERT INTO
  ntss.sys_data_set (
    sql_cd,
    "sql",
    db_class,
    detail,
    can_repeat,
    use_application,
    report_class,
    memo,
    reg_date,
    up_date,
    pre_sql_info
  )
VALUES
  (
    -2511,
    'SELECT
    user_id AS upstaff
  ,disp_user_id AS updatecode
FROM
    mst_user_authentication
WHERE facility_cd = @facilityCd;',
    1,
    '[{}]'::jsonb,
    '1',
    '{"applications": [5]}'::jsonb,
    '{"classes": []}'::jsonb,
    '患者病歴情報　@facilityCd使用 {"Mergekey": ["upstaff"]}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    NULL
  );


INSERT INTO
  ntss.sys_data_set (
    sql_cd,
    "sql",
    db_class,
    detail,
    can_repeat,
    use_application,
    report_class,
    memo,
    reg_date,
    up_date,
    pre_sql_info
  )
VALUES
  (
    -2512,
    'SELECT
       user_id AS upstaff
       ,CONCAT(personal_info_decrypt(user_last_name), ''　'', personal_info_decrypt(user_first_name))  AS updatename --更新者名
     FROM
       mst_personal_user
     WHERE
       facility_cd = @facilityCd;',
    3,
    '[{}]'::jsonb,
    '1',
    '{"applications": [5]}'::jsonb,
    '{"classes": []}'::jsonb,
    '患者病歴情報　@facilityCd 使用 {"Mergekey": ["upstaff"]}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    NULL
  );