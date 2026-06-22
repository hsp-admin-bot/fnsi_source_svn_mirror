-- #9111 2023.07.14 add 複数装置の 装置ステータス の更新を1つのSQL文で実施 TDC山崎
update
  mnt_machine_state
set
  machine_status = data_tbl.machine_status,
  up_date = current_timestamp
from
(
  select * from
  (
    values
      /*%for param : paramList*/
      (
        /*param.machineStatus*/1,
        /*param.facilityCd*/'1',
        /*param.machineTypeCd*/'1',
        /*param.machineSerial*/'1'
      )
      /*%if param_has_next */
      /*# "," */
      /*%end*/
      /*%end*/
  ) as tmp(machine_status, facility_cd, machine_type_cd, machine_serial)
) as data_tbl
where
  mnt_machine_state.facility_cd = data_tbl.facility_cd and
  mnt_machine_state.machine_type_cd = data_tbl.machine_type_cd and
  mnt_machine_state.machine_serial = data_tbl.machine_serial -- trimはjava側で実施
;
