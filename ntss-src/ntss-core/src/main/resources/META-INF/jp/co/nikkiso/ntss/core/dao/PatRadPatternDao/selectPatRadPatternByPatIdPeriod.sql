select
  A.rad_pattern_cd,
  A.pat_id,
  A.facility_cd,
  A.fn_pat_id,
  A.reg_rad_date,
  A.reg_order_class,
  A.rad_pattern,
  A.rad_week,
  A.rad_from,
  A.rad_to,
  A.order_rad_set_cd,
  A.is_del,
  A.reg_date,
  A.reg_staff,
  A.up_date,
  A.up_staff
from pat_rad_pattern A
where
  A.pat_id = /* patId */0
/*%if fromDt != null */
  and rad_to >= /* fromDt */'2099/12/31 23:59:59'
/*%end */
/*%if toDt != null */
  and rad_from <= /* toDt */'1970/01/01 00:00:00'
/*%end */
;
