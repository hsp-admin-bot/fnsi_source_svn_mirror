select
	ma.addition_short_name
from
	mst_addition ma
	inner join 
	(	
		select
		 o.ord_no as ord_no,
		 j1.cd as cd,
		 j1.name as name,
		 j1.kind as kind
		from ord_main o,
		  jsonb_to_recordset(addition_info) 
			as j1(
				cd bigint,
				name text,
				kind text
			)
		where
			o.is_del = '0'
			and o.facility_cd = /*facilityCd*/'000000'
			and o.ord_no = /*ordNo*/0
			and o.pat_id = /*patId*/0
	) a 
	on ma.addition_cd = a.cd
where
    ma.is_del = '0'
order by 
    ma.addition_cd
;

