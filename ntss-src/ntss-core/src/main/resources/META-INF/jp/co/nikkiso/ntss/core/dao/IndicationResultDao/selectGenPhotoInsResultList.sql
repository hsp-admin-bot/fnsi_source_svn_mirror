select
  to_char(reg_rad_date,'yyyyMMdd') as event_start_date,
  order_rad_set_info as json_value
from
  pat_rad_main
where
  facility_cd = /*facilityCd*/1
and
  pat_id = /*patId*/1
/*%if treatDateFrom != null */
and
  to_char(reg_rad_date,'yyyyMMdd') >= /*treatDateFrom*/'00010101'
/*%end */
/*%if treatDateTo != null */
and
  to_char(reg_rad_date,'yyyyMMdd') <= /*treatDateTo*/'99991231'
/*%end */
and
  is_del = '0'
order by
  reg_rad_date desc
