UPDATE pat_ind_approve
SET 
	approve_user2_cd = /*approve_user2_cd*/null,
	approve_user2_time = CURRENT_TIMESTAMP,
	is_user2_approved = '1',
	is_content_appd_changed = '0',
	up_date = CURRENT_TIMESTAMP,
	approve_content = /*approve_content*/'{}'
WHERE ord_no = /*ord_no*/0
