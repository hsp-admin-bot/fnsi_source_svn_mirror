
update
  mnt_machine_state MNT
set
  process_state = /*mntParams.processState*/null,
  is_preventive_mainte = /*mntParams.isPreventiveMainte*/0,
  up_date = /*mntParams.upDate*/null
from
  (select facility_cd, machine_type_cd, machine_serial from mst_machine
    where facility_cd = /*facilityCd*/'1' and machine_no in /*codeList*/(null)) MST
where
  MNT.facility_cd = MST.facility_cd
  and MNT.machine_type_cd = MST.machine_type_cd
  and MNT.machine_serial = MST.machine_serial
;
