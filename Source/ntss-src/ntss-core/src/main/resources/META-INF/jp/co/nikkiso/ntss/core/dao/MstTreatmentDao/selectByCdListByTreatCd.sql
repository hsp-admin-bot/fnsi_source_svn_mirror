select
    /*%expand "A" */*
from
    mst_treatment A
where
        A.is_del = '0'
  and
        A.treatment_cd in /*treatmentCdList*/(null)
;
