UPDATE
  tmp_comm_failure_recovery
SET
  ord_no = /* param.ordNo */null,
  pat_id = /* param.patId */null,
  next_ord_no = /* param.nextOrdNo */null,
  next_patid = /* param.nextPatid */null,
  start_date = /* param.startDate */null,
  end_date = /* param.endDate */null,
  up_date = /* param.upDate */null
WHERE
  facility_cd = /* param.facilityCd */'000001'
AND
  machine_type_cd = /* param.machineTypeCd */'001'
AND
  machine_serial = TRIM(/* param.machineSerial */'00000001')
