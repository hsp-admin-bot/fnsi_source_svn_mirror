select
  /*%expand "A" */*
from
  ord_main A
where
  is_del = '0'
and
  pat_id = /*pat_id*/0
/*%if null != facility_cd */
and
  facility_cd = /*facility_cd*/'0'
/*%end*/
and
  treat_date >= /*dialysis_date_from*/'00000000'
/*%if null != dialysis_date_to*/
and
  treat_date <= /*dialysis_date_to*/'00000000'
/*%end*/
/*%if null != rst_dialysis_state */
and
  rst_dialysis_state = /*rst_dialysis_state*/'0'
/*%end*/
/*%if null != treatment_cd */
and
  ind_treatment_cd = /*treatment_cd*/0
/*%end*/
/*%if 0 < treat_week.size() */
and
  treat_week in /*treat_week*/(0)
/*%end*/
/*%if true == hasIndKurCd */
and
  ind_kur_cd <> 0
/*%end*/
;
