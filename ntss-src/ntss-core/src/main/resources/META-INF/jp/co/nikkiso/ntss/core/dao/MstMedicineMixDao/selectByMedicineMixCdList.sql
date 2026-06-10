--調製薬剤マスタ
select
  /*%expand "A" */*
from
  mst_medicine_mix A   --テーブル名
where
  A.facility_cd = /* facilityCd */null
and
  A.is_del = '0'
and
  A.is_disp = '1'
/*%if medicineMixCdList.size() > 0 */
  and A.medicine_mix_cd in /* medicineMixCdList */(0)
/*%end */
;
