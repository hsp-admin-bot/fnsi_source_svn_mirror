delete from ntss.sys_data_set where sql_cd in ('9620', '7302', '9609');
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (9620, 'select A.relationship_cd as relation_cd
from mst_relationship A
         left join (select mss.facility_cd,
                           ms.code,
                           row_number() over () as index
                    from mst_selector mss
                             cross join lateral jsonb_to_recordset(mss.order_settings -> ''items'') as ms
                        (code bigint, name text)
                    where facility_cd = @facilityCd
                      and master_physical_name = ''mst_relationship''
) ms on A.facility_cd = ms.facility_cd and A.relationship_cd = ms.code
where A.facility_cd = @facilityCd
  and a.relationship_name = @otherContactInfo.relationName
order by ms.index', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)日機装の患者プロファイル(連絡先情報)', '2022-06-23 01:55:02.171', CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (7302, 'with diseaseInfo as (select case ''@medicalHstInfo.diseaseCd'' when '''' then ''999999'' else ''@medicalHstInfo.diseaseCd'' end as diseaseCd),
     outComeInfo as (select case (select case when ''@isDie'' = ''1'' then ''10'' else ''@medicalHstInfo.outCome'' end)
                                when '''' then '' '' end as outCome),
     currentTime as (select case (select case when ''@isDie'' = ''1'' then to_char(CURRENT_TIMESTAMP,''YYYYMMDD'') else ''@medicalHstInfo.outComeDate'' end) when '''' then '' '' else ''@medicalHstInfo.outComeDate'' end as nowDate),
     medicalHstInfo as (select (case when medical_hst_info is null then ''[]''::jsonb else medical_hst_info end) as medical_hst_info
                        from pat_unique
                        where pat_id = @patId
                          and facility_cd = ''@facilityCd''
                          and is_del = ''0'')
update pat_unique
set medical_hst_info = (case ''@medicalHstInfoFlg''
                           when '''' then medicalHstInfo.medical_hst_info
                           else (CASE
                                     WHEN ''@upBaseDiseaseFlg'' = ''0'' and ''@isDie'' = ''''  and ''@medicalHstInfo.diseaseDate''<> ''''
                                     and ''@medicalHstInfo.diseaseCd'' <> ''''
                                        THEN replace(cast(medicalHstInfo.medical_hst_info as text),
                                                                                 ''"is_dialysis_underlying_disease": "1"'',
                                                                                 ''"is_dialysis_underlying_disease": "0"'')::jsonb
                                     ELSE medicalHstInfo.medical_hst_info END)
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
                               "is_dialysis_underlying_disease": "''|| CASE WHEN ''@upBaseDiseaseFlg'' = ''0'' and ''@isDie'' = '''' THEN ''1'' ELSE ''0''END ||''"}]'' as text)::jsonb else ''[]''::jsonb end
    end)
        from diseaseInfo,outComeInfo,currentTime,medicalHstInfo
where pat_id = @patId
  and facility_cd = ''@facilityCd''
  and is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)日機装の患者プロファイル(既往歴情報情報)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": 1009, "field_name": "up_base_disease_flg", "replace_var": "@upBaseDiseaseFlg"}]');
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (9609, 'UPDATE pat_unique
SET medical_hst_info = (select jsonb_agg(lists)
                        from (select lists
                              from (select distinct on (t1.disease_cd) lists, disease_date as dDate
                                    from (select *
                                          from (select list ->> ''disease_cd''                     as disease_cd,
                                                       list ->> ''disease_date''                   as disease_date,
                                                       list ->> ''is_dialysis_underlying_disease'' as is_dialysis_underlying_disease,
                                                       list                                      as lists
                                                from pat_unique
                                                         cross join jsonb_array_elements(medical_hst_info) list
                                                where pat_id = @patId
                                                  and facility_cd = ''@facilityCd''
                                                  and is_del = ''0''
                                                order by disease_date desc) as t0
                                          order by t0.is_dialysis_underlying_disease desc) as t1) as t2
                              order by t2.dDate desc) as t3)
WHERE pat_id = @patId
  and facility_cd = ''@facilityCd''
  AND is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)富士通の患者プロファイル_固有情報更新', '2022-06-15 11:50:35.610', CURRENT_TIMESTAMP, null);
