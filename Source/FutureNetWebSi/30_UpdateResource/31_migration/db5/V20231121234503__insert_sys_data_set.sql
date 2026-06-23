DELETE 
FROM ntss.sys_data_set
WHERE sql_cd IN (-303001,-303002,-303003,-303004,-303101,-303102,-303103,-303201,-306101,-306102,-306103,-306104,-307001,-307002,-307003,-307004,-307005,-307006,-307007,-307008,-307009,-307010,-307011,-307012,-307013,-307014,-307015,-307016,-307017,-307018,-307019,-307020,-307021,-307022,-307023,-307024,-307025,-307026,-307027,-307028,-307029,-307030,-307031,-307032,-307033,-307034,-307035,-307036,-307037,-307038,-307039,-307040,-307041,-307042,-307043,-307044,-307045,-307046,-307047,-307048,-307049,-307050,-307051,-307052,-307053,-307054,-307055,-307056,-307057,-307058,-307059,-307060,-307061,-307062,-307063,-307064,-307065,-307066,-307067,-307068,-307069,-307070,-307071,-307073,-309101,-310001,-310002,-310003,-310004,-310005,-310006,-310007,-310008,-310009,-310010,-310011,-310012,-310013,-310014,-310015,-317019,-317102,-317104,-317105,-317106,-317107,-317108,-317110,-317111,-317112,-317113,-317114,-317115,-317116,-317117,-317118,-317119,-317120,-317121,-317122,-317123,-317124,-317140,-317141)
;


-- 患者頭書連携
-- I pat_personal_main
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-303101, 'WITH new_name_info AS ( 
  SELECT
    substring(''@patLastName'' ::TEXT from ''^(.*?)[\u3000\s]'') AS patLastName
    , substring(''@patLastName'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstName
    , substring(''@patLastNmKana'' ::TEXT from ''^(.*?)[\u3000\s]'') AS patLastNmKana
    , substring(''@patLastNmKana'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstNmKana
) 
, birthday_info AS ( 
SELECT
  CASE WHEN left(wareki, 1) = ''M'' THEN (18670000 + to_number(right(wareki, 6), ''999999'')) :: text
       WHEN left(wareki, 1) = ''T'' THEN (19110000 + to_number(right(wareki, 6), ''999999'')) :: text
       WHEN left(wareki, 1) = ''S'' THEN (19250000 + to_number(right(wareki, 6), ''999999'')) :: text
       WHEN left(wareki, 1) = ''H'' THEN (19880000 + to_number(right(wareki, 6), ''999999'')) :: text
       WHEN left(wareki, 1) = ''R'' THEN (20180000 + to_number(right(wareki, 6), ''999999'')) :: text
       else wareki
  END AS seireki
FROM
  (
    SELECT ''@patBirthday'' AS wareki
  ) AS tmp
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
  NULL
  , LEFT(NULLIF(''@hospPatId'', ''''),12)
  , NULL
  , NULLIF(''@facilityCd'', '''')
  , personal_info_encrypt((SELECT patLastName FROM new_name_info)) 
  , personal_info_encrypt((SELECT patFirstName FROM new_name_info))
  , personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
  , personal_info_encrypt((SELECT patFirstNmKana FROM new_name_info))
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , (SELECT seireki FROM birthday_info)
  , CASE  
    WHEN ''@patSex'' NOT IN (''1'',''2'') THEN 0
    ELSE TO_NUMBER(''@patSex'', ''FM9999999999999999'') 
    END
  , ''JPN''
  , NULL
  , NULL
  , NULL
  , 0
  , NULL
  , NULL
  , NULL
  , COALESCE(NULLIF(''@dialDiffComInfo'', ''''), ''[]'') ::JSONB
  , NULL
  , NULL
  , json_build_object( 
      ''zip_cd''
      , NULLIF(''@patContactInfo.zipCd'', '''')
      , ''address''
      , NULLIF(''@patContactInfo.address1'' || ''@patContactInfo.address2'', '''')
      , ''tel1''
      , NULLIF(''@patContactInfo.tel1'', '''')
      , ''tel2''
      , NULLIF(''@patContactInfo.tel2'', '''')
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
  ,  ''[]'' ::JSONB
  ,  ''[]'' ::JSONB
  , ''[]'' ::JSONB
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , NULL
  , NULL
  , NULL
  , NULL
)', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)患者個人情報の新規登録', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -303001, "field_name": "dial_diff_com_info", "replace_var": "@dialDiffComInfo"}]'::jsonb);




--S mst_dialysis_difficulty
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-303001, 'SELECT
  array_to_json(ARRAY_AGG(T.col)) AS dial_diff_com_info
FROM
  ( 
    SELECT
      json_build_object(''is_main'', ''0'', ''reg_date'', null, ''dial_diff_cd'', A.dialysis_difficulty_cd, ''is_dial_diff'', ''0'') AS col
    FROM
      mst_dialysis_difficulty A 
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
      AND master_physical_name = ''mst_dialysis_difficulty'' 
      ) ms 
    WHERE
      A.facility_cd = ms.facility_cd 
      AND A.dialysis_difficulty_cd = ms.code 
      AND A.is_del = ''0'' 
      AND A.is_disp = ''1'' 
    ORDER BY
      ms.INDEX
  ) AS T', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '外部連携用の[患者個人情報→透析困難情報]デフォルト値の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



-- U pat_personal_main
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-303201, 'WITH new_name_info AS ( 
  SELECT
    substring(''@patLastName'' ::TEXT from ''^(.*?)[\u3000\s]'') AS patLastName
    , substring(''@patLastName'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstName
    , substring(''@patLastNmKana'' ::TEXT from ''^(.*?)[\u3000\s]'') AS patLastNmKana
    , substring(''@patLastNmKana'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstNmKana
) 
, birthday_info AS ( 
SELECT
  CASE WHEN left(wareki, 1) = ''M'' THEN (18670000 + to_number(right(wareki, 6), ''999999'')) :: text
       WHEN left(wareki, 1) = ''T'' THEN (19110000 + to_number(right(wareki, 6), ''999999'')) :: text
       WHEN left(wareki, 1) = ''S'' THEN (19250000 + to_number(right(wareki, 6), ''999999'')) :: text
       WHEN left(wareki, 1) = ''H'' THEN (19880000 + to_number(right(wareki, 6), ''999999'')) :: text
       WHEN left(wareki, 1) = ''R'' THEN (20180000 + to_number(right(wareki, 6), ''999999'')) :: text
       else wareki
  END AS seireki
FROM
  (
    SELECT ''@patBirthday'' AS wareki
  ) AS tmp 
)

UPDATE pat_personal_main 
SET
  pat_last_name = CASE WHEN pat_last_name IS NULL THEN personal_info_encrypt((SELECT patLastName FROM new_name_info)) ELSE pat_last_name END
  , pat_first_name = CASE WHEN pat_first_name IS NULL THEN personal_info_encrypt((SELECT pat_first_name FROM new_name_info)) ELSE pat_first_name END
  , pat_last_name_kana = CASE WHEN pat_last_name_kana IS NULL THEN personal_info_encrypt((SELECT pat_last_name_kana FROM new_name_info)) ELSE pat_last_name_kana END
  , pat_first_name_kana = CASE WHEN pat_first_name_kana IS NULL THEN personal_info_encrypt((SELECT pat_first_name_kana FROM new_name_info)) ELSE pat_first_name_kana END
  , pat_birthday = (SELECT seireki FROM birthday_info)
  , pat_sex = CASE  
    WHEN ''@patSex'' NOT IN (''1'',''2'') THEN 0
    ELSE TO_NUMBER(''@patSex'', ''FM9999999999999999'') 
    END
  , pat_contact_info = pat_contact_info || json_build_object( 
      ''zip_cd''
      , NULLIF(''@patContactInfo.zipCd'', '''')
      , ''address''
      , NULLIF(''@patContactInfo.address1'' || ''@patContactInfo.address2'', '''')
      , ''tel1''
      , NULLIF(''@patContactInfo.tel1'', '''')
      , ''tel2''
      , NULLIF(''@patContactInfo.tel2'', '''')
    ) :: jsonb
  , up_date = CURRENT_TIMESTAMP
WHERE
  is_del = ''0'' 
  AND hosp_pat_id = ''@hospPatId''  
  AND facility_cd = ''@facilityCd''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)患者個人情報の修正', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



--S pat_main
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-303002, 'SELECT
    pat_id,
    facility_cd,
    is_same,
    is_implant,
    is_infect,
    is_diabetes,
    is_blood_suger_exam,
    in_out_current_state,
    in_out_plan_state,
    in_out_plan_date,
    pat_memo_info,
    addition_info,
    charge_staff_info,
    pat_group_info,
    taboo_allergy_info,
    infect_info,
    implant_info,
    tare_info,
    off_water_info,
    device_set_info,
    acceptance_status_info,
    is_del,
    up_date,
    reg_date,
    is_wheel_chair,
    medical_care_info,
    sch_ext_end_date,
    sch_ext_status,
    card_idm,
    old_up_date,
    host_notification_info
FROM
    pat_main 
WHERE
    is_del = ''0'' 
    AND pat_id = @patId', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)患者基本情報の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);


-- I pat_main
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-303102, 'WITH device_set_info_default AS ( 
  SELECT
    (device_set_info ->> ''pat'')::jsonb as device_set_info_pat,
    tare_info ::text as tare_info,
    off_water_info ::text as off_water_info,
    host_notification_info
  FROM
    mst_device_set_info_default
  WHERE
    facility_cd = ''@facilityCd''
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
  , 0
  , 0
  , 0
  , 0
  , 0
  , NULL
  , NULL
  , NULL
  , COALESCE(NULLIF(''@patMemoInfo'', ''''), ''[]'') ::JSONB
  , COALESCE(NULLIF(''@additioninfo'', ''''), ''[]'') ::JSONB
  , ''[]''
  , ''[]''
  , ''[]''
  , ''[]''
  , ''[]''
  , NULLIF((SELECT
  ''{"1": '' || tare_info || '','' ||
  ''"2": ''  || tare_info || '','' ||
  ''"3": ''  || tare_info || '','' ||
  ''"4": ''  || tare_info || '','' ||
  ''"5": ''  || tare_info || '','' ||
  ''"6": ''  || tare_info || '','' ||
  ''"7": ''  || tare_info || ''}''
FROM device_set_info_default), ''[]'') ::JSONB
  , NULLIF((SELECT
  ''{"1": '' || off_water_info || '','' ||
  ''"2": ''  || off_water_info || '','' ||
  ''"3": ''  || off_water_info || '','' ||
  ''"4": ''  || off_water_info || '','' ||
  ''"5": ''  || off_water_info || '','' ||
  ''"6": ''  || off_water_info || '','' ||
  ''"7": ''  || off_water_info || ''}''
 FROM device_set_info_default), ''[]'') ::JSONB
  , NULLIF((SELECT device_set_info_pat FROM device_set_info_default), ''[]'') ::JSONB
  , ''[]''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , 0
  , json_build_object( 
      ''ward_cd''
      , NULL
      , ''facility_cd''
      , NULL
      , ''dialysis_count''
      , NULL
      , ''main_course_cd''
      , NULL
      , ''dialysis_course_cd''
      , NULL
      , ''pat_dialysis_count''
      , NULL
      , ''purification_count''
      , NULL
      , ''dialysis_start_date''
      , NULL
      , ''hospital_start_date''
      , NULL
    ) 
  , NULL
  , 0
  , NULL
  , NULL
  , NULLIF((SELECT host_notification_info FROM device_set_info_default), ''[]'') ::JSONB
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)パナソニックの患者プロファイル_患者基本情報の新規', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1002, "field_name": "pat_memo_info", "replace_var": "@patMemoInfo"}, {"sql_cd": -303003, "field_name": "addition_info", "replace_var": "@additioninfo"}]'::jsonb);


-- S mst_addition
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-303003, 'SELECT
  array_to_json(ARRAY_AGG(T.col)) AS addition_info
FROM
  ( 
    SELECT
       json_build_object(''cd'', A.addition_cd, ''reg_date'', A.reg_date + cast( ''-9 hours'' as INTERVAL ), ''is_enable'', ''1'') AS col
    FROM
      mst_addition A
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
          AND master_physical_name = ''mst_addition''
      ) ms
    WHERE
      A.facility_cd = ms.facility_cd 
      AND A.addition_cd = ms.code 
      AND A.is_del = ''0'' 
      AND A.is_disp = ''1'' 
    ORDER BY
      ms.INDEX
  ) AS T', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '外部連携用の[患者基本情報→加算情報]デフォルト値の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



-- S pat_coop_detail
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-303004, 'SELECT
  coop_save_no,
  facility_cd,
  pat_id,
  save_1,
  save_2,
  save_3,
  save_4,
  save_5,
  save_6,
  save_7,
  save_8,
  save_9,
  save_10,
  is_disp,
  is_del,
  user_id,
  coop_version,
  up_date,
  reg_date
FROM
  pat_coop_detail 
WHERE
  facility_cd = @facilityCd
  AND coop_version = @coopVersion
  AND pat_id = @patId
  AND is_del = ''0''
  AND save_2->>''insu_set_no''::TEXT = ''@save2.insuSetNo''
  AND save_2->>''insu_no''::TEXT = ''@save2.insuNo''
  AND save_2->>''insu_name''::TEXT = ''@save2.insuName''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)パナソニックの患者連携情報取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);


-- I pat_coop_detail
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-303103, 'INSERT INTO pat_coop_detail 
(
  facility_cd,
  pat_id,
  save_1,
  save_2,
  save_3,
  save_4,
  save_5,
  save_6,
  save_7,
  save_8,
  save_9,
  save_10,
  is_disp,
  is_del,
  user_id,
  coop_version,
  up_date,
  reg_date
)
VALUES ( 
  ''@facilityCd''
  , @patId
  , json_build_object(''pkg'', ''MED'')
  , json_build_object(
      ''insu_set_no'', NULLIF(''@save2.insuSetNo'', '''')
      , ''insu_no'', NULLIF(''@save2.insuNo'', '''')
      , ''insu_name'', NULLIF(''@save2.insuName'', '''')
    )
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , NULL
  , ''1''
  , ''0''
  , ''-1''
  , ''@coopVersion''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)パナソニックの患者連携情報登録', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);




-- 検査オーダ連携
-- S mst_coop_ini
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310001, 'SELECT
        UNNEST(string_to_array(COALESCE(
                    NULLIF(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) AS exam_institution_cd
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(
                ini.coop_ini_info::json
            ) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''EXAM_INSTITUTION_CD''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom検査オーダ連携用の[連携設定→検査機関コード]値取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310002, 'SELECT
        UNNEST(string_to_array(COALESCE(
                    NULLIF(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) AS facility_no
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(
                ini.coop_ini_info::json
            ) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''FACILITY_NO''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom検査オーダ連携用の[連携設定→施設NO]値取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310005, 'WITH other_sex AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''DEFAULT_SEX''
),
pat_id_digit AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''PAT_ID_DIGIT''
),
pat_id_padding AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''PAT_ID_PADDING''
),
unset_default_name AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''UNSET_DEFAULT_NAME''
),
outside_terms_default_name AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''OUTSIDE_TERMS_DEFAULT_NAME''
)

SELECT
  CASE 
    WHEN @patSex::text IN (''1'',''2'') THEN @patSex::text
    ELSE (SELECT value FROM other_sex)
    END AS pat_sex,
  CASE (SELECT value FROM pat_id_padding)
    WHEN ''0'' THEN LPAD(@hospPatId::text, (SELECT value FROM pat_id_digit)::smallint, ''0'')
    WHEN ''1'' THEN RPAD(@hospPatId::text, (SELECT value FROM pat_id_digit)::smallint, ''0'') 
    ELSE @hospPatId::text
    END AS hosp_pat_id,
  CASE 
    WHEN COALESCE(@patNameKana,'''') = '''' THEN (SELECT value FROM unset_default_name)
    ELSE 
        CASE
        WHEN @patNameKana  ~ ''^[ァ-ヶｦ-ﾟｱ-ﾝ 　]+$'' THEN LEFT(hankana_translate(@patNameKana), 20)
        ELSE (SELECT value FROM outside_terms_default_name)
        END
    END AS pat_name_kana', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom検査オーダ連携用の連携設定で変換する値取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -310004, "field_name": "hosp_pat_id", "replace_var": "@hospPatId"}, {"sql_cd": -310004, "field_name": "pat_name_kana", "replace_var": "@patNameKana"}, {"sql_cd": -310004, "field_name": "pat_sex", "replace_var": "@patSex"}]'::jsonb);



-- S pat_main
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310003, 'WITH def_course AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''DEFAULT_COURSE''
),
def_ward AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''DEFAULT_WARD''
)

SELECT
  medical_care_info ->> ''ward_cd'' AS ward_cd
  , ward.ward_name AS ward_name
  , LEFT(COALESCE(ward.in_hospital_cd_1, (SELECT value FROM def_ward)), 15) AS ward_in_hospital_cd
  , medical_care_info ->> ''main_course_cd'' AS main_course_cd
  , course.course_name AS course_name
  , LEFT(COALESCE(course.in_hospital_cd_1, (SELECT value FROM def_course)), 15) AS course_in_hospital_cd
FROM
  pat_main AS main 
  LEFT JOIN mst_ward AS ward ON ward.ward_cd ::TEXT = main.medical_care_info ->> ''ward_cd'' 
  LEFT JOIN mst_course AS course ON course.course_cd ::TEXT = main.medical_care_info ->> ''main_course_cd'' 
WHERE
  pat_id = @patId', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'Medicom検査オーダ', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



-- S pat_personal_main
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310004, 'select
 LEFT(hosp_pat_id, 10) as hosp_pat_id,
 personal_info_decrypt(pat_last_name)||'' ''||personal_info_decrypt(pat_first_name) as pat_name,
 personal_info_decrypt(pat_last_name_kana)||'' ''||personal_info_decrypt(pat_first_name_kana) as pat_name_kana,
 personal_info_decrypt(pat_last_name_alpha)||'' ''||personal_info_decrypt(pat_first_name_alpha) as pat_name_alpha,
 pat_birthday as pat_birthday_yyyymmdd,
 to_char(to_date(pat_birthday, ''YYYYMMDD''), ''YYYY/MM/DD'') as pat_birthday,
 case when pat_birthday is null then null
 else to_char(date_part(''year'',age(''now'', to_date(pat_birthday, ''YYYYMMDD''))), ''FM999'')
 end as pat_age,
 pat_sex,
 pat_blood_type_abo,
 pat_blood_type_rh,
 pat_blood_type_abo * 10 +  pat_blood_type_rh as pat_blood_type_abo_rh,
 pat_blood_type_serovar as pat_blood_type_serovar,
 case in_out_class when 0 then ''2'' when 1 then ''1'' else '''' end as in_out_class,
 case in_out_class when 0 then ''外来'' when 1 then ''入院'' else ''不明'' end as in_out_class_name,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''zip_cd'')) as pat_zip,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''address'')) as pat_address,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''tel1'')) as pat_tel1,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''tel2'')) as pat_tel2,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''fax'')) as pat_fax,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''e_mail'')) as pat_e_mail,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''work_name'')) as pat_work_name,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''work_tel'')) as pat_work_tel,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''memo1'')) as pat_memo1,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''memo2'')) as pat_memo2,
 nationality as nationality,
 COALESCE(severity_cd,0) as severity_cd,
 COALESCE(transport_cd,0) as transport_cd,
 is_die,
 die_date,
 die_cd,
 die_cd as die_cd1,
 -- 透析困難有無
 case when jsonb_array_length(dial_diff_com_info) > 0 then 1 else 0 end as dial_diff_com_info_flag,
 up_date
 from
 pat_personal_main
 where
 is_del = ''0''
 and
 pat_personal_main.pat_id = @patId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



-- S ord_main, pat_exam_main
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310006, 'WITH exam_data AS(
  SELECT
    TO_CHAR(reg_exam_date, ''YYYYMMDD'') AS exam_date,
    CASE reg_order_class
      WHEN ''0'' THEN '' ''
      ELSE reg_order_class
    END AS exam_timing,
    exam_set_info ->> ''set_cd'' AS exam_set_cd,
    pat_id
  FROM
    ntss.pat_exam_main
    CROSS JOIN
      LATERAL json_array_elements(
        pat_exam_main.order_exam_set_info::json
      ) exam_set_info
  WHERE
    exam_main_cd = @ordNo
  AND exam_set_info ->> ''no'' = ''1''
),
exam_set_data AS(
  SELECT
    other_exam_time
  FROM
    mst_exam_set
  WHERE
    exam_set_cd = (
      SELECT
        exam_set_cd
      FROM
        exam_data
    )::int
),
ord_data AS(
  SELECT
    ord_main.ind_treat_start_time,
    ord_main.ind_cond_info,
    LEFT(mst_bed.in_hospital_cd_1, 4) AS in_hospital_cd_1,
    LEFT(mst_bed.in_hospital_cd_2, 4) AS in_hospital_cd_2
  FROM
    ord_main
    LEFT OUTER JOIN
      mst_bed
    ON  ord_main.ind_bed_cd = mst_bed.bed_cd
  WHERE
    pat_id = (
      SELECT
        pat_id
      FROM
        exam_data
    )
  AND treat_date = (
      SELECT
        exam_date
      FROM
        exam_data
    )
  AND ind_kur_cd > 0
  AND ord_main.is_del = ''0''
  ORDER BY
    ind_treat_start_time ASC
  LIMIT 1
),
before_margin AS(
  SELECT
    COALESCE(
      NULLIF(
        info ->> ''value'',
        ''''
      ),
      info ->> ''default_v''
    ) AS value
  FROM
    mst_coop_ini AS ini
    CROSS JOIN
      LATERAL json_array_elements(
        ini.coop_ini_info::json
      ) info
  WHERE
    facility_cd = @facilityCd
  AND is_del = ''0''
  AND info ->> ''key0'' = ''MED''
  AND info ->> ''key1'' = ''EXAM_ORD''
  AND info ->> ''key2'' = ''BEFORE_MARGIN''
),
after_margin AS(
  SELECT
    COALESCE(
      NULLIF(
        info ->> ''value'',
        ''''
      ),
      info ->> ''default_v''
    ) AS value
  FROM
    mst_coop_ini AS ini
    CROSS JOIN
      LATERAL json_array_elements(
        ini.coop_ini_info::json
      ) info
  WHERE
    facility_cd = @facilityCd
  AND is_del = ''0''
  AND info ->> ''key0'' = ''MED''
  AND info ->> ''key1'' = ''EXAM_ORD''
  AND info ->> ''key2'' = ''AFTER_MARGIN''
),
output_bed_no AS(
  SELECT
    COALESCE(
      NULLIF(
        info ->> ''value'',
        ''''
      ),
      info ->> ''default_v''
    ) AS value
  FROM
    mst_coop_ini AS ini
    CROSS JOIN
      LATERAL json_array_elements(
        ini.coop_ini_info::json
      ) info
  WHERE
    facility_cd = @facilityCd
  AND is_del = ''0''
  AND info ->> ''key0'' = ''MED''
  AND info ->> ''key1'' = ''EXAM_ORD''
  AND info ->> ''key2'' = ''OUTPUT_BED_NO''
),
bed_code_conv AS(
  SELECT
    COALESCE(
      NULLIF(
        info ->> ''value'',
        ''''
      ),
      info ->> ''default_v''
    ) AS value
  FROM
    mst_coop_ini AS ini
    CROSS JOIN
      LATERAL json_array_elements(
        ini.coop_ini_info::json
      ) info
  WHERE
    facility_cd = @facilityCd
  AND is_del = ''0''
  AND info ->> ''key0'' = ''MED''
  AND info ->> ''key1'' = ''MST''
  AND info ->> ''key2'' = ''BED_CODE_CONV''
)
SELECT
  exam_date,
  exam_timing,
  CASE exam_timing
    WHEN ''1'' THEN to_char((
        ind_treat_start_time::time - ((
            SELECT
              value
            FROM
              before_margin
          ) || '' minutes'')::interval
      ), ''HH24MI'')
    WHEN ''2'' THEN to_char((
        ind_treat_start_time::time + (
          ind_cond_info -> ''1'' ->> ''value'' || '' minutes''
        )::interval + ((
            SELECT
              value
            FROM
              after_margin
          ) || '' minutes'')::interval
      ), ''HH24MI'')
    ELSE(
      SELECT
        other_exam_time
      FROM
        exam_set_data
    )
  END AS exam_time,
  CASE(
      SELECT
        value
      FROM
        output_bed_no
    )
    WHEN ''1'' THEN CASE(
        SELECT
          value
        FROM
          bed_code_conv
      )
      WHEN ''1'' THEN in_hospital_cd_1
      WHEN ''2'' THEN in_hospital_cd_2
      ELSE ''    ''
    END
    ELSE ''    ''
  END AS bed_cd
FROM
  exam_data,
  ord_data', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'Medicom', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);




-- S 検査オーダファイル名取得
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310007, 'WITH  sequence_digit AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''SEQUENCE_DIGIT''
),
journal AS (
  SELECT
    COUNT(1) AS CNT 
  FROM
    sys_coop_journal AS coop1 
    JOIN sys_coop_journal AS coop2 
    ON coop1.facility_cd = coop2.facility_cd
    AND coop1.ctl_no = @ctlNo
    AND coop1.coop_cd = coop2.coop_cd
    AND TO_CHAR(coop2.reg_date, ''YYYYMMDD'') = TO_CHAR(coop1.reg_date, ''YYYYMMDD'') 
    AND coop2.ctl_no < @ctlNo
)

SELECT to_char(CURRENT_TIMESTAMP, ''YYMMDD'') || LPAD(((SELECT CNT FROM journal) % (RPAD(''1'', value::smallint, ''0'')::smallint))::text, value::smallint, ''0'') || ''.txt'' AS filename FROM sequence_digit', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom検査オーダファイル名取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



-- S 担当医取得事前SQL
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310008, 'WITH
min_staff_ctl_no AS (
SELECT min(staff.value ->> ''ctl_no'') AS min_is_main_ctl_no
FROM pat_main 
        CROSS JOIN
            LATERAL json_array_elements(pat_main.charge_staff_info::json) staff
    WHERE
        pat_id = @patId
        AND staff.value ->> ''is_main'' = ''1'' 
),
staff AS (
SELECT 
    staff.value ->> ''staff_cd'' staff_cd
from pat_main 
        CROSS JOIN
            LATERAL json_array_elements(pat_main.charge_staff_info::json) staff
    WHERE
        pat_id = @patId
        and staff.value ->> ''ctl_no'' = (SELECT min_is_main_ctl_no FROM min_staff_ctl_no)
),
def_doctor AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''DEFAULT_DOCTOR''
)


SELECT 
    CASE 
    WHEN (SELECT min_is_main_ctl_no FROM min_staff_ctl_no) IS NULL THEN (SELECT value FROM def_doctor)
    ELSE (SELECT staff_cd FROM staff)
    END AS staff_cd
    ,CASE 
    WHEN (SELECT min_is_main_ctl_no FROM min_staff_ctl_no) IS NULL THEN 0
    ELSE 1
    END AS is_conv', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom検査オーダ担当医取得事前SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);


-- S 担当医取得SQL
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310009, 'select case  when @isConv = 0 THEN @staffCd ELSE (select LEFT(personal_info_decrypt(user_last_name) || '' '' || personal_info_decrypt(user_first_name), 10) AS user_name
FROM 
    mst_personal_user
WHERE 
    user_id::TEXT = @staffCd) END AS user_name,
    @staffCd AS staff_cd', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom検査オーダ担当医取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -310008, "field_name": "staff_cd", "replace_var": "@staffCd"}, {"sql_cd": -310008, "field_name": "is_conv", "replace_var": "@isConv"}]'::jsonb);



-- S Medicom検査オーダ 繰り返し
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310010, 'WITH
exam_item AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''MST''
    AND info ->> ''key2'' = ''EXAM_ITEM''
),
exam_set AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''MST''
    AND info ->> ''key2'' = ''EXAM_SET''
),
output_item AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''OUTPUT_ITEM''
),
output_in_out AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''OUTPUT_IN_OUT''
),
item_set_no AS (
SELECT info.value ->> ''no'' AS no
FROM ( 
                select
                  m.* 
                from
                  pat_exam_main as m 
                where
                  m.is_del = ''0'' 
                  and jsonb_array_length(m.order_exam_set_info) > 0 
                  and m.exam_main_cd = @ordNo
              ) p 
              cross join lateral json_array_elements(p.order_exam_set_info ::json) info 
              inner join mst_exam_set as item 
                on info ->> ''set_cd'' = (item.exam_set_cd || '''')
                AND 
                CASE (SELECT value FROM output_in_out)
                WHEN ''1'' THEN item.is_in_hospital = ''0''
                WHEN ''2'' THEN item.is_in_hospital = ''1''
                ELSE true
                END
),
institution_cd AS (
 SELECT
        UNNEST(string_to_array(COALESCE(
                    NULLIF(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) AS exam_institution_cd
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(
                ini.coop_ini_info::json
            ) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''EXAM_INSTITUTION_CD''
)

select
  ''検査項目'' as detail_id,
  (select exam_institution_cd from institution_cd) as exam_institution_cd,
  (exam_full.exam_row + 1) as exam_row,
  LEFT(max(case exam_full.exam_col when 0 then exam_full.in_hospital_cd else null end ), 17) as exam1,
  max(case exam_full.exam_col when 0 then exam_full.sub_no else null end ) as exam1p,
  LEFT(max(case exam_full.exam_col when 1 then exam_full.in_hospital_cd else null end ), 17) as exam2,
  max(case exam_full.exam_col when 1 then exam_full.sub_no else null end ) as exam2p,
  LEFT(max(case exam_full.exam_col when 2 then exam_full.in_hospital_cd else null end ), 17) as exam3,
  max(case exam_full.exam_col when 2 then exam_full.sub_no else null end ) as exam3p,
  LEFT(max(case exam_full.exam_col when 3 then exam_full.in_hospital_cd else null end ), 17) as exam4,
  max(case exam_full.exam_col when 3 then exam_full.sub_no else null end ) as exam4p,
  LEFT(max(case exam_full.exam_col when 4 then exam_full.in_hospital_cd else null end ), 17) as exam5,
  max(case exam_full.exam_col when 4 then exam_full.sub_no else null end ) as exam5p
from
  ( 
    select
      (row_number() over () - 1) / 5 as exam_row
      , (row_number() over () - 1) % 5 as exam_col
      , exam.sub_no
      , exam.in_hospital_cd
    from
      ( 
        select
          exam_all.* 
        from
          ( 
            select
              info ->> ''no'' as seq_no
              , ''6'' as sub_no -- 子（検査項目）
              , info ->> ''item_cd'' as item_cd 
              , info ->> ''item_name'' as item_name
              , CASE (SELECT value FROM exam_item)
              WHEN ''1'' THEN item.in_hospital_cd1
              WHEN ''2'' THEN item.in_hospital_cd2
              WHEN ''3'' THEN item.in_hospital_cd3
              ELSE NULL
              END as in_hospital_cd
            from
              ( 
                select
                  m.* 
                from
                  pat_exam_main as m 
                where
                  m.is_del = ''0'' 
                  and jsonb_array_length(m.order_exam_set_info) > 0 
                  and m.exam_main_cd = @ordNo
              ) p 
              cross join lateral json_array_elements(p.exam_order_info ::json) info 
              left outer join mst_exam_item as item 
                on info ->> ''item_cd'' = (item.exam_item_cd || '''') 
              WHERE info ->> ''no'' IN (SELECT no FROM item_set_no)
              AND 
              CASE (SELECT value FROM output_item)
              WHEN ''1'' THEN false
              ELSE true
              END
            union all 
            select
              info ->> ''no'' as seq_no
              , ''5'' as sub_no -- 親（検査セット）
              , info ->> ''set_cd'' as item_cd 
              , info ->> ''set_name'' as item_name
              , CASE (SELECT value FROM exam_set)
              WHEN ''1'' THEN item.in_hospital_cd1
              WHEN ''2'' THEN item.in_hospital_cd2
              WHEN ''3'' THEN item.in_hospital_cd3
              ELSE NULL
              END as in_hospital_cd
            from
              ( 
                select
                  m.* 
                from
                  pat_exam_main as m 
                where
                  m.is_del = ''0'' 
                  and jsonb_array_length(m.order_exam_set_info) > 0 
                  and m.exam_main_cd = @ordNo
              ) p 
              cross join lateral json_array_elements(p.order_exam_set_info ::json) info 
              left outer join mst_exam_set as item 
                on info ->> ''set_cd'' = (item.exam_set_cd || '''')
              WHERE info ->> ''no'' IN (SELECT no FROM item_set_no)
              AND 
              CASE (SELECT value FROM output_item)
              WHEN ''2'' THEN false
              ELSE true
              END
          ) exam_all
        order by
          seq_no ASC 
          , sub_no ASC
      ) exam
  ) exam_full 
group by
  exam_full.exam_row 
order by
  exam_row', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'Medicom検査オーダ 繰り返し部', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);








-- S Medicom検査オーダ 繰り返し項目数
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310011, 'WITH
output_item AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''OUTPUT_ITEM''
),
output_in_out AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''OUTPUT_IN_OUT''
),
item_set_no AS (
SELECT info.value ->> ''no'' AS no
FROM ( 
                select
                  m.* 
                from
                  pat_exam_main as m 
                where
                  m.is_del = ''0'' 
                  and jsonb_array_length(m.order_exam_set_info) > 0 
                  and m.exam_main_cd = @ordNo
              ) p 
              cross join lateral json_array_elements(p.order_exam_set_info ::json) info 
              inner join mst_exam_set as item 
                on info ->> ''set_cd'' = (item.exam_set_cd || '''')
                AND 
                CASE (SELECT value FROM output_in_out)
                WHEN ''1'' THEN item.is_in_hospital = ''0''
                WHEN ''2'' THEN item.is_in_hospital = ''1''
                ELSE true
                END
)

select
  count(1) as exam_set_cnt
        from
          ( 
            select
              1
            from
              ( 
                select
                  m.* 
                from
                  pat_exam_main as m 
                where
                  m.is_del = ''0'' 
                  and jsonb_array_length(m.order_exam_set_info) > 0 
                  and m.exam_main_cd = @ordNo
              ) p 
              cross join lateral json_array_elements(p.exam_order_info ::json) info 
              left outer join mst_exam_item as item 
                on info ->> ''item_cd'' = (item.exam_item_cd || '''') 
              WHERE info ->> ''no'' IN (SELECT no FROM item_set_no)
              AND 
              CASE (SELECT value FROM output_item)
              WHEN ''1'' THEN false
              ELSE true
              END
            union all 
            select
              1
            from
              ( 
                select
                  m.* 
                from
                  pat_exam_main as m 
                where
                  m.is_del = ''0'' 
                  and jsonb_array_length(m.order_exam_set_info) > 0 
                  and m.exam_main_cd = @ordNo
              ) p 
              cross join lateral json_array_elements(p.order_exam_set_info ::json) info 
              left outer join mst_exam_set as item 
                on info ->> ''set_cd'' = (item.exam_set_cd || '''')
              WHERE info ->> ''no'' IN (SELECT no FROM item_set_no)
              AND 
              CASE (SELECT value FROM output_item)
              WHEN ''2'' THEN false
              ELSE true
              END
          ) exam_all ', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'Medicom検査オーダ 検査項目カウント', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);




-- S 修正連携判定
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310012, 'WITH  coop_update AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''COOP_UPDATE''
), ord_coop AS (
SELECT ctl_no
FROM ord_coop_no
WHERE
ord_no = @ordNo
AND coop_cd = ''exam_ord''
AND facility_cd = @facilityCd
AND status = ''1''
)

SELECT ''O1'' AS kbn
WHERE 
CASE (SELECT value FROM coop_update)
WHEN ''0'' THEN (SELECT ctl_no FROM ord_coop) IS NULL
ELSE true
END', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'Medicom検査オーダ 修正連携判定', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



-- S 削除連携用
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310013, 'select 1 where false', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'Medicom結果0件SQL ※is_zero_endで連携しない用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);







-- 再来受付連携
insert
	into
	ntss.sys_data_set
(sql_cd,
	"sql",
	db_class,
	detail,
	can_repeat,
	use_application,
	report_class,
	memo,
	reg_date,
	up_date,
	pre_sql_info)
values(-306101,
'SELECT
    CASE
        WHEN severity_name IS NOT NULL
    AND transport_name IS NOT NULL THEN Left(zenkana_translate(severity_name) || ''、'' || zenkana_translate(transport_name),20)
        WHEN severity_name IS NOT NULL THEN Left(zenkana_translate(severity_name),20)
        WHEN transport_name IS NOT NULL THEN Left(zenkana_translate(transport_name),20)
        ELSE ''''
    END AS comment
FROM
    (
        SELECT
            (
                SELECT
                    severity.severity_name
                FROM
                    mst_severity AS severity
                WHERE
                    severity.severity_cd = @severityCd
            ) AS severity_name,
            (
                SELECT
                    transport.transport_name
                FROM
                    mst_transport AS transport
                WHERE
                    transport.transport_cd = @transportCd
            ) AS transport_name
    ) AS T01
',
2,
'[{}]'::jsonb,
'0',
'{"applications": [4]}'::jsonb,
null,
'Medicom受付情報の「コメント」',
CURRENT_TIMESTAMP,
CURRENT_TIMESTAMP,
'[{"sql_cd": -300001, "field_name": "severity_cd", "replace_var": "@severityCd"}, {"sql_cd": -300001, "field_name": "transport_cd", "replace_var": "@transportCd"}]'::jsonb);



insert
	into
	ntss.sys_data_set
(sql_cd,
	"sql",
	db_class,
	detail,
	can_repeat,
	use_application,
	report_class,
	memo,
	reg_date,
	up_date,
	pre_sql_info)
values(-306102,
'WITH id_info AS(
    SELECT
        coop.hosp_pat_id as hosp_pat_id
    FROM
        sys_coop_journal AS coop
    WHERE
        coop.pat_id  = @patId
),
item_info AS(
    SELECT
        UNNEST(string_to_array(COALESCE(
                    NULLIF(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) AS VALUE
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(
                ini.coop_ini_info::json
            ) info
    WHERE
        facility_cd = ''P_hosp''
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''ACCEPT_SEND''
    AND info ->> ''key2'' = ''FILENAME_NUMBER''
)
SELECT
    TO_CHAR(current_timestamp, ''YYYYMMDD_HH24MISS'') || ''_'' || VALUE || ''_'' || LTRIM(
        hosp_pat_id::TEXT,
        ''0''
    ) || ''.dat'' AS filename
FROM
    id_info,item_info',
2,
'[{}]'::jsonb,
'0',
'{"applications": [4]}'::jsonb,
null,
'Medicom再来受付連携ファイル名取得',
CURRENT_TIMESTAMP,
CURRENT_TIMESTAMP,
null);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-306103, 'with disp_user as (
select
    disp_user_id
from
    mst_user_authentication
where
    user_id = @staffCd
)
select
    case
        @isTransformation when 1 then (select disp_user_id from disp_user)
        else @staffCd::text
    end as staff_cd', 1, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom受付情報の「医師１」', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
    '[
	{
		"sql_cd": -306104,
		"field_name": "staff_cd",
		"replace_var": "@staffCd"
	},
	{
		"sql_cd": -306104,
		"field_name": "is_transformation",
		"replace_var": "@isTransformation"
	}
]'::jsonb);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-306104, 'with pat_info as(
select
    staff_info ->> ''ctl_no'' as ctl_no,
    staff_info ->> ''disp_order'' as disp_order,
    staff_info ->> ''staff_cd'' as staff_cd,
    staff_info ->> ''is_main'' as is_main,
    staff_info ->> ''is_charge'' as is_charge,
    staff_info ->> ''is_puncture'' as is_puncture
from
    pat_main as pat
cross join
            lateral json_array_elements(
                pat.charge_staff_info::json
            ) staff_info
where
    pat.pat_id = @patId
    and staff_info ->> ''is_main'' = ''1''
order by
    staff_info ->> ''disp_order'' asc
limit 1
),
accept_send as(
select
    info ->> ''key2'' as key2,
    unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as VALUE
from
    mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
    facility_cd = @facilityCd
    and is_del = ''0''
    and info ->> ''key0'' = ''MED''
    and info ->> ''key1'' = ''ACCEPT_SEND''
)
select
    case
        (
        select
            VALUE
        from
            accept_send
        where
            key2 = ''DOCTOR_CLASSIFICATION''
        )
        when ''0'' then coalesce(staff_cd,(
        select
            VALUE
                from
                    accept_send
                where
                    key2 = ''FIXED_DOCTOR_CODE1''
            ))
        -- 0：患者の担当医１ （取得できない場合は固定医師コード1）
        when ''1'' then(
        select
            VALUE
        from
            accept_send
        where
            key2 = ''FIXED_DOCTOR_CODE1''
        )
        --1：固定医師コード１
        when ''2'' then(
        select
            VALUE
        from
            accept_send
        where
            key2 = ''FIXED_DOCTOR_CODE2''
        )
        --2：固定医師コード２
        when ''3'' then ''''
        --3：空白   
        else ''''
    end as staff_cd,
    (case
        when
        (
        select
            value
        from
            accept_send
        where
            key2 = ''DOCTOR_CLASSIFICATION''
        ) = ''0''
        and staff_cd is not null then 1
        else 0
    end) as is_transformation
from
    (
    select
        (
        select
            staff_cd
        from
            pat_info
            ) as staff_cd
    ) as T01', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom受付情報の「医師１」事前実行SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);





-- I 検査依頼実績連携
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310014, 'WITH exam_data AS (
SELECT
    TO_CHAR(reg_exam_date, ''YYYYMMDD'') AS exam_date,
    CASE reg_order_class
    WHEN ''0'' THEN '' ''
    ELSE reg_order_class
    END AS exam_timing,
    order_exam_set_info
FROM
    ntss.pat_exam_main
WHERE
    exam_main_cd = @ordNo
), exam_set AS (
SELECT exam_set.other_exam_time
FROM ( 
                select
                  order_exam_set_info
                from
                  exam_data
              ) p 
              cross join lateral json_array_elements(p.order_exam_set_info ::json) info 
              inner join mst_exam_set as exam_set 
                on info ->> ''set_cd'' = (exam_set.exam_set_cd || '''')
), before_margin AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''BEFORE_MARGIN''
), after_margin AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''AFTER_MARGIN''
), ord_data AS(
    SELECT
        ord.ord_no,
        ord.ind_treat_start_time,
        ind_cond_info -> ''1'' ->> ''value'' AS plan_dialysis_time
    FROM (
        SELECT *
        FROM ord_main
        WHERE pat_id = @patId
        AND treat_date = (SELECT exam_date FROM exam_data)
        AND is_del = ''0''
        ORDER BY ind_treat_start_time ASC
        LIMIT 1) ord
), exam_time AS (
SELECT
  (SELECT ord_no FROM ord_data) AS ord_no,
  exam_date,
  exam_timing,
  CASE exam_timing
  WHEN ''1'' THEN 
  to_char(((SELECT ind_treat_start_time FROM ord_data)::time - ((SELECT value FROM before_margin) || '' minutes'')::interval), ''HH24MI'')
  WHEN ''2'' THEN 
  to_char(((SELECT ind_treat_start_time FROM ord_data)::time + ((SELECT plan_dialysis_time FROM ord_data) || '' minutes'')::interval + ((SELECT value FROM after_margin) || '' minutes'')::interval), ''HH24MI'')
  ELSE (SELECT other_exam_time FROM exam_set)
  END AS exam_time
FROM exam_data
), output_in_out AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''OUTPUT_IN_OUT''
),
item_set_no AS (
SELECT info.value ->> ''no'' AS no
FROM ( 
                select
                  m.* 
                from
                  pat_exam_main as m 
                where
                  m.is_del = ''0'' 
                  and jsonb_array_length(m.order_exam_set_info) > 0 
                  and m.exam_main_cd = @ordNo
              ) p 
              cross join lateral json_array_elements(p.order_exam_set_info ::json) info 
              inner join mst_exam_set as item 
                on info ->> ''set_cd'' = (item.exam_set_cd || '''')
                AND 
                CASE (SELECT value FROM output_in_out)
                WHEN ''1'' THEN item.is_in_hospital = ''0''
                WHEN ''2'' THEN item.is_in_hospital = ''1''
                ELSE true
                END
), exam_items AS (
select
    item_cd, 
    item_name,
    in_hospital_cd1,
    in_hospital_cd2,
    in_hospital_cd3
    from
      ( 
        select
          info ->> ''no'' as seq_no,
          ''6'' as sub_no, -- 子（検査項目）
          info ->> ''item_cd'' as item_cd,
          info ->> ''item_name'' as item_name,
          item.in_hospital_cd1,
          item.in_hospital_cd2,
          item.in_hospital_cd3
        from
          ( 
            select
              m.* 
            from
              pat_exam_main as m 
            where
              m.is_del = ''0'' 
              and jsonb_array_length(m.order_exam_set_info) > 0
              and m.exam_main_cd = @ordNo
          ) p 
          cross join lateral json_array_elements(p.exam_order_info ::json) info
          left outer join mst_exam_item as item 
            on info ->> ''item_cd'' = (item.exam_item_cd || '''')
          WHERE info ->> ''no'' IN (SELECT no FROM item_set_no)
          AND
          CASE (SELECT value FROM output_item)
          WHEN ''1'' THEN false
          ELSE true
          END
        union all 
        select
          info ->> ''no'' as seq_no,
          ''5'' as sub_no, -- 親（検査セット）
          info ->> ''set_cd'' as item_cd,
          info ->> ''set_name'' as item_name,
          item.in_hospital_cd1,
          item.in_hospital_cd2,
          item.in_hospital_cd3
        from
          ( 
            select
              m.* 
            from
              pat_exam_main as m 
            where
              m.is_del = ''0'' 
              and jsonb_array_length(m.order_exam_set_info) > 0 
              and m.exam_main_cd = @ordNo
          ) p 
          cross join lateral json_array_elements(p.order_exam_set_info ::json) info
          left outer join mst_exam_set as item
            on info ->> ''set_cd'' = (item.exam_set_cd || '''')
          WHERE info ->> ''no'' IN (SELECT no FROM item_set_no)
          AND 
          CASE (SELECT value FROM output_item)
          WHEN ''2'' THEN false
          ELSE true
          END
      ) exam_all
      ORDER BY seq_no, sub_no
)


INSERT INTO ntss.pat_coop_detail(
    facility_cd,
    pat_id,
    save_1,
    save_2,
    is_disp,
    is_del,
    user_id,
    up_date,
    reg_date
)
SELECT
    @facilityCd,
    @patId,
    ''{"pkg": "MED"}''::jsonb,
    jsonb_build_object(''ord_no'', (SELECT ord_no FROM ord_data), ''hosp_pat_id'', @hospPatId, ''exam_date'', (SELECT exam_date FROM exam_data), ''exam_timing'', (SELECT exam_timing FROM exam_data), ''exam_time'', (SELECT exam_time FROM exam_time), ''doctor_name'', @doctorName, ''doctor_cd'', @doctorCd || 
      jsonb_build_object(''exam_items'',
      jsonb_agg(jsonb_build_object(''exam_cd'', item_cd, ''exam_name'', item_name, ''in_hospital_cd1'', in_hospital_cd1, ''in_hospital_cd2'', in_hospital_cd2, ''in_hospital_cd3'', in_hospital_cd3))),
    ''1'',
    ''0'',
    - 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM
    exam_items



', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom検査依頼実績連携', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -310009, "field_name": "staff_cd", "replace_var": "@doctorCd"}, {"sql_cd": -310009, "field_name": "user_name", "replace_var": "@doctorName"}]'::jsonb);




-- 検査依頼実績連携 検査依頼変更不可更新
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310015, 'UPDATE
    pat_exam_main
SET
    is_lock = ''1''
WHERE
    exam_main_cd = @ordNo', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'Medicom検査依頼実績連携 検査依頼変更不可更新', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



-- 透析経過データ連携
-- 透析経過データ連携
-- S テーブル指定なし（mst_coop_layout更新スキップ用）
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317019, '
select 1 as skip where false', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携修正連携スキップ用SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



-- S pat_personal_main
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317102, '
  select
	hosp_pat_id as e01
  FROM
	pat_personal_main
  WHERE
	pat_id = @patId', 3, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携PatientCode取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



-- S ord_main
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317104, '
with medical_name_info as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as VALUE
from
	mst_coop_ini as ini
cross join lateral jsON_array_elements(ini.coop_ini_info ::jsON) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = ''MED''
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
)
select
  ord.rst_treatment_name as e01  --血液浄化法
  ,to_char(ord.rst_start_date,''YYYY/MM/DD'') as e02--透析日
	,RIGHT(''00''||TRUNC(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''999999'')/60,0),2)||''時間''||RIGHT(''00''||MOD(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''999999''),60),2)||''分''as e03--予定時間
  ,to_char(ord.rst_start_date,''YYYY/MM/DD HH24:MI:SS'') as e04--開始時刻
  ,to_char(ord.rst_end_date,''YYYY/MM/DD HH24:MI:SS'') as e05--終了時刻
  ,RIGHT(CAST(TRUNC(rst_running_time/60,0) as TEXT),2) || ''時間'' || RIGHT(CAST(MOD(rst_running_time,60) as TEXT),2) || ''分'' as e06--透析時間・実績時間
  ,to_number(cast(ord.rst_dialysis_cnt as text), ''FM999999'') as e07--透析回数
  ,to_number(ord.rst_cond_info->''14''->>''value'', ''FM999'') as e08--血流量
  ,to_char(cast(ord.rst_weight_info->>''ctr'' as numeric),''FM9999.00'') as e09--CTR
  ,ord.rst_cond_info->''5''->>''value_name_1'' as e10--ダイアライザ
  ,ord.rst_cond_info->''2''->>''value_name_1'' as e11--ブラッドアクセス・バスキュラーアクセス
  , case (
  	select
  		value
  	from
  		medical_name_info
  	where 
  		key2 = ''MEDICAL_NAME''
	) when ''0'' then coalesce(ord.rst_course_name,(
		select 
			value
		from
			medical_name_info
		where
			key2 = ''FIXED_MEDICAL_NAME''
	))when ''1'' then (
		select 
			value
		from
			medical_name_info
		where
			key2 = ''FIXED_MEDICAL_NAME''		
	)
    end as e12--診療科名
	,ord.rst_cond_info->''25''->>''value_name_1''  as e13--抗凝固剤
	,trim(to_char(to_number(ord.rst_cond_info->''26''->>''value'',''9999.99''),''99990.99''))  as e14--初回注入量
	,trim(to_char(to_number(ord.rst_cond_info->''27''->>''value'',''9999.99''),''99990.99'')) as e15--持続注入量
	,trim(to_char(to_number(ord.rst_cond_info->''28''->>''value'',''9999.99''),''99990.99'')) as e16--持続総量
from 
	ord_main ord
where
	ord.ord_no = @ordNo

', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携治療情報テーブルデータ取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



-- S mni_monitor
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317107, '
select
  ''前・脈・血圧'' as detail_id,
  occur_date
  ,to_number(monitor_data->>''90'', ''FM999'') as bp_high
  ,to_number(monitor_data->>''91'', ''FM999'') as bp_low
  ,to_number(monitor_data->>''92'', ''FM999'') as bp_ave
  ,to_number(monitor_data->>''93'', ''FM999'') as pulse
from
  mni_monitor
where
  ord_no = @ordNo and data_type = 5 and is_del = ''0''
order by up_date desc
limit 1', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '汎用）透析前血圧', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



-- S mni_monitor
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317108, '
select
  ''後・脈・血圧'' as detail_id,
  occur_date
  ,to_number(monitor_data->>''90'', ''FM999'') as bp_high
  ,to_number(monitor_data->>''91'', ''FM999'') as bp_low
  ,to_number(monitor_data->>''92'', ''FM999'') as bp_ave
  ,to_number(monitor_data->>''93'', ''FM999'') as pulse
from
  mni_monitor
where
  ord_no = @ordNo and data_type = 6 and is_del = ''0''
order by up_date desc
limit 1', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '汎用）透析後血圧', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



-- S pat_info,sys_coop_info,ord_info,doctor_name_value
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317110, 'with pat_info as(
select
	staff_info ->> ''ctl_no'' as ctl_no,
	staff_info ->> ''disp_order'' as disp_order,
	staff_info ->> ''staff_cd'' as staff_cd,
	staff_info ->> ''is_main'' as is_main
from
	pat_main as pat
cross join
            lateral json_array_elements(
                pat.charge_staff_info::json
            ) staff_info
where
	pat.pat_id = @patId
	and staff_info ->> ''is_main'' = ''1''
order by
	staff_info ->> ''disp_order'' asc
limit 1
),
sys_coop_info as(
  select
    user_id
  from
    sys_coop_journal as sys
  where
	sys.ctl_no = @ctlNo
),
ord_info as (
  select
    rst_charge_user_info ->> ''user_last_name_1'' as last_name1,
    rst_charge_user_info ->> ''user_first_name_1'' as first_name1
  from
    ord_main
  where
    ord_no = @ordNo
),
doctor_name_value as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as VALUE
from
	mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = ''MED''
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
)
select
	(
		select 
			value
		from
			doctor_name_value
		where
			key2 = ''DOCTOR_NAME_CLASSIFICATION''
	) as doctor_name_classification,
	(
		select
			user_id
		from
			sys_coop_info
	) as user_id,
	(
		select
			last_name1 || first_name1
		from
			ord_info
	) as ord_full_name,
	(
		select
			staff_cd
		from
			pat_info
	) as staff_cd,
	(
		select
			value
		from
			doctor_name_value
		where
			key2 = ''FIXED_DOCTOR_NAME1''
	) as fixed_doctor_name1,
	(
		select
			value
		from
			doctor_name_value
		where
			key2 = ''FIXED_DOCTOR_NAME2''
	) as fixed_doctor_name2,
	(
		select
			value
		from
			doctor_name_value
		where
			key2 = ''FIXED_NURSE_NAME1''
	) as fixed_nurse_name1,
	(
		select
			value
		from
			doctor_name_value
		where
			key2 = ''FIXED_NURSE_NAME2''
	) as fixed_nurse_name2', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携医師名取得事前SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



-- S sys_user_info,pat_user_info
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317111, 'with sys_user_info as(
	select
		personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name) as sys_full_name
	from
		mst_personal_user
	where
		user_id = @userId
),
pat_user_info as(
	select
		personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)  as pat_full_name
	from
		mst_personal_user
	where
		user_id = coalesce(
			nullif(@staffCd,''''),
			''-1''
		)::int
)
select
(
		case @doctorNameClassification
		when ''0'' then coalesce(
                    nullif(
                      (SELECT sys_full_name FROM sys_user_info),
                      ''''
                    ),
                    coalesce(
                    @ordFullName,
                    @fixedDoctorName1)
                  )
		when ''1'' then coalesce(
                    nullif(
                      @ordFullName,
                      ''''
                    ),
                    coalesce(
                    	(SELECT pat_full_name FROM pat_user_info),
                    	@fixedDoctorName1)
                  )
 		when ''2'' then coalesce(
                    nullif(
                      (SELECT pat_full_name FROM pat_user_info),
                      ''''
                    ),
                    	@fixedDoctorName1
                  )
		when ''3'' then @fixedDoctorName1
		when ''4'' then @fixedDoctorName2
		when ''5'' then @fixedNurseName1
		when ''6'' then @fixedNurseName2
		end 
		) as e01', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携医師名取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[
  {
    "sql_cd": -317110,
    "field_name": "doctor_name_classification",
    "replace_var": "@doctorNameClassification"
  },
  {
    "sql_cd": -317110,
    "field_name": "user_id",
    "replace_var": "@userId"
  },
  {
    "sql_cd": -317110,
    "field_name": "ord_full_name",
    "replace_var": "@ordFullName"
  },
  {
    "sql_cd": -317110,
    "field_name": "staff_cd",
    "replace_var": "@staffCd"
  },
  {
    "sql_cd": -317110,
    "field_name": "fixed_doctor_name1",
    "replace_var": "@fixedDoctorName1"
  },
  {
    "sql_cd": -317110,
    "field_name": "fixed_doctor_name2",
    "replace_var": "@fixedDoctorName2"
  },
  {
    "sql_cd": -317110,
    "field_name": "fixed_nurse_name1",
    "replace_var": "@fixedNurseName1"
  },
  {
    "sql_cd": -317110,
    "field_name": "fixed_nurse_name2",
    "replace_var": "@fixedNurseName2"
  }
]'::jsonb);



-- S テーブル指定なし
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317112, 'with puncture_user_value as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as value
from
	mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = ''MED''
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
),
puncture_user_info as (
	select
        ord.rst_puncture_user_info ->>''user_last_name_1'' as user_last_name_1,
        ord.rst_puncture_user_info ->>''user_first_name_1'' as user_first_name_1,
        ord.rst_puncture_user_info ->>''user_last_name_2'' as user_last_name_2,
        ord.rst_puncture_user_info ->>''user_first_name_2'' as user_first_name_2
    from
        ord_main as ord
    where
		ord.ord_no = @ordNo
)
select
	case (
		select
			value
		from
			puncture_user_value
		where
			key2 = ''PUNCTURE_USER_CLASSIFICATION''
	)
		when ''0'' then coalesce(
      nullif(
        (select
          user_last_name_1 || user_first_name_1
        from
          puncture_user_info),'''')
      ,(
			  coalesce(nullif(
          (select
            user_last_name_2 || user_first_name_2
          from
            puncture_user_info),'''')
		    ,(
          	select
          		value
			      from
				      puncture_user_value
			      where
				      key2 = ''FIXED_DOCTOR_NAME1''
          )
        )
      )
    )
		when ''1'' then coalesce(
      nullif(
        (select 
          user_last_name_2 || user_first_name_2
        from 
          puncture_user_info),'''')
        ,(
    			select
		    		value
			    from
				    puncture_user_value
			    where
				    key2 = ''FIXED_DOCTOR_NAME1''
		))
		when ''2'' then (
			select
				value
			from
				puncture_user_value
			where
				key2 = ''FIXED_DOCTOR_NAME1''
		)
		when ''3'' then(
			select
				value
			from
				puncture_user_value
			where
				key2 = ''FIXED_DOCTOR_NAME2''
		)
		when ''4'' then(
			select
				value
			from
				puncture_user_value
			where
				key2 = ''FIXED_NURSE_NAME1''
		)
		when ''5'' then(
			select
				value
			from
				puncture_user_value
			where
				key2 = ''FIXED_NURSE_NAME2''
		)
	end as e01', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携穿刺者取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



-- S テーブル指定なし
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317113, '
with return_user_value as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as value
from
	mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = ''MED''
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
),
return_user_info as (
	select
		ord.rst_return_user_info ->>''user_last_name_1'' as user_last_name_1,
		ord.rst_return_user_info ->>''user_first_name_1'' as user_first_name_1,
		ord.rst_return_user_info ->>''user_last_name_2'' as user_last_name_2,
		ord.rst_return_user_info ->>''user_first_name_2'' as user_first_name_2
	from 
		ord_main as ord
where
	ord.ord_no = @ordNo	
)
select
	case (
		select
			value
		from
			return_user_value
		where
			key2 = ''RECOVERY_USER_CLASSIFICATION''
	)
		when ''0'' then coalesce(
      nullif(
        (select
          user_last_name_1 || user_first_name_1
        from
          return_user_info),'''')
      ,(
		coalesce(nullif(
          (select
            user_last_name_2 || user_first_name_2
          from
            return_user_info),'''')
		    ,(
          	select
          		value
			      from
				      return_user_value
			      where
				      key2 = ''FIXED_DOCTOR_NAME1''
          )
        )
      )
    )
		when ''1'' then coalesce(
      nullif(
        (select 
          user_last_name_2 || user_first_name_2
        from 
          return_user_info),'''')
        ,(
    			select
		    		value
			    from
				    return_user_value
			    where
				    key2 = ''FIXED_DOCTOR_NAME1''
		))
		when ''2'' then (
			select
				value
			from
				return_user_value
			where
				key2 = ''FIXED_DOCTOR_NAME1''
		)
		when ''3'' then(
			select
				value
			from
				return_user_value
			where
				key2 = ''FIXED_DOCTOR_NAME2''
		)
		when ''4'' then(
			select
				value
			from
				return_user_value
			where
				key2 = ''FIXED_NURSE_NAME1''
		)
		when ''5'' then(
			select
				value
			from
				return_user_value
			where
				key2 = ''FIXED_NURSE_NAME2''
		)
	end as e01', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携回収者取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



-- S テーブル指定なし
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317114, '
with charge_user_value as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as value
from
	mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = ''MED''
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
),
charge_user_info as (
	select
		ord.rst_charge_user_info ->>''user_last_name_1'' as user_last_name_1,
		ord.rst_charge_user_info ->>''user_first_name_1'' as user_first_name_1,
		ord.rst_charge_user_info ->>''user_last_name_2'' as user_last_name_2,
		ord.rst_charge_user_info ->>''user_first_name_2'' as user_first_name_2
	from 
		ord_main as ord
where
	ord.ord_no = @ordNo
)
select
	case (
		select
			value
		from
			charge_user_value
		where
			key2 = ''CHARGE_USER_CLASSIFICATION''
	)
		when ''0'' then coalesce(
      nullif(
        (select
          user_last_name_1 || user_first_name_1
        from
          charge_user_info),'''')
      ,(
		coalesce(nullif(
          (select
            user_last_name_2 || user_first_name_2
          from
            charge_user_info),'''')
		    ,(
          	select
          		value
			      from
				      charge_user_value
			      where
				      key2 = ''FIXED_DOCTOR_NAME1''
          )
        )
      )
    )
		when ''1'' then coalesce(
      nullif(
        (select 
          user_last_name_2 || user_first_name_2
        from 
          charge_user_info),'''')
        ,(
    			select
		    		value
			    from
				    charge_user_value
			    where
				    key2 = ''FIXED_DOCTOR_NAME1''
		))
		when ''2'' then (
			select
				value
			from
				charge_user_value
			where
				key2 = ''FIXED_DOCTOR_NAME1''
		)
		when ''3'' then(
			select
				value
			from
				charge_user_value
			where
				key2 = ''FIXED_DOCTOR_NAME2''
		)
		when ''4'' then(
			select
				value
			from
				charge_user_value
			where
				key2 = ''FIXED_NURSE_NAME1''
		)
		when ''5'' then(
			select
				value
			from
				charge_user_value
			where
				key2 = ''FIXED_NURSE_NAME2''
		)
	end as e01', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携担当者取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



-- S pat_personal_main
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317115, '
select
	pat_blood_type_abo as ABO,
	pat_blood_type_rh as RH
from 
	pat_personal_main
where
	pat_id = @patId', 3, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携血液取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



-- S blood_type
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317116, '
with blood_value as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as VALUE
from
	mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = ''MED''
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
)
select
	''血液'' as detail_id,
	case abo
	when ''0'' then (
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_A''
	)
	when ''1'' then(
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_B''
	)
	when ''2'' then(
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_AB''
	)
	when ''3'' then(
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_O''
	)
	else (
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_UNKNOWN''
	)
	end as abo,
	case rh
	when ''0'' then(
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_RH+''
	)
	when ''2'' then(
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_RH-''
	)
	else (
		select
			value
		from
			blood_value
		where
			key2 = ''BLOOD_TYPE_UNKNOWN''
	)
	end as rh
from
	(
		select
			@blood_type_abo as abo,
			@blood_type_rh as rh
	) as blood_type', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携血液取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[
  {
    "sql_cd": -317115,
    "field_name": "blood_type_abo",
    "replace_var": "@bloodTypeAbo"
  },
  {
    "sql_cd": -317115,
    "field_name": "blood_type_rh",
    "replace_var": "@bloodTypeRh"
  }
]'::jsonb);



-- S ord_info
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317117, '
with ord_info as (
  select
    rst_charge_user_info ->> ''user_last_name_1'' as last_name1,
    rst_charge_user_info ->> ''user_first_name_1'' as first_name1,
    rst_charge_user_info ->> ''user_last_name_2'' as last_name2,
    rst_charge_user_info ->> ''user_first_name_2'' as first_name2
  from
    ord_main
  where
    ord_no = @ordNo
),
dr_value as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as VALUE
from
	mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = ''MED''
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
)
select
	(
		select 
			value
		from
			dr_value
		where
			key2 = ''DR1_NAME_CLASSIFICATION''
	) as dr1_name_classification,
	(
		select 
			value
		from
			dr_value
		where
			key2 = ''DR2_NAME_CLASSIFICATION''
	) as dr2_name_classification,
	(
		select 
			value
		from
			dr_value
		where
			key2 = ''DR3_NAME_CLASSIFICATION''
	) as dr3_name_classification,
	(
		select 
			value
		from
			dr_value
		where
			key2 = ''DR4_NAME_CLASSIFICATION''
	) as dr4_name_classification,
	(
		select 
			value
		from
			dr_value
		where
			key2 = ''DR5_NAME_CLASSIFICATION''
	) as dr5_name_classification,
	(
		select
			staff_info ->> ''staff_cd'' as staff_cd
		from
			pat_main as pat
		cross join
            lateral json_array_elements(
                pat.charge_staff_info::json
            ) staff_info
		where
			pat.pat_id = @patId
		and staff_info ->> ''is_main'' = ''1''
		order by
			staff_info ->> ''disp_order'' asc
		limit 1
	) as staff_cd,
	ord.last_name1 || ord.first_name1 as ord_full_name1,
	ord.last_name2 || ord.first_name2 as ord_full_name2,
	(
		select
			value
		from
			dr_value
		where
			key2 = ''FIXED_DOCTOR_NAME1''
	) as fixed_doctor_name1,
	(
		select
			value
		from
			dr_value
		where
			key2 = ''FIXED_DOCTOR_NAME2''
	) as fixed_doctor_name2
from
	ord_info as ord', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携Dr事前取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



-- S テーブル指定なし
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317118, 'select
(case @dr1NameClassification
	when ''0'' then coalesce(
	(select
	        personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)  as pat_full_name
	      from
	        mst_personal_user
	      where
			user_id = coalesce(
			nullif(@staffCd,''''),
			''-1''
		)::int
		)
	,coalesce(nullif(@ordFullName1,''''),
	@fixedDoctorName1)
	)
		when ''1'' then coalesce(nullif(@ordFullName1,''''),@fixedDoctorName1)
		when ''2'' then @fixedDoctorName1
		when ''3'' then @fixedDoctorName2
		end
	) as e01,
	(
	case @dr2NameClassification
	when ''0'' then coalesce(
	(select
	        personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)  as pat_full_name
	      from
	        mst_personal_user
	      where
			user_id = coalesce(
			nullif(@staffCd,''''),
			''-1''
		)::int
		)
	,coalesce(nullif(@ordFullName2,''''),
	@fixedDoctorName1)
	)
		when ''1'' then coalesce(nullif(@ordFullName2,''''),@fixedDoctorName1)
		when ''2'' then @fixedDoctorName1
		when ''3'' then @fixedDoctorName2
		end 
	) as e02,
	(
	case @dr3NameClassification
	when ''0'' then coalesce(
	(select
	        personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)  as pat_full_name
	      from
	        mst_personal_user
	      where
			user_id = coalesce(
			nullif(@staffCd,''''),
			''-1''
		)::int
		)
	,@fixedDoctorName1)
	when ''1'' then @fixedDoctorName1
	when ''2'' then @fixedDoctorName2
	when ''3'' then @fixedDoctorName2
	end 
	) as e03,
	(
	case @dr4NameClassification
	when ''0'' then coalesce(
	(select
	        personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)  as pat_full_name
	      from
	        mst_personal_user
	      where
			user_id = coalesce(
			nullif(@staffCd,''''),
			''-1''
		)::int
		)
	,@fixedDoctorName1)
	when ''1'' then @fixedDoctorName1
	when ''2'' then @fixedDoctorName2
	when ''3'' then @fixedDoctorName2
	end 
	) as e04,
	(
	case @dr5NameClassification
	when ''0'' then coalesce(
	(select
	        personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)  as pat_full_name
	      from
	        mst_personal_user
	      where
			user_id = coalesce(
			nullif(@staffCd,''''),
			''-1''
		)::int
		)
	,@fixedDoctorName1)
	when ''1'' then @fixedDoctorName1
	when ''2'' then @fixedDoctorName2
	when ''3'' then @fixedDoctorName2
	end 
	) as e05', 3, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携Dr取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);


-- S ord_info
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317119, '
with ord_info as (
  select
    rst_charge_user_info ->> ''user_last_name_1'' as last_name1,
    rst_charge_user_info ->> ''user_first_name_1'' as first_name1,
    rst_charge_user_info ->> ''user_last_name_2'' as last_name2,
    rst_charge_user_info ->> ''user_first_name_2'' as first_name2
  from
    ord_main
  where
    ord_no = @ordNo
),
dr_value as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as VALUE
from
	mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = ''MED''
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
)
select
	(
		select 
			value
		from
			dr_value
		where
			key2 = ''NS1_NAME_CLASSIFICATION''
	) as ns1_name_classification,
	(
		select 
			value
		from
			dr_value
		where
			key2 = ''NS2_NAME_CLASSIFICATION''
	) as ns2_name_classification,
	(
		select 
			value
		from
			dr_value
		where
			key2 = ''NS3_NAME_CLASSIFICATION''
	) as ns3_name_classification,
	(
		select 
			value
		from
			dr_value
		where
			key2 = ''NS4_NAME_CLASSIFICATION''
	) as ns4_name_classification,
	(
		select 
			value
		from
			dr_value
		where
			key2 = ''NS5_NAME_CLASSIFICATION''
	) as ns5_name_classification,
	(
		select
			staff_info ->> ''staff_cd'' as staff_cd
		from
			pat_main as pat
		cross join
					lateral json_array_elements(
						pat.charge_staff_info::json
					) staff_info
		where
			pat.pat_id = @patId
			and staff_info ->> ''is_charge'' = ''1''
		order by
			staff_info ->> ''disp_order'' asc
		limit 1		
	) as staff_cd,
	ord.last_name1 || ord.first_name1 as ord_full_name1,
	ord.last_name2 || ord.first_name2 as ord_full_name2,
	(
		select
			value
		from
			dr_value
		where
			key2 = ''FIXED_NURSE_NAME1''
	) as fixed_nurse_name1,
	(
		select
			value
		from
			dr_value
		where
			key2 = ''FIXED_NURSE_NAME2''
	) as fixed_nurse_name2
from
	ord_info as ord', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携担当Ns事前取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



-- S テーブル指定なし
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317120, '
select
	(case @ns1NameClassification
	when ''0'' then coalesce(
	(select
	        personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)  as pat_full_name
	      from
	        mst_personal_user
	      where
			user_id = coalesce(
			nullif(@staffCd,''''),
			''-1''
		)::int
		)
	,coalesce(nullif(@ordFullName1,''''),
	@fixedNurseName1)
	)
		when ''1'' then coalesce(nullif(@ordFullName1,''''),@fixedNurseName1)
		when ''2'' then @fixedNurseName1
		when ''3'' then @fixedNurseName2
		end 
	) as e01,
	(
		case @ns2NameClassification
	when ''0'' then coalesce(
	(select
	        personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)  as pat_full_name
	      from
	        mst_personal_user
	      where
			user_id = coalesce(
			nullif(@staffCd,''''),
			''-1''
		)::int
		)
	,coalesce(nullif(@ordFullName2,''''),
	@fixedNurseName1)
	)
		when ''1'' then coalesce(nullif(@ordFullName2,''''),@fixedNurseName1)
		when ''2'' then @fixedNurseName1
		when ''3'' then @fixedNurseName2
		end 
	) as e02,
	(
		case @ns3NameClassification
		when ''0'' then coalesce(
		(select
		        personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)  as pat_full_name
		      from
		        mst_personal_user
		      where
				user_id = coalesce(
				nullif(@staffCd,''''),
				''-1''
			)::int
			)
		,@fixedNurseName1)
		when ''1'' then @fixedNurseName1
		when ''2'' then @fixedNurseName2
		end 
	) as e03,
	(
		case @ns4NameClassification
		when ''0'' then coalesce(
		(select
		        personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)  as pat_full_name
		      from
		        mst_personal_user
		      where
				user_id = coalesce(
				nullif(@staffCd,''''),
				''-1''
			)::int
			)
		,@fixedNurseName1)
		when ''1'' then @fixedNurseName1
		when ''2'' then @fixedNurseName2
		end 
	) as e04,
	(
		case @ns5NameClassification
		when ''0'' then coalesce(
		(select
		        personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)  as pat_full_name
		      from
		        mst_personal_user
		      where
				user_id = coalesce(
				nullif(@staffCd,''''),
				''-1''
			)::int
			)
		,@fixedNurseName1)
		when ''1'' then @fixedNurseName1
		when ''2'' then @fixedNurseName2
		end 
	) as e05', 3, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携担当Ns取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[
	{
		"sql_cd": -317119,
		"field_name": "ns1_name_classification",
		"replace_var": "@ns1NameClassification"
	},
	{
		"sql_cd": -317119,
		"field_name": "ns2_name_classification",
		"replace_var": "@ns2NameClassification"
	},
	{
		"sql_cd": -317119,
		"field_name": "ns3_name_classification",
		"replace_var": "@ns3NameClassification"
	},
	{
		"sql_cd": -317119,
		"field_name": "ns4_name_classification",
		"replace_var": "@ns4NameClassification"
	},
	{
		"sql_cd": -317119,
		"field_name": "ns5_name_classification",
		"replace_var": "@ns5NameClassification"
	},
	{
		"sql_cd": -317119,
		"field_name": "staff_cd",
		"replace_var": "@staffCd"
	},
	{
		"sql_cd": -317119,
		"field_name": "ord_full_name1",
		"replace_var": "@ordFullName1"
	},
	{
		"sql_cd": -317119,
		"field_name": "ord_full_name2",
		"replace_var": "@ordFullName2"
	},
	{
		"sql_cd": -317119,
		"field_name": "fixed_nurse_name1",
		"replace_var": "@fixedNurseName1"
	},
	{
		"sql_cd": -317119,
		"field_name": "fixed_nurse_name2",
		"replace_var": "@fixedNurseName2"
	}
]'::jsonb);



-- S テーブル指定なし
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317124, '
with info as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as value
from
	mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = ''MED''
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
)
select
	(
		select
			value
		from
			info
		where
			key2 = ''COMMENT''
	) as e01,--入力内容を表すコメント
	(
		select
			value
		from
			info
		where
			key2 = ''MEDICAL_INTERVIEWS_INPUT_DATA_FILE_INFO_ID''
	) as e02,--問診入力データファイル情報ＩＤ
	(
		select
			value
		from
			info
		where
			key2 = ''DESCRIBED_CONTENT_TYPE''
	) as e03--記載内容種別', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携コメント・問診入力データファイル情報ID・記載内容種別取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



-- S admission_info, device_info
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317106, '
with admission_info AS(
    SELECT
        UNNEST(string_to_array(
                        info ->> ''value'','','')) AS ADMISSION_VALUE
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(
                ini.coop_ini_info::json
            ) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''KARTE_ORD_SEND''
    AND info ->> ''key2'' = ''ADMISSION_SUPPORTED''
),
device_info AS(
    SELECT
        UNNEST(string_to_array(COALESCE(
                    NULLIF(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) AS DEVICE_VALUE
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(
                ini.coop_ini_info::json
            ) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''KARTE_ORD_SEND''
    AND info ->> ''key2'' = ''DEVICE_IDENTIFICATION_NAME''
)
SELECT
    TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDDHH24MISS'') || CASE ADMISSION_VALUE
        WHEN ''0'' THEN ''.xml''        
        WHEN ''1'' THEN ''_'' || ADMISSION_VALUE || ''_'' || DEVICE_VALUE || ''.xml''
    END AS filename
FROM
    admission_info, device_info', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicomカルテ記載連携(透析経過データ連携)ファイル名取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-309101, 'WITH
exam_item AS(
    SELECT
        COALESCE(NULLIF(info ->> ''''value'''', ''''), info ->> ''default_v'') AS value
    FROM
        ntss.mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    where
        facility_cd = ''@facilityCd''
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''MST''
    AND info ->> ''key2'' = ''EXAM_ITEM''
)
INSERT INTO pat_exam_main (
  pat_id,
  facility_cd,
  ord_no,
  fn_pat_id,
  reg_exam_date,
  reg_order_class,
  exam_status,
  order_comment,
  order_exam_set_info,
  exam_order_info,
  order_label_info,
  data_gen_class,
  result_exam_date,
  result_comment,
  exam_result_info,
  cop_order_no1,
  cop_order_no2,
  is_lock,
  ind_user_id,
  is_del,
  reg_date,
  reg_staff,
  up_date,
  up_staff,
  is_order,
  exam_week,
  exam_from,
  exam_to,
  exam_pattern 
)
VALUES
  (
    @patId,
    ''@facilityCd'',
  CASE
      ''@ordNo'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@ordNo'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
    END,
    NULLIF ( ''@fnPatId'', '''' ),
  CASE
      ''@regExamDate'' 
      WHEN '''' THEN
      CURRENT_TIMESTAMP ELSE to_timestamp( ''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 
    END,
  CASE
      ''@regOrderClass'' 
      WHEN '''' THEN
      NULL ELSE''@regOrderClass'' 
      END,
    NULLIF ( ''@examStatus'', '''' ),
    NULLIF ( ''@orderComment'', '''' ),
    ''@orderExamSetInfoValue'',
    ''@examOrderInfoValue'',
    ''@orderLabelInfoValue'',
    NULLIF ( ''@dataGenClass'', '''' ),
  CASE
      ''@resultExamDate'' 
      WHEN '''' THEN
      NULL ELSE to_timestamp( ''@resultExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 
    END,
    NULLIF ( ''@resultComment'', '''' ),
    (SELECT jsonb_agg(jsonb_set(info::jsonb, ''{"item_cd"}'', to_jsonb(CASE (SELECT value FROM exam_item)
       WHEN ''1'' THEN item.in_hospital_cd1::text
       WHEN ''2'' THEN item.in_hospital_cd2::text
       WHEN ''3'' THEN item.in_hospital_cd3::text
       ELSE NULL
       END)))
     from
       json_array_elements(''@examResultInfoValue'' ::json) info
         left outer join ntss.mst_exam_set as item 
           on info ->> ''item_cd'' = (item.exam_set_cd || '''')),
  CASE
      ''@copOrderNo1'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@copOrderNo1'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
    END,
  CASE
      ''@copOrderNo2'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@copOrderNo2'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
      END,
    NULLIF ( ''@isLock'', '''' ),
  CASE
      ''@indUserId'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@indUserId'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
    END,
    ''0'',
    CURRENT_TIMESTAMP,
  CASE
      ''@regStaff'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@regStaff'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
    END,
    CURRENT_TIMESTAMP,
  CASE
      ''@upStaff'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@upStaff'', ''9999999999999999999999999999999999999999999999999999999999999999'' ) 
    END,
    NULLIF ( ''@isOrder'', '''' ),
  CASE
      ''@examWeek'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@examWeek'', ''9999999999999999'' ) 
    END,
  CASE
      ''@examFrom'' 
      WHEN '''' THEN
      NULL ELSE to_timestamp( ''@examFrom'', ''yyyymmddhh24miss'' ) 
      END,
  CASE
      ''@examTo'' 
      WHEN '''' THEN
      NULL ELSE to_timestamp( ''@examTo'', ''yyyymmddhh24miss'' ) 
      END,
  CASE
      ''@examPattern'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@examPattern'', ''9999999999999999'' ) 
    END 
  )', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)Medicomの検査結果', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317105, '-- 【SQL_CD=-317105】
  select
  	pev.pat_id as pat_id
  FROM
    pat_event AS pev
    , ord_main AS ord 
  WHERE
    pev.event_start_date = ord.treat_date 
    AND ord.pat_id = pev.pat_id 
    AND pev.use_type = 2 
    AND pev.is_del = ''0'' 
    AND ord.ord_no = @ordNo
    AND ord.ord_no = pev.ord_no ', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携PatientCode事前取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317121, 'with mst_coop_ini_info as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
				nullif(
				info ->> ''value'',
				''''
			),
			info ->> ''default_v''
	        ), '','')
    ) as VALUE
from
	mst_coop_ini as ini
cross join
	lateral json_array_elements(
		ini.coop_ini_info::json
	) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = ''MED''
	and info ->> ''key1'' = ''SEND_COMMENT''
),
pat_event_info AS ( 
	SELECT
		pev.pat_event_cd,
		pev.up_date AS up_date,
		pev.reg_staff_info ->> ''reg_staff_name'' AS reg_staff_name,
		pev.input_params,
		pev.result_params
	FROM
		pat_event AS pev
	,	ord_main AS ord 
  WHERE
	pev.event_start_date = ord.treat_date 
	AND ord.pat_id = pev.pat_id 
	AND pev.use_type = 2 
	AND pev.is_del = ''0'' 
	AND ord.ord_no = @ordNo
	AND pev.category_name = (select value from mst_coop_ini_info where key2 = ''CATEGORY'')
	AND pev.sub_category_name = (select value from mst_coop_ini_info where key2 = ''SUB_CATEGORY'')
),
input_row as (
	select
		pei.pat_event_cd,
		ROW_NUMBER() OVER (PARTITION by pei.pat_event_cd) as input_row_no,
		input_params.value
	from
		pat_event_info as pei
	cross join
		lateral json_array_elements(
			pei.input_params::json
		) input_params
),
result_row as (
	select
		pei.pat_event_cd,
		ROW_NUMBER() OVER (PARTITION by pei.pat_event_cd) as result_row_no,
		result_params.value
	from
		pat_event_info as pei
	cross join
		lateral json_array_elements(
			pei.result_params::json
		) result_params
),
s_info as (
	SELECT
		result_row.pat_event_cd,
		(
			case split_part(split_part(result_row.value ->> ''result_value'', ''>'', 2), ''<'', 1)
			when '''' then result_row.value ->> ''result_value''
			else split_part(split_part(result_row.value ->> ''result_value'', ''>'', 2), ''<'', 1)
			end
		) AS e01
	FROM
		result_row
	INNER JOIN input_row on
		input_row.pat_event_cd = result_row.pat_event_cd
	AND result_row.result_row_no = input_row.input_row_no
	AND input_row.value ->> ''field_name'' = (select value from mst_coop_ini_info where key2 = ''S_FIELD'')
),
o_info as (
	SELECT
		result_row.pat_event_cd,
		(
			case split_part(split_part(result_row.value ->> ''result_value'', ''>'', 2), ''<'', 1)
			when '''' then result_row.value ->> ''result_value''
			else split_part(split_part(result_row.value ->> ''result_value'', ''>'', 2), ''<'', 1)
			end
		) AS e01
	FROM
		result_row
	INNER JOIN input_row on
		input_row.pat_event_cd = result_row.pat_event_cd
	AND result_row.result_row_no = input_row.input_row_no
	AND input_row.value ->> ''field_name'' = (select value from mst_coop_ini_info where key2 = ''O_FIELD'')
),
a_info as (
	SELECT
		result_row.pat_event_cd,
		(
			case split_part(split_part(result_row.value ->> ''result_value'', ''>'', 2), ''<'', 1)
			when '''' then result_row.value ->> ''result_value''
			else split_part(split_part(result_row.value ->> ''result_value'', ''>'', 2), ''<'', 1)
			end
		) AS e01
	FROM
		result_row
	INNER JOIN input_row on
		input_row.pat_event_cd = result_row.pat_event_cd
	AND result_row.result_row_no = input_row.input_row_no
	AND input_row.value ->> ''field_name'' = (select value from mst_coop_ini_info where key2 = ''A_FIELD'')
),
p_info as (
	SELECT
		result_row.pat_event_cd,
		(
			case split_part(split_part(result_row.value ->> ''result_value'', ''>'', 2), ''<'', 1)
			when '''' then result_row.value ->> ''result_value''
			else split_part(split_part(result_row.value ->> ''result_value'', ''>'', 2), ''<'', 1)
			end
		) AS e01
	FROM
		result_row
	INNER JOIN input_row on
		input_row.pat_event_cd = result_row.pat_event_cd
	AND result_row.result_row_no = input_row.input_row_no
	AND input_row.value ->> ''field_name'' = (select value from mst_coop_ini_info where key2 = ''P_FIELD'')
)
SELECT
	s_info.e01 AS S,
	o_info.e01 AS O,
	a_info.e01 AS A,
	p_info.e01 AS P,
	TO_CHAR(pei.up_date, ''YYYY-MM-DD HH24:MI:SS'') AS up_date,
	pei.reg_staff_name as staff_name
FROM
    pat_event_info pei
INNER JOIN s_info ON
	pei.pat_event_cd = s_info.pat_event_cd
INNER JOIN o_info ON
	pei.pat_event_cd = o_info.pat_event_cd
INNER JOIN a_info ON
	pei.pat_event_cd = a_info.pat_event_cd
INNER JOIN p_info ON
	pei.pat_event_cd = p_info.pat_event_cd
', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携SOAP取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317122, 'with mst_coop_ini_info as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
				nullif(
				info ->> ''value'',
				''''
			),
			info ->> ''default_v''
	        ), '','')
    ) as VALUE
from
	mst_coop_ini as ini
cross join
	lateral json_array_elements(
		ini.coop_ini_info::json
	) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = ''MED''
	and info ->> ''key1'' = ''SEND_COMMENT2''
),
pat_event_info AS ( 
	SELECT
		pev.pat_event_cd,
		pev.up_date AS up_date,
		pev.reg_staff_info ->> ''reg_staff_name'' AS reg_staff_name,
		pev.input_params,
		pev.result_params
	FROM
		pat_event AS pev
	,	ord_main AS ord 
  WHERE
	pev.event_start_date = ord.treat_date 
	AND ord.pat_id = pev.pat_id 
	AND pev.use_type = 2 
	AND pev.is_del = ''0'' 
	AND ord.ord_no = @ordNo
	AND pev.category_name = (select value from mst_coop_ini_info where key2 = ''CATEGORY'')
	AND pev.sub_category_name = (select value from mst_coop_ini_info where key2 = ''SUB_CATEGORY'')
),
input_row as (
	select
		pei.pat_event_cd,
		ROW_NUMBER() OVER (PARTITION by pei.pat_event_cd) as input_row_no,
		input_params.value
	from
		pat_event_info as pei
	cross join
		lateral json_array_elements(
			pei.input_params::json
		) input_params
),
result_row as (
	select
		pei.pat_event_cd,
		ROW_NUMBER() OVER (PARTITION by pei.pat_event_cd) as result_row_no,
		result_params.value
	from
		pat_event_info as pei
	cross join
		lateral json_array_elements(
			pei.result_params::json
		) result_params
),
nursing_notes_info as (
	SELECT
		result_row.pat_event_cd,
		(
			case split_part(split_part(result_row.value ->> ''result_value'', ''>'', 2), ''<'', 1)
			when '''' then result_row.value ->> ''result_value''
			else split_part(split_part(result_row.value ->> ''result_value'', ''>'', 2), ''<'', 1)
			end
		) AS e01
	FROM
		result_row
	INNER JOIN input_row on
		input_row.pat_event_cd = result_row.pat_event_cd
	AND result_row.result_row_no = input_row.input_row_no
	AND input_row.value ->> ''field_name'' = (select value from mst_coop_ini_info where key2 = ''FIELD'')
)
SELECT
	nursing_notes_info.e01,
	TO_CHAR(pei.up_date, ''YYYY-MM-DD HH24:MI:SS'') AS up_date,
	pei.reg_staff_name as staff_name
FROM
    pat_event_info pei
INNER JOIN nursing_notes_info ON
	pei.pat_event_cd = nursing_notes_info.pat_event_cd
', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携看護メモ取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317123, 'with mst_coop_ini_info as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
				nullif(
				info ->> ''value'',
				''''
			),
			info ->> ''default_v''
	        ), '','')
    ) as VALUE
from
	mst_coop_ini as ini
cross join
	lateral json_array_elements(
		ini.coop_ini_info::json
	) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = ''MED''
	and info ->> ''key1'' = ''SEND_COMMENT3''
),
pat_event_info AS ( 
	SELECT
		pev.pat_event_cd,
		pev.up_date AS up_date,
		pev.reg_staff_info ->> ''reg_staff_name'' AS reg_staff_name,
		pev.input_params,
		pev.result_params
	FROM
		pat_event AS pev
	,	ord_main AS ord 
  WHERE
	pev.event_start_date = ord.treat_date 
	AND ord.pat_id = pev.pat_id 
	AND pev.use_type = 2 
	AND pev.is_del = ''0'' 
	AND ord.ord_no = @ordNo
	AND pev.category_name = (select value from mst_coop_ini_info where key2 = ''CATEGORY'')
	AND pev.sub_category_name = (select value from mst_coop_ini_info where key2 = ''SUB_CATEGORY'')
),
input_row as (
	select
		pei.pat_event_cd,
		ROW_NUMBER() OVER (PARTITION by pei.pat_event_cd) as input_row_no,
		input_params.value
	from
		pat_event_info as pei
	cross join
		lateral json_array_elements(
			pei.input_params::json
		) input_params
),
result_row as (
	select
		pei.pat_event_cd,
		ROW_NUMBER() OVER (PARTITION by pei.pat_event_cd) as result_row_no,
		result_params.value
	from
		pat_event_info as pei
	cross join
		lateral json_array_elements(
			pei.result_params::json
		) result_params
),
interview_record_info as (
	SELECT
		result_row.pat_event_cd,
		(
			case split_part(split_part(result_row.value ->> ''result_value'', ''>'', 2), ''<'', 1)
			when '''' then result_row.value ->> ''result_value''
			else split_part(split_part(result_row.value ->> ''result_value'', ''>'', 2), ''<'', 1)
			end
		) AS e01
	FROM
		result_row
	INNER JOIN input_row on
		input_row.pat_event_cd = result_row.pat_event_cd
	AND result_row.result_row_no = input_row.input_row_no
	AND input_row.value ->> ''field_name'' = (select value from mst_coop_ini_info where key2 = ''FIELD'')
)
SELECT
	interview_record_info.e01,
	TO_CHAR(pei.up_date, ''YYYY-MM-DD HH24:MI:SS'') AS up_date,
	pei.reg_staff_name as staff_name
FROM
    pat_event_info pei
INNER JOIN interview_record_info ON
	pei.pat_event_cd = interview_record_info.pat_event_cd
', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携問診記録取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317140, 'with mst_coop_ini_info as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as VALUE
from
	mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = ''MED''
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
)
select
	(
	select
		value
	from
		mst_coop_ini_info
	where
		key2 = ''ADMISSION_SUPPORTED''
	) as admission_supported,
	(
	select
		value
	from
		mst_coop_ini_info
	where
		key2 = ''ELAPSED_DATA_OUTPUT''
	) as elapsed_data_output
', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携出力有無事前取得用SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317141, 'with pat_personal_main_info as (
select
  in_out_class
from
  pat_personal_main
where
  pat_id = @patId
)
select
  ''01.10'' as e01
from
	pat_personal_main_info	
where
  @admissionSupported <> ''1''
  OR @elapsedDataOutput <> ''0''
  OR in_out_class <> 1', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携出力有無取得用SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -317140, "field_name": "admission_supported", "replace_var": "@admissionSupported"}, {"sql_cd": -317140, "field_name": "elapsed_data_output", "replace_var": "@elapsedDataOutput"}]'::jsonb);



INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307001, 'with pat_info as(
	select
		staff_info ->> ''ctl_no'' as ctl_no,
		staff_info ->> ''disp_order'' as disp_order,
		staff_info ->> ''staff_cd'' as staff_cd,
		staff_info ->> ''is_main'' as is_main
	from
		pat_main as pat
		cross join lateral json_array_elements(pat.charge_staff_info :: json) staff_info
	where
		pat.pat_id = @patId
		and staff_info ->> ''is_main'' = ''1''
	order by
		staff_info ->> ''disp_order'' asc
	limit
		1
), sys_coop_info as(
	select
		user_id
	from
		sys_coop_journal as sys
	where
		sys.ctl_no = @ctlNo
),
ord_info as (
	select
		rst_charge_user_info ->> ''user_last_name_1'' as last_name1,
		rst_charge_user_info ->> ''user_first_name_1'' as first_name1,
		rst_charge_user_info ->> ''user_id_1'' as user_id_1,
		rst_course_cd,
		rst_course_name
	from
		ord_main
	where
		ord_no = @ordNo
),
doctor_name_value as(
	select
		info ->> ''key2'' as key2,
		unnest(
			string_to_array(
				coalesce(
					nullif(info ->> ''value'', ''''),
					info ->> ''default_v''
				),
				'',''
			)
		) as VALUE
	from
		mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info :: json) info
	where
		facility_cd = @facilityCd
		and is_del = ''0''
		and info ->> ''key0'' = ''MED''
		and info ->> ''key1'' = ''KARTE_ORD_SEND''
),
accept_send as(
	select
		info ->> ''key2'' as key2,
		unnest(
			string_to_array(
				coalesce(
					info ->> ''default_v'',
					nullif(info ->> ''value'', '''')
				),
				'',''
			)
		) as VALUE
	from
		mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info :: json) info
	where
		facility_cd = @facilityCd
		and is_del = ''0''
		and info ->> ''key0'' = ''MED''
		and info ->> ''key1'' = ''ACCEPT_SEND''
),
nurse_code_value as(
	select
		info ->> ''key2'' as key2,
		unnest(
			string_to_array(
				coalesce(
					nullif(info ->> ''value'', ''''),
					info ->> ''default_v''
				),
				'',''
			)
		) as VALUE
	from
		mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info :: json) info
	where
		facility_cd = @facilityCd
		and is_del = ''0''
		and info ->> ''key0'' = ''MED''
		and info ->> ''key1'' = ''MST''
),
rst_dial_value as(
	select
		info ->> ''key2'' as key2,
		unnest(
			string_to_array(
				coalesce(
					nullif(info ->> ''value'', ''''),
					info ->> ''default_v''
				),
				'',''
			)
		) as VALUE
	from
		mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info :: json) info
	where
		facility_cd = @facilityCd
		and is_del = ''0''
		and info ->> ''key0'' = ''MED''
		and info ->> ''key1'' = ''RST_DIAL''
)
select
	(
		case
			(
				select
					value
				from
					rst_dial_value
				where
					key2 = ''STAFF_KBN''
			)
			when ''0'' then coalesce(
				(
					select
						cast(user_id as character varying)
					from
						sys_coop_info
				),
				(
					select
						last_name1 || first_name1
					from
						ord_info
				)
			)
			when ''1'' then coalesce(
				(
					select
						last_name1 || first_name1
					from
						ord_info
				),
				(
					select
						staff_cd
					from
						pat_info
				)
			)
			when ''2'' then coalesce(
				(
					select
						staff_cd
					from
						pat_info
				),
				(
					select
						value
					from
						doctor_name_value
					where
						key2 = ''FIXED_DOCTOR_NAME1''
				)
			)
			when ''3'' then (
				select
					value
				from
					doctor_name_value
				where
					key2 = ''FIXED_DOCTOR_NAME1''
			)
			when ''4'' then (
				select
					value
				from
					doctor_name_value
				where
					key2 = ''FIXED_DOCTOR_NAME2''
			)
			when ''5'' then (
				select
					value
				from
					doctor_name_value
				where
					key2 = ''FIXED_NURSE_NAME1''
			)
			when ''6'' then (
				select
					value
				from
					doctor_name_value
				where
					key2 = ''FIXED_NURSE_NAME1''
			)
		end
	) as staff_name,
	(
		case
			(
				select
					value
				from
					rst_dial_value
				where
					key2 = ''STAFF_KBN''
			)
			when ''0'' then case
				when coalesce(
					(
						select
							user_id
						from
							sys_coop_info
					),
					0
				) = 0 then 0
				else 1
			end
			when ''1'' then case
				when coalesce(
					(
						select
							last_name1 || first_name1
						from
							ord_info
					),
					''''
				) = '''' then 1
				else 0
			end
			when ''2'' then case
				when coalesce(
					(
						select
							staff_cd
						from
							pat_info
					),
					''''
				) = '''' then 0
				else 1
			end
			when ''3'' then 0
			when ''4'' then 0
			when ''5'' then 0
			when ''6'' then 0
		end
	) as trans_kbn,
	(
		case
			(
				select
					value
				from
					rst_dial_value
				where
					key2 = ''STAFF_KBN''
			)
			when ''0'' then coalesce(
				(
					select
						cast (user_id as character varying)
					from
						sys_coop_info
				),
				(
					select
						user_id_1
					from
						ord_info
				)
			)
			when ''1'' then coalesce(
				(
					select
						user_id_1
					from
						ord_info
				),
				(
					select
						staff_cd
					from
						pat_info
				)
			)
			when ''2'' then coalesce(
				(
					select
						staff_cd
					from
						pat_info
				),
				(
					select
						value
					from
						accept_send
					where
						key2 = ''FIXED_DOCTOR_CODE1''
				)
			)
			when ''3'' then (
				select
					value
				from
					accept_send
				where
					key2 = ''FIXED_DOCTOR_CODE1''
			)
			when ''4'' then (
				select
					value
				from
					accept_send
				where
					key2 = ''FIXED_DOCTOR_CODE2''
			)
			when ''5'' then (
				select
					value
				from
					nurse_code_value
				where
					key2 = ''FIXED_NURSE_CODE1''
			)
			when ''6'' then (
				select
					value
				from
					nurse_code_value
				where
					key2 = ''FIXED_NURSE_CODE2''
			)
		end
	) as staff_cd,
	coalesce(
		(
			select
				rst_course_name
			from
				ord_info
		),
		(
			select
				value
			from
				accept_send
			where
				key2 = ''FIXED_COURES_NAME1''
		)
	) AS department_name,
	coalesce(
		(
			select
				in_hospital_cd_1
			from
				ord_info
				LEFT OUTER JOIN mst_course AS mcs ON mcs.course_cd = ord_info.rst_course_cd
		),
		(
			select
				value
			from
				accept_send
			where
				key2 = ''FIXED_COURES_CODE1''
		)
	) AS department_cd,
	(
		select
			value
		from
			accept_send
		where
			key2 = ''PRESCRIPTION_INOUT''
	) AS presciption_inout', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307002, 'select
	(
		case
			@transKbn
			when ''0'' then @staffCd
			when ''1'' then (
				select
					disp_user_id
				from
					mst_user_authentication
				where
					user_id in @staffCd
			)
		end
	) as staff_cd,', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307001, "field_name": "trans_kbn", "replace_var": "@transKbn"}, {"sql_cd": -307001, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307003, 'select
	(
		case
			@transKbn
			when ''0'' then @staffName
			when ''1'' then (
				select
					personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
				from
					mst_personal_user
				where
					user_id = @staffName
			)
		end
	) as staff_name,', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307001, "field_name": "trans_kbn", "replace_var": "@transKbn"}, {"sql_cd": -307001, "field_name": "staff_name", "replace_var": "@staffName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307004, 'with pat_coop_detail_present as (
	select
		pat_coop_detail.coop_save_no
	from
		pat_coop_detail,
		ord_main
	where
		ord_no = @ordNo
		and ord_main.treat_date = TO_CHAR(pat_coop_detail.up_date, ''YYYYMMDD'')
	order by
		pat_coop_detail.up_date desc
	limit
		1
), pat_coop_detail_past as (
	select
		pat_coop_detail.coop_save_no
	from
		pat_coop_detail,
		ord_main
	where
		ord_no = @ordNo
		and ord_main.treat_date > TO_CHAR(pat_coop_detail.up_date, ''YYYYMMDD'')
	order by
		pat_coop_detail.up_date desc
	limit
		1
), pat_coop_detail_future as (
	select
		pat_coop_detail.coop_save_no
	from
		pat_coop_detail,
		ord_main
	where
		ord_no = @ordNo
		and ord_main.treat_date = TO_CHAR(pat_coop_detail.up_date, ''YYYYMMDD'')
	order by
		pat_coop_detail.up_date desc
	limit
		1
)
select
	pat_coop_detail.save_2 ->> ''key_1'' as insurance,
	pat_coop_detail.save_2 ->> ''key_2'' as insurance_id
from
	pat_coop_detail,
	pat_coop_detail_present,
	pat_coop_detail_past,
	pat_coop_detail_future
where
	pat_coop_detail.coop_save_no = (
		case
			when pat_coop_detail_present.coop_save_no = null then pat_coop_detail_present.coop_save_no
			when pat_coop_detail_past.coop_save_no = null then pat_coop_detail_present.coop_save_no
			when pat_coop_detail_future.coop_save_no = null then pat_coop_detail_future.coop_save_no
			else null
		end
	)', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307005, 'with pat_info as(
	select
		staff_info ->> ''ctl_no'' as ctl_no,
		staff_info ->> ''disp_order'' as disp_order,
		staff_info ->> ''staff_cd'' as staff_cd,
		staff_info ->> ''is_main'' as is_main
	from
		pat_main as pat
		cross join lateral json_array_elements(pat.charge_staff_info :: json) staff_info
	where
		pat.pat_id = @patId
		and staff_info ->> ''is_main'' = ''1''
	order by
		staff_info ->> ''disp_order'' asc
	limit
		1
), ord_info as (
	select
		rst_charge_user_info ->> ''user_last_name_1'' as last_name1,
		rst_charge_user_info ->> ''user_first_name_1'' as first_name1,
		rst_charge_user_info ->> ''user_id_1'' as user_id_1,
		rst_treat_staff_info ->> ''treat_staff_cd'' as treat_staff_cd,
		rst_treat_staff_info ->> ''treat_staff_name'' as treat_staff_name,
		rst_medi_info ->> ''effect_flg'' as effect_flg,
		rst_medi_info ->> ''cd'' as rst_medicine_cd,
		rst_medi_info ->> ''medicine_type'' as medicine_type,
		rst_treatment_info ->> ''treat_medicine_cd'' as treat_medicine_cd,
		rst_course_cd,
		rst_course_name
	from
		ord_main
	where
		ord_no = @ordNo
),
accept_send as(
	select
		info ->> ''key2'' as key2,
		unnest(
			string_to_array(
				coalesce(
					nullif(info ->> ''value'', ''''),
					info ->> ''default_v''
				),
				'',''
			)
		) as VALUE
	from
		mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info :: json) info
	where
		facility_cd = @facilityCd
		and is_del = ''0''
		and info ->> ''key0'' = ''MED''
		and info ->> ''key1'' = ''ACCEPT_SEND''
),
rst_dial_value as(
	select
		info ->> ''key2'' as key2,
		unnest(
			string_to_array(
				coalesce(
					nullif(info ->> ''value'', ''''),
					info ->> ''default_v''
				),
				'',''
			)
		) as VALUE
	from
		mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info :: json) info
	where
		facility_cd = @facilityCd
		and is_del = ''0''
		and info ->> ''key0'' = ''MED''
		and info ->> ''key1'' = ''RST_DIAL''
),
doctor_name_value as(
	select
		info ->> ''key2'' as key2,
		unnest(
			string_to_array(
				coalesce(
					nullif(info ->> ''value'', ''''),
					info ->> ''default_v''
				),
				'',''
			)
		) as VALUE
	from
		mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info :: json) info
	where
		facility_cd = @facilityCd
		and is_del = ''0''
		and info ->> ''key0'' = ''MED''
		and info ->> ''key1'' = ''KARTE_ORD_SEND''
)
select
	lpad(
		concat(
			@ordNo,
			(
				select
					value
				from
					accept_send
				where
					key2 = ''PRESCRIPTION_INOUT''
			)
		),
		10
	) as order_units_id,
	(
		case
			(
				select
					value
				from
					rst_dial_value
				where
					key2 = ''INPUT_USER_KBN''
			)
			when ''0'' then coalesce(
				(
					select
						staff_cd
					from
						pat_info
				),
				(
					select
						last_name1 || first_name1
					from
						ord_info
				)
			)
			when ''1'' then coalesce(
				(
					select
						last_name1 || first_name1
					from
						ord_info
				),
				(
					select
						treat_staff_name
					from
						ord_info
				)
			)
			when ''2'' then coalesce(
				(
					select
						treat_staff_name
					from
						ord_info
				),
				(
					select
						value
					from
						doctor_name_value
					where
						key2 = ''FIXED_DOCTOR_NAME1''
				)
			)
			when ''3'' then (
				select
					value
				from
					doctor_name_value
				where
					key2 = ''FIXED_DOCTOR_NAME1''
			)
			when ''4'' then (
				select
					value
				from
					doctor_name_value
				where
					key2 = ''FIXED_DOCTOR_NAME2''
			)
			when ''5'' then (
				select
					value
				from
					doctor_name_value
				where
					key2 = ''FIXED_NURSE_NAME1''
			)
			when ''6'' then (
				select
					value
				from
					doctor_name_value
				where
					key2 = ''FIXED_NURSE_NAME1''
			)
		end
	) as staff_name,
	(
		case
			(
				select
					value
				from
					rst_dial_value
				where
					key2 = ''INPUT_USER_KBN''
			)
			when ''0'' then case
				when coalesce(
					(
						select
							staff_cd
						from
							pat_info
					),
					''''
				) = '''' then 0
				else 1
			end
			when ''1'' then case
				when coalesce(
					(
						select
							last_name1 || first_name1
						from
							ord_info
					),
					''''
				) = '''' then 1
				else 0
			end
			when ''2'' then case
				when coalesce(
					(
						select
							treat_staff_cd
						from
							ord_info
					),
					''''
				) = '''' then 0
				else 1
			end
			when ''3'' then 0
			when ''4'' then 0
			when ''5'' then 0
			when ''6'' then 0
		end
	) as trans_kbn,
	(
		case
			(
				select
					value
				from
					rst_dial_value
				where
					key2 = ''INPUT_USER_KBN''
			)
			when ''0'' then coalesce(
				(
					select
						staff_cd
					from
						pat_info
				),
				(
					select
						user_id_1
					from
						ord_info
				)
			)
			when ''1'' then coalesce(
				(
					select
						user_id_1
					from
						ord_info
				),
				(
					select
						treat_staff_cd
					from
						ord_info
				)
			)
			when ''2'' then coalesce(
				(
					select
						treat_staff_cd
					from
						ord_info
				),
				(
					select
						value
					from
						accept_send
					where
						key2 = ''FIXED_DOCTOR_CODE1''
				)
			)
			when ''3'' then (
				select
					value
				from
					accept_send
				where
					key2 = ''FIXED_DOCTOR_CODE1''
			)
			when ''4'' then (
				select
					value
				from
					accept_send
				where
					key2 = ''FIXED_DOCTOR_CODE2''
			)
			when ''5'' then (
				select
					value
				from
					nurse_code_value
				where
					key2 = ''FIXED_NURSE_CODE1''
			)
			when ''6'' then (
				select
					value
				from
					nurse_code_value
				where
					key2 = ''FIXED_NURSE_CODE2''
			)
		end
	) as staff_cd,
	(
		case
			(
				select
					value
				from
					rst_dial_value
				where
					key2 = ''INPUT_USER_KBN''
			)
			when ''0'' then (
				select
					mst_medicine
				from
					ord_info,
					mst_medicine
				where
					ord_info.rst_medicine_cd = mst_medicine.medicine_cd
					and mst_medicine.effect_flg = 1
			)
			when ''0'' then (
				select
					mst_medicine
				from
					ord_info,
					mst_medicine
				where
					ord_info.treat_medicine_cd = mst_medicine.medicine_cd
					and mst_medicine.class_cd = 1
			)
		end
	) as staff_cd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307006, 'select
	(
		case
			@transKbn
			when ''0'' then @staffName
			when ''1'' then (
				select
					personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
				from
					mst_personal_user
				where
					user_id = @staffName
			)
		end
	) as staff_name', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307005, "field_name": "trans_kbn", "replace_var": "@transKbn"}, {"sql_cd": -307005, "field_name": "staff_name", "replace_var": "@staffName"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307007, 'select
	(
		case
			@transKbn
			when ''0'' then @staffCd
			when ''1'' then (
				select
					disp_user_id
				from
					mst_user_authentication
				where
					user_id in @staffCd
			)
		end
	) as staff_cd', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307005, "field_name": "trans_kbn", "replace_var": "@transKbn"}, {"sql_cd": -307005, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307008, 'SELECT
    ''01'' AS detail_id', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307009, 'with ord_medi_infos as (
    select
        ord_medi_info ->> ''cd as'' medicine_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''effect_flg'' = ''1''
        and ord_medi_info ->> ''medicine_type'' = ''1''
    union
    select
        ord_treatment_info ->> ''medicine_cd'' as medicine_cd,
        ord_treatment_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info :: json) ord_treatment_info
    where
        ord_no = @ordNo
),
ord_medi_mix_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_mix_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''effect_flg'' = ''1''
        and ord_medi_info ->> ''medicine_type'' = ''2''
)
select
    ROW_NUMBER() over(
        order by
            code
    ) AS seq_no,
    ord_info.*
from
    (
        select
            left(
                cast(mst_medicine.medicine_cd as character varying),
                20
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            ord_medi_infos.amount,
            mst_medicine.unit
        from
            ord_medi_infos,
            mst_medicine
        where
            ord_medi_infos.medicine_cd = cast(mst_medicine.medicine_cd as character varying)
            and mst_medicine.class_cd = ''01''
        union
        select
            left(
                cast(
                    mst_medicine_mix.medicine_mix_cd as character varying
                ),
                20
            ) as code,
            left(mst_medicine_mix.medicine_mix_name, 80) as name,
            ord_medi_mix_infos.amount,
            mst_medicine_mix.unit
        from
            ord_medi_mix_infos,
            mst_medicine_mix
        where
            ord_medi_mix_infos.medicine_mix_cd = cast(
                mst_medicine_mix.medicine_mix_cd as character varying
            )
            and mst_medicine_mix.class_cd = ''01''
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307010, 'SELECT
    ''02'' AS detail_id', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307011, 'with ord_medi_infos as (
    select
        ord_medi_info ->> ''cd as'' medicine_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''effect_flg'' = ''1''
        and ord_medi_info ->> ''medicine_type'' = ''1''
    union
    select
        ord_treatment_info ->> ''medicine_cd'' as medicine_cd,
        ord_treatment_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info :: json) ord_treatment_info
    where
        ord_no = @ordNo
),
ord_medi_mix_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_mix_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''effect_flg'' = ''1''
        and ord_medi_info ->> ''medicine_type'' = ''2''
)
select
    ROW_NUMBER() over(
        order by
            code
    ) AS seq_no,
    ord_info.*
from
    (
        select
            left(
                cast(mst_medicine.medicine_cd as character varying),
                20
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            ord_medi_infos.amount,
            mst_medicine.unit
        from
            ord_medi_infos,
            mst_medicine
        where
            ord_medi_infos.medicine_cd = cast(mst_medicine.medicine_cd as character varying)
            and mst_medicine.class_cd = ''02''
        union
        select
            left(
                cast(
                    mst_medicine_mix.medicine_mix_cd as character varying
                ),
                20
            ) as code,
            left(mst_medicine_mix.medicine_mix_name, 80) as name,
            ord_medi_mix_infos.amount,
            mst_medicine_mix.unit
        from
            ord_medi_mix_infos,
            mst_medicine_mix
        where
            ord_medi_mix_infos.medicine_mix_cd = cast(
                mst_medicine_mix.medicine_mix_cd as character varying
            )
            and mst_medicine_mix.class_cd = ''02''
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307012, 'SELECT
    ''03'' AS detail_id', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307013, 'with ord_medi_infos as (
    select
        ord_medi_info ->> ''cd as'' medicine_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''effect_flg'' = ''1''
        and ord_medi_info ->> ''medicine_type'' = ''1''
    union
    select
        ord_treatment_info ->> ''medicine_cd'' as medicine_cd,
        ord_treatment_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info :: json) ord_treatment_info
    where
        ord_no = @ordNo
),
ord_medi_mix_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_mix_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''effect_flg'' = ''1''
        and ord_medi_info ->> ''medicine_type'' = ''2''
)
select
    ROW_NUMBER() over(
        order by
            code
    ) AS seq_no,
    ord_info.*
from
    (
        select
            left(
                cast(mst_medicine.medicine_cd as character varying),
                20
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            ord_medi_infos.amount,
            mst_medicine.unit
        from
            ord_medi_infos,
            mst_medicine
        where
            ord_medi_infos.medicine_cd = cast(mst_medicine.medicine_cd as character varying)
            and mst_medicine.class_cd = ''03''
        union
        select
            left(
                cast(
                    mst_medicine_mix.medicine_mix_cd as character varying
                ),
                20
            ) as code,
            left(mst_medicine_mix.medicine_mix_name, 80) as name,
            ord_medi_mix_infos.amount,
            mst_medicine_mix.unit
        from
            ord_medi_mix_infos,
            mst_medicine_mix
        where
            ord_medi_mix_infos.medicine_mix_cd = cast(
                mst_medicine_mix.medicine_mix_cd as character varying
            )
            and mst_medicine_mix.class_cd = ''03''
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307014, 'SELECT
    ''04'' AS detail_id', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307015, 'with ord_medi_infos as (
    select
        ord_medi_info ->> ''cd as'' medicine_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''effect_flg'' = ''1''
        and ord_medi_info ->> ''medicine_type'' = ''1''
    union
    select
        ord_treatment_info ->> ''medicine_cd'' as medicine_cd,
        ord_treatment_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info :: json) ord_treatment_info
    where
        ord_no = @ordNo
),
ord_medi_mix_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_mix_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''effect_flg'' = ''1''
        and ord_medi_info ->> ''medicine_type'' = ''2''
)
select
    ROW_NUMBER() over(
        order by
            code
    ) AS seq_no,
    ord_info.*
from
    (
        select
            left(
                cast(mst_medicine.medicine_cd as character varying),
                20
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            ord_medi_infos.amount,
            mst_medicine.unit
        from
            ord_medi_infos,
            mst_medicine
        where
            ord_medi_infos.medicine_cd = cast(mst_medicine.medicine_cd as character varying)
            and mst_medicine.class_cd = ''04''
        union
        select
            left(
                cast(
                    mst_medicine_mix.medicine_mix_cd as character varying
                ),
                20
            ) as code,
            left(mst_medicine_mix.medicine_mix_name, 80) as name,
            ord_medi_mix_infos.amount,
            mst_medicine_mix.unit
        from
            ord_medi_mix_infos,
            mst_medicine_mix
        where
            ord_medi_mix_infos.medicine_mix_cd = cast(
                mst_medicine_mix.medicine_mix_cd as character varying
            )
            and mst_medicine_mix.class_cd = ''04''
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307016, 'SELECT
    ''01'' AS detail_id', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307017, 'with ord_medi_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''procedure_cd'' = ''1''
    union
    select
        ord_treatment_info ->> ''medicine_cd'' as medicine_cd,
        ord_treatment_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info :: json) ord_treatment_info
    where
        ord_no = @ordNo
        and ord_treatment_info ->> ''procedure_cd'' = ''1''
),
ord_medi_mix_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_mix_cd,
        ord_medi_info ->> ''amount'' amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''procedure_cd'' = ''1''
)
select
    ROW_NUMBER() over(
        order by
            code
    ) AS seq_no,
    ord_info.*
from
    (
        select
            left(
                cast(mst_medicine.medicine_cd as character varying),
                20
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            ord_medi_infos.amount,
            mst_medicine.unit
        from
            ord_medi_infos,
            mst_medicine
        where
            ord_medi_infos.medicine_cd = cast(mst_medicine.medicine_cd as character varying)
        union
        select
            left(
                cast(
                    mst_medicine_mix.medicine_mix_cd as character varying
                ),
                20
            ) as code,
            left(mst_medicine_mix.medicine_mix_name, 80) as name,
            ord_medi_mix_infos.amount,
            mst_medicine_mix.unit
        from
            ord_medi_mix_infos,
            mst_medicine_mix
        where
            ord_medi_mix_infos.medicine_mix_cd = cast(
                mst_medicine_mix.medicine_mix_cd as character varying
            )
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307018, 'SELECT
    ''02'' AS detail_id', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307019, 'with ord_medi_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''procedure_cd'' = ''2''
    union
    select
        ord_treatment_info ->> ''medicine_cd'' as medicine_cd,
        ord_treatment_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info :: json) ord_treatment_info
    where
        ord_no = @ordNo
        and ord_treatment_info ->> ''procedure_cd'' = ''2''
),
ord_medi_mix_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_mix_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''procedure_cd'' = ''2''
)
select
    ROW_NUMBER() over(
        order by
            code
    ) AS seq_no,
    ord_info.*
from
    (
        select
            left(
                cast(mst_medicine.medicine_cd as character varying),
                20
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            ord_medi_infos.amount,
            mst_medicine.unit
        from
            ord_medi_infos,
            mst_medicine
        where
            ord_medi_infos.medicine_cd = cast(
                mst_medicine.medicine_cd as character varying
            )
        union
        select
            left(
                cast(
                    mst_medicine_mix.medicine_mix_cd as character varying
                ),
                20
            ) as code,
            left(mst_medicine_mix.medicine_mix_name, 80) as name,
            ord_medi_mix_infos.amount,
            mst_medicine_mix.unit
        from
            ord_medi_mix_infos,
            mst_medicine_mix
        where
            ord_medi_mix_infos.medicine_mix_cd = cast(
                mst_medicine_mix.medicine_mix_cd as character varying
            )
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307020, 'SELECT
    ''03'' AS detail_id', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307021, 'with ord_medi_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''procedure_cd'' = ''3''
    union
    select
        ord_treatment_info ->> ''medicine_cd'' as medicine_cd,
        ord_treatment_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info :: json) ord_treatment_info
    where
        ord_no = @ordNo
        and ord_treatment_info ->> ''procedure_cd'' = ''3''
),
ord_medi_mix_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_mix_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''procedure_cd'' = ''3''
)
select
    ROW_NUMBER() over(
        order by
            code
    ) AS seq_no,
    ord_info.*
from
    (
        select
            left(
                cast(mst_medicine.medicine_cd as character varying),
                20
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            ord_medi_infos.amount,
            mst_medicine.unit
        from
            ord_medi_infos,
            mst_medicine
        where
            ord_medi_infos.medicine_cd = cast(
                mst_medicine.medicine_cd as character varying
            )
        union
        select
            left(
                cast(
                    mst_medicine_mix.medicine_mix_cd as character varying
                ),
                20
            ) as code,
            left(mst_medicine_mix.medicine_mix_name, 80) as name,
            ord_medi_mix_infos.amount,
            mst_medicine_mix.unit
        from
            ord_medi_mix_infos,
            mst_medicine_mix
        where
            ord_medi_mix_infos.medicine_mix_cd = cast(
                mst_medicine_mix.medicine_mix_cd as character varying
            )
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307022, 'SELECT
    ''04'' AS detail_id', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307023, 'with ord_medi_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''procedure_cd'' = ''4''
    union
    select
        ord_treatment_info ->> ''medicine_cd'' as medicine_cd,
        ord_treatment_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info :: json) ord_treatment_info
    where
        ord_no = @ordNo
        and ord_treatment_info ->> ''procedure_cd'' = ''4''
),
ord_medi_mix_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_mix_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''procedure_cd'' = ''4''
)
select
    ROW_NUMBER() over(
        order by
            code
    ) AS seq_no,
    ord_info.*
from
    (
        select
            left(
                cast(mst_medicine.medicine_cd as character varying),
                20
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            ord_medi_infos.amount,
            mst_medicine.unit
        from
            ord_medi_infos,
            mst_medicine
        where
            ord_medi_infos.medicine_cd = cast(
                mst_medicine.medicine_cd as character varying
            )
        union
        select
            left(
                cast(
                    mst_medicine_mix.medicine_mix_cd as character varying
                ),
                20
            ) as code,
            left(mst_medicine_mix.medicine_mix_name, 80) as name,
            ord_medi_mix_infos.amount,
            mst_medicine_mix.unit
        from
            ord_medi_mix_infos,
            mst_medicine_mix
        where
            ord_medi_mix_infos.medicine_mix_cd = cast(
                mst_medicine_mix.medicine_mix_cd as character varying
            )
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307024, 'SELECT
    ''05'' AS detail_id', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307025, 'with ord_medi_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''procedure_cd'' = ''5''
    union
    select
        ord_treatment_info ->> ''medicine_cd'' as medicine_cd,
        ord_treatment_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info :: json) ord_treatment_info
    where
        ord_no = @ordNo
        and ord_treatment_info ->> ''procedure_cd'' = ''5''
),
ord_medi_mix_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_mix_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''procedure_cd'' = ''5''
)
select
    ROW_NUMBER() over(
        order by
            code
    ) AS seq_no,
    ord_info.*
from
    (
        select
            left(
                cast(mst_medicine.medicine_cd as character varying),
                20
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            ord_medi_infos.amount,
            mst_medicine.unit
        from
            ord_medi_infos,
            mst_medicine
        where
            ord_medi_infos.medicine_cd = cast(
                mst_medicine.medicine_cd as character varying
            )
        union
        select
            left(
                cast(
                    mst_medicine_mix.medicine_mix_cd as character varying
                ),
                20
            ) as code,
            left(mst_medicine_mix.medicine_mix_name, 80) as name,
            ord_medi_mix_infos.amount,
            mst_medicine_mix.unit
        from
            ord_medi_mix_infos,
            mst_medicine_mix
        where
            ord_medi_mix_infos.medicine_mix_cd = cast(
                mst_medicine_mix.medicine_mix_cd as character varying
            )
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307026, 'SELECT
    ''06'' AS detail_id', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307027, 'with ord_medi_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''procedure_cd'' = ''6''
    union
    select
        ord_treatment_info ->> ''medicine_cd'' as medicine_cd,
        ord_treatment_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info :: json) ord_treatment_info
    where
        ord_no = @ordNo
        and ord_treatment_info ->> ''procedure_cd'' = ''6''
),
ord_medi_mix_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_mix_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''procedure_cd'' = ''6''
)
select
    ROW_NUMBER() over(
        order by
            code
    ) AS seq_no,
    ord_info.*
from
    (
        select
            left(
                cast(mst_medicine.medicine_cd as character varying),
                20
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            ord_medi_infos.amount,
            mst_medicine.unit
        from
            ord_medi_infos,
            mst_medicine
        where
            ord_medi_infos.medicine_cd = cast(
                mst_medicine.medicine_cd as character varying
            )
        union
        select
            left(
                cast(
                    mst_medicine_mix.medicine_mix_cd as character varying
                ),
                20
            ) as code,
            left(mst_medicine_mix.medicine_mix_name, 80) as name,
            ord_medi_mix_infos.amount,
            mst_medicine_mix.unit
        from
            ord_medi_mix_infos,
            mst_medicine_mix
        where
            ord_medi_mix_infos.medicine_mix_cd = cast(
                mst_medicine_mix.medicine_mix_cd as character varying
            )
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307028, 'SELECT
    ''01'' AS detail_id', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307029, 'with ord_medi_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''effect_flg'' = ''1''
        and ord_medi_info ->> ''medicine_type'' = ''1''
    union
    select
        ord_treatment_info ->> ''medicine_cd'' as medicine_cd,
        ord_treatment_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info :: json) ord_treatment_info
    where
        ord_no = @ordNo
),
ord_medi_mix_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_mix_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''effect_flg'' = ''1''
        and ord_medi_info ->> ''medicine_type'' = ''2''
)
select
    ROW_NUMBER() over(
        order by
            code
    ) AS seq_no,
    ord_info.*
from
    (
        select
            left(
                cast(mst_medicine.medicine_cd as character varying),
                20
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            ord_medi_infos.amount,
            mst_medicine.unit
        from
            ord_medi_infos,
            mst_medicine
        where
            ord_medi_infos.medicine_cd = cast(
                mst_medicine.medicine_cd as character varying
            )
            and mst_medicine.class_cd = ''01''
        union
        select
            left(
                cast(
                    mst_medicine_mix.medicine_mix_cd as character varying
                ),
                20
            ) as code,
            left(mst_medicine_mix.medicine_mix_name, 80) as name,
            ord_medi_mix_infos.amount,
            mst_medicine_mix.unit
        from
            ord_medi_mix_infos,
            mst_medicine_mix
        where
            ord_medi_mix_infos.medicine_mix_cd = cast(
                mst_medicine_mix.medicine_mix_cd as character varying
            )
            and mst_medicine_mix.class_cd = ''01''
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307030, 'SELECT
    ''02'' AS detail_id', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307031, 'with ord_medi_infos as (
    select
        ord_addition_info ->> ''medicine_cd'' as medicine_cd,
        ord_addition_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.addition_info :: json) ord_addition_info
    where
        ord_no = @ordNo
)
select
    ROW_NUMBER() over(
        order by
            code
    ) AS seq_no,
    ord_info.*
from
    (
        select
            left(
                cast(mst_medicine.medicine_cd as character varying),
                20
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            ord_medi_infos.amount,
            mst_medicine.unit
        from
            ord_medi_infos,
            mst_medicine
        where
            ord_medi_infos.medicine_cd = cast(
                mst_medicine.medicine_cd as character varying
            )
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307032, 'SELECT
    ''03'' AS detail_idd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307033, 'select
    array_agg(pat_dial_diff_com_info ->> ''dial_diff_cd'') as dial_diff_cds
from
    pat_personal_main
    cross join lateral json_array_elements(pat_personal_main.dial_diff_com_info :: json) pat_dial_diff_com_info
where
    pat_personal_main.pat_id = @patId
    and pat_dial_diff_com_info ->> ''is_dial_diff'' = ''1''', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307034, 'select
    ROW_NUMBER() over(
        order by
            cast(
                mst_dialysis_difficulty.dialysis_difficulty_cd as character varying
            )
    ) AS seq_no,
    left(
        cast(
            mst_dialysis_difficulty.dialysis_difficulty_cd as character varying
        ),
        20
    ) as code,
    left(
        mst_dialysis_difficulty.dialysis_difficulty_name,
        40
    ) as name
from
    mst_dialysis_difficulty
where
    mst_dialysis_difficulty.dialysis_difficulty_cd in @dial_diff_cds', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307033, "field_name": "dial_diff_cds", "replace_var": "@dial_diff_cds"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307035, 'SELECT
    ''04'' AS detail_idd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307036, 'with ord_main_info as(
    select
        ord_addition_info ->> ''cd'' as code
    from
        ord_main
        cross join lateral json_array_elements(ord_main.addition_info :: json) ord_addition_info
    where
        ord_main.ord_no = @ordNo
)
select
    ROW_NUMBER() over(
        order by
            cast(mst_addition.addition_cd as character varying)
    ) AS seq_no,
    left(
        cast(mst_addition.addition_cd as character varying),
        20
    ) as code,
    left(mst_addition.addition_name, 256) as name
from
    ord_main_info,
    mst_addition
where
    ord_main_info.code = cast(mst_addition.addition_cd as character varying)
    and mst_addition.addition_class = ''1''', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307037, 'SELECT
    ''05'' AS detail_idd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307038, 'with ord_main_info as(
    select
        ord_addition_info ->> ''cd'' as code
    from
        ord_main
        cross join lateral json_array_elements(ord_main.addition_info :: json) ord_addition_info
    where
        ord_main.ord_no = @ordNo
),
addition_key_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(
            ini.coop_ini_info :: json
        ) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = ''MED''
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''ADDITION_KEY''
)
select
    ROW_NUMBER() over(
        order by
            cast(mst_addition.addition_cd as character varying)
    ) AS seq_no,
    left(
        cast(mst_addition.addition_cd as character varying),
        20
    ) as code,
    left(mst_addition.addition_name, 256) as name
from
    ord_main_info,
    mst_addition,
    addition_key_value
where
    ord_main_info.code = cast(mst_addition.addition_cd as character varying)
    and mst_addition.in_hospital_cd_2 = cast(addition_key_value.value as character varying)', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307039, 'SELECT
    ''06'' AS detail_idd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307040, 'with ord_main_info as(
    select
        ord_addition_info ->> ''cd'' as code
    from
        ord_main
        cross join lateral json_array_elements(ord_main.addition_info :: json) ord_addition_info
    where
        ord_main.ord_no = @ordNo
),
addition_key_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(
            ini.coop_ini_info :: json
        ) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = ''MED''
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''ADDITION_KEY''
)
select
    ROW_NUMBER() over(
        order by
            cast(mst_addition.addition_cd as character varying)
    ) AS seq_no,
    left(
        cast(mst_addition.addition_cd as character varying),
        20
    ) as code,
    left(mst_addition.addition_name, 256) as name
from
    ord_main_info,
    mst_addition,
    addition_key_value
where
    ord_main_info.code = cast(mst_addition.addition_cd as character varying)
    and mst_addition.in_hospital_cd_2 <> cast(addition_key_value.value as character varying)', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307041, 'SELECT
    ''07'' AS detail_idd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307042, 'with addition_treatment_name as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as value
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(
            ini.coop_ini_info :: json
        ) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = ''MED''
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''ADDITION_TREATMENT_NAME''
)
select
    ROW_NUMBER() over(
        order by
            cast(mst_treatment.treatment_cd as character varying)
    ) AS seq_no,
    left(
        cast(mst_treatment.treatment_cd as character varying),
        20
    ) as code,
    left(mst_treatment.treatment_name, 256) as name
from
    mst_treatment,
    addition_treatment_name
where
    mst_treatment.treatment_name = cast(
        addition_treatment_name.value as character varying
    )', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307043, 'SELECT
    ''08'' AS detail_idd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307044, 'with anticoagulant as (
    select
        ind_cond_info -> ''25'' ->> ''value'' AS medicine_cd,
        rst_cond_info -> ''25'' ->> ''medicine_type'' AS medicine_type,
        (
            cast(rst_cond_info -> ''26'' ->> ''value'' as integer) + cast(rst_cond_info -> ''28'' ->> ''value'' as integer)
        ) AS amount
    from
        ord_main
    where
        ord_no = @ordNo
),
treatment_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = ''MED''
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''TREATMENT_ITEM''
)
select
    ROW_NUMBER() over(
        order by
            cast(code as character varying)
    ) AS seq_no,
    ord_info.*
from
    (
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_medicine.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_medicine.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_medicine.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            anticoagulant.amount,
            mst_medicine.unit
        from
            anticoagulant,
            mst_medicine
        where
            anticoagulant.medicine_cd = cast(mst_medicine.medicine_cd as character varying)
            and anticoagulant.medicine_type = ''1''
        union
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_medicine.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_medicine.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_medicine.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            cast(anticoagulant_mix.amount as integer),
            mst_medicine.unit
        from
            (
                select
                    mix_info ->> ''cd'' as medicine_cd,
                    mix_info ->> ''amount'' as amount
                from
                    anticoagulant,
                    mst_medicine_mix
                    cross join lateral json_array_elements(mst_medicine_mix.mix_info :: json) mix_info
                where
                    anticoagulant.medicine_cd = cast(
                        mst_medicine_mix.medicine_mix_cd as character varying
                    )
                    and anticoagulant.medicine_type = ''2''
            ) as anticoagulant_mix,
            mst_medicine
        where
            anticoagulant_mix.medicine_cd = cast(mst_medicine.medicine_cd as character varying)
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307045, 'SELECT
    ''09'' AS detail_idd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307046, 'with anticoagulant as (
    select
        ind_cond_info -> ''15'' ->> ''value'' AS medicine_cd,
        rst_cond_info -> ''15'' ->> ''medicine_type'' AS medicine_type,
        rst_cond_info -> ''16'' ->> ''value'' AS amount
    from
        ord_main
    where
        ord_no = @ordNo
),
treatment_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = ''MED''
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''TREATMENT_ITEM''
)
select
    ROW_NUMBER() over(
        order by
            cast(code as character varying)
    ) AS seq_no,
    ord_info.*
from
    (
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_medicine.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_medicine.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_medicine.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            anticoagulant.amount,
            mst_medicine.unit_second as unit
        from
            anticoagulant,
            mst_medicine
        where
            anticoagulant.medicine_cd = cast(mst_medicine.medicine_cd as character varying)
            and anticoagulant.medicine_type = ''1''
        union
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_medicine.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_medicine.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_medicine.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            anticoagulant_mix.amount,
            mst_medicine.unit_second as unit
        from
            (
                select
                    mix_info ->> ''cd'' as medicine_cd,
                    mix_info ->> ''amount'' as amount
                from
                    anticoagulant,
                    mst_medicine_mix
                    cross join lateral json_array_elements(mst_medicine_mix.mix_info :: json) mix_info
                where
                    anticoagulant.medicine_cd = cast(
                        mst_medicine_mix.medicine_mix_cd as character varying
                    )
                    and anticoagulant.medicine_type = ''2''
            ) as anticoagulant_mix,
            mst_medicine
        where
            anticoagulant_mix.medicine_cd = cast(mst_medicine.medicine_cd as character varying)
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307047, 'SELECT
    ''10'' AS detail_idd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307048, 'with anticoagulant as (
    select
        ind_cond_info -> ''19'' ->> ''value'' AS medicine_cd,
        rst_cond_info -> ''19'' ->> ''medicine_type'' AS medicine_type,
        rst_cond_info -> ''22'' ->> ''value'' AS amount
    from
        ord_main
    where
        ord_no = @ordNo
),
treatment_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = ''MED''
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''TREATMENT_ITEM''
)
select
    ROW_NUMBER() over(
        order by
            cast(code as character varying)
    ) AS seq_no,
    ord_info.*
from
    (
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_medicine.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_medicine.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_medicine.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            anticoagulant.amount,
            mst_medicine.unit_second as unit
        from
            anticoagulant,
            mst_medicine
        where
            anticoagulant.medicine_cd = cast(mst_medicine.medicine_cd as character varying)
            and anticoagulant.medicine_type = ''1''
        union
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_medicine.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_medicine.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_medicine.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            anticoagulant_mix.amount,
            mst_medicine.unit_second as unit
        from
            (
                select
                    mix_info ->> ''cd'' as medicine_cd,
                    mix_info ->> ''amount'' as amount
                from
                    anticoagulant,
                    mst_medicine_mix
                    cross join lateral json_array_elements(mst_medicine_mix.mix_info :: json) mix_info
                where
                    anticoagulant.medicine_cd = cast(
                        mst_medicine_mix.medicine_mix_cd as character varying
                    )
                    and anticoagulant.medicine_type = ''2''
            ) as anticoagulant_mix,
            mst_medicine
        where
            anticoagulant_mix.medicine_cd = cast(mst_medicine.medicine_cd as character varying)
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307049, 'SELECT
    ''11'' AS detail_idd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307050, 'with ord_medi_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''effect_flg'' = ''1''
        and ord_medi_info ->> ''medicine_type'' = ''1''
    union
    select
        ord_treatment_info ->> ''medicine_cd'' as medicine_cd,
        ord_treatment_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info :: json) ord_treatment_info
    where
        ord_no = @ordNo
),
ord_medi_mix_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_mix_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''effect_flg'' = ''1''
        and ord_medi_info ->> ''medicine_type'' = ''2''
),
treatment_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = ''MED''
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''TREATMENT_ITEM''
)
select
    ROW_NUMBER() over(
        order by
            cast(code as character varying)
    ) AS seq_no,
    ord_info.*
from
    (
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_comp_treatment.in_hospital_cd_a1, 20)
                    when ''2'' then left(mst_comp_treatment.in_hospital_cd_a2, 20)
                    when ''3'' then left(mst_comp_treatment.in_hospital_cd_a3, 20)
                end
            ) as code,
            left(mst_comp_treatment.treatment, 256) as name,
            ord_medi_infos.amount,
            mst_medicine.unit
        from
            ord_medi_infos,
            mst_medicine,
            mst_comp_treatment
        where
            ord_medi_infos.medicine_cd = cast(
                mst_medicine.medicine_cd as character varying
            )
            and mst_medicine.class_cd = ''01''
            and mst_medicine.medicine_cd = mst_comp_treatment.comp_treatment_cd
            and mst_comp_treatment.treat_class = ''1''
        union
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_comp_treatment.in_hospital_cd_a1, 20)
                    when ''2'' then left(mst_comp_treatment.in_hospital_cd_a2, 20)
                    when ''3'' then left(mst_comp_treatment.in_hospital_cd_a3, 20)
                end
            ) as code,
            left(mst_comp_treatment.treatment, 256) as name,
            ord_medi_mix_infos.amount,
            mst_medicine_mix.unit
        from
            ord_medi_mix_infos,
            mst_medicine_mix,
            mst_comp_treatment
        where
            ord_medi_mix_infos.medicine_mix_cd = cast(
                mst_medicine_mix.medicine_mix_cd as character varying
            )
            and mst_medicine_mix.class_cd = ''01''
            and mst_medicine_mix.medicine_mix_cd = mst_comp_treatment.comp_treatment_cd
            and mst_comp_treatment.treat_class = ''1''
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307051, 'SELECT
    ''12'' AS detail_idd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307052, 'with column_info as (
    select
        ind_cond_info -> ''6'' ->> ''value'' AS equipment_cd,
        1 AS amount
    from
        ord_main
    where
        ord_no = @ordNo
),
equipment_info as (
    select
        rst_equip_info ->> ''cd'' AS equipment_cd,
        rst_equip_info ->> ''amount'' AS amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_equip_info :: json) rst_equip_info
    where
        ord_no = @ordNo
),
treatment_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = ''MED''
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''TREATMENT_ITEM''
)
select
    ROW_NUMBER() over(
        order by
            cast(code as character varying)
    ) AS seq_no,
    ord_info.*
from
    (
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_equipment.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_equipment.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_equipment.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_equipment.equipment_name, 80) as name,
            column_info.amount,
            mst_equipment.unit
        from
            column_info,
            mst_equipment
        where
            column_info.equipment_cd = cast(mst_equipment.equipment_cd as character varying)
        union
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_equipment.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_equipment.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_equipment.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_equipment.equipment_name, 80) as name,
            cast(equipment_info.amount as integer),
            mst_equipment.unit
        from
            equipment_info,
            mst_equipment
        where
            equipment_info.equipment_cd = cast(mst_equipment.equipment_cd as character varying)
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307053, 'SELECT
    ''13'' AS detail_idd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307054, 'with dialyzer_info as (
    select
        ind_cond_info -> ''5'' ->> ''value'' AS dialyzer_cd,
        1 AS amount
    from
        ord_main
    where
        ord_no = @ordNo
),
treatment_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = ''MED''
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''TREATMENT_ITEM''
)
select
    ROW_NUMBER() over(
        order by
            cast(code as character varying)
    ) AS seq_no,
    ord_info.*
from
    (
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_dialyzer.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_dialyzer.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_dialyzer.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_dialyzer.dialyzer_type, 80) as name,
            dialyzer_info.amount,
            ''1'' as unit
        from
            dialyzer_info,
            mst_dialyzer
        where
            dialyzer_info.dialyzer_cd = cast(mst_dialyzer.dialyzer_cd as character varying)
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307055, 'SELECT
    ''14'' AS detail_idd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307056, 'with equipment_info1 as (
    select
        ind_cond_info -> ''7'' ->> ''value'' AS equipment_cd,
        1 AS amount
    from
        ord_main
    where
        ord_no = @ordNo
),
equipment_info2 as (
    select
        ind_cond_info -> ''8'' ->> ''value'' AS equipment_cd,
        1 AS amount
    from
        ord_main
    where
        ord_no = @ordNo
),
treatment_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = ''MED''
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''TREATMENT_ITEM''
)
select
    ROW_NUMBER() over(
        order by
            cast(code as character varying)
    ) AS seq_no,
    ord_info.*
from
    (
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_equipment.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_equipment.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_equipment.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_equipment.equipment_name, 80) as name,
            equipment_info1.amount,
            mst_equipment.unit
        from
            equipment_info1,
            mst_equipment
        where
            equipment_info1.equipment_cd = cast(mst_equipment.equipment_cd as character varying)
        union
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_equipment.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_equipment.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_equipment.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_equipment.equipment_name, 80) as name,
            equipment_info2.amount,
            mst_equipment.unit
        from
            equipment_info2,
            mst_equipment
        where
            equipment_info2.equipment_cd = cast(mst_equipment.equipment_cd as character varying)
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307057, 'SELECT
    ''15'' AS detail_idd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307058, 'with oxygen_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as value,
        info ->> ''key2'' as key2
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = ''MED''
        and info ->> ''key1'' = ''OXYGEN_PROCEDURE''
)
select
    1 AS seq_no,
    (
        select
            value
        from
            oxygen_item_value
        where
            key2 = ''MEDI_CD''
    ) as code,
    (
        select
            value
        from
            oxygen_item_value
        where
            key2 = ''MEDI_NAME''
    ) as name', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307059, 'SELECT
    ''16'' AS detail_idd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307060, 'with ord_rst_treatment_info as (
    select
        ord_rst_treatment_info ->> ''oxygen_amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info :: json) ord_rst_treatment_info
    where
        ord_no = @ordNo
),
oxygen_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as value,
        info ->> ''key2'' as key2
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = ''MED''
        and info ->> ''key1'' = ''OXYGEN''
)
select
    1 AS seq_no,
    (
        select
            value
        from
            oxygen_item_value
        where
            key2 = ''MEDI_CD''
    ) as code,
    (
        select
            value
        from
            oxygen_item_value
        where
            key2 = ''MEDI_NAME''
    ) as name,
    sum(cast(ord_rst_treatment_info.amount as integer)) as amount,
    (
        select
            value
        from
            oxygen_item_value
        where
            key2 = ''UNIT''
    ) as unit
from
    ord_rst_treatment_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307061, 'SELECT
    ''17'' AS detail_idd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307062, 'with ord_medi_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''effect_flg'' = ''1''
        and ord_medi_info ->> ''medicine_type'' = ''1''
    union
    select
        ord_treatment_info ->> ''medicine_cd'' as medicine_cd,
        ord_treatment_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info :: json) ord_treatment_info
    where
        ord_no = @ordNo
),
ord_medi_mix_infos as (
    select
        ord_medi_info ->> ''cd'' as medicine_mix_cd,
        ord_medi_info ->> ''amount'' as amount
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info :: json) ord_medi_info
    where
        ord_no = @ordNo
        and ord_medi_info ->> ''effect_flg'' = ''1''
        and ord_medi_info ->> ''medicine_type'' = ''2''
),
treatment_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = ''MED''
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''TREATMENT_ITEM''
)
select
    ROW_NUMBER() over(
        order by
            cast(code as character varying)
    ) AS seq_no,
    ord_info.*
from
    (
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_medicine.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_medicine.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_medicine.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_medicine.medicine_name, 80) as name,
            ord_medi_infos.amount,
            mst_medicine.unit
        from
            ord_medi_infos,
            mst_medicine
        where
            ord_medi_infos.medicine_cd = cast(
                mst_medicine.medicine_cd as character varying
            )
            and mst_medicine.class_cd = ''01''
        union
        select
            (
                case
                    (
                        select
                            value
                        from
                            treatment_item_value
                    )
                    when ''1'' then left(mst_medicine_mix.in_hospital_cd_1, 20)
                    when ''2'' then left(mst_medicine_mix.in_hospital_cd_2, 20)
                    when ''3'' then left(mst_medicine_mix.in_hospital_cd_3, 20)
                end
            ) as code,
            left(mst_medicine_mix.medicine_mix_name, 80) as name,
            ord_medi_mix_infos.amount,
            mst_medicine_mix.unit
        from
            ord_medi_mix_infos,
            mst_medicine_mix
        where
            ord_medi_mix_infos.medicine_mix_cd = cast(
                mst_medicine_mix.medicine_mix_cd as character varying
            )
            and mst_medicine_mix.class_cd = ''01''
    ) ord_info', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307063, 'SELECT
    ''17'' AS detail_idd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307064, 'with ord_main_info as(
    select
        ord_addition_info ->> ''cd'' as code
    from
        ord_main
        cross join lateral json_array_elements(ord_main.addition_info :: json) ord_addition_info
    where
        ord_main.ord_no = @ordNo
),
treatment_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = ''MED''
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''TREATMENT_ITEM''
)
select
    ROW_NUMBER() over(
        order by
            cast(code as character varying)
    ) AS seq_no,
    (
        case
            (
                select
                    value
                from
                    treatment_item_value
            )
            when ''1'' then left(mst_addition.in_hospital_cd_1, 20)
            when ''2'' then left(mst_addition.in_hospital_cd_2, 20)
            when ''3'' then left(mst_addition.in_hospital_cd_3, 20)
        end
    ) as code,
    left(mst_addition.addition_name, 256) as name
from
    ord_main_info,
    mst_addition
where
    ord_main_info.code = cast(mst_addition.addition_cd as character varying)
    and mst_addition.addition_class = ''1''', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307065, 'SELECT
    ''18'' AS detail_idd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307066, 'with ord_main_info as(
    select
        ord_addition_info ->> ''cd'' as code
    from
        ord_main
        cross join lateral json_array_elements(ord_main.addition_info :: json) ord_addition_info
    where
        ord_main.ord_no = @ordNo
),
treatment_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = ''MED''
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''TREATMENT_ITEM''
)
select
    ROW_NUMBER() over(
        order by
            cast(code as character varying)
    ) AS seq_no,
    (
        case
            (
                select
                    value
                from
                    treatment_item_value
            )
            when ''1'' then left(mst_addition.in_hospital_cd_1, 20)
            when ''2'' then left(mst_addition.in_hospital_cd_2, 20)
            when ''3'' then left(mst_addition.in_hospital_cd_3, 20)
        end
    ) as code,
    left(mst_addition.addition_name, 256) as name
from
    ord_main_info,
    mst_addition
where
    ord_main_info.code = cast(mst_addition.addition_cd as character varying)
    and mst_addition.addition_class = ''1''', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307067, 'SELECT
    ''18'' AS detail_idd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307068, 'with ord_main_info as(
    select
        ord_addition_info ->> ''cd'' as code
    from
        ord_main
        cross join lateral json_array_elements(ord_main.addition_info :: json) ord_addition_info
    where
        ord_main.ord_no = @ordNo
),
treatment_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = ''MED''
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''TREATMENT_ITEM''
)
select
    ROW_NUMBER() over(
        order by
            cast(code as character varying)
    ) AS seq_no,
    (
        case
            (
                select
                    value
                from
                    treatment_item_value
            )
            when ''1'' then left(mst_addition.in_hospital_cd_1, 20)
            when ''2'' then left(mst_addition.in_hospital_cd_2, 20)
            when ''3'' then left(mst_addition.in_hospital_cd_3, 20)
        end
    ) as code,
    left(mst_addition.addition_name, 256) as name
from
    ord_main_info,
    mst_addition
where
    ord_main_info.code = cast(mst_addition.addition_cd as character varying)
    and mst_addition.addition_class = ''1''', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307069, 'SELECT
    ''19'' AS detail_idd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307070, 'with ord_main_info as(
    select
        ord_addition_info ->> ''cd'' as code
    from
        ord_main
        cross join lateral json_array_elements(ord_main.addition_info :: json) ord_addition_info
    where
        ord_main.ord_no = @ordNo
),
treatment_item_value as(
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as VALUE
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = ''MED''
        and info ->> ''key1'' = ''RST_DIAL''
        and info ->> ''key2'' = ''TREATMENT_ITEM''
)
select
    ROW_NUMBER() over(
        order by
            cast(code as character varying)
    ) AS seq_no,
    (
        case
            (
                select
                    value
                from
                    treatment_item_value
            )
            when ''1'' then left(mst_addition.in_hospital_cd_1, 20)
            when ''2'' then left(mst_addition.in_hospital_cd_2, 20)
            when ''3'' then left(mst_addition.in_hospital_cd_3, 20)
        end
    ) as code,
    left(mst_addition.addition_name, 256) as name
from
    ord_main_info,
    mst_addition
where
    ord_main_info.code = cast(mst_addition.addition_cd as character varying)
    and mst_addition.addition_class = ''1''', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307071, 'SELECT
    ''20'' AS detail_idd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307073, 'SELECT
    ''21'' AS detail_idd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
