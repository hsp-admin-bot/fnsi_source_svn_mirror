select
  /*%expand "t" */*
from
  mst_treatment t
    inner join ord_main o on
      o.rst_treatment_cd = t.treatment_cd
where
  o.ord_no = /*ordNo*/1
and
  o.is_del = '0'
;
