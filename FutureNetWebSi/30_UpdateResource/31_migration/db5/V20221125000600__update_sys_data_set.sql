DELETE from ntss.sys_data_set where sql_cd = '3102';
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (3102, 'WITH take_cource_info AS (SELECT 1       AS order_no,
                                 CASE TRIM(ini_info ->> ''value'')
                                     WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'')
                                     ELSE TRIM(ini_info ->> ''value'')
                                     END AS take_cource_flg
                          FROM mst_coop_ini AS ini
                                   CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info
                          WHERE ini.is_del = ''0''
                            AND ini.facility_cd = ''@facilityCd''
                            AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV''
                            AND TRIM(ini_info ->> ''key2'') = ''ORDER_RECV_DOCTOR_SETTING''
                          UNION
                          SELECT 2   AS order_no
                               , ''0'' AS take_cource_flg
                          ORDER BY order_no ASC
                          LIMIT 1),
     witch_ctl_no as (select (case take_cource_flg
                                  when ''0'' then (select (case
                                                             when position(''1'' in t.ctl_no_str) > 0 and position(''2'' in t.ctl_no_str) = 0
                                                                 then ''2''
                                                             when position(''1'' in t.ctl_no_str) = 0 and position(''2'' in t.ctl_no_str) > 0
                                                                 then ''1''
                                                             when position(''1'' in t.ctl_no_str) = 0 and position(''2'' in t.ctl_no_str) = 0
                                                                 then ''1''
                                                             else '''' end)
                                                 from (select coalesce(nullif(string_agg(staff_info ->> ''ctl_no'', '',''), ''''), '''') as ctl_no_str
                                                       from pat_main
                                                                CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS staff_info
                                                       where pat_id = @patId
                                                         and staff_info ->> ''is_main'' = ''1''
                                                         and (staff_info ->> ''ctl_no'' = ''1'' or staff_info ->> ''ctl_no'' = ''2'')) as t)
                                  else take_cource_flg end) as ctl_no
                      from take_cource_info),
     total_number_of_docs as (select count(staff_info) as total
                              from pat_main
                                       CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS staff_info
                              where pat_id = @patId
                                and staff_info ->> ''is_main'' = ''1''
                                and staff_info ->> ''ctl_no'' in (''1'', ''2'')),
     count_all as (select count(staff_info) as counts
                   from pat_main
                            CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS staff_info
                   where pat_id = @patId
                     and staff_info ->> ''is_main'' = ''1''),
     check_staff_code as (select (case ''@chargeStaffInfo.staffCd''
                                      when '''' then ''-999999''
                                      else ''@chargeStaffInfo.staffCd'' end) as staff_code),
     disp_order_For_Doc as (select coalesce((select nullif(info ->> ''disp_order'', '''')
                                             from pat_main,
                                                  witch_ctl_no
                                                      CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS info
                                             where pat_id = @patId
                                               and info ->> ''ctl_no'' = witch_ctl_no.ctl_no
                                               and info ->> ''flg'' is null),
                                            cast((count_all.counts + 1) as text)) as disp_order
                            from count_all),
     change_status_for_doc as (select 1                                     as no,
                                      coalesce(info ->> ''is_charge'', ''0'')   as is_charge,
                                      coalesce(info ->> ''is_puncture'', ''0'') as is_puncture
                               from pat_main,
                                    witch_ctl_no
                                        CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS info
                               where pat_id = @patId
                                 and info ->> ''ctl_no'' = witch_ctl_no.ctl_no
                               union
                               select 2 as no, ''0'' as isCharge, ''0'' as isPuncture
                               order by no
                               limit 1),
     check_for_duplicate as (select (case when count(1) > 0 then false else true end) as check
                             from pat_main,
                                  check_staff_code
                                      CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS staff_info
                             where pat_id = @patId
                               and staff_info ->> ''is_main'' = ''1''
                               and staff_info ->> ''ctl_no'' in (''1'', ''2'')
                               and staff_info ->> ''staff_cd'' = check_staff_code.staff_code)
UPDATE pat_main
SET charge_staff_info = (case
                             when take_cource_info.take_cource_flg = ''0'' then (case
                                                                                   when total_number_of_docs.total < 2 and check_for_duplicate.check
                                                                                       then charge_staff_info || cast(''[
                        {
                          "ctl_no": '' || witch_ctl_no.ctl_no || '',
                          "disp_order": '' || total_number_of_docs.total + 1 || '',
                          "staff_cd": '' || check_staff_code.staff_code || '',
                          "is_main": "1",
                          "is_charge": "0",
                          "is_puncture": "0",
                          "flg":"doc"
                        }
                      ]'' as text) :: jsonb
                                                                                   else charge_staff_info end)
                             when (take_cource_info.take_cource_flg = ''1'' or take_cource_info.take_cource_flg = ''2'') and
                                  check_for_duplicate.check
                                 then (charge_staff_info || cast(''[
                        {
                          "ctl_no": '' || witch_ctl_no.ctl_no || '',
                          "disp_order": '' || disp_order_For_Doc.disp_order || '',
                          "staff_cd": '' || check_staff_code.staff_code || '',
                          "is_main": "1",
                          "is_charge": "'' || change_status_for_doc.is_charge || ''",
                          "is_puncture": "'' || change_status_for_doc.is_puncture || ''",
                          "flg":"doc"
                        }
                      ]'' as text) :: jsonb)
                             else charge_staff_info end),
    up_date           = CURRENT_TIMESTAMP
from take_cource_info,
     total_number_of_docs,
     witch_ctl_no,
     check_staff_code,
     disp_order_For_Doc,
     change_status_for_doc,
     check_for_duplicate
WHERE is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', null, '', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, null);
