select
  1 as vkey,
  value
from
  mst_facility_setting a
where
  a.facility_cd = /*facilityCd*/000000
  and
  a.facility_setting_no = /*facilitySettingNo*/0001
union
select
  2 as vkey,
  default_value
from
  sys_facility_setting b
where
  b.facility_setting_no = /*facilitySettingNo*/0001
;
