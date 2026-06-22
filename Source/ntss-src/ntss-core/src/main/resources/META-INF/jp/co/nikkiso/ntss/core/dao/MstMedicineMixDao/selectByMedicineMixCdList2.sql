--調製薬剤マスタ
select
  /*%expand "A" */*
from
  mst_medicine_mix A   --テーブル名
where
  A.medicine_mix_cd in /* medicineMixCdList */(0)
and
  A.is_del = '0'
and
  A.is_disp = '1'
;
