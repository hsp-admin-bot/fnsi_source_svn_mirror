INSERT INTO
	mnt_gathering_manage
	(
		gathering_manage_no,
		facility_cd,
		gathering_status,
		gathering_info,
		ope_info,
		parent_manage_no,
		user_id,
		reg_date,
		up_date
	)
VALUES
	(
		/* gatheringManage.gatheringManageNo */1,
		/* gatheringManage.facilityCd */'000001',
		/* gatheringManage.gatheringStatus */0,
		jsonb(/* gatheringManage.gatheringInfo */null),
		/* gatheringManage.opeInfo */0,
		/* gatheringManage.parentManageNo */1,
		/* gatheringManage.userId */null,
		/* gatheringManage.regDate */null,
		/* gatheringManage.upDate */null
	)
