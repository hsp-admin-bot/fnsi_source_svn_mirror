select
  pat_id,
  facility_cd,
  is_same,
  is_implant,
  is_infect,
  is_diabetes,
  is_blood_suger_exam,
  is_wheel_chair,
  in_out_current_state,
  in_out_plan_state,
  in_out_plan_date,
  pat_memo_info,
  addition_info,
  charge_staff_info,
  pat_group_info,
  taboo_allergy_info,
  infect_info,
  implant_info,
  tare_info,
  off_water_info,
  device_set_info,
  acceptance_status_info,
  is_del,
  up_date,
  reg_date,
  medical_care_info,
  sch_ext_end_date,
  sch_ext_status,
  host_notification_info,
  wheel_chair_cd
from
  pat_main
where
  is_del = '0'
  and facility_cd = /*facilityCd*/'000001'
  and pat_id in /* patIdList */(null)
order by
  pat_id
;
