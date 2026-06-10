SELECT bed_list
FROM mst_room_bed_group
WHERE room_bed_group_cd in /* listBedGroupCd */(NULL)
    AND facility_cd = /*facilityCd*/NULL
	AND is_del = '0'
	AND is_disp = '1'
