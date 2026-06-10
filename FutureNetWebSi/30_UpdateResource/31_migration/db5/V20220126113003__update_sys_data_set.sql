delete from "sys_data_set" where "sql_cd" in (1102,1103,1501,1502,1705,1706,1707,1708,1709,1710,1711,1712,1713);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1102, 'WITH name_info AS ( 
  SELECT
    ''@patLastName'' ::TEXT AS patLastName
    , ''@patFirstName'' ::TEXT AS patFirstName
    , ''@patLastNmKana'' ::TEXT AS patLastNmKana
    , ''@patFirstNmKana'' ::TEXT AS patFirstNmKana
) 
, tmp_index_info AS ( 
  SELECT
    COALESCE(NULLIF(POSITION(''　'' IN patLastName), 0), LENGTH(patLastName) + 1) AS indexLast1
    , COALESCE(NULLIF(POSITION('' '' IN patLastName), 0), LENGTH(patLastName) + 1) AS indexLast2
    , COALESCE(NULLIF(POSITION(''　'' IN patFirstName), 0), LENGTH(patFirstName) + 1) AS indexFirst1
    , COALESCE(NULLIF(POSITION('' '' IN patFirstName), 0), LENGTH(patFirstName) + 1) AS indexFirst2
    , COALESCE(NULLIF(POSITION(''　'' IN patLastNmKana), 0), LENGTH(patLastNmKana) + 1) AS indexLastK1
    , COALESCE(NULLIF(POSITION('' '' IN patLastNmKana), 0), LENGTH(patLastNmKana) + 1) AS indexLastK2
    , COALESCE(NULLIF(POSITION(''　'' IN patFirstNmKana), 0), LENGTH(patFirstNmKana) + 1) AS indexFirstK1
    , COALESCE(NULLIF(POSITION('' '' IN patFirstNmKana), 0), LENGTH(patFirstNmKana) + 1) AS indexFirstK2 
  FROM
    name_info
) 
, index_info AS ( 
  SELECT
    CASE 
      WHEN indexLast1 > indexLast2 
        THEN indexLast2 
      ELSE indexLast1 
      END AS indexLast
    , CASE 
      WHEN indexFirst1 > indexFirst2 
        THEN indexFirst2 
      ELSE indexFirst1 
      END AS indexFirst
    , CASE 
      WHEN indexLastK1 > indexLastK2 
        THEN indexLastK2 
      ELSE indexLastK1 
      END AS indexLastK
    , CASE 
      WHEN indexFirstK1 > indexFirstK2 
        THEN indexFirstK2 
      ELSE indexFirstK1 
      END AS indexFirstK 
  FROM
    tmp_index_info
)
, new_name_info AS (
  SELECT
    TRIM(TRIM(TRIM(SUBSTRING(patLastName, 1, indexLast-1)), ''　'')) AS patLastName
    , TRIM(TRIM(TRIM(SUBSTRING(patFirstName, indexFirst + 1)), ''　'')) AS patFirstName
    , TRIM(TRIM(TRIM(SUBSTRING(patLastNmKana, 1, indexLastK-1)), ''　'')) AS patLastNmKana
    , TRIM(TRIM(TRIM(SUBSTRING(patFirstNmKana, indexFirstK + 1)), ''　'')) AS patFirstNmKana
  FROM 
    name_info,
    index_info
) 
INSERT 
INTO pat_personal_main( 
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
  , personal_info_encrypt((SELECT patLastName FROM new_name_info)) 
  , personal_info_encrypt((SELECT patFirstName FROM new_name_info))
  , personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
  , personal_info_encrypt((SELECT patFirstNmKana FROM new_name_info))
  , NULLIF(''@patLastNmAlpha'', '''')
  , NULLIF(''@patFirstNmAlpha'', '''')
  , NULLIF(''@patBirthName'', '''')
  , NULLIF(''@patBirthNmKana'', '''')
  , NULLIF(''@patBirthNmAlpha'', '''')
  , NULLIF(''@patBirthday'', '''')
  , CASE ''@patSex'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@patSex'', ''FM9999999999999999'') 
    END
  , NULLIF(''@nationality'', '''')
  , CASE ''@patBloodTypeAbo'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@patBloodTypeAbo'', ''FM9999999999999999'') 
    END
  , CASE ''@patBloodTypeRh'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@patBloodTypeRh'', ''FM9999999999999999'') 
    END
  , CASE ''@patBloodTypeSerovar'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@patBloodTypeSerovar'', ''FM9999999999999999'') 
    END
  , CASE ''@inOutClass'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@inOutClass'', ''FM9999999999999999'') 
    END
  , NULLIF(''@isDie'', '''')
  , CASE ''@dieCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@dieCd'', ''FM99999999999999999999999999999999'') 
    END
  , CASE ''@dieDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE TO_TIMESTAMP(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') 
    END
  , COALESCE(NULLIF(''@dialDiffComInfo'', ''''), ''[]'') ::JSONB
  , CASE ''@severityCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@severityCd'', ''FM99999999999999999999999999999999'') 
    END
  , CASE ''@transportCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@transportCd'', ''FM99999999999999999999999999999999'') 
    END
  , CASE ''@patContactInfoFlg'' 
    WHEN '''' THEN json_build_object( 
      ''zip_cd''
      , NULL
      , ''address''
      , NULL
      , ''tel1''
      , NULL
      , ''tel2''
      , NULL
      , ''fax''
      , NULL
      , ''e_mail''
      , NULL
      , ''work_name''
      , NULL
      , ''work_address''
      , NULL
      , ''work_tel''
      , NULL
      , ''memo1''
      , NULL
      , ''memo2''
      , NULL
    ) 
    ELSE json_build_object( 
      ''zip_cd''
      , NULLIF(''@patContactInfo.zipCd'', '''')
      , ''address''
      , NULLIF((TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　'') || TRIM(TRIM(TRIM(''@patContactInfo.detailsAddress'', ''　''), '' ''), ''　'')), '''') 
      , ''tel1''
      , NULLIF(''@patContactInfo.tel1'', '''')
      , ''tel2''
      , NULLIF(''@patContactInfo.tel2'', '''')
      , ''fax''
      , NULLIF(''@patContactInfo.fax'', '''')
      , ''e_mail''
      , NULLIF(''@patContactInfo.eMail'', '''')
      , ''work_name''
      , NULLIF(''@patContactInfo.workName'', '''')
      , ''work_address''
      , NULLIF(''@patContactInfo.workAddress'', '''')
      , ''work_tel''
      , NULLIF(''@patContactInfo.workTel'', '''')
      , ''memo1''
      , NULLIF(''@patContactInfo.memo1'', '''')
      , ''memo2''
      , NULLIF(''@patContactInfo.memo2'', '''')
    ) 
    END
  , ''@otherContactInfoValue''
  , ''@vendorContactInfoValue''
  , ''@insuranceInfoValue''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , CASE ''@primaryDiseaseCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@primaryDiseaseCd'', ''FM99999999999999999999999999999999'') 
    END
  , CASE ''@remoteMonitorService'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@remoteMonitorService'', ''FM99999999999999999999999999999999'') 
    END
  , NULLIF(''@remoteMonitorUserId'', '''')
  , NULLIF(''@remoteMonitorUserPw'', '''')
)', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', '2021-11-24 09:13:17.574', '[{"sql_cd": 1001, "field_name": "dial_diff_com_info", "replace_var": "@dialDiffComInfo"}]');
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1103, 'WITH name_info AS ( 
  SELECT
    ''@patLastName'' ::TEXT AS patLastName
    , ''@patFirstName'' ::TEXT AS patFirstName
    , ''@patLastNmKana'' ::TEXT AS patLastNmKana
    , ''@patFirstNmKana'' ::TEXT AS patFirstNmKana
) 
, tmp_index_info AS ( 
  SELECT
    COALESCE(NULLIF(POSITION(''　'' IN patLastName), 0), LENGTH(patLastName) + 1) AS indexLast1
    , COALESCE(NULLIF(POSITION('' '' IN patLastName), 0), LENGTH(patLastName) + 1) AS indexLast2
    , COALESCE(NULLIF(POSITION(''　'' IN patFirstName), 0), LENGTH(patFirstName) + 1) AS indexFirst1
    , COALESCE(NULLIF(POSITION('' '' IN patFirstName), 0), LENGTH(patFirstName) + 1) AS indexFirst2
    , COALESCE(NULLIF(POSITION(''　'' IN patLastNmKana), 0), LENGTH(patLastNmKana) + 1) AS indexLastK1
    , COALESCE(NULLIF(POSITION('' '' IN patLastNmKana), 0), LENGTH(patLastNmKana) + 1) AS indexLastK2
    , COALESCE(NULLIF(POSITION(''　'' IN patFirstNmKana), 0), LENGTH(patFirstNmKana) + 1) AS indexFirstK1
    , COALESCE(NULLIF(POSITION('' '' IN patFirstNmKana), 0), LENGTH(patFirstNmKana) + 1) AS indexFirstK2 
  FROM
    name_info
) 
, index_info AS ( 
  SELECT
    CASE 
      WHEN indexLast1 > indexLast2 
        THEN indexLast2 
      ELSE indexLast1 
      END AS indexLast
    , CASE 
      WHEN indexFirst1 > indexFirst2 
        THEN indexFirst2 
      ELSE indexFirst1 
      END AS indexFirst
    , CASE 
      WHEN indexLastK1 > indexLastK2 
        THEN indexLastK2 
      ELSE indexLastK1 
      END AS indexLastK
    , CASE 
      WHEN indexFirstK1 > indexFirstK2 
        THEN indexFirstK2 
      ELSE indexFirstK1 
      END AS indexFirstK 
  FROM
    tmp_index_info
)
, new_name_info AS (
  SELECT
    TRIM(TRIM(TRIM(SUBSTRING(patLastName, 1, indexLast-1)), ''　'')) AS patLastName
    , TRIM(TRIM(TRIM(SUBSTRING(patFirstName, indexFirst + 1)), ''　'')) AS patFirstName
    , TRIM(TRIM(TRIM(SUBSTRING(patLastNmKana, 1, indexLastK-1)), ''　'')) AS patLastNmKana
    , TRIM(TRIM(TRIM(SUBSTRING(patFirstNmKana, indexFirstK + 1)), ''　'')) AS patFirstNmKana
  FROM 
    name_info,
    index_info
) 
UPDATE pat_personal_main 
SET
  fn_pat_id = NULLIF(''@fnPatId'', '''')
  , hosp_pat_id = LTRIM(NULLIF(''@hospPatId'', ''''), ''0'')
  , nkk_pat_id = NULLIF(''@nkkPatId'', '''')
  , facility_cd = NULLIF(''@facilityCd'', '''')
  , pat_last_name = personal_info_encrypt((SELECT patLastName FROM new_name_info))
  , pat_first_name = COALESCE(personal_info_encrypt(NULLIF((SELECT patFirstName FROM new_name_info), '''')), pat_first_name) 
  , pat_last_name_kana = personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
  , pat_first_name_kana = COALESCE(personal_info_encrypt(NULLIF((SELECT patFirstNmKana FROM new_name_info), '''')) , pat_first_name_kana) 
  , pat_last_name_alpha = NULLIF(''@patLastNmAlpha'', '''')
  , pat_first_name_alpha = NULLIF(''@patFirstNmAlpha'', '''')
  , pat_birth_name = NULLIF(''@patBirthName'', '''')
  , pat_birth_name_kana = NULLIF(''@patBirthNmKana'', '''')
  , pat_birth_name_alpha = NULLIF(''@patBirthNmAlpha'', '''')
  , pat_birthday = NULLIF(''@patBirthday'', '''')
  , pat_sex = CASE ''@patSex'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@patSex'', ''FM9999999999999999'') 
    END
  , nationality = NULLIF(''@nationality'', '''')
  , pat_blood_type_abo = CASE ''@patBloodTypeAbo'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@patBloodTypeAbo'', ''FM9999999999999999'') 
    END
  , pat_blood_type_rh = CASE ''@patBloodTypeRh'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@patBloodTypeRh'', ''FM9999999999999999'') 
    END
  , pat_blood_type_serovar = CASE ''@patBloodTypeSerovar'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@patBloodTypeSerovar'', ''FM9999999999999999'') 
    END
  , in_out_class = CASE ''@inOutClass'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@inOutClass'', ''FM9999999999999999'') 
    END
  , is_die = NULLIF(''@isDie'', '''')
  , die_cd = CASE ''@dieCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@dieCd'', ''FM99999999999999999999999999999999'') 
    END
  , die_date = CASE ''@dieDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE TO_TIMESTAMP(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') 
    END
  , dial_diff_com_info = ''@dialDiffComInfoValue''
  , severity_cd = CASE ''@severityCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER( ''@severityCd'', ''FM99999999999999999999999999999999'') 
    END
  , transport_cd = CASE ''@transportCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@transportCd'', ''FM99999999999999999999999999999999'') 
    END
  , pat_contact_info = CASE ''@patContactInfoFlg'' 
    WHEN '''' THEN ''@patContactInfoValue'' 
    ELSE json_build_object( 
      ''zip_cd''
      , NULLIF(''@patContactInfo.zipCd'', '''')
      , ''address''
      , NULLIF((TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　'') || TRIM(TRIM(TRIM(''@patContactInfo.detailsAddress'', ''　''), '' ''), ''　'')), '''') 
      , ''tel1''
      , NULLIF(''@patContactInfo.tel1'', '''')
      , ''tel2''
      , NULLIF(''@patContactInfo.tel2'', '''')
      , ''fax''
      , NULLIF(''@patContactInfo.fax'', '''')
      , ''e_mail''
      , NULLIF(''@patContactInfo.eMail'', '''')
      , ''work_name''
      , NULLIF(''@patContactInfo.workName'', '''')
      , ''work_address''
      , NULLIF(''@patContactInfo.workAddress'', '''')
      , ''work_tel''
      , NULLIF(''@patContactInfo.workTel'', '''')
      , ''memo1''
      , NULLIF(''@patContactInfo.memo1'', '''')
      , ''memo2''
      , NULLIF(''@patContactInfo.memo2'', '''')
    ) 
    END
  , other_contact_info = ''@otherContactInfoValue''
  , vendor_contact_info = ''@vendorContactInfoValue''
  , insurance_info = ''@insuranceInfoValue''
  , reg_date = ''@regDate''
  , up_date = CURRENT_TIMESTAMP
  , primary_disease_cd = CASE ''@primaryDiseaseCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@primaryDiseaseCd'', ''FM99999999999999999999999999999999'') 
    END
  , remote_monitor_service = CASE ''@remoteMonitorService'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@remoteMonitorService'', ''FM99999999999999999999999999999999'') 
    END
  , remote_monitor_user_id = NULLIF(''@remoteMonitorUserId'', '''')
  , remote_monitor_user_pw = NULLIF(''@remoteMonitorUserPw'', '''') 
WHERE
  is_del = ''0'' 
  AND hosp_pat_id = ''@hospPatId'' 
  AND facility_cd = ''@facilityCd''
', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2022-01-07 18:21:46', '2022-01-07 18:21:46', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1501, 'select
  pat_id,
  fn_pat_id,
  hosp_pat_id,
  nkk_pat_id,
  facility_cd,
  personal_info_decrypt(pat_last_name) as pat_last_name,
  personal_info_decrypt(pat_first_name) as pat_first_name,
  personal_info_decrypt(pat_last_name_kana) as pat_last_name_kana,
  personal_info_decrypt(pat_first_name_kana) as pat_first_name_kana,
  personal_info_decrypt(pat_last_name_alpha) as pat_last_name_alpha,
  personal_info_decrypt(pat_first_name_alpha) as pat_first_name_alpha,
  personal_info_decrypt(pat_birth_name) as pat_birth_name,
  personal_info_decrypt(pat_birth_name_kana) as pat_birth_name_kana,
  personal_info_decrypt(pat_birth_name_alpha) as pat_birth_name_alpha,
  pat_birthday,
  pat_sex,
  nationality,
  pat_blood_type_abo,
  pat_blood_type_rh,
  pat_blood_type_serovar,
  in_out_class,
  is_die,
  die_cd,
  die_date,
  dial_diff_com_info,
  severity_cd,
  transport_cd,
  personal_info_decrypt_jsonb(pat_contact_info) as pat_contact_info,
  personal_info_decrypt_jsonb(other_contact_info) as other_contact_info,
  personal_info_decrypt_jsonb(vendor_contact_info) as vendor_contact_info,
  insurance_info,
  is_del,
  up_date,
  reg_date,
  primary_disease_cd,
  remote_monitor_service,
  personal_info_decrypt(remote_monitor_user_id) as remote_monitor_user_id,
  personal_info_decrypt(remote_monitor_user_pw) as remote_monitor_user_pw
from
  pat_personal_main
where
  is_del = ''0''
and
  ltrim(hosp_pat_id, ''0'') = ltrim(@hospPatId, ''0'')
and
  facility_cd = @facilityCd', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1502, 'WITH die_info AS (
  SELECT 
    COALESCE(NULLIF(''@isDie'', ''''), ''0'') AS is_die
    , TO_TIMESTAMP(NULLIF(''@dieDate_Date'', ''''), ''YYYY-MM-DD HH24:MI:SS'') AS die_date
)
UPDATE pat_personal_main 
SET
  is_die = (SELECT is_die FROM die_info)
  , die_date = CASE (SELECT is_die FROM die_info)
    WHEN ''0'' THEN NULL 
    ELSE (SELECT die_date FROM die_info)
    END 
WHERE
  facility_cd = ''@facilityCd'' 
  AND hosp_pat_id = ''@hospPatId'' 
  AND pat_id = @patId ', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_生存の有無登録', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1705, 'WITH data_new_info AS (
  SELECT 
    null AS ctl_no,
    ''@inOutClass'' :: TEXT AS in_out, 
    null AS reason,
    null AS to_course,
    null AS to_doctor,
    0 AS disp_order,
    null AS period_end,
    ''@facilityCd'' AS facility_cd,
    null AS from_course,
    null AS from_doctor,
    (CASE ''@inOutClass'' WHEN ''0'' THEN  ''6'' WHEN ''1'' THEN ''4'' ELSE ''10'' END) :: TEXT AS move_in_out,
    null AS to_facility,
    TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'') AS period_start,
    null AS from_facility,
    ''0'' AS course_is_free,
    ''0'' AS doctor_is_free,
    null AS period_end_day,
    null AS period_end_year,
    ''0'' AS facility_is_free,
    null AS period_end_month,
    TO_CHAR(CURRENT_TIMESTAMP, ''DD'') AS period_start_day,
    TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'') AS period_start_date,
    TO_CHAR(CURRENT_TIMESTAMP, ''YYYY'') AS period_start_year,
    TO_CHAR(CURRENT_TIMESTAMP, ''MM'') AS period_start_month,
    ''0'' AS period_end_input_free,
    ''0'' AS period_start_input_free,
    null AS to_medicalInstitutionCd,
    null AS from_medicalInstitutionCd
) 
, data_old_info AS (
  SELECT
    info ->> ''ctl_no'' AS ctl_no,
    info ->> ''in_out'' AS in_out,
    info ->> ''reason'' AS reason,
    info ->> ''to_course'' AS to_course,
    info ->> ''to_doctor'' AS to_doctor,
    info ->> ''disp_order'' AS disp_order,
    info ->> ''period_end'' AS period_end,
    info ->> ''facility_cd'' AS facility_cd,
    info ->> ''from_course'' AS from_course,
    info ->> ''from_doctor'' AS from_doctor,
    info ->> ''move_in_out'' AS move_in_out,
    info ->> ''to_facility'' AS to_facility,
    info ->> ''period_start'' AS period_start,
    info ->> ''from_facility'' AS from_facility,
    info ->> ''course_is_free'' AS course_is_free,
    info ->> ''doctor_is_free'' AS doctor_is_free,
    info ->> ''period_end_day'' AS period_end_day,
    info ->> ''period_end_year'' AS period_end_year,
    info ->> ''facility_is_free'' AS facility_is_free,
    info ->> ''period_end_month'' AS period_end_month,
    info ->> ''period_start_day'' AS period_start_day,
    info ->> ''period_start_date'' AS period_start_date,
    info ->> ''period_start_year'' AS period_start_year,
    info ->> ''period_start_month'' AS period_start_month,
    info ->> ''period_end_input_free'' AS period_end_input_free,
    info ->> ''period_start_input_free'' AS period_start_input_free,
    info ->> ''to_medicalInstitutionCd'' AS to_medicalInstitutionCd,
    info ->> ''from_medicalInstitutionCd'' AS from_medicalInstitutionCd
  FROM
    pat_unique patu
    CROSS JOIN LATERAL json_array_elements ( patu.in_out_visit_history_info :: json ) AS info 
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
  ORDER BY
    period_start DESC, ctl_no ASC LIMIT 1
) 
, data_exists_info AS (
  SELECT
    1 AS order_no
    , ''1'' AS exists_flag 
  FROM
    data_old_info AS OLD
    , data_new_info AS NEW 
  WHERE
    (OLD.in_out ::TEXT) = (NEW.in_out ::TEXT) 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS exists_flag 
  ORDER BY
    order_no ASC LIMIT 1
)
, data_info AS ( 
  SELECT
    0 AS order_no,
    ctl_no::TEXT AS ctl_no,
    in_out::TEXT AS in_out,
    reason::TEXT AS reason,
    to_course::TEXT AS to_course,
    to_doctor::TEXT AS to_doctor,
    disp_order::TEXT AS disp_order,
    period_end::TEXT AS period_end,
    facility_cd::TEXT AS facility_cd,
    from_course::TEXT AS from_course,
    from_doctor::TEXT AS from_doctor,
    move_in_out::TEXT AS move_in_out,
    to_facility::TEXT AS to_facility,
    period_start::TEXT AS period_start,
    from_facility::TEXT AS from_facility,
    course_is_free::TEXT AS course_is_free,
    doctor_is_free::TEXT AS doctor_is_free,
    period_end_day::TEXT AS period_end_day,
    period_end_year::TEXT AS period_end_year,
    facility_is_free::TEXT AS facility_is_free,
    period_end_month::TEXT AS period_end_month,
    period_start_day::TEXT AS period_start_day,
    period_start_date::TEXT AS period_start_date,
    period_start_year::TEXT AS period_start_year,
    period_start_month::TEXT AS period_start_month,
    period_end_input_free::TEXT AS period_end_input_free,
    period_start_input_free::TEXT AS period_start_input_free,
    to_medicalInstitutionCd::TEXT AS to_medicalInstitutionCd,
    from_medicalInstitutionCd::TEXT AS from_medicalInstitutionCd
  FROM
    data_new_info 
  WHERE
    (SELECT exists_flag FROM data_exists_info) = ''0'' 
  UNION 
  SELECT
    1 AS order_no,
    info ->> ''ctl_no'' AS ctl_no,
    info ->> ''in_out'' AS in_out,
    info ->> ''reason'' AS reason,
    info ->> ''to_course'' AS to_course,
    info ->> ''to_doctor'' AS to_doctor,
    info ->> ''disp_order'' AS disp_order,
    info ->> ''period_end'' AS period_end,
    info ->> ''facility_cd'' AS facility_cd,
    info ->> ''from_course'' AS from_course,
    info ->> ''from_doctor'' AS from_doctor,
    info ->> ''move_in_out'' AS move_in_out,
    info ->> ''to_facility'' AS to_facility,
    info ->> ''period_start'' AS period_start,
    info ->> ''from_facility'' AS from_facility,
    info ->> ''course_is_free'' AS course_is_free,
    info ->> ''doctor_is_free'' AS doctor_is_free,
    info ->> ''period_end_day'' AS period_end_day,
    info ->> ''period_end_year'' AS period_end_year,
    info ->> ''facility_is_free'' AS facility_is_free,
    info ->> ''period_end_month'' AS period_end_month,
    info ->> ''period_start_day'' AS period_start_day,
    info ->> ''period_start_date'' AS period_start_date,
    info ->> ''period_start_year'' AS period_start_year,
    info ->> ''period_start_month'' AS period_start_month,
    info ->> ''period_end_input_free'' AS period_end_input_free,
    info ->> ''period_start_input_free'' AS period_start_input_free,
    info ->> ''to_medicalInstitutionCd'' AS to_medicalInstitutionCd,
    info ->> ''from_medicalInstitutionCd'' AS from_medicalInstitutionCd
  FROM
    pat_unique patu
    CROSS JOIN LATERAL json_array_elements ( patu.in_out_visit_history_info :: json ) AS info 
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
  ORDER BY
    order_no DESC, period_start ASC)
, json_data AS (
  SELECT json_build_object(
    ''ctl_no'', row_number() over(order by order_no DESC, period_start ASC),
    ''in_out'' , in_out,
    ''reason'' , reason,
    ''to_course'' , to_course,
    ''to_doctor'' , to_doctor,
    ''disp_order'' , disp_order,
    ''period_end'' , period_end,
    ''facility_cd'' , facility_cd,
    ''from_course'' , from_course,
    ''from_doctor'' , from_doctor,
    ''move_in_out'' , move_in_out,
    ''to_facility'' , to_facility,
    ''period_start'' , period_start,
    ''from_facility'' , from_facility,
    ''course_is_free'' , course_is_free,
    ''doctor_is_free'' , doctor_is_free,
    ''period_end_day'' , period_end_day,
    ''period_end_year'' , period_end_year,
    ''facility_is_free'' , facility_is_free,
    ''period_end_month'' , period_end_month,
    ''period_start_day'' , period_start_day,
    ''period_start_date'' , period_start_date,
    ''period_start_year'' , period_start_year,
    ''period_start_month'' , period_start_month,
    ''period_end_input_free'' , period_end_input_free,
    ''period_start_input_free'' , period_start_input_free,
    ''to_medicalInstitutionCd'' , to_medicalInstitutionCd,
    ''from_medicalInstitutionCd'' , from_medicalInstitutionCd) AS new_data
  FROM data_info
)
UPDATE pat_unique 
SET
  in_out_visit_history_info = (SELECT array_to_json(ARRAY_AGG(new_data)) FROM json_data)
  , up_date = CURRENT_TIMESTAMP
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報_入外・転入出情報(死亡以外)', '2020-05-25 18:21:40.841', '2021-12-24 17:59:06.44', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1706, 'WITH data_new_info AS (
  SELECT 
    null AS ctl_no,
    ''2'' :: TEXT AS in_out, 
    null AS reason,
    null AS to_course,
    null AS to_doctor,
    0 AS disp_order,
    null AS period_end,
    ''@facilityCd'' AS facility_cd,
    null AS from_course,
    null AS from_doctor,
    ''11'' :: TEXT AS move_in_out,
    null AS to_facility,
    TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'') AS period_start,
    null AS from_facility,
    ''0'' AS course_is_free,
    ''0'' AS doctor_is_free,
    null AS period_end_day,
    null AS period_end_year,
    ''0'' AS facility_is_free,
    null AS period_end_month,
    TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''DD'') AS period_start_day,
    null AS period_start_date,
    TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYY'') AS period_start_year,
    TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''MM'') AS period_start_month,
    ''0'' AS period_end_input_free,
    ''0'' AS period_start_input_free,
    null AS to_medicalInstitutionCd,
    null AS from_medicalInstitutionCd
) 
, data_old_info AS (
  SELECT
    info ->> ''ctl_no'' AS ctl_no,
    info ->> ''in_out'' AS in_out,
    info ->> ''reason'' AS reason,
    info ->> ''to_course'' AS to_course,
    info ->> ''to_doctor'' AS to_doctor,
    info ->> ''disp_order'' AS disp_order,
    info ->> ''period_end'' AS period_end,
    info ->> ''facility_cd'' AS facility_cd,
    info ->> ''from_course'' AS from_course,
    info ->> ''from_doctor'' AS from_doctor,
    info ->> ''move_in_out'' AS move_in_out,
    info ->> ''to_facility'' AS to_facility,
    info ->> ''period_start'' AS period_start,
    info ->> ''from_facility'' AS from_facility,
    info ->> ''course_is_free'' AS course_is_free,
    info ->> ''doctor_is_free'' AS doctor_is_free,
    info ->> ''period_end_day'' AS period_end_day,
    info ->> ''period_end_year'' AS period_end_year,
    info ->> ''facility_is_free'' AS facility_is_free,
    info ->> ''period_end_month'' AS period_end_month,
    info ->> ''period_start_day'' AS period_start_day,
    info ->> ''period_start_date'' AS period_start_date,
    info ->> ''period_start_year'' AS period_start_year,
    info ->> ''period_start_month'' AS period_start_month,
    info ->> ''period_end_input_free'' AS period_end_input_free,
    info ->> ''period_start_input_free'' AS period_start_input_free,
    info ->> ''to_medicalInstitutionCd'' AS to_medicalInstitutionCd,
    info ->> ''from_medicalInstitutionCd'' AS from_medicalInstitutionCd
  FROM
    pat_unique patu
    CROSS JOIN LATERAL json_array_elements ( patu.in_out_visit_history_info :: json ) AS info 
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
  ORDER BY
    period_start DESC, ctl_no ASC LIMIT 1
) 
, data_exists_info AS (
  SELECT
    1 AS order_no
    , ''1'' AS exists_flag 
  FROM
    data_old_info AS OLD
    , data_new_info AS NEW 
  WHERE
    (OLD.in_out ::TEXT) = (NEW.in_out ::TEXT) 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS exists_flag 
  ORDER BY
    order_no ASC LIMIT 1
)
, data_info AS ( 
  SELECT
    0 AS order_no,
    ctl_no::TEXT AS ctl_no,
    in_out::TEXT AS in_out,
    reason::TEXT AS reason,
    to_course::TEXT AS to_course,
    to_doctor::TEXT AS to_doctor,
    disp_order::TEXT AS disp_order,
    period_end::TEXT AS period_end,
    facility_cd::TEXT AS facility_cd,
    from_course::TEXT AS from_course,
    from_doctor::TEXT AS from_doctor,
    move_in_out::TEXT AS move_in_out,
    to_facility::TEXT AS to_facility,
    period_start::TEXT AS period_start,
    from_facility::TEXT AS from_facility,
    course_is_free::TEXT AS course_is_free,
    doctor_is_free::TEXT AS doctor_is_free,
    period_end_day::TEXT AS period_end_day,
    period_end_year::TEXT AS period_end_year,
    facility_is_free::TEXT AS facility_is_free,
    period_end_month::TEXT AS period_end_month,
    period_start_day::TEXT AS period_start_day,
    period_start_date::TEXT AS period_start_date,
    period_start_year::TEXT AS period_start_year,
    period_start_month::TEXT AS period_start_month,
    period_end_input_free::TEXT AS period_end_input_free,
    period_start_input_free::TEXT AS period_start_input_free,
    to_medicalInstitutionCd::TEXT AS to_medicalInstitutionCd,
    from_medicalInstitutionCd::TEXT AS from_medicalInstitutionCd
  FROM
    data_new_info 
  WHERE
    (SELECT exists_flag FROM data_exists_info) = ''0'' 
  UNION 
  SELECT
    1 AS order_no,
    info ->> ''ctl_no'' AS ctl_no,
    info ->> ''in_out'' AS in_out,
    info ->> ''reason'' AS reason,
    info ->> ''to_course'' AS to_course,
    info ->> ''to_doctor'' AS to_doctor,
    info ->> ''disp_order'' AS disp_order,
    info ->> ''period_end'' AS period_end,
    info ->> ''facility_cd'' AS facility_cd,
    info ->> ''from_course'' AS from_course,
    info ->> ''from_doctor'' AS from_doctor,
    info ->> ''move_in_out'' AS move_in_out,
    info ->> ''to_facility'' AS to_facility,
    info ->> ''period_start'' AS period_start,
    info ->> ''from_facility'' AS from_facility,
    info ->> ''course_is_free'' AS course_is_free,
    info ->> ''doctor_is_free'' AS doctor_is_free,
    info ->> ''period_end_day'' AS period_end_day,
    info ->> ''period_end_year'' AS period_end_year,
    info ->> ''facility_is_free'' AS facility_is_free,
    info ->> ''period_end_month'' AS period_end_month,
    info ->> ''period_start_day'' AS period_start_day,
    info ->> ''period_start_date'' AS period_start_date,
    info ->> ''period_start_year'' AS period_start_year,
    info ->> ''period_start_month'' AS period_start_month,
    info ->> ''period_end_input_free'' AS period_end_input_free,
    info ->> ''period_start_input_free'' AS period_start_input_free,
    info ->> ''to_medicalInstitutionCd'' AS to_medicalInstitutionCd,
    info ->> ''from_medicalInstitutionCd'' AS from_medicalInstitutionCd
  FROM
    pat_unique patu
    CROSS JOIN LATERAL json_array_elements ( patu.in_out_visit_history_info :: json ) AS info 
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
  ORDER BY
    order_no DESC, period_start ASC)
, json_data AS (
  SELECT json_build_object(
    ''ctl_no'', row_number() over(order by order_no DESC, period_start ASC),
    ''in_out'' , in_out,
    ''reason'' , reason,
    ''to_course'' , to_course,
    ''to_doctor'' , to_doctor,
    ''disp_order'' , disp_order,
    ''period_end'' , period_end,
    ''facility_cd'' , facility_cd,
    ''from_course'' , from_course,
    ''from_doctor'' , from_doctor,
    ''move_in_out'' , move_in_out,
    ''to_facility'' , to_facility,
    ''period_start'' , period_start,
    ''from_facility'' , from_facility,
    ''course_is_free'' , course_is_free,
    ''doctor_is_free'' , doctor_is_free,
    ''period_end_day'' , period_end_day,
    ''period_end_year'' , period_end_year,
    ''facility_is_free'' , facility_is_free,
    ''period_end_month'' , period_end_month,
    ''period_start_day'' , period_start_day,
    ''period_start_date'' , period_start_date,
    ''period_start_year'' , period_start_year,
    ''period_start_month'' , period_start_month,
    ''period_end_input_free'' , period_end_input_free,
    ''period_start_input_free'' , period_start_input_free,
    ''to_medicalInstitutionCd'' , to_medicalInstitutionCd,
    ''from_medicalInstitutionCd'' , from_medicalInstitutionCd) AS new_data
  FROM data_info
)
UPDATE pat_unique 
SET
  in_out_visit_history_info = (SELECT array_to_json(ARRAY_AGG(new_data)) FROM json_data)
  , up_date = CURRENT_TIMESTAMP
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報_入外・転入出情報(死亡)', '2020-05-25 18:21:40.841', '2021-12-24 17:59:06.44', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1707, 'WITH data_new_info AS (
  SELECT 
     null AS memo, 
     null AS ctl_no, 
     TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'') AS die_date, 
     ''10'' AS out_come, 
     null AS course_cd, 
     ''0'' AS is_notice, 
     null AS disease_cd, 
     ''0'' AS disp_order, 
     null AS disease_day, 
     ''@facilityCd'' AS facility_cd, 
     null AS disease_date, 
     null AS disease_year, 
     ''0'' AS is_diagnosed, 
     null AS diagnosis_day, 
     null AS disease_month, 
     TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'') AS out_come_date, 
     ''0'' AS course_is_free, 
     null AS diagnosis_date, 
     null AS diagnosis_year, 
     null AS diagnosis_month, 
     ''0'' AS is_main_disease, 
     null AS diagnostician_cd, 
     null AS diagnosis_facility_cd, 
     ''0'' AS diagnostician_is_free, 
     ''0'' AS is_confirmation_biopsy, 
     ''0'' AS diagnosis_facility_is_free, 
     ''0'' AS is_dialysis_underlying_disease
) 
, data_old_info AS (
  SELECT
    info ->> ''memo'' AS memo, 
    info ->> ''ctl_no'' AS ctl_no, 
    info ->> ''die_date'' AS die_date, 
    info ->> ''out_come'' AS out_come, 
    info ->> ''course_cd'' AS course_cd, 
    info ->> ''is_notice'' AS is_notice, 
    info ->> ''disease_cd'' AS disease_cd, 
    info ->> ''disp_order'' AS disp_order, 
    info ->> ''disease_day'' AS disease_day, 
    info ->> ''facility_cd'' AS facility_cd, 
    info ->> ''disease_date'' AS disease_date, 
    info ->> ''disease_year'' AS disease_year, 
    info ->> ''is_diagnosed'' AS is_diagnosed, 
    info ->> ''diagnosis_day'' AS diagnosis_day, 
    info ->> ''disease_month'' AS disease_month, 
    info ->> ''out_come_date'' AS out_come_date, 
    info ->> ''course_is_free'' AS course_is_free, 
    info ->> ''diagnosis_date'' AS diagnosis_date, 
    info ->> ''diagnosis_year'' AS diagnosis_year, 
    info ->> ''diagnosis_month'' AS diagnosis_month, 
    info ->> ''is_main_disease'' AS is_main_disease, 
    info ->> ''diagnostician_cd'' AS diagnostician_cd, 
    info ->> ''diagnosis_facility_cd'' AS diagnosis_facility_cd, 
    info ->> ''diagnostician_is_free'' AS diagnostician_is_free, 
    info ->> ''is_confirmation_biopsy'' AS is_confirmation_biopsy, 
    info ->> ''diagnosis_facility_is_free'' AS diagnosis_facility_is_free, 
    info ->> ''is_dialysis_underlying_disease'' AS is_dialysis_underlying_disease
  FROM
    pat_unique patu
    CROSS JOIN LATERAL json_array_elements ( patu.medical_hst_info :: json ) AS info 
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
  ORDER BY
    ctl_no DESC LIMIT 1
) 
, data_exists_info AS (
  SELECT
    1 AS order_no
    , ''1'' AS exists_flag 
  FROM
    data_old_info AS OLD
    , data_new_info AS NEW 
  WHERE
    (OLD.out_come ::TEXT) = (NEW.out_come ::TEXT) 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS exists_flag 
  ORDER BY
    order_no ASC LIMIT 1
)
, data_info AS ( 
  SELECT
    0 AS order_no,
    memo::TEXT AS memo, 
    ctl_no::TEXT AS ctl_no, 
    die_date::TEXT AS die_date, 
    out_come::TEXT AS out_come, 
    course_cd::TEXT AS course_cd, 
    is_notice::TEXT AS is_notice, 
    disease_cd::TEXT AS disease_cd, 
    disp_order::TEXT AS disp_order, 
    disease_day::TEXT AS disease_day, 
    facility_cd::TEXT AS facility_cd, 
    disease_date::TEXT AS disease_date, 
    disease_year::TEXT AS disease_year, 
    is_diagnosed::TEXT AS is_diagnosed, 
    diagnosis_day::TEXT AS diagnosis_day, 
    disease_month::TEXT AS disease_month, 
    out_come_date::TEXT AS out_come_date, 
    course_is_free::TEXT AS course_is_free, 
    diagnosis_date::TEXT AS diagnosis_date, 
    diagnosis_year::TEXT AS diagnosis_year, 
    diagnosis_month::TEXT AS diagnosis_month, 
    is_main_disease::TEXT AS is_main_disease, 
    diagnostician_cd::TEXT AS diagnostician_cd, 
    diagnosis_facility_cd::TEXT AS diagnosis_facility_cd, 
    diagnostician_is_free::TEXT AS diagnostician_is_free, 
    is_confirmation_biopsy::TEXT AS is_confirmation_biopsy, 
    diagnosis_facility_is_free::TEXT AS diagnosis_facility_is_free, 
    is_dialysis_underlying_disease::TEXT AS is_dialysis_underlying_disease
  FROM
    data_new_info 
  WHERE
    (SELECT exists_flag FROM data_exists_info) = ''0'' 
  UNION 
  SELECT
    1 AS order_no,
    info ->> ''memo'' AS memo, 
    info ->> ''ctl_no'' AS ctl_no, 
    info ->> ''die_date'' AS die_date, 
    info ->> ''out_come'' AS out_come, 
    info ->> ''course_cd'' AS course_cd, 
    info ->> ''is_notice'' AS is_notice, 
    info ->> ''disease_cd'' AS disease_cd, 
    info ->> ''disp_order'' AS disp_order, 
    info ->> ''disease_day'' AS disease_day, 
    info ->> ''facility_cd'' AS facility_cd, 
    info ->> ''disease_date'' AS disease_date, 
    info ->> ''disease_year'' AS disease_year, 
    info ->> ''is_diagnosed'' AS is_diagnosed, 
    info ->> ''diagnosis_day'' AS diagnosis_day, 
    info ->> ''disease_month'' AS disease_month, 
    info ->> ''out_come_date'' AS out_come_date, 
    info ->> ''course_is_free'' AS course_is_free, 
    info ->> ''diagnosis_date'' AS diagnosis_date, 
    info ->> ''diagnosis_year'' AS diagnosis_year, 
    info ->> ''diagnosis_month'' AS diagnosis_month, 
    info ->> ''is_main_disease'' AS is_main_disease, 
    info ->> ''diagnostician_cd'' AS diagnostician_cd, 
    info ->> ''diagnosis_facility_cd'' AS diagnosis_facility_cd, 
    info ->> ''diagnostician_is_free'' AS diagnostician_is_free, 
    info ->> ''is_confirmation_biopsy'' AS is_confirmation_biopsy, 
    info ->> ''diagnosis_facility_is_free'' AS diagnosis_facility_is_free, 
    info ->> ''is_dialysis_underlying_disease'' AS is_dialysis_underlying_disease
  FROM
    pat_unique patu
    CROSS JOIN LATERAL json_array_elements ( patu.medical_hst_info :: json ) AS info 
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
  ORDER BY
    order_no DESC, ctl_no ASC)
, json_data AS (
  SELECT json_build_object(
    ''memo'', memo, 
    ''ctl_no'', row_number() over(order by order_no DESC, ctl_no ASC),
    ''die_date'', die_date, 
    ''out_come'', out_come, 
    ''course_cd'', course_cd, 
    ''is_notice'', is_notice, 
    ''disease_cd'', disease_cd, 
    ''disp_order'', disp_order, 
    ''disease_day'', disease_day, 
    ''facility_cd'', facility_cd, 
    ''disease_date'', disease_date, 
    ''disease_year'', disease_year, 
    ''is_diagnosed'', is_diagnosed, 
    ''diagnosis_day'', diagnosis_day, 
    ''disease_month'', disease_month, 
    ''out_come_date'', out_come_date, 
    ''course_is_free'', course_is_free, 
    ''diagnosis_date'', diagnosis_date, 
    ''diagnosis_year'', diagnosis_year, 
    ''diagnosis_month'', diagnosis_month, 
    ''is_main_disease'', is_main_disease, 
    ''diagnostician_cd'', diagnostician_cd, 
    ''diagnosis_facility_cd'', diagnosis_facility_cd, 
    ''diagnostician_is_free'', diagnostician_is_free, 
    ''is_confirmation_biopsy'', is_confirmation_biopsy, 
    ''diagnosis_facility_is_free'', diagnosis_facility_is_free, 
    ''is_dialysis_underlying_disease'', is_dialysis_underlying_disease) AS new_data
  FROM data_info
)
UPDATE pat_unique 
SET
  medical_hst_info = (SELECT array_to_json(ARRAY_AGG(new_data)) FROM json_data)
  , up_date = CURRENT_TIMESTAMP
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報_既往歴情報(死亡)', '2020-05-25 18:21:40.841', '2021-12-24 17:59:06.44', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1708, 'INSERT 
INTO ord_main_restore( 
  del_date
  , ord_no
  , pat_id
  , fn_pat_id
  , treat_date
  , treat_week
  , facility_cd
  , facility_name
  , ind_va_cd
  , ind_treatment_cd
  , ind_treatment_name
  , ind_kur_cd
  , ind_kur_name
  , ind_treat_start_time
  , ind_bed_cd
  , ind_bed_name
  , ind_schedule_user_info
  , ind_cond_info
  , ind_medi_info
  , ind_equip_info
  , ind_ind_comment_info
  , ind_tare_info
  , ind_off_water_info
  , ind_device_set_info
  , rst_fn_dialysis_no
  , rst_relation_dialysis_no
  , rst_edition
  , rst_is_update_edition
  , rst_input_class
  , rst_dialysis_state
  , rst_treatment_cd
  , rst_treatment_name
  , rst_kur_cd
  , rst_kur_name
  , rst_bed_cd
  , rst_bed_name
  , rst_machine_no
  , rst_machine_name
  , rst_cond_send_date
  , rst_accept_date
  , rst_start_date
  , rst_end_date
  , rst_return_home_date
  , rst_in_out_class
  , rst_dialysis_cnt
  , rst_ward_cd
  , rst_ward_name
  , rst_course_cd
  , rst_course_name
  , rst_puncture_user_info
  , rst_return_user_info
  , rst_charge_user_info
  , rst_blood_circulate_total
  , rst_running_time
  , rst_kt_v
  , rec_set_date
  , send_ctl_no
  , blood_purifier_name
  , pull_leave_amount
  , rst_cond_info
  , rst_medi_info
  , rst_equip_info
  , rst_ind_comment_info
  , rst_tare_info
  , rst_off_water_info
  , rst_device_set_info
  , rst_weight_info
  , rst_vital_info
  , rst_complaint_info
  , rst_treatment_info
  , rst_treat_staff_info
  , rst_rounds_info
  , is_del
  , up_date
  , reg_date
  , rst_dw
  , weight_scale_no
  , treat_type
  , is_confirm
  , ind_dw
  , rst_purification_cnt
  , addition_info
  , up_ind_user_id
  , up_user_id
  , rst_edition_date
  , cur_edition_date
  , fn_plural
) 
SELECT
  CURRENT_TIMESTAMP AS del_date
  , ord_no
  , pat_id
  , fn_pat_id
  , treat_date
  , treat_week
  , facility_cd
  , facility_name
  , ind_va_cd
  , ind_treatment_cd
  , ind_treatment_name
  , ind_kur_cd
  , ind_kur_name
  , ind_treat_start_time
  , ind_bed_cd
  , ind_bed_name
  , ind_schedule_user_info
  , ind_cond_info
  , ind_medi_info
  , ind_equip_info
  , ind_ind_comment_info
  , ind_tare_info
  , ind_off_water_info
  , ind_device_set_info
  , rst_fn_dialysis_no
  , rst_relation_dialysis_no
  , rst_edition
  , rst_is_update_edition
  , rst_input_class
  , rst_dialysis_state
  , rst_treatment_cd
  , rst_treatment_name
  , rst_kur_cd
  , rst_kur_name
  , rst_bed_cd
  , rst_bed_name
  , rst_machine_no
  , rst_machine_name
  , rst_cond_send_date
  , rst_accept_date
  , rst_start_date
  , rst_end_date
  , rst_return_home_date
  , rst_in_out_class
  , rst_dialysis_cnt
  , rst_ward_cd
  , rst_ward_name
  , rst_course_cd
  , rst_course_name
  , rst_puncture_user_info
  , rst_return_user_info
  , rst_charge_user_info
  , rst_blood_circulate_total
  , rst_running_time
  , rst_kt_v
  , rec_set_date
  , send_ctl_no
  , blood_purifier_name
  , pull_leave_amount
  , rst_cond_info
  , rst_medi_info
  , rst_equip_info
  , rst_ind_comment_info
  , rst_tare_info
  , rst_off_water_info
  , rst_device_set_info
  , rst_weight_info
  , rst_vital_info
  , rst_complaint_info
  , rst_treatment_info
  , rst_treat_staff_info
  , rst_rounds_info
  , is_del
  , up_date
  , reg_date
  , rst_dw
  , weight_scale_no
  , treat_type
  , is_confirm
  , ind_dw
  , rst_purification_cnt
  , addition_info
  , up_ind_user_id
  , up_user_id
  , rst_edition_date
  , cur_edition_date
  , fn_plural 
FROM
  ord_main 
WHERE
  is_del = ''0'' 
  AND rst_edition = 0
  AND rst_treatment_cd is null
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND treat_date > TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')', 2, '[{}]', '0', '{"applications": [4]}', NULL, '未来日データをコピーする。透析予定(ord_main) → ord_main_restore', '2020-05-25 18:21:40.841', '2021-12-24 17:59:06.44', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1709, 'INSERT 
INTO pat_exam_main_hst( 
  exam_main_cd
  , pat_id
  , facility_cd
  , ord_no
  , fn_pat_id
  , reg_exam_date
  , reg_order_class
  , exam_status
  , order_comment
  , order_exam_set_info
  , exam_order_info
  , order_label_info
  , data_gen_class
  , result_exam_date
  , result_comment
  , exam_result_info
  , cop_order_no1
  , cop_order_no2
  , is_lock
  , ind_user_id
  , is_del
  , reg_date
  , reg_staff
  , up_date
  , up_staff
  , is_order
) 
SELECT
  exam_main_cd
  , pat_id
  , facility_cd
  , ord_no
  , fn_pat_id
  , reg_exam_date
  , reg_order_class
  , exam_status
  , order_comment
  , order_exam_set_info
  , exam_order_info
  , order_label_info
  , data_gen_class
  , result_exam_date
  , result_comment
  , exam_result_info
  , cop_order_no1
  , cop_order_no2
  , is_lock
  , ind_user_id
  , is_del
  , reg_date
  , reg_staff
  , up_date
  , up_staff
  , is_order
FROM
  pat_exam_main 
WHERE
  is_del = ''0'' 
  AND exam_status = ''0''
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND TO_CHAR(reg_exam_date, ''YYYYMMDD'') > TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')', 2, '[{}]', '0', '{"applications": [4]}', NULL, '未来日データをコピーする。検査オーダ（pat_exam_main） → pat_exam_main_hst', '2020-05-25 18:21:40.841', '2021-12-24 17:59:06.44', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1710, 'INSERT 
INTO pat_rad_main_hst( 
  rad_result_cd
  , pat_id
  , facility_cd
  , fn_pat_id
  , reg_rad_date
  , reg_order_class
  , rad_status
  , order_rad_set_info
  , cop_order_no1
  , cop_order_no2
  , is_lock
  , ind_user_id
  , is_del
  , reg_date
  , reg_staff
  , up_date
  , up_staff
) 
SELECT
  rad_result_cd
  , pat_id
  , facility_cd
  , fn_pat_id
  , reg_rad_date
  , reg_order_class
  , rad_status
  , order_rad_set_info
  , cop_order_no1
  , cop_order_no2
  , is_lock
  , ind_user_id
  , is_del
  , reg_date
  , reg_staff
  , up_date
  , up_staff
FROM
  pat_rad_main 
WHERE
  is_del = ''0'' 
  AND rad_status = ''0''
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND TO_CHAR(reg_rad_date, ''YYYYMMDD'') > TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')', 2, '[{}]', '0', '{"applications": [4]}', NULL, '未来日データをコピーする。一般撮影検査オーダ（pat_rad_main） → pat_rad_main_hst', '2020-05-25 18:21:40.841', '2021-12-24 17:59:06.44', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1711, 'DELETE 
FROM
  ord_main 
WHERE
  is_del = ''0'' 
  AND rst_edition = 0
  AND rst_treatment_cd is null
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND treat_date > TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')', 2, '[{}]', '0', '{"applications": [4]}', NULL, '未来日データを削除する。透析予定(ord_main)', '2020-05-25 18:21:40.841', '2021-12-24 17:59:06.44', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1712, 'DELETE 
FROM
  pat_exam_main 
WHERE
  is_del = ''0'' 
  AND exam_status = ''0''
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND TO_CHAR(reg_exam_date, ''YYYYMMDD'') > TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')', 2, '[{}]', '0', '{"applications": [4]}', NULL, '未来日データを削除する。検査オーダ（pat_exam_main）', '2020-05-25 18:21:40.841', '2021-12-24 17:59:06.44', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1713, 'DELETE 
FROM
  pat_rad_main 
WHERE
  is_del = ''0'' 
  AND rad_status = ''0''
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND TO_CHAR(reg_rad_date, ''YYYYMMDD'') > TO_CHAR(TO_DATE(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'')', 2, '[{}]', '0', '{"applications": [4]}', NULL, '未来日データを削除する。一般撮影検査オーダ（pat_rad_main）', '2020-05-25 18:21:40.841', '2021-12-24 17:59:06.44', NULL);
