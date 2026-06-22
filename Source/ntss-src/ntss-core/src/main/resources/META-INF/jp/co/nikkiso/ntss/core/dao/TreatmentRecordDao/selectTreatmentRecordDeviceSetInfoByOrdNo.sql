select
--   add 10196 by kangjie 20240130 start del
--   rst_device_set_info
--   ,
--   add 10196 by kangjie 20240130 end del
  pat_id
  , facility_cd
from
  ord_main
where
  ord_no = /*ordNo*/1
and
  is_del = '0'
;
