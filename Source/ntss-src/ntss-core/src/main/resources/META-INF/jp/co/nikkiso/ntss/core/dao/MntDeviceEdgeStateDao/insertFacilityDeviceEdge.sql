insert into
	mnt_device_edge_state
	(
		facility_cd,
		device_edge_no,
		alive_moni_status,
		last_moni_time,
		reg_date,
		up_date
	)
values
	(
		/* facilityCd */null,
		/* deviceEdgeNo */null,
		'F0',
    current_timestamp,
    current_timestamp,
    current_timestamp
	)
