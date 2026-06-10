-- add 10310 ダイアライザマスタから情報取得 gjn start
select
  /*%expand "A" */*
from
  mst_dialyzer A
where
  facility_cd = /*facilityCd*/null
and
  is_del = '0'
and
  A.is_disp = '1'
and
  dialyzer_cd in /* dialyzerList */(null)
order by
  dialyzer_cd
;
-- add 10310 ダイアライザマスタから情報取得 gjn end
