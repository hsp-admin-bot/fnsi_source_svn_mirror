delete from "sys_data_set" where "sql_cd" = -201;
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-201, 'select 
	''vital'' as detail_id,
	substring(vital_all.vital,1,2) as vital_cd,
	substring(vital_all.vital,3) as vital_data,
	vital_all.occur_date
from
(
select
  to_char(occur_date,''YYYYMMDDHH24MI'')as occur_date
  ,regexp_split_to_table(concat(''bh'',monitor_data->>''90'','','',''bl'',monitor_data->>''91'','','',''pl'',monitor_data->>''93'' ,'','',''te'', monitor_data->>''94'') , '','') as vital
from
  mni_monitor
where
  ord_no =@ordNo and data_type in (0, 2, 4,5,6) and is_del = ''0''
 ) vital_all
where
 octet_length(vital_all.vital) > 2
 
union all

select
 ''vital'' as detail_id,
 ''bw'' as bw_cd,
 ord.rst_weight_info->>''weight_before'' as bw_w,
 to_char((ord.rst_weight_info->>''weight_before_date'')::timestamp,''YYYYMMDDHH24MI'') as bw_date
from 
 ord_main ord
where
 ord.ord_no = @ordNo
  and COALESCE(ord.rst_weight_info->>''weight_before_date'',''NODATE'') <> ''NODATE''
 
 union all
 
 select
 ''vital'' as detail_id,
 ''aw'' as aw_cd,
 ord.rst_weight_info->>''weight_after'' as aw_w,
 to_char((ord.rst_weight_info->>''weight_after_date'')::timestamp,''YYYYMMDDHH24MI'') as aw_date
from 
 ord_main ord
where
 ord.ord_no = @ordNo
 and COALESCE(ord.rst_weight_info->>''weight_after_date'',''NODATE'') <> ''NODATE''
 
union all

select 
	''vital'' as detail_id,
	substring(moni_all.moni,1,2) as moni_cd,
	substring(moni_all.moni,3) as moni_data,
	moni_all.occur_date
from
(
select
to_char(occur_date,''YYYYMMDDHH24MI'') as occur_date,
regexp_split_to_table(concat(
''01'',
monitor_data->>''1''
,'','',''31''
,monitor_data->>''31'' 
,'','',''36''
,monitor_data->>''36'' 
,'','',''33''
,monitor_data->>''33'' 
,'','',''05''
,monitor_data->>''5'' 
,'','',''32''
,monitor_data->>''32'' 
,'','',''11''
,monitor_data->>''11'' 
,'','',''12''
,monitor_data->>''12'' 
,'','',''13''
,monitor_data->>''13'' 
,'','',''09''
,monitor_data->>''9'' 
,'','',''37''
,monitor_data->>''37'' 
,'','',''21''
,monitor_data->>''21'' 
,'','',''20''
,monitor_data->>''20'' 
,'','',''22''
,monitor_data->>''22'' 
,'','',''73''
,monitor_data->>''73'' 
,'','',''72''
,monitor_data->>''72'' 
,'','',''74''
,monitor_data->>''74'' 
,'','',''17''
,monitor_data->>''17'' 
,'','',''80''
,monitor_data->>''80'' ), '','') as moni
from
  mni_monitor
where
  to_number(monitor_data->>''1'',''999'') > 0 and
  to_number(monitor_data->>''1'',''999'') % 5 = 0 and  
  ord_no =@ordNo and data_type = 1 and is_del = ''0''
) moni_all
where
 octet_length(moni_all.moni) > 2', 2, '[{}]', '0', '{"applications": [4]}', NULL, 'NEC)バイタル繰り返し部', '2020-05-15 10:28:50.001', '2020-05-15 10:28:54.001', NULL);
