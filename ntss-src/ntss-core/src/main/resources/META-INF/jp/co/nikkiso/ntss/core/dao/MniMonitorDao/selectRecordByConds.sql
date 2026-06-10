select
  /*%expand */*
from
  mni_monitor mm
where
  /*%if param != null && param.bioMoniCtlNo != null*/
  mm.bio_moni_ctl_no = /*param.bioMoniCtlNo*/0
  /*%end*/
  /*%if param != null && param.facilityCd != null*/
  and mm.facility_cd = /*param.facilityCd*/'0'
  /*%end*/
  /*%if param != null && param.machineTypeCd != null*/
  and mm.machine_type_cd = /*param.machineTypeCd*/'0'
  /*%end*/
  /*%if param != null && param.machineSerial != null*/
  and mm.machine_serial = /*param.machineSerial*/'0'
  /*%end*/
  /*%if param != null && param.ordNo != null*/
  and mm.ord_no = /*param.ordNo*/0
  /*%end*/
  /*%if param != null && param.patId != null*/
  and mm.pat_id = /*param.patId*/0
  /*%end*/
  /*%if param != null && param.dataType != null*/
  and mm.data_type = /*param.dataType*/0
  /*%end*/
  /*%if param != null && param.isDel != null*/
  and mm.is_del = /*param.isDel*/'0'
  /*%end*/
  /*%if param != null && param.occurDate != null*/
  and mm.occur_date = /*param.occurDate*/'0'
  /*%end*/
