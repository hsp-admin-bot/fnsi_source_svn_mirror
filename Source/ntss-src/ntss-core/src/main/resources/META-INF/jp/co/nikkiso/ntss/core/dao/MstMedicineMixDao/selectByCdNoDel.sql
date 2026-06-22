--調製薬剤マスタ
select
  /*%expand "A" */*
from
  mst_medicine_mix A   --テーブル名
where
  A.facility_cd = /* facilityCd */null
and
  A.medicine_mix_cd = /* medicineMixCd */0
;
