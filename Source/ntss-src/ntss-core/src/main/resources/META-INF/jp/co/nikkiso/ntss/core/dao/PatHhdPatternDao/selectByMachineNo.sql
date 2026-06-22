select
  /*%expand "A" */*
from
  pat_hhd_pattern A
where
  A.facility_cd = /*facility_cd*/null
And
  A.machine_no = /*rst_machine_no*/null
order by
  A.revision desc