select
  /*%expand "A" */*
from
  ord_main A
where
    pat_id = /*patId*/0
  /*%if toDate != null */
  and treat_date >= /*fromDate*/''
  and treat_date <= /*toDate*/''
  /*%else*/
  and treat_date = /*fromDate*/''
  /*%end*/
  and facility_cd = /*facilityCd*/'000000'
order by
  rst_end_date IS NOT NULL, rst_end_date DESC
;
