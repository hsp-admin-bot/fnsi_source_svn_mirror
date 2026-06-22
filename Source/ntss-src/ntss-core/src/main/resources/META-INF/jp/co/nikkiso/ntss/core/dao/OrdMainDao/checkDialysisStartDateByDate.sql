select
	case
		when count(distinct o.treat_date) = 1  then true
		when count(distinct o.treat_date) != 1  then false
	end
from ord_main O,
(
	select
		max(I.period_start_date) as dilysis_start_date
	from
		pat_unique U
			cross join lateral jsonb_to_recordset(U.in_out_visit_history_info) as I
			(
				ctl_no bigint,
				period_start_date date,
-- mod #7218 2022-06-20 患者経過総合ビューアで手動実績作成しようとすると条件送信を実行できませんでしたと表示され実績作成ができない dou start
-- 				period_start_day bigint,
-- 				period_start_month bigint,
-- 				period_start_year bigint,
-- 				move_in_out smallint
				period_start_day varchar,
				period_start_month varchar,
				period_start_year varchar,
				move_in_out varchar
-- mod #7218 2022-06-20 患者経過総合ビューアで手動実績作成しようとすると条件送信を実行できませんでしたと表示され実績作成ができない dou end
			)
		where
			U.pat_id = /*patId*/0
			and U.is_del = '0'
			and (I.period_start_day is not null)
			and I.period_start_month is not null
			and I.period_start_year is not null
-- mod #7218 2022-06-20 患者経過総合ビューアで手動実績作成しようとすると条件送信を実行できませんでしたと表示され実績作成ができない dou start
-- 			and I.move_in_out = 1
			and I.move_in_out = '1'
-- mod #7218 2022-06-20 患者経過総合ビューアで手動実績作成しようとすると条件送信を実行できませんでしたと表示され実績作成ができない dou end
) as D
where
	O.is_del = '0'
	and (
		o.treat_date::date < (d.dilysis_start_date +interval '1 month')::date
		or
		(
			o.treat_date::date = (d.dilysis_start_date +interval '1 month')::date
			and (
				extract(month from d.dilysis_start_date) = '1'
				and extract(day from d.dilysis_start_date) in (30, 31)
				and extract(day from o.treat_date::date) in (29)
			)
		)
		or
		(
			o.treat_date::date = (d.dilysis_start_date +interval '1 month')::date
			and (
				extract(month from d.dilysis_start_date) = '1'
				and extract(day from d.dilysis_start_date) in (29, 30, 31)
				and extract(day from o.treat_date::date) in (28)
			)
		)
	)
	and O.treat_date::date >= D.dilysis_start_date
	and O.ord_no = /*ordNo*/0
;
