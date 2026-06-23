DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (1716);
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (9615);
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (1303);
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (1013);
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (1401);
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (7104);


INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1716, 'WITH
isDie AS (
  SELECT CASE WHEN ''@isDie''<> ''1''
            	THEN 0 
							ELSE 1
				 END AS is_die
)
,inOutClass AS (
  SELECT (CASE WHEN ''@inOutClass'' = ''1''
						   THEN ''1''
						   ELSE ''0'' 
				  END) AS inOut
)
, date_exist_info AS (
  -- 既存データの日付は存在するかどうか
  (
	SELECT
		1 AS exist_flg
  FROM
    pat_unique patu
    CROSS JOIN LATERAL json_array_elements ( patu.in_out_visit_history_info :: json ) AS info 
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
		AND info->>''move_in_out'' = ''1''
		AND info->>''period_start'' = replace(''@syoriDate'', ''/'', '''')
	)
		UNION
	(
	SELECT
		0 AS exist_flg
	)
	ORDER BY exist_flg DESC
	LIMIT 1
)
, max_date_info AS (
  -- 既存データの日付は取り込む日付より大きいデータを取得する
  (SELECT
		1 AS num,
    info->>''period_start'' AS max_date
  FROM
    pat_unique patu
    CROSS JOIN LATERAL json_array_elements ( patu.in_out_visit_history_info :: json ) AS info 
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
  ORDER BY info->>''period_start'' DESC, ((info->>''ctl_no'') :: INTEGER) DESC LIMIT 1)
		UNION
	(SELECT
		2 AS num,
	  ''00000000'' AS max_date)
	ORDER BY num
	LIMIT 1
)
, min_date_info AS (
  -- 既存データの日付は取り込む日付より小さいデータを取得する
  (SELECT
		1 AS num,
    info->>''period_start'' AS min_date
  FROM
    pat_unique patu
    CROSS JOIN LATERAL json_array_elements ( patu.in_out_visit_history_info :: json ) AS info 
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
  ORDER BY info->>''period_start'', ((info->>''ctl_no'') :: INTEGER) LIMIT 1)
		UNION
	(SELECT
		2 AS num,
	  ''00000000'' AS min_date)
	ORDER BY num
	LIMIT 1
)
,data_new_info AS (
  SELECT 
    null AS ctl_no,
    (CASE (replace(''@syoriDate'', ''/'', '''') < mind.min_date OR replace(''@syoriDate'', ''/'', '''') > maxd.max_date) 
		     WHEN true 
				 THEN io.inOut
				 ELSE (  SELECT
										((info->>''in_out'')::TEXT) AS in_out
									FROM
										pat_unique patu
										CROSS JOIN LATERAL json_array_elements ( patu.in_out_visit_history_info :: json ) AS info 
									WHERE
										pat_id = @patId 
										AND facility_cd = ''@facilityCd'' 
										AND is_del = ''0'' 
										AND info->>''period_start'' <= replace(''@syoriDate'', ''/'', '''')
									ORDER BY info->>''period_start'' DESC, ((info->>''ctl_no'') :: INTEGER) DESC LIMIT 1)
		END ) :: TEXT AS in_out, 
    null AS reason,
    null AS to_course,
    null AS to_doctor,
    0 AS disp_order,
    null AS period_end,
    NULLIF(''@facilityCd'', '''') AS facility_cd,
    null AS from_course,
    null AS from_doctor,
    ''1'' :: TEXT AS move_in_out,
    null AS to_facility,
    replace(''@syoriDate'', ''/'', '''') AS period_start,
    null AS from_facility,
    ''0'' AS course_is_free,
    ''0'' AS doctor_is_free,
    null AS period_end_day,
    null AS period_end_year,
    ''0'' AS facility_is_free,
    null AS period_end_month,
    SUBSTR(replace(''@syoriDate'', ''/'', ''''), 7, 2) AS period_start_day,
    replace(''@syoriDate'', ''/'', '''') AS period_start_date,
    SUBSTR(replace(''@syoriDate'', ''/'', ''''), 1, 4) AS period_start_year,
    SUBSTR(replace(''@syoriDate'', ''/'', ''''), 5, 2) AS period_start_month,
    ''0'' AS period_end_input_free,
    ''0'' AS period_start_input_free,
    null AS to_medicalInstitutionCd,
    null AS from_medicalInstitutionCd
	  from inOutClass io, max_date_info maxd, min_date_info mind
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
)
, json_data AS (
  SELECT json_build_object(
    ''ctl_no'', row_number() over(order by order_no DESC, ctl_no ASC),
    ''in_out'' , (in_out :: INTEGER),
    ''reason'' , reason,
    ''to_course'' , (to_course :: INTEGER),
    ''to_doctor'' , (to_doctor :: INTEGER),
    ''disp_order'' , (disp_order :: INTEGER),
    ''period_end'' , period_end,
    ''facility_cd'' , facility_cd,
    ''from_course'' , (from_course :: INTEGER),
    ''from_doctor'' , (from_doctor :: INTEGER),
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
	AND (SELECT is_die FROM isDie) <> 1
	AND (SELECT exist_flg FROM date_exist_info) = 0 ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル_固有情報_入外・転入出情報(死亡以外)・導入', '2022-06-22 08:26:30.149', CURRENT_TIMESTAMP, NULL);

INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9615, 'with infectValue as (select (case
                                 when ''@infectInfo.infect'' = ''0''
                                     or ''@infectInfo.infect'' = ''1''
                                     or ''@infectInfo.infect'' = ''2''
                                     then ''@infectInfo.infect''
                                 else ''0'' end) as infectValue),
     examDate as (select to_char(to_date(''@infectInfo.examDate_Date'', ''yyyy-mm-dd''), ''yyyymmdd'') as examDate),
     changeOrNot as (select (case
                                 when (infectValue.infectValue <> coalesce(t0.infect, '''') or examDate.examDate <> coalesce(t0.exam_date, ''''))
                                     then true
                                 else false end) as res
                     from (select value ->> ''infect'' as infect, value ->> ''exam_date'' as exam_date
                           FROM pat_main,
                               jsonb_array_elements(infect_info) WITH ORDINALITY
                           WHERE is_del = ''0''
                             AND pat_id = @patId
                             AND value ->> ''infection_cd'' = ''@infectInfo.infectionCd'') t0,
                          infectValue,
                          examDate)
update pat_main
set 
	up_date = CURRENT_TIMESTAMP,
	infect_info = (case when ''@infectInfo.infectionCd'' != '''' and changeOrNot.res then jsonb_set(
        infect_info,
        array [
            (select ORDINALITY::INT - 1
             FROM pat_main d2,
                 jsonb_array_elements(infect_info) WITH ORDINALITY
             WHERE is_del = ''0''
               AND pat_id = @patId
               AND value ->> ''infection_cd'' = ''@infectInfo.infectionCd'')::text,
            ''exam_date''
            ],
        cast(''"''|| examDate.examDate ||''"'' as text)::jsonb
    ) else infect_info end)
from infectValue,
     changeOrNot,
     examDate
WHERE is_del = ''0''
  AND pat_id = @patId
  and facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(感染症情報)', '2022-06-08 00:56:38.271', CURRENT_TIMESTAMP, NULL);

INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1303, 'update pat_insurance set
  ctl_no = case ''@ctlNo''
             when '''' then null
             else to_number(''@ctlNo'',''99999999999999999999999999999999'')
           end,
  fn_pat_id = NULLIF(''@fnPatId'',''''),
  insu_class = case ''@insuClass''
                 when '''' then null
                 else to_number(''@insuClass'',''99999999999999999999999999999999'')
               end,
  insu_name = NULLIF(TRIM(''@insuName'', ''　''),''''),
  insu_name_short = NULLIF(''@insuNmShort'',''''),
  insu_info = case ''@insuInfoFlg''
                when '''' then ''@insuInfoValue''
                else json_build_object(''insu_pat_name'',NULLIF(''@insuInfo.insuPatName'',''''),''insu_no'',NULLIF(''@insuInfo.insuNo'',''''),''insu_kbn'',NULLIF(''@insuInfo.insuKbn'',''''),''insu_pat_mark'',NULLIF(''@insuInfo.insuPatMark'',''''),''insu_pat_no'',NULLIF(''@insuInfo.insuPatNo'',''''),''cki_class'',NULLIF(''@insuInfo.ckiClass'',''''),''kki_class'',NULLIF(''@insuInfo.kkiClass'',''''),''und_six'',NULLIF(''@insuInfo.undSix'',''''),''futan-g'',NULLIF(''@insuInfo.futan-g'',''''),''futan-n'',NULLIF(''@insuInfo.futan-n'',''''))
              end,
  insu_pub_info = case ''@insuPubInfoFlg''
                    when '''' then ''@insuPubInfoValue''
                    else json_build_object(''insu_pub_name'',NULLIF(''@insuPubInfo.insuPubName'',''''),''insu_pub_no'',NULLIF(''@insuPubInfo.insuPubNo'',''''),''insu_pub_pat_no'',NULLIF(''@insuPubInfo.insuPubPatNo'',''''))
                  end,
  insu_set_info = case ''@insuSetInfoFlg''
                    when '''' then ''@insuSetInfoValue''
                    else json_build_object(''insu_cd'',NULLIF(''@insuSetInfo.insuCd'',''''),''insu_pub1_cd'',NULLIF(''@insuSetInfo.insuPub1Cd'',''''),''insu_pub2_cd'',NULLIF(''@insuSetInfo.insuPub2Cd'',''''),''insu_pub3_cd'',NULLIF(''@insuSetInfo.insuPub3Cd'',''''),''insu_pub4_cd'',NULLIF(''@insuSetInfo.insuPub4Cd'',''''))
                  end,
  insu_self_info = null,
  is_selected = NULLIF(''@isSelected'',''''),
  is_disp = NULLIF(''@isDisp'',''''),
  coop_code = NULLIF(''@coopCode'',''''),
  is_coop = NULLIF(''@isCoop'',''''),
  up_date = CURRENT_TIMESTAMP,
  start_date = NULLIF(''@startDate'',''''),
  end_date = NULLIF(''@endDate'',''''),
  check_date = NULLIF(''@checkDate'',''''),
  old_up_date = case ''@oldUpDate_Date''
                  when '''' then null
                  else to_timestamp(''@oldUpDate_Date'',''yyyy-MM-dd hh24:mi:ss'')
                end
where
  pat_id = @patId
and
  facility_cd = ''@facilityCd''
and
  is_del = ''0''
and
  ctl_no = @ctlNo', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1013, 'WITH name_info AS ( 
  SELECT
    ''@patLastName'' ::TEXT AS patLastName
    , ''@patFirstName'' ::TEXT AS patFirstName
    , ''@patLastNmKana'' ::TEXT AS patLastNmKana
    , ''@patFirstNmKana'' ::TEXT AS patFirstNmKana
) 
, Blood_info AS ( 
  SELECT
    ''@patBloodTypeRh'' ::TEXT AS patBloodTypeRh
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
  , hosp_pat_id = NULLIF(''@hospPatId'', '''')
  , nkk_pat_id = NULLIF(''@nkkPatId'', '''')
  , facility_cd = NULLIF(''@facilityCd'', '''')
  , pat_last_name = personal_info_encrypt((SELECT patLastName FROM new_name_info))
  , pat_first_name = COALESCE(personal_info_encrypt(NULLIF((SELECT patFirstName FROM new_name_info), '''')) , pat_first_name) 
  , pat_last_name_kana = personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
  , pat_first_name_kana = COALESCE(personal_info_encrypt(NULLIF((SELECT patFirstNmKana FROM new_name_info), '''')) , pat_first_name_kana) 
  , pat_last_name_alpha = NULLIF(''@patLastNmAlpha'', '''')
  , pat_first_name_alpha = NULLIF(''@patFirstNmAlpha'', '''')
  , pat_birth_name = NULLIF(''@patBirthName'', '''')
  , pat_birth_name_kana = NULLIF(''@patBirthNmKana'', '''')
  , pat_birth_name_alpha = NULLIF(''@patBirthNmAlpha'', '''')
  , pat_birthday = NULLIF(TRIM(REPLACE(''@patBirthday'',''/'','''' )), '''')
  , pat_sex = TO_NUMBER(''@outPatSex'', ''FM9999999999999999'') 
  , nationality = NULLIF(''@nationality'', '''')
  , pat_blood_type_abo = TO_NUMBER(''@patBloodAboType'', ''FM9999999999999999'') 
  , pat_blood_type_rh = TO_NUMBER(''@patBloodRhType'', ''FM9999999999999999'') 
  , pat_blood_type_serovar = CASE ''@patBloodTypeSerovar'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeSerovar'', ''FM9999999999999999'') 
    END
  , in_out_class = TO_NUMBER(''@outInOutClass'', ''FM9999999999999999'') 
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
  , vendor_contact_info = ''@vendorContactInfoValue''
  , insurance_info = ''@insuranceInfoValue''
  , reg_date = ''@regDate''
  , up_date = CURRENT_TIMESTAMP
  , primary_disease_cd = CASE ''@primaryDiseaseCd'' 
    WHEN '''' THEN NULL 
    ELSE (CASE WHEN ''@upBaseDiseaseFlg'' = ''0'' THEN NULL ELSE TO_NUMBER(''@primaryDiseaseCd'', ''FM99999999999999999999999999999999'') END) 
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
  AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装)患者プロファイル(profile)(XML):患者個人情報の取得の修正', '2022-06-13 08:34:44.813', CURRENT_TIMESTAMP, '[{"sql_cd": 1009, "field_name": "up_base_disease_flg", "replace_var": "@upBaseDiseaseFlg"}, {"sql_cd": 1010, "field_name": "check_value", "replace_var": "@patBloodRhType"}, {"sql_cd": 1011, "field_name": "check_value", "replace_var": "@patBloodAboType"}, {"sql_cd": 1014, "field_name": "check_value", "replace_var": "@outPatSex"}, {"sql_cd": 1015, "field_name": "check_value", "replace_var": "@outInOutClass"}]');

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1401, 'select
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
  hosp_pat_id = @hospPatId
and
  facility_cd = @facilityCd', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7104, 'SELECT dialysis_difficulty_cd as dialysis_difficulty_cd_no FROM mst_dialysis_difficulty WHERE  in_hospital_cd_1 = @dialDiffComInfo.dialDiffCd AND facility_cd = ''@facilityCd''
union
select 0 as dialysis_difficulty_cd_no
order by dialysis_difficulty_cd_no desc nulls last
limit 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の取得', '2022-06-27 12:39:22.557', CURRENT_TIMESTAMP, NULL);









