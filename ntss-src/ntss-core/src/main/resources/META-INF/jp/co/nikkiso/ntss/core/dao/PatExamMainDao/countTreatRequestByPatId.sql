select count(distinct u.treat_date)
from
(
	select o.treat_date
	from 
		pat_exam_main e
	cross join
		ord_main o
	where 
		o.ord_no = /*ordNo*/0
		and e.is_del = '0'
		and e.is_order = '1'
		and e.pat_id = /*patId*/0
		and e.facility_cd = /*facilityCd*/'000000'
		and lpad(cast(extract(year from e.reg_exam_date) as text),4,'0')  = substring(o.treat_date from 1 for 4)
		and lpad(cast(extract(month from e.reg_exam_date) as text),2,'0') = substring(o.treat_date from 5 for 2)
		and lpad(cast(extract(day from e.reg_exam_date) as text),2,'0')   = substring(o.treat_date from 7 for 2)
	union
	select o.treat_date
	from 
		pat_rad_main r
	cross join
		ord_main o
	where 
		o.ord_no = /*ordNo*/0
		and r.is_del = '0'
		and r.pat_id = /*patId*/0
		and r.facility_cd = /*facilityCd*/'000000'
		and lpad(cast(extract(year from r.reg_rad_date) as text),4,'0')  = substring(o.treat_date from 1 for 4)
		and lpad(cast(extract(month from r.reg_rad_date) as text),2,'0') = substring(o.treat_date from 5 for 2)
		and lpad(cast(extract(day from r.reg_rad_date) as text),2,'0')   = substring(o.treat_date from 7 for 2)
) u