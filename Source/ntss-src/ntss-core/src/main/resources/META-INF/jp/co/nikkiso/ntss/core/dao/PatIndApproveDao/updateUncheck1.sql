UPDATE pat_ind_approve
SET 
	check_user1_cd = null,
	is_user1_checked = '0',
	check_user1_time = null,
	check_user2_cd = null,
	is_user2_checked = '0',
	check_user2_time = null,
	is_content_changed = '0',
	up_date = CURRENT_TIMESTAMP
WHERE 
	ord_no = /*ord_no*/0
	AND is_user1_checked = '1'
