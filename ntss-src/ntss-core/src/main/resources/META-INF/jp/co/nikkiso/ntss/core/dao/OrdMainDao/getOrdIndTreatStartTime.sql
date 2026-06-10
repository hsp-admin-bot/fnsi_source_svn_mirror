select
	ind_treat_start_time
from
	ord_main 
where
	is_del = '0'
and
	ord_no = /*ordNo*/0
;