update ord_main
set
  bvms_path = /*bvmsPath*/'',
  up_date = CURRENT_TIMESTAMP
where
  ord_no = /*ordNo*/null
;
