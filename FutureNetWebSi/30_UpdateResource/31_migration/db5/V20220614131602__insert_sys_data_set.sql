delete from ntss.sys_data_set where sql_cd in ('9607', '9608', '9609');
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (9609, 'UPDATE pat_unique
SET medical_hst_info = (select jsonb_agg(lists)
      from (select distinct on (t1.disease_cd) lists, disease_date as dDate
            from (select list ->> ''disease_cd'' as disease_cd, list ->> ''disease_date'' as disease_date, list as lists
                  from pat_unique
                           cross join jsonb_array_elements(medical_hst_info) list
                  where pat_id = @patId
                    and facility_cd = ''@facilityCd''
                    and is_del = ''0'' order by disease_date desc) as t1) as t2)
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)富士通の患者プロファイル_固有情報更新', current_timestamp, current_timestamp, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (9608, 'select (CASE WHEN @upBaseDiseaseFlg = ''0'' THEN list->>''disease_cd'' ELSE ''0'' END) as disease_cd
from pat_unique
cross join jsonb_array_elements(medical_hst_info) with ordinality j(list, n)
where pat_id = @patId
  and facility_cd = @facilityCd
  and is_del = ''0''
order by n desc limit 1', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)日機装の患者プロファイル(連絡先情報)', current_timestamp, current_timestamp, '[{"sql_cd": 1009, "field_name": "up_base_disease_flg", "replace_var": "@upBaseDiseaseFlg"}]');
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (9607, 'UPDATE pat_personal_main
SET primary_disease_cd = (CASE WHEN ''@diseaseCd'' != 0 THEN ''@diseaseCd'' ELSE primary_disease_cd END)
WHERE
    is_del = ''0'' 
    AND hosp_pat_id = ''@hospPatId'' 
    AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', null, '(受信用)日機装の患者プロファイル(連絡先情報)', current_timestamp, current_timestamp, '[{"sql_cd": 9608, "field_name": "disease_cd", "replace_var": "@diseaseCd"}]');
