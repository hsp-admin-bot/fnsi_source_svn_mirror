select
  ord_no
  , rst_start_date
  , rst_end_date
  , rst_complaint_info
  , rst_treatment_info
  , rst_treat_staff_info
  , up_date
  , reg_date
from
  ord_main
where
  ord_no = /*ordNo*/1
and
  is_del = '0'
;
