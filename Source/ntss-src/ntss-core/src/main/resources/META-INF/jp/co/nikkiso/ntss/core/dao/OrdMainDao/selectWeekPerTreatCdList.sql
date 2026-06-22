select
  json_build_object(
    'ind_treatment_cd', B.ind_treatment_cd,
    'treat_week', json_agg(B.treat_week)
  ) ord_main_list
from (
  select distinct
    A.ind_treatment_cd,
    A.treat_week
  from
    ord_main A
  where
    A.is_del = '0'
  and
    A.pat_id = /*pat_id*/0
  and
    A.facility_cd = /*facility_cd*/'0'
  and
    A.treat_date >= /*dialysis_date_from*/'00000000'
  /*%if null != dialysis_date_to*/
  and
    A.treat_date <= /*dialysis_date_to*/'00000000'
  /*%end*/
  /*%if null != rst_dialysis_state */
  and
    A.rst_dialysis_state = /*rst_dialysis_state*/'0'
  /*%end*/
  order by
    A.ind_treatment_cd,
    A.treat_week
) B
GROUP BY B.ind_treatment_cd
;
