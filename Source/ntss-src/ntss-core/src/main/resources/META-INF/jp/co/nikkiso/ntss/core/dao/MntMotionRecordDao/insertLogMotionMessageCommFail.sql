insert into mnt_motion_record
  (event_reg_date, facility_cd,
  device_edge_no, machine_type_cd,
  machine_serial, com_format_cd,
  data_type, machine_record_cd,
  machine_record_message,
  machine_record_aux_data,
  log_type,
  report_disp_flg,
  ord_no,
  reg_date, up_date)
  select
  /*param.eventRegDate*/'2018-01-01 00:00:00'::Timestamp,
  /*param.facilityCd*/'1',
  /*param.deviceEdgeNo*/'1',
  /*param.machineTypeCd*/'1',
  /*param.machineSerial*/'0',
  /*param.comFormatCd*/'0',
  /*param.dataType*/'1',
  /*param.machineRecordCd*/'0',
  /*param.machineRecordMessage*/'message',
  /*param.machineRecordAuxData*/'0',
  /*param.logType*/0,
  /*param.reportDispFlg*/'0',
  ord_no,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
from
  tmp_comm_failure_recovery
where
  facility_cd = /*param.facilityCd*/'999000'
  and machine_type_cd = /*param.machineTypeCd*/'002'
  and machine_serial = trim(/*param.machineSerial*/'TDC0002')
UNION ALL
-- SELECT結果がゼロ件でもord_no以外の値を挿入する
select
  /*param.eventRegDate*/'2018-01-01 00:00:00'::Timestamp,
  /*param.facilityCd*/'1',
  /*param.deviceEdgeNo*/'1',
  /*param.machineTypeCd*/'1',
  /*param.machineSerial*/'0',
  /*param.comFormatCd*/'0',
  /*param.dataType*/'1',
  /*param.machineRecordCd*/'0',
  /*param.machineRecordMessage*/'message',
  /*param.machineRecordAuxData*/'0',
  /*param.logType*/0,
  /*param.reportDispFlg*/'0',
  null,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
where
 NOT EXISTS(
select
  facility_cd
from
  tmp_comm_failure_recovery
where
  facility_cd = /*param.facilityCd*/'999000'
  and machine_type_cd = /*param.machineTypeCd*/'002'
  and machine_serial = trim(/*param.machineSerial*/'TDC0002'))
;
