DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-436);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-436, '-- 【SQL_CD=-436】
 WITH sch_start_time_info AS (
  SELECT
    0 AS order_no 
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS start_time_kbn 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND COALESCE(info->>''key0'','''') = @key0
    AND info ->> ''key1'' = ''COOP_CONFIG'' 
    AND info ->> ''key2'' = ''SCH_START_TIME'' 
  UNION
  SELECT
    1 AS order_no 
    , ''0'' AS start_time_kbn 
  ORDER BY order_no ASC LIMIT 1
)
, staff_info AS (
   SELECT ROW_NUMBER( ) OVER ( ORDER BY info ->> ''is_main'' DESC,  info ->> ''is_charge'' DESC,  info ->> ''is_puncture'' DESC, info ->> ''ctl_no'' ASC ) AS CNT,
     info ->> ''staff_cd'' AS staff_cd 
   FROM
     pat_main AS pat
     LEFT JOIN LATERAL json_array_elements ( pat.charge_staff_info :: json ) info ON info ->> ''ctl_no'' IS NOT NULL 
   WHERE
     pat.pat_id = @patId 
   )
 SELECT
    ord.treat_date AS treat_date,
    ord.ind_treat_start_time AS start_time,
    -- クールマスタ
    ord.ind_kur_cd AS kur_cd,
    mkr.kur_name AS kur_name,
    COALESCE(TRIM(mkr.in_hospital_cd_1), cast(mkr.kur_cd as VARCHAR)) AS kur_cd1,
    LEFT ( mkr.kur_standard_start_time, 4 ) AS kur_standard_start_time,
    CASE WHEN (SELECT start_time_kbn FROM sch_start_time_info) = ''0''
    THEN mkr.kur_standard_start_time
    ELSE ord.ind_treat_start_time || ''00''
    END AS kur_standard_start_time_6,
    -- ベッドマスタ
    ord.ind_bed_cd AS bed_cd,
    mbd.bed_name AS bed_name,
    COALESCE(TRIM(mbd.in_hospital_cd_1), cast(mbd.bed_cd as VARCHAR)) AS bed_cd1,
    -- 診療科マスタ
    pat.medical_care_info ->> ''main_course_cd'' AS course_cd,
    course.course_name AS course_name,
    COALESCE(TRIM(course.in_hospital_cd_1), cast(course.course_cd as VARCHAR)) AS course_cd1,
    -- 医師1
    staff1.staff_cd AS staff_cd1,
    -- 医師2
    staff2.staff_cd AS staff_cd2 
 FROM
    pat_main AS pat
    LEFT JOIN ord_main AS ord ON pat.pat_id = ord.pat_id AND ord.ord_no = @ordNo
    LEFT JOIN staff_info AS staff1 ON staff1.CNT = 1
    LEFT JOIN staff_info AS staff2 ON staff2.CNT = 2
    LEFT JOIN mst_kur AS mkr ON mkr.kur_cd = ord.ind_kur_cd 
    LEFT JOIN mst_bed AS mbd ON mbd.bed_cd = ord.ind_bed_cd
    LEFT JOIN mst_course AS course ON course.course_cd ::TEXT = pat.medical_care_info ->> ''main_course_cd''
  WHERE
    pat.pat_id = @patId ', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析予約(連携電文の透析スケジュール)', '2023-09-27 16:27:39.853', CURRENT_TIMESTAMP, NULL);