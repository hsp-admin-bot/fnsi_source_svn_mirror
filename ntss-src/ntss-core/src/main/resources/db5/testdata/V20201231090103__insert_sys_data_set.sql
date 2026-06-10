INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-998, 'select
  right(pat_personal_main.hosp_pat_id,10) as hosp_pat_id
from
  pat_personal_main personal,
	ord_main ord
where
  personal.is_del = ''0''
and ord.is_del = ''0''
and ord.facility_cd = @facilityCd
and ord.treat_date =to_char(CURRENT_DATE, ''YYYYHHDD'')
and personal.pat_id = ord.pat_id', 3, '[{}]', '0', '{"applications": [4]}', NULL, '施設内患者ID取得(下10桁）', '2020-03-11 18:05:37.059', '2020-03-11 18:05:39.831', NULL);
