

SELECT
		tmpTable.machine_no,
		tmpTable.machine_type_cd,
		tmpTable.machine_serial,
		tmpTable.machine_name,
		tmpTable.version,
		mst_machine_type.machine_type,
		mst_bed.bed_name

FROM (SELECT
		*
FROM
		mst_machine
WHERE
		machine_no = /* machineNo*/'0') AS tmpTable
CROSS JOIN mst_machine_type
LEFT OUTER JOIN
mst_bed
ON
tmpTable.machine_no = mst_bed.machine_no
AND
mst_bed.is_disp = '1'
AND
mst_bed.is_del = '0'
WHERE
		mst_machine_type.machine_type_cd = tmptable.machine_type_cd


