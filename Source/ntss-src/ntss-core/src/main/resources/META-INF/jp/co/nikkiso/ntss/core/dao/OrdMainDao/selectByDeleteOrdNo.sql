select
  /*%expand "A" */*
from
  ord_main A
where
/*%if null != ord_no */
  ord_no = /*ord_no*/'1'
/*%else*/
  pat_id = /*pat_id*/'0'
and
  treat_date >= /*dialysis_date_from*/'00000000'
  /*%if null != dialysis_date_to*/
and
  treat_date <= /*dialysis_date_to*/'00000000'
  /*%end*/
and
  is_del = '0'
  /*%if 0 < treatment_cd.size() */
    and
      ind_treatment_cd in /*treatment_cd*/(0)
  /*%end*/
  /*%if 0 < kur_cd.size() */
    and
      ind_kur_cd in /*kur_cd*/(0)
  /*%end*/
/*%end*/
