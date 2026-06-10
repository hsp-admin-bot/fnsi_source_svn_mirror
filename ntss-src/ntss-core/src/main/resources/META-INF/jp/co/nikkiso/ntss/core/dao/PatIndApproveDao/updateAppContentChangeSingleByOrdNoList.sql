UPDATE pat_ind_approve
SET
  is_content_changed = '1',
  is_content_appd_changed = '1',
  up_date = current_timestamp
WHERE ord_no in /*ordNos*/(null)
;
