select
  ord_no
  , ind_treat_start_time
  , rst_cond_info
  , rst_dw
  , rst_treatment_cd
  , rst_treatment_name
  , up_date
  , reg_date
  -- add by chamaojia 2025-02-28 [11471] Add the return value of 【rst_device_mode】 --start
  , rst_device_mode as device_mode
  -- add by chamaojia 2025-02-28 [11471] Add the return value of 【rst_device_mode】 --end
from
  ord_main
where
  ord_no = /*ordNo*/1
and
  is_del = '0'
;
