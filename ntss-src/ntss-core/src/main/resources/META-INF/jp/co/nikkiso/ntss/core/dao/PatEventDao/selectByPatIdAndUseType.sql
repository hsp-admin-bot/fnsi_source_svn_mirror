select
  substring(to_timestamp(A.event_start_date, 'YYYYMMDD')::text, 1, 10) as event_start_date
from
  pat_event A
where
  A.pat_id = /*patId*/0
and
  A.facility_cd = /*facilityCd*/NULL
and
  A.use_type = '1'
and
  A.is_del = '0'
order by
  ORDER BY up_date desc LIMIT 1
;
