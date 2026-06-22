select
  facility.facility_name,
  state.facility_cd,
  state.machine_type_cd,
  machine_type.machine_type,
  state.machine_serial,
  state.model,
  state.machine_name,
  state.bed_name,
  state.process_state,
  state.m_notice_cnt,
  state.preventive_mainte_cnt,
  state.is_preventive_mainte,
  machine.com_format_cd,
  machine.com_type,
  machine.device_edge_no,
  machine.is_ftp,
  machine.version
 
from
  mnt_machine_state state
    left outer join mst_facility facility 
      on state.facility_cd = facility.facility_cd
    left outer join mst_machine_type machine_type
      on state.machine_type_cd = machine_type.machine_type_cd
  left outer join mst_machine machine
    on state.facility_cd = machine.facility_cd
    and state.machine_type_cd = machine.machine_type_cd
    and state.machine_serial = machine.machine_serial

where 
  state.facility_cd = /*facilityCd*/'1'
  and
  state.machine_type_cd = /*machineTypeCd*/'1'
  and
  state.machine_serial = /*machineSerial*/'1'