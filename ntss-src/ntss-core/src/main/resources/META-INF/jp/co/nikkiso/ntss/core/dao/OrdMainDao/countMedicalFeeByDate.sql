select 
	count(distinct o.treat_date)
from ord_main o,
(
	select
		max(i.period_start_date) as dilysis_start_date
	from
		pat_unique u
			cross join lateral jsonb_to_recordset(u.in_out_visit_history_info) as i
			(
				period_start_date date,
				period_start_day bigint,
				period_start_month bigint,
				period_start_year bigint
			)
		where
			u.pat_id = /*patId*/0
			and u.is_del = '0'
			and (i.period_start_day is not null)
			and i.period_start_month is not null
			and i.period_start_year is not null
) as d
join lateral jsonb_array_elements(o.addition_info) exp on exp->>'cd' =/*additionCd*/'0'
where
	o.is_del = '0'
	and o.pat_id = /*patId*/0
	and o.facility_cd = /*facilityCd*/''
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
	and o.treat_date::date >= d.dilysis_start_date
;