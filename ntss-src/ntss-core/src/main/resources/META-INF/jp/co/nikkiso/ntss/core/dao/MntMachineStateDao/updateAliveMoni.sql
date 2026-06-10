UPDATE
  mnt_machine_state
SET
  process_state = /* machineState.processState */'99',
  is_preventive_mainte = /* machineState.isPreventiveMainte */1,
  up_date = /* machineState.upDate */null
WHERE
  facility_cd = /* machineState.facilityCd */'000001'
AND
  machine_type_cd = /* machineState.machineTypeCd */'001'
AND
  machine_serial = TRIM(/* machineState.machineSerial */'00000001')
