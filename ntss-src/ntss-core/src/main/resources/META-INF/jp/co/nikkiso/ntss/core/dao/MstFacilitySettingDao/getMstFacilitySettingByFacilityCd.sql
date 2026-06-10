SELECT
	mst.facility_setting_no,
	mst.facility_cd,
	mst."value",
	mst.reg_date,
	mst.up_date
FROM
	mst_facility_setting mst where mst.facility_cd=/*facilityCd*/'' and mst.facility_setting_no = '1038'

