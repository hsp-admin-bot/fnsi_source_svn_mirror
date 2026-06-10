update mnt_machine_state
set
  pat_id = /*patId*/null,
  next_patid = /*patId*/null,
  up_date = /*upDate*/null
where
  ord_no = /*ordNo*/null
and
  facility_cd = /*facilityCd*/'1'
and
  machine_type_cd = /*machineTypeCd*/'1'
and
  machine_serial = trim(/*machineSerial*/'1')
  ;
