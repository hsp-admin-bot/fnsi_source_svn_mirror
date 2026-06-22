UPDATE pat_main
SET
  device_set_info =  jsonb_merge_recursive(device_set_info::jsonb, /*deviceInfo*/'{}'::jsonb),
  up_date = CURRENT_TIMESTAMP
WHERE
/*%if null != patId*/
  pat_id = /*patId*/1
AND
/*%end*/
/*%if null != facilityCd*/
  facility_cd = /*facilityCd*/'000000'
/*%end*/