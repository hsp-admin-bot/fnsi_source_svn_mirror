select
  /*%expand*/*
from
  pat_group
where
pat_group_cd = /*patGroupCd*/1
   and facility_cd = /*facilityCd*/'000000'
   and is_del = '0'
;
