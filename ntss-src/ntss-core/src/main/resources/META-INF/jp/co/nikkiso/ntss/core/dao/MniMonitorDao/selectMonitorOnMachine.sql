select
  /*%expand "A" */*
 from
  mni_monitor A
where
  A.facility_cd = /*facilityCd*/'999900'
  and
  A.machine_type_cd = /*machineTypeCd*/'005'
  and
  A.machine_serial = /*machineSerial*/'TDC0001'
/*%if startDate != null */
  and
  A.occur_date >= /*startDate*/'2019/08/01 00:00:00'
/*%end*/
/*%if endDate != null */
  and
  A.occur_date < /*endDate*/'2019/08/30 00:00:00'
/*%end*/
  and
  A.is_del = '0'
order by
  A.occur_date
  ;
