delete from "sys_data_set" where "sql_cd" in (9409,9408);
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
FROM
  mst_user 
WHERE
  user_id = @userId', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECスタッフマスタ連携の利用者取得(mst_user)', '2021-12-07 10:00:00', '2021-12-07 10:00:00', NULL);
