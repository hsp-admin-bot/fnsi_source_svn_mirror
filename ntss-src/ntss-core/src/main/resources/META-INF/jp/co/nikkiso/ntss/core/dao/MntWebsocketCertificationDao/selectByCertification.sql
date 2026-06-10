select
  /*%expand "A" */*
from
  mnt_websocket_certification A
where
  A.certification_cd = /*certificationCd*/'99999999999949999999999999999999'
;
