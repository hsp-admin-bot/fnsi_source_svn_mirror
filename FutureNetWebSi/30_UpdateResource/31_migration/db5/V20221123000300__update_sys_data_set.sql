delete from ntss.sys_data_set where sql_cd = '1203';
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1203, 'WITH take_cource_info AS (SELECT 1 AS order_no
                               , CASE TRIM(ini_info ->> ''value'')
                                     WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''1'')
                                     ELSE TRIM(ini_info ->> ''value'')
        END                        AS take_cource_flg
                          FROM mst_coop_ini AS ini
                                   CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info
                          WHERE ini.is_del = ''0''
                            AND ini.facility_cd = ''@facilityCd''
                            AND TRIM(ini_info ->> ''key1'') = ''PATIENT_SEND''
                            AND TRIM(ini_info ->> ''key2'') = ''IS_TAKE_COURCE_FLG''
                          UNION
                          SELECT 2   AS order_no
                               , ''1'' AS take_cource_flg
                          ORDER BY order_no ASC
                          LIMIT 1),
     cource_ward_info AS (SELECT (CASE
                                      WHEN (SELECT take_cource_flg FROM take_cource_info) = ''1'' AND
                                           (''@inOutClass'') = ''1'' -- ''1''：入院
                                          THEN ''@medicalCareInfo.mainCourseCd''
                                      ELSE medical_care_info ->> ''main_course_cd''
         END) :: TEXT                                                     AS main_course_cd
                               , (case ''@medicalCareInfo.wardCd''
                                      when '''' then medical_care_info ->> ''ward_cd''
                                      else ''@medicalCareInfo.wardCd'' end) AS ward_cd
                          FROM pat_main
                          WHERE is_del = ''0''
                            AND pat_id = @patId)
UPDATE pat_main
SET up_date              = CURRENT_TIMESTAMP
  , in_out_current_state = (case ''@isDie'' when ''1'' then ''11'' else in_out_current_state end)
  , medical_care_info    = json_build_object(
        ''main_course_cd''
    , TO_NUMBER(NULLIF((SELECT main_course_cd FROM cource_ward_info), ''''), ''FM999999999'')
    , ''dialysis_course_cd''
    , medical_care_info -> ''dialysis_course_cd''
    , ''ward_cd''
    , TO_NUMBER(NULLIF((SELECT ward_cd FROM cource_ward_info), ''''), ''FM999999999'')
    , ''dialysis_count''
    , medical_care_info -> ''dialysis_count''
    , ''purification_count''
    , medical_care_info -> ''purification_count''
    , ''other_dialysis_count''
    , medical_care_info -> ''other_dialysis_count''
    , ''pat_dialysis_count''
    , medical_care_info -> ''pat_dialysis_count''
    , ''facility_cd''
    , medical_care_info ->> ''facility_cd''
    , ''dialysis_start_date''
    , medical_care_info ->> ''dialysis_start_date''
    , ''hospital_start_date''
    , medical_care_info ->> ''hospital_start_date''
    )
WHERE is_del = ''0''
  AND pat_id = @patId', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)富士通の患者プロファイル_患者基本情報の修正', '2022-01-28 18:21:40.000', CURRENT_TIMESTAMP, null);
