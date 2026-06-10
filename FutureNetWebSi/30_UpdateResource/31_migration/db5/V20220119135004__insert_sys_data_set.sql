delete from "sys_data_set" where "sql_cd" in (-27,-28,-40,-41,-45,-46,-47,-48,-49,-50);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-27, 'WITH hosp_code_no_info AS ( 
  -- 使用院内コード番号:院内コードを指定
  SELECT
    ''0'' AS order_no 
    , CASE WHEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') IN (''1'', ''2'', ''3'')
      THEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'')
      ELSE ''1''  END AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info->>''key1'' = ''XRAY_INFO''
    AND info->>''key2'' = ''USE_IN_HOSP_NO''
  UNION
  SELECT
    ''1'' AS order_no 
    , ''1'' AS VALUE 
  ORDER BY order_no ASC LIMIT 1
)  
, examin_hosp_code_info AS ( 
  -- 放射線の院内コード
  SELECT
    info->>''key2'' AS key2 -- 放射線の院内コード
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info->>''key1'' = ''XRAY_IN_HOSP_CODE'' -- TODO：[放射線種別判定]不明、XRAY_IN_HOSP_CODEを設定する
) 
, class_attr_info AS ( 
  -- 放射線の項目属性
  SELECT
    info->>''key2'' AS key2 -- 項目属性名
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info->>''key1'' = ''XRAY_CLASS_ATTR''
)  
, class_sort_info AS ( 
  -- 放射線のソート順
  SELECT
    info->>''key2'' AS key2 -- 項目ソート順
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info->>''key1'' = ''XRAY_CLASS_SORT''
) 
, data_info AS (
  SELECT
    ''撮影項目'' AS detail_id
    , CASE (SELECT VALUE FROM hosp_code_no_info) 
      WHEN ''1'' THEN mset.in_hospital_cd1
      WHEN ''2'' THEN mset.in_hospital_cd2
      WHEN ''3'' THEN mset.in_hospital_cd3
      ELSE mset.in_hospital_cd1
      END AS in_hospital_cd1
    , COALESCE(NULLIF((SELECT VALUE FROM class_attr_info WHERE key2 = mset.rad_set_name), ''''), ''---'') AS sbt_cd1
    , COALESCE(NULLIF(mset.rad_set_name, ''''), ''不明'') AS item_name
    , ''不明'' AS tag_name

    , TO_NUMBER(COALESCE(NULLIF((SELECT VALUE FROM class_sort_info WHERE key2 = mset.rad_set_name), ''''), ''999''), ''FM999'') AS order_no
    , mset.rad_set_cd
  FROM
    pat_rad_main AS rad 
    CROSS JOIN LATERAL json_array_elements(rad.order_rad_set_info ::json) info 
    LEFT OUTER JOIN mst_rad_set AS mset ON TO_NUMBER(info ->> ''rad_set_cd'', ''FM999999999'') = mset.rad_set_cd 
  WHERE
    rad.is_del = ''0'' 
    AND rad.rad_result_cd = @ordNo 
    AND jsonb_array_length(rad.order_rad_set_info) > 0 
  ORDER BY rad_set_cd, order_no ASC
)
SELECT
  ''撮影項目'' AS detail_id
  , in_hospital_cd1
  , sbt_cd1
  , item_name
  , tag_name
FROM
  data_info
WHERE
  AND COALESCE(NULLIF(in_hospital_cd1, ''''), ''no_cd'') <> ''no_cd'' 
  AND ((SELECT COUNT(1) FROM examin_hosp_code_info) = 0 -- 検体検査の院内コードを設定が存在しない場合は全て送信対象とする。
   OR EXISTS (SELECT 1 FROM examin_hosp_code_info AS hosp WHERE COALESCE(NULLIF(in_hospital_cd1, ''''), ''no_cd'') = hosp.key2)
    -- 院内コードをキーとして連携IDを設定するの場合は送信対象とする。
  )
ORDER BY
  order_no ASC
LIMIT 299 ', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）放射線：撮影繰り返し部', '2022-01-19 18:29:49', '2022-01-19 18:29:49', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-28, 'SELECT
  MAX(CASE part WHEN ''comm'' THEN staff_cd ELSE '''' END) staff_cd_comm
  , MAX(CASE part WHEN ''data'' THEN staff_cd ELSE '''' END) staff_cd_data 
FROM
  ( 
    ( 
      SELECT
        ''comm'' AS part
        , order_no
        , staffs.staff_cd 
      FROM
        ( 
          SELECT
            0 AS order_no
            , TO_CHAR(pem.ind_user_id, ''FM9999999999'') AS staff_cd 
          FROM
            pat_rad_main pem 
          WHERE
            pem.rad_result_cd = @ordNo 
          UNION 
          SELECT
            1 AS order_no
            , staff ->> ''staff_cd'' AS staff_cd 
          FROM
            pat_main pm 
            CROSS JOIN LATERAL json_array_elements(pm.charge_staff_info ::json) staff 
          WHERE
            staff ->> ''is_main'' = ''1'' 
            AND pm.pat_id = @patId 
          UNION 
          SELECT
            3 AS order_no
            , TO_CHAR(pem.up_staff, ''FM9999999999'') AS staff_cd 
          FROM
            pat_rad_main pem 
          WHERE
            pem.rad_result_cd = @ordNo 
          UNION 
          SELECT
            6 AS order_no
            , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
          FROM
            mst_coop_ini AS ini 
            CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
          WHERE
            facility_cd = @facilityCd 
            AND is_del = ''0'' 
            AND info ->> ''key1'' = ''FJI_COM_INFO'' 
            AND info ->> ''key2'' = ''EXAM_DEFAULT_USER_NO'' 
          UNION 
          SELECT
            9 AS order_no
            , '''' AS staff_cd
        ) staffs 
      WHERE (NULLIF(staff_cd, '''') IS NOT NULL AND order_no <> 9) OR (order_no = 9) 
      ORDER BY order_no ASC LIMIT 1
    ) 
    UNION ( 
      SELECT
        ''data'' AS part
        , order_no
        , staffs.staff_cd 
      FROM
        ( 
          SELECT
            0 AS order_no
            , TO_CHAR(pem.ind_user_id, ''FM9999999999'') AS staff_cd 
          FROM
            pat_rad_main pem 
          WHERE
            pem.rad_result_cd = @ordNo 
          UNION 
          SELECT
            1 AS order_no
            , staff ->> ''staff_cd'' AS staff_cd 
          FROM
            pat_main pm 
            CROSS JOIN LATERAL json_array_elements(pm.charge_staff_info ::json) staff 
          WHERE
            staff ->> ''is_main'' = ''1'' 
            AND pm.pat_id = @patId 
          UNION 
          SELECT
            6 AS order_no
            , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
          FROM
            mst_coop_ini AS ini 
            CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
          WHERE
            facility_cd = @facilityCd 
            AND is_del = ''0'' 
            AND info ->> ''key1'' = ''FJI_COM_INFO'' 
            AND info ->> ''key2'' = ''EXAM_DEFAULT_USER_NO'' 
          UNION 
          SELECT
            9 AS order_no
            , '''' AS staff_cd
        ) staffs 
      WHERE (NULLIF(staff_cd, '''') IS NOT NULL AND order_no <> 9) OR (order_no = 9) 
      ORDER BY order_no ASC LIMIT 1
    )
  ) AS T', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）放射線：撮影依頼者', '2022-01-19 18:29:49', '2022-01-19 18:29:49', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-40, 'WITH order_time_type_info AS ( 
  -- オーダ時間の設定値に応じた時間
  SELECT
    0 AS order_no
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS order_time_type 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info->>''key1'' = ''XRAY_INFO''
    AND info->>''key2'' = ''SET_ORDER_TIME_TYPE''
  UNION
  SELECT
    1 AS order_no
    , ''0'' AS order_time_type 
  ORDER BY order_no ASC LIMIT 1
) 
, margin_time_info AS ( 
  -- 検査時刻マージン時間:透析前/透析後マージン時間
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS margin_time 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info->>''key1'' = ''EXAM_MARGIN_TIME''
    AND info->>''key2'' IN (''DIAL_AFTER'', ''DIAL_BEFORE'')
) 
, data_info AS (
  SELECT
    TO_CHAR(pem.reg_rad_date, ''YYYYMMDD'') AS exam_date
    , pem.reg_order_class
    , ( 
      CASE pem.reg_order_class 
        WHEN ''1'' THEN COALESCE(ord.ind_treat_start_time, ''0000'') 
        WHEN ''2'' THEN COALESCE(TO_CHAR(TO_TIMESTAMP(ord.treat_date || '' '' || SUBSTRING(ord.ind_treat_start_time, 1, 2) || '':'' || SUBSTRING(ord.ind_treat_start_time, 3, 2) || '':00'', ''YYYYMMDD HH24:MI:SS'') + (INTERVAL ''1minute'' * TO_NUMBER(COALESCE(NULLIF(ord.ind_cond_info -> ''1'' ->> ''value'', ''''), ''0''), ''FM999999'')), ''HH24MI''), ''0000'') 
        ELSE ''0000'' 
        END
    ) AS exam_start_time
    , COALESCE(ord.ind_treat_start_time, ''9999'') AS sort_no 
  FROM
    pat_rad_main pem 
    LEFT OUTER JOIN ord_main AS ord ON ord.pat_id = pem.pat_id AND ord.treat_date = TO_CHAR(pem.reg_rad_date, ''YYYYMMDD'') 
  WHERE
    rad_result_cd = @ordNo
  ORDER BY sort_no ASC LIMIT 1
)
-- オーダ時間設定が「1」の場合、検査区分に従い以下の時間を設定します。
SELECT 
  1 AS order_no
  , exam_date
  , CASE reg_order_class 
    WHEN ''1'' THEN TO_CHAR(TO_TIMESTAMP(exam_date || exam_start_time || ''00'', ''YYYYMMDDHH24MISS'') - (INTERVAL ''1minute'' * TO_NUMBER(COALESCE(NULLIF((SELECT margin_time FROM margin_time_info WHERE key2 = ''DIAL_BEFORE''), ''''), ''0''), ''FM999999'')), ''HH24MISS'')
    WHEN ''2'' THEN TO_CHAR(TO_TIMESTAMP(exam_date || exam_start_time || ''00'', ''YYYYMMDDHH24MISS'') + (INTERVAL ''1minute'' * TO_NUMBER(COALESCE(NULLIF((SELECT margin_time FROM margin_time_info WHERE key2 = ''DIAL_AFTER''), ''''), ''0''), ''FM999999'')), ''HH24MISS'')
    ELSE data_info.exam_start_time || ''00''
    END AS exam_start_time
FROM 
  data_info
WHERE 
  (SELECT order_time_type FROM order_time_type_info) = ''1''
  AND COALESCE(NULLIF(exam_start_time, ''''), ''0000'') <> ''0000''
-- オーダ時間設定が「2」の場合、検査予定時間を設定します。
UNION
SELECT
  2 AS order_no 
  , exam_date
  , ''777700'' AS exam_start_time  -- TODO:検査予定時間 が無し、777700を設定する
FROM 
  data_info
WHERE 
  (SELECT order_time_type FROM order_time_type_info) = ''2''
-- オーダ時間設定が「0」の場合、「777700」固定を設定します。
UNION
SELECT 
  3 AS order_no
  , exam_date
  , ''777700'' AS exam_start_time
FROM 
  data_info
ORDER BY order_no ASC LIMIT 1
', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）放射線：検査日時取得', '2022-01-19 18:29:49', '2022-01-19 18:29:49', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-41, 'WITH course_from_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS course_from 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''XRAY_INFO'' 
    AND info ->> ''key2'' = ''COURSE'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS course_from 
  ORDER BY
    order_no ASC LIMIT 1
) 
, course_code_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS course_code 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''XRAY_INFO'' 
    AND info ->> ''key2'' = ''COURSE_CODE'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS course_code 
  ORDER BY
    order_no ASC LIMIT 1
) 
, ward_from_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS ward_from 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''XRAY_INFO'' 
    AND info ->> ''key2'' = ''WARD'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS ward_from 
  ORDER BY
    order_no ASC LIMIT 1
) 
, ward_code_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS ward_code 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''XRAY_INFO'' 
    AND info ->> ''key2'' = ''WARD_CODE'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS ward_code 
  ORDER BY
    order_no ASC LIMIT 1
) 
, exam_info AS ( 
  SELECT
    medical_care_info ->> ''ward_cd'' AS ward_cd
    , ward.ward_name AS ward_name
    , ward.in_hospital_cd_1 AS ward_in_hospital_cd
    , medical_care_info ->> ''main_course_cd'' AS main_course_cd
    , course.course_name AS course_name
    , course.in_hospital_cd_1 AS course_in_hospital_cd 
  FROM
    pat_main AS main 
    LEFT JOIN mst_ward AS ward 
      ON ward.ward_cd ::TEXT = main.medical_care_info ->> ''ward_cd'' 
    LEFT JOIN mst_course AS course 
      ON course.course_cd ::TEXT = main.medical_care_info ->> ''main_course_cd'' 
  WHERE
    main.pat_id = @patId 
) 
SELECT
  CASE 
    WHEN (SELECT course_from FROM course_from_info) = ''1'' 
      THEN COALESCE(NULLIF((SELECT course_in_hospital_cd FROM exam_info), ''''), (SELECT course_code FROM course_code_info)) 
    ELSE (SELECT course_code FROM course_code_info) 
    END AS course_cd
  , CASE 
    WHEN (SELECT ward_from FROM ward_from_info) = ''1'' 
      THEN COALESCE(NULLIF((SELECT ward_in_hospital_cd FROM exam_info), ''''), (SELECT ward_code FROM ward_code_info)) 
    ELSE (SELECT ward_code FROM ward_code_info) 
    END AS ward_cd', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）放射線：診療科コードと病棟コード', '2022-01-19 18:29:49', '2022-01-19 18:29:49', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-45, 'WITH order_time_type_info AS ( 
  -- オーダ時間の設定値に応じた時間
  SELECT
    0 AS order_no
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS order_time_type 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info->>''key1'' = ''XRAY_INFO''
    AND info->>''key2'' = ''SET_ORDER_TIME_TYPE''
  UNION
  SELECT
    1 AS order_no
    , ''0'' AS order_time_type 
  ORDER BY order_no ASC LIMIT 1
)
, margin_time_info AS ( 
  -- 検査時刻マージン時間:透析前/透析後マージン時間
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS margin_time 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info->>''key1'' = ''EXAM_MARGIN_TIME''
    AND info->>''key2'' IN (''DIAL_AFTER'', ''DIAL_BEFORE'')
) 
, data_info AS (
  SELECT
    TO_CHAR(pem.reg_rad_date, ''YYYYMMDD'') AS exam_date
    , pem.reg_order_class
    , ( 
      CASE pem.reg_order_class 
        WHEN ''1'' THEN COALESCE(ord.ind_treat_start_time, ''0000'') 
        WHEN ''2'' THEN COALESCE(TO_CHAR(TO_TIMESTAMP(ord.treat_date || '' '' || SUBSTRING(ord.ind_treat_start_time, 1, 2) || '':'' || SUBSTRING(ord.ind_treat_start_time, 3, 2) || '':00'', ''YYYYMMDD HH24:MI:SS'') + (INTERVAL ''1minute'' * TO_NUMBER(COALESCE(NULLIF(ord.ind_cond_info -> ''1'' ->> ''value'', ''''), ''0''), ''FM999999'')), ''HH24MI''), ''0000'') 
        ELSE ''0000'' 
        END
    ) AS exam_start_time
    , COALESCE(ord.ind_treat_start_time, ''9999'') AS sort_no 
  FROM
    pat_rad_main_hst pem 
    LEFT OUTER JOIN ord_main AS ord ON ord.pat_id = pem.pat_id AND ord.treat_date = TO_CHAR(pem.reg_rad_date, ''YYYYMMDD'') 
  WHERE
    rad_result_cd = @ordNo
  ORDER BY sort_no ASC LIMIT 1
)
-- オーダ時間設定が「1」の場合、検査区分に従い以下の時間を設定します。
SELECT 
  1 AS order_no
  , exam_date
  , CASE reg_order_class 
    WHEN ''1'' THEN TO_CHAR(TO_TIMESTAMP(exam_date || exam_start_time || ''00'', ''YYYYMMDDHH24MISS'') - (INTERVAL ''1minute'' * TO_NUMBER(COALESCE(NULLIF((SELECT margin_time FROM margin_time_info WHERE key2 = ''DIAL_BEFORE''), ''''), ''0''), ''FM999999'')), ''HH24MISS'')
    WHEN ''2'' THEN TO_CHAR(TO_TIMESTAMP(exam_date || exam_start_time || ''00'', ''YYYYMMDDHH24MISS'') + (INTERVAL ''1minute'' * TO_NUMBER(COALESCE(NULLIF((SELECT margin_time FROM margin_time_info WHERE key2 = ''DIAL_AFTER''), ''''), ''0''), ''FM999999'')), ''HH24MISS'')
    ELSE data_info.exam_start_time || ''00''
    END AS exam_start_time
FROM 
  data_info
WHERE 
  (SELECT order_time_type FROM order_time_type_info) = ''1''
  AND COALESCE(NULLIF(exam_start_time, ''''), ''0000'') <> ''0000''
-- オーダ時間設定が「2」の場合、検査予定時間を設定します。
UNION
SELECT
  2 AS order_no 
  , exam_date
  , ''777700'' AS exam_start_time  -- TODO:検査予定時間 が無し、777700を設定する
FROM 
  data_info
WHERE 
  (SELECT order_time_type FROM order_time_type_info) = ''2''
-- オーダ時間設定が「0」の場合、「777700」固定を設定します。
UNION
SELECT 
  3 AS order_no
  , exam_date
  , ''777700'' AS exam_start_time
FROM 
  data_info
ORDER BY order_no ASC LIMIT 1
', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）放射線：検査日時取得 ★削除用', '2022-01-19 18:29:49', '2022-01-19 18:29:49', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-46, 'WITH hosp_code_no_info AS ( 
  -- 使用院内コード番号:院内コードを指定
  SELECT
    ''0'' AS order_no 
    , CASE WHEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') IN (''1'', ''2'', ''3'')
      THEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'')
      ELSE ''1''  END AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info->>''key1'' = ''XRAY_INFO''
    AND info->>''key2'' = ''USE_IN_HOSP_NO''
  UNION
  SELECT
    ''1'' AS order_no 
    , ''1'' AS VALUE 
  ORDER BY order_no ASC LIMIT 1
)  
, examin_hosp_code_info AS ( 
  -- 放射線の院内コード
  SELECT
    info->>''key2'' AS key2 -- 放射線の院内コード
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info->>''key1'' = ''XRAY_IN_HOSP_CODE'' -- TODO：[放射線種別判定]不明、XRAY_IN_HOSP_CODEを設定する
) 
, class_attr_info AS ( 
  -- 放射線の項目属性
  SELECT
    info->>''key2'' AS key2 -- 項目属性名
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info->>''key1'' = ''XRAY_CLASS_ATTR''
)  
, class_sort_info AS ( 
  -- 放射線のソート順
  SELECT
    info->>''key2'' AS key2 -- 項目ソート順
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info->>''key1'' = ''XRAY_CLASS_SORT''
) 
, data_info AS (
  SELECT
    ''撮影項目'' AS detail_id
    , CASE (SELECT VALUE FROM hosp_code_no_info) 
      WHEN ''1'' THEN mset.in_hospital_cd1
      WHEN ''2'' THEN mset.in_hospital_cd2
      WHEN ''3'' THEN mset.in_hospital_cd3
      ELSE mset.in_hospital_cd1
      END AS in_hospital_cd1
    , COALESCE(NULLIF((SELECT VALUE FROM class_attr_info WHERE key2 = mset.rad_set_name), ''''), ''---'') AS sbt_cd1
    , COALESCE(NULLIF(mset.rad_set_name, ''''), ''不明'') AS item_name
    , ''不明'' AS tag_name

    , TO_NUMBER(COALESCE(NULLIF((SELECT VALUE FROM class_sort_info WHERE key2 = mset.rad_set_name), ''''), ''999''), ''FM999'') AS order_no
    , mset.rad_set_cd
  FROM
    pat_rad_main_hst AS rad 
    CROSS JOIN LATERAL json_array_elements(rad.order_rad_set_info ::json) info 
    LEFT OUTER JOIN mst_rad_set AS mset ON TO_NUMBER(info ->> ''rad_set_cd'', ''FM999999999'') = mset.rad_set_cd 
  WHERE
    --rad.is_del = ''0'' 
    rad.rad_result_cd = @ordNo 
    AND jsonb_array_length(rad.order_rad_set_info) > 0 
  ORDER BY rad_set_cd, order_no ASC
)
SELECT
  ''撮影項目'' AS detail_id
  , in_hospital_cd1
  , sbt_cd1
  , item_name
  , tag_name
FROM
  data_info
WHERE
  AND COALESCE(NULLIF(in_hospital_cd1, ''''), ''no_cd'') <> ''no_cd'' 
  AND ((SELECT COUNT(1) FROM examin_hosp_code_info) = 0 -- 検体検査の院内コードを設定が存在しない場合は全て送信対象とする。
   OR EXISTS (SELECT 1 FROM examin_hosp_code_info AS hosp WHERE COALESCE(NULLIF(in_hospital_cd1, ''''), ''no_cd'') = hosp.key2)
    -- 院内コードをキーとして連携IDを設定するの場合は送信対象とする。
  )
ORDER BY
  order_no ASC
LIMIT 299 ', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）放射線：撮影繰り返し部 ★削除用', '2022-01-19 18:29:49', '2022-01-19 18:29:49', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-47, 'SELECT
  MAX(CASE part WHEN ''comm'' THEN staff_cd ELSE '''' END) staff_cd_comm
  , MAX(CASE part WHEN ''data'' THEN staff_cd ELSE '''' END) staff_cd_data 
FROM
  ( 
    ( 
      SELECT
        ''comm'' AS part
        , order_no
        , staffs.staff_cd 
      FROM
        ( 
          SELECT
            0 AS order_no
            , TO_CHAR(pem.ind_user_id, ''FM9999999999'') AS staff_cd 
          FROM
            pat_rad_main_hst pem 
          WHERE
            pem.rad_result_cd = @ordNo 
          UNION 
          SELECT
            1 AS order_no
            , staff ->> ''staff_cd'' AS staff_cd 
          FROM
            pat_main pm 
            CROSS JOIN LATERAL json_array_elements(pm.charge_staff_info ::json) staff 
          WHERE
            staff ->> ''is_main'' = ''1'' 
            AND pm.pat_id = @patId 
          UNION 
          SELECT
            3 AS order_no
            , TO_CHAR(pem.up_staff, ''FM9999999999'') AS staff_cd 
          FROM
            pat_rad_main_hst pem 
          WHERE
            pem.rad_result_cd = @ordNo 
          UNION 
          SELECT
            6 AS order_no
            , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
          FROM
            mst_coop_ini AS ini 
            CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
          WHERE
            facility_cd = @facilityCd 
            AND is_del = ''0'' 
            AND info ->> ''key1'' = ''FJI_COM_INFO'' 
            AND info ->> ''key2'' = ''EXAM_DEFAULT_USER_NO'' 
          UNION 
          SELECT
            9 AS order_no
            , '''' AS staff_cd
        ) staffs 
      WHERE (NULLIF(staff_cd, '''') IS NOT NULL AND order_no <> 9) OR (order_no = 9) 
      ORDER BY order_no ASC LIMIT 1
    ) 
    UNION ( 
      SELECT
        ''data'' AS part
        , order_no
        , staffs.staff_cd 
      FROM
        ( 
          SELECT
            0 AS order_no
            , TO_CHAR(pem.ind_user_id, ''FM9999999999'') AS staff_cd 
          FROM
            pat_rad_main_hst pem 
          WHERE
            pem.rad_result_cd = @ordNo 
          UNION 
          SELECT
            1 AS order_no
            , staff ->> ''staff_cd'' AS staff_cd 
          FROM
            pat_main pm 
            CROSS JOIN LATERAL json_array_elements(pm.charge_staff_info ::json) staff 
          WHERE
            staff ->> ''is_main'' = ''1'' 
            AND pm.pat_id = @patId 
          UNION 
          SELECT
            6 AS order_no
            , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
          FROM
            mst_coop_ini AS ini 
            CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
          WHERE
            facility_cd = @facilityCd 
            AND is_del = ''0'' 
            AND info ->> ''key1'' = ''FJI_COM_INFO'' 
            AND info ->> ''key2'' = ''EXAM_DEFAULT_USER_NO'' 
          UNION 
          SELECT
            9 AS order_no
            , '''' AS staff_cd
        ) staffs 
      WHERE (NULLIF(staff_cd, '''') IS NOT NULL AND order_no <> 9) OR (order_no = 9) 
      ORDER BY order_no ASC LIMIT 1
    )
  ) AS T', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）放射線：撮影依頼者 ★削除用', '2022-01-19 18:29:49', '2022-01-19 18:29:49', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-48, 'SELECT
  ''0'' AS order_no 
  , CASE WHEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') = ''1'' 
    THEN ''01''
    ELSE ''00'' 
    END AS document_no 
FROM
  mst_coop_ini AS ini 
  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
WHERE
  facility_cd = @facilityCd 
  AND is_del = ''0'' 
  AND info->>''key1'' = ''FJI_COM_INFO''
  AND info->>''key2'' = ''DOCUMENT_NO_SETTING''
UNION
SELECT
  ''1'' AS order_no 
  , ''00'' AS document_no 
ORDER BY order_no ASC LIMIT 1', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）文書番号末尾設定取得 ', '2022-01-19 18:29:49', '2022-01-19 18:29:49', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-49, 'SELECT
  MAX(CASE T01.key2 when ''SLIP_CODE'' THEN T01.value ELSE null END) AS slip_code
  , MAX(CASE T01.key2 when ''SLIP_NAME'' THEN T01.value ELSE null END) AS slip_name
FROM
(
  (
    SELECT
      ''0'' AS order_no 
      , ''SLIP_CODE'' AS key2 
      , COALESCE(NULLIF(info->>''value'', ''''), COALESCE(NULLIF(info->>''default_v'', ''''), ''E001'')) AS value 
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
    WHERE
      facility_cd = @facilityCd 
      AND is_del = ''0'' 
      AND info->>''key1'' = ''EXAMIN_INFO''
      AND info->>''key2'' = ''SLIP_CODE''
    UNION
    SELECT
      ''1'' AS order_no 
      , ''SLIP_CODE'' AS key2 
      , ''E001'' AS value 
    ORDER BY order_no ASC LIMIT 1
  )
  UNION
  (
    SELECT
      ''0'' AS order_no 
      , ''SLIP_NAME'' AS key2 
      , COALESCE(NULLIF(info->>''value'', ''''), COALESCE(NULLIF(info->>''default_v'', ''''), ''透析発生検査'')) AS value 
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
    WHERE
      facility_cd = @facilityCd 
      AND is_del = ''0'' 
      AND info->>''key1'' = ''EXAMIN_INFO''
      AND info->>''key2'' = ''SLIP_NAME''
    UNION
    SELECT
      ''1'' AS order_no 
      , ''SLIP_NAME'' AS key2 
      , ''透析発生検査'' AS value 
    ORDER BY order_no ASC LIMIT 1
  )
) AS T01', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）検査依頼：伝票情報取得', '2022-01-19 18:29:49', '2022-01-19 18:29:49', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-50, 'SELECT
  MAX(CASE T01.key2 when ''SLIP_CODE'' THEN T01.value ELSE null END) AS slip_code
  , MAX(CASE T01.key2 when ''SLIP_NAME'' THEN T01.value ELSE null END) AS slip_name
FROM
(
  (
    SELECT
      ''0'' AS order_no 
      , ''SLIP_CODE'' AS key2 
      , COALESCE(NULLIF(info->>''value'', ''''), COALESCE(NULLIF(info->>''default_v'', ''''), ''F010'')) AS value 
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
    WHERE
      facility_cd = @facilityCd 
      AND is_del = ''0'' 
      AND info->>''key1'' = ''XRAY_INFO''
      AND info->>''key2'' = ''SLIP_CODE''
    UNION
    SELECT
      ''1'' AS order_no 
      , ''SLIP_CODE'' AS key2 
      , ''F010'' AS value 
    ORDER BY order_no ASC LIMIT 1
  )
  UNION
  (
    SELECT
      ''0'' AS order_no 
      , ''SLIP_NAME'' AS key2 
      , COALESCE(NULLIF(info->>''value'', ''''), COALESCE(NULLIF(info->>''default_v'', ''''), ''病院一般撮影'')) AS value 
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
    WHERE
      facility_cd = @facilityCd 
      AND is_del = ''0'' 
      AND info->>''key1'' = ''XRAY_INFO''
      AND info->>''key2'' = ''SLIP_NAME''
    UNION
    SELECT
      ''1'' AS order_no 
      , ''SLIP_NAME'' AS key2 
      , ''病院一般撮影'' AS value 
    ORDER BY order_no ASC LIMIT 1
  )
) AS T01', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）放射線：伝票情報取得 ', '2022-01-19 18:29:49', '2022-01-19 18:29:49', NULL);
