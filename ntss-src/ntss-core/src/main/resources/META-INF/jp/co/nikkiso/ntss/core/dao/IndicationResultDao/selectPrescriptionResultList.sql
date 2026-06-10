select
  ord_prescription_no as unique_serial,
  issue_date as event_start_date,
  prescription_type as prescription_type,
  issue_state as issue_state,
  prescription_detail as json_value
from
  ord_prescription
where
  facility_cd = /*facilityCd*/1
and
  pat_id = /*patId*/1
/*%if treatDateFrom != null */
and
  issue_date >= /*treatDateFrom*/'00010101'
/*%end */
/*%if treatDateTo != null */
and
  issue_date <= /*treatDateTo*/'99991231'
/*%end */
and
  is_del = '0'
order by
  issue_date desc
