update 
  pat_main
set
  device_set_info = jsonb_merge_recursive(device_set_info::jsonb, /* deviceSetInfo */null::jsonb),
  up_date = CURRENT_TIMESTAMP
where
/*%if patId != null*/
  pat_id = /* patId */null
/*%else*/
  facility_cd = /*facilityCd*/null
/*%end*/