
update
  ord_main
set
  rst_kur_cd = /*entity.rstKurCd*/null
  , rst_dialysis_state = /*entity.rstDialysisState*/null
  , rst_kur_name = /*entity.rstKurName*/null
  , rst_bed_cd = /*entity.rstBedCd*/null
  , rst_bed_name = /*entity.rstBedName*/null
  , rst_cond_send_date = /*entity.rstCondSendDate*/null
  , rst_accept_date = /*entity.rstAcceptDate*/null
  , rst_start_date = /*entity.rstStartDate*/null
  , rst_end_date = /*entity.rstEndDate*/null
  , rst_return_home_date = /*entity.rstReturnHomeDate*/null
  , rst_in_out_class = /*entity.rstInOutClass*/null
  , rst_dialysis_cnt = /*entity.rstDialysisCnt*/null
  , rst_ward_cd = /*entity.rstWardCd*/null
  , rst_ward_name = /*entity.rstWardName*/null
  , rst_course_cd = /*entity.rstCourseCd*/null
  , rst_course_name = /*entity.rstCourseName*/null
  , rst_puncture_user_info = /*entity.rstPunctureUserInfo*/null
  , rst_return_user_info = /*entity.rstReturnUserInfo*/null
  , rst_charge_user_info = /*entity.rstChargeUserInfo*/null
  , rst_blood_circulate_total = /*entity.rstBloodCirculateTotal*/null
  , rst_running_time = /*entity.rstRunningTime*/null
  , rst_kt_v = /*entity.rstKtV*/null
  , rec_set_date = /*entity.recSetDate*/null
  , send_ctl_no = /*entity.sendCtlNo*/null
  , blood_purifier_name = /*entity.bloodPurifierName*/null
  , pull_leave_amount = /*entity.pullLeaveAmount*/null
  , rst_cond_info = /*entity.rstCondInfo*/null
  , rst_medi_info = /*entity.rstMediInfo*/null
  , rst_equip_info = /*entity.rstEquipInfo*/null
  , rst_ind_comment_info = /*entity.rstIndCommentInfo*/null
  , rst_tare_info = /*entity.rstTareInfo*/null
  , rst_off_water_info = /*entity.rstOffWaterInfo*/null
--   add 10196 by kangjie 20240130 start del
--   , rst_device_set_info = /*entity.rstDeviceSetInfo*/null
--   add 10196 by kangjie 20240130 end del
  , weight_scale_no = /*entity.weightScaleNo*/null
  , rst_weight_info = /*entity.rstWeightInfo*/null
--   add 10196 by kangjie 20240130 start del
--   , rst_vital_info = /*entity.rstVitalInfo*/null
--   add 10196 by kangjie 20240130 start del
  , rst_complaint_info = /*entity.rstComplaintInfo*/null
  , rst_treatment_info = /*entity.rstTreatmentInfo*/null
  , rst_treat_staff_info = /*entity.rstTreatStaffInfo*/null
  , rst_rounds_info = /*entity.rstRoundsInfo*/null
  , is_confirm = case when rst_dialysis_state = '6' then '0' else is_confirm end
  , up_date = /*entity.upDate*/'2000-01-01 00:00:00'
  , rst_purification_cnt = /*entity.rstPurificationCnt*/null
  , rst_treatment_name = /*entity.rstTreatmentName*/null
  , rst_treatment_cd = /*entity.rstTreatmentCd*/null
  , rst_dw = /*entity.rstDw*/null
where
  ord_no = /*ordNo*/1
and
  is_del = '0'
;
