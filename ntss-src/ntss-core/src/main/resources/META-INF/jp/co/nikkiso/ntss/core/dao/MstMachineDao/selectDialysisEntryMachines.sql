select /*%expand "MM"*/*
from mst_machine MM
  inner join mnt_machine_state MMS
    on MMS.facility_cd = MM.facility_cd
    and MMS.machine_type_cd = MM.machine_type_cd
    and MMS.machine_serial = MM.machine_serial
  inner join ord_main O on MMS.ord_no = O.ord_no
where MM.facility_cd = /*facilityCd*/''
  and MM.is_disp = '1'
  and MM.is_del = '0'
  and O.rst_dialysis_state in ('1', '2', '3')
  and O.is_del = '0'
;
