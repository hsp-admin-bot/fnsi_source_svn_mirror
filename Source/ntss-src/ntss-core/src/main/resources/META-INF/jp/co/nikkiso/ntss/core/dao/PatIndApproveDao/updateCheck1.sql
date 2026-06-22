UPDATE pat_ind_approve
SET 
  check_user1_cd = /*check_user1_cd*/null,
  check_user1_time = CURRENT_TIMESTAMP,
  is_user1_checked = '1',
  check_content = /*check_content*/'{}',
  is_content_changed = '0',
  up_date = CURRENT_TIMESTAMP
WHERE 
  ord_no = /*ord_no*/0