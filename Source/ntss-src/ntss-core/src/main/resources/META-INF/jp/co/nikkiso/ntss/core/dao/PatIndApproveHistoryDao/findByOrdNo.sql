select /*%expand "A" */*
from pat_ind_approve_history A
where ord_no = /* ordNo */0
and
  approve_kind in
  /*%if kind.equals("approve") */
    ('3','4')
  /*%elseif kind.equals("check") */
    ('1','2')
  /*%else */
    (null)
  /*%end*/
/*# orderBy */;
