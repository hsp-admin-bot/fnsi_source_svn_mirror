select
    /*%expand "A" */*
from ord_main A
where
  facility_cd = /*facilityCd*/'000000'
and
  treat_date > /*startDate*/'20190101'
and
  treat_date < /*endDate*/'20190101'
and
  pat_id = /*patId*/0
and
  is_del = '0'
order by
  treat_date
;
