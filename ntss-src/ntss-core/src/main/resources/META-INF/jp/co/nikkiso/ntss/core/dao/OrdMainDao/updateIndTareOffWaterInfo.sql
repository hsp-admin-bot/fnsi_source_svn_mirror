UPDATE
  ord_main
SET
/*%if null != tareInfo*/
  ind_tare_info = jsonb_merge_recursive(ind_tare_info::jsonb, /*tareInfo*/'{}'::jsonb),
/*%end*/
/*%if null != offWaterInfo*/
  ind_off_water_info = jsonb_merge_recursive(ind_off_water_info::jsonb, /*offWaterInfo*/'{}'::jsonb),
/*%end*/
  up_date = /*upDate*/'0000-00-00 00:00:00.000'
WHERE
  ord_no = /*ordNo*/0
