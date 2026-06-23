DELETE FROM
  "ntss"."sys_data_set"
WHERE
  sql_cd IN (1012,1013,7102,9621);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(1012, 'WITH name_info AS (SELECT ''@patLastName'' ::TEXT    AS patLastName
                        , ''@patFirstName'' ::TEXT   AS patFirstName
                        , ''@patLastNmKana'' ::TEXT  AS patLastNmKana
                        , ''@patFirstNmKana'' ::TEXT AS patFirstNmKana)
   , tmp_index_info AS (SELECT COALESCE(NULLIF(POSITION(''　'' IN patLastName), 0), LENGTH(patLastName) + 1)       AS indexLast1
                             , COALESCE(NULLIF(POSITION('' '' IN patLastName), 0), LENGTH(patLastName) +
                                                                                 1)                             AS indexLast2
                             , COALESCE(NULLIF(POSITION(''　'' IN patFirstName), 0), LENGTH(patFirstName) +
                                                                                  1)                            AS indexFirst1
                             , COALESCE(NULLIF(POSITION('' '' IN patFirstName), 0), LENGTH(patFirstName) +
                                                                                  1)                            AS indexFirst2
                             , COALESCE(NULLIF(POSITION(''　'' IN patLastNmKana), 0), LENGTH(patLastNmKana) +
                                                                                   1)                           AS indexLastK1
                             , COALESCE(NULLIF(POSITION('' '' IN patLastNmKana), 0), LENGTH(patLastNmKana) +
                                                                                   1)                           AS indexLastK2
                             , COALESCE(NULLIF(POSITION(''　'' IN patFirstNmKana), 0), LENGTH(patFirstNmKana) +
                                                                                    1)                          AS indexFirstK1
                             , COALESCE(NULLIF(POSITION('' '' IN patFirstNmKana), 0), LENGTH(patFirstNmKana) +
                                                                                    1)                          AS indexFirstK2
                        FROM name_info)
   , index_info AS (SELECT CASE
                               WHEN indexLast1 > indexLast2
                                   THEN indexLast2
                               ELSE indexLast1
    END     AS indexLast
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
                    FROM tmp_index_info)
   , new_name_info AS (SELECT TRIM(TRIM(TRIM(SUBSTRING(patLastName, 1, indexLast - 1)), ''　''))    AS patLastName
                            , TRIM(TRIM(TRIM(SUBSTRING(patFirstName, indexFirst + 1)), ''　''))     AS patFirstName
                            , TRIM(TRIM(TRIM(SUBSTRING(patLastNmKana, 1, indexLastK - 1)), ''　'')) AS patLastNmKana
                            , TRIM(TRIM(TRIM(SUBSTRING(patFirstNmKana, indexFirstK + 1)), ''　''))  AS patFirstNmKana
                       FROM name_info,
                            index_info)
INSERT
INTO pat_personal_main( fn_pat_id
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
                      , remote_monitor_user_pw)
VALUES ( NULLIF(''@fnPatId'', '''')
       , NULLIF(''@hospPatId'', '''')
       , NULLIF(''@nkkPatId'', '''')
       , NULLIF(''@facilityCd'', '''')
       , personal_info_encrypt((SELECT patLastName FROM new_name_info))
       , coalesce(personal_info_encrypt((SELECT patFirstName FROM new_name_info)), '''')
       , personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
       , personal_info_encrypt((SELECT patFirstNmKana FROM new_name_info))
       , NULLIF(''@patLastNmAlpha'', '''')
       , NULLIF(''@patFirstNmAlpha'', '''')
       , NULLIF(''@patBirthName'', '''')
       , NULLIF(''@patBirthNmKana'', '''')
       , NULLIF(''@patBirthNmAlpha'', '''')
       , NULLIF(TRIM(REPLACE(''@patBirthday'', ''/'', '''')), '''')
       , TO_NUMBER(''@patSexOut'', ''FM9999999999999999'')
       , NULLIF(''@nationality'', '''')
       , TO_NUMBER(''@patBloodAboType'', ''FM9999999999999999'')
       , TO_NUMBER(''@patBloodRhType'', ''FM9999999999999999'')
       , CASE ''@patBloodTypeSerovar''
             WHEN '''' THEN 0
             ELSE TO_NUMBER(''@patBloodTypeSerovar'', ''FM9999999999999999'')
             END
       , TO_NUMBER(''@inOutClassOut'', ''FM9999999999999999'')
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
                 , REPLACE(NULLIF(''@patContactInfo.zipCd'', ''''), ''-'', '''')
                 , ''address''
                 , NULLIF((TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　'') ||
                           TRIM(TRIM(TRIM(''@patContactInfo.detailsAddress'', ''　''), '' ''), ''　'')), '''')
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
       , NULLIF(''@remoteMonitorUserPw'', ''''))', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)日機装)患者プロファイル(profile)(XML):患者個人情報の取得の新規', '2022-06-13 08:34:44.813', CURRENT_TIMESTAMP, '[{"sql_cd": 1001, "field_name": "dial_diff_com_info", "replace_var": "@dialDiffComInfo"}, {"sql_cd": 1010, "field_name": "check_value", "replace_var": "@patBloodRhType"}, {"sql_cd": 1011, "field_name": "check_value", "replace_var": "@patBloodAboType"}, {"sql_cd": 1014, "field_name": "check_value", "replace_var": "@patSexOut"}, {"sql_cd": 1015, "field_name": "check_value", "replace_var": "@inOutClassOut"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(1013, 'WITH name_info AS (SELECT ''@patLastName'' ::TEXT    AS patLastName
                        , ''@patFirstName'' ::TEXT   AS patFirstName
                        , ''@patLastNmKana'' ::TEXT  AS patLastNmKana
                        , ''@patFirstNmKana'' ::TEXT AS patFirstNmKana)
   , Blood_info AS (SELECT ''@patBloodTypeRh'' ::TEXT AS patBloodTypeRh)
   , tmp_index_info AS (SELECT COALESCE(NULLIF(POSITION(''　'' IN patLastName), 0), LENGTH(patLastName) + 1)       AS indexLast1
                             , COALESCE(NULLIF(POSITION('' '' IN patLastName), 0), LENGTH(patLastName) +
                                                                                 1)                             AS indexLast2
                             , COALESCE(NULLIF(POSITION(''　'' IN patFirstName), 0), LENGTH(patFirstName) +
                                                                                  1)                            AS indexFirst1
                             , COALESCE(NULLIF(POSITION('' '' IN patFirstName), 0), LENGTH(patFirstName) +
                                                                                  1)                            AS indexFirst2
                             , COALESCE(NULLIF(POSITION(''　'' IN patLastNmKana), 0), LENGTH(patLastNmKana) +
                                                                                   1)                           AS indexLastK1
                             , COALESCE(NULLIF(POSITION('' '' IN patLastNmKana), 0), LENGTH(patLastNmKana) +
                                                                                   1)                           AS indexLastK2
                             , COALESCE(NULLIF(POSITION(''　'' IN patFirstNmKana), 0), LENGTH(patFirstNmKana) +
                                                                                    1)                          AS indexFirstK1
                             , COALESCE(NULLIF(POSITION('' '' IN patFirstNmKana), 0), LENGTH(patFirstNmKana) +
                                                                                    1)                          AS indexFirstK2
                        FROM name_info)
   , index_info AS (SELECT CASE
                               WHEN indexLast1 > indexLast2
                                   THEN indexLast2
                               ELSE indexLast1
    END     AS indexLast
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
                    FROM tmp_index_info)
   , new_name_info AS (SELECT TRIM(TRIM(TRIM(SUBSTRING(patLastName, 1, indexLast - 1)), ''　''))    AS patLastName
                            , TRIM(TRIM(TRIM(SUBSTRING(patFirstName, indexFirst + 1)), ''　''))     AS patFirstName
                            , TRIM(TRIM(TRIM(SUBSTRING(patLastNmKana, 1, indexLastK - 1)), ''　'')) AS patLastNmKana
                            , TRIM(TRIM(TRIM(SUBSTRING(patFirstNmKana, indexFirstK + 1)), ''　''))  AS patFirstNmKana
                       FROM name_info,
                            index_info)
UPDATE pat_personal_main
SET fn_pat_id              = NULLIF(''@fnPatId'', '''')
  , hosp_pat_id            = NULLIF(''@hospPatId'', '''')
  , nkk_pat_id             = NULLIF(''@nkkPatId'', '''')
  , facility_cd            = NULLIF(''@facilityCd'', '''')
--   , pat_last_name = personal_info_encrypt((SELECT patLastName FROM new_name_info))
--   , pat_first_name = COALESCE(personal_info_encrypt(NULLIF((SELECT patFirstName FROM new_name_info), '''')) , pat_first_name)
  , pat_last_name          =
    case
        when (''@patLastName'' like ''% %'') then (SELECT personal_info_encrypt(patLastName) FROM new_name_info)
        when (((SELECT concat(patLastName, patFirstName) FROM new_name_info) =
               concat(personal_info_decrypt(pat_last_name), personal_info_decrypt(pat_first_name))) and
              (''@patLastName'' not like ''% %'')) then pat_last_name
        when ((SELECT concat(patLastName, patFirstName) FROM new_name_info) !=
              concat(personal_info_decrypt(pat_last_name), personal_info_decrypt(pat_first_name)) and
              (''@patLastName'' not like ''% %''))
            then (SELECT personal_info_encrypt(concat(patLastName, patFirstName)) FROM new_name_info) end
  , pat_first_name         = case
                                 when (''@patFirstName'' like ''% %'')
                                     then (SELECT personal_info_encrypt(patFirstName) FROM new_name_info)
                                 when ((SELECT concat(patLastName, patFirstName) FROM new_name_info) =
                                       concat(personal_info_decrypt(pat_last_name),
                                              personal_info_decrypt(pat_first_name)) and
                                       (''@patFirstName'' not like ''% %'')) then pat_first_name
                                 when ((SELECT concat(patLastName, patFirstName) FROM new_name_info) !=
                                       concat(personal_info_decrypt(pat_last_name),
                                              personal_info_decrypt(pat_first_name)) and
                                       (''@patFirstName'' not like ''% %'')) then '''' end
--   , pat_last_name_kana = personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
--   , pat_first_name_kana = COALESCE(personal_info_encrypt(NULLIF((SELECT patFirstNmKana FROM new_name_info), '''')) , pat_first_name_kana)
  , pat_last_name_kana     =
    case
        when (''@patLastNmKana'' like ''% %'') then (SELECT personal_info_encrypt(patLastNmKana) FROM new_name_info)
        when (((SELECT concat(patLastNmKana, patFirstNmKana) FROM new_name_info) =
               concat(personal_info_decrypt(pat_last_name_kana), personal_info_decrypt(pat_first_name_kana))) and
              (''@patLastNmKana'' not like ''% %'')) then pat_last_name_kana
        when ((SELECT concat(patLastNmKana, patFirstNmKana) FROM new_name_info) !=
              concat(personal_info_decrypt(pat_last_name_kana), personal_info_decrypt(pat_first_name_kana)) and
              (''@patLastNmKana'' not like ''% %''))
            then (SELECT personal_info_encrypt(concat(patLastNmKana, patFirstNmKana)) FROM new_name_info) end
  , pat_first_name_kana    = case
                                 when (''@patFirstNmKana'' like ''% %'')
                                     then (SELECT personal_info_encrypt(patFirstNmKana) FROM new_name_info)
                                 when ((SELECT concat(patLastNmKana, patFirstNmKana) FROM new_name_info) =
                                       concat(personal_info_decrypt(pat_last_name_kana),
                                              personal_info_decrypt(pat_first_name_kana)) and
                                       (''@patFirstNmKana'' not like ''% %'')) then pat_first_name_kana
                                 when ((SELECT concat(patLastNmKana, patFirstNmKana) FROM new_name_info) !=
                                       concat(personal_info_decrypt(pat_last_name_kana),
                                              personal_info_decrypt(pat_first_name_kana)) and
                                       (''@patFirstNmKana'' not like ''% %'')) then NULL end
  , pat_last_name_alpha    = NULLIF(''@patLastNmAlpha'', '''')
  , pat_first_name_alpha   = NULLIF(''@patFirstNmAlpha'', '''')
  , pat_birth_name         = NULLIF(''@patBirthName'', '''')
  , pat_birth_name_kana    = NULLIF(''@patBirthNmKana'', '''')
  , pat_birth_name_alpha   = NULLIF(''@patBirthNmAlpha'', '''')
  , pat_birthday           = NULLIF(TRIM(REPLACE(''@patBirthday'', ''/'', '''')), '''')
  , pat_sex                = TO_NUMBER(''@outPatSex'', ''FM9999999999999999'')
  , nationality            = NULLIF(''@nationality'', '''')
  , pat_blood_type_abo     = TO_NUMBER(''@patBloodAboType'', ''FM9999999999999999'')
  , pat_blood_type_rh      = TO_NUMBER(''@patBloodRhType'', ''FM9999999999999999'')
  , pat_blood_type_serovar = CASE ''@patBloodTypeSerovar''
                                 WHEN '''' THEN 0
                                 ELSE TO_NUMBER(''@patBloodTypeSerovar'', ''FM9999999999999999'')
    END
  , in_out_class           = TO_NUMBER(''@outInOutClass'', ''FM9999999999999999'')
  , is_die                 = NULLIF(''@isDie'', '''')
  , die_cd                 = CASE ''@dieCd''
                                 WHEN '''' THEN NULL
                                 ELSE TO_NUMBER(''@dieCd'', ''FM99999999999999999999999999999999'')
    END
  , die_date               = CASE ''@dieDate_Date''
                                 WHEN '''' THEN NULL
                                 ELSE TO_TIMESTAMP(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS'')
    END
  , dial_diff_com_info     = ''@dialDiffComInfoValue''
  , severity_cd            = CASE ''@severityCd''
                                 WHEN '''' THEN NULL
                                 ELSE TO_NUMBER(''@severityCd'', ''FM99999999999999999999999999999999'')
    END
  , transport_cd           = CASE ''@transportCd''
                                 WHEN '''' THEN NULL
                                 ELSE TO_NUMBER(''@transportCd'', ''FM99999999999999999999999999999999'')
    END
  , pat_contact_info       = CASE ''@patContactInfoFlg''
                                 WHEN '''' THEN ''@patContactInfoValue''
                                 ELSE json_build_object(
                                         ''zip_cd''
                                     , REPLACE(NULLIF(''@patContactInfo.zipCd'', ''''), ''-'', '''')
                                     , ''address''
                                     , NULLIF((TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　'')), '''')
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
  , vendor_contact_info    = ''@vendorContactInfoValue''
  , insurance_info         = ''@insuranceInfoValue''
  , reg_date               = ''@regDate''
  , up_date                = CURRENT_TIMESTAMP
  , primary_disease_cd     = CASE ''@primaryDiseaseCd''
                                 WHEN '''' THEN NULL
                                 ELSE (CASE
                                           WHEN ''@upBaseDiseaseFlg'' = ''0'' THEN NULL
                                           ELSE TO_NUMBER(''@primaryDiseaseCd'', ''FM99999999999999999999999999999999'') END)
    END
  , remote_monitor_service = CASE ''@remoteMonitorService''
                                 WHEN '''' THEN NULL
                                 ELSE TO_NUMBER(''@remoteMonitorService'', ''FM99999999999999999999999999999999'')
    END
  , remote_monitor_user_id = NULLIF(''@remoteMonitorUserId'', '''')
  , remote_monitor_user_pw = NULLIF(''@remoteMonitorUserPw'', '''')
WHERE is_del = ''0''
  AND hosp_pat_id = ''@hospPatId''
  AND facility_cd = ''@facilityCd''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)日機装)患者プロファイル(profile)(XML):患者個人情報の取得の修正', '2022-06-13 08:34:44.813', CURRENT_TIMESTAMP, '[{"sql_cd": 1009, "field_name": "up_base_disease_flg", "replace_var": "@upBaseDiseaseFlg"}, {"sql_cd": 1010, "field_name": "check_value", "replace_var": "@patBloodRhType"}, {"sql_cd": 1011, "field_name": "check_value", "replace_var": "@patBloodAboType"}, {"sql_cd": 1014, "field_name": "check_value", "replace_var": "@outPatSex"}, {"sql_cd": 1015, "field_name": "check_value", "replace_var": "@outInOutClass"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(7102, 'with origin_pat_contact_info as (select t.info ->> ''fax''       as fax,
                                        t.info ->> ''e_mail''    as e_mail,
                                        t.info ->> ''work_name'' as work_name,
                                        t.info ->> ''work_tel''  as work_tel,
                                        t.info ->> ''memo1''     as memo1,
                                        t.info ->> ''memo2''     as memo2
                                 from (select personal_info_decrypt_jsonb(pat_contact_info) as info
                                       from pat_personal_main
                                       WHERE is_del = ''0''
                                         AND hosp_pat_id = ''@hospPatId''
                                         AND facility_cd = ''@facilityCd'') t),
     nameSplit as (select split_part(''@otherContactInfo.lastName'', '' '', 1) as lastName,
                          split_part(''@otherContactInfo.lastName'', '' '', 2) as firstName),
     dup as (select (case when count(1) >= 1 then 1 else 0 end) as checkDup
             FROM pat_personal_main
                      CROSS JOIN jsonb_array_elements(personal_info_decrypt_jsonb(other_contact_info)) WITH ORDINALITY arr(j, idx),
                  nameSplit
             WHERE is_del = ''0''
               AND hosp_pat_id = ''@hospPatId''
               and (((j ->> ''first_name'')::text = nameSplit.firstName
               and (j ->> ''last_name'')::text = nameSplit.lastName)
    or (''@otherContactInfo.lastName'' not like ''% %'' and concat((j ->> ''last_name'')::text,(j ->> ''first_name'')::text)=''@otherContactInfo.lastName'')))
    , replaceZipCd as (
        select
            REPLACE(NULLIF(''@otherContactInfo.zipCd'', ''''), ''-'', '''') as zipCd
    )
UPDATE pat_personal_main
SET up_date            = CURRENT_TIMESTAMP,
    other_contact_info = (CASE
        ''@otherContactInfoFlg''
                              WHEN '''' THEN
                                  ''@otherContactInfoValue''
                              ELSE (case
                                        when ''@otherContactInfo.relationName'' <> ''本人'' and dup.checkDup = ''0'' then
                                                other_contact_info || jsonb_build_object(
                                                    ''ctl_no'', ''@otherContactInfo.ctlNo''
                                                , ''disp_order'', ''@otherContactInfo.dispOrder''
                                                , ''is_key_person'', ''@otherContactInfo.isKeyPerson''
                                                , ''pat_id'', ''@otherContactInfo.patId''
                                                , ''last_name'', nameSplit.lastName 
                                                , ''first_name'', nameSplit.firstName 
                                                , ''last_name_kana'', ''@otherContactInfo.lastNmKana''
                                                , ''first_name_kana'', ''@otherContactInfo.firstNmKana''
                                                , ''relation_cd'', CASE ''@relationCd''
                                                                     WHEN ''@'' || ''relationCd'' THEN null
                                                                     ELSE ''@relationCd'' END
                                                , ''relation_name'', ''@otherContactInfo.relationName''
                                                , ''zip_cd'', replaceZipCd.zipCd
                                                , ''address'', ''@otherContactInfo.address''
                                                , ''e_mail'', ''@otherContactInfo.eMail''
                                                , ''work_name'', ''@otherContactInfo.workName''
                                                , ''work_tel'', ''@otherContactInfo.workTel''
                                                , ''tel1'', ''@otherContactInfo.tel1''
                                                , ''tel2'', ''@otherContactInfo.tel2''
                                                , ''fax'', ''@otherContactInfo.fax''
                                                , ''memo1'', ''@otherContactInfo.memo1''
                                                , ''memo2'', ''@otherContactInfo.memo2''
                                                )
                                        else ''@otherContactInfoValue'' end)
        END)::jsonb,
    pat_contact_info   = (CASE
                              when
                                  ''@otherContactInfoFlg'' <> '''' and ''@otherContactInfo.relationName'' = ''本人''
                                  THEN
                                  jsonb_build_object(
                                          ''zip_cd''
                                      , replaceZipCd.zipCd
                                      , ''address''
                                      , NULLIF((TRIM(TRIM(TRIM(''@otherContactInfo.address'', ''　''), '' ''), ''　'')), '''')
                                      , ''tel1''
                                      , NULLIF(''@otherContactInfo.tel1'', '''')
                                      , ''tel2''
                                      , NULLIF(''@otherContactInfo.tel2'', '''')
                                      , ''fax''
                                      , NULLIF(opci.fax, '''')
                                      , ''e_mail''
                                      , NULLIF(opci.e_mail, '''')
                                      , ''work_name''
                                      , NULLIF(opci.work_name, '''')
                                      , ''work_address''
                                      , NULLIF(''@otherContactInfo.workAddress'', '''')
                                      , ''work_tel''
                                      , NULLIF(opci.work_tel, '''')
                                      , ''memo1''
                                      , NULLIF(opci.memo1, '''')
                                      , ''memo2''
                                      , NULLIF(opci.memo2, '''')
                                      )
                              ELSE pat_contact_info
        END)
from dup,
     nameSplit,
     origin_pat_contact_info opci,
     replaceZipCd
WHERE is_del = ''0''
  AND hosp_pat_id = ''@hospPatId''
  AND facility_cd = ''@facilityCd''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)日機装の患者プロファイル(連絡先情報)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": 9620, "field_name": "relation_cd", "replace_var": "@relationCd"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9621, 'with nameSplit as (select split_part(''@otherContactInfo.lastName'' ,'' '', 1) as lastName,
                          split_part(''@otherContactInfo.lastName'' ,'' '', 2) as firstName),
     oldInfo as (select (other_contact_info ->> (idx - 1)::int)::json AS oldInfo
                 FROM pat_personal_main CROSS JOIN jsonb_array_elements(personal_info_decrypt_jsonb(other_contact_info)) WITH ORDINALITY arr(j, idx), nameSplit 
                 WHERE  
             ((''@otherContactInfo.lastName''  like ''% %'' and (j ->> ''first_name'')::text = nameSplit.firstName
               and (j ->> ''last_name'')::text = nameSplit.lastName)
             or (''@otherContactInfo.lastName'' not like ''% %'' and concat((j ->> ''last_name'')::text,(j ->> ''first_name'')::text) 
						 = ''@otherContactInfo.lastName'')
						 )
                   and is_del = ''0''
                   AND hosp_pat_id = ''@hospPatId''
                   AND facility_cd = ''@facilityCd'' )	
     , replaceZipCd as (
        select
            REPLACE(NULLIF(''@otherContactInfo.zipCd'', ''''), ''-'', '''') as zipCd
    )							 
UPDATE pat_personal_main
SET 
	up_date = CURRENT_TIMESTAMP,
other_contact_info = REPLACE(other_contact_info::text, oldInfo.oldInfo::text, jsonb_build_object(
                 ''ctl_no'',''@otherContactInfo.ctlNo''
                 ,''disp_order'',''@otherContactInfo.dispOrder''
                 ,''is_key_person'',oldInfo.oldInfo ->> ''is_key_person''
                 ,''pat_id'',oldInfo.oldInfo ->> ''pat_id''
								 ,''last_name'', oldInfo.oldInfo ->> ''last_name'' 
                 ,''first_name'',oldInfo.oldInfo ->> ''first_name''
                 ,''last_name_kana'',oldInfo.oldInfo ->> ''last_name_kana''
                 ,''first_name_kana'',oldInfo.oldInfo ->> ''first_name_kana''
                 ,''relation_cd'',CASE ''@relationCd'' WHEN ''@''||''relationCd'' THEN null ELSE ''@relationCd'' END
                 ,''relation_name'',''@otherContactInfo.relationName''
                 ,''zip_cd'',replaceZipCd.zipCd
                 ,''address'',''@otherContactInfo.address''
                 ,''e_mail'',oldInfo.oldInfo ->> ''e_mail''
                 ,''work_name'',oldInfo.oldInfo ->> ''work_name''
                 ,''work_tel'',oldInfo.oldInfo ->> ''work_tel''
                 ,''tel1'',''@otherContactInfo.tel1''
                 ,''tel2'',''@otherContactInfo.tel2''
                 ,''fax'',oldInfo.oldInfo ->> ''fax''
                 ,''memo1'',oldInfo.oldInfo ->> ''memo1''
                 ,''memo2'',oldInfo.oldInfo ->> ''memo2''
)::text)::jsonb
from nameSplit,oldInfo,replaceZipCd
WHERE is_del = ''0''
  AND hosp_pat_id = ''@hospPatId''
  AND facility_cd = ''@facilityCd''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)日機装の患者プロファイル(連絡先情報)', '2022-06-27 12:39:15.173', CURRENT_TIMESTAMP, '[{"sql_cd": 9620, "field_name": "relation_cd", "replace_var": "@relationCd"}]'::jsonb);