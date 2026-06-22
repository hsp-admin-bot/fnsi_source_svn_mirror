select
  mm.com_format_cd,
  mm.com_type,
  A.machine_type_cd,
  A.bed_cd,
  A.process_state,
  A.machine_status,
  A.is_offline,
  A.start_plan_date,
  A.end_plan_date,
  A.start_date,
  A.end_date,
  A.weigh_before_date,
  A.weigh_after_date,
  A.cond_send_date,
  A.cond_set_date,
  A.is_pat_verified
from mnt_machine_state A
  inner join mst_machine mm
  on A.facility_cd = mm.facility_cd
  and  A.machine_type_cd = mm.machine_type_cd
  and A.machine_serial = mm.machine_serial
  inner join mst_bed mb
  on mm.machine_no = mb.machine_no
where
  mb.bed_cd = /*bedCd*/0
  and
  mm.is_del = '0'
;
