insert into ord_main_restore
(
ord_no,
del_date,
pat_id
,fn_pat_id
,treat_date
,treat_week
,facility_cd
,facility_name
,ind_va_cd
,ind_treatment_cd
,ind_treatment_name
,ind_kur_cd
,ind_kur_name
,ind_treat_start_time
,ind_bed_cd
,ind_bed_name
,ind_schedule_user_info
,ind_cond_info
,ind_medi_info
,ind_equip_info
,ind_ind_comment_info
,ind_tare_info
,ind_off_water_info
,rst_fn_dialysis_no
,rst_relation_dialysis_no
,rst_edition
,rst_is_update_edition
,rst_input_class
,rst_dialysis_state
,rst_treatment_cd
,rst_treatment_name
,rst_kur_cd
,rst_kur_name
,rst_bed_cd
,rst_bed_name
,rst_machine_no
,rst_machine_name
,rst_cond_send_date
,rst_accept_date
,rst_start_date
,rst_end_date
,rst_return_home_date
,rst_in_out_class
,rst_dialysis_cnt
,rst_ward_cd
,rst_ward_name
,rst_course_cd
,rst_course_name
,rst_puncture_user_info
,rst_return_user_info
,rst_charge_user_info
,rst_blood_circulate_total
,rst_running_time
,rst_kt_v
,rec_set_date
,send_ctl_no
,blood_purifier_name
,pull_leave_amount
,rst_cond_info
,rst_medi_info
,rst_equip_info
,rst_ind_comment_info
,rst_tare_info
,rst_off_water_info
,rst_weight_info
--   add 10196 by kangjie 20240130 start del
-- ,rst_vital_info
--   add 10196 by kangjie 20240130 end del
,rst_complaint_info
,rst_treatment_info
,rst_treat_staff_info
,rst_rounds_info
,is_del
,up_date
,reg_date
,ind_device_set_info
--   add 10196 by kangjie 20240130 start del
-- ,rst_device_set_info
--   add 10196 by kangjie 20240130 end del
,treat_type
,rst_purification_cnt
,up_ind_user_id
,up_user_id
,rst_dw
,weight_scale_no
,fn_plural
,is_confirm
,ind_dw
,addition_info
,bvms_path
--   add 11467 【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。 関 start
,ind_dw_user_info
,ind_device_mode
,rst_device_mode
--   add 11467 【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。 関 end
)
values
/*%for omr : ordMainRestoreList */
(
  /*omr.ordNo*/'1',
  /*omr.delDate*/null,
  /*omr.patId*/'1',
  /*omr.fnPatId*/null,
  /*omr.treatDate*/null,
  /*omr.treatWeek*/null,
  /*omr.facilityCd*/null,
  /*omr.facilityName*/null,
  /*omr.indVaCd*/null,
  /*omr.indTreatmentCd*/null,
  /*omr.indTreatmentName*/null,
  /*omr.indKurCd*/null,
  /*omr.indKurName*/null,
  /*omr.indTreatStartTime*/null,
  /*omr.indBedCd*/null,
  /*omr.indBedName*/null,
  /*omr.indScheduleUserInfo*/null,
  /*omr.indCondInfo*/null,
  /*omr.indMediInfo*/null,
  /*omr.indEquipInfo*/null,
  /*omr.indIndCommentInfo*/null,
  /*omr.indTareInfo*/null,
  /*omr.indOffWaterInfo*/null,
  /*omr.rstFnDialysisNo*/null,
  /*omr.rstRelationDialysisNo*/null,
  /*omr.rstEdition*/'0',
  /*omr.rstIsUpdateEdition*/null,
  /*omr.rstInputClass*/null,
  /*omr.rstDialysisState*/'0',
  /*omr.rstTreatmentCd*/null,
  /*omr.rstTreatmentName*/null,
  /*omr.rstKurCd*/null,
  /*omr.rstKurName*/null,
  /*omr.rstBedCd*/null,
  /*omr.rstBedName*/null,
  /*omr.rstMachineNo*/null,
  /*omr.rstMachineName*/null,
  /*omr.rstCondSendDate*/null,
  /*omr.rstAcceptDate*/null,
  /*omr.rstStartDate*/null,
  /*omr.rstEndDate*/null,
  /*omr.rstReturnHomeDate*/null,
  /*omr.rstInOutClass*/null,
  /*omr.rstDialysisCnt*/null,
  /*omr.rstWardCd*/null,
  /*omr.rstWardName*/null,
  /*omr.rstCourseCd*/null,
  /*omr.rstCourseName*/null,
  /*omr.rstPunctureUserInfo*/null,
  /*omr.rstReturnUserInfo*/null,
  /*omr.rstChargeUserInfo*/null,
  /*omr.rstBloodCirculateTotal*/null,
  /*omr.rstRunningTime*/null,
  /*omr.rstKtV*/null,
  /*omr.recSetDate*/null,
  /*omr.sendCtlNo*/null,
  /*omr.bloodPurifierName*/null,
  /*omr.pullLeaveAmount*/null,
  /*omr.rstCondInfo*/null,
  /*omr.rstMediInfo*/null,
  /*omr.rstEquipInfo*/null,
  /*omr.rstIndCommentInfo*/null,
  /*omr.rstTareInfo*/null,
  /*omr.rstOffWaterInfo*/null,
  /*omr.rstWeightInfo*/null,
--   add 10196 by kangjie 20240130 start del
--   /*omr.rstVitalInfo*/null,
--   add 10196 by kangjie 20240130 end del
  /*omr.rstComplaintInfo*/null,
  /*omr.rstTreatmentInfo*/null,
  /*omr.rstTreatStaffInfo*/null,
  /*omr.rstRoundsInfo*/null,
  /*omr.isDel*/'0',
  /*omr.upDate*/null,
  /*omr.regDate*/null,
  /*omr.indDeviceSetInfo*/null,
--   add 10196 by kangjie 20240130 start del
--   /*omr.rstDeviceSetInfo*/null,
--   add 10196 by kangjie 20240130 end del
  /*omr.treatType*/null,
  /*omr.rstPurificationCnt*/null,
  /*omr.upIndUserId*/null,
  /*omr.upUserId*/null,
  /*omr.rstDw*/null,
  /*omr.weightScaleNo*/null,
  /*omr.fnPlural*/null,
  /*omr.isConfirm*/null,
  /*omr.indDw*/null,
  /*omr.additionInfo*/null,
  /*omr.bvmsPath*/null
  --   add 11467 【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。 関 start
  ,/*omr.indDwUserInfo*/null
  ,/*omr.indDeviceMode*/null
  ,/*omr.rstDeviceMode*/null
--   add 11467 【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。 関 end
)
/*%if omr_has_next */
/*# "," */
/*%end */
/*%end*/
;
