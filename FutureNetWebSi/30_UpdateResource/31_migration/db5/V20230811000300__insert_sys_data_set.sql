delete from ntss.sys_data_set where sql_cd = '1604';

INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1604, e'select pat_id
from
  pat_personal_main
where
  is_del = \'0\'
and
  hosp_pat_id = @hospPatId
and
  facility_cd = @facilityCd', 3, '[{}]', '0', '{"applications": [4]}', null, '(受信用)患者個人情報の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, null);

