--病名
select
    /*%expand*/*
from
  mst_disease
where
  is_del = '0'
;
