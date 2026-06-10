select
  card_idm
from
  pat_main A
where
  A.is_del = '0'
and
  A.pat_id = /* patId */1
;
