delete from "sys_data_set" where "sql_cd" = -2400 or "sql_cd" = -2401;INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2401, 'select
  ord.pat_id,
  ord.ord_no
from
  ord_main ord
where
    ord.is_del = ''0''
and ord.facility_cd = @facilityCd
and ord.treat_date =to_char(CURRENT_DATE, ''YYYYHHDD'')
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '定時一括送信機能（患者プロファイル用）', '2020-03-11 18:05:37.059', '2020-03-11 18:05:39.831', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2400, 'select
 @pat_id as patid,
 @ord_no as ordno,
 right(hosp_pat_id,10) as hosp_pat_id
from
  pat_personal_main
where
  is_del = ''0''
and pat_id = @pat_id', 3, '[{}]', '0', '{"applications": [4]}', NULL, '定時一括送信機能（患者プロファイル用）', '2020-03-11 18:05:37.059', '2020-03-11 18:05:39.831', '[{"sql_cd": -2401, "field_name": "ord_no", "replace_var": "@ord_no"}, {"sql_cd": -2401, "field_name": "pat_id", "replace_var": "@pat_id"}]');
