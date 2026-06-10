select
  /*%expand "A" */*
from
  mst_treatment_status_layout A
where
  A.layout_no = /*layoutNo */1
  and
  A.is_disp = '1'
  and
  A.is_del = '0'
;
