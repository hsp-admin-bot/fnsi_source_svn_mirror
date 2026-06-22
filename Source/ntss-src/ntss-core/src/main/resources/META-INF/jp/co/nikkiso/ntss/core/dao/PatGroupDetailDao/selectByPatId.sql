select
  a.pat_group_cd, a.pat_id
from
  pat_group_detail as a left join pat_group as b on a.pat_group_cd = b.pat_group_cd
where
  b.is_del = '0' and
  pat_id = /*patId*/null
;
