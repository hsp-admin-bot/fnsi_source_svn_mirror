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
  A.up_staff,
  A.ind_user_id
from pat_rad_pattern A
where
  A.pat_id = /* patId */null
and
  is_del = '0'
and
  to_char(A.rad_from,'YYYY-MM-DD') <=  /* toDate */null
and
  to_char(A.rad_to,'YYYY-MM-DD') >=  /* fromDate */null
;
