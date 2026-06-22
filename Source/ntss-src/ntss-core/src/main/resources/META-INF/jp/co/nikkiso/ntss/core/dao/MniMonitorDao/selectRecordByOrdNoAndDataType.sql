select
  /*%expand */*
from
  mni_monitor mm
where
  mm.facility_cd = /*facilityCd*/'NKK'
  and mm.ord_no = /*ordNo*/1
  /*%if dataTypes != null && dataTypes.size() > 0*/
  and data_type in /*dataTypes*/(1)
  /*%end*/
  and mm.is_del = '0'
