DELETE FROM "sys_data_set" WHERE "sql_cd" = -999;
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-999, 'select

  right(hosp_pat_id,10) as hosp_pat_id

from

  pat_personal_main

where

  is_del = ''0''

and

  pat_id = @patId

', 3, '[{}]', '0', '{"applications": [4]}', NULL, '施設内患者ID取得(下10桁）', '2020-03-11 18:05:37.059', '2020-03-11 18:05:39.831', NULL);
