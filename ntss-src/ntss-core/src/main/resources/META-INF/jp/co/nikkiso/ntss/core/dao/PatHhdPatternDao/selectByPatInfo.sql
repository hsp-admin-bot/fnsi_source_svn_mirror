select
  /*%expand "A" */*
from
  pat_hhd_pattern A
where
  A.facility_cd = /*facility_cd*/null
and
  A.pat_id = /*pat_id*/null
and
  A.ind_treat_start_date <= /*current_date*/null
ORDER BY
  A.ind_treat_start_date DESC,
  A.revision DESC