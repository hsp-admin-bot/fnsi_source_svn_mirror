DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (
	9402,-600514,-600515
	);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9402, 'INSERT INTO mst_personal_user( 
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
SELECT
  ''@facilityCd''
  , TO_NUMBER(COALESCE(NULLIF(''@userType'', ''''), ''0''), ''FM9'')
  , personal_info_encrypt(COALESCE(NULLIF(split_part(''@userName'', ''　'', 1), ''''), ''@inHospitalCd1''))
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
  , NULL
  , ''0''
  , personal_info_encrypt(NULLIF(''@anesthesiologistLicenseNo'', ''''))
  , NULL
  , CASE ''@patientShared'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER( ''@patientShared'', ''FM9999999999'') 
    END
  , NULLIF(''@fnStaffCd'', '''')
WHERE 
    TO_CHAR(CURRENT_DATE, ''YYYYMMDD'') BETWEEN 
        ''@startDateAfter'' AND ''@endDateAfter''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の利用者新規(mst_personal_user)', '2021-12-07 10:00:00.000', CURRENT_TIMESTAMP, '[{"sql_cd": 9404, "field_name": "job_cd", "replace_var": "@fnwJobCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600514, 'SELECT
    1
WHERE
    octet_length(convert_to(CAST(@userName AS TEXT), ''SJIS'')) > 20;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', '2024-12-30 05:07:03.298', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600515, 'SELECT
    1
WHERE
    octet_length(convert_to(CAST(@userKana AS TEXT), ''SJIS'')) > 20;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', '2024-12-30 05:07:03.298', CURRENT_TIMESTAMP, NULL);