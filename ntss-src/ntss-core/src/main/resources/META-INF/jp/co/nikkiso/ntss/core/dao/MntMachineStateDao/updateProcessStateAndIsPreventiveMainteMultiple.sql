-- #9243 2023.07.31 add 複数装置の 工程状態 と 通信不良有無 の更新を1つのSQL文で実施 TDC山崎
update
  mnt_machine_state
set
  process_state = data_tbl.process_state,
  is_preventive_mainte = data_tbl.is_preventive_mainte,
  up_date = current_timestamp
from
(
  select * from
  (
    values
      /*%for param : paramList*/
      (
        /*param.processState*/1,
        /*param.isPreventiveMainte*/1,
        /*param.facilityCd*/'1',
        /*param.machineTypeCd*/'1',
        /*param.machineSerial*/'1'
      )
      /*%if param_has_next */
      /*# "," */
      /*%end*/
      /*%end*/
  ) as tmp(process_state, is_preventive_mainte, facility_cd, machine_type_cd, machine_serial)
) as data_tbl
where
  mnt_machine_state.facility_cd = data_tbl.facility_cd and
  mnt_machine_state.machine_type_cd = data_tbl.machine_type_cd and
  mnt_machine_state.machine_serial = data_tbl.machine_serial -- trimはjava側で実施
;
