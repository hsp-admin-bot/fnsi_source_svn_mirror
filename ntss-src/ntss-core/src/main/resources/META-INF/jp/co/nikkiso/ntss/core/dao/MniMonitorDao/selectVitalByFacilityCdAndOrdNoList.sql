select
  bio_moni_ctl_no,
  facility_cd,
  machine_type_cd,
  machine_serial,
  ord_no,
  pat_id,
  data_type,
  monitor_data,
  is_del,
  occur_date,
  reg_date,
  up_date
from
  mni_monitor
where
  (facility_cd, ord_no) IN (
    /*%for bodyData : facilityCdAndOrdNoList */
        (/* bodyData.get("facility_cd") */null, /* bodyData.get("ord_no") */0)
        /*%if bodyData_has_next */
        /*# "," */
        /*%end*/
    /*%end*/
  )
and
  data_type in (2, 4, 5, 6)
and
  is_del = '0'
;
