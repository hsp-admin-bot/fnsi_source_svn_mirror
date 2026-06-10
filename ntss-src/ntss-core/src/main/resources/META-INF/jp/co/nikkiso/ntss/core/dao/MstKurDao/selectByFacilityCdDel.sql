--クール
  select
      /*%expand "A" */*
  from
    mst_kur A
  where
         A.facility_cd = /* facility_cd*/'0'
    and
         A.is_del = '1'
;
