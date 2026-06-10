UPDATE pat_ind_approve
SET
  is_content_changed_for_map = /*param.is_content_changed_for_map*/'0',
  content_for_map = /*param.content_for_map*/'{}',
  up_date = /*param.upDate*/null
WHERE ord_no = /*param.ord_no*/0
