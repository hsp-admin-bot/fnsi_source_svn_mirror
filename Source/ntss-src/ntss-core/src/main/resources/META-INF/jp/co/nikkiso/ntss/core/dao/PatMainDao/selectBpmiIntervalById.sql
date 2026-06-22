select
  host_notification_info#>>'{bpmi,interval}' as bpmi_interval
from
  pat_main
where
      is_del = '0'
  and pat_id = /* patId */1
  and host_notification_info#>>'{bpmi,judge}' = 'true'
;