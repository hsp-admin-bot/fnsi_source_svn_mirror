select
  A.rad_result_cd,
  A.pat_id,
  A.facility_cd,
  A.fn_pat_id,
  A.reg_rad_date,
  A.reg_order_class,
  A.rad_status,
  A.order_rad_set_info,
  A.cop_order_no1,
  A.cop_order_no2,
  A.is_lock,
  A.ind_user_id,
  A.is_del,
  A.reg_date,
  A.reg_staff,
  A.up_date,
  A.up_staff
from pat_rad_main A
where
  A.rad_result_cd = /* radResultCd */-1
;
