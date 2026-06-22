select
  facility.department_cd,
  facility.facility_cd,
  facility.facility_name,
  facility.facility_name_kana,
  device_edge.serial_no,
  device_edge.device_edge_no,
  device_edge.device_name,
  state.alive_moni_status,
  state.alive_moni_status_change_date,
  facility.prefectures_cd,
  prefecture.pref_name,
  to_char(state.last_moni_time, 'yyyy/MM/dd HH24:MI:SS') as last_moni_time

from
  mst_device_edge device_edge

  left outer join mst_facility facility
    on device_edge.facility_cd = facility.facility_cd

  left outer join mnt_device_edge_state state
    on device_edge.device_edge_no = state.device_edge_no and
       device_edge.facility_cd = state.facility_cd

  left outer join sys_prefectures prefecture
    on facility.prefectures_cd = prefecture.pref_cd

where
  device_edge.facility_cd in /*facilityCds*/('1', '2')

order by
  facility.department_cd asc,
  facility.facility_name asc,
  device_edge.device_name asc

;