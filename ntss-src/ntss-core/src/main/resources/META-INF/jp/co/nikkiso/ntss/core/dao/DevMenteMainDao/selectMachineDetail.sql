

SELECT
		tmpTable.machine_no,
		tmpTable.machine_type_cd,
		tmpTable.machine_serial,
		tmpTable.machine_name,
		mst_machine_type.machine_type

FROM (SELECT
		*
FROM
		mst_machine
WHERE
		machine_no = /* machineNo*/'0') AS tmpTable
CROSS JOIN mst_machine_type
WHERE
		mst_machine_type.machine_type_cd = tmptable.machine_type_cd


