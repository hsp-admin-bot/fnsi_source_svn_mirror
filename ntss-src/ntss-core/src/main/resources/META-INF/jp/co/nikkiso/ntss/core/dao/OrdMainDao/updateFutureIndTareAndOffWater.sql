UPDATE
  ord_main
SET
/*%if null != tareInfo*/
  ind_tare_info = /*tareInfo*/'{}'::jsonb,
/*%end*/
/*%if null != offWaterInfo*/
  ind_off_water_info = /*offWaterInfo*/'{}'::jsonb,
/*%end*/
  up_date = /*upDate*/'0000-00-00 00:00:00.000'
WHERE
  pat_id = /*patId*/0
AND
  treat_date >= /*treatDate*/'00000000'
AND
  treat_week = /*treatWeek*/0
-- add FNSI-予定の場合はord_mainを更新する 趙 start
AND
  rst_dialysis_state = '0'
-- add FNSI-予定の場合はord_mainを更新する 趙 end
