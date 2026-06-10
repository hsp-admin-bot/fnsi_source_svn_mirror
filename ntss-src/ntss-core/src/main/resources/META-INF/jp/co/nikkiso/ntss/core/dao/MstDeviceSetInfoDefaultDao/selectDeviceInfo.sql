select
  device_set_info /*%if null != first_key*/-> /*first_key*/'' /*%if null != second_key*/-> /*second_key*/'' /*%end*/ /*%end*/ as device_info
from
--  mst_device_set_info_default
  mst_device_set_info_default
where
  facility_cd = /*facility_cd*/'0'
