select
   alive_moni_status
from
  mnt_device_edge_state
where
  facility_cd = /*facility_cd*/1
and
  device_edge_no = /*device_edge_no*/1
;
