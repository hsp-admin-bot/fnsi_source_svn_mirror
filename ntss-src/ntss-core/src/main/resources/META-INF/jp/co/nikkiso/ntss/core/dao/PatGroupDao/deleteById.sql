update pat_group
set
  is_del = 1
where
  pat_group_cd = /*patGroupId*/null
;