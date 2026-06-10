--  add #11257 機能帳票の出力に帳票保存のソート条件を適用する 高 start
select
  /*%expand "om" */*
from
  ord_main as om
where
  om.ord_no in /* ordNos */(null)
  and om.is_del = '0'
  and om.facility_cd = /*facilityCd*/''
;
--  add #11257 機能帳票の出力に帳票保存のソート条件を適用する 高 end
