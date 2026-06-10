select
	count(*)
from ord_main o,
	(	
		select
			substring(detail.date from 1 for 4) as year,
			substring(detail.date from 6 for 2) as month,
			substring(detail.date from 9 for 2) as day
		from
		   mst_holiday h
		   cross join lateral jsonb_to_recordset(h.holiday_json) as detail
			 (
				 date text
			 )
		where
			h.is_disp = '1'
			and h.is_del = '0'
			and h.facility_cd in ('nkknkk', /*facilityCd*/'000000')
			and h.class = '0'
	)a
where 
		substring(o.treat_date from 1 for 4) = a.year
	and
		substring(o.treat_date from 5 for 2) = a.month
	and
		substring(o.treat_date from 7 for 2) = a.day
	and 
		o.ord_no = /*ordNo*/0
;