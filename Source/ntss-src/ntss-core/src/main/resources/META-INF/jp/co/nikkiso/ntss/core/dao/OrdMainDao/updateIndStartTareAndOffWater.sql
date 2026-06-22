update ord_main
set
/*%if null != tareInfo*/
  ind_tare_info = /*tareInfo*/'{}',
/*%end*/
/*%if null != offWaterInfo*/
  ind_off_water_info = /*offWaterInfo*/'{}',
/*%end*/
  up_date = CURRENT_TIMESTAMP
where
  ord_no = /*ordNo*/0