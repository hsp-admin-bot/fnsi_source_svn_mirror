select
  /*%expand "A"*/*
from
  mnt_machine_state A
where
  A.pat_id = /*patId*/'1'
  and A.process_state <> '99'
;
