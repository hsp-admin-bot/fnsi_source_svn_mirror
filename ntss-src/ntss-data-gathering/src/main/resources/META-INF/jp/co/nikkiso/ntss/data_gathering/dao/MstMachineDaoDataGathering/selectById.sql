SELECT
	/*%expand  "A" */*
FROM
	mst_machine A
WHERE
	A.facility_cd = /* facilityCd */'000001'
AND
	/*%if -1 != deviceEdgeNo */
	A.device_edge_no = /* deviceEdgeNo */1
AND
  /*%else*/
  device_edge_no IN
  (
    SELECT
      device_edge_no
    FROM
      mst_device_edge
    WHERE
      facility_cd = /* facilityCd */'000001'
    AND
      device_edge_no IS NOT NULL
    AND
      is_disp = '1'
    AND
      is_del = '0'
  )
AND
  /*%end*/
	/*%if null != machineTypeCd && null != machineSerial */
	machine_type_cd = /* machineTypeCd */'001'
AND
	machine_serial = /* machineSerial */'0000001'
AND
	/*%end*/
	A.ip_address IS NOT NULL
ORDER BY
	A.device_edge_no,
	A.machine_type_cd,
	A.machine_serial
