select
    /*%expand "A" */*
from ord_main A
where
  facility_cd = /*facilityCd*/'000000'
and
  treat_date = /*treatDate*/'20190101'
and
  pat_id = /*patId*/0
and
  is_del = '0'
order by
  rst_start_date
;
