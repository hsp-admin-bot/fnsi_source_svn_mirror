select 
  state.use_time,
  machine.com_format_cd,
  machine.com_type
 
from
  mnt_machine_state state
  left outer join mst_machine machine on
    state.facility_cd = machine.facility_cd
    and
    state.machine_type_cd = machine.machine_type_cd
    and
    state.machine_serial = machine.machine_serial
    
  
where
  state.facility_cd = /*facilityCd*/'1'
  and
  state.machine_type_cd = /*machineTypeCd*/'1'
  and
  state.machine_serial = /*machineSerial*/'1'
  
;