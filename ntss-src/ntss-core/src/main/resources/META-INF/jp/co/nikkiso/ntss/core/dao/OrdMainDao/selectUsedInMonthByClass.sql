select
	count(*)
from 
	(
		select
			ord.ord_no,
			ord.treat_date,
			j1.cd as cd
		from ord_main ord,
			jsonb_to_recordset(addition_info) as j1(
				cd bigint,
				name text,
				kind text
			)
		where
			ord.is_del = '0'
			and ord.facility_cd = /*facilityCd*/'000000'
			and ord.pat_id = /*patId*/0
			and extract(month from ord.treat_date::date) = extract(month from now())
 			and extract(year from ord.treat_date::date) = extract(year from now())
	) o
	inner join mst_addition ma on o.cd = ma.addition_cd
where 
	ma.is_del = '0'
	and ma.is_disp = '1'
	and ma.addition_kind = '1'
	and ma.addition_class = '12'
;