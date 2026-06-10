-- add 10310 医療材料マスタから情報取得 gjn start
select
  /*%expand "A" */*
from
  mst_equipment A
where
  facility_cd = /*facilityCd*/null
and
  is_del = '0'
and
  A.is_disp = '1'
and
  equipment_cd in /* equipList */(null)
order by
  equipment_cd
;
-- add 10310 医療材料マスタから情報取得 gjn end
