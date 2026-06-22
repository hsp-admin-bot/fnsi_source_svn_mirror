select
	case
		when count(distinct o.treat_date) = 1  then true
		when count(distinct o.treat_date) != 1  then false
	end
from ord_main o,
(
	select
-- mod #7218 2022-06-20 患者経過総合ビューアで手動実績作成しようとすると条件送信を実行できませんでしたと表示され実績作成ができない dou start
-- 		substring(max(concat(i.period_start_year, i.period_start_month)::bigint)::varchar,1,4) as date,
-- 		substring(max(concat(i.period_start_year, i.period_start_month)::bigint)::varchar,5,2) as month
		substring(max(concat(i.period_start_year, i.period_start_month)::varchar)::varchar,1,4) as date,
		substring(max(concat(i.period_start_year, i.period_start_month)::varchar)::varchar,5,2) as month
-- mod #7218 2022-06-20 患者経過総合ビューアで手動実績作成しようとすると条件送信を実行できませんでしたと表示され実績作成ができない dou end
	from
		pat_unique u
			cross join lateral jsonb_to_recordset(u.in_out_visit_history_info) as i
			(
-- mod #7218 2022-06-20 患者経過総合ビューアで手動実績作成しようとすると条件送信を実行できませんでしたと表示され実績作成ができない dou start
-- 				period_start_month bigint,
-- 				period_start_year bigint,
-- 				move_in_out smallint
				period_start_month varchar,
				period_start_year varchar,
				move_in_out varchar
-- mod #7218 2022-06-20 患者経過総合ビューアで手動実績作成しようとすると条件送信を実行できませんでしたと表示され実績作成ができない dou end
			)
		where
			u.pat_id = /*patId*/0
			and u.is_del = '0'
			and i.period_start_month is not null
			and i.period_start_year is not null
-- mod #7218 2022-06-20 患者経過総合ビューアで手動実績作成しようとすると条件送信を実行できませんでしたと表示され実績作成ができない dou start
-- 			and i.move_in_out = 1
			and i.move_in_out = '1'
-- mod #7218 2022-06-20 患者経過総合ビューアで手動実績作成しようとすると条件送信を実行できませんでしたと表示され実績作成ができない dou end
) as d
where
	o.is_del = '0'
	and d.date::bigint = substring(o.treat_date,1,4)::bigint
	and d.month::bigint = substring(o.treat_date,5,2)::bigint
	and o.ord_no = /*ordNo*/0
;
