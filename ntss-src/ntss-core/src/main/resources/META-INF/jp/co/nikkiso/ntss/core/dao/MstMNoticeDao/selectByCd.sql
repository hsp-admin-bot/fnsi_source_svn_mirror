select
  /*%expand*/*
from
  mst_m_notice
where
  facility_cd = /*facilityCd*/'1'
and
  machine_record_cd = /*machineRecordCd*/'1'
;
