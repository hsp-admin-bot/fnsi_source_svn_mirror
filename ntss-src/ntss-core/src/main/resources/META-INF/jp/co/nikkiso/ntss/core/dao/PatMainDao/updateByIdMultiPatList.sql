update pat_main
set
  -- pat_id = /* pat.pat_id */null,
  -- facility_cd = /* pat.facility_cd */null,
  is_same = /* pat.is_same */null,
  is_implant = /* pat.is_implant */null,
  is_infect = /* pat.is_infect */null,
  is_diabetes = /* pat.is_diabetes */null,
  is_wheel_chair = /* pat.is_wheel_chair */null,
  is_blood_suger_exam = /* pat.is_blood_suger_exam */null,
  in_out_current_state = /* pat.in_out_current_state */null,
  in_out_plan_state = /* pat.in_out_plan_state */null,
  in_out_plan_date = /* pat.in_out_plan_date */null,
  pat_memo_info = /*pat.pat_memo_info*/null,
  addition_info = /*pat.addition_info*/null,
  charge_staff_info = /*pat.charge_staff_info*/null,
  taboo_allergy_info = /*pat.taboo_allergy_info*/null,
  infect_info = /*pat.infect_info*/null,
  implant_info = /*pat.implant_info*/null,
  tare_info = /*pat.tare_info*/null,
  off_water_info = /*pat.off_water_info*/null,
  device_set_info = /*pat.device_set_info*/null,
  acceptance_status_info = /*pat.acceptance_status_info*/null,
  up_date = to_timestamp(/* pat.up_date */null, 'YYYY-MM-DD HH24:MI:SS'),
  --reg_date = /* pat.reg_date */null,
  medical_care_info = /*pat.medical_care_info*/null,
  sch_ext_end_date = /*pat.sch_ext_end_date*/null,
  sch_ext_status = /*pat.sch_ext_status*/null,
  host_notification_info = /*pat.host_notification_info*/null,
  wheel_chair_cd = /*pat.wheel_chair_cd*/null
where
  pat_id = /*pat_id*/null
;