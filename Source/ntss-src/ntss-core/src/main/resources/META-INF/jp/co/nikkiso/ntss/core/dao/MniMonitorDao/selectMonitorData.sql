select
  MO.monitor_data
from
  mni_monitor MO
  inner join mst_machine MA
  on
    MO.machine_type_cd = MA.machine_type_cd
    and
    MO.machine_serial = MA.machine_serial
    and
    MO.facility_cd = MA.facility_cd
    and
    MA.is_disp = '1'
    and
    MA.is_del = '0'
where
  MO.facility_cd = /* facilityCd */'1'
  and
  MO.ord_no = /* ordNo */0
  and
  MO.pat_id = /* patId */0
  and
  MA.com_type = 1
  and
  MO.is_del = '0'
order by MO.occur_date DESC
;
