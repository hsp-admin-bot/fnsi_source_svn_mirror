select
  tare_info as tare_info,
  off_water_info as off_water_info
from
  mst_device_set_info_default
where
  facility_cd = /*facility_cd*/'0'