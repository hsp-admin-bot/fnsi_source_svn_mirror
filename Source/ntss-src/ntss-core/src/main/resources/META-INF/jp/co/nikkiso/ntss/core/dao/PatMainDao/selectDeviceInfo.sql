select
  device_set_info /*%if null!= second_key*/-> /*second_key*/'{}' /*%end*/ as device_info
from
  pat_main
where
  pat_id = /*pat_id*/0
  
  