select
json_build_object(
/*%for key : keys*/
/*key*/'1', ( monitor_data ->> /*key*/'1' )
  /*%if key_has_next */
/*# "," */
  /*%end */
/*%end*/
) as monitor_data,
occur_date,
bio_moni_ctl_no
from
  mni_monitor
where
  facility_cd = /*facilityCd*/'1'
  and
  machine_type_cd = /*machineTypeCd*/'1'
  and
  machine_serial = trim(/*machineSerial*/'1')
/*%if ordNo >= 0L */
  and
  ord_no = /* ordNo */0
/*%end*/
/*%if bioMoniCtlNo > 0L */
  and
  bio_moni_ctl_no > /* bioMoniCtlNo */1
/*%end*/
/*%if occurDate != null */
  and
  occur_date >= /*occurDate*/'1900/01/01 00:00:00'
/*%end*/
order by
  occur_date
;
