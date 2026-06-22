update mst_machine_record_control
set
  machine_record_message = /* mstMachineRecordControl.machineRecordMessage  */null,
  disp_flg = /* mstMachineRecordControl.dispFlg  */null,
  -- machine_flg = /* mstMachineRecordControl.machineFlg  */null,
  -- alarm_flg = /* mstMachineRecordControl.alarmFlg  */null,
  up_date = /* mstMachineRecordControl.upDate */null
where
  machine_record_cd = /* mstMachineRecordControl.machineRecordCd */null
and
  facility_cd =  /* mstMachineRecordControl.facilityCd */null
;