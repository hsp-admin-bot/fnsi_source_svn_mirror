UPDATE
  ord_main
SET
/*%if null != tareInfo*/
  rst_tare_info = jsonb_merge_recursive(jsonb_merge_recursive(rst_tare_info, (json_build_object('before', /*tareInfo*/'{}'::jsonb))::jsonb), json_build_object('after', /*tareInfo*/'{}'::jsonb)::jsonb),
/*%end*/
/*%if null != offWaterInfo*/
  rst_off_water_info = jsonb_merge_recursive(rst_off_water_info, /*offWaterInfo*/'{}'::jsonb),
/*%end*/
  up_date = /*upDate*/'0000-00-00 00:00:00.000'

WHERE
  ord_no = /*ordNo*/0
