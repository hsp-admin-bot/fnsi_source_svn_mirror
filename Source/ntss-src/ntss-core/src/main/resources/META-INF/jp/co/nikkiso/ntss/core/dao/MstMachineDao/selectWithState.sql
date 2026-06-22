select
  mst.machine_type_cd,
  mst.machine_serial,
  mst.facility_cd,
  mst.machine_name,
  mnt.bed_cd,
  mnt.bed_name,
  mnt.process_state,
  mnt.machine_status,
  mnt.ord_no,
  mnt.pat_id,
  mnt.weigh_before_date,
  mnt.cond_send_date,
  mnt.cond_set_date,
  mnt.start_plan_date,
  mnt.end_plan_date,
  mnt.start_date,
  mnt.end_date,
  mnt.weigh_after_date,
  mnt.alarm_list,
  pat.hosp_pat_id,
  pat.pat_name,
  pat.pat_name_kana,
  pat.pat_name_alpha,
  pat.pat_sex,
  pat.pat_birthday,
  pat.pat_blood_type_abo,
  pat.pat_blood_type_rh,
  pat.in_out_class,
  pat.is_same,
  pat.taboo_info,
  pat.is_infect,
  pat.is_implant,
  pat.charge_staff_info as pat_charge_staff_info
from
  mst_machine mst
  left join mnt_machine_state mnt
  on mst.facility_cd = mnt.facility_cd
  and mst.machine_serial = mnt.machine_serial
  and mst.facility_cd = mnt.facility_cd
  left join pat_main pat on mnt.pat_id = pat.pat_id
where
  mst.facility_cd = /*facilityCd*/'999900'
/*%if machineTypeCd != null */
  and
  mst.machine_type_cd = /*machineTypeCd*/'1'
/*%end*/
/*%if machineSerial != null */
  and
  mst.machine_serial = /*machineSerial*/'1'
/*%end*/
  and
  (mnt.model = '004' or mnt.model = '005')
order by
  mnt.bed_name, mnt.bed_cd, mst.machine_serial
;
