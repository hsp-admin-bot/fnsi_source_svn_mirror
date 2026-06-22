select
  A.rad_pattern_cd,
  A.pat_id,
  A.facility_cd,
  A.fn_pat_id,
  A.reg_rad_date,
  to_char(A.reg_rad_date, 'YYYYMMDD') as str_rad_date,
  to_char(A.reg_rad_date, 'HH24:MI') as str_rad_time,
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
  1 as status
from pat_rad_pattern A
where
  A.facility_cd = /*facilityCd*/'1'
  and
  A.is_del = '0'
  /*%if patIdList.size() != 0 */
  and A.pat_id in /* patIdList */(null)
  /*%end*/
  and A.rad_to >= TO_TIMESTAMP(/* startDate */null, 'YYYY/MM/DD')::timestamp
order by A.rad_pattern, A.rad_week, A.reg_rad_date
;
