select
	/*%expand "A" */*
from
	ntss.pat_group A
	,(
		select code, row_number() over() as index
		from ntss.mst_selector mss
		cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
		(
			code bigint,
			name text
		)
		where
			facility_cd = /* facilityCd */'000000'
			and master_physical_name = 'pat_group'
	) ms
	where
		A.facility_cd = /* facilityCd */'000000'
	and
		A.pat_group_cd = ms.code --コードのカラム
	and
		A.is_del = '0'
	and
		A.is_disp = '1'
order by
	ms.index
;