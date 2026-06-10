select
  tare_info -> /*dayOfWeekTare*/'1' as tare_info,
  off_water_info -> /*dayOfWeekOffWater*/'1' as off_water_info
from pat_main
where
  is_del = '0' and
  pat_id = /*patId*/3
;
