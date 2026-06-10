SELECT
	serial_no,
	facility_cd,
	device_edge_no
FROM
	mst_device_edge
WHERE
	serial_no = /* serialNo */null
