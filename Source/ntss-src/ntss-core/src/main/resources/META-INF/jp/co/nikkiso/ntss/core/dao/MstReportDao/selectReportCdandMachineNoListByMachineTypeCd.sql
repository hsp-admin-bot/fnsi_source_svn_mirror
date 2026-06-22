WITH machine_tbl as (
    SELECT
		machine_no,
		machine_type_cd
    FROM
        mst_machine
	WHERE
		facility_cd = /* facilityCd */null
	AND machine_no in /* machineNos */(0)
	AND is_del = '0'
	AND is_disp = '1'
	ORDER BY machine_type_cd DESC
)
SELECT
	r.report_cd,
	table1.machine_no
FROM
	mst_report r,
	jsonb_to_record ( r.extraction_condition ) AS b ( machine_type_cd TEXT ),
	jsonb_to_record ( r.extraction_condition ) AS d ( layout_class TEXT ),
	machine_tbl table1
WHERE
	r.facility_cd = /* facilityCd */null
	AND b.machine_type_cd = table1.machine_type_cd
	AND d.layout_class = /* mainteClass */''
	AND r.is_del = '0'
	AND r.is_disp = '1'

