--投与タイミング
  select
      /*%expand "A" */*
  from
    mst_medicate_timing A   --テーブル名
      where
          A.facility_cd = /* params.facilityCd*/'0'

;
