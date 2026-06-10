WITH sql1 AS (
	SELECT
		t2.mainte_layout_group_cd,
		t2.mainte_layout_group_edition,
		t2.mainte_layout_cd,
		t2.detail,
		t2.machine_no
	FROM
		mnt_mainte_main t2
	WHERE
		t2.mainte_class = /* mainteClass */''
		AND t2.machine_no in /* machineNos */(0)
		AND t2.mainte_date between date_trunc('day', /* fromDate */'' ::timestamp ) and date_trunc('day', /* toDate */'' ::timestamp) + '1 days - 1 milliseconds'
		AND t2.is_del = '0'
		AND t2.facility_cd = /* facilityCd*/'00000'
		/*%if mainteClass == "1"*/
        AND t2.mainte_ans_1 is not null
		AND t2.mainte_ans_1<>''
        /*%end*/
)

SELECT
	r.report_cd,
	table1.machine_no
FROM
	mst_report r,
	jsonb_to_record ( r.extraction_condition ) AS b ( mainte_layout_cd TEXT ),
	jsonb_to_record ( r.extraction_condition ) AS d ( layout_class TEXT ),
	(
		SELECT
			CAST( sql1.mainte_layout_cd AS TEXT ),
			m2.machine_name,
			m2.machine_serial,
			m2.machine_no,
			mt2.machine_type
		FROM
			mst_mainte_layout_group t3,
			mst_mainte_layout_group_hst t4,
			sql1,
			mst_machine m2,
			mst_machine_type mt2
		WHERE
			(
			CASE
				WHEN sql1.detail IS NULL
				THEN sql1.mainte_layout_group_cd = t3.mainte_layout_group_cd
				ELSE sql1.mainte_layout_group_cd = t4.mainte_layout_group_cd
				AND sql1.mainte_layout_group_edition = t4.edition_no
			END
			)
			AND t3.mainte_layout_group_cd = t4.mainte_layout_group_cd
			AND sql1.machine_no = m2.machine_no
			AND m2.machine_type_cd = mt2.machine_type_cd
		UNION ALL
		SELECT
			CAST( t1.mainte_layout_cd AS TEXT ),
			m1.machine_name,
			m1.machine_serial,
			m1.machine_no,
			mt1.machine_type
		FROM
			mnt_mainte_main t1,
			mst_machine m1,
			mst_machine_type mt1
		WHERE
			t1.mainte_class = /* mainteClass */''
			AND t1.machine_no in /* machineNos */(0)
			AND t1.mainte_date between date_trunc('day', /* fromDate */'' ::timestamp ) and date_trunc('day', /* toDate */'' ::timestamp) + '1 days - 1 milliseconds'
			AND t1.facility_cd = /* facilityCd*/'00000'
			AND t1.is_del = '0'
			/*%if mainteClass == "1"*/
            AND t1.mainte_ans_1 is not null
			AND t1.mainte_ans_1<>''
            /*%end*/
			AND t1.machine_no = m1.machine_no
			AND m1.machine_type_cd = mt1.machine_type_cd
	) table1
WHERE
	b.mainte_layout_cd = table1.mainte_layout_cd
	AND r.is_del = '0'
	AND r.is_disp = '1'
	AND d.layout_class = /* mainteClass */''
