select
	count(1)
from
    ord_main
where
    pat_id = /*patId*/0
    and facility_cd = /*facilityCd*/'000000'
    and treat_date = /*baseDate*/null
    and ind_kur_cd <> 0
    and ind_kur_cd is not null
    and is_del = '0';