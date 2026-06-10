select
  /*%expand*/*
from
  pat_group
where
  pat_group_cd = /*patGroupCd*/null
and
  facility_cd = /*facilityCd*/null
;
