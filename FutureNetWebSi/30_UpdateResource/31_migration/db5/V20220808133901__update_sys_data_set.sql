DELETE FROM sys_data_set WHERE sql_cd in(-506,-14);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-506, 'WITH ord_main_restore_info AS (
  SELECT * FROM ord_main_restore as ord_i
  WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
  ORDER BY del_date DESC LIMIT 1
)
select
  to_char(ord.rst_start_date,''YYYYMMDDHH24MISS'') as start_date14,--透析開始日時
  to_char(ord.rst_start_date,''YYYY/MM/DD HH24:MI:SS'') as start_date14a,--透析開始日時
  to_char(ord.rst_start_date,''YYYYMMDD'') as start_date8,--透析開始日時
  to_char(ord.rst_start_date,''YYYY/MM/DD'') as start_date8a,--透析開始日時
  to_char(ord.rst_start_date,''HH24MISS'') as start_date6,--透析開始日時
  to_char(ord.rst_start_date,''HH24:MI:SS'') as start_date6a,--透析開始日時
  to_char(ord.rst_end_date,''YYYYMMDDHH24MISS'') as end_date14,--透析終了日時
  to_char(ord.rst_end_date,''YYYYMMDD'') as end_date8,--透析終了日時
  to_char(ord.rst_end_date,''HH24MISS'') as end_date6,--透析終了日時
  to_char(ord.rst_end_date,''YYYY/MM/DD HH24:MI:SS'') as end_date14a,--透析終了日時
  to_char(ord.rst_end_date,''YYYY/MM/DD'') as end_date8a,--透析終了日時
  to_char(ord.rst_end_date,''HH24:MI:SS'') as end_date6a,--透析終了日時
  to_char(ord.rst_start_date,''HH24MI'') as start_time4,--透析開始時刻
  to_char(ord.rst_end_date,''HH24MI'') as end_time4,--透析終了時刻
  ord.rst_running_time as running_time,
	--(case when ord.rst_start_date is not null and ord.rst_end_date is not null then(case when date_part(''''day'''', ord.rst_end_date - ord.rst_start_date) * 24 * 60 + date_part(''''hour'''', ord.rst_end_date - ord.rst_start_date)* 60 + date_part(''''minute'''', ord.rst_end_date - ord.rst_start_date)<=999 then date_part(''''day'''', ord.rst_end_date - ord.rst_start_date) * 24 * 60 + date_part(''''hour'''', ord.rst_end_date - ord.rst_start_date)* 60 + date_part(''''minute'''', ord.rst_end_date - ord.rst_start_date) else null end ) else null  end)::TEXT as running_time_str,
	(case when ord.rst_start_date is not null and ord.rst_end_date is not null then(case when (((to_char(ord.rst_end_date,''dd''))::INTEGER -(to_char(ord.rst_start_date,''dd''))::INTEGER) *24*60
	+ ((to_char(ord.rst_end_date,''hh24''))::INTEGER -(to_char(ord.rst_start_date,''hh24''))::INTEGER) * 60
	+(to_char(ord.rst_end_date,''MI''))::INTEGER -(to_char(ord.rst_start_date,''MI''))::INTEGER )<=999 then (((to_char(ord.rst_end_date,''dd''))::INTEGER -(to_char(ord.rst_start_date,''dd''))::INTEGER) *24*60
	+ ((to_char(ord.rst_end_date,''hh24''))::INTEGER -(to_char(ord.rst_start_date,''hh24''))::INTEGER) * 60
	+(to_char(ord.rst_end_date,''MI''))::INTEGER -(to_char(ord.rst_start_date,''MI''))::INTEGER ) 
	else null end ) else null  end)::TEXT as running_time_str,
  RIGHT(''00''||TRUNC(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999'')/60,0),2)||'':''||RIGHT(''00''||MOD(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999''),60),2) as treatment_time,
  to_char(timestamp ''now'',''YYYYMMDDHH24MISS'') as nowtime14,
  ord.treat_date as treat_date,
  ord.ind_treat_start_time || ''00'' as ind_treat_start_time
from
  ord_main_restore_info as ord
where
  ord.ord_no = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, 'NKK)  実績）透析開始終了日時変換（削除）', '2022-08-08 01:01:09.031', CURRENT_TIMESTAMP, NULL);
  INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-14, '	select
  to_char(ord.rst_start_date,''YYYYMMDDHH24MISS'') as start_date14,--透析開始日時
  to_char(ord.rst_start_date,''YYYY/MM/DD HH24:MI:SS'') as start_date14a,--透析開始日時
  to_char(ord.rst_start_date,''YYYYMMDD'') as start_date8,--透析開始日時
  to_char(ord.rst_start_date,''YYYY/MM/DD'') as start_date8a,--透析開始日時
  to_char(ord.rst_start_date,''HH24MISS'') as start_date6,--透析開始日時
  to_char(ord.rst_start_date,''HH24:MI:SS'') as start_date6a,--透析開始日時
  to_char(ord.rst_end_date,''YYYYMMDDHH24MISS'') as end_date14,--透析終了日時
  to_char(ord.rst_end_date,''YYYYMMDD'') as end_date8,--透析終了日時
  to_char(ord.rst_end_date,''HH24MISS'') as end_date6,--透析終了日時
  to_char(ord.rst_end_date,''YYYY/MM/DD HH24:MI:SS'') as end_date14a,--透析終了日時
  to_char(ord.rst_end_date,''YYYY/MM/DD'') as end_date8a,--透析終了日時
  to_char(ord.rst_end_date,''HH24:MI:SS'') as end_date6a,--透析終了日時
  to_char(ord.rst_start_date,''HH24MI'') as start_time4,--透析開始時刻
  to_char(ord.rst_end_date,''HH24MI'') as end_time4,--透析終了時刻
  ord.rst_running_time as running_time,
	--(case when ord.rst_start_date is not null and ord.rst_end_date is not null then(case when date_part(''''day'''', ord.rst_end_date - ord.rst_start_date) * 24 * 60 + date_part(''''hour'''', ord.rst_end_date - ord.rst_start_date)* 60 + date_part(''''minute'''', ord.rst_end_date - ord.rst_start_date)<=999 then date_part(''''day'''', ord.rst_end_date - ord.rst_start_date) * 24 * 60 + date_part(''''hour'''', ord.rst_end_date - ord.rst_start_date)* 60 + date_part(''''minute'''', ord.rst_end_date - ord.rst_start_date) else null end ) else null  end)::TEXT as running_time_str,
	(case when ord.rst_start_date is not null and ord.rst_end_date is not null then(case when (((to_char(ord.rst_end_date,''dd''))::INTEGER -(to_char(ord.rst_start_date,''dd''))::INTEGER) *24*60
	+ ((to_char(ord.rst_end_date,''hh24''))::INTEGER -(to_char(ord.rst_start_date,''hh24''))::INTEGER) * 60
	+(to_char(ord.rst_end_date,''MI''))::INTEGER -(to_char(ord.rst_start_date,''MI''))::INTEGER )<=999 then (((to_char(ord.rst_end_date,''dd''))::INTEGER -(to_char(ord.rst_start_date,''dd''))::INTEGER) *24*60
	+ ((to_char(ord.rst_end_date,''hh24''))::INTEGER -(to_char(ord.rst_start_date,''hh24''))::INTEGER) * 60
	+(to_char(ord.rst_end_date,''MI''))::INTEGER -(to_char(ord.rst_start_date,''MI''))::INTEGER ) 
	else null end ) else null  end)::TEXT as running_time_str,
  RIGHT(''00''||TRUNC(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999'')/60,0),2)||'':''||RIGHT(''00''||MOD(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999''),60),2) as treatment_time,
  to_char(timestamp ''now'',''YYYYMMDDHH24MISS'') as nowtime14,
  ord.treat_date as treat_date,
  ord.ind_treat_start_time || ''00'' as ind_treat_start_time
from
  ord_main as ord
where
  ord.ord_no = @ordNo
	and ord.rst_start_date is not null
	and ord.rst_end_date is not null
	union  
	(
	select
  to_char(ord.rst_start_date,''YYYYMMDDHH24MISS'') as start_date14,--透析開始日時
  to_char(ord.rst_start_date,''YYYY/MM/DD HH24:MI:SS'') as start_date14a,--透析開始日時
  to_char(ord.rst_start_date,''YYYYMMDD'') as start_date8,--透析開始日時
  to_char(ord.rst_start_date,''YYYY/MM/DD'') as start_date8a,--透析開始日時
  to_char(ord.rst_start_date,''HH24MISS'') as start_date6,--透析開始日時
  to_char(ord.rst_start_date,''HH24:MI:SS'') as start_date6a,--透析開始日時
  to_char(ord.rst_end_date,''YYYYMMDDHH24MISS'') as end_date14,--透析終了日時
  to_char(ord.rst_end_date,''YYYYMMDD'') as end_date8,--透析終了日時
  to_char(ord.rst_end_date,''HH24MISS'') as end_date6,--透析終了日時
  to_char(ord.rst_end_date,''YYYY/MM/DD HH24:MI:SS'') as end_date14a,--透析終了日時
  to_char(ord.rst_end_date,''YYYY/MM/DD'') as end_date8a,--透析終了日時
  to_char(ord.rst_end_date,''HH24:MI:SS'') as end_date6a,--透析終了日時
  to_char(ord.rst_start_date,''HH24MI'') as start_time4,--透析開始時刻
  to_char(ord.rst_end_date,''HH24MI'') as end_time4,--透析終了時刻
  ord.rst_running_time as running_time,
	--(case when ord.rst_start_date is not null and ord.rst_end_date is not null then(case when date_part(''''day'''', ord.rst_end_date - ord.rst_start_date) * 24 * 60 + date_part(''''hour'''', ord.rst_end_date - ord.rst_start_date)* 60 + date_part(''''minute'''', ord.rst_end_date - ord.rst_start_date)<=999 then date_part(''''day'''', ord.rst_end_date - ord.rst_start_date) * 24 * 60 + date_part(''''hour'''', ord.rst_end_date - ord.rst_start_date)* 60 + date_part(''''minute'''', ord.rst_end_date - ord.rst_start_date) else null end ) else null  end)::TEXT as running_time_str,
	(case when ord.rst_start_date is not null and ord.rst_end_date is not null then(case when (((to_char(ord.rst_end_date,''dd''))::INTEGER -(to_char(ord.rst_start_date,''dd''))::INTEGER) *24*60
	+ ((to_char(ord.rst_end_date,''hh24''))::INTEGER -(to_char(ord.rst_start_date,''hh24''))::INTEGER) * 60
	+(to_char(ord.rst_end_date,''MI''))::INTEGER -(to_char(ord.rst_start_date,''MI''))::INTEGER )<=999 then (((to_char(ord.rst_end_date,''dd''))::INTEGER -(to_char(ord.rst_start_date,''dd''))::INTEGER) *24*60
	+ ((to_char(ord.rst_end_date,''hh24''))::INTEGER -(to_char(ord.rst_start_date,''hh24''))::INTEGER) * 60
	+(to_char(ord.rst_end_date,''MI''))::INTEGER -(to_char(ord.rst_start_date,''MI''))::INTEGER ) 
	else null end ) else null  end)::TEXT as running_time_str,
  RIGHT(''00''||TRUNC(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999'')/60,0),2)||'':''||RIGHT(''00''||MOD(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999''),60),2) as treatment_time,
  to_char(timestamp ''now'',''YYYYMMDDHH24MISS'') as nowtime14,
  ord.treat_date as treat_date,
  ord.ind_treat_start_time || ''00'' as ind_treat_start_time
from
  ord_main_restore as ord
where
  ord.ord_no = @ordNo
	and ord.rst_start_date is not null
	and ord.rst_end_date is not null
	and 0 = (	select
 count(rst_start_date)
from
  ord_main as ord
where
  ord.ord_no = @ordNo)
ORDER BY ord.del_date DESC LIMIT 1)
 ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '実績）透析開始終了日時変換', '2020-03-27 10:46:07', CURRENT_TIMESTAMP, NULL);
