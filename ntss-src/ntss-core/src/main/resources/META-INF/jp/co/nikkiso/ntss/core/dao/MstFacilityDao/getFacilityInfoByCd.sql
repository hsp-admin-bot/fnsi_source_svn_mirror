--  add FNSI-3922 投薬指示機能が施設拡張設定のON\OFF制御に反映していない liumx start
select
  /*%expand "A" */*
from
  mst_facility A
where
  A.facility_cd = /*facilityCd*/''
  ;
-- add FNSI-3922 投薬指示機能が施設拡張設定のON\OFF制御に反映していない liumx end
