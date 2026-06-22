select
  A.pat_id,
  to_char(A.reg_rad_date, 'YYYYMMDD') as str_rad_date
from
  pat_rad_main A
where
  A.is_del = '0'
and
  A.facility_cd = /*facilityCd*/null
and
  DATE_TRUNC('DAY', A.reg_rad_date) >= TO_TIMESTAMP(/* startDate */null, 'YYYY/MM/DD')::timestamp
and
  DATE_TRUNC('DAY', A.reg_rad_date) <= TO_TIMESTAMP(/* endDate */null, 'YYYY/MM/DD')::timestamp
;
