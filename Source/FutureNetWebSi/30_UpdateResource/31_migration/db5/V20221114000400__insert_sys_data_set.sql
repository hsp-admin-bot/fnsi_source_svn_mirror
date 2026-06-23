delete from ntss.sys_data_set where sql_cd = '3100';
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (3100, 'with markedData as (select coalesce(nullif(jsonb_agg(t1.t0), null), ''[]'') as data
                    from (select jsonb_array_elements(charge_staff_info) as t0
                          from pat_main
                          where is_del = ''0''
                            AND pat_id = @patId
                            AND facility_cd = ''@facilityCd'') as t1
                    where t1.t0 ->> ''flg'' = ''doc''
                      and t1.t0 ->> ''staff_cd'' <> ''-999999''),
     unmarkedData as (select coalesce(nullif(jsonb_agg(t1.t0), null), ''[]'') as data
                      from (select jsonb_array_elements(charge_staff_info) as t0
                            from pat_main
                            where is_del = ''0''
                              AND pat_id = @patId
                              AND facility_cd = ''@facilityCd'') as t1
                      where t1.t0 ->> ''ctl_no'' not in (select t1.t0 ->> ''ctl_no''
                                                       from (select jsonb_array_elements(charge_staff_info) as t0
                                                             from pat_main
                                                             where is_del = ''0''
                                                               AND pat_id = @patId
                                                               AND facility_cd = ''@facilityCd'') as t1
                                                       where t1.t0 ->> ''flg'' = ''doc''
                                                         or t1.t0 ->> ''staff_cd'' = ''-999999''))
update pat_main
set charge_staff_info = (select jsonb_agg(t3.jList)
                         from (select jsonb_delete(t2.list, ''flg'') as jList
                               from (select jsonb_array_elements(unmarkedData.data || markedData.data) as list
                                     from markedData,
                                          unmarkedData) as t2
                               order by t2.list ->> ''disp_order'' asc) t3)
where is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd'';', 2, '[{}]', '0', '{"applications": [4]}', null, '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, null);
