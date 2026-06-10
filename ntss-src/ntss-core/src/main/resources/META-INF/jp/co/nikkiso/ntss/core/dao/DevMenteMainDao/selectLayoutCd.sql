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
		t2.mainte_class = '2'
		AND t2.machine_no = /* machineNo*/0
		AND t2.mainte_date = /* menteDate*/''
		AND t2.is_disp = '1'
		AND t2.is_del = '0'
	) SELECT
	r.report_cd
FROM
	mst_report r,
	jsonb_to_record ( r.extraction_condition ) AS b ( mainte_layout_cd TEXT ),
	(
	SELECT CAST
		( sql1.mainte_layout_cd AS TEXT ),
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

				WHEN sql1.detail IS NULL THEN
				sql1.mainte_layout_group_cd = t3.mainte_layout_group_cd ELSE sql1.mainte_layout_group_cd = t4.mainte_layout_group_cd
				AND sql1.mainte_layout_group_edition = t4.edition_no
			END
			)
			AND t3.mainte_layout_group_cd = t4.mainte_layout_group_cd
			AND sql1.machine_no = m2.machine_no
			AND m2.machine_type_cd = mt2.machine_type_cd UNION ALL
		SELECT CAST
			( t1.mainte_layout_cd AS TEXT ),
			m1.machine_name,
			m1.machine_serial,
			m1.machine_no,
			mt1.machine_type
		FROM
			mnt_mainte_main t1,
			mst_machine m1,
			mst_machine_type mt1
		WHERE
			t1.mainte_class = '1'
			AND t1.machine_no = /* machineNo*/0
			AND t1.mainte_date = /* menteDate*/''
			AND t1.is_disp = '1'
			AND t1.is_del = '0'
			AND t1.machine_no = m1.machine_no
			AND m1.machine_type_cd = mt1.machine_type_cd
		) table1
	WHERE
	b.mainte_layout_cd = table1.mainte_layout_cd
	AND r.is_del = '0'
	order by
	/*%if null != firstName */
	/*%if "装置番号" == firstName && "asc" == firstOrd*/
	 table1.machine_no asc
	/*%elseif "装置番号" == firstName && "desc" == firstOrd*/
	 table1.machine_no desc
	/*%elseif "装置名称" == firstName && "asc" == firstOrd*/
	 table1.machine_name asc
	/*%elseif "装置名称" == firstName && "desc" == firstOrd*/
	 table1.machine_name desc
	/*%elseif "製造番号" == firstName && "asc" == firstOrd*/
	 table1.machine_serial asc
	/*%elseif "製造番号" == firstName && "desc" == firstOrd*/
	 table1.machine_serial desc
	/*%elseif "型式名" == firstName && "asc" == firstOrd*/
	 table1.machine_type asc
	/*%elseif "型式名" == firstName && "desc" == firstOrd*/
	 table1.machine_type desc
	/*%end*/
	/*%end*/
/*%if null != secondName */
	/*%if "装置番号" == secondName && "asc" == secondOrd*/
	, table1.machine_no asc
	/*%elseif "装置番号" == secondName && "desc" == secondOrd*/
	, table1.machine_no desc
	/*%elseif "装置名称" == secondName && "asc" == secondOrd*/
	, table1.machine_name asc
	/*%elseif "装置名称" == secondName && "desc" == secondOrd*/
	, table1.machine_name desc
	/*%elseif "製造番号" == secondName && "asc" == secondOrd*/
	, table1.machine_serial asc
	/*%elseif "製造番号" == secondName && "desc" == secondOrd*/
	, table1.machine_serial desc
	/*%elseif "型式名" == secondName && "asc" == secondOrd*/
	, table1.machine_type asc
	/*%elseif "型式名" == secondName && "desc" == secondOrd*/
	, table1.machine_type desc
	/*%end*/
	/*%end*/
	/*%if null != thirdName */
	/*%if "装置番号" == thirdName && "asc" == thirdOrd*/
	, table1.machine_no asc
	/*%elseif "装置番号" == thirdName && "desc" == thirdOrd*/
	, table1.machine_no desc
	/*%elseif "装置名称" == thirdName && "asc" == thirdOrd*/
	, table1.machine_name asc
	/*%elseif "装置名称" == thirdName && "desc" == thirdOrd*/
	, table1.machine_name desc
	/*%elseif "製造番号" == thirdName && "asc" == thirdOrd*/
	, table1.machine_serial asc
	/*%elseif "製造番号" == thirdName && "desc" == thirdOrd*/
	, table1.machine_serial desc
	/*%elseif "型式名" == thirdName && "asc" == thirdOrd*/
	, table1.machine_type asc
	/*%elseif "型式名" == thirdName && "desc" == thirdOrd*/
	, table1.machine_type desc
	/*%end*/
	/*%end*/

