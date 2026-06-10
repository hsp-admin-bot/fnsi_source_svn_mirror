update
  mnt_motion_record
set
  ord_no = null,
  up_date = /*upDate*/null

where
  facility_cd = /*facilityCd*/'1'
  and
  machine_type_cd = /*machineTypeCd*/'1'
  and
  machine_serial = /*machineSerial*/'1'
  and
  ord_no = /*ordNo*/0

;
