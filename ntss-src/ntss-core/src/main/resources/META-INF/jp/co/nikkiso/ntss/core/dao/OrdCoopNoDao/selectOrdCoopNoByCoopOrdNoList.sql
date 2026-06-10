select
  /*%expand*/*
from
	ord_coop_no
where
	is_del = '0'

    and is_disp='1'

    and ord_no in /* ordNoSet */(0)

    and facility_cd =/*facilityCd*/'1'

    and ord_no is not null

    and pat_id is not null
