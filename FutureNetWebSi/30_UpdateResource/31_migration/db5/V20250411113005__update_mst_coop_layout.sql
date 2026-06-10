DELETE FROM ntss.mst_coop_layout
WHERE ctl_no IN (-5020010, -5020011);

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5020010, 'S_hosp', 'ord_dial', 'bed', 'R', 'all', 'text', 'SSI_透析オーダ受け連携', 'SSI', '透析オーダ受け連携(標準)', '1', '<root name="透析オーダ受け連携(ベッド入れ替え)">
  <item name="CRUD" len="0" col="$journal.const.crud" type="string" value="const:C"/>
  <item name="期間開始日" len="8" type="string" note="取込対象外"/>
  <item name="期間終了日" len="8" type="string" note="取込対象外"/>
  <item name="透析日" len="8" col="$journal.const.date_yyyymmdd" type="string"/>
  <item name="開始時刻" len="4" col="$journal.ord_main.ind_treat_start_time" type="string"/>
  <item name="患者ID" len="12" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
  <item name="患者名" len="20" note="取込対象外"/>
  <item name="透析時間" len="3" type="string"/>
  <item name="治療方法" len="20" col="$journal.ord_main.ind_treatment_name" type="string"/>
  <item name="ベッド-コード" len="10" col="$journal.ord_main.ind_bed_cd" type="string"/>
  <item name="ベッド-名称" len="20" col="$journal.ord_main.ind_bed_name" type="string" note="取込対象外"/>
  <item name="ダイアライザ-コード" len="10" type="string"/>
  <item name="ダイアライザ-名称" len="20" type="string"/>
  <item name="A針-コード" len="10" type="string"/>
  <item name="A針-名称" len="40" type="string"/>
  <item name="V針-コード" len="10" type="string"/>
  <item name="V針-名称" len="40" type="string"/>
  <item name="透析液-コード" len="10" type="string"/>
  <item name="透析液-名称" len="80" type="string"/>
  <item name="透析液-数量" len="7" type="string"/>
  <item name="透析液-単位" len="20" type="string"/>
  <item name="抗凝固剤-コード" len="10" type="string"/>
  <item name="抗凝固剤-名称" len="80" type="string"/>
  <item name="抗凝固剤-ワンショット量" len="7" type="string"/>
  <item name="抗凝固剤-持続注入量" len="7" type="string"/>
  <item name="抗凝固剤-持続総量" len="7" type="string"/>
  <item name="抗凝固剤-単位" len="20" type="string"/>
  <item name="DW" len="5" note="取込対象外"/>
  <item name="DW更新日" len="8" note="取込対象外"/>
  <item name="CTR" len="4" note="取込対象外"/>
  <item name="CTR更新日" len="8" note="取込対象外"/>
  <item name="血流量" len="3" type="string"/>
  <item name="IP速度" len="3" type="string"/>
  <item name="補液量" len="3" type="string"/>
  <item name="除水量制限" len="4" type="string"/>
  <item name="除水速度制限" len="4" note="取込対象外"/>
  <item name="ブラッドアクセスコード" len="10" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス名称" len="40" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス部位" len="1" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス更新日" len="8" note="NTSS関連項目が無し、取込対象外"/>
  <item name="消耗品情報" len="530"/>
  <item name="処方情報" len="4140"/>
  <item name="除水補正-名称-1" len="16" type="string"/>
  <item name="除水補正-量-1" len="5" type="string"/>
  <item name="除水補正-名称-2" len="16" type="string"/>
  <item name="除水補正-量-2" len="5" type="string"/>
  <item name="除水補正-名称-3" len="16" type="string"/>
  <item name="除水補正-量-3" len="5" type="string"/>
  <item name="除水補正-名称-4" len="16" type="string"/>
  <item name="除水補正-量-4" len="5" type="string"/>
  <item name="除水補正-名称-5" len="16" type="string"/>
  <item name="除水補正-量-5" len="5" type="string"/>
  <item name="風袋-名称-1" len="16" type="string"/>
  <item name="風袋-量-1" len="5" type="string"/>
  <item name="風袋-名称-2" len="16" type="string"/>
  <item name="風袋-量-2" len="5" type="string"/>
  <item name="風袋-名称-3" len="16" type="string"/>
  <item name="風袋-量-3" len="5" type="string"/>
  <item name="風袋-名称-4" len="16" type="string"/>
  <item name="風袋-量-4" len="5" type="string"/>
  <item name="風袋-名称-5" len="16" type="string"/>
  <item name="風袋-量-5" len="5" type="string"/>
  <item name="ダイアライザ２-コード２" len="10" type="string"/>
  <item name="ダイアライザ２-名称２" len="20" type="string"/>
  <item name="吸着器コード" len="10" type="string"/>
  <item name="吸着器名称" len="20" type="string"/>
  <item name="透析液-温度" len="3" type="string"/>
  <item name="補液-コード" len="10" type="string"/>
  <item name="補液-名称" len="40" type="string"/>
  <item name="補液-使用数" len="3" type="string"/>
  <item name="補液-速度" len="4" type="string"/>
  <item name="担当医-コード" len="10" col="$journal.ord_main.ind_schedule_user_info.upd_user_id" type="string"/>
  <item name="担当医名" len="20" type="string"/>
  <item name="CRLF" len="2" type="string"/>
</root>
', '{"dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}], "sqlGroup2": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500064, "@indBedCd": "$journal.ord_main.ind_bed_cd", "@indBedName": "$journal.ord_main.ind_bed_name", "ExceptionMessage": "ベッド[@indBedCd]は取込対象外です。", "ExceptionCondition": "<>0"}], "sqlGroup3": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500012, "@indBedCd": "$journal.ord_main.ind_bed_cd", "@indBedName": "$journal.ord_main.ind_bed_name", "ExceptionMessage": "ベッド[@indBedCd]は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}], "sqlGroup4": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": 8101, "@treatDate": "$journal.const.date_yyyymmdd", "updateResult": "{@ordNo:''ord_no'', @patId:''pat_id'', @fnPatId:''fn_pat_id'', @treatDate:''treat_date'', @treatWeek:''treat_week'', @facilityCd:''facility_cd'', @facilityName:''facility_name'', @indVaCd:''ind_va_cd'', @indTreatmentCd:''ind_treatment_cd'', @indTreatmentName:''ind_treatment_name'', @indKurCd:''ind_kur_cd'', @indKurName:''ind_kur_name'', @indTreatStartTime:''ind_treat_start_time'', @indBedCd:''ind_bed_cd'', @indBedName:''ind_bed_name'', @indScheduleUserInfoFlg:'''', @indScheduleUserInfoValue:''ind_schedule_user_info'', @indScheduleUserInfo.indUserId:'''', @indScheduleUserInfo.indUserLastName:'''', @indScheduleUserInfo.indUserFirstName:'''', @indScheduleUserInfo.updUserId:'''', @indScheduleUserInfo.updUserLastName:'''', @indScheduleUserInfo.updUserFirstName:'''', @indCondInfo:''ind_cond_info'', @indMediInfoValue:''ind_medi_info'', @indEquipInfoValue:''ind_equip_info'', @indIndCommentInfoValue:''ind_ind_comment_info'', @indTareInfoFlg:'''', @indTareInfoValue:''ind_tare_info'', @indTareInfo.name1:'''', @indTareInfo.name2:'''', @indTareInfo.name3:'''', @indTareInfo.name4:'''', @indTareInfo.name5:'''', @indTareInfo.weight1:'''', @indTareInfo.weight2:'''', @indTareInfo.weight3:'''', @indTareInfo.weight4:'''', @indTareInfo.weight5:'''', @indOffWaterInfoFlg:'''', @indOffWaterInfoValue:''ind_off_water_info'', @indOffWaterInfo.name1:'''', @indOffWaterInfo.name2:'''', @indOffWaterInfo.name3:'''', @indOffWaterInfo.name4:'''', @indOffWaterInfo.name5:'''', @indOffWaterInfo.weight1:'''', @indOffWaterInfo.weight2:'''', @indOffWaterInfo.weight3:'''', @indOffWaterInfo.weight4:'''', @indOffWaterInfo.weight5:'''', @indDeviceSetInfo:''ind_device_set_info'', @rstFnDialysisNo:''rst_fn_dialysis_no'', @rstRelationDialysisNo:''rst_relation_dialysis_no'', @rstEdition:''rst_edition'', @rstIsUpdateEdition:''rst_is_update_edition'', @rstInputClass:''rst_input_class'', @rstDialysisState:''rst_dialysis_state'', @rstTreatmentCd:''rst_treatment_cd'', @rstTreatmentName:''rst_treatment_name'', @rstKurCd:''rst_kur_cd'', @rstKurName:''rst_kur_name'', @rstBedCd:''rst_bed_cd'', @rstBedName:''rst_bed_name'', @rstMachineNo:''rst_machine_no'', @rstMachineName:''rst_machine_name'', @rstCondSendDate_Date:''rst_cond_send_date'', @rstAcceptDate_Date:''rst_accept_date'', @rstStartDate_Date:''rst_start_date'', @rstEndDate_Date:''rst_end_date'', @rstReturnHomeDate_Date:''rst_return_home_date'', @rstInOutClass:''rst_in_out_class'', @rstDialysisCnt:''rst_dialysis_cnt'', @rstWardCd:''rst_ward_cd'', @rstWardName:''rst_ward_name'', @rstCourseCd:''rst_course_cd'', @rstCourseName:''rst_course_name'', @rstPunctureUserInfo:''rst_puncture_user_info'', @rstReturnUserInfo:''rst_return_user_info'', @rstChargeUserInfo:''rst_charge_user_info'', @rstBloodCirculateTotal:''rst_blood_circulate_total'', @rstRunningTime:''rst_running_time'', @rstKtV:''rst_kt_v'', @recSetDate_Date:''rec_set_date'', @sendCtlNo:''send_ctl_no'', @bloodPurifierName:''blood_purifier_name'', @pullLeaveAmount:''pull_leave_amount'', @rstCondInfo:''rst_cond_info'', @rstMediInfo:''rst_medi_info'', @rstEquipInfo:''rst_equip_info'', @rstIndCommentInfo:''rst_ind_comment_info'', @rstTareInfo:''rst_tare_info'', @rstOffWaterInfo:''rst_off_water_info'', @rstDeviceSetInfo:''rst_device_set_info'', @rstWeightInfo:''rst_weight_info'', @rstVitalInfo:''rst_vital_info'', @rstComplaintInfo:''rst_complaint_info'', @rstTreatmentInfo:''rst_treatment_info'', @rstTreatStaffInfo:''rst_treat_staff_info'', @rstRoundsInfo:''rst_rounds_info'', @isDel:''is_del'', @upDate_Date:''up_date'', @regDate_Date:''reg_date'', @rstDw:''rst_dw'', @weightScaleNo:''weight_scale_no'', @treatType:''treat_type'', @isConfirm:''is_confirm'', @indDw:''ind_dw'', @rstPurificationCnt:''rst_purification_cnt'', @additionInfo:''addition_info'', @upIndUserId:''up_ind_user_id'', @upUserId:''up_user_id'', @rstEditionDate_Date:''rst_edition_date'', @curEditionDate_Date:''cur_edition_date'', @fnPlural:''fn_plural''}"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500089, "@indBedCd": "$journal.ord_main.ind_bed_cd", "@treatDate": "$journal.const.date_yyyymmdd", "@indBedName": "$journal.ord_main.ind_bed_name", "@indTreatStartTime": "$journal.ord_main.ind_treat_start_time", "@chargeStaffInfo.staffCd": "$journal.ord_main.ind_schedule_user_info.upd_user_id"}]}}'::jsonb, '1', '0', -1, '2025-04-08 14:45:52.443', '2025-04-08 14:45:52.443', 'SSI');


INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5020011, 'S_hosp', 'ord_dial', 'bed', 'R', 'all', 'text', 'SSI_透析オーダ受け連携', 'SSI', '透析オーダ受け連携(拡張)', '1', '<root name="透析オーダ受け連携(ベッド入れ替え)">
  <item name="CRUD" len="0" col="$journal.const.crud" type="string" value="const:C"/>
  <item name="期間開始日" len="8" type="string" note="取込対象外"/>
  <item name="期間終了日" len="8" type="string" note="取込対象外"/>
  <item name="透析日" len="8" col="$journal.const.date_yyyymmdd" type="string"/>
  <item name="開始時刻" len="4" col="$journal.ord_main.ind_treat_start_time" type="string"/>
  <item name="患者ID" len="12" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
  <item name="患者名" len="20" note="取込対象外"/>
  <item name="透析時間" len="4" type="string"/>
  <item name="治療方法" len="20" col="$journal.ord_main.ind_treatment_name" type="string"/>
  <item name="ベッド-コード" len="10" col="$journal.ord_main.ind_bed_cd" type="string"/>
  <item name="ベッド-名称" len="20" col="$journal.ord_main.ind_bed_name" type="string" note="取込対象外"/>
  <item name="ダイアライザ-コード" len="10" type="string"/>
  <item name="ダイアライザ-名称" len="20" type="string"/>
  <item name="A針-コード" len="10" type="string"/>
  <item name="A針-名称" len="40" type="string"/>
  <item name="V針-コード" len="10" type="string"/>
  <item name="V針-名称" len="40" type="string"/>
  <item name="透析液-コード" len="10" type="string"/>
  <item name="透析液-名称" len="80" type="string"/>
  <item name="透析液-数量" len="7" type="string"/>
  <item name="透析液-単位" len="20" type="string"/>
  <item name="抗凝固剤-コード" len="10" type="string"/>
  <item name="抗凝固剤-名称" len="80" type="string"/>
  <item name="抗凝固剤-ワンショット量" len="7" type="string"/>
  <item name="抗凝固剤-持続注入量" len="7" type="string"/>
  <item name="抗凝固剤-持続総量" len="7" type="string"/>
  <item name="抗凝固剤-単位" len="20" type="string"/>
  <item name="DW" len="5" note="取込対象外"/>
  <item name="DW更新日" len="8" note="取込対象外"/>
  <item name="CTR" len="4" note="取込対象外"/>
  <item name="CTR更新日" len="8" note="取込対象外"/>
  <item name="血流量" len="3" type="string"/>
  <item name="IP速度" len="3" type="string"/>
  <item name="補液量" len="4" type="string"/>
  <item name="除水量制限" len="4" type="string"/>
  <item name="除水速度制限" len="4" note="取込対象外"/>
  <item name="ブラッドアクセスコード" len="10" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス名称" len="40" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス部位" len="1" note="NTSS関連項目が無し、取込対象外"/>
  <item name="ブラッドアクセス更新日" len="8" note="NTSS関連項目が無し、取込対象外"/>
  <item name="消耗品情報" len="530"/>
  <item name="処方情報" len="4140"/>
  <item name="除水補正-名称-1" len="16" type="string"/>
  <item name="除水補正-量-1" len="5" type="string"/>
  <item name="除水補正-名称-2" len="16" type="string"/>
  <item name="除水補正-量-2" len="5" type="string"/>
  <item name="除水補正-名称-3" len="16" type="string"/>
  <item name="除水補正-量-3" len="5" type="string"/>
  <item name="除水補正-名称-4" len="16" type="string"/>
  <item name="除水補正-量-4" len="5" type="string"/>
  <item name="除水補正-名称-5" len="16" type="string"/>
  <item name="除水補正-量-5" len="5" type="string"/>
  <item name="風袋-名称-1" len="16" type="string"/>
  <item name="風袋-量-1" len="5" type="string"/>
  <item name="風袋-名称-2" len="16" type="string"/>
  <item name="風袋-量-2" len="5" type="string"/>
  <item name="風袋-名称-3" len="16" type="string"/>
  <item name="風袋-量-3" len="5" type="string"/>
  <item name="風袋-名称-4" len="16" type="string"/>
  <item name="風袋-量-4" len="5" type="string"/>
  <item name="風袋-名称-5" len="16" type="string"/>
  <item name="風袋-量-5" len="5" type="string"/>
  <item name="ダイアライザ２-コード２" len="10" type="string"/>
  <item name="ダイアライザ２-名称２" len="20" type="string"/>
  <item name="吸着器コード" len="10" type="string"/>
  <item name="吸着器名称" len="20" type="string"/>
  <item name="透析液-温度" len="3" type="string"/>
  <item name="補液-コード" len="10" type="string"/>
  <item name="補液-名称" len="40" type="string"/>
  <item name="補液-使用数" len="5" type="string"/>
  <item name="補液-速度" len="4" type="string"/>
  <item name="担当医-コード" len="10" col="$journal.ord_main.ind_schedule_user_info.upd_user_id" type="string"/>
  <item name="担当医名" len="20" type="string"/>
  <item name="CRLF" len="2" type="string"/>
</root>
', '{"dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}], "sqlGroup2": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500064, "@indBedCd": "$journal.ord_main.ind_bed_cd", "@indBedName": "$journal.ord_main.ind_bed_name", "ExceptionMessage": "ベッド[@indBedCd]は取込対象外です。", "ExceptionCondition": "<>0"}], "sqlGroup3": [{"crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": -500012, "@indBedCd": "$journal.ord_main.ind_bed_cd", "@indBedName": "$journal.ord_main.ind_bed_name", "ExceptionMessage": "ベッド[@indBedCd]は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}], "sqlGroup4": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": 8101, "@treatDate": "$journal.const.date_yyyymmdd", "updateResult": "{@ordNo:''ord_no'', @patId:''pat_id'', @fnPatId:''fn_pat_id'', @treatDate:''treat_date'', @treatWeek:''treat_week'', @facilityCd:''facility_cd'', @facilityName:''facility_name'', @indVaCd:''ind_va_cd'', @indTreatmentCd:''ind_treatment_cd'', @indTreatmentName:''ind_treatment_name'', @indKurCd:''ind_kur_cd'', @indKurName:''ind_kur_name'', @indTreatStartTime:''ind_treat_start_time'', @indBedCd:''ind_bed_cd'', @indBedName:''ind_bed_name'', @indScheduleUserInfoFlg:'''', @indScheduleUserInfoValue:''ind_schedule_user_info'', @indScheduleUserInfo.indUserId:'''', @indScheduleUserInfo.indUserLastName:'''', @indScheduleUserInfo.indUserFirstName:'''', @indScheduleUserInfo.updUserId:'''', @indScheduleUserInfo.updUserLastName:'''', @indScheduleUserInfo.updUserFirstName:'''', @indCondInfo:''ind_cond_info'', @indMediInfoValue:''ind_medi_info'', @indEquipInfoValue:''ind_equip_info'', @indIndCommentInfoValue:''ind_ind_comment_info'', @indTareInfoFlg:'''', @indTareInfoValue:''ind_tare_info'', @indTareInfo.name1:'''', @indTareInfo.name2:'''', @indTareInfo.name3:'''', @indTareInfo.name4:'''', @indTareInfo.name5:'''', @indTareInfo.weight1:'''', @indTareInfo.weight2:'''', @indTareInfo.weight3:'''', @indTareInfo.weight4:'''', @indTareInfo.weight5:'''', @indOffWaterInfoFlg:'''', @indOffWaterInfoValue:''ind_off_water_info'', @indOffWaterInfo.name1:'''', @indOffWaterInfo.name2:'''', @indOffWaterInfo.name3:'''', @indOffWaterInfo.name4:'''', @indOffWaterInfo.name5:'''', @indOffWaterInfo.weight1:'''', @indOffWaterInfo.weight2:'''', @indOffWaterInfo.weight3:'''', @indOffWaterInfo.weight4:'''', @indOffWaterInfo.weight5:'''', @indDeviceSetInfo:''ind_device_set_info'', @rstFnDialysisNo:''rst_fn_dialysis_no'', @rstRelationDialysisNo:''rst_relation_dialysis_no'', @rstEdition:''rst_edition'', @rstIsUpdateEdition:''rst_is_update_edition'', @rstInputClass:''rst_input_class'', @rstDialysisState:''rst_dialysis_state'', @rstTreatmentCd:''rst_treatment_cd'', @rstTreatmentName:''rst_treatment_name'', @rstKurCd:''rst_kur_cd'', @rstKurName:''rst_kur_name'', @rstBedCd:''rst_bed_cd'', @rstBedName:''rst_bed_name'', @rstMachineNo:''rst_machine_no'', @rstMachineName:''rst_machine_name'', @rstCondSendDate_Date:''rst_cond_send_date'', @rstAcceptDate_Date:''rst_accept_date'', @rstStartDate_Date:''rst_start_date'', @rstEndDate_Date:''rst_end_date'', @rstReturnHomeDate_Date:''rst_return_home_date'', @rstInOutClass:''rst_in_out_class'', @rstDialysisCnt:''rst_dialysis_cnt'', @rstWardCd:''rst_ward_cd'', @rstWardName:''rst_ward_name'', @rstCourseCd:''rst_course_cd'', @rstCourseName:''rst_course_name'', @rstPunctureUserInfo:''rst_puncture_user_info'', @rstReturnUserInfo:''rst_return_user_info'', @rstChargeUserInfo:''rst_charge_user_info'', @rstBloodCirculateTotal:''rst_blood_circulate_total'', @rstRunningTime:''rst_running_time'', @rstKtV:''rst_kt_v'', @recSetDate_Date:''rec_set_date'', @sendCtlNo:''send_ctl_no'', @bloodPurifierName:''blood_purifier_name'', @pullLeaveAmount:''pull_leave_amount'', @rstCondInfo:''rst_cond_info'', @rstMediInfo:''rst_medi_info'', @rstEquipInfo:''rst_equip_info'', @rstIndCommentInfo:''rst_ind_comment_info'', @rstTareInfo:''rst_tare_info'', @rstOffWaterInfo:''rst_off_water_info'', @rstDeviceSetInfo:''rst_device_set_info'', @rstWeightInfo:''rst_weight_info'', @rstVitalInfo:''rst_vital_info'', @rstComplaintInfo:''rst_complaint_info'', @rstTreatmentInfo:''rst_treatment_info'', @rstTreatStaffInfo:''rst_treat_staff_info'', @rstRoundsInfo:''rst_rounds_info'', @isDel:''is_del'', @upDate_Date:''up_date'', @regDate_Date:''reg_date'', @rstDw:''rst_dw'', @weightScaleNo:''weight_scale_no'', @treatType:''treat_type'', @isConfirm:''is_confirm'', @indDw:''ind_dw'', @rstPurificationCnt:''rst_purification_cnt'', @additionInfo:''addition_info'', @upIndUserId:''up_ind_user_id'', @upUserId:''up_user_id'', @rstEditionDate_Date:''rst_edition_date'', @curEditionDate_Date:''cur_edition_date'', @fnPlural:''fn_plural''}"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": -500089, "@indBedCd": "$journal.ord_main.ind_bed_cd", "@treatDate": "$journal.const.date_yyyymmdd", "@indBedName": "$journal.ord_main.ind_bed_name", "@indTreatStartTime": "$journal.ord_main.ind_treat_start_time", "@chargeStaffInfo.staffCd": "$journal.ord_main.ind_schedule_user_info.upd_user_id"}]}}'::jsonb, '1', '1', -1, '2025-03-26 16:24:35.361', CURRENT_TIMESTAMP, 'SSI');