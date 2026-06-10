SELECT CAST
	( A.comsv_cd AS BIGINT ) AS comsv_cd,
	A.device_edge_no,
	A.facility_cd
FROM
	mst_comsv_setting
	A LEFT JOIN (
	SELECT
		mss.facility_cd,
		ms.*,
		ROW_NUMBER ( ) OVER ( ) AS INDEX
	FROM
		mst_selector mss
		CROSS JOIN LATERAL jsonb_to_recordset ( mss.order_settings -> 'items' ) AS ms ( code BIGINT, NAME TEXT )
	WHERE
		facility_cd = /*facilityCd*/'999999'
		AND master_physical_name = 'mst_comsv_setting' --テーブル名

	) ms ON A.facility_cd = ms.facility_cd
	AND A.comsv_cd = ms.code
WHERE
	A.facility_cd = /*facilityCd*/'999999'
	and A.is_disp = '1'
	and A.is_del = '0'
	ORDER BY  ms.INDEX
;
