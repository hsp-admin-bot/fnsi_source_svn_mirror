  select
      /*%expand "A" */*
  from
    mst_bed A
      where
             A.facility_cd = /* facility_cd*/'0'
;
