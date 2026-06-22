select
  pat_event_cd as unique_serial
  , event_start_date
  , event_end_date
  , event_start_time
  , event_end_time
  , category_name
  , sub_category_name
from
  pat_event
where
  facility_cd = /*facilityCd*/1
and
  pat_id = /*patId*/1
/*%if treatDateFrom != null */
and
  event_start_date >= /*treatDateFrom*/'00010101'
/*%end */
/*%if treatDateTo != null */
and
  event_start_date <= /*treatDateTo*/'99991231'
/*%end */
and
  is_del = '0'
order by
  event_start_date desc,
  event_start_time desc
