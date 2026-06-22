select
  /*%expand "A" */*
from
  ord_main A
where
  pat_id = /*patId*/0
    and treat_date = /*treatDate*/''
    and facility_cd = /*facilityCd*/'000000'
   order by
    rst_end_date IS NULL, rst_end_date DESC limit 1
;
