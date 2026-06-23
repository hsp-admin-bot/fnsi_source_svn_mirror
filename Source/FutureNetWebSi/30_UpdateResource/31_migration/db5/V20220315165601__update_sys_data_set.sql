delete from "ntss"."sys_data_set" where "sql_cd" in (-52);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-52, 'WITH course_from_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS course_from 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
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
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
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
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
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
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
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
        , COALESCE(( CASE ord.rst_in_out_class WHEN ''0'' THEN ''1'' WHEN ''1'' THEN ''2'' ELSE NULL END ), '''')as  rst_in_out_class -- 院内コードの変換
  FROM
    pat_main AS main 
        INNER  JOIN ord_main AS ord
            on main.pat_id = ord.pat_id
    LEFT JOIN mst_ward AS ward 
      ON ward.ward_cd  = ord.rst_ward_cd
    LEFT JOIN mst_course AS course 
      ON course.course_cd  = ord.rst_course_cd
        where	
    main.pat_id =  @patId 
        and ord.ord_no = @ordNo
) 
SELECT
  CASE 
    WHEN (SELECT course_from FROM course_from_info) = ''1'' or (SELECT course_from FROM course_from_info) = ''2''
      THEN COALESCE(NULLIF((SELECT course_in_hospital_cd FROM exam_info), ''''), (SELECT course_code FROM course_code_info)) 
    ELSE (SELECT course_code FROM course_code_info) 
    END AS course_cd
  , CASE (SELECT  rst_in_out_class FROM  exam_info) WHEN ''2'' THEN
      (CASE WHEN (SELECT ward_from FROM ward_from_info) = ''1'' 
       THEN COALESCE(NULLIF((SELECT ward_in_hospital_cd FROM exam_info), ''''), (SELECT ward_code FROM ward_code_info)) 
       ELSE (SELECT ward_code FROM ward_code_info) 
       END)
    ELSE '''' END AS ward_cd', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）透析実績：診療科コードと病棟コード(-20を利用)', '2022-02-25 16:58:57.235', CURRENT_TIMESTAMP, NULL);

