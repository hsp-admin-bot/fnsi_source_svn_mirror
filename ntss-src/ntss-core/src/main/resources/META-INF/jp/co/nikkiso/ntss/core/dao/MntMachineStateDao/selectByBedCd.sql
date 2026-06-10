select
  /*%expand "A"*/*
from
  mnt_machine_state A
where
  A.bed_cd = /*bedCd*/'1'
;