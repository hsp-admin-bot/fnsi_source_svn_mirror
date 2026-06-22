select /*%expand */*
from
  mst_disease
where facility_cd = /*facilityCd*/'999999'
 limit /*limit*/0
 offset /*offset*/0
;
