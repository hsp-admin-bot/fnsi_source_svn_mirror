update mnt_machine_state
set
    tmp_device_set_info = /*jsonCondData*/'{}'
  ,up_date = current_timestamp
where
        facility_cd = /*facilityCd*/'1'
  and
        machine_type_cd = /*machineTypeCd*/'1'
  and
        machine_serial = /*machineSerial*/'1'
