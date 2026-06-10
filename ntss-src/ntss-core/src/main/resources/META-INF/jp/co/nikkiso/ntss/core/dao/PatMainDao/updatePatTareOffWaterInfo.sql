
UPDATE
  pat_main
SET
/*%if null != tareInfo*/
  tare_info = jsonb_merge_recursive(tare_info::jsonb, /*tareInfo*/'{}'::jsonb),
/*%end*/
/*%if null != offWaterInfo*/
  off_water_info = jsonb_merge_recursive(off_water_info::jsonb, /*offWaterInfo*/'{}'::jsonb),
/*%end*/
  up_date = /*upDate*/'0000-00-00 00:00:00.000'
WHERE
/*%if null != patId*/
  pat_id = /*patId*/0
/*%end*/
/*%if null != facilityCd*/
AND
  facility_cd = /*facilityCd*/'000000'
/*%end*/