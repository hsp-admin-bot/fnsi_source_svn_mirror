DELETE from sys_data_set where sql_cd= -499;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-499, 'select
		replace(max(I.period_start_date)::text,''-'','''') as dialysis_start_date
	from
		pat_unique U
			cross join lateral jsonb_to_recordset(U.in_out_visit_history_info) as I
			(ctl_no bigint,
			period_start_date date,
			period_start_day bigint,
			period_start_month bigint,
			period_start_year bigint,
			move_in_out smallint
 			)
 		left join ord_main ord on ord.pat_id = U.pat_id 
		where
			ord.ord_no = @ordNo
			and U.is_del = ''0''
			and (I.period_start_day is not null)
			and I.period_start_month is not null
			and I.period_start_year is not null
			and I.move_in_out = 1', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'で送信する透析導入日', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
