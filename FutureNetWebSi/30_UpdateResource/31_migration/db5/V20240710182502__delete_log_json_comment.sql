DELETE FROM 
	log_json_comment
where
	(
	tbl_name ='mst_kur'
	and col_name = 'mst_user_authentication'
	and json_key_name in (
		'data-All-disp_user_id'
		, 'data-Satur-disp_user_id'
		, 'data-Sun-disp_user_id'
		, 'data-Mon-disp_user_id'
		, 'data-Thurs-disp_user_id'
		, 'data-Wednes-disp_user_id'
		, 'data-Tues-disp_user_id'
		, 'data-Fri-disp_user_id'
		)
	)
	or(
	tbl_name = 'mst_report'
	and col_name ='report_hst_info'
	and json_key_name = 'items-upd_user_id'
	);