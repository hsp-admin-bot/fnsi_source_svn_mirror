select
  *
from
  mst_machine
where
  machine_type_cd = /*machine_type_cd*/'1'
and
  machine_serial = /*machine_serial*/'1'
and
  facility_cd = /*facility_cd*/'1'
;