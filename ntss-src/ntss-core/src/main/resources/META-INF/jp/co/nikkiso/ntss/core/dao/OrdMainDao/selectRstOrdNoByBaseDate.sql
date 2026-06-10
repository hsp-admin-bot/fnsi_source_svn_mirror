select
	*
from
    ord_main
where
    pat_id = /*patId*/0
    and facility_cd = /*facilityCd*/'000000'
    and treat_date = /*baseDate*/'20250529'
    and is_del = '0'
order by treat_date,ord_no desc limit 1;
