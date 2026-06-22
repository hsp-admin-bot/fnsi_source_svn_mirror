select
  pat_id,
  host_notification_info
from
  pat_main
where
  pat_id in /*patIdList*/(null)
;
