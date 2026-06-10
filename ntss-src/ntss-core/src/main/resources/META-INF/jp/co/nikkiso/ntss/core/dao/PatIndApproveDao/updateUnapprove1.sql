UPDATE pat_ind_approve
SET 
	approve_user1_cd = null,
	is_user1_approved = '0',
	approve_user1_time = null,
	approve_user2_cd = null,
	is_user2_approved = '0',
	approve_user2_time = null,
	is_content_appd_changed = '0',
	up_date = CURRENT_TIMESTAMP
WHERE 
	ord_no = /*ord_no*/0
	AND is_user1_approved = '1'
