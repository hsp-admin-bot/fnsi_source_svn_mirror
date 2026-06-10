UPDATE pat_ind_approve
SET 
  approve_user1_cd = /*approve_user1_cd*/null,
  approve_user1_time = CURRENT_TIMESTAMP,
  is_user1_approved = '1',
  is_content_appd_changed = '0',
  up_date = CURRENT_TIMESTAMP,
  approve_content = /*approve_content*/'{}'
WHERE ord_no = /*ord_no*/0
