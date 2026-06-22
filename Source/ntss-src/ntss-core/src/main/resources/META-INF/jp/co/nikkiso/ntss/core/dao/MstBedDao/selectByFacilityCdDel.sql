  select
      /*%expand "A" */*
  from
    mst_bed A
      where
             A.facility_cd = /* facility_cd*/'0'
       and
             (A.is_del = '1' or A.is_disp = '0')
;
