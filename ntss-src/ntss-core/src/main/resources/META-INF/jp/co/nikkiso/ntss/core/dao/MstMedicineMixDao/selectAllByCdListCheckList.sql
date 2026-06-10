-- add 10310 薬剤マスタから情報取得 gjn start
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
and
  A.medicine_mix_cd in /* medicineMixCdList */(null)
;
-- add 10310 薬剤マスタから情報取得 gjn end
