select
	pat_id,treat_date pat_name
from
	ord_main
where
	facility_cd = /*facilityCd*/''
	AND pat_id in /*patId*/(null)
	AND is_del = '0'
order by
/*%if "asc" != sortValue */
	treat_date DESC
/*%else*/
	treat_date ASC
/*%end*/
