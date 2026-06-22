select
 j1.cd as cd,
 j1.name as name,
 j1.is_enable as is_enable,
 j1.start_date As start_date
from ord_main o,
  jsonb_to_recordset(addition_info) 
	as j1(
		cd bigint,
		name text,
		is_enable text,
		start_date text
	)
where
	o.is_del = '0'
	and o.facility_cd = /*facilityCd*/'000000'
	and o.ord_no = /*ordNo*/0
	and o.pat_id = /*patId*/0
;