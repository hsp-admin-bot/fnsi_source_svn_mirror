-- add 10310 薬剤マスタから情報取得 gjn start
select
  /*%expand "A" */*
from
  mst_medicine A
where
  facility_cd = /*facilityCd*/null
and
  is_del = '0'
and
  A.is_disp = '1'
and
  medicine_cd in /* medicineList */(null)
order by
  medicine_cd
;
-- add 10310 薬剤マスタから情報取得 gjn end
