DELETE  FROM "ntss"."sys_data_set" WHERE sql_cd IN (10000,10001,10002,10003,10004,10005,10006,10007,10008,10009,10010,10011,10012,10013,10014);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (10008, 'SELECT
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
  user_id = @userId', 1, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通)スタッフマスタ連携の利用者取得(mst_user_authentication)', CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (10007, 'UPDATE mst_user_authentication 
SET
  disp_user_id = NULLIF(''@dispUserId'', '''')
  , user_password = COALESCE(NULLIF(''@%%passwordencoder%%_userPassword'', ''''), COALESCE(NULLIF(''@%%passwordencoder%%_dispUserId'', ''''), ''@%%passwordencoder%%_defaultPassword''))
  , up_date = CURRENT_TIMESTAMP 
WHERE
  user_id = @userId 
  AND facility_cd = ''@facilityCd''
', 1, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通)スタッフマスタ連携の利用者更新(mst_user_authentication)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (10004, 'WITH del_staff_flg AS (
   SELECT
    ''0'' AS order_no 
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS del_staff_flg 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND COALESCE(info->>''key0'','''') = @key0
    AND info->>''key1'' = ''FJI_MST_STAFF''
    AND info->>''key2'' = ''DEL_STAFF_FLG''
  UNION
  SELECT
    ''1'' AS order_no 
    , ''0'' AS del_staff_flg 
  ORDER BY order_no ASC LIMIT 1
)
SELECT del_staff_flg FROM del_staff_flg 
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通)スタッフマスタ連携:利用者取得連携設定 「削除済みスタッフの更新フラグ」', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (10006, 'INSERT INTO mst_user_authentication( 
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
)', 1, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通)スタッフマスタ連携の利用者新規(mst_user_authentication)',CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (10011, 'SELECT
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
FROM
  mst_user 
WHERE
  user_id = @userId', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通)スタッフマスタ連携の利用者取得(mst_user)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (10003, 'with del_user AS (
SELECT
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
   facility_cd = @facilityCd 
  AND in_hospital_cd_1 = @inHospitalCd1
 AND @del_staff_flg= ''0''
ORDER BY up_date  desc
 LIMIT 1 
)

SELECT
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
  del_user 
WHERE
  is_del =''1''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通)スタッフマスタ連携:削除済みスタッフの更新フラグ判断', CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, '[{"sql_cd": 10004, "field_name": "del_staff_flg", "replace_var": "@del_staff_flg"}]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (10001, 'UPDATE mst_personal_user 
SET
    user_last_name = personal_info_encrypt(COALESCE(NULLIF(split_part(''@userName'', ''　'', 1), ''''), '' ''))
  , user_first_name = personal_info_encrypt(COALESCE(NULLIF(split_part(''@userName'', ''　'', 2), ''''), '' ''))
  , user_last_name_kana = personal_info_encrypt(COALESCE(NULLIF(split_part(''@userKana'', ''　'', 1), ''''), '' ''))
  , user_first_name_kana = personal_info_encrypt(COALESCE(NULLIF(split_part(''@userKana'', ''　'', 2), ''''), '' ''))
  , up_date = CURRENT_TIMESTAMP 
WHERE
  is_del = ''0''
  AND user_id = @userId 
  AND facility_cd = ''@facilityCd'' ', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通)スタッフマスタ連携の利用者更新(mst_personal_user)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (10009, 'WITH job_settings AS ( 
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
    AND A.job_cd = @job_cd
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
  , is_consent
  , consent_date
  , reg_password_date
  , facility_cd
) 
VALUES ( 
  @userId
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
  , NULL
  , NULL
  , NULL
  , 0
  , 0
  , NULL
  , NULL
  , ''@facilityCd''
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通)スタッフマスタ連携の利用者新規(mst_user)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 10005, "field_name": "job_cd", "replace_var": "@job_cd"}, {"sql_cd": 10005, "field_name": "order_no", "replace_var": "@order_no"}]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (10005, 'WITH  FJI_MST_STAFF_JOB_AUTH AS( -- 連携設定[職種ごとのスタッフ権限]
  SELECT
    ''0'' AS order_no 
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS fji_mst_staff_job_auth
  , @jobCd ::TEXT AS jobCd
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND COALESCE(info->>''key0'','''') =  @key0
    AND info->>''key1'' = ''FJI_MST_STAFF_JOB_AUTH''
    AND info->>''key2'' = @jobCd
)
,MST_JOB_SELECTOR AS(--FNIS  システムソート
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
)
,DEFAULT_JOB_CD AS (--連携設定[デフォルト職種]
  SELECT
    ''0'' AS order_no 
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS default_job_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND COALESCE(info->>''key0'','''') =  @key0
    AND info->>''key1'' = ''FJI_MST_STAFF''
    AND info->>''key2'' = ''DEFAULT_JOB_CD''
  ORDER BY order_no ASC LIMIT 1
)
SELECT
  1 AS order_no
  , A.up_date
  , CAST(A.job_cd AS TEXT) AS job_cd
  , A.job_name
  , A.is_doctor
  , A.in_hospital_cd_1 
FROM
  mst_job A
  ,MST_JOB_SELECTOR ms 
WHERE
  A.facility_cd = ms.facility_cd 
  AND A.job_cd = ms.code 
  AND A.is_del = ''0'' 
  AND A.is_disp = ''1'' 
  AND A.in_hospital_cd_1 = (SELECT jobCd FROM FJI_MST_STAFF_JOB_AUTH)::TEXT
UNION
SELECT
  2 AS order_no
  , A.up_date
  , CAST(A.job_cd AS TEXT) AS job_cd
  , A.job_name
  , A.is_doctor
  , A.in_hospital_cd_1 
FROM
  mst_job A
  ,MST_JOB_SELECTOR ms 
WHERE
  A.facility_cd = ms.facility_cd 
  AND A.job_cd = ms.code 
  AND A.is_del = ''0'' 
  AND A.is_disp = ''1'' 
  AND A.in_hospital_cd_1 = @jobCd
UNION 
SELECT
  3 AS order_no
  , A.up_date
  , CAST(A.job_cd AS TEXT) AS job_cd
  , A.job_name
  , A.is_doctor
  , A.in_hospital_cd_1 
FROM
  mst_job A
  ,MST_JOB_SELECTOR ms 
WHERE
  A.facility_cd = ms.facility_cd 
  AND A.job_cd = ms.code 
  AND A.is_del = ''0'' 
  AND A.is_disp = ''1'' 
  AND A.in_hospital_cd_1 = (SELECT default_job_cd FROM DEFAULT_JOB_CD)::TEXT
UNION 
SELECT
  4 AS order_no
  , CURRENT_TIMESTAMP AS up_date
  , ''-1'' AS job_cd
  , ''不明'' AS job_name
  , ''0'' AS is_doctor
  , '''' AS in_hospital_cd_1 
ORDER BY
  order_no ASC, up_date DESC LIMIT 1 ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通)スタッフマスタ連携の利用者取得職種', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (10012, 'WITH  STAFF_AUTH AS(  -- 連携設定[デフォルトスタッフ権限]
 SELECT
  ''0'' AS order_no,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_auth 
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: JSON ) info 
 WHERE
  facility_cd = ''@facilityCd''
  
  AND is_del = ''0'' 
  AND COALESCE ( info ->> ''key0'', '''' ) = ''@key0''
  
  AND info ->> ''key1'' = ''FJI_MST_STAFF'' 
  AND info ->> ''key2'' = ''STAFF_AUTH''

)
,STAFF_JOB_AUTH AS (-- 連携設定[職種ごとのスタッフ権限]
 SELECT
  ''0'' AS order_no,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_job_auth 
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: JSON ) info 
 WHERE
  facility_cd =  ''@facilityCd'' 
  AND is_del = ''0'' 
  AND COALESCE ( info ->> ''key0'', '''' ) = ''@key0'' 
  AND info ->> ''key1'' = ''FJI_MST_STAFF_JOB_AUTH'' 
  AND info ->> ''key2'' = ''@jobCd''

)
,STAFF_AUTHORITY AS( --  デフォルトスタッフ権限：権限分割　　　[11111101]
 SELECT ROW_NUMBER
  ( ) OVER ( ) :: INTEGER AS ordernow1,
  func AS func 
 FROM
  ( SELECT regexp_split_to_table( A.staff_auth, '''' ) AS func FROM STAFF_AUTH A ) T

) 
,STAFF_JOB_AUTH_STAFF_AUTHORITY AS(--   職種ごとのスタッフ権限：権限分割　　　[11111101]
 SELECT ROW_NUMBER
  ( ) OVER ( ) :: INTEGER AS ordernow1,
  func AS func 
 FROM
  ( SELECT regexp_split_to_table( A.staff_job_auth, '''' ) AS func FROM STAFF_JOB_AUTH A ) T
)
,AUTHORITY_SETTING AS( -- FNIS 画面のデフォルト権限
 SELECT
  1 AS tag,
  ''"037"'' AS settingfunc UNION ALL
 SELECT
  1 AS tag,
  ''"020"'' AS settingfunc UNION ALL
 SELECT
  2 AS tag,
  ''"017"'' AS settingfunc UNION ALL
 SELECT
  2 AS tag,
  ''"007"'' AS settingfunc UNION ALL
 SELECT
  2 AS tag,
  ''"023"'' AS settingfunc UNION ALL
 SELECT
  2 AS tag,
  ''"010"'' AS settingfunc UNION ALL
 SELECT
  3 AS tag,
  ''"027"'' AS settingfunc UNION ALL
 SELECT
  3 AS tag,
  ''"030"'' AS settingfunc UNION ALL
 SELECT
  3 AS tag,
  ''"016"'' AS settingfunc UNION ALL
 SELECT
  4 AS tag,
  ''"010"'' AS settingfunc UNION ALL
 SELECT
  5 AS tag,
  ''"004"'' AS settingfunc UNION ALL
 SELECT
  5 AS tag,
  ''"009"'' AS settingfunc UNION ALL
 SELECT
  6 AS tag,
  ''"004"'' AS settingfunc UNION ALL
 SELECT
  6 AS tag,
  ''"009"'' AS settingfunc UNION ALL
 SELECT
  6 AS tag,
  ''"013"'' AS settingfunc UNION ALL
 SELECT
  7 AS tag,
  ''"028"'' AS settingfunc UNION ALL
 SELECT
  7 AS tag,
  ''"005"'' AS settingfunc UNION ALL
 SELECT
  8 AS tag,
  ''"022"'' AS settingfunc UNION ALL
 SELECT
  8 AS tag,
  ''"021"'' AS settingfunc UNION ALL
 SELECT
  9 AS tag,
  ''"029"'' AS settingfunc UNION ALL
 SELECT
  10 AS tag,
  ''"006"'' AS settingfunc UNION ALL
 SELECT
  11 AS tag,
  ''"018"'' AS settingfunc UNION ALL
 SELECT
  12 AS tag,
  ''"032"'' AS settingfunc UNION ALL
 SELECT
  12 AS tag,
  ''"033"'' AS settingfunc UNION ALL
 SELECT
  12 AS tag,
  ''"034"'' AS settingfunc UNION ALL
 SELECT
  13 AS tag,
  ''"007"'' AS settingfunc UNION ALL
 SELECT
  14 AS tag,
  ''"027"'' AS settingfunc UNION ALL
 SELECT
  14 AS tag,
  ''"030"'' AS settingfunc UNION ALL
 SELECT
  14 AS tag,
  ''"016"'' AS settingfunc UNION ALL
 SELECT
  15 AS tag,
  ''"006"'' AS settingfunc UNION ALL
 SELECT
  16 AS tag,
  ''"018"'' AS settingfunc UNION ALL
 SELECT
  17 AS tag,
  ''"029"'' AS settingfunc

)
,EDIT_SETTING AS(--FNISデフォルトスタッフ権限
 SELECT
  1 AS tag,
  ''2'' AS editcdoe,
  ''013'' AS edit_setting UNION ALL
 SELECT
  2 AS tag,
  ''2'' AS editcdoe,
  ''023'' AS edit_setting UNION ALL
 SELECT
  3 AS tag,
  ''2'' AS editcdoe,
  ''033'' AS edit_setting UNION ALL
 SELECT
  4 AS tag,
  ''2'' AS editcdoe,
  ''043'' AS edit_setting UNION ALL
 SELECT
  5 AS tag,
  ''1'' AS editcdoe,
  ''052'' AS edit_setting UNION ALL
 SELECT
  5 AS tag,
  ''2'' AS editcdoe,
  ''053'' AS edit_setting UNION ALL
 SELECT
  6 AS tag,
  ''2'' AS editcdoe,
  ''133'' AS edit_setting UNION ALL
 SELECT
  7 AS tag,
  ''2'' AS editcdoe,
  ''063'' AS edit_setting UNION ALL
 SELECT
  8 AS tag,
  ''1'' AS editcdoe,
  ''072'' AS edit_setting UNION ALL
 SELECT
  8 AS tag,
  ''2'' AS editcdoe,
  ''073'' AS edit_setting UNION ALL
 SELECT
  9 AS tag,
  ''1'' AS editcdoe,
  ''082'' AS edit_setting UNION ALL
 SELECT
  9 AS tag,
  ''2'' AS editcdoe,
  ''083'' AS edit_setting UNION ALL
 SELECT
  10 AS tag,
  ''2'' AS editcdoe,
  ''093'' AS edit_setting UNION ALL
 SELECT
  11 AS tag,
  ''2'' AS editcdoe,
  ''103'' AS edit_setting UNION ALL
 SELECT
  12 AS tag,
  ''2'' AS editcdoe,
  ''113'' AS edit_setting UNION ALL
 SELECT
  13 AS tag,
  ''3'' AS editcdoe,
  ''991'' AS edit_setting UNION ALL
 SELECT
  14 AS tag,
  ''3'' AS editcdoe,
  ''992'' AS edit_setting UNION ALL
 SELECT
  15 AS tag,
  ''3'' AS editcdoe,
  ''993'' AS edit_setting UNION ALL
 SELECT
  16 AS tag,
  ''3'' AS editcdoe,
  ''994'' AS edit_setting UNION ALL
 SELECT
  17 AS tag,
  ''3'' AS editcdoe,
  ''995'' AS edit_setting
)
,AUTHORITY_SETTING_ENABLE AS( -- 利用可能を権限
 SELECT
  1 AS tag,
  ''2'' AS authority_setting_enable UNION ALL
 SELECT
  2 AS tag,
  ''2'' AS authority_setting_enable UNION ALL
 SELECT
  3 AS tag,
  ''2'' AS authority_setting_enable UNION ALL
 SELECT
  4 AS tag,
  ''2'' AS authority_setting_enable UNION ALL
 SELECT
  5 AS tag,
  ''1'' AS authority_setting_enable UNION ALL
  SELECT
  5 AS tag,
  ''2'' AS authority_setting_enable UNION ALL
 SELECT
  6 AS tag,
  ''2'' AS authority_setting_enable UNION ALL
 SELECT
  7 AS tag,
  ''2'' AS authority_setting_enable UNION ALL
 SELECT
  8 AS tag,
  ''1'' AS authority_setting_enable UNION ALL
 SELECT
  8 AS tag,
  ''2'' AS authority_setting_enable UNION ALL
 SELECT
  9 AS tag,
  ''1'' AS authority_setting_enable UNION ALL
 SELECT
  9 AS tag,
  ''2'' AS authority_setting_enable UNION ALL
 SELECT
  10 AS tag,
  ''2'' AS authority_setting_enable UNION ALL
 SELECT
  11 AS tag,
  ''2'' AS authority_setting_enable UNION ALL
 SELECT
  12 AS tag,
  ''2'' AS authority_setting_enable UNION ALL
 SELECT
  13 AS tag,
  ''2'' AS authority_setting_enable UNION ALL
 SELECT
  14 AS tag,
  ''2'' AS authority_setting_enable UNION ALL
 SELECT
  15 AS tag,
  ''2'' AS authority_setting_enable UNION ALL
 SELECT
  16 AS tag,
  ''2'' AS authority_setting_enable UNION ALL 
 SELECT
  17 AS tag,
  ''2'' AS authority_setting_enable 
)
,STAFF_AUTHORITY_SETTING_INFO AS (
 SELECT DISTINCT
  ( aut.settingfunc ) :: TEXT AS settingfunc 
 FROM
  STAFF_AUTHORITY SA
  LEFT JOIN AUTHORITY_SETTING AS aut ON aut.tag = ordernow1
  JOIN AUTHORITY_SETTING_ENABLE AS ase ON ase.tag = ordernow1 
  AND ase.authority_setting_enable = func
)
,STAFF_AUTHORITY_SETTING AS(--[デフォルトスタッフ権限]画面権限：統廃合　
 SELECT
 ''{"initial_menu_function": ''||(SELECT settingfunc FROM STAFF_AUTHORITY_SETTING_INFO LIMIT 1)||'', "default_menu_functions": [''
  ||string_agg ( settingfunc, '','' ) 
  ||'']}''  AS  staff_authority_setting
 FROM
 STAFF_AUTHORITY_SETTING_INFO
)
,STAFF_EDIT_SETTING AS(--[デフォルトスタッフ権限]デフォルトスタッフ権限：統廃合

 SELECT
  string_agg ( T.settingfunc, '','' ) AS  staff_edit_setting
 FROM
  ( SELECT DISTINCT ( aut.edit_setting ) :: TEXT AS settingfunc FROM STAFF_AUTHORITY SA LEFT JOIN EDIT_SETTING AS aut ON aut.tag = SA.ordernow1 AND aut.editcdoe = func) T

)
,STAFF_JOB_AUTH_STAFF_AUTHORITY_SETTING_INFO AS(
 SELECT DISTINCT
  ( aut.settingfunc ) :: TEXT AS settingfunc 
 FROM
  STAFF_JOB_AUTH_STAFF_AUTHORITY fJ
  LEFT JOIN AUTHORITY_SETTING AS aut ON aut.tag = ordernow1
  JOIN AUTHORITY_SETTING_ENABLE AS ase ON ase.tag = ordernow1 
  AND ase.authority_setting_enable = func

)
,STAFF_JOB_AUTH_STAFF_AUTHORITY_SETTING AS(--[職種ごとのスタッフ権限]画面権限：統廃合
 SELECT
  ''{"initial_menu_function": ''||(SELECT * FROM STAFF_JOB_AUTH_STAFF_AUTHORITY_SETTING_INFO LIMIT 1)||'', "default_menu_functions": ['' || string_agg ( settingfunc, '','' ) || '']}'' AS staff_authority_setting 
 FROM
  STAFF_JOB_AUTH_STAFF_AUTHORITY_SETTING_INFO
)
,STAFF_JOB_AUTH_STAFF_AUTHORITY_EDIT_SETTING AS(--[職種ごとのスタッフ権限]デフォルトスタッフ権限：統廃合

 SELECT
  string_agg ( T.settingfunc, '','' ) AS  staff_edit_setting
 FROM
  ( SELECT DISTINCT ( aut.edit_setting ) :: TEXT AS settingfunc FROM STAFF_JOB_AUTH_STAFF_AUTHORITY fJ LEFT JOIN EDIT_SETTING AS aut ON aut.tag = ordernow1 AND aut.editcdoe = func) T
)


UPDATE mst_job 
SET default_menu_settings = ( CASE ''@order_no'' WHEN ''3'' THEN ( SELECT staff_authority_setting FROM STAFF_AUTHORITY_SETTING ) WHEN ''1'' THEN ( SELECT staff_authority_setting FROM STAFF_JOB_AUTH_STAFF_AUTHORITY_SETTING ) END ) :: JSONB,
up_date = CURRENT_TIMESTAMP,
default_authorized_authorities = ( CASE ''@order_no'' WHEN ''3'' THEN ( SELECT staff_edit_setting FROM STAFF_EDIT_SETTING ) WHEN ''1'' THEN ( SELECT staff_edit_setting FROM STAFF_JOB_AUTH_STAFF_AUTHORITY_EDIT_SETTING ) END ) 
WHERE
 job_cd = @job_cd AND  (''@order_no'' = ''1'' OR ''@order_no'' = ''3'') 

', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通)スタッフマスタ連携の利用者取得(mst_job)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 10005, "field_name": "job_cd", "replace_var": "@job_cd"}, {"sql_cd": 10005, "field_name": "order_no", "replace_var": "@order_no"}]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (10013, '-- 『現在日(YYYYMMDD) ≧ 有効期間開始日時』、かつ
-- 『現在日(YYYYMMDD) ≦ 有効期間終了日時』、かつ
-- 『廃止フラグが1以外』、かつ
-- 『使用停止フラグが1以外』
SELECT
 1
WHERE
 NOT EXISTS (
 SELECT 1
 WHERE
  @stopTag <> ''1'' 
  AND @abolishTag <> ''1'' 
  AND CURRENT_DATE >= to_date( @indateStart, ''YYYYMMDD'' ) 
 AND CURRENT_DATE <= to_date( @indatesEnd, ''YYYYMMDD'' )
 )', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通)スタッフマスタ連携取り込み条件判断',CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 10005, "field_name": "job_cd", "replace_var": "@job_cd"}, {"sql_cd": 10005, "field_name": "order_no", "replace_var": "@order_no"}]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (10014, 'SELECT
 1 AS num,
 user_id AS user_id 
FROM
 mst_personal_user 
WHERE
 is_del = ''0'' 
 AND facility_cd = @facilityCd 
 AND in_hospital_cd_1 = @inHospitalCd1 
 UNION
SELECT
 2 AS num,
 -1 AS user_id 
ORDER BY num ASC
LIMIT 1', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通)スタッフマスタ連携同名判断',CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (10010, 'SELECT
 * 
FROM
 mst_user_authentication 
WHERE
 facility_cd = @facilityCd
 AND disp_user_id= @inHospitalCd1
    AND -1  = @user_id', 1, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通)スタッフマスタ連携同名判断', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 10014, "field_name": "user_id", "replace_var": "@user_id"}]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (10000, 'INSERT INTO mst_personal_user( 
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
  , personal_info_encrypt(COALESCE(NULLIF(split_part(''@userKana'', ''　'', 1), ''''), '' ''))
  , personal_info_encrypt(COALESCE(NULLIF(split_part(''@userKana'', ''　'', 2), ''''), '' ''))
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , personal_info_encrypt(NULLIF(''@fnwJobCd'', ''-1''))
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , TO_NUMBER( COALESCE(NULLIF(''@administrator'', ''''), ''0''), ''FM9'') 
  , ''1''
  , ''0''
  , NULLIF(''@inHospitalCd1'', '''')
  , NULLIF(''@inHospitalCd2'', '''')
  , ''0''
  , NULL
  , NULL
  , NULL
  , NULL
)', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通)スタッフマスタ連携の利用者新規(mst_personal_user)',CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 10005, "field_name": "job_cd", "replace_var": "@fnwJobCd"}]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (10002, 'SELECT
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
  AND in_hospital_cd_1 = @inHospitalCd1', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通)スタッフマスタ連携の利用者取得(mst_personal_user)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
