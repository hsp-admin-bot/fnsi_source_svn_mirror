update 
  ord_main
set
  ind_device_set_info = jsonb_merge_recursive(ind_device_set_info::jsonb, /* deviceSetInfo */null::jsonb),
  up_date = CURRENT_TIMESTAMP
where
  ord_no = /* ord_no */null