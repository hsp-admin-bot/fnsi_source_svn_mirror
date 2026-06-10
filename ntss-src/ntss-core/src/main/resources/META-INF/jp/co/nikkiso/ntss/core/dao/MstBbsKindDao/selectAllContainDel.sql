  select
      /*%expand "A" */*
  from
    mst_bbs_kind A
      where
             A.facility_cd = /* params.facilityCd*/null
         and
             A.is_del = '1'
;
