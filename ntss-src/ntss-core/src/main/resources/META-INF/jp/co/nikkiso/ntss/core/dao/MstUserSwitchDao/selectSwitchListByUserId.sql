SELECT
	switch_id,
	facility_cd,
	user_id,
	group_id,
	opt_status
FROM
	mst_user_switch
WHERE
	group_id = (
	SELECT
	group_id
FROM
	mst_user_switch
WHERE
	user_id = /*userId*/0
	)
	and user_id != /*userId*/0
