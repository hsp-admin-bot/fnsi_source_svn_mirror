select 
	count(*)
from (
	select
		distinct m1.effect_date::date as effect_date
	from ord_main om
		cross join lateral jsonb_to_recordset(om.rst_medi_info) as m1(
			cd text,
			effect_flg text,
			effect_date text
		)
	where 
		m1.cd = /*mediCd*/'0'
		and om.pat_id = /*patId*/0
) a
where
 	extract(month from a.effect_date) = extract(month from now())
 	and extract(year from a.effect_date) = extract(year from now())
;
