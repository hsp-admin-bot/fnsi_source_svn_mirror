select
    /*%expand "A"*/*
from mnt_machine_state A
         inner join mst_machine mm
                    on A.facility_cd = mm.facility_cd
                        and  A.machine_type_cd = mm.machine_type_cd
                        and A.machine_serial = mm.machine_serial
         INNER JOIN mst_bed mb ON mm.machine_no = mb.machine_no
where
        mm.facility_cd = /*facilityCd*/'1'
  and
        mb.bed_cd = /*bedCd*/0
  and
        mm.is_del = '0'
;
