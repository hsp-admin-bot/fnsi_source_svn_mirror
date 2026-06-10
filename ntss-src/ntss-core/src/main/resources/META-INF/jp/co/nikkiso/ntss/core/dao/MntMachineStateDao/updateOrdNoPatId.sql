update mnt_machine_state
set
  ord_no = /*baseordNo*/null,
  next_ord_no = /*baseordNo*/null,
  pat_id = /*patId*/null,
  next_patid = /*patId*/null,
  up_date = /*upDate*/null
where
  ord_no = /*ordNo*/null
and
  facility_cd = /*facilityCd*/null
and
  machine_type_cd = /*machineTypeCd*/null
and
  machine_serial = /*machineSerial*/null
;