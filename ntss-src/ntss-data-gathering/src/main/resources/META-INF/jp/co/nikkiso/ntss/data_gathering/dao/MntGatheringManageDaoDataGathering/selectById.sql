SELECT
	/*%expand  "A" */*
FROM
	mnt_gathering_manage A
WHERE
	/*%if -1L != gatheringManageNo */
	A.gathering_manage_no = /* gatheringManageNo */1
	/*%end*/
ORDER BY
	A.gathering_manage_no
