select 
  /*%expand "A" */*
from mnt_weight_state A
where A.weight_cd = /*weightCd*/0
;