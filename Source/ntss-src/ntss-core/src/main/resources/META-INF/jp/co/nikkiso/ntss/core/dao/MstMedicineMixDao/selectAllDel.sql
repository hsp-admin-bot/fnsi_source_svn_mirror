--調製薬剤マスタ
  select
      /*%expand "A" */*
  from
    mst_medicine_mix A   --テーブル名
  where
    A.facility_cd = /* params.facilityCd*/'0'
    and
    A.is_del = '1'
;
