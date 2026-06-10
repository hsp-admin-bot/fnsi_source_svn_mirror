select
  /*%expand "A" */*
from
  ord_main A
 where
  pat_id = /*pat_id*/'000000000001'
 and
  dialysis_date >= /*dialysis_date_from*/'20010101'
 and 
  dialysis_date <= /*dialysis_date_to*/'20991231'
 and
  EXTRACT(ISODOW FROM to_date(dialysis_date, 'yyyyMMdd')) in /* weeks_array */(1,2,3,4,5,6,7)
 and 
  kur_cd = /*kur_cd*/'0'
 and 
  treat_item_cd = /*treat_item_cd_before*/'0'
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