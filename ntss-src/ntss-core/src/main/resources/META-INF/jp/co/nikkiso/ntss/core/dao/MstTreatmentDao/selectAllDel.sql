--治療方法
  select
      /*%expand "A" */*
  from
    mst_treatment A
      where
             A.facility_cd = /* params.facilityCd*/'0'
       and
             (A.is_del = '1' or A.is_disp = '0')
;
