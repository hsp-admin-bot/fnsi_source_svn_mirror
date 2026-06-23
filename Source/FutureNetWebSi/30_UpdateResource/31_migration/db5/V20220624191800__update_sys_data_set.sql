delete from ntss.sys_data_set where sql_cd in ('7302', '1881', '1999','9998');
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1999, 'update pat_personal_main set transport_cd = (case when ''@tCd''=''0'' then null else ''@tCd'' end)::integer
', 3, '[{}]', '0', '{"applications": [4]}', null, '（送信用）日機裝）profile：profile連携（XML）で受信した詳細情報（搬送区分）', '2022-06-19 07:42:57.470', CURRENT_TIMESTAMP, '[{"sql_cd": 9998, "field_name": "t_cd", "replace_var": "@tCd"}]');
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (9998, 'select transport_cd as t_cd from mst_transport where
  in_hospital_cd_1 = @transportCd
	and facility_cd = @facilityCd
  and is_del = ''0''
union
select 0 as t_cd
order by t_cd desc
limit 1', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)profile連携（XML）で受信した詳細情報（搬送区分）', '2022-06-20 11:45:57.229', CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (7302, 'with diseaseInfo as (select case ''@medicalHstInfo.diseaseCd'' when '''' then ''999999'' else ''@medicalHstInfo.diseaseCd'' end as diseaseCd),
     outComeInfo as (select case (select case when ''@isDie'' = ''1'' then ''10'' else ''@medicalHstInfo.outCome'' end)
                                when '''' then '' '' end as outCome),
     currentTime as (select case (select case when ''@isDie'' = ''1'' then to_char(CURRENT_TIMESTAMP,''YYYYMMDD'') else ''@medicalHstInfo.outComeDate'' end) when '''' then '' '' else ''@medicalHstInfo.outComeDate'' end as nowDate)
update pat_unique
set medical_hst_info = (case ''@medicalHstInfoFlg''
                           when '''' then medical_hst_info
                           else (CASE
                                     WHEN ''@upBaseDiseaseFlg'' = ''0'' and ''@isDie'' = ''''  and ''@medicalHstInfo.diseaseDate''<> ''''
                                        THEN replace(cast(medical_hst_info as text),
                                                                                 ''"is_dialysis_underlying_disease": "1"'',
                                                                                 ''"is_dialysis_underlying_disease": "0"'')::jsonb
                                     ELSE medical_hst_info END)
                                     || case when (''@medicalHstInfo.diseaseCd'' <> '''' and ''@isDie'' = '''' and ''@medicalHstInfo.diseaseDate'' <> '''')
                                                    or (''@isDie'' = ''1'' and ''@medicalHstInfo.diseaseDate'' <> '''')
                                        then cast(''[{
                               "memo": "@medicalHstInfo.memo",
                               "ctl_no": "@nextCtlNo2",
                               "die_date": "@medicalHstInfo.dieDate",
                               "out_come": "''|| outComeInfo.outCome ||''",
                               "course_cd": "@medicalHstInfo.courseCd",
                               "is_notice": "@medicalHstInfo.isNotice",
                               "disease_cd": ''|| diseaseInfo.diseaseCd ||'',
                               "disp_order": "@medicalHstInfo.dispOrder",
                               "disease_day": "'' || substr(replace(''@medicalHstInfo.diseaseDate'', ''/'', ''''), 7, 2) || ''",
                               "facility_cd": "@medicalHstInfo.facilityCd",
                               "disease_date": "@medicalHstInfo.diseaseDate",
                               "disease_year": "'' || substr(replace(''@medicalHstInfo.diseaseDate'', ''/'', ''''), 1, 4) || ''",
                               "is_diagnosed": "@medicalHstInfo.isDiagnosed",
                               "diagnosis_day": "@medicalHstInfo.diagnosisDay",
                               "disease_month": "'' || substr(replace(''@medicalHstInfo.diseaseDate'', ''/'', ''''), 5, 2) || ''",
                               "out_come_date": "''||currentTime.nowDate||''",
                               "course_is_free": "@medicalHstInfo.courseIsFree",
                               "diagnosis_date": "@medicalHstInfo.diagnosisDate",
                               "diagnosis_year": "@medicalHstInfo.diagnosisYear",
                               "diagnosis_month": "@medicalHstInfo.diagnosisMonth",
                               "is_main_disease": "@medicalHstInfo.isMainDisease",
                               "diagnostician_cd": "@medicalHstInfo.diagnosticianCd",
                               "diagnosis_facility_cd": "@medicalHstInfo.diagnosisFacilityCd",
                               "diagnostician_is_free": "@medicalHstInfo.diagnosticianIsFree",
                               "is_confirmation_biopsy": "@medicalHstInfo.isConfirmationBiopsy",
                               "diagnosis_facility_is_free": "@medicalHstInfo.diagnosisFacilityIsFree",
                               "is_dialysis_underlying_disease": "''|| CASE WHEN ''@upBaseDiseaseFlg'' = ''0'' and ''@isDie'' = '''' THEN ''1'' ELSE ''0''END ||''"}]'' as text)::jsonb end
    end)
        from diseaseInfo,outComeInfo,currentTime
where pat_id = @patId
  and facility_cd = ''@facilityCd''
  and is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)日機装の患者プロファイル(既往歴情報情報)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": 1009, "field_name": "up_base_disease_flg", "replace_var": "@upBaseDiseaseFlg"}]');
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1881, 'with currentTime as (select to_char(CURRENT_TIMESTAMP, ''YYYYMMDD'') as nowDate)
update pat_unique
set medical_hst_info = COALESCE(nullif(medical_hst_info::text, '' ''), ''[]'')::jsonb ||
    cast(''[{"memo":null, "ctl_no":null, "die_date": "@dieDate", "out_come": "10", "course_cd":null, "is_notice":null, "disease_cd":null, "disp_order":null, "disease_day":null, "facility_cd":null, "disease_date":null, "disease_year":null, "is_diagnosed":null, "diagnosis_day":null, "disease_month":null, "out_come_date": "'' ||
         currentTime.nowDate ||
         ''", "course_is_free":null, "diagnosis_date":null, "diagnosis_year":null, "diagnosis_month":null, "is_main_disease":null, "diagnostician_cd":null, "diagnosis_facility_cd":null, "diagnostician_is_free":null, "is_confirmation_biopsy":null, "diagnosis_facility_is_free":null, "is_dialysis_underlying_disease":null}]'' as text)::jsonb
from currentTime
where pat_id = @patId
  and facility_cd = ''@facilityCd''
  and is_del = ''0'';', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)富士通の患者プロファイル_固有情報_生存情報', '2022-06-20 11:45:57.492', CURRENT_TIMESTAMP, '[]');
