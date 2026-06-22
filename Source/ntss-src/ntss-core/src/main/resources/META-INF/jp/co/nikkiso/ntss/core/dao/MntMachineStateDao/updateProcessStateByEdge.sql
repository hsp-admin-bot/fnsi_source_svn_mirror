update
  mnt_machine_state
set
  process_state = /* machineState.processState */'99',
  is_preventive_mainte = /* machineState.isPreventiveMainte */1,
  up_date = /* machineState.upDate */null
from
  (
  select
    mm.facility_cd,
    mm.machine_type_cd,
    mm.machine_serial
  from
    mst_machine mm
  where
    mm.facility_cd = /* machineState.facilityCd */'0'
    and
    mm.device_edge_no = /* deviceEdgeNo */'1'
    and
    /*%if isExcludeOffline */
    mm.com_format_cd <> 'F'
    and
    mm.com_type <> 0
    and
    /*%end */
    mm.is_disp = '1'
    and
    mm.is_del = '0'
  ) mm2
where
  mnt_machine_state.facility_cd = mm2.facility_cd
  and mnt_machine_state.machine_type_cd = mm2.machine_type_cd
  and mnt_machine_state.machine_serial = mm2.machine_serial
;