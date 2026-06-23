delete from ntss.sys_data_set where sql_cd in ('1603', '7302');
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (7302, 'update pat_unique
set medical_hst_info = case ''@medicalHstInfoFlg''
                           when '''' then ''@medicalHstInfoValue''
                           else (CASE WHEN ''@upBaseDiseaseFlg'' = ''0'' THEN replace(cast(medical_hst_info as text), ''"is_dialysis_underlying_disease": "1"'', ''"is_dialysis_underlying_disease": "0"'')::jsonb ELSE medical_hst_info END) || cast(''[
                             {
                               "memo": "@medicalHstInfo.memo",
                               "ctl_no": "@nextCtlNo2",
                               "die_date": "@medicalHstInfo.dieDate",
                               "out_come": "@medicalHstInfo.outCome",
                               "course_cd": "@medicalHstInfo.courseCd",
                               "is_notice": "@medicalHstInfo.isNotice",
                               "disease_cd": ''|| @medicalHstInfo.diseaseCd ||'',
                               "disp_order": "@medicalHstInfo.dispOrder",
                               "disease_day": "''|| substr(replace(''@medicalHstInfo.diseaseDate'',''/'',''''),7, 2) ||''",
                               "facility_cd": "@medicalHstInfo.facilityCd",
                               "disease_date": "@medicalHstInfo.diseaseDate",
                               "disease_year": "''|| substr(replace(''@medicalHstInfo.diseaseDate'',''/'',''''),1, 4) ||''",
                               "is_diagnosed": "@medicalHstInfo.isDiagnosed",
                               "diagnosis_day": "@medicalHstInfo.diagnosisDay",
                               "disease_month": "''|| substr(replace(''@medicalHstInfo.diseaseDate'',''/'',''''),5, 2) ||''",
                               "out_come_date": "@medicalHstInfo.outComeDate",
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
                               "is_dialysis_underlying_disease": "''|| CASE WHEN ''@upBaseDiseaseFlg'' = ''0'' THEN ''1'' ELSE ''0''END ||''"
                             }
                           ]'' as text)::jsonb
    end
where pat_id = @patId
  and facility_cd = ''@facilityCd''
  and is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)日機装の患者プロファイル(既往歴情報情報)', '2020-05-25 18:21:40.841', current_timestamp, '[{"sql_cd": 1009, "field_name": "up_base_disease_flg", "replace_var": "@upBaseDiseaseFlg"}]');
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1603, 'UPDATE pat_unique 
SET in_out_visit_history_info = ''[]''
  , physical_info = ''[]'' 
  , up_date = CURRENT_TIMESTAMP
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)富士通の患者プロファイル_固有情報更新', '2020-05-25 18:21:40.841', current_timestamp, null);
