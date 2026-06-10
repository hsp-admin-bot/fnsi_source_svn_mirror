delete from "sys_data_set" where "sql_cd" in (9506,9505,9504,9503,9502,9501,7206,1203,1202);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9506, 'WITH taboo_allergy_nec AS ( 
  SELECT
    COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''0'') AS ctl_no
    , COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''0'') AS disp_order
    , A.CONTENT
    , ''@tabooAllergyInfo.memo'' AS memo
    , ''0'' AS category_class
    , ''1'' AS taboo_allergy_class
    , A.taboo_allergy_cd ::TEXT AS taboo_allergy_cd 
  FROM
    mst_taboo_allergy A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      WHERE
        facility_cd = ''@facilityCd'' 
        AND master_physical_name = ''mst_taboo_allergy''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.taboo_allergy_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
    AND ( A.in_hospital_cd_1 = ''@tabooAllergyInfo.inHospitalCd'') 
  UNION 
  SELECT
    COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''0'') AS ctl_no
    , COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''0'') AS disp_order
    , ''@tabooAllergyInfo.content'' AS CONTENT
    , ''@tabooAllergyInfo.memo'' AS memo
    , ''0'' AS category_class
    , ''1'' AS taboo_allergy_class
    , ''0'' AS taboo_allergy_cd 
  ORDER BY
    taboo_allergy_cd DESC LIMIT 1
) 
, tabooAllergyInfo AS ( 
  SELECT
    (idx - 1) AS idx
    , ms ->> ''ctl_no'' AS ctl_no
    , ms ->> ''disp_order'' AS disp_order
    , nec.CONTENT AS CONTENT
    , nec.memo AS memo
    , ms ->> ''category_class'' AS category_class
    , ms ->> ''taboo_allergy_class'' AS taboo_allergy_class
    , ms ->> ''taboo_allergy_cd'' AS taboo_allergy_cd 
  FROM
    pat_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.taboo_allergy_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
    INNER JOIN taboo_allergy_nec AS nec ON nec.taboo_allergy_cd = ms ->> ''taboo_allergy_cd'' AND ms ->> ''taboo_allergy_cd'' != ''0'' 
  WHERE
    A.is_del = ''0'' 
    AND A.facility_cd = ''@facilityCd'' 
    AND A.pat_id = @patId 
  UNION 
  SELECT
    NULL AS idx
    , nec.* 
  FROM
    taboo_allergy_nec AS nec 
  ORDER BY
    idx ASC NULLS LAST LIMIT 1
) 
UPDATE pat_main 
SET
  taboo_allergy_info = jsonb_set( 
    COALESCE(taboo_allergy_info, ''[]'') ::JSONB
    , CAST( 
      ( 
        SELECT
          ''{'' || COALESCE(idx, 999) || ''}'' 
        FROM
          tabooAllergyInfo
      ) AS TEXT []
    ) 
    , CAST( 
      ( 
        SELECT
          ''{"ctl_no":'' || ctl_no || '', "disp_order":'' || disp_order || '', "content":"'' || CONTENT || ''", "memo":"''
           || memo || ''", "category_class":"'' || category_class || ''", "taboo_allergy_class":"'' || taboo_allergy_class
           || ''", "taboo_allergy_cd":'' || taboo_allergy_cd || ''}'' 
        FROM
          tabooAllergyInfo
      ) AS JSONB
    ) ::JSONB
  ) 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECiSの患者属性連携_禁忌・アレルギー情報(薬剤禁忌)の更新', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9505, 'WITH taboo_allergy_nec AS ( 
  SELECT
    COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''0'') AS ctl_no
    , COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''0'') AS disp_order
    , A.CONTENT
    , ''@tabooAllergyInfo.memo'' AS memo
    , ''0'' AS category_class
    , ''1'' AS taboo_allergy_class
    , A.taboo_allergy_cd ::TEXT AS taboo_allergy_cd 
  FROM
    mst_taboo_allergy A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      WHERE
        facility_cd = ''@facilityCd'' 
        AND master_physical_name = ''mst_taboo_allergy''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.taboo_allergy_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
    AND ( A.in_hospital_cd_1 = ''@tabooAllergyInfo.content'' OR A.CONTENT = ''@tabooAllergyInfo.content'') 
  UNION 
  SELECT
    COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''0'') AS ctl_no
    , COALESCE(NULLIF(''@nextCtlNo3'', ''''), ''0'') AS disp_order
    , ''@tabooAllergyInfo.content'' AS CONTENT
    , ''@tabooAllergyInfo.memo'' AS memo
    , ''0'' AS category_class
    , ''1'' AS taboo_allergy_class
    , ''0'' AS taboo_allergy_cd 
  ORDER BY
    taboo_allergy_cd DESC LIMIT 1
) 
, tabooAllergyInfo AS ( 
  SELECT
    (idx - 1) AS idx
    , ms ->> ''ctl_no'' AS ctl_no
    , ms ->> ''disp_order'' AS disp_order
    , nec.CONTENT AS CONTENT
    , nec.memo AS memo
    , ms ->> ''category_class'' AS category_class
    , ms ->> ''taboo_allergy_class'' AS taboo_allergy_class
    , ms ->> ''taboo_allergy_cd'' AS taboo_allergy_cd 
  FROM
    pat_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.taboo_allergy_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
    INNER JOIN taboo_allergy_nec AS nec ON nec.taboo_allergy_cd = ms ->> ''taboo_allergy_cd'' AND ms ->> ''taboo_allergy_cd'' != ''0'' 
  WHERE
    A.is_del = ''0'' 
    AND A.facility_cd = ''@facilityCd'' 
    AND A.pat_id = @patId 
  UNION 
  SELECT
    NULL AS idx
    , nec.* 
  FROM
    taboo_allergy_nec AS nec 
  ORDER BY
    idx ASC NULLS LAST LIMIT 1
) 
UPDATE pat_main 
SET
  taboo_allergy_info = jsonb_set( 
    COALESCE(taboo_allergy_info, ''[]'') ::JSONB
    , CAST( 
      ( 
        SELECT
          ''{'' || COALESCE(idx, 999) || ''}'' 
        FROM
          tabooAllergyInfo
      ) AS TEXT []
    ) 
    , CAST( 
      ( 
        SELECT
          ''{"ctl_no":'' || ctl_no || '', "disp_order":'' || disp_order || '', "content":"'' || CONTENT || ''", "memo":"''
           || memo || ''", "category_class":"'' || category_class || ''", "taboo_allergy_class":"'' || taboo_allergy_class
           || ''", "taboo_allergy_cd":'' || taboo_allergy_cd || ''}'' 
        FROM
          tabooAllergyInfo
      ) AS JSONB
    ) ::JSONB
  ) 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECiSの患者属性連携_禁忌・アレルギー情報(薬剤禁忌以外)の更新', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9504, 'UPDATE pat_main 
SET
  taboo_allergy_info = ''[]''
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECiSの患者属性連携_禁忌・アレルギー情報のクリア', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9503, 'WITH contact_info AS (
  SELECT 
    CASE WHEN ''@contactInfo.zipCd'' = '''' THEN ''null'' ELSE ''"'' || ''@contactInfo.zipCd'' || ''"'' END AS zip_cd,
    CASE WHEN ''@contactInfo.address1'' = '''' AND ''@contactInfo.address2'' = '''' THEN ''null''
         ELSE ''"'' || TRIM(TRIM(TRIM(TRIM(''@contactInfo.address1'', ''　''), '' ''), ''　'') || '' '' || TRIM(TRIM(TRIM(''@contactInfo.address2'', ''　''), '' ''), ''　''), '' '') || ''"''
    END AS address,
    CASE WHEN ''@contactInfo.tel1'' = '''' THEN ''null'' ELSE ''"'' || ''@contactInfo.tel1'' || ''"'' END AS tel1
)
UPDATE pat_personal_main 
SET
  pat_contact_info = CASE WHEN  ''@contactInfo.kbn'' = ''0107'' AND pat_contact_info = ''{}'' 
                     THEN personal_info_encrypt_jsonb(CAST(''{"zip_cd":'' || (SELECT zip_cd FROM contact_info) || '', "address":'' || (SELECT address FROM contact_info) || '', "tel1":'' || (SELECT tel1 FROM contact_info) || '', "tel2":null, "fax":null, "e_mail":null, "work_name":null, "work_address":null, "work_tel":null, "memo1":null, "memo2":null}'' AS JSONB))
                     ELSE pat_contact_info END
  , other_contact_info = CASE WHEN  ''@contactInfo.kbn'' = ''0109'' AND other_contact_info = ''[]'' 
                     THEN personal_info_encrypt_jsonb(CAST(''[{"ctl_no":1, "disp_order":0, "is_key_person":null, "pat_id":null, "last_name":" ", "first_name":" ", "last_name_kana":null, "first_name_kana":null, "relation_cd":null, "relation_name":null, "zip_cd":'' || (SELECT zip_cd FROM contact_info) || '', "address":'' || (SELECT address FROM contact_info) || '', "e_mail":null, "work_name":null, "work_tel":null, "tel1":'' || (SELECT tel1 FROM contact_info) || '', "tel2":null, "fax":null, "memo1":null, "memo2":null}]'' AS JSONB))
                     ELSE other_contact_info END
  , vendor_contact_info = CASE WHEN  ''@contactInfo.kbn'' = ''0108'' AND vendor_contact_info = ''[]'' 
                     THEN personal_info_encrypt_jsonb(CAST(''[{"ctl_no":1, "disp_order":0, "company_name":" ", "zip_cd":'' || (SELECT zip_cd FROM contact_info) || '', "address":'' || (SELECT address FROM contact_info) || '', "company_tel":null, "fax":null, "worker_last_name":null, "worker_first_name":null, "worker_tel":'' || (SELECT tel1 FROM contact_info) || '', "worker_e_mail":null, "memo1":null, "memo2":null}]'' AS JSONB))
                     ELSE vendor_contact_info END
  , up_date = CURRENT_TIMESTAMP
WHERE
  is_del = ''0'' 
  AND hosp_pat_id = LTRIM(''@hospPatId'', ''0'') 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND (pat_contact_info = ''{}'' OR other_contact_info = ''[]'' OR vendor_contact_info = ''[]'')', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECiSの患者属性連携_連絡先情報(UPDATE)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9502, 'WITH in_out_info AS (
  SELECT CASE WHEN CURRENT_TIMESTAMP BETWEEN TO_TIMESTAMP(NULLIF(''@startDate_Date'', ''''), ''yyyy-MM-dd hh24:mi:ss'')
                                         AND TO_TIMESTAMP(NULLIF(''@endDate_Date'', ''''), ''yyyy-MM-dd hh24:mi:ss'') 
    THEN 1 ELSE 0 END AS in_out_class
)
UPDATE pat_personal_main 
SET
  pat_last_name = personal_info_encrypt(COALESCE(NULLIF(''@patLastName'', ''''), ''@hospPatId''))
  , pat_first_name = personal_info_encrypt(COALESCE(NULLIF(TRIM(''@patMiddleName @patFirstName''), ''''), '' ''))
  , pat_last_name_kana = personal_info_encrypt(''@patLastNmKana'') 
  , pat_first_name_kana = personal_info_encrypt(TRIM(''@patMiddleNmKana @patFirstNmKana'')) 
  , pat_birthday = NULLIF(''@patBirthday'', '''')
  , pat_sex = CASE ''@patSex'' 
    WHEN '''' THEN NULL 
    ELSE to_number(''@patSex'', ''9999999999999999'') 
    END
  , pat_blood_type_abo = CASE ''@patBloodTypeAbo'' 
    WHEN '''' THEN NULL 
    ELSE to_number(''@patBloodTypeAbo'', ''9999999999999999'') 
    END
  , pat_blood_type_rh = CASE ''@patBloodTypeRh'' 
    WHEN '''' THEN NULL 
    ELSE to_number(''@patBloodTypeRh'', ''9999999999999999'') 
    END
  , in_out_class = (SELECT in_out_class FROM in_out_info)
  , is_die = NULLIF(''@isDie'', '''')
  , die_date = CASE ''@dieDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@dieDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , pat_contact_info = ''{}''
  , other_contact_info = ''[]''
  , vendor_contact_info = ''[]''
  , up_date = CURRENT_TIMESTAMP
WHERE
  is_del = ''0'' 
  AND hosp_pat_id = LTRIM(''@hospPatId'', ''0'') 
  AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECiSの患者属性連携(UPDATE)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9501, 'WITH in_out_info AS (
  SELECT CASE WHEN CURRENT_TIMESTAMP BETWEEN to_timestamp(NULLIF(''@startDate_Date'', ''''), ''yyyy-MM-dd hh24:mi:ss'')
                                         AND to_timestamp(NULLIF(''@endDate_Date'', ''''), ''yyyy-MM-dd hh24:mi:ss'') 
    THEN 1 ELSE 0 END AS in_out_class
)
INSERT INTO pat_personal_main( 
  fn_pat_id
  , hosp_pat_id
  , nkk_pat_id
  , facility_cd
  , pat_last_name
  , pat_first_name
  , pat_last_name_kana
  , pat_first_name_kana
  , pat_last_name_alpha
  , pat_first_name_alpha
  , pat_birth_name
  , pat_birth_name_kana
  , pat_birth_name_alpha
  , pat_birthday
  , pat_sex
  , nationality
  , pat_blood_type_abo
  , pat_blood_type_rh
  , pat_blood_type_serovar
  , in_out_class
  , is_die
  , die_cd
  , die_date
  , dial_diff_com_info
  , severity_cd
  , transport_cd
  , pat_contact_info
  , other_contact_info
  , vendor_contact_info
  , insurance_info
  , is_del
  , up_date
  , reg_date
  , primary_disease_cd
  , remote_monitor_service
  , remote_monitor_user_id
  , remote_monitor_user_pw
) 
VALUES ( 
  NULLIF(''@fnPatId'', '''')
  , LTRIM(NULLIF(''@hospPatId'', ''''), ''0'')
  , NULLIF(''@nkkPatId'', '''')
  , NULLIF(''@facilityCd'', '''')
  , personal_info_encrypt(COALESCE(NULLIF(''@patLastName'', ''''), ''@hospPatId''))
  , personal_info_encrypt(COALESCE(NULLIF(TRIM(''@patMiddleName @patFirstName''), ''''), '' ''))
  , personal_info_encrypt(''@patLastNmKana'') 
  , personal_info_encrypt(TRIM(''@patMiddleNmKana @patFirstNmKana'')) 
  , NULLIF(''@patLastNmAlpha'', '''')
  , NULLIF(''@patFirstNmAlpha'', '''')
  , NULLIF(''@patBirthName'', '''')
  , NULLIF(''@patBirthNmKana'', '''')
  , NULLIF(''@patBirthNmAlpha'', '''')
  , NULLIF(''@patBirthday'', '''')
  , CASE ''@patSex'' 
    WHEN '''' THEN NULL 
    ELSE to_number(''@patSex'', ''9999999999999999'') 
    END
  , NULLIF(''@nationality'', '''')
  , CASE ''@patBloodTypeAbo'' 
    WHEN '''' THEN NULL 
    ELSE to_number(''@patBloodTypeAbo'', ''9999999999999999'') 
    END
  , CASE ''@patBloodTypeRh'' 
    WHEN '''' THEN NULL 
    ELSE to_number(''@patBloodTypeRh'', ''9999999999999999'') 
    END
  , CASE ''@patBloodTypeSerovar'' 
    WHEN '''' THEN NULL 
    ELSE to_number(''@patBloodTypeSerovar'', ''9999999999999999'') 
    END
  , (SELECT in_out_class FROM in_out_info)
  , NULLIF(''@isDie'', '''')
  , CASE ''@dieCd'' 
    WHEN '''' THEN NULL 
    ELSE to_number(''@dieCd'', ''99999999999999999999999999999999'') 
    END
  , CASE ''@dieDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@dieDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , ''@dialDiffComInfoValue''
  , CASE ''@severityCd'' 
    WHEN '''' THEN NULL 
    ELSE to_number( ''@severityCd'', ''99999999999999999999999999999999'') 
    END
  , CASE ''@transportCd'' 
    WHEN '''' THEN NULL 
    ELSE to_number( ''@transportCd'', ''99999999999999999999999999999999'') 
    END
  , ''{}''
  , ''[]''
  , ''[]''
  , ''@insuranceInfoValue''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , CASE ''@primaryDiseaseCd'' 
    WHEN '''' THEN NULL 
    ELSE to_number( ''@primaryDiseaseCd'', ''99999999999999999999999999999999'') 
    END
  , CASE ''@remoteMonitorService'' 
    WHEN '''' THEN NULL 
    ELSE to_number( ''@remoteMonitorService'', ''99999999999999999999999999999999'') 
    END
  , NULLIF(''@remoteMonitorUserId'', '''')
  , NULLIF(''@remoteMonitorUserPw'', '''')
)', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECiSの患者属性連携(INSERT)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7206, 'WITH infection_nec AS ( 
  SELECT
    A.infection_cd :: TEXT AS infection_cd
  FROM
    mst_infection A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      WHERE
        facility_cd = ''@facilityCd'' 
        AND master_physical_name = ''mst_infection''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.infection_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
    AND ( A.in_hospital_cd_1 = ''@infectInfo.infectionCd'') 
  UNION 
  SELECT
    ''0'' AS infection_cd 
  ORDER BY
    infection_cd DESC LIMIT 1
) 
, infectionInfo AS ( 
  SELECT
    (idx - 1) AS idx
    , ms ->> ''infection_cd'' AS infection_cd 
    , CASE ''@infectInfo.infect'' WHEN ''1'' THEN ''1'' WHEN ''2'' THEN ''2'' ELSE ''0'' END AS infect
    , SUBSTR(COALESCE(NULLIF(''@infectInfo.examDate'', ''''), TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'')), 1, 8) AS exam_date
    , TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'') AS up_date
  FROM
    pat_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.infect_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
    INNER JOIN infection_nec AS nec ON nec.infection_cd = ms ->> ''infection_cd'' AND ms ->> ''infection_cd'' != ''0'' 
  WHERE
    A.is_del = ''0'' 
    AND A.facility_cd = ''@facilityCd'' 
    AND A.pat_id = @patId 
  UNION 
  SELECT
    NULL AS idx
    , nec.infection_cd AS infection_cd 
    , CASE ''@infectInfo.infect'' WHEN ''1'' THEN ''1'' WHEN ''2'' THEN ''2'' ELSE ''0'' END AS infect
    , SUBSTR(COALESCE(NULLIF(''@infectInfo.examDate'', ''''), TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'')), 1, 8) AS exam_date
    , TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'') AS up_date
  FROM
    infection_nec AS nec 
  ORDER BY
    idx ASC NULLS LAST LIMIT 1
) 
UPDATE pat_main 
SET
  infect_info = jsonb_set( 
    COALESCE(infect_info, ''[]'') ::JSONB
    , CAST( 
      ( 
        SELECT
          ''{'' || COALESCE(idx, 999) || ''}'' 
        FROM
          infectionInfo
      ) AS TEXT []
    ) 
    , CAST( 
      ( 
        SELECT
          ''{"infect":"'' || infect || ''", "up_date":"'' || up_date || ''", "exam_date":"'' || exam_date || ''", "infection_cd":'' || infection_cd || ''}'' 
        FROM
          infectionInfo
      ) AS JSONB
    ) ::JSONB
  ) 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(感染症情報)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1203, 'WITH mstWardInfo AS ( 
  SELECT
    A.ward_cd
    , A.ward_name
    , A.in_hospital_cd_1 AS hospital_cd 
  FROM
    mst_ward A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      WHERE
        facility_cd = ''@facilityCd'' 
        AND master_physical_name = ''mst_ward''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.ward_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
    AND '''' != ''@medicalCareInfo.wardCd'' 
    AND A.in_hospital_cd_1 = ''@medicalCareInfo.wardCd'' 
  ORDER BY
    ms.INDEX
) 
, mstCourseInfo AS ( 
  SELECT
    A.course_cd
    , A.course_name
    , A.standard_course_cd
    , A.in_hospital_cd_1 AS hospital_cd 
  FROM
    mst_course A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      WHERE
        facility_cd = ''@facilityCd''
        AND master_physical_name = ''mst_course''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.course_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
    AND '''' != ''@medicalCareInfo.mainCourseCd'' 
    AND A.in_hospital_cd_1 = ''@medicalCareInfo.mainCourseCd'' 
  ORDER BY
    ms.INDEX
)
UPDATE pat_main 
SET
  pat_id = @patId
  , facility_cd = ''@facilityCd''
  , is_same = NULLIF(''@isSame'', '''')
  , is_implant = NULLIF(''@isImplant'', '''')
  , is_infect = NULLIF(''@isInfect'', '''')
  , is_diabetes = NULLIF(''@isDiabetes'', '''')
  , is_blood_suger_exam = NULLIF(''@isBloodSugerExam'', '''')
  , in_out_current_state = NULLIF(''@inOutCurrentState'', '''')
  , in_out_plan_state = NULLIF(''@inOutPlanState'', '''')
  , in_out_plan_date = CASE ''@inOutPlanDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@inOutPlanDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , pat_memo_info = ''@patMemoInfoValue''
  , addition_info = ''@additionInfoValue''
  , charge_staff_info = ''@chargeStaffInfoValue''
  , pat_group_info = ''@patGroupInfoValue''
  , taboo_allergy_info = ''@tabooAllergyInfoValue''
  , infect_info = ''@infectInfoValue''
  , implant_info = ''@implantInfoValue''
  , tare_info = ''@tareInfoValue''
  , off_water_info = ''@offWaterInfoValue''
  , device_set_info = ''@deviceSetInfoValue''
  , acceptance_status_info = ''@acceptanceStatusInfoValue''
  , up_date = CURRENT_TIMESTAMP
  , is_wheel_chair = NULLIF(''@isWheelChair'', '''')
  , medical_care_info = CASE ''@medicalCareInfoFlg'' 
    WHEN '''' THEN ''@medicalCareInfoValue'' 
    ELSE json_build_object( 
      ''main_course_cd''
      , COALESCE((SELECT course_cd FROM mstCourseInfo), 0)
      , ''dialysis_course_cd''
      , NULLIF(''@medicalCareInfo.dialysisCourseCd'', '''')
      , ''ward_cd''
      , COALESCE((SELECT ward_cd FROM mstWardInfo), 0)
      , ''dialysis_count''
      , NULLIF(''@medicalCareInfo.dialysisCount'', '''')
      , ''purification_count''
      , NULLIF(''@medicalCareInfo.purificationCount'', '''')
      , ''other_dialysis_count''
      , NULLIF(''@medicalCareInfo.otherDialysisCount'', '''')
      , ''facility_cd''
      , NULLIF(''@medicalCareInfo.facilityCd'', '''')
      , ''dialysis_start_date''
      , NULLIF(''@medicalCareInfo.dialysisStartDate'', '''')
      , ''hospital_start_date''
      , NULLIF(''@medicalCareInfo.hospitalStartDate'', '''')
    ) 
    END
  , sch_ext_end_date = NULLIF(''@schExtEndDate'', '''')
  , sch_ext_status = NULLIF(''@schExtStatus'', '''')
  , card_idm = NULLIF(''@cardIdm'', '''')
  , old_up_date = CASE ''@oldUpDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@oldUpDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1202, 'WITH mstWardInfo AS ( 
  SELECT
    A.ward_cd
    , A.ward_name
    , A.in_hospital_cd_1 AS hospital_cd 
  FROM
    mst_ward A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      WHERE
        facility_cd = ''@facilityCd'' 
        AND master_physical_name = ''mst_ward''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.ward_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
    AND '''' != ''@medicalCareInfo.wardCd'' 
    AND A.in_hospital_cd_1 = ''@medicalCareInfo.wardCd'' 
  ORDER BY
    ms.INDEX
) 
, mstCourseInfo AS ( 
  SELECT
    A.course_cd
    , A.course_name
    , A.standard_course_cd
    , A.in_hospital_cd_1 AS hospital_cd 
  FROM
    mst_course A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      WHERE
        facility_cd = ''@facilityCd''
        AND master_physical_name = ''mst_course''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.course_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
    AND '''' != ''@medicalCareInfo.mainCourseCd'' 
    AND A.in_hospital_cd_1 = ''@medicalCareInfo.mainCourseCd'' 
  ORDER BY
    ms.INDEX
)
INSERT 
INTO pat_main( 
  pat_id
  , facility_cd
  , is_same
  , is_implant
  , is_infect
  , is_diabetes
  , is_blood_suger_exam
  , in_out_current_state
  , in_out_plan_state
  , in_out_plan_date
  , pat_memo_info
  , addition_info
  , charge_staff_info
  , pat_group_info
  , taboo_allergy_info
  , infect_info
  , implant_info
  , tare_info
  , off_water_info
  , device_set_info
  , acceptance_status_info
  , is_del
  , up_date
  , reg_date
  , is_wheel_chair
  , medical_care_info
  , sch_ext_end_date
  , sch_ext_status
  , card_idm
  , old_up_date
  , host_notification_info
) 
VALUES ( 
  @patId
  , ''@facilityCd''
  , NULLIF(''@isSame'', '''')
  , NULLIF(''@isImplant'', '''')
  , NULLIF(''@isInfect'', '''')
  , NULLIF(''@isDiabetes'', '''')
  , NULLIF(''@isBloodSugerExam'', '''')
  , NULLIF(''@inOutCurrentState'', '''')
  , NULLIF(''@inOutPlanState'', '''')
  , CASE ''@inOutPlanDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@inOutPlanDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , COALESCE(NULLIF(''@patMemoInfo'', ''''), ''[]'') ::JSONB
  , COALESCE(NULLIF(''@additioninfo'', ''''), ''[]'') ::JSONB
  , ''@chargeStaffInfoValue''
  , ''@patGroupInfoValue''
  , ''@tabooAllergyInfoValue''
  , COALESCE(NULLIF(''@infectInfo'', ''''), ''[]'') ::JSONB
  , ''@implantInfoValue''
  , ''@tareInfoValue''
  , ''@offWaterInfoValue''
  , ''@deviceSetInfoValue''
  , ''@acceptanceStatusInfoValue''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , NULLIF(''@isWheelChair'', '''')
  , CASE ''@medicalCareInfoFlg'' 
    WHEN '''' THEN json_build_object( 
      ''main_course_cd''
      , NULL
      , ''dialysis_course_cd''
      , NULL
      , ''ward_cd''
      , NULL
      , ''dialysis_count''
      , NULL
      , ''purification_count''
      , NULL
      , ''other_dialysis_count''
      , NULL
      , ''facility_cd''
      , NULL
      , ''dialysis_start_date''
      , NULL
      , ''hospital_start_date''
      , NULL
    ) 
    ELSE json_build_object( 
      ''main_course_cd''
      , COALESCE((SELECT course_cd FROM mstCourseInfo), 0)
      , ''dialysis_course_cd''
      , NULLIF(''@medicalCareInfo.dialysisCourseCd'', '''')
      , ''ward_cd''
      , COALESCE((SELECT ward_cd FROM mstWardInfo), 0)
      , ''dialysis_count''
      , NULLIF(''@medicalCareInfo.dialysisCount'', '''')
      , ''purification_count''
      , NULLIF(''@medicalCareInfo.purificationCount'', '''')
      , ''other_dialysis_count''
      , NULLIF(''@medicalCareInfo.otherDialysisCount'', '''')
      , ''facility_cd''
      , NULLIF(''@medicalCareInfo.facilityCd'', '''')
      , ''dialysis_start_date''
      , NULLIF(''@medicalCareInfo.dialysisStartDate'', '''')
      , ''hospital_start_date''
      , NULLIF(''@medicalCareInfo.hospitalStartDate'', '''')
    ) 
    END
  , NULLIF(''@schExtEndDate'', '''')
  , NULLIF(''@schExtStatus'', '''')
  , NULLIF(''@cardIdm'', '''')
  , CASE ''@oldUpDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@oldUpDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , NULL
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": 1002, "field_name": "pat_memo_info", "replace_var": "@patMemoInfo"}, {"sql_cd": 1003, "field_name": "infect_info", "replace_var": "@infectInfo"}, {"sql_cd": 1004, "field_name": "addition_info", "replace_var": "@additioninfo"}]');
