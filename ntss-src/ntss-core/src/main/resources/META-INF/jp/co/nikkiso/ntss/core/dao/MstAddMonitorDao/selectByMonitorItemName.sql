select
  /*%expand "A" */*
from
  mst_add_monitor A
where
--     mod #10077 by zhangruixue 2024-01-04 --start
--   A.vital_monitor_item_name = /*vitalMonitorItemName*/0
    A.vital_monitor_item_cd = CAST(/*vitalMonitorItemName*/0 AS INTEGER) - 10000
--     mod #10077 by zhangruixue 2024-01-04 --end
  AND A.facility_cd = /*facilityCd*/'0'
  AND A.is_disp = '1'
  AND A.is_del = '0'
  limit 1
;
