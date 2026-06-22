UPDATE
  ord_main
SET
/*%if null != tareInfo*/
  ind_tare_info = jsonb_merge_recursive(ind_tare_info::jsonb, /*tareInfo*/'{}'::jsonb),
/*%end*/
/*%if null != offWaterInfo*/
  ind_off_water_info = jsonb_merge_recursive(ind_off_water_info::jsonb, /*offWaterInfo*/'{}'::jsonb),
/*%end*/
  -- add 10196 by kangjie 20240124 start
--   up_date = /*upDate*/'0000-00-00 00:00:00.000'
    up_date =CURRENT_TIMESTAMP
--     del 11119 by kangjie 20241007 start
-- ,up_ind_user_id = /*indUser*/0
--     del 11119 by kangjie 20241007 end
  -- add 10196 by kangjie 20240124 end
WHERE
  ord_no in /*ordNoList*/()
