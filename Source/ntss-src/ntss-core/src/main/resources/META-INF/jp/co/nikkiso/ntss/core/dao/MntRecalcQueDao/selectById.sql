select
  /*%expand "A" */*
from
  mnt_recalc_que A
where
  A.disp_flg = '1'
    /*%if recalcQueCd != null */
  AND
    A.recalc_que_cd = /* recalcQueCd */0
    /*%end */
    limit 1
select
  /*%expand "A" */*
from
  mnt_recalc_que A
where
  A.disp_flg = '1'
    /*%if recalcQueCd != null */
  AND
    A.recalc_que_cd = /* recalcQueCd */0
    /*%end */
    limit 1
