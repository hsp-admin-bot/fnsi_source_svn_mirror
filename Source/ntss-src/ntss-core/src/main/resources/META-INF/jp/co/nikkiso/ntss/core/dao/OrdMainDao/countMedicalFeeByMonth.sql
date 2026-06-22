select 
	count(distinct o.treat_date)
from ord_main o,
(
	select 
		substring(max(concat(i.period_start_year, i.period_start_month)::bigint)::varchar,1,4) as date,
		substring(max(concat(i.period_start_year, i.period_start_month)::bigint)::varchar,5,2) as month
	from
		pat_unique u
			cross join lateral jsonb_to_recordset(u.in_out_visit_history_info) as i
			(
				period_start_month bigint,
				period_start_year bigint
			)
		where
			u.pat_id = /*patId*/0
			and u.is_del = '0'
			and i.period_start_month is not null
			and i.period_start_year is not null
) as d
join lateral jsonb_array_elements(o.addition_info) exp on exp->>'cd' =/*additionCd*/'0' 
where
	o.is_del = '0'
	and o.pat_id = /*patId*/0
	and o.facility_cd = /*facilityCd*/''
	and d.date::bigint = substring(o.treat_date,1,4)::bigint
	and d.month::bigint = substring(o.treat_date,5,2)::bigint
;