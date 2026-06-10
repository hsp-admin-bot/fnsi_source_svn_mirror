select
      /*%expand "A" */*
  from
    mst_medicine A
      where
             A.facility_cd = /* params.facilityCd*/'0'
       and
             A.is_del = '0'
       and
             A.is_disp = '1'
;
