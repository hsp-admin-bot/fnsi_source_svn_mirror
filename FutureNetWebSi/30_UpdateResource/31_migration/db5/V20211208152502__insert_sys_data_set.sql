delete from "sys_data_set" where "sql_cd" in (9413,9412,9411,9410,9409,9408,9407,9406,9405,9404,9403,9402,9401);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9413, 'UPDATE mst_user
SET is_del = ''1''
   , up_date = CURRENT_TIMESTAMP
WHERE
  is_del = ''0'' 
  AND facility_cd = ''@facilityCd''
  AND user_id = @userId 
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECスタッフマスタ連携の利用者削除(mst_user 倫理削除)', '2021-12-07 10:00:00', '2021-12-07 10:00:00', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9412, 'DELETE FROM
  mst_user_authentication 
WHERE
  facility_cd = ''@facilityCd''
  AND user_id = @userId 
', 1, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECスタッフマスタ連携の利用者削除(mst_user_authentication 物理削除)', '2021-12-07 10:00:00', '2021-12-07 10:00:00', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9411, 'UPDATE mst_personal_user
SET is_del = ''1''
   , up_date = CURRENT_TIMESTAMP
WHERE
  is_del = ''0'' 
  AND facility_cd = ''@facilityCd''
  AND user_id = @userId 
', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECスタッフマスタ連携の利用者削除(mst_personal_user 倫理削除)', '2021-12-07 10:00:00', '2021-12-07 10:00:00', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9410, 'WITH job_settings AS ( 
  SELECT
    1 AS order_no
    , A.job_cd
    , A.up_date
    , A.default_menu_settings ->> ''initial_menu_function'' AS initial_menu_function
    , A.default_menu_settings ->> ''default_menu_functions'' AS default_menu_functions
    , array_to_json(STRING_TO_ARRAY(A.default_authorized_authorities, '','')) ::TEXT AS default_authorized_authorities 
  FROM
    mst_job A
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
        AND master_physical_name = ''mst_job''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.job_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
    AND A.in_hospital_cd_1 = ''@jobCd'' 
  UNION 
  SELECT
    2 AS order_no
    , - 1 AS job_cd
    , CURRENT_TIMESTAMP AS up_date
    , NULL AS initial_menu_function
    , NULL AS default_menu_functions
    , NULL AS default_authorized_authorities 
  ORDER BY order_no ASC , up_date DESC  LIMIT 1
) 
, job_user_settings AS ( 
  SELECT
    job_cd
    , ''{"theme": 0, "font_size": 1, "is_disp_menu": 1, "use_functions": ''
		  || job.default_menu_functions
      || '', "is_split_frame": 1, "default_setting": {}, "ind_rst_pattern": null, "initial_function": "''
			|| job.initial_menu_function
      || ''", "personal_settings": [], "authorized_functions": ''
			|| job.default_menu_functions
      || '', "authorized_authorities": ''
			|| job.default_authorized_authorities
      || ''}'' AS user_settings 
  FROM
    job_settings AS job
) 
UPDATE mst_user
SET 
  user_settings = CASE WHEN (SELECT job_cd FROM job_user_settings) = -1 THEN
      ''@userSettingsValue''
    ELSE
      (SELECT user_settings FROM job_user_settings) :: JSONB
    END
  , up_date = CURRENT_TIMESTAMP
WHERE
  user_id = @userId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECスタッフマスタ連携の利用者更新(mst_user)', '2021-12-07 10:00:00', '2021-12-07 10:00:00', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9409, 'WITH job_settings AS ( 
  SELECT
    1 AS order_no
    , A.job_cd
    , A.up_date
    , A.default_menu_settings ->> ''initial_menu_function'' AS initial_menu_function
    , A.default_menu_settings ->> ''default_menu_functions'' AS default_menu_functions
    , array_to_json(STRING_TO_ARRAY(A.default_authorized_authorities, '','')) ::TEXT AS default_authorized_authorities 
  FROM
    mst_job A
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
        AND master_physical_name = ''mst_job''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.job_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
    AND A.in_hospital_cd_1 = ''@jobCd'' 
  UNION 
  SELECT
    2 AS order_no
    , - 1 AS job_cd
    , CURRENT_TIMESTAMP AS up_date
    , NULL AS initial_menu_function
    , NULL AS default_menu_functions
    , NULL AS default_authorized_authorities 
  ORDER BY order_no ASC , up_date DESC  LIMIT 1
) 
, job_user_settings AS ( 
  SELECT
    job_cd
    , ''{"theme": 0, "font_size": 1, "is_disp_menu": 1, "use_functions": ''
		  || job.default_menu_functions
      || '', "is_split_frame": 1, "default_setting": {}, "ind_rst_pattern": null, "initial_function": "''
			|| job.initial_menu_function
      || ''", "personal_settings": [], "authorized_functions": ''
			|| job.default_menu_functions
      || '', "authorized_authorities": ''
			|| job.default_authorized_authorities
      || ''}'' AS user_settings 
  FROM
    job_settings AS job
) 
INSERT INTO mst_user( 
  user_id
  , user_settings
  , is_provisional
  , reg_date
  , up_date
  , is_disp
  , is_del
  , pat_id
  , tmp_log_search_condition
  , secret_key
  , is_set_qr_code
  , card_idm
  , is_consent
  , consent_date
  , reg_password_date
  , facility_cd
  , login_method 
) 
VALUES ( 
  @userId
  , CASE WHEN (SELECT job_cd FROM job_user_settings) = -1 THEN
      ''@userSettingsValue''
    ELSE
      (SELECT user_settings FROM job_user_settings) :: JSONB
    END
  , CASE ''@isProvisional'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER( ''@isProvisional'', ''FM9'') 
    END
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , ''1''
  , ''0''
  , CASE ''@patId'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER( ''@patId'', ''FM9999999999999999999'') 
    END
  , NULL
  , NULLIF(''@secretKey'', '''')
  , CASE ''@isSetQrCode'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER( ''@isSetQrCode'', ''FM9'') 
    END
  , NULLIF(''@cardIdm'', '''')
  , CASE ''@isConsent'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER( ''@isConsent'', ''FM9'') 
    END
  , NULL
  , NULL
  , ''@facilityCd''
  , NULLIF(''@loginMethod'', '''')
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECスタッフマスタ連携の利用者新規(mst_user)', '2021-12-07 10:00:00', '2021-12-07 10:00:00', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9408, 'SELECT
  user_id
  , user_settings
  , is_provisional
  , reg_date
  , up_date
  , is_disp
  , is_del
  , pat_id
  , tmp_log_search_condition
  , secret_key
  , is_set_qr_code
  , card_idm
  , is_consent
  , consent_date
  , reg_password_date
  , facility_cd
  , login_method 
FROM
  mst_user 
WHERE
  user_id = @userId', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECスタッフマスタ連携の利用者取得(mst_user)', '2021-12-07 10:00:00', '2021-12-07 10:00:00', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9407, 'UPDATE mst_user_authentication 
SET
  disp_user_id = NULLIF(''@dispUserId'', '''')
  , user_password = COALESCE(NULLIF(''@%%passwordencoder%%_userPassword'', ''''), COALESCE(NULLIF(''@%%passwordencoder%%_dispUserId'', ''''), ''@%%passwordencoder%%_defaultPassword''))
  , up_date = CURRENT_TIMESTAMP 
WHERE
  user_id = @userId 
  AND facility_cd = ''@facilityCd''
', 1, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECスタッフマスタ連携の利用者更新(mst_user_authentication)', '2021-12-07 10:00:00', '2021-12-07 10:00:00', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9406, 'INSERT INTO mst_user_authentication( 
  user_id
  , facility_cd
  , disp_user_id
  , user_password
  , failure_cnt
  , reg_date
  , up_date
  , user_password_history 
) 
VALUES ( 
  @userId
  , ''@facilityCd''
  , NULLIF(''@dispUserId'', '''')
  , COALESCE(NULLIF(''@%%passwordencoder%%_userPassword'', ''''), COALESCE(NULLIF(''@%%passwordencoder%%_dispUserId'', ''''), ''@%%passwordencoder%%_defaultPassword''))
  , 0
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , NULL
)', 1, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECスタッフマスタ連携の利用者新規(mst_user_authentication)', '2021-12-07 10:00:00', '2021-12-07 10:00:00', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9405, 'SELECT
  user_id
  , facility_cd
  , disp_user_id
  , user_password
  , failure_cnt
  , reg_date
  , up_date
  , user_password_history 
FROM
  mst_user_authentication 
WHERE
  user_id = @userId', 1, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECスタッフマスタ連携の利用者取得(mst_user_authentication)', '2021-12-07 10:00:00', '2021-12-07 10:00:00', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9404, 'SELECT
  1 AS order_no
  , A.up_date
  , CAST(A.job_cd AS TEXT) AS job_cd
  , A.job_name
  , A.is_doctor
  , A.in_hospital_cd_1 
FROM
  mst_job A
  , ( 
    SELECT
      mss.facility_cd
      , ms.*
      , ROW_NUMBER() OVER () AS INDEX 
    FROM
      mst_selector mss 
      CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
    WHERE
      facility_cd = @facilityCd 
      AND master_physical_name = ''mst_job''
  ) ms 
WHERE
  A.facility_cd = ms.facility_cd 
  AND A.job_cd = ms.code 
  AND A.is_del = ''0'' 
  AND A.is_disp = ''1'' 
  AND A.in_hospital_cd_1 = @jobCd 
UNION 
SELECT
  2 AS order_no
  , CURRENT_TIMESTAMP AS up_date
  , '''' AS job_cd
  , ''不明'' AS job_name
  , ''0'' AS is_doctor
  , '''' AS in_hospital_cd_1 
ORDER BY
  order_no ASC, up_date DESC LIMIT 1	', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECスタッフマスタ連携(連携の職種コードより、FNWの職種コードを取得)', '2021-12-07 10:00:00', '2021-12-07 10:00:00', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9403, 'UPDATE mst_personal_user 
SET
   user_last_name = personal_info_encrypt(COALESCE(NULLIF(split_part(''@userName'', ''　'', 1), ''''), '' ''))
   , user_first_name = personal_info_encrypt(COALESCE(NULLIF(split_part(''@userName'', ''　'', 2), ''''), '' ''))
   , user_last_name_kana = CASE 
    WHEN split_part(''@userKana'', ''　'', 2) IS NULL OR split_part(''@userKana'', ''　'', 2) = '''' 
    THEN personal_info_encrypt(split_part(''@userKana'', '' '', 1)) 
    ELSE personal_info_encrypt(split_part(''@userKana'', ''　'', 1)) 
    END
   , user_first_name_kana = CASE 
    WHEN split_part(''@userKana'', ''　'', 2) IS NULL OR split_part(''@userKana'', ''　'', 2) = '''' 
    THEN personal_info_encrypt(split_part(''@userKana'', '' '', 2)) 
    ELSE personal_info_encrypt(split_part(''@userKana'', ''　'', 2)) 
    END
  , job_cd = personal_info_encrypt(NULLIF(''@fnwJobCd'', ''''))
  , up_date = CURRENT_TIMESTAMP 
WHERE
  is_del = ''0'' 
  AND user_id = @userId 
  AND facility_cd = ''@facilityCd'' ', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECスタッフマスタ連携の利用者更新(mst_personal_user)', '2021-12-07 10:00:00', '2021-12-07 10:00:00', '[{"sql_cd": 9404, "field_name": "job_cd", "replace_var": "@fnwJobCd"}]');
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9402, 'INSERT INTO mst_personal_user( 
  facility_cd
  , user_type
  , user_last_name
  , user_first_name
  , user_last_name_kana
  , user_first_name_kana
  , user_last_name_alpha
  , user_first_name_alpha
  , user_email_address_1
  , user_email_address_2
  , extension_no
  , home_no
  , mobile_phone_no
  , fax_no
  , zipcd_3
  , zipcd_4
  , address
  , address_kana
  , job_cd
  , reg_date
  , up_date
  , administrator
  , is_disp
  , is_del
  , in_hospital_cd_1
  , in_hospital_cd_2
  , info_disp_to_admin
  , anesthesiologist_license_no
  , signin_date
  , patient_shared
  , fn_staff_cd
) 
VALUES ( 
  ''@facilityCd''
  , TO_NUMBER(COALESCE(NULLIF(''@userType'', ''''), ''0''), ''FM9'')
  , personal_info_encrypt(COALESCE(NULLIF(split_part(''@userName'', ''　'', 1), ''''), '' ''))
  , personal_info_encrypt(COALESCE(NULLIF(split_part(''@userName'', ''　'', 2), ''''), '' ''))
  , CASE 
    WHEN split_part(''@userKana'', ''　'', 2) IS NULL OR split_part(''@userKana'', ''　'', 2) = '''' 
    THEN personal_info_encrypt(split_part(''@userKana'', '' '', 1)) 
    ELSE personal_info_encrypt(split_part(''@userKana'', ''　'', 1)) 
    END
  , CASE 
    WHEN split_part(''@userKana'', ''　'', 2) IS NULL OR split_part(''@userKana'', ''　'', 2) = '''' 
    THEN personal_info_encrypt(split_part(''@userKana'', '' '', 2)) 
    ELSE personal_info_encrypt(split_part(''@userKana'', ''　'', 2)) 
    END
  , personal_info_encrypt(NULLIF(''@userLastNameAlpha'', ''''))
  , personal_info_encrypt(NULLIF(''@userFirstNameAlpha'', ''''))
  , personal_info_encrypt(NULLIF(''@userEmailAddress1'', ''''))
  , personal_info_encrypt(NULLIF(''@userEmailAddress2'', ''''))
  , personal_info_encrypt(NULLIF(''@extensionNo'', ''''))
  , personal_info_encrypt(NULLIF(''@homeNo'', ''''))
  , personal_info_encrypt(NULLIF(''@mobilePhoneNo'', ''''))
  , personal_info_encrypt(NULLIF(''@faxNo'', ''''))
  , personal_info_encrypt(NULLIF(''@zipcd3'', ''''))
  , personal_info_encrypt(NULLIF(''@zipcd4'', ''''))
  , personal_info_encrypt(NULLIF(''@address'', ''''))
  , personal_info_encrypt(NULLIF(''@addressKana'', ''''))
  , personal_info_encrypt(NULLIF(''@fnwJobCd'', ''''))
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , TO_NUMBER( COALESCE(NULLIF(''@administrator'', ''''), ''0''), ''FM9'') 
  , ''1''
  , ''0''
  , NULLIF(''@inHospitalCd1'', '''')
  , NULLIF(''@inHospitalCd2'', '''')
  , ''0''
  , personal_info_encrypt(NULLIF(''@anesthesiologistLicenseNo'', ''''))
  , NULL
  , CASE ''@patientShared'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER( ''@patientShared'', ''FM9999999999'') 
    END
  , NULLIF(''@fnStaffCd'', '''')
)', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECスタッフマスタ連携の利用者新規(mst_personal_user)', '2021-12-07 10:00:00', '2021-12-07 10:00:00', '[{"sql_cd": 9404, "field_name": "job_cd", "replace_var": "@fnwJobCd"}]');
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9401, 'SELECT
  user_id
  , facility_cd
  , user_type
  , personal_info_decrypt(user_last_name) AS user_last_name
  , personal_info_decrypt(user_first_name) AS user_first_name
  , personal_info_decrypt(user_last_name_kana) AS user_last_name_kana
  , personal_info_decrypt(user_first_name_kana) AS user_first_name_kana
  , personal_info_decrypt(user_last_name_alpha) AS user_last_name_alpha
  , personal_info_decrypt(user_first_name_alpha) AS user_first_name_alpha
  , personal_info_decrypt(user_email_address_1) AS user_email_address_1
  , personal_info_decrypt(user_email_address_2) AS user_email_address_2
  , personal_info_decrypt(extension_no) AS extension_no
  , personal_info_decrypt(home_no) AS home_no
  , personal_info_decrypt(mobile_phone_no) AS mobile_phone_no
  , personal_info_decrypt(fax_no) AS fax_no
  , personal_info_decrypt(zipcd_3) AS zipcd_3
  , personal_info_decrypt(zipcd_4) AS zipcd_4
  , personal_info_decrypt(address) AS address
  , personal_info_decrypt(address_kana) AS address_kana
  , personal_info_decrypt(job_cd) AS job_cd
  , reg_date
  , up_date
  , administrator
  , is_disp
  , is_del
  , in_hospital_cd_1
  , in_hospital_cd_2
  , info_disp_to_admin
  , personal_info_decrypt(anesthesiologist_license_no) AS anesthesiologist_license_no
  , signin_date
  , patient_shared
  , fn_staff_cd 
FROM
  mst_personal_user 
WHERE
  is_del = ''0'' 
  AND facility_cd = @facilityCd 
  AND in_hospital_cd_1 = @inHospitalCd1', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECスタッフマスタ連携の利用者取得(mst_personal_user)', '2021-12-07 10:00:00', '2021-12-07 10:00:00', NULL);
