insert into ord_main
(
ord_no,
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
  -- add 10196 by kangjie 20240130 start del
-- ,rst_vital_info
  -- add 10196 by kangjie 20240130 end del
,rst_complaint_info
,rst_treatment_info
,rst_treat_staff_info
,rst_rounds_info
,is_del
,up_date
,reg_date
,ind_device_set_info
  -- add 10196 by kangjie 20240130 start del
-- ,rst_device_set_info
  -- add 10196 by kangjie 20240130 end del
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
/*%for oms : ordMainList */
(
  /*oms.ordNo*/null,
  /*oms.patId*/null,
  /*oms.fnPatId*/null,
  /*oms.treatDate*/null,
  /*oms.treatWeek*/null,
  /*oms.facilityCd*/null,
  /*oms.facilityName*/null,
  /*oms.indVaCd*/null,
  /*oms.indTreatmentCd*/null,
  /*oms.indTreatmentName*/null,
  /*oms.indKurCd*/null,
  /*oms.indKurName*/null,
  /*oms.indTreatStartTime*/null,
  /*oms.indBedCd*/null,
  /*oms.indBedName*/null,
  /*oms.indScheduleUserInfo*/null,
  /*oms.indCondInfo*/null,
  /*oms.indMediInfo*/null,
  /*oms.indEquipInfo*/null,
  /*oms.indIndCommentInfo*/null,
  /*oms.indTareInfo*/null,
  /*oms.indOffWaterInfo*/null,
  /*oms.rstFnDialysisNo*/null,
  /*oms.rstRelationDialysisNo*/null,
  /*oms.rstEdition*/'0',
  /*oms.rstIsUpdateEdition*/null,
  /*oms.rstInputClass*/null,
  /*oms.rstDialysisState*/'0',
  /*oms.rstTreatmentCd*/null,
  /*oms.rstTreatmentName*/null,
  /*oms.rstKurCd*/null,
  /*oms.rstKurName*/null,
  /*oms.rstBedCd*/null,
  /*oms.rstBedName*/null,
  /*oms.rstMachineNo*/null,
  /*oms.rstMachineName*/null,
  /*oms.rstCondSendDate*/null,
  /*oms.rstAcceptDate*/null,
  /*oms.rstStartDate*/null,
  /*oms.rstEndDate*/null,
  /*oms.rstReturnHomeDate*/null,
  /*oms.rstInOutClass*/null,
  /*oms.rstDialysisCnt*/null,
  /*oms.rstWardCd*/null,
  /*oms.rstWardName*/null,
  /*oms.rstCourseCd*/null,
  /*oms.rstCourseName*/null,
  /*oms.rstPunctureUserInfo*/null,
  /*oms.rstReturnUserInfo*/null,
  /*oms.rstChargeUserInfo*/null,
  /*oms.rstBloodCirculateTotal*/null,
  /*oms.rstRunningTime*/null,
  /*oms.rstKtV*/null,
  /*oms.recSetDate*/null,
  /*oms.sendCtlNo*/null,
  /*oms.bloodPurifierName*/null,
  /*oms.pullLeaveAmount*/null,
  /*oms.rstCondInfo*/null,
  /*oms.rstMediInfo*/null,
  /*oms.rstEquipInfo*/null,
  /*oms.rstIndCommentInfo*/null,
  /*oms.rstTareInfo*/null,
  /*oms.rstOffWaterInfo*/null,
  /*oms.rstWeightInfo*/null,
 -- add 10196 by kangjie 20240130 start del
 -- /*oms.rstVitalInfo*/null,
 -- add 10196 by kangjie 20240130 start del
  /*oms.rstComplaintInfo*/null,
  /*oms.rstTreatmentInfo*/null,
  /*oms.rstTreatStaffInfo*/null,
  /*oms.rstRoundsInfo*/null,
  /*oms.isDel*/'0',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  /*%if oms.indDeviceSetInfo != null */
    /*oms.indDeviceSetInfo*/null,
  /*%else*/
    (select
      jsonb_build_object('ufr', (device_set_info->'ord'->'ufr' || /*oms.indDeviceUserInfo*/'{}')) ||
      jsonb_build_object('na', (device_set_info->'ord'->'na' || /*oms.indDeviceUserInfo*/'{}')) ||
      jsonb_build_object('dc', (device_set_info->'ord'->'dc' || /*oms.indDeviceUserInfo*/'{}')) ||
      jsonb_build_object('qbqd', (device_set_info->'ord'->'qbqd' || /*oms.indDeviceUserInfo*/'{}')) ||
      jsonb_build_object('ihdf', (device_set_info->'ord'->'ihdf' || /*oms.indDeviceUserInfo*/'{}')) ||
      jsonb_build_object('bvufc', (device_set_info->'ord'->'bvufc' || /*oms.indDeviceUserInfo*/'{}')) ||
      jsonb_build_object('dia', (device_set_info->'ord'->'dia' || /*oms.indDeviceUserInfo*/'{}'))
    from mst_device_set_info_default
    where facility_cd = /*oms.facilityCd*/null),
  /*%end*/
--   add 10196 by kangjie 20240130 start del
--   /*oms.rstDeviceSetInfo*/null,
--   add 10196 by kangjie 20240130 end del
  /*oms.treatType*/null,
  /*oms.rstPurificationCnt*/null,
  /*oms.upIndUserId*/null,
  /*oms.upUserId*/null
  -- add 10096 by kangjie 20240119 start
  , /*oms.rstDw*/null
  , /*oms.weightScaleNo*/null
  , /*oms.isConfirm*/0
  , /*oms.indDw*/null
  , /*oms.additionInfo*/null
  , /*oms.rstEditionDate*/null
  , /*oms.curEditionDate*/null
  , /*oms.fnPlural*/null
  , /*oms.bvmsPath*/null
  -- add 10096 by kangjie 20240119 end
--   add 11467 【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。 関 start
  ,/*oms.indDwUserInfo*/null
  ,/*oms.indDeviceMode*/null
  ,/*oms.rstDeviceMode*/null
--   add 11467 【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。 関 end
)
    /*%if oms_has_next */
    /*# "," */
    /*%end */
/*%end*/
