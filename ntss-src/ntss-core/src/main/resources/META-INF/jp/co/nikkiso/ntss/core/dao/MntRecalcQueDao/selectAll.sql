select
  /*%expand "A" */*
from
  mnt_recalc_que A
where
  A.disp_flg = '1'
;
