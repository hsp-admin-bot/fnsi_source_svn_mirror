select
      /*%expand "A" */*
  from
    mst_treatment A
  where
    A.facility_cd = /*facilityCd*/0
  and
    A.is_del = '0'

