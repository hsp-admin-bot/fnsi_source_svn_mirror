select
  /*%expand "A" */*
from
  mst_equipment A
where
  A.is_del = '0'
and
  A.facility_cd = /*facilityCd*/'009999'
and
  A.in_hospital_cd_1 = /*inHospitalCd1*/''
;
