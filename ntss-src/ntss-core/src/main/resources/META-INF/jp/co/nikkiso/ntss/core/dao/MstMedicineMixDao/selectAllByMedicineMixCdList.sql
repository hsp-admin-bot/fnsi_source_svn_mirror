--調製薬剤マスタ(selectByMedicineMixCdの一括版)
select
  /*%expand "A" */*
from
  mst_medicine_mix A
where
  A.facility_cd = /* facilityCd */null
and
  A.is_del = '0'
/*%if medicineMixCdList.size() > 0 */
and
  A.medicine_mix_cd in /* medicineMixCdList */(0)
/*%end */
;
