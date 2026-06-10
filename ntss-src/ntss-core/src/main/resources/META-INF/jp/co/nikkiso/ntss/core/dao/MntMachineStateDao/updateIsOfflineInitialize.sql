update
  mnt_machine_state
set
  is_offline = sub.default_is_offline
from (
  select
    case mm.com_format_cd = 'F' and mm.com_type = 0 when true then '1' else '0' end as default_is_offline,
    mm.facility_cd,
    mm.machine_type_cd,
    mm.machine_serial
  from
    mst_machine mm
  where
    mm.facility_cd = /*facilityCd*/'1' and
    mm.machine_type_cd = /*machineTypeCd*/'1' and
    mm.machine_serial =  trim(/*machineSerial*/'1')
) as sub
where
  mnt_machine_state.facility_cd = sub.facility_cd and
  mnt_machine_state.machine_type_cd = sub.machine_type_cd and
  mnt_machine_state.machine_serial = sub.machine_serial
;
