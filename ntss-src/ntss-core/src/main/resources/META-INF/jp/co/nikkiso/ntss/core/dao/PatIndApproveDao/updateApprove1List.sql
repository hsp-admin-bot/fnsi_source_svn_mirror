UPDATE pat_ind_approve
SET 
  approve_user1_cd = /*patIndApproves.approve_user1_cd*/null,
  approve_user1_time = CURRENT_TIMESTAMP,
  is_user1_approved = '1',
  approve_content = /*patIndApproves.approve_content*/'{}',
  is_content_appd_changed = '0',
  up_date = CURRENT_TIMESTAMP
WHERE 
  ord_no = /*patIndApproves.ord_no*/0
