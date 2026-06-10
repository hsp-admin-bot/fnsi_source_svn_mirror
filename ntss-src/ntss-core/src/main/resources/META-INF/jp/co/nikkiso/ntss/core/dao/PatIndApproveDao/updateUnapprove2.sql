UPDATE pat_ind_approve
SET 
	approve_user2_cd = null,
	is_user2_approved = '0',
	approve_user2_time = null,
	up_date = CURRENT_TIMESTAMP,
	is_content_appd_changed = '0',
WHERE 
	ord_no = /*ord_no*/0
	AND is_user2_approved = '1'
