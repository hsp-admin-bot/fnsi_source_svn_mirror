select
  /*%expand "A" */*
from mnt_scale_bed_state A
where A.bed_cd = /*bedCd*/0
;
