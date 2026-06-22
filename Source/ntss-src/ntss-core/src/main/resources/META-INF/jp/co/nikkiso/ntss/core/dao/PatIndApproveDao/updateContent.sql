UPDATE pat_ind_approve
SET
  check_content = /*param.check_content*/'{}',
  approve_content = /*param.approve_content*/'{}',
  up_date = CURRENT_TIMESTAMP
WHERE ord_no = /*param.ord_no*/0
