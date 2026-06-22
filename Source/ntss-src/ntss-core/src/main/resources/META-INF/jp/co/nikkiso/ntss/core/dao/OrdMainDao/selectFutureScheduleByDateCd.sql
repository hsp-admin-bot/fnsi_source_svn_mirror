select
  /*%expand "A" */*
from
  ord_main A
where
/*%if facility_cd != null */
  facility_cd = /*facility_cd*/'000000'
/*%end*/
/*%if pat_id != null */
and
  pat_id = /*pat_id*/'000000000001'
/*%end*/
and
  treat_date >= to_char(CURRENT_DATE, 'yyyyMMdd')
and
  is_del = '0'
order by
  treat_date
;
