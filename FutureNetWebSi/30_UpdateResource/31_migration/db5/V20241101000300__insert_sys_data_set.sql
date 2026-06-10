delete from sys_data_set where sql_cd in ('1719','1720','1721', '1722', '1723', '1724');
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1719, e'with compareDate as (select (case TO_DATE(\'@dieDate_Date\', \'YYYY-MM-DD HH24:MI:SS\') >
                                  TO_DATE(to_char(CURRENT_TIMESTAMP, \'YYYY-MM-DD HH24:MI:SS\'), \'YYYY-MM-DD HH24:MI:SS\')
                                 when true then \'@dieDate_Date\'
                                 else to_char(CURRENT_TIMESTAMP, \'YYYY-MM-DD HH24:MI:SS\') end) as die_date)
DELETE
FROM pat_exam_pattern
WHERE is_del = \'0\'
  AND pat_id = @patId
  AND facility_cd = \'@facilityCd\'
  AND TO_CHAR(exam_to, \'YYYYMMDD\') >=
      TO_CHAR(TO_DATE((select die_date from compareDate), \'YYYY-MM-DD HH24:MI:SS\'), \'YYYYMMDD\');', 2, '[{}]', '0', '{"applications": [4]}', null, '削除pat_exam_pattern', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1722, e'with compareDate as (select (case TO_DATE(\'@dieDate_Date\', \'YYYY-MM-DD HH24:MI:SS\') >
                                  TO_DATE(to_char(CURRENT_TIMESTAMP, \'YYYY-MM-DD HH24:MI:SS\'), \'YYYY-MM-DD HH24:MI:SS\')
                                 when true then \'@dieDate_Date\'
                                 else to_char(CURRENT_TIMESTAMP, \'YYYY-MM-DD HH24:MI:SS\') end) as die_date)
DELETE
FROM pat_exam_pattern
WHERE is_del = \'0\'
  AND pat_id = @patId
  AND facility_cd = \'@facilityCd\'
  AND TO_CHAR(exam_to, \'YYYYMMDD\') >=
      TO_CHAR(TO_DATE((select die_date from compareDate), \'YYYY-MM-DD HH24:MI:SS\'), \'YYYYMMDD\');', 2, '[{}]', '0', '{"applications": [4]}', null, '削除pat_exam_pattern', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1720, e'with compareDate as (select (case TO_DATE(\'@dieDate_Date\', \'YYYY-MM-DD HH24:MI:SS\') >
                                  TO_DATE(to_char(CURRENT_TIMESTAMP, \'YYYY-MM-DD HH24:MI:SS\'), \'YYYY-MM-DD HH24:MI:SS\')
                                 when true then \'@dieDate_Date\'
                                 else to_char(CURRENT_TIMESTAMP, \'YYYY-MM-DD HH24:MI:SS\') end) as die_date)
DELETE
FROM pat_rad_pattern
WHERE is_del = \'0\'
  AND pat_id = @patId
  AND facility_cd = \'@facilityCd\'
  AND TO_CHAR(rad_to, \'YYYYMMDD\') >=
      TO_CHAR(TO_DATE((select die_date from compareDate), \'YYYY-MM-DD HH24:MI:SS\'), \'YYYYMMDD\');', 2, '[{}]', '0', '{"applications": [4]}', null, '削除pat_rad_pattern', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1721, e'with update_pat_main as (update pat_main set sch_ext_end_date = null where pat_id = @patId)
DELETE
FROM pat_treatment_pattern
WHERE pat_id = @patId
  AND facility_cd = \'@facilityCd\';', 2, '[{}]', '0', '{"applications": [4]}', null, '削除pat_treatment_pattern', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1723, e'with compareDate as (select (case TO_DATE(\'@dieDate_Date\', \'YYYY-MM-DD HH24:MI:SS\') >
                                  TO_DATE(to_char(CURRENT_TIMESTAMP, \'YYYY-MM-DD HH24:MI:SS\'), \'YYYY-MM-DD HH24:MI:SS\')
                                 when true then \'@dieDate_Date\'
                                 else to_char(CURRENT_TIMESTAMP, \'YYYY-MM-DD HH24:MI:SS\') end) as die_date)
DELETE
FROM pat_rad_pattern
WHERE is_del = \'0\'
  AND pat_id = @patId
  AND facility_cd = \'@facilityCd\'
  AND TO_CHAR(rad_to, \'YYYYMMDD\') >=
      TO_CHAR(TO_DATE((select die_date from compareDate), \'YYYY-MM-DD HH24:MI:SS\'), \'YYYYMMDD\');', 2, '[{}]', '0', '{"applications": [4]}', null, '削除pat_rad_pattern', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1724, e'with update_pat_main as (update pat_main set sch_ext_end_date = null where pat_id = @patId)
DELETE
FROM pat_treatment_pattern
WHERE pat_id = @patId
  AND facility_cd = \'@facilityCd\';', 2, '[{}]', '0', '{"applications": [4]}', null, '削除pat_treatment_pattern', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, null);
