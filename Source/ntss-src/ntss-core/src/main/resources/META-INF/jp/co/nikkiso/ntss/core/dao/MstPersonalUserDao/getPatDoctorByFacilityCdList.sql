SELECT
	user_id,
	personal_info_decrypt ( user_last_name ) AS user_last_name,
	personal_info_decrypt ( user_first_name ) AS user_first_name
FROM
	mst_personal_user
WHERE
	facility_cd in /*facilityCdList*/(0)
