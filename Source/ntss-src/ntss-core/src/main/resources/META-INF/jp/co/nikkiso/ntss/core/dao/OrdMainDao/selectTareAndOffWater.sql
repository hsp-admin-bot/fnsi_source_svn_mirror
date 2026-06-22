select
/*%if flgIndRst == 0*/
  ind_tare_info as tare_info,
  ind_off_water_info as off_water_info,
  treat_week,
  pat_id as pat_id,
  rst_dialysis_state
/*%else*/
  rst_tare_info as tare_info,
  rst_off_water_info as off_water_info,
  treat_week,
  pat_id as pat_id,
  rst_dialysis_state
/*%end*/
from
  ord_main
where
  ord_no = /*ord_no*/0