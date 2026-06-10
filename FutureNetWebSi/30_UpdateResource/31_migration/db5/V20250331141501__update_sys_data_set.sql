DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (9401, 9402, 9403, 9404, 9406, 9407, 9409, 9410 , -600201, -600500, -600501, -600503, -600504, -600505, -600506, -600507, -600508, -600509, -600510, -600511, -600512, -600513, -600514, -600515, -600516 , -600517, -600518, -600203, -600303);


INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600518, 'DELETE FROM mst_user_authentication
WHERE disp_user_id = ''@inHospitalCd1''
AND facility_cd = ''@facilityCd''
AND TO_CHAR(CURRENT_DATE, ''YYYYMMDD'') NOT BETWEEN
    ''@startDateAfter'' AND ''@endDateAfter'';', 1, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', '2025-02-05 11:12:00.547', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600517, 'UPDATE mst_user
SET is_del = 1
WHERE user_id = @userId
AND TO_CHAR(CURRENT_DATE, ''YYYYMMDD'') NOT BETWEEN
    ''@startDateAfter'' AND ''@endDateAfter'';', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', '2025-02-05 11:12:00.547', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600516, 'UPDATE mst_personal_user
SET is_del = 1
WHERE user_id = @userId
AND TO_CHAR(CURRENT_DATE, ''YYYYMMDD'') NOT BETWEEN
    ''@startDateAfter'' AND ''@endDateAfter'';', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', '2025-02-05 11:12:00.547', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600515, 'SELECT
    1
WHERE
    char_length(CAST(@userKana AS TEXT)) > 20;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', '2024-12-30 05:07:03.298', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600514, 'SELECT
    1
WHERE
    char_length(CAST(@userName AS TEXT)) > 20;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', '2024-12-30 05:07:03.298', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600513, 'SELECT
    1
WHERE
    char_length(CAST(@userPassword AS TEXT)) > 16;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', '2024-12-30 05:07:03.298', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600512, 'SELECT
    1
WHERE
    @userPassword !~ ''^[a-zA-Z0-9]+$''
    AND @userPassword <> '''';', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', '2025-02-05 11:12:00.547', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600511, 'SELECT 
    1
WHERE
    (
        NOT (@endDateAfter ~ ''^\d{8}$'') 
        OR TO_DATE(@endDateAfter, ''YYYYMMDD'') IS NULL
    )
    AND @endDateAfter NOT IN (''00000000'', ''99999999'');', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', '2025-02-05 11:12:00.547', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600510, 'SELECT
    1
WHERE
        @endDateAfter = '''';', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', '2025-02-05 11:12:00.547', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600509, 'SELECT 
    1
WHERE
    (
        NOT (@startDateAfter ~ ''^\d{8}$'') 
        OR TO_DATE(@startDateAfter, ''YYYYMMDD'') IS NULL
    )
    AND @startDateAfter NOT IN (''00000000'', ''99999999'');', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', '2025-02-05 11:12:00.547', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600508, 'SELECT
    1
WHERE
        @startDateAfter = '''';', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', '2025-02-05 11:12:00.547', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600507, 'SELECT
    1
WHERE
    @inHospitalCd !~ ''^[a-zA-Z0-9]+$'';', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', '2025-02-05 11:12:00.547', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600506, 'SELECT
    1
WHERE
    char_length(CAST(@inHospitalCd AS TEXT)) > 10;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', '2024-12-30 05:07:03.298', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600505, 'SELECT
    1
WHERE
        @inHospitalCd = '''';', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', '2025-02-05 11:12:00.547', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600504, 'SELECT
    1
WHERE NOT (@crud IN (''C'', ''U'', ''D''))', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の利用者削除(mst_user_authentication 物理削除)', '2025-02-05 11:12:00.547', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600503, 'SELECT
    1
WHERE
        @inHospitalCd = ''ScalApp4''
        OR @inHospitalCd = ''CardApp4''
        OR @inHospitalCd = ''PrintSrvApp4'';', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の入力チェック', '2025-02-05 11:12:00.547', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600501, 'WITH is_name_empty_ng AS(
SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS val
FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND is_disp = ''1''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''NEC_MSTSTAFFRCV''
    AND info ->> ''key2'' = ''STAFF_NAME_EMPTY''
)
SELECT 1
WHERE CASE 
WHEN (SELECT val FROM is_name_empty_ng) = ''1'' AND @userName = '''' THEN TRUE
ELSE FALSE
END;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の連携設定.PROTECT_STAFFの制御', '2025-02-05 11:12:00.547', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600500, 'WITH is_pass_empty_ng AS(
SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS val
FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND is_disp = ''1''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''NEC_MSTSTAFFRCV''
    AND info ->> ''key2'' = ''STAFF_PASSWORD_EMPTY''
)
SELECT 1
WHERE CASE 
WHEN (SELECT val FROM is_pass_empty_ng) = ''1'' AND @userPassword = '''' THEN TRUE
ELSE FALSE
END;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の連携設定.PROTECT_STAFFの制御', '2025-02-05 11:12:00.547', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600201, 'SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS update_flg
FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND is_disp = ''1''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''NEC_MSTSTAFFRCV''
    AND info ->> ''key2'' = ''UPDATE_STAFF_CLASS''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携のUPDATE_DEL_FLG', '2025-02-05 11:12:00.547', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9401, 'SELECT
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
  AND in_hospital_cd_1 = @inHospitalCd1', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の利用者取得(mst_personal_user)', '2021-12-07 10:00:00.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
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
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9403, 'UPDATE mst_personal_user 
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
  , job_cd = CASE 
    WHEN ''@fnwUpdateFlg'' = ''1'' THEN personal_info_encrypt(NULLIF(''@fnwJobCd'', '''')) 
    ELSE job_cd
    END
  , up_date = CURRENT_TIMESTAMP 
WHERE
  is_del = ''0'' 
  AND user_id = @userId 
  AND facility_cd = ''@facilityCd'' ', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の利用者更新(mst_personal_user)', '2021-12-07 10:00:00.000', CURRENT_TIMESTAMP, '[{"sql_cd": -600201, "field_name": "update_flg", "replace_var": "@fnwUpdateFlg"}, {"sql_cd": 9404, "field_name": "job_cd", "replace_var": "@fnwJobCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9404, '  WITH staff_job_cd AS (
      SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND info ->> ''key0'' = @key0
        AND info ->> ''key1'' = ''NEC_MSTSTAFFRCV''
        AND info ->> ''key2'' = ''DEFAULT_STAFF_JOB_CD''
  )
   , mst_jobs as (
  SELECT
  job_cd,
  job_name,
  1 AS priority
  FROM
    mst_job
  WHERE
    mst_job.in_hospital_cd_1 = @jobCd
    AND mst_job.facility_cd = @facilityCd
  UNION ALL
  SELECT
    job_cd,
    job_name,
    2 AS priority
  FROM
    mst_job
  WHERE
    mst_job.in_hospital_cd_1 = (SELECT value FROM staff_job_cd)
    AND mst_job.facility_cd = @facilityCd
  ORDER BY priority ASC
  LIMIT 1
  )
 SELECT
  1 AS priority
  , job_cd::text
  , A.job_name 
FROM
  mst_jobs A
UNION 
SELECT
  2 AS priority
  , '''' AS job_cd
  , ''不明'' AS job_name 
ORDER BY
  priority ASC LIMIT 1', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携(連携の職種コードより、FNWの職種コードを取得)', '2021-12-07 10:00:00.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9406, 'INSERT INTO mst_user_authentication(
  user_id
  , facility_cd
  , disp_user_id
  , user_password
  , failure_cnt
  , reg_date
  , up_date
  , user_password_history
)
SELECT
  ''@userId'' :: bigint
  , ''@facilityCd''
  , NULLIF(''@dispUserId'', '''')
  , COALESCE(NULLIF(''@%%passwordencoder%%_userPassword'', ''''), COALESCE(NULLIF(''@%%passwordencoder%%_dispUserId'', '''')))
  , 0
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , NULL
WHERE 
    TO_CHAR(CURRENT_DATE, ''YYYYMMDD'') BETWEEN 
        ''@startDateAfter'' AND ''@endDateAfter''', 1, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の利用者新規(mst_user_authentication)', '2021-12-07 10:00:00.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9407, 'UPDATE mst_user_authentication 
SET
  user_password = COALESCE(NULLIF(''@%%passwordencoder%%_userPassword'', ''''), user_password)
  , up_date = CURRENT_TIMESTAMP 
WHERE
  user_id = @userId 
  AND facility_cd = ''@facilityCd''
  AND NULLIF(''@%%passwordencoder%%_userPassword'', '''') IS NOT NULL', 1, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の利用者更新(mst_user_authentication)', '2021-12-07 10:00:00.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9409, 'WITH job_settings AS ( 
  SELECT
    1 AS order_no
    , A.job_cd
    , A.default_menu_settings ->> ''initial_menu_function'' AS initial_menu_function
    , A.default_menu_settings ->> ''default_menu_functions'' AS default_menu_functions
    , array_to_json(STRING_TO_ARRAY(A.default_authorized_authorities, '','')) ::TEXT AS default_authorized_authorities 
  FROM
    mst_job A
  WHERE
    A.facility_cd = ''@facilityCd''
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
    AND A.job_cd::text = ''@fnwJobCd''
  UNION 
  SELECT
    2 AS order_no
    , - 1 AS job_cd
    , NULL AS initial_menu_function
    , NULL AS default_menu_functions
    , NULL AS default_authorized_authorities 
  ORDER BY order_no ASC LIMIT 1
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
  , is_consent
  , consent_date
  , reg_password_date
  , facility_cd
) 
SELECT
  '' @userId'' :: bigint
  , CASE WHEN (SELECT job_cd FROM job_user_settings) = -1 THEN
      ''@userSettingsValue''
    ELSE
      (SELECT user_settings FROM job_user_settings) :: JSONB
    END
  , 0
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
  , CASE ''@isConsent'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER( ''@isConsent'', ''FM9'') 
    END
  , NULL
  , CURRENT_TIMESTAMP
  , ''@facilityCd''
WHERE 
    TO_CHAR(CURRENT_DATE, ''YYYYMMDD'') BETWEEN 
        ''@startDateAfter'' AND ''@endDateAfter''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の利用者新規(mst_user)', '2021-12-07 10:00:00.000', CURRENT_TIMESTAMP, '[{"sql_cd": 9404, "field_name": "job_cd", "replace_var": "@fnwJobCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9410, 'WITH job_settings AS ( 
  SELECT
    1 AS order_no
    , A.job_cd
    , A.default_menu_settings ->> ''initial_menu_function'' AS initial_menu_function
    , A.default_menu_settings ->> ''default_menu_functions'' AS default_menu_functions
    , array_to_json(STRING_TO_ARRAY(A.default_authorized_authorities, '','')) ::TEXT AS default_authorized_authorities 
  FROM
    mst_job A
  WHERE
    A.facility_cd = ''@facilityCd''
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
    AND A.job_cd::text = ''@fnwJobCd''
  UNION 
  SELECT
    2 AS order_no
    , - 1 AS job_cd
    , NULL AS initial_menu_function
    , NULL AS default_menu_functions
    , NULL AS default_authorized_authorities 
  ORDER BY order_no ASC LIMIT 1
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
  AND facility_cd = ''@facilityCd''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECスタッフマスタ連携の利用者更新(mst_user)', '2021-12-07 10:00:00.000', CURRENT_TIMESTAMP, '[{"sql_cd": 9404, "field_name": "job_cd", "replace_var": "@fnwJobCd"}]'::jsonb);



INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600203, 'WITH IND_ORDER_NO_HEADER_cd AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS ind_header_cd
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC''
        AND info ->> ''key2'' = ''IND_ORDER_NO_HEADER''
)
SELECT
    CASE
        WHEN LENGTH(coop_ord_no) <= 11
        THEN concat((SELECT ind_header_cd FROM IND_ORDER_NO_HEADER_cd)
            , to_char(to_number(coop_ord_no, ''FM00000000000''), ''FM00000000000'')
            , ''000'')
        ELSE coop_ord_no
    END AS ind_ord_no
FROM sys_coop_journal
WHERE
    ctl_no = @ctlNo', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC)オーダ番号', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600303, 'WITH IND_ORDER_NO_HEADER_cd AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS ind_header_cd
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC''
        AND info ->> ''key2'' = ''IND_ORDER_NO_HEADER''
)
, DIALYSIS_ORDER_NO_HEADER_cd AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS dialysis_header_cd
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC''
        AND info ->> ''key2'' = ''DIALYSIS_ORDER_NO_HEADER''
)
, ind_dial_journal AS (
    SELECT
        CASE
            WHEN LENGTH(coop_ord_no) <= 11
            THEN concat((SELECT ind_header_cd FROM IND_ORDER_NO_HEADER_cd)
                , to_char(to_number(coop_ord_no, ''FM00000000000''), ''FM00000000000'')
                , ''000'')
            ELSE coop_ord_no
            END AS coop_ord_no
    FROM ord_coop_no
    WHERE
        ord_no = @ordNo
        AND facility_cd = @facilityCd
        AND coop_cd = ''ind_dial''
        AND is_del = ''0''
        AND is_disp = ''1''
        AND status = ''1''
)
, rst_dial_journal AS (
    SELECT
        CASE
            WHEN LENGTH(coop_ord_no) <= 11
            THEN concat((SELECT dialysis_header_cd FROM DIALYSIS_ORDER_NO_HEADER_cd)
                , to_char(to_number(coop_ord_no, ''FM00000000000''), ''FM00000000000'')
                , ''000'')
            ELSE coop_ord_no
        END AS coop_ord_no
    FROM sys_coop_journal
    WHERE
        ctl_no = @ctlNo
)
, rst_ord AS (
    SELECT ord.rst_dw AS rst_dw
    FROM ord_main ord
    WHERE ord.ord_no =  @ordNo
    AND ord.facility_cd = @facilityCd
)
SELECT
    CASE
        WHEN (SELECT coop_ord_no FROM ind_dial_journal) IS NOT NULL
        THEN (SELECT coop_ord_no FROM ind_dial_journal)
        ELSE ''0000000000000000''
        END AS ind_ord_no,
    (SELECT coop_ord_no FROM rst_dial_journal) AS rst_ord_no,
    TO_CHAR(COALESCE((SELECT rst_dw FROM rst_ord), 0), ''FM000V9'') AS dw', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC)オーダ番号・DW', '2025-03-18 11:34:58.308', CURRENT_TIMESTAMP, NULL);
