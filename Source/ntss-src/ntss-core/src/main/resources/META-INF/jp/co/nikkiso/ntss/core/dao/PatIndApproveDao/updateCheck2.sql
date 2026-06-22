UPDATE pat_ind_approve
SET 
	check_user2_cd = /*check_user2_cd*/null,
	check_user2_time = CURRENT_TIMESTAMP,
	is_user2_checked = '1',
	is_content_changed = '0',
	up_date = CURRENT_TIMESTAMP,
	check_content = /*check_content*/'{}'
WHERE 
	ord_no = /*ord_no*/0
