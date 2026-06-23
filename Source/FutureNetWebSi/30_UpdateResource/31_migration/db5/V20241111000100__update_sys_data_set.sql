delete from sys_data_set where sql_cd in ('1711','1891');
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1711, e'with compareDate as (select (case TO_DATE(\'@dieDate_Date\', \'YYYY-MM-DD HH24:MI:SS\') >
                                  TO_DATE(to_char(CURRENT_TIMESTAMP, \'YYYY-MM-DD HH24:MI:SS\'), \'YYYY-MM-DD HH24:MI:SS\')
                                 when true then \'@dieDate_Date\'
                                 else to_char(CURRENT_TIMESTAMP, \'YYYY-MM-DD HH24:MI:SS\') end) as die_date),
     ord_no_list as (select ord_no
                     FROM ord_main
                     WHERE is_del = \'0\'
                       AND rst_edition = 0
                       AND rst_treatment_cd is null
                       AND pat_id = @patId
                       AND facility_cd = \'@facilityCd\'
                       AND treat_date >=
                           TO_CHAR(TO_DATE((select die_date from compareDate), \'YYYY-MM-DD HH24:MI:SS\'), \'YYYYMMDD\')
                       AND treat_date not in (select treat_date
                                              FROM ord_main
                                              WHERE is_del = \'0\'
                                                AND rst_edition = 0
                                                AND pat_id = @patId
                                                AND facility_cd = \'@facilityCd\'
                                                AND treat_date >= TO_CHAR(
                                                      TO_DATE((select die_date from compareDate), \'YYYY-MM-DD HH24:MI:SS\'),
                                                      \'YYYYMMDD\')
                                                AND rst_dialysis_state > \'0\')),
     del_schedule
         as (delete from ord_schedule where facility_cd = \'@facilityCd\' and ord_no in (select ord_no from ord_no_list))
DELETE
FROM ord_main
where ord_no in (select ord_no from ord_no_list)', 2, '[{}]', '0', '{"applications": [4]}', null, '未来日データを削除する。透析予定(ord_main)', '2020-05-25 18:21:40.841', current_timestamp, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1891, e'with compareDate as (select (case TO_DATE(\'@dieDate_Date\', \'YYYY-MM-DD HH24:MI:SS\') >
                                  TO_DATE(to_char(CURRENT_TIMESTAMP, \'YYYY-MM-DD HH24:MI:SS\'), \'YYYY-MM-DD HH24:MI:SS\')
                                 when true then \'@dieDate_Date\'
                                 else to_char(CURRENT_TIMESTAMP, \'YYYY-MM-DD HH24:MI:SS\') end) as die_date),
     ord_no_list as (select ord_no
                     FROM ord_main
                     WHERE is_del = \'0\'
                       AND rst_edition = 0
                       AND rst_treatment_cd is null
                       AND pat_id = @patId
                       AND facility_cd = \'@facilityCd\'
                       AND treat_date >=
                           TO_CHAR(TO_DATE((select die_date from compareDate), \'YYYY-MM-DD HH24:MI:SS\'), \'YYYYMMDD\')
                       AND treat_date not in (select treat_date
                                              FROM ord_main
                                              WHERE is_del = \'0\'
                                                AND rst_edition = 0
                                                AND pat_id = @patId
                                                AND facility_cd = \'@facilityCd\'
                                                AND treat_date >= TO_CHAR(
                                                      TO_DATE((select die_date from compareDate), \'YYYY-MM-DD HH24:MI:SS\'),
                                                      \'YYYYMMDD\')
                                                AND rst_dialysis_state > \'0\')),
     del_schedule
         as (delete from ord_schedule where facility_cd = \'@facilityCd\' and ord_no in (select ord_no from ord_no_list))
DELETE
FROM ord_main
where ord_no in (select ord_no from ord_no_list)', 2, '[{}]', '0', '{"applications": [4]}', null, '未来日データを削除する。透析予定(ord_main)', '2022-06-20 11:45:57.587', current_timestamp, null);
