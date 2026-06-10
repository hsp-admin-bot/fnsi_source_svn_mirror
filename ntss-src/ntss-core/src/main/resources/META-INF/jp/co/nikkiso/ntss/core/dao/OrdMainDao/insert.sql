insert into ord_main
(
/*%if ordMain.ordNo != null */
ord_no,
/*%end*/
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
  -- add 10096 by kangjie 20240119 start
  ,rst_dw
  ,weight_scale_no
  ,is_confirm
  ,ind_dw
  ,addition_info
  ,rst_edition_date
  ,cur_edition_date
  ,fn_plural
  ,bvms_path
  -- add 10096 by kangjie 20240119 end
--   add 11467 【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。 関 start
  ,ind_dw_user_info
  ,ind_device_mode
  ,rst_device_mode
--   add 11467 【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。 関 end
)
values
(
  /*%if ordMain.ordNo != null */
    /*ordMain.ordNo*/'1',
  /*%end*/
  /*ordMain.patId*/'1',
  /*ordMain.fnPatId*/null,
  /*ordMain.treatDate*/null,
  /*ordMain.treatWeek*/null,
  /*ordMain.facilityCd*/null,
  /*ordMain.facilityName*/null,
  /*ordMain.indVaCd*/null,
  /*ordMain.indTreatmentCd*/null,
  /*ordMain.indTreatmentName*/null,
  /*ordMain.indKurCd*/null,
  /*ordMain.indKurName*/null,
  /*ordMain.indTreatStartTime*/null,
  /*ordMain.indBedCd*/null,
  /*ordMain.indBedName*/null,
  /*ordMain.indScheduleUserInfo*/null,
  /*ordMain.indCondInfo*/null,
  /*ordMain.indMediInfo*/null,
  /*ordMain.indEquipInfo*/null,
  /*ordMain.indIndCommentInfo*/null,
  /*ordMain.indTareInfo*/null,
  /*ordMain.indOffWaterInfo*/null,
  /*ordMain.rstFnDialysisNo*/null,
  /*ordMain.rstRelationDialysisNo*/null,
  /*ordMain.rstEdition*/'0',
  /*ordMain.rstIsUpdateEdition*/null,
  /*ordMain.rstInputClass*/null,
  /*ordMain.rstDialysisState*/'0',
  /*ordMain.rstTreatmentCd*/null,
  /*ordMain.rstTreatmentName*/null,
  /*ordMain.rstKurCd*/null,
  /*ordMain.rstKurName*/null,
  /*ordMain.rstBedCd*/null,
  /*ordMain.rstBedName*/null,
  /*ordMain.rstMachineNo*/null,
  /*ordMain.rstMachineName*/null,
  /*ordMain.rstCondSendDate*/null,
  /*ordMain.rstAcceptDate*/null,
  /*ordMain.rstStartDate*/null,
  /*ordMain.rstEndDate*/null,
  /*ordMain.rstReturnHomeDate*/null,
  /*ordMain.rstInOutClass*/null,
  /*ordMain.rstDialysisCnt*/null,
  /*ordMain.rstWardCd*/null,
  /*ordMain.rstWardName*/null,
  /*ordMain.rstCourseCd*/null,
  /*ordMain.rstCourseName*/null,
  /*ordMain.rstPunctureUserInfo*/null,
  /*ordMain.rstReturnUserInfo*/null,
  /*ordMain.rstChargeUserInfo*/null,
  /*ordMain.rstBloodCirculateTotal*/null,
  /*ordMain.rstRunningTime*/null,
  /*ordMain.rstKtV*/null,
  /*ordMain.recSetDate*/null,
  /*ordMain.sendCtlNo*/null,
  /*ordMain.bloodPurifierName*/null,
  /*ordMain.pullLeaveAmount*/null,
  /*ordMain.rstCondInfo*/null,
  /*ordMain.rstMediInfo*/null,
  /*ordMain.rstEquipInfo*/null,
  /*ordMain.rstIndCommentInfo*/null,
  /*ordMain.rstTareInfo*/null,
  /*ordMain.rstOffWaterInfo*/null,
  /*ordMain.rstWeightInfo*/null,

--   add 10196 by kangjie 20240130 start del
--   /*ordMain.rstVitalInfo*/null,
--   add 10196 by kangjie 20240130 end del

  /*ordMain.rstComplaintInfo*/null,
  /*ordMain.rstTreatmentInfo*/null,
  /*ordMain.rstTreatStaffInfo*/null,
  /*ordMain.rstRoundsInfo*/null,
  /*ordMain.isDel*/'0',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  /*%if ordMain.indDeviceSetInfo != null */
    /*ordMain.indDeviceSetInfo*/null,
  /*%else*/
    (select
      jsonb_build_object('ufr', (device_set_info->'ord'->'ufr' || /*ordMain.indDeviceUserInfo*/'{}')) ||
      jsonb_build_object('na', (device_set_info->'ord'->'na' || /*ordMain.indDeviceUserInfo*/'{}')) ||
      jsonb_build_object('dc', (device_set_info->'ord'->'dc' || /*ordMain.indDeviceUserInfo*/'{}')) ||
      jsonb_build_object('qbqd', (device_set_info->'ord'->'qbqd' || /*ordMain.indDeviceUserInfo*/'{}')) ||
      jsonb_build_object('ihdf', (device_set_info->'ord'->'ihdf' || /*ordMain.indDeviceUserInfo*/'{}')) ||
      jsonb_build_object('bvufc', (device_set_info->'ord'->'bvufc' || /*ordMain.indDeviceUserInfo*/'{}')) ||
      jsonb_build_object('dia', (device_set_info->'ord'->'dia' || /*ordMain.indDeviceUserInfo*/'{}'))
    from mst_device_set_info_default
    where facility_cd = /*ordMain.facilityCd*/null),
  /*%end*/

--   add 10196 by kangjie 20240130 start del
--   /*ordMain.rstDeviceSetInfo*/null,
--   add 10196 by kangjie 20240130 end del

  /*ordMain.treatType*/null,
  /*ordMain.rstPurificationCnt*/null,
  /*ordMain.upIndUserId*/null,
  /*ordMain.upUserId*/null
  -- add 10096 by kangjie 20240119 start
  ,/*ordMain.rstDw*/null
  ,/*ordMain.weightScaleNo*/null
  ,/*ordMain.isConfirm*/0
--   mod 11467 【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。 関 start
  ,/*ordMain.indDw*/null
--   mod 11467 【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。 関 end
  ,/*ordMain.additionInfo*/null
  ,/*ordMain.rstEditionDate*/null
  ,/*ordMain.curEditionDate*/null
  ,/*ordMain.fnPlural*/null
  ,/*ordMain.bvmsPath*/null
  -- add 10096 by kangjie 20240119 end
--   add 11467 【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。 関 start
  ,/*ordMain.indDwUserInfo*/null
  ,/*ordMain.indDeviceMode*/null
  ,/*ordMain.rstDeviceMode*/null
--   add 11467 【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。 関 end
)
;
