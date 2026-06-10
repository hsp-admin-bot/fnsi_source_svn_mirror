select
  mac.machine_option
from
  mst_machine mac,ord_main ord
where
  ord.ord_no = /*ordNo*/1
and
  mac.facility_cd = ord.facility_cd
and
  mac.is_disp = '1'
and
  mac.is_del = '0'
