update pat_main
set
/*%if null != tareInfo*/
  tare_info = /*tareInfo*/'{}',
/*%end*/
/*%if null != offWaterInfo*/
  off_water_info = /*offWaterInfo*/'{}',
/*%end*/
  up_date = CURRENT_TIMESTAMP
where
  pat_id = /*patId*/0