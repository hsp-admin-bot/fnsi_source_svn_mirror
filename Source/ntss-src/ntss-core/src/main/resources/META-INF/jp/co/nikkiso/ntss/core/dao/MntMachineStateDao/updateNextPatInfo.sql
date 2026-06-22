update mnt_machine_state
set
  next_ord_no = /*nextOrdNo*/null,
  next_patid = /*nextPatid*/null,
  next_kur_cd = /*nextKurCd*/null,
  start_plan_date = /*startPlanDate*/null,
	up_date = /*upDate*/null
where
	facility_cd = /*facilityCd*/null
and
	machine_type_cd = /*machineTypeCd*/null
and
	machine_serial = trim(/*machineSerial*/null)
;
