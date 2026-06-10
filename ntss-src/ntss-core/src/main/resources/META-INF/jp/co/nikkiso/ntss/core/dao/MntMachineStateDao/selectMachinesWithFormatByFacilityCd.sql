select
  A.facility_cd,
  A.machine_type_cd,
  A.machine_serial,
  A.machine_name,
  A.bed_cd,
  A.bed_name,
  A.process_state,
  A.m_notice_cnt,
  A.preventive_mainte_cnt,
  A.is_preventive_mainte,
  A.use_time,
  A.machine_status,
  A.alarm_moni,
  A.is_offline,
  A.ord_no,
  A.next_ord_no,
  A.pat_id,
  A.next_patid,
  A.next_kur_cd,
  A.start_plan_date,
  A.end_plan_date,
  A.weigh_before_date,
  A.cond_send_date,
  A.cond_set_date,
  A.start_date,
  A.end_date,
  A.weigh_after_date,
  A.alarm_list,
  A.reg_date,
  A.up_date,
  A.is_pat_verified,
  A.tmp_device_set_info,
  B.model,
  A.monitor_data,
  BASE.com_format_cd
from
  mst_machine BASE
  left outer join mnt_machine_state A
    on BASE.facility_cd = A.facility_cd
    and BASE.machine_type_cd = A.machine_type_cd
    and BASE.machine_serial = A.machine_serial
  inner join mst_machine_type B
    on BASE.machine_type_cd = B.machine_type_cd
where
  BASE.facility_cd = /*facilityCd*/'999900'
  and
  BASE.is_disp = '1'
  and
  BASE.is_del = '0'
;
