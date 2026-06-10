select
  /*%expand "A" */*
from
  ord_main A
where
  pat_id = /*patId*/0
    and treat_date >= /*startTreatDate*/''
    and treat_date<= /*endTreatDate*/''
    and facility_cd = /*facilityCd*/'000000'
;
