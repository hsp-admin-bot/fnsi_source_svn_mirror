UPDATE
	mnt_gathering_manage
SET
	gathering_status = /* gatheringManage.gatheringStatus */0,
	gathering_info = (/* gatheringManage.gatheringInfo */null)::jsonb,
	up_date = /* gatheringManage.upDate */null
WHERE
	gathering_manage_no = /* gatheringManage.gatheringManageNo */1
