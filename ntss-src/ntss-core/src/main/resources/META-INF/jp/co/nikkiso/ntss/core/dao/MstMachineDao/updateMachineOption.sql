UPDATE mst_machine
SET
  up_date = /*param.upDate*/'1970/01/01 00:00:00',
  machine_option = /*param.machineOption*/'{}'
WHERE
  facility_cd = /* param.facilityCd */'1'
AND
  machine_no = /*param.machineNo*/1
AND
  device_edge_no = /*param.deviceEdgeNo*/1
;