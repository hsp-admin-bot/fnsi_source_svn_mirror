update mnt_machine_state
set
  ord_no = /*param.ordNo*/1,
  next_ord_no = /*param.nextOrdNo*/1,
  pat_id = /*param.patId*/null,
  next_patid = /*param.nextPatid*/null,
  machine_status = /*param.machineStatus*/0,
  start_date = /*param.startDate*/'1970/01/01 00:00:00',
  alarm_list = '{}'::JSONB,
  up_date = /*param.upDate*/'1970/01/01 00:00:00',
  next_kur_cd= /*param.nextKurCd*/null,
  start_plan_date= /*param.startPlanDate*/'1970/01/01 00:00:00',
  end_plan_date= /*param.endPlanDate*/'1970/01/01 00:00:00',
  weigh_before_date= /*param.weighBeforeDate*/'1970/01/01 00:00:00',
  cond_send_date= /*param.condSendDate*/'1970/01/01 00:00:00',
  cond_set_date= /*param.condSetDate*/'1970/01/01 00:00:00',
  end_date= /*param.endDate*/'1970/01/01 00:00:00',
  weigh_after_date= /*param.weighAfterDate*/'1970/01/01 00:00:00',
  tmp_device_set_info= /*param.tmpDeviceSetInfo*/null
where
  facility_cd = /*param.facilityCd*/'1' and
  machine_type_cd = /*param.machineTypeCd*/'1' and
  machine_serial = trim(/*param.machineSerial*/'1')
;
