select
  A.facility_cd,
  A.machine_type_cd,
  A.machine_serial,
  A.bed_cd,     
  C.bed_name
from
  mst_machine BASE
  inner join mnt_machine_state A
    on BASE.facility_cd = A.facility_cd
    and BASE.machine_type_cd = A.machine_type_cd
    and BASE.machine_serial = A.machine_serial
  inner join mst_machine_type B
    on BASE.machine_type_cd = B.machine_type_cd
  inner join mst_bed C
    on A.bed_cd  = C.bed_cd
where
    BASE.facility_cd = /*facilityCd*/''
  and
    BASE.is_disp = '1'
  and
    BASE.is_del = '0'
  and
    C.is_disp = '1'
  and
    C.is_del = '0'
  and 
    A.bed_cd is not null
/*%if bedCdList != null && bedCdList.size() > 0 */
  and
    A.bed_cd in /*bedCdList*/(NULL)
/*%end */
  and 
    B.model in ('004', '005')
;
