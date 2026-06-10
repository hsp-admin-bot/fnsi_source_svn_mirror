select
  /*%expand "A" */*
from
  mst_disease A
where
    A.is_del = '0'
  and
    A.disease_cd in /* diseaseCds */(NULL)
;
