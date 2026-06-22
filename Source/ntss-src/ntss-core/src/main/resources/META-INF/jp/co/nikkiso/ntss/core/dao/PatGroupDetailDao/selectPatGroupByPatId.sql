select
  A.pat_group_cd, B.pat_group_name
from
  pat_group_detail as A LEFT JOIN pat_group as B ON A.pat_group_cd = B.pat_group_cd
where
  B.is_del = '0' and
  A.pat_id = /*patId*/null
 ;