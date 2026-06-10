select
	distinct on (extract(month from to_date(treat_date, 'yyyyMMdd'))) treat_date
from
	ord_main
where
	facility_cd = /*facilityCd*/'-1'
	and
	pat_id = /*patId*/'-1'
	and
	to_char(to_date(treat_date, 'yyyyMMdd'), 'yyyyMM') >= to_char(to_date(/*treatDateStart*/'19700101', 'yyyyMMdd'), 'yyyyMM')
	and
	to_char(to_date(treat_date, 'yyyyMMdd'), 'yyyyMM') <= to_char(to_date(/*treatDateEnd*/'19700101', 'yyyyMMdd'), 'yyyyMM')
	and
	is_del = '0'
order by
	extract(month from to_date(treat_date, 'yyyyMMdd')) desc,
	treat_date desc
;