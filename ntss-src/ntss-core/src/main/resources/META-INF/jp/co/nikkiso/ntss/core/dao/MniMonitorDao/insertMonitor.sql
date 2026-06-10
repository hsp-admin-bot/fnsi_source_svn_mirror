insert into mni_monitor
  (facility_cd,
  machine_type_cd,
  machine_serial,
  data_type,
  monitor_data,
  occur_date,
  reg_date,
  up_date,
  ord_no,
  pat_id)
select
  /*param.facilityCd*/'999000',
  /*param.machineTypeCd*/'1',
  /*param.machineSerial*/'1',
  /*param.dataType*/0,
  /*param.monitorData*/'{"0":"1"}'::JSONB,
  /*param.occurDate*/'2018-01-01 00:00:00'::Timestamp,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  ord_no,
  pat_id
from
  mnt_machine_state
where
  facility_cd = /*param.facilityCd*/'999000'
  and machine_type_cd = /*param.machineTypeCd*/'002'
  and machine_serial = trim(/*param.machineSerial*/'TDC0002')
UNION ALL
-- SELECT結果がゼロ件でもord_no以外の値を挿入する
select
  /*param.facilityCd*/'999000',
  /*param.machineTypeCd*/'1',
  /*param.machineSerial*/'1',
  /*param.dataType*/0,
  /*param.monitorData*/'{"0":"1"}'::JSONB,
  /*param.occurDate*/'2018-01-01 00:00:00'::Timestamp,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  null,
  null
where
 NOT EXISTS(
select
  facility_cd
from
  mnt_machine_state
where
  facility_cd = /*param.facilityCd*/'999000'
  and machine_type_cd = /*param.machineTypeCd*/'002'
  and machine_serial = trim(/*param.machineSerial*/'TDC0002'))
;
