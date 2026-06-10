UPDATE
  ord_main
SET
  rst_dialysis_state = /*param.rstDialysisState*/null,
  rst_kur_cd = /*param.rstKurCd*/null,
  rst_kur_name = /*param.rstKurName*/null,
  rst_bed_cd = /*param.rstBedCd*/null,
  rst_bed_name = /*param.rstBedName*/null,
  rst_machine_no = /*param.rstMachineNo*/null,
  rst_machine_name = /*param.rstMachineName*/null,
  rst_input_class = /*param.rstInputClass*/0,
  rst_start_date = /*param.rstStartDate*/null,
  rst_end_date = /*param.rstEndDate*/null,
  rst_return_home_date = /*param.rstReturnHomeDate*/null,
  rst_dialysis_cnt = /*param.rstDialysisCnt*/null,
  rst_blood_circulate_total = /*param.rstBloodCirculateTotal*/null,
  rst_running_time = /*param.rstRunningTime*/null,
  rst_kt_v = /*param.rstKtV*/null,
  rec_set_date = /*param.recSetDate*/null,
  send_ctl_no = /*param.sendCtlNo*/null,
  blood_purifier_name = /*param.bloodPurifierName*/null,
  pull_leave_amount = /*param.pullLeaveAmount*/null,
  rst_puncture_user_info = /*param.rstPunctureUserInfo*/null,
  rst_return_user_info = /*param.rstReturnUserInfo*/null,
  rst_charge_user_info = /*param.rstChargeUserInfo*/null,
  up_date = /*upDate*/null,
  --// add FNSI-？？？？患者割り当て 陳 start
  rst_cond_info = /*param.rstCondInfo*/null,
  rst_treatment_cd = /*param.rstTreatmentCd*/null,
  rst_treatment_name = /*param.rstTreatmentName*/null,
  rst_in_out_class = /*param.rstInOutClass*/null,
  rst_ward_cd = /*param.rstWardCd*/null,
  rst_ward_name = /*param.rstWardName*/null,
  rst_course_cd = /*param.rstCourseCd*/null,
  rst_course_name = /*param.rstCourseName*/null,
  rst_dw = /*param.rstDw*/null,
  rst_medi_info = /*param.rstMediInfo*/null,
  rst_equip_info = /*param.rstEquipInfo*/null,
  rst_ind_comment_info = /*param.rstIndCommentInfo*/null,
  rst_tare_info = /*param.rstTareInfo*/null,
  rst_off_water_info = /*param.rstOffWaterInfo*/null,
  weight_scale_no = /*param.weightScaleNo*/null,
  rst_weight_info = /*param.rstWeightInfo*/null,
  rst_complaint_info = /*param.rstComplaintInfo*/null,
  rst_treatment_info = /*param.rstTreatmentInfo*/null,
  rst_treat_staff_info = /*param.rstTreatStaffInfo*/null,
  rst_rounds_info = /*param.rstRoundsInfo*/null,
  rst_purification_cnt = /*param.rstPurificationCnt*/null,
  rst_cond_send_date = /*param.rstCondSendDate*/null,
  --// add FNSI-？？？？患者割り当て 陳 start
  -- add 10860 ind_schedule_user_infoのデータ不正 zhao start
  ind_schedule_user_info = /*param.indScheduleUserInfo*/null
  -- add 10860 ind_schedule_user_infoのデータ不正 zhao end
WHERE
  ord_no = /*param.ordNo*/0
;
