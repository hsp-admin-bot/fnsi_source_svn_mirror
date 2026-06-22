update mnt_machine_state
set
  ord_no = /*machineState.ordNo*/1,
  next_ord_no = /*machineState.nextOrdNo*/1,
  pat_id = /*machineState.patId*/null,
  next_patid = /*machineState.nextPatid*/null,
  machine_status = /*machineState.machineStatus*/0,
  start_date = /*machineState.startDate*/'1970/01/01 00:00:00',
  end_date = /* machineState.endDate */'1970/01/01 00:00:00',
  up_date = /*machineState.upDate*/'1970/01/01 00:00:00',
  next_kur_cd= /*machineState.nextKurCd*/null,
  start_plan_date= /*machineState.startPlanDate*/'1970/01/01 00:00:00',
  end_plan_date= /*machineState.endPlanDate*/'1970/01/01 00:00:00',
  weigh_before_date= /*machineState.weighBeforeDate*/'1970/01/01 00:00:00',
  cond_send_date= /*machineState.condSendDate*/'1970/01/01 00:00:00',
  cond_set_date= /*machineState.condSetDate*/'1970/01/01 00:00:00',
  weigh_after_date= /*machineState.weighAfterDate*/'1970/01/01 00:00:00',
  is_pat_verified = /*machineState.isPatVerified*/'0',
  tmp_device_set_info= /*machineState.tmpDeviceSetInfo*/null
where
  facility_cd = /*machineState.facilityCd*/'1' and
  machine_type_cd = /*machineState.machineTypeCd*/'1' and
  machine_serial = trim(/*machineState.machineSerial*/'1')
;
