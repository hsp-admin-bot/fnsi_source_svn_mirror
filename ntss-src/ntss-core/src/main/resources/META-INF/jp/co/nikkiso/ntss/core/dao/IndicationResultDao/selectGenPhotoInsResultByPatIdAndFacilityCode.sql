select
  to_char(reg_rad_date,'yyyyMMdd') as event_start_date
from
  pat_rad_main
where
  pat_id = /*patId*/1
and
  facility_cd = /*facilityCd*/1
and
  to_char(reg_rad_date,'yyyyMMdd') between /*treatDateFrom*/'20190620' and /*treatDateTo*/'20190621'
and
  is_del = '0'
