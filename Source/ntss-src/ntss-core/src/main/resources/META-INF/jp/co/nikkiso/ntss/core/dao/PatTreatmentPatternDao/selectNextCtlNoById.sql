select
  case
    when MAX(A.ctl_no) is null then 1
    else MAX(A.ctl_no) + 1
  end ctl_no
from
  pat_treatment_pattern A
where
  A.pat_id = /*pat_id*/null
