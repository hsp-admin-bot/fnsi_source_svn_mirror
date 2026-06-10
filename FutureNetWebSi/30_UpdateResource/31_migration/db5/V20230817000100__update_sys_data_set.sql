DELETE FROM ntss.sys_data_set WHERE sql_cd in (7302,-132,-507,-110);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7302, 'with diseaseInfo as (select case ''@medicalHstInfo.diseaseCd''
                                when '''' then ''999999''
                                else ''@medicalHstInfo.diseaseCd'' end as diseaseCd),
     outComeInfo as (select case (select case when ''@isDie'' = ''1'' then ''10'' else ''@medicalHstInfo.outCome'' end)
                                when '''' then ''0'' end as outCome),
     currentTime as (select case (select case
                                             when ''@isDie'' = ''1'' then to_char(CURRENT_TIMESTAMP, ''YYYYMMDD'')
                                             else ''@medicalHstInfo.outComeDate'' end)
                                when '''' then '' ''
                                else ''@medicalHstInfo.outComeDate'' end as nowDate),
     medicalHstInfo
         as (select (case when medical_hst_info is null then ''[]''::jsonb else medical_hst_info end) as medical_hst_info
             from pat_unique
             where pat_id = @patId
               and facility_cd = ''@facilityCd''
               and is_del = ''0'')
update pat_unique
set up_date          = CURRENT_TIMESTAMP,
    medical_hst_info = (case ''@medicalHstInfoFlg''
                            when '''' then medicalHstInfo.medical_hst_info
                            else (CASE
                                      WHEN ''@upBaseDiseaseFlg'' = ''0'' and ''@isDie'' = '''' and
                                           ''@medicalHstInfo.diseaseDate'' <> ''''
                                          and ''@medicalHstInfo.diseaseCd'' <> ''''
                                          THEN replace(cast(medicalHstInfo.medical_hst_info as text),
                                                       ''"is_dialysis_underlying_disease": "1"'',
                                                       ''"is_dialysis_underlying_disease": "0"'')::jsonb
                                      ELSE medicalHstInfo.medical_hst_info END)
                                || case
                                       when (''@medicalHstInfo.diseaseCd'' <> '''' and ''@isDie'' = '''' and
                                             ''@medicalHstInfo.diseaseDate'' <> '''')
                                           or (''@isDie'' = ''1'' and ''@medicalHstInfo.diseaseDate'' <> '''')
                                           then jsonb_build_object(
                                               ''memo'', ''@medicalHstInfo.memo'',
                                               ''ctl_no'', ''@nextCtlNo2'',
                                               ''die_date'', ''@medicalHstInfo.dieDate'',
                                               ''out_come'', outComeInfo.outCome,
                                               ''course_cd'', ''@medicalHstInfo.courseCd'',
                                               ''is_notice'', ''@medicalHstInfo.isNotice'',
                                               ''disease_cd'', diseaseInfo.diseaseCd,
                                               ''disp_order'', ''@medicalHstInfo.dispOrder'',
                                               ''disease_day'',
                                               substr(replace(''@medicalHstInfo.diseaseDate'', ''/'', ''''), 7, 2),
                                               ''facility_cd'', ''@medicalHstInfo.facilityCd'',
                                               ''disease_date'', ''@medicalHstInfo.diseaseDate'',
                                               ''disease_year'',
                                               substr(replace(''@medicalHstInfo.diseaseDate'', ''/'', ''''), 1, 4),
                                               ''is_diagnosed'', ''@medicalHstInfo.isDiagnosed'',
                                               ''diagnosis_day'', ''@medicalHstInfo.diagnosisDay'',
                                               ''disease_month'',
                                               substr(replace(''@medicalHstInfo.diseaseDate'', ''/'', ''''), 5, 2),
                                               ''out_come_date'', currentTime.nowDate,
                                               ''course_is_free'', ''@medicalHstInfo.courseIsFree'',
                                               ''diagnosis_date'', ''@medicalHstInfo.diagnosisDate'',
                                               ''diagnosis_year'', ''@medicalHstInfo.diagnosisYear'',
                                               ''diagnosis_month'', ''@medicalHstInfo.diagnosisMonth'',
                                               ''is_main_disease'', ''@medicalHstInfo.isMainDisease'',
                                               ''diagnostician_cd'', ''@medicalHstInfo.diagnosticianCd'',
                                               ''diagnosis_facility_cd'', ''@medicalHstInfo.diagnosisFacilityCd'',
                                               ''diagnostician_is_free'', ''@medicalHstInfo.diagnosticianIsFree'',
                                               ''is_confirmation_biopsy'', ''@medicalHstInfo.isConfirmationBiopsy'',
                                               ''diagnosis_facility_is_free'', ''@medicalHstInfo.diagnosisFacilityIsFree'',
                                               ''is_dialysis_underlying_disease'', CASE
                                                                                     WHEN ''@upBaseDiseaseFlg'' = ''0'' and ''@isDie'' = ''''
                                                                                         THEN ''1''
                                                                                     ELSE ''0'' END)
                                       else ''[]''::jsonb end
        end)
from diseaseInfo,
     outComeInfo,
     currentTime,
     medicalHstInfo
where pat_id = @patId
  and facility_cd = ''@facilityCd''
  and is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(既往歴情報情報)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": 1009, "field_name": "up_base_disease_flg", "replace_var": "@upBaseDiseaseFlg"}]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-132, 'WITH ord_main_data AS ( 
   ( SELECT (to_number(ind_cond_info:: json ->''26'' ->> ''value'', ''9999.99'')+
to_number(ind_cond_info:: json ->''28'' ->> ''value'', ''9999.99''))::TEXT AS anti_coagulant_amount, pat_id
    FROM ord_main 
    WHERE ord_no = @ordNo)
		union 
				   ( SELECT (to_number(ind_cond_info:: json ->''26'' ->> ''value'', ''9999.99'')+
to_number(ind_cond_info:: json ->''28'' ->> ''value'', ''9999.99''))::TEXT AS anti_coagulant_amount, pat_id
    FROM ord_main_restore
    WHERE ord_no = @ordNo
		and (select count(1) from  ord_main 
    WHERE ord_no = @ordNo) = ''0''
		ORDER BY del_date desc limit 1)
)
, ini_data AS (
    SELECT COALESCE
        ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS default_setting 
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
    WHERE
        facility_cd = @facilityCd
     
        AND is_del = ''0''
                -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
                AND COALESCE(info ->> ''key0'', '''') = @key0
                -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end 
        AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
        AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
) 
, dialysis_date AS (
    SELECT
        REPLACE(MIN(I.period_start_date) :: TEXT, ''-'', '''') AS dialysis_start_date
    FROM
        pat_unique U
        CROSS JOIN LATERAL jsonb_to_recordset(U.in_out_visit_history_info) AS I
        (   ctl_no bigint,
            period_start_date date,
            period_start_day bigint,
            period_start_month bigint,
            period_start_year bigint,
            move_in_out smallint
        )
    WHERE pat_id = (SELECT pat_id FROM ord_main_data)
    AND U.is_del = ''0''
    AND I.period_start_day IS NOT NULL
    AND I.period_start_month IS NOT NULL
    AND I.period_start_year IS NOT NULL
    AND I.period_start_date IS NOT NULL
    AND I.move_in_out = 1
) 
, hospital_date AS (
    SELECT 
        REPLACE(MAX(I.period_start_date) :: TEXT, ''-'', '''') AS hospital_start_date
    FROM
        pat_unique U
        CROSS JOIN LATERAL jsonb_to_recordset(U.in_out_visit_history_info) AS I
        (   ctl_no bigint,
            period_start_date date,
            from_facility bigint,
            move_in_out smallint
        )
    WHERE pat_id = (SELECT pat_id FROM ord_main_data)
    AND U.is_del = ''0''
    AND I.period_start_date IS NOT NULL
    AND I.from_facility IS NULL
    AND (I.move_in_out = 1 OR I.move_in_out = 2)
)
SELECT dialysis_date.dialysis_start_date, hospital_date.hospital_start_date, ini_data.default_setting,
(CASE ord_main_data.anti_coagulant_amount::FLOAT >= 1
    WHEN TRUE THEN
        LPAD(split_part((ord_main_data.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 8, '' '')
    ELSE
        (
        CASE ini_data.default_setting
    WHEN ''0'' THEN
        LPAD(split_part((ord_main_data.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 8, '' '')
    WHEN ''1'' THEN
        LPAD(LPAD(split_part((ord_main_data.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 3, ''0''), 8, '' '')
  END
    )
END
) AS calculate_one_shot_amount
FROM ord_main_data, ini_data, dialysis_date, hospital_date', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）指示）透析条件', '2022-08-18 15:49:19.638',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-507, 'WITH 
	ord_main_restore_info AS (
		SELECT * FROM ord_main_restore as ord_i
		WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
		ORDER BY del_date DESC LIMIT 1
	),
	A AS ( 
	SELECT (to_number(rst_cond_info:: json ->''26'' ->> ''value'', ''9999.99'')+
to_number(rst_cond_info:: json ->''28'' ->> ''value'', ''9999.99''))::TEXT AS anti_coagulant_amount
	FROM ord_main_restore_info 
	WHERE ord_no = @ordNo
	),
 B AS (
SELECT COALESCE
	( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS default_setting 
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
WHERE
	facility_cd = @facilityCd
 
	AND is_del = ''0'' 
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 start
	AND COALESCE(info->>''key0'','''') = @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため 孟堅 end
	AND info ->> ''key1'' = ''DIALYSISSEND'' 
	AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
	),
	KOU_COAG_RESOLVE_MODE_cd AS(
SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL jsON_array_elements(ini.coop_ini_info ::jsON) info
  WHERE
    facility_cd = @facilityCd

    AND is_del = ''0''
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''KOU_COAG_RESOLVE_MODE''
)
SELECT B.default_setting,
case when (select (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd)) in (''0'',''1'') 
or (	SELECT rst_cond_info -> ''25'' ->> ''medicine_type'' FROM ord_main_restore as ord_i
		WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
		ORDER BY del_date DESC LIMIT 1)=''1''
then
(CASE A.anti_coagulant_amount::FLOAT >= 1
	WHEN true THEN
		LPAD(split_part((A.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 8, '' '')
	ELSE
		(
		CASE B.default_setting
	WHEN ''0'' THEN
		LPAD(split_part((A.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 8, '' '')
	WHEN ''1'' THEN
		LPAD(LPAD(split_part((A.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 3, ''0''), 8, '' '')
  END
	)
END
) else '''' END AS calculate_one_shot_amount
FROM A,B', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：抗凝固剤総量（単体薬剤）（削除）', '2022-08-01 14:31:32.443', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-110, 'WITH 
	A AS ( 
	SELECT (to_number(rst_cond_info:: json ->''26'' ->> ''value'', ''9999.99'')+
to_number(rst_cond_info:: json ->''28'' ->> ''value'', ''9999.99''))::TEXT AS anti_coagulant_amount
	FROM ord_main 
	WHERE ord_no = @ordNo
 
	),
 B AS (
SELECT COALESCE
	( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS default_setting 
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
WHERE
	facility_cd = @facilityCd
 
	AND is_del = ''0'' 
	AND info ->> ''key1'' = ''DIALYSISSEND'' 
	AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
	),
	KOU_COAG_RESOLVE_MODE_cd AS(
SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL jsON_array_elements(ini.coop_ini_info ::jsON) info
  WHERE
    facility_cd = @facilityCd

    AND is_del = ''0''
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
    AND info ->> ''key1'' = ''DIALYSISSEND''
    AND info ->> ''key2'' = ''KOU_COAG_RESOLVE_MODE''
)
SELECT B.default_setting,
case when (select (SELECT staff_cd FROM KOU_COAG_RESOLVE_MODE_cd)) in (''0'',''1'') or
(select rst_cond_info -> ''25'' ->> ''medicine_type'' from ord_main 
	WHERE ord_no = @ordNo) = ''1''
then
(CASE A.anti_coagulant_amount::FLOAT >= 1
	WHEN true THEN
		LPAD(split_part((A.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 8, '' '')
	ELSE
		(
		CASE B.default_setting
	WHEN ''0'' THEN
		LPAD(split_part((A.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 8, '' '')
	WHEN ''1'' THEN
		LPAD(LPAD(split_part((A.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 3, ''0''), 8, '' '')
  END
	)
END 
) else '''' END AS calculate_one_shot_amount
FROM A,B', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：抗凝固剤総量（単体薬剤）', '2022-06-08 15:38:53', CURRENT_TIMESTAMP, NULL);
