update
  mst_device_set_info_default
set
  device_set_info = jsonb_merge_recursive(device_set_info::jsonb, /* deviceSetInfo */null::jsonb),
  up_date = CURRENT_TIMESTAMP
where
  facility_cd = /* facility_cd */null