select
	/*%expand "A" */*
from
	mst_addition A
	,(
		select
			mss.facility_cd, ms.*, row_number() over() as index
		from
			mst_selector mss
		cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
		(
			code text,
			name text
		)
		where
		/*%if facilityCd != null */  
			facility_cd = /* facilityCd */'0'
		and
		/*%end */
			master_physical_name = 'mst_addition'
	) ms
	where
		A.facility_cd = ms.facility_cd
	and
		A.addition_cd::text = ms.code --コードのカラム
	/*%if !additionClass.size() == 0 */
	and 
		A.addition_class in /* additionClass */('')
	/*%end */
	and
		A.is_del = '0'
	and
		A.is_disp = '1'
order by
	ms.index,
	A.addition_kind asc NULLS LAST
;