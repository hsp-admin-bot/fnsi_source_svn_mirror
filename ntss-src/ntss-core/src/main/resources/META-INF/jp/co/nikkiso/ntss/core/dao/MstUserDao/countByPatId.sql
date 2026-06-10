select
  count(pat_id)
from
  mst_user
where
  pat_id = /*patId*/1
and
  is_disp = '1'
and
  is_del = '0'
;
