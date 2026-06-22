select
  A.pat_id,
  substring(to_timestamp(A.event_start_date, 'YYYYMMDD')::text, 1, 10) as event_start_date,
  substring(to_timestamp(A.event_end_date, 'YYYYMMDD')::text, 1, 10) as event_end_date
from
  pat_event A
where
-- mod #10601 スケジュール表動作不正 start
  A.facility_cd = /*facilityCd*/null
and
  A.is_del = '0'
and
  (
    REPLACE(/* startDate */null, '/', '') <= A.event_end_date
    and
    A.event_start_date <= REPLACE(/* endDate */null, '/', '')
  )
--   A.is_del = '0'
-- and
--   A.facility_cd = /*facilityCd*/null
-- and
--   (
--     TO_TIMESTAMP(/* startDate */null, 'YYYY/MM/DD')::timestamp <= DATE_TRUNC('DAY', to_timestamp(A.event_end_date, 'YYYYMMDD'))
--     and
--     DATE_TRUNC('DAY', to_timestamp(A.event_start_date, 'YYYYMMDD')) <= TO_TIMESTAMP(/* endDate */null, 'YYYY/MM/DD')::timestamp
--   )
-- mod #10601 スケジュール表動作不正 end
;
