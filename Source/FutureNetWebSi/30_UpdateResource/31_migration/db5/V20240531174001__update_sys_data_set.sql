DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2280,-2281,-2051,-2042,-2509,-2510,-2511,-2512)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2280, 'WITH mtss_db5_om AS (
    SELECT
        treat_date
        , ind_treat_start_time
        , ind_cond_info_value
        , ord_no
        , pat_id
    FROM (
        SELECT 
            mtss_db5_om.treat_date
            , mtss_db5_om.ind_treat_start_time
            , mtss_db5_om.ind_cond_info -> ''1'' ->> ''value'' AS ind_cond_info_value
            , mtss_db5_om.ord_no
            , mtss_db5_om.pat_id
            , ROW_NUMBER() OVER (PARTITION BY mtss_db5_om.facility_cd,mtss_db5_om.pat_id,mtss_db5_om.treat_date ORDER BY COALESCE(mtss_db5_om.ind_treat_start_time,''9999'') ASC, sortkey ASC) AS num
        FROM ord_main mtss_db5_om 
      LEFT JOIN (
        SELECT
          ntss_db5_ms.facility_cd,
          setting ->> ''code'' AS code,
          ROW_NUMBER() OVER() AS sortkey
        FROM
          ntss.mst_selector ntss_db5_ms
          CROSS JOIN LATERAL json_array_elements((ntss_db5_ms.order_settings #> ''{"items"}'') :: json) setting
        WHERE
          ntss_db5_ms.facility_cd = @facilityCd
          AND ntss_db5_ms.master_physical_name = ''mst_treatment''
      ) AS ntss_db5_mst_sel ON mtss_db5_om.facility_cd = ntss_db5_mst_sel.facility_cd
      AND mtss_db5_om.ind_treatment_cd :: TEXT = ntss_db5_mst_sel.code
        WHERE
            mtss_db5_om.facility_cd = @facilityCd
            AND @fromDate <= mtss_db5_om.treat_date AND mtss_db5_om.treat_date < @toDate
        ) AS date_data
    WHERE num = 1
),
ntss_db5_pem as (
  SELECT
      ntss_db5_pem.pat_id AS patid
      ,to_char(ntss_db5_pem.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
      ,to_char(ntss_db5_pem.reg_exam_date, ''YYYYMMDD'') AS examdate --検査予定日
      ,(
      CASE
                WHEN ntss_db5_pem.reg_order_class = ''0''
                    THEN (
                        CASE
                            WHEN mtss_db5_om.ord_no IS NOT NULL
                                THEN  mtss_db5_om.ind_treat_start_time
                            ELSE NULL
                        END
                )
                WHEN ntss_db5_pem.reg_order_class = ''1''
                    THEN (
                        CASE
                            WHEN mtss_db5_om.ord_no IS NOT NULL
                                THEN  to_char((mtss_db5_om.ind_treat_start_time::time + (ind_cond_info_value || '' minutes'')::interval), ''HH24MI'')
                            ELSE NULL
                        END
                )
                WHEN  ntss_db5_pem.reg_order_class = ''2''
                    THEN ntss_db5_pem_mst_ei.other_exam_time
                ELSE NULL
            END
    ) AS examtime --検査予定時刻
      ,ntss_db5_pem_mst_ei.in_hospital_cd1 AS examsetcd --検査セットNo(院内コード)
      ,ntss_db5_pem_oesi_json ->> ''set_name'' AS examsetname --検査セット名称
      ,CASE
            WHEN ntss_db5_pem.reg_order_class = ''1''
                THEN ''0''
            WHEN ntss_db5_pem.reg_order_class = ''2''
                THEN ''1''
            ELSE ''2''
        END AS examdivision --検査予定区分
      ,''1'' AS examproccd --検査実施予定コード
      ,ntss_db5_pem.ind_user_id 
      ,ntss_db5_pem.reg_staff
      ,ntss_db5_pem.up_staff
      ,ntss_db5_pem.exam_main_cd
  FROM
      pat_exam_main ntss_db5_pem
      CROSS JOIN LATERAL json_array_elements(ntss_db5_pem.order_exam_set_info::json) ntss_db5_pem_oesi_json
      LEFT JOIN mtss_db5_om
        ON to_char(ntss_db5_pem.reg_exam_date, ''YYYYMMDD'') = mtss_db5_om.treat_date
        AND ntss_db5_pem.pat_id = mtss_db5_om.pat_id
      LEFT JOIN mst_exam_set ntss_db5_pem_mst_ei
        ON ntss_db5_pem_mst_ei.exam_set_cd = cast(ntss_db5_pem_oesi_json ->> ''set_cd'' AS integer)
  WHERE
      ntss_db5_pem.facility_cd = @facilityCd
      AND @fromDate <= ntss_db5_pem.reg_exam_date AND ntss_db5_pem.reg_exam_date < @toDate
      AND ntss_db5_pem.order_exam_set_info IS NOT NULL
      AND ntss_db5_pem.order_exam_set_info <> ''[]''
)
SELECT
  '''' AS hosppatid --患者ID
    ,ntss_db5_pem.patid
    ,ntss_db5_pem.update --更新日時
    ,ntss_db5_pem.examdate --検査予定日
    ,ntss_db5_pem.examtime --検査予定時刻
    ,ntss_db5_pem.examsetcd --検査セットNo(院内コード)
    ,ntss_db5_pem.examsetname --検査セット名称
    ,ntss_db5_pem.examdivision --検査予定区分
    ,ntss_db5_pem.examproccd --検査実施予定コード
    ,ntss_db5_pem.ind_user_id AS userid
    ,'''' AS doctorcode --指示者
    ,'''' AS doctorname --指示者名
    ,ntss_db5_pem.reg_staff AS regstaff
    ,'''' AS orderstaff --スタッフコード
    ,'''' AS ordername
    ,ntss_db5_pem.up_staff AS upstaff
    ,'''' AS updatecode
    ,'''' AS updatename
    ,ntss_db5_pem.exam_main_cd AS examno --依頼番号
FROM
    ntss_db5_pem;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid,regstaff,upstaff"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);

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