DELETE FROM "ntss"."sys_data_set" where "sql_cd" IN (9608);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9608, 'select disease_cd from (select (CASE
            WHEN ''0''
                = ''0'' THEN list ->> ''disease_cd''
            ELSE ''0'' END):: integer as disease_cd
from pat_unique
         cross join jsonb_array_elements(medical_hst_info) with ordinality j(list, n)
where pat_id = @patId
  and facility_cd = @facilityCd
  and is_del = ''0''
order by n desc LIMIT 1) t
UNION
SELECT 0 AS disease_cd
order by disease_cd desc nulls last
LIMIT 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(連絡先情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1009, "field_name": "up_base_disease_flg", "replace_var": "@upBaseDiseaseFlg"}]');
