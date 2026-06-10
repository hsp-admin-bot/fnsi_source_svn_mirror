UPDATE "ntss"."sys_data_set" SET "sql" = 'select
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
	(case when ord.rst_start_date is not null and ord.rst_end_date is not null then(case when date_part(''day'', ord.rst_end_date - ord.rst_start_date) * 24 * 60 + date_part(''hour'', ord.rst_end_date - ord.rst_start_date)* 60 + date_part(''minute'', ord.rst_end_date - ord.rst_start_date)<=999 then date_part(''day'', ord.rst_end_date - ord.rst_start_date) * 24 * 60 + date_part(''hour'', ord.rst_end_date - ord.rst_start_date)* 60 + date_part(''minute'', ord.rst_end_date - ord.rst_start_date) else null end ) else null  end)::TEXT as running_time_str,
  RIGHT(''00''||TRUNC(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999'')/60,0),2)||'':''||RIGHT(''00''||MOD(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999''),60),2) as treatment_time,
  to_char(timestamp ''now'',''YYYYMMDDHH24MISS'') as nowtime14,
  ord.treat_date as treat_date,
  ord.ind_treat_start_time || ''00'' as ind_treat_start_time
from
  ord_main as ord
where
  ord.ord_no = @ordNo', "db_class" = 2, "detail" = '[{}]', "can_repeat" = '0', "use_application" = '{"applications": [4]}', "report_class" = NULL, "memo" = '実績）透析開始終了日時変換', "reg_date" = '2020-03-27 10:46:07', "up_date" = CURRENT_TIMESTAMP, "pre_sql_info" = NULL WHERE "sql_cd" = -14;
