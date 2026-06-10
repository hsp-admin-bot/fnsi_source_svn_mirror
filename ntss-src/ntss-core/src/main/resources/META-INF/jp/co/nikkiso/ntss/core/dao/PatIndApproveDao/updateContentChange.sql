UPDATE pat_ind_approve
SET
  is_content_changed = '1',
  is_content_appd_changed = '1',
  is_content_changed_for_map = '1',
  up_date = /*param.upDate*/null
WHERE ord_no = /*param.ord_no*/0
;
