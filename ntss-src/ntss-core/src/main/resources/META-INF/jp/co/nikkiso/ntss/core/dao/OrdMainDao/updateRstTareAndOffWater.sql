UPDATE
  ord_main
SET
/*%if null != tareInfo*/
  rst_tare_info = jsonb_merge_recursive(rst_tare_info, /*tareInfo*/'{}'::jsonb),
/*%end*/
/*%if null != offWaterInfo*/
  rst_off_water_info = jsonb_merge_recursive(rst_off_water_info, /*offWaterInfo*/'{}'::jsonb),
/*%end*/
  up_date = CURRENT_TIMESTAMP
WHERE
  ord_no = /*ordNo*/0
  