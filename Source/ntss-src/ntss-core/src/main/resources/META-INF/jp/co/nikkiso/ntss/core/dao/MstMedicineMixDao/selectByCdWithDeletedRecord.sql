--調製薬剤マスタ
select
  /*%expand "A" */*
from
  mst_medicine_mix A
where
  A.facility_cd = /* facilityCd */null
and
  A.medicine_mix_cd = /* medicineMixCd */0
and
  A.is_del = '0'
;
