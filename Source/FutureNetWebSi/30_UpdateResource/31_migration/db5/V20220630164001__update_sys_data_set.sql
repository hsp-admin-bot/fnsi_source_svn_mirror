delete from ntss.sys_data_set where sql_cd in (-113);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-113, 'select

 @pat_id as patid,

 @ord_no as ordno,

 hosp_pat_id

from

  pat_personal_main

where

  is_del = ''0''

and pat_id = @pat_id', 3, '[{}]', '0', '{"applications": [4]}', NULL, '定時一括送信機能（患者プロファイル用）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -2401, "field_name": "ord_no", "replace_var": "@ord_no"}, {"sql_cd": -2401, "field_name": "pat_id", "replace_var": "@pat_id"}]');
