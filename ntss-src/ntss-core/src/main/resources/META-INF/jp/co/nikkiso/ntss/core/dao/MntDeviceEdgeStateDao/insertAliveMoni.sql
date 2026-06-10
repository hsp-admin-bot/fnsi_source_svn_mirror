INSERT INTO
	mnt_device_edge_state
	(
		facility_cd,
		device_edge_no,
		alive_moni_status,
		version_information,
		last_moni_time,
		reg_date,
		up_date
	)
VALUES
	(
		/* deviceEdgeState.facilityCd */'000001',
		/* deviceEdgeState.deviceEdgeNo */1,
		/* deviceEdgeState.aliveMoniStatus */'01',
		jsonb(/* deviceEdgeState.versionInformation */null),
		/* deviceEdgeState.lastMoniTime */null,
		/* deviceEdgeState.regDate */null,
		/* deviceEdgeState.upDate */null
	)
