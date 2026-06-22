update mnt_machine_state
set
  bed_cd = /*bedCd*/null,
  bed_name = /*bedNm*/null,
  -- add by chamaojia 2024-07-03 [10806] Update to supplement 【up_date】 --start
  up_date = CURRENT_TIMESTAMP
  -- add by chamaojia 2024-07-03 [10806] Update to supplement 【up_date】 --end
where
  facility_cd = /*facilityCd*/null
and
  machine_type_cd = /*machineTypeCd*/null
and
  trim(machine_serial) = trim(/*machineSerial*/null)
;
