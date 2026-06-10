delete from ntss.sys_data_set where sql_cd in ('9997', '9996');
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (9997, 'with diseaseCdBoolean as (select (case ''@medicalHstInfo.diseaseCd''
                                      when '''' then true
                                      else false end) as status),
     diseaseDateBoolean as (select (case ''@medicalHstInfo.diseaseDate''
                                      when '''' then true
                                      else false end) as status)
update pat_unique
set medical_hst_info = (case when diseaseCdBoolean.status and diseaseDateBoolean.status then replace(cast(medical_hst_info as text),
                               ''"is_dialysis_underlying_disease": "1"'',
                               ''"is_dialysis_underlying_disease": "0"'')::jsonb else medical_hst_info end)
from diseaseCdBoolean, diseaseDateBoolean
where pat_id = @patId
  and facility_cd = ''@facilityCd''
  and is_del = ''0'';', 2, '[{}]', '0', '{"applications": [4]}', null, '', '2022-03-10 09:51:01.219', CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (9996, 'with diseaseCdBoolean as (select (case ''@medicalHstInfo.diseaseCd''
                                      when '''' then true
                                      else false end) as status),
     diseaseDateBoolean as (select (case ''@medicalHstInfo.diseaseDate''
                                      when '''' then true
                                      else false end) as status)
UPDATE pat_personal_main
SET primary_disease_cd = (case when diseaseCdBoolean.status and diseaseDateBoolean.status then null else primary_disease_cd end)
from diseaseCdBoolean, diseaseDateBoolean
WHERE is_del = ''0''
  AND hosp_pat_id = ''@hospPatId''
  AND facility_cd = ''@facilityCd'';', 3, '[{}]', '0', '{"applications": [4]}', null, '', '2022-03-10 09:51:01.219', CURRENT_TIMESTAMP, null);
