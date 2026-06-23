delete from ntss.sys_data_set where sql_cd in (1209, 1210);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1209, 'with markedData as (select coalesce(nullif(jsonb_agg(t1.t0), null), ''[]'') as data
                    from (select jsonb_array_elements(charge_staff_info) as t0
                          from pat_main
                          where is_del = ''0''
                            AND pat_id = @patId
                            AND facility_cd = ''@facilityCd'') as t1
                    where t1.t0 ->> ''flg'' in (''doc'', ''nur'')
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
                                                       where t1.t0 ->> ''flg'' in (''doc'', ''nur'')
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
  AND facility_cd = ''@facilityCd'';', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)富士通の患者プロファイル_患者基本情報の新規', '2022-06-17 06:29:02.276', CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (1210, 'WITH take_cource_info AS (SELECT 1 AS order_no
                               , CASE TRIM(ini_info ->> ''value'')
                                     WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'')
                                     ELSE TRIM(ini_info ->> ''value'')
        END                        AS take_cource_flg
                          FROM mst_coop_ini AS ini
                                   CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info
                          WHERE ini.is_del = ''0''
                            AND ini.facility_cd = ''@facilityCd''
                            AND TRIM(ini_info ->> ''key1'') = ''PATIENTRCV_XML''
                            AND TRIM(ini_info ->> ''key2'') = ''IND_DOCTOR_FLG''
                          UNION
                          SELECT 2   AS order_no
                               , ''0'' AS take_cource_flg
                          ORDER BY order_no ASC
                          LIMIT 1),
     noForDoc as (select count(1) + 1 as counts
                  from (select jsonb_array_elements(charge_staff_info) as t0
                        from pat_main
                        where pat_id = @patId) as t1
                  where t1.t0 ->> ''flg'' = ''doc''),
     noForNur as (select (case
                              when take_cource_info.take_cource_flg = ''0'' then c + 3
                              when take_cource_info.take_cource_flg = ''1'' then c + 2 end) as counts
                  from (select count(1) as c
                        from (select jsonb_array_elements(charge_staff_info) as t0
                              from pat_main
                              where pat_id = @patId) as t1
                        where t1.t0 ->> ''flg'' = ''nur'') as t2,
                       take_cource_info),
     countAll as (select coalesce(nullif(max(t1.t0 ->> ''disp_order''), '''')::integer, 0) as counts
                  from (select jsonb_array_elements(charge_staff_info) as t0
                        from pat_main
                        where pat_id = @patId) as t1),
     dispOrderForDoc as (select coalesce((select nullif(info ->> ''disp_order'', '''')
                                          from pat_main,
                                               noForDoc
                                                   CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS info
                                          where pat_id = @patId
                                            and info ->> ''ctl_no'' = cast(noForDoc.counts as text)
                                            and info ->> ''flg'' is null),
                                         cast((countAll.counts + 1) as text)) as dispOrder
                         from countAll),
     dispOrderForNur as (select coalesce((select nullif(info ->> ''disp_order'', '''')
                                          from pat_main,
                                               noForNur
                                                   CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS info
                                          where pat_id = @patId
                                            and info ->> ''ctl_no'' = cast(noForNur.counts as text)
                                            and info ->> ''flg'' is null),
                                         cast((countAll.counts + 1) as text)) as dispOrder
                         from countAll),
     changeStatusForDoc as (select 1                                     as no,
                                   coalesce(info ->> ''is_charge'', ''0'')   as isCharge,
                                   coalesce(info ->> ''is_puncture'', ''0'') as isPuncture
                            from pat_main,
                                 noForDoc
                                     CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS info
                            where pat_id = @patId
                              and info ->> ''ctl_no'' = cast(noForDoc.counts as text)
                            union
                            select 2 as no, ''0'' as isCharge, ''0'' as isPuncture
                            order by no
                            limit 1),
     changeStatusForNur as (select 1                                     as no,
                                   coalesce(info ->> ''is_charge'', ''0'')   as isCharge,
                                   coalesce(info ->> ''is_puncture'', ''0'') as isPuncture
                            from pat_main,
                                 noForNur
                                     CROSS JOIN LATERAL json_array_elements(charge_staff_info ::json) AS info
                            where pat_id = @patId
                              and info ->> ''ctl_no'' = cast(noForNur.counts as text)
                            union
                            select 2 as no, ''0'' as isCharge, ''0'' as isPuncture
                            order by no
                            limit 1),
     checkStaffCode as (select (case ''@chargeStaffInfo.staffCd''
                                    when '''' then ''-999999''
                                    else ''@chargeStaffInfo.staffCd'' end) as staffCode),
     checkIndicatorStaffCode as (select (case ''@chargeStaffInfo.indicatorStaffCd''
                                             when '''' then ''-999999''
                                             else ''@chargeStaffInfo.indicatorStaffCd'' end) as staffCode),
     checkFortest as (select ''@check'' as check)
UPDATE pat_main
SET charge_staff_info =
        CASE ''@chargeStaffInfoFlg''
            WHEN ''''
                THEN ''@chargeStaffInfoValue''
            ELSE (case
                      when take_cource_info.take_cource_flg = ''0'' and
                           ''@chargeStaffInfo.staffCd'' <> ''@'' || ''chargeStaffInfo.staffCd''
                          then (case
                                    when ''@chargeStaffInfo.isMain'' = ''1'' and ''@chargeStaffInfo.isCharge'' = ''0'' and
                                         noForDoc.counts < 3 then
                                            charge_staff_info || cast(''[
                        {
                          "ctl_no": '' || noForDoc.counts || '',
                          "disp_order": "'' || dispOrderForDoc.dispOrder || ''",
                          "staff_cd": '' || checkStaffCode.staffCode || '',
                          "is_main": "1",
                          "is_charge": "'' || changeStatusForDoc.isCharge || ''",
                          "is_puncture": "'' || changeStatusForDoc.isPuncture || ''",
                          "flg":"doc"
                        }
                      ]'' as text) :: jsonb
                                    when ''@chargeStaffInfo.isMain'' = ''0'' and ''@chargeStaffInfo.isCharge'' = ''1'' and
                                         noForNur.counts < 5 then
                                            charge_staff_info || cast(''[
                        {
                          "ctl_no": '' || noForNur.counts || '',
                          "disp_order": "'' || dispOrderForNur.dispOrder || ''",
                          "staff_cd": '' || checkStaffCode.staffCode || '',
                          "is_main": "0",
                          "is_charge": "1",
                          "is_puncture": "'' || changeStatusForNur.isPuncture || ''",
                          "flg":"nur"
                        }
                      ]'' as text) :: jsonb
                                    else charge_staff_info end)
                      when take_cource_info.take_cource_flg = ''1''
                          then (case
                                    when noForDoc.counts = 1 and ''@chargeStaffInfo.indicatorStaffCd'' <> ''@''||''chargeStaffInfo.indicatorStaffCd'' then
                                            charge_staff_info || cast(''[
                        {
                          "ctl_no": 1,
                          "disp_order": "'' || dispOrderForDoc.dispOrder || ''",
                          "staff_cd": '' || checkIndicatorStaffCode.staffCode || '',
                          "is_main": "1",
                          "is_charge": "'' || changeStatusForDoc.isCharge || ''",
                          "is_puncture": "'' || changeStatusForDoc.isPuncture || ''",
                          "flg":"doc"
                        }
                      ]'' as text) :: jsonb
                                    when ''@chargeStaffInfo.isMain'' = ''0'' and ''@chargeStaffInfo.isCharge'' = ''1'' and
                                         ''@chargeStaffInfo.staffCd'' <> ''@'' || ''chargeStaffInfo.staffCd'' and
                                         noForNur.counts < 4 then
                                            charge_staff_info || cast(''[
                        {
                          "ctl_no": '' || noForNur.counts || '',
                          "disp_order": "'' || dispOrderForNur.dispOrder || ''",
                          "staff_cd": '' || checkStaffCode.staffCode || '',
                          "is_main": "0",
                          "is_charge": "1",
                          "is_puncture": "'' || changeStatusForNur.isPuncture || ''",
                          "flg":"nur"
                        }
                      ]'' as text) :: jsonb
                                    else charge_staff_info end)
                      else charge_staff_info END) END
from take_cource_info,
     noForDoc,
     noForNur,
     checkStaffCode,
     checkIndicatorStaffCode,
     dispOrderForDoc,
     dispOrderForNur,
     changeStatusForDoc,
     changeStatusForNur
WHERE is_del = ''0''
  AND pat_id = @patId
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)富士通の患者プロファイル_患者基本情報の修正', '2022-06-13 02:07:03.922', CURRENT_TIMESTAMP, null);
