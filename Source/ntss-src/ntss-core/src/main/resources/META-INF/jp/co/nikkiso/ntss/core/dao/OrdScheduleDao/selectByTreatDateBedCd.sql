select
  /*%expand "A"*/*
from
  ord_schedule as A
where
    facility_cd = /* facilityCd */null
  and
    treat_date = /* treatDate */null
  and
    bed_cd = /* bedCd */null
  and
    kur_cd > 0
;
