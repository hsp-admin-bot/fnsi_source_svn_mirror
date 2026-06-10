insert into mnt_motion_record 
  (event_reg_date, facility_cd, device_edge_no, machine_type_cd, machine_serial, com_format_cd, data_type, machine_record_message, contents, reg_date, up_date)
  values
  (
  /*param.eventRegDate*/'2018-01-01 00:00:00', 
  /*param.facilityCd*/'1', 
  /*param.deviceEdgeNo*/'1', 
  /*param.machineTypeCd*/'1', 
  /*param.machineSerial*/'0', 
  /*param.comFormatCd*/'0', 
  /*param.dataType*/'1', 
  /*param.machineRecordMessage*/'0', 
  /*param.contents*/'{"0":"1"}'::JSONB,
  CURRENT_TIMESTAMP, 
  CURRENT_TIMESTAMP)
  ;