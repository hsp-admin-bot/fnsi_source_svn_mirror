select
  /*%expand "A" */*
from
  sys_medicine A
where
  1 = 1
/*%if null != keyword && "isNullOrEmpty" != keyword */
  and A.sales_name LIKE '%' || /* keyword */null || '%'
/*%end*/
order by
  A.standard_no
/*%if limit > 0*/
 limit /*limit*/0
/*%end*/
/*%if offset > 0*/
 offset /*offset*/0
/*%end*/
;
