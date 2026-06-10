select
  /*%expand*/*
from
  mst_comsv_setting
where
  facility_cd = /*facilityCd*/'000001'
and
  is_del = '0'
order by
  comsv_cd
;
