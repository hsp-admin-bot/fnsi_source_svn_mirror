select
  /*%expand "A" */*
from
  ord_main A
where
/*%if pat_id != null */
  pat_id = /*pat_id*/'000000000001'
  /*%if null !=  treat_date_from */
and
  treat_date >= /*treat_date_from*/'20180220'
  /*%end*/
  /*%if null != treat_date_to */
and
  treat_date <= /*treat_date_to*/'20180226'
  /*%end*/
/*%elseif null != ord_no */
  ord_no = /*ord_no*/1
/*%end*/
/*%if null != edition */
and
  edition = /*edition*/1
/*%end*/
/*%if null != is_del */
and
  is_del = /*is_del*/'0'
/*%end*/
order by
  dialysis_date, edition, start_date
;
