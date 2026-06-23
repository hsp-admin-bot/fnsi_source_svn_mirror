delete from "mst_coop_layout" where "ctl_no" in (-5020001,-5020002,-5020003,-5020004,-5020005,-5020006);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-5020001, 'S_hosp', 'ord_dial', '', 'R', 'pre', 'text', 'SSI_透析オーダ受け連携', 'SSI', '透析オーダ受け連携(標準)', '1', '<root name="透析オーダ受け連携(標準 pre)">
    <item name="期間開始日" len="8" type="string"/>
    <item name="期間終了日" len="8" type="string"/>
    <item name="透析日" len="8" type="string"/>
    <item name="開始時刻" len="4" key="shori_kbn" type="string"/>
    <item name="患者ID" len="12" type="string"/>
    <item name="患者名" len="20" type="string"/>
    <item name="透析時間" len="3" type="string"/>
    <item name="治療方法" len="20" type="string"/>
    <item name="ベッド-コード" len="10" type="string"/>
    <item name="ベッド-名称" len="20" type="string"/>
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
    <item name="DW" len="5" type="string"/>
    <item name="DW更新日" len="8" type="string"/>
    <item name="CTR" len="4" type="string"/>
    <item name="CTR更新日" len="8" type="string"/>
    <item name="血流量" len="3" type="string"/>
    <item name="IP速度" len="3" type="string"/>
    <item name="補液量" len="3" type="string"/>
    <item name="除水量制限" len="4" type="string"/>
    <item name="除水速度制限" len="4" type="string"/>
    <item name="ブラッドアクセスコード" len="10" type="string"/>
    <item name="ブラッドアクセス名称" len="40" type="string"/>
    <item name="ブラッドアクセス部位" len="1" type="string"/>
    <item name="ブラッドアクセス更新日" len="8" type="string"/>
    <occ name="消耗品情報" len="0" repeat="10" detail="消耗品情報"/>
    <occ name="処方情報" len="0" repeat="20" detail="処方情報"/>
    <occ name="除水補正情報" len="0" repeat="5" detail="除水補正情報"/>
    <occ name="風袋情報" len="0" repeat="5" detail="風袋情報"/>
    <item name="ダイアライザ２-コード２" len="10" type="string"/>
    <item name="ダイアライザ２-名称２" len="20" type="string"/>
    <item name="吸着器コード" len="10" type="string"/>
    <item name="吸着器名称" len="20" type="string"/>
    <item name="透析液-温度" len="3" type="string"/>
    <item name="補液-コード" len="10" type="string"/>
    <item name="補液-名称" len="40" type="string"/>
    <item name="補液-使用数" len="3" type="string"/>
    <item name="補液-速度" len="4" type="string"/>
    <item name="担当医-コード" len="10" type="string"/>
    <item name="担当医名" len="20" type="string"/>
    <item name="CRLF" len="2" type="string"/>
</root>', '{"key": {"shori_kbn": {"9999": "削除", "_DEFAULT": "登録"}}, "dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}], "sqlGroup2": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": 8101, "@treatDate": "$journal.ord_main.treat_date", "insertResult": "{@ordNo:'''', @patId:'''', @fnPatId:'''', @treatDate:'''', @treatWeek:'''', @facilityCd:'''', @facilityName:'''', @indVaCd:'''', @indTreatmentCd:'''', @indTreatmentName:'''', @indKurCd:'''', @indKurName:'''', @indTreatStartTime:'''', @indBedCd:'''', @indBedName:'''', @indScheduleUserInfoFlg:'''', @indScheduleUserInfo.indUserId:'''', @indScheduleUserInfo.indUserLastName:'''', @indScheduleUserInfo.indUserFirstName:'''', @indScheduleUserInfo.updUserId:'''', @indScheduleUserInfo.updUserLastName:'''', @indScheduleUserInfo.updUserFirstName:'''', @indCondInfo:''{}'', @indMediInfoValue:''[]'', @indEquipInfoValue:''[]'', @indIndCommentInfoValue:''[]'', @indTareInfoFlg:'''', @indTareInfo.name1:'''', @indTareInfo.name2:'''', @indTareInfo.name3:'''', @indTareInfo.name4:'''', @indTareInfo.name5:'''', @indTareInfo.weight1:'''', @indTareInfo.weight2:'''', @indTareInfo.weight3:'''', @indTareInfo.weight4:'''', @indTareInfo.weight5:'''', @indOffWaterInfoFlg:'''', @indOffWaterInfo.name1:'''', @indOffWaterInfo.name2:'''', @indOffWaterInfo.name3:'''', @indOffWaterInfo.name4:'''', @indOffWaterInfo.name5:'''', @indOffWaterInfo.weight1:'''', @indOffWaterInfo.weight2:'''', @indOffWaterInfo.weight3:'''', @indOffWaterInfo.weight4:'''', @indOffWaterInfo.weight5:'''', @indDeviceSetInfo:''{}'', @rstFnDialysisNo:'''', @rstRelationDialysisNo:'''', @rstEdition:''0'', @rstIsUpdateEdition:'''', @rstInputClass:'''', @rstDialysisState:''0'', @rstTreatmentCd:'''', @rstTreatmentName:'''', @rstKurCd:'''', @rstKurName:'''', @rstBedCd:'''', @rstBedName:'''', @rstMachineNo:'''', @rstMachineName:'''', @rstCondSendDate_Date:'''', @rstAcceptDate_Date:'''', @rstStartDate_Date:'''', @rstEndDate_Date:'''', @rstReturnHomeDate_Date:'''', @rstInOutClass:'''', @rstDialysisCnt:'''', @rstWardCd:'''', @rstWardName:'''', @rstCourseCd:'''', @rstCourseName:'''', @rstPunctureUserInfo:'''', @rstReturnUserInfo:'''', @rstChargeUserInfo:'''', @rstBloodCirculateTotal:'''', @rstRunningTime:'''', @rstKtV:'''', @recSetDate_Date:'''', @sendCtlNo:'''', @bloodPurifierName:'''', @pullLeaveAmount:'''', @rstCondInfo:'''', @rstMediInfo:'''', @rstEquipInfo:'''', @rstIndCommentInfo:'''', @rstTareInfo:'''', @rstOffWaterInfo:'''', @rstDeviceSetInfo:'''', @rstWeightInfo:'''', @rstVitalInfo:'''', @rstComplaintInfo:'''', @rstTreatmentInfo:'''', @rstTreatStaffInfo:'''', @rstRoundsInfo:'''', @isDel:''0'', @upDate_Date:'''', @regDate_Date:'''', @rstDw:'''', @weightScaleNo:'''', @treatType:''1'', @isConfirm:''0'', @indDw:'''', @rstPurificationCnt:'''', @additionInfo:'''', @upIndUserId:'''', @upUserId:'''', @rstEditionDate_Date:'''', @curEditionDate_Date:'''', @fnPlural:''''}", "updateResult": "{@ordNo:''ord_no'', @patId:''pat_id'', @fnPatId:''fn_pat_id'', @treatDate:''treat_date'', @treatWeek:''treat_week'', @facilityCd:''facility_cd'', @facilityName:''facility_name'', @indVaCd:''ind_va_cd'', @indTreatmentCd:''ind_treatment_cd'', @indTreatmentName:''ind_treatment_name'', @indKurCd:''ind_kur_cd'', @indKurName:''ind_kur_name'', @indTreatStartTime:''ind_treat_start_time'', @indBedCd:''ind_bed_cd'', @indBedName:''ind_bed_name'', @indScheduleUserInfoFlg:'''', @indScheduleUserInfoValue:''ind_schedule_user_info'', @indScheduleUserInfo.indUserId:'''', @indScheduleUserInfo.indUserLastName:'''', @indScheduleUserInfo.indUserFirstName:'''', @indScheduleUserInfo.updUserId:'''', @indScheduleUserInfo.updUserLastName:'''', @indScheduleUserInfo.updUserFirstName:'''', @indCondInfo:''ind_cond_info'', @indMediInfoValue:''ind_medi_info'', @indEquipInfoValue:''ind_equip_info'', @indIndCommentInfoValue:''ind_ind_comment_info'', @indTareInfoFlg:'''', @indTareInfoValue:''ind_tare_info'', @indTareInfo.name1:'''', @indTareInfo.name2:'''', @indTareInfo.name3:'''', @indTareInfo.name4:'''', @indTareInfo.name5:'''', @indTareInfo.weight1:'''', @indTareInfo.weight2:'''', @indTareInfo.weight3:'''', @indTareInfo.weight4:'''', @indTareInfo.weight5:'''', @indOffWaterInfoFlg:'''', @indOffWaterInfoValue:''ind_off_water_info'', @indOffWaterInfo.name1:'''', @indOffWaterInfo.name2:'''', @indOffWaterInfo.name3:'''', @indOffWaterInfo.name4:'''', @indOffWaterInfo.name5:'''', @indOffWaterInfo.weight1:'''', @indOffWaterInfo.weight2:'''', @indOffWaterInfo.weight3:'''', @indOffWaterInfo.weight4:'''', @indOffWaterInfo.weight5:'''', @indDeviceSetInfo:''ind_device_set_info'', @rstFnDialysisNo:''rst_fn_dialysis_no'', @rstRelationDialysisNo:''rst_relation_dialysis_no'', @rstEdition:''rst_edition'', @rstIsUpdateEdition:''rst_is_update_edition'', @rstInputClass:''rst_input_class'', @rstDialysisState:''rst_dialysis_state'', @rstTreatmentCd:''rst_treatment_cd'', @rstTreatmentName:''rst_treatment_name'', @rstKurCd:''rst_kur_cd'', @rstKurName:''rst_kur_name'', @rstBedCd:''rst_bed_cd'', @rstBedName:''rst_bed_name'', @rstMachineNo:''rst_machine_no'', @rstMachineName:''rst_machine_name'', @rstCondSendDate_Date:''rst_cond_send_date'', @rstAcceptDate_Date:''rst_accept_date'', @rstStartDate_Date:''rst_start_date'', @rstEndDate_Date:''rst_end_date'', @rstReturnHomeDate_Date:''rst_return_home_date'', @rstInOutClass:''rst_in_out_class'', @rstDialysisCnt:''rst_dialysis_cnt'', @rstWardCd:''rst_ward_cd'', @rstWardName:''rst_ward_name'', @rstCourseCd:''rst_course_cd'', @rstCourseName:''rst_course_name'', @rstPunctureUserInfo:''rst_puncture_user_info'', @rstReturnUserInfo:''rst_return_user_info'', @rstChargeUserInfo:''rst_charge_user_info'', @rstBloodCirculateTotal:''rst_blood_circulate_total'', @rstRunningTime:''rst_running_time'', @rstKtV:''rst_kt_v'', @recSetDate_Date:''rec_set_date'', @sendCtlNo:''send_ctl_no'', @bloodPurifierName:''blood_purifier_name'', @pullLeaveAmount:''pull_leave_amount'', @rstCondInfo:''rst_cond_info'', @rstMediInfo:''rst_medi_info'', @rstEquipInfo:''rst_equip_info'', @rstIndCommentInfo:''rst_ind_comment_info'', @rstTareInfo:''rst_tare_info'', @rstOffWaterInfo:''rst_off_water_info'', @rstDeviceSetInfo:''rst_device_set_info'', @rstWeightInfo:''rst_weight_info'', @rstVitalInfo:''rst_vital_info'', @rstComplaintInfo:''rst_complaint_info'', @rstTreatmentInfo:''rst_treatment_info'', @rstTreatStaffInfo:''rst_treat_staff_info'', @rstRoundsInfo:''rst_rounds_info'', @isDel:''is_del'', @upDate_Date:''up_date'', @regDate_Date:''reg_date'', @rstDw:''rst_dw'', @weightScaleNo:''weight_scale_no'', @treatType:''treat_type'', @isConfirm:''is_confirm'', @indDw:''ind_dw'', @rstPurificationCnt:''rst_purification_cnt'', @additionInfo:''addition_info'', @upIndUserId:''up_ind_user_id'', @upUserId:''up_user_id'', @rstEditionDate_Date:''rst_edition_date'', @curEditionDate_Date:''cur_edition_date'', @fnPlural:''fn_plural''}"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": 8102, "@indBedCd": "$journal.ord_main.ind_bed_cd", "@upUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@treatDate": "$journal.ord_main.treat_date", "@indBedName": "$journal.ord_main.ind_bed_name", "@indEquipInfo.cd": "$journal.ord_main.ind_equip_info.cd", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "@indEquipInfo.name": "$journal.ord_main.ind_equip_info.name", "@indTreatStartTime": "$journal.ord_main.ind_treat_start_time", "@indScheduleUserInfo.indUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@indScheduleUserInfo.updUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@indScheduleUserInfo.indUserLastName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.updUserLastName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.indUserFirstName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.updUserFirstName": "$journal.ord_main.ind_schedule_user_info.upd_user_name"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "3", "sqlCode": 8103, "@indBedCd": "$journal.ord_main.ind_bed_cd", "@upUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@treatDate": "$journal.ord_main.treat_date", "@indBedName": "$journal.ord_main.ind_bed_name", "@indEquipInfo.cd": "$journal.ord_main.ind_equip_info.cd", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "@indEquipInfo.name": "$journal.ord_main.ind_equip_info.name", "@indTreatStartTime": "$journal.ord_main.ind_treat_start_time", "@indScheduleUserInfo.indUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@indScheduleUserInfo.updUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@indScheduleUserInfo.indUserLastName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.updUserLastName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.indUserFirstName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.updUserFirstName": "$journal.ord_main.ind_schedule_user_info.upd_user_name"}], "sqlGroup3": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": 8101, "@treatDate": "$journal.ord_main.treat_date", "updateResult": "{@ordNo:''ord_no''}"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": 8104, "@indCondInfo.format": "Standard", "@indCondInfo.015.unit": "$journal.ord_main.ind_cond_info.015.unit", "@indCondInfo.025.unit": "$journal.ord_main.ind_cond_info.025.unit", "@indCondInfo.001.value": "$journal.ord_main.ind_cond_info.001.value", "@indCondInfo.004.value": "$journal.ord_main.ind_cond_info.004.value", "@indCondInfo.005.value": "$journal.ord_main.ind_cond_info.005.value", "@indCondInfo.006.value": "$journal.ord_main.ind_cond_info.006.value", "@indCondInfo.010.value": "$journal.ord_main.ind_cond_info.010.value", "@indCondInfo.011.value": "$journal.ord_main.ind_cond_info.011.value", "@indCondInfo.014.value": "$journal.ord_main.ind_cond_info.014.value", "@indCondInfo.015.value": "$journal.ord_main.ind_cond_info.015.value", "@indCondInfo.017.value": "$journal.ord_main.ind_cond_info.017.value", "@indCondInfo.018.value": "$journal.ord_main.ind_cond_info.018.value", "@indCondInfo.019.value": "$journal.ord_main.ind_cond_info.019.value", "@indCondInfo.020.value": "$journal.ord_main.ind_cond_info.020.value", "@indCondInfo.022.value": "$journal.ord_main.ind_cond_info.022.value", "@indCondInfo.024.value": "$journal.ord_main.ind_cond_info.024.value", "@indCondInfo.025.value": "$journal.ord_main.ind_cond_info.025.value", "@indCondInfo.026.value": "$journal.ord_main.ind_cond_info.026.value", "@indCondInfo.027.value": "$journal.ord_main.ind_cond_info.027.value", "@indCondInfo.028.value": "$journal.ord_main.ind_cond_info.028.value", "@indCondInfo.033.value": "$journal.ord_main.ind_cond_info.033.value", "@indCondInfo.005.valueName1": "$journal.ord_main.ind_cond_info.005.value_name_1", "@indCondInfo.006.valueName1": "$journal.ord_main.ind_cond_info.006.value_name_1", "@indCondInfo.010.valueName1": "$journal.ord_main.ind_cond_info.010.value_name_1", "@indCondInfo.011.valueName1": "$journal.ord_main.ind_cond_info.011.value_name_1", "@indCondInfo.015.valueName1": "$journal.ord_main.ind_cond_info.015.value_name_1", "@indCondInfo.019.valueName1": "$journal.ord_main.ind_cond_info.019.value_name_1", "@indCondInfo.025.valueName1": "$journal.ord_main.ind_cond_info.025.value_name_1"}], "sqlGroup4": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#=#D", "table": "ord_main", "ctl_no": "1", "sqlCode": 8101, "@treatDate": "$journal.ord_main.treat_date", "updateResult": "{@ordNo:''ord_no''}"}, {"crud": "U", "kind": "1", "note": "倫理削除処理", "judge": "$journal.const.crud#=#D", "table": "ord_main", "ctl_no": "2", "sqlCode": 8105, "@upUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id"}], "sqlGroup5": [{"crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.crud#<>#D", "table": "ord_main_1", "ctl_no": "1", "sqlCode": 8101, "@treatDate": "$journal.ord_main.treat_date", "updateResult": "{@indEquipInfoFlg:'''', @indEquipInfoValue:''ind_equip_info'', @indEquipInfo.cd:'''', @indEquipInfo.name:'''', @indEquipInfo.unit:'''', @indEquipInfo.amount:'''', @indEquipInfo.classCd:'''', @indEquipInfo.className:'''', @indEquipInfo.classType:'''', @indEquipInfo.equipType:''0'', @indEquipInfo.shortName:'''', @indEquipInfo.indUserId:'''', @indEquipInfo.inputClass:''3'', @indEquipInfo.isEditable:''1'', @indEquipInfo.needleType:'''', @indEquipInfo.updUserId:'''', @indEquipInfo.copOrderNo:'''', @indEquipInfo.indUserLastName:'''', @indEquipInfo.updUserLastName:'''', @indEquipInfo.indUserFirstName:'''', @indEquipInfo.updUserFirstName:''''}"}, {"Note": "json場合、[D]の設定が必要です。しかし、消耗品情報をクリアしません。judgeに[crud#=#NG]を設定する。", "crud": "D", "kind": "1", "judge": "$journal.const.crud#=#NG", "table": "ord_main_1", "ctl_no": "2", "sqlCode": 8106}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_1", "ctl_no": "3", "sqlCode": 8107, "@indEquipInfo.cd": "$journal.detail.ord_main_1.ind_equip_info.cd", "@indEquipInfo.name": "$journal.detail.ord_main_1.ind_equip_info.name", "@indEquipInfo.amount": "$journal.detail.ord_main_1.ind_equip_info.amount", "@indEquipInfo.equipType": "0", "@indEquipInfo.inputClass": "3", "@indEquipInfo.isEditable": "1"}], "sqlGroup6": [{"crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.crud#<>#D", "table": "ord_main_2", "ctl_no": "1", "sqlCode": 8101, "@treatDate": "$journal.ord_main.treat_date", "updateResult": "{@indMediInfoFlg:'''', @indMediInfoValue:''ind_medi_info'', @indMediInfo.cd:'''', @indMediInfo.no:'''', @indMediInfo.name:'''', @indMediInfo.unit:'''', @indMediInfo.amount:'''', @indMediInfo.comment:'''', @indMediInfo.classCd:'''', @indMediInfo.initDate:'''', @indMediInfo.timingCd:'''', @indMediInfo.className:'''', @indMediInfo.classType:'''', @indMediInfo.shortName:'''', @indMediInfo.indUserId:'''', @indMediInfo.inputClass:'''', @indMediInfo.isEditable:'''', @indMediInfo.timingName:'''', @indMediInfo.updUserId:'''', @indMediInfo.copOrderNo:'''', @indMediInfo.procedureCd:'''', @indMediInfo.dateInterval:'''', @indMediInfo.medicineType:'''', @indMediInfo.procedureName:'''', @indMediInfo.indUserLastName:'''', @indMediInfo.updUserLastName:'''', @indMediInfo.indUserFirstName:'''', @indMediInfo.updUserFirstName:''''}"}, {"Note": "json場合、[D]の設定が必要です。しかし、処方情報をクリアしません。judgeに[crud#=#NG]を設定する。", "crud": "D", "kind": "1", "judge": "$journal.const.crud#=#NG", "table": "ord_main_2", "ctl_no": "2", "sqlCode": 8108}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_2", "ctl_no": "3", "sqlCode": 8109, "@indMediInfo.cd": "$journal.detail.ord_main_2.ind_medi_info.cd", "@indMediInfo.name": "$journal.detail.ord_main_2.ind_medi_info.name", "@indMediInfo.unit": "$journal.detail.ord_main_2.ind_medi_info.unit", "@indMediInfo.amount": "$journal.detail.ord_main_2.ind_medi_info.amount", "@indMediInfo.inputClass": "3", "@indMediInfo.isEditable": "1", "@indMediInfo.procedureCd": "$journal.detail.ord_main_2.ind_medi_info.procedure_cd", "@indMediInfo.medicineType": "1", "@indMediInfo.procedureName": "$journal.detail.ord_main_2.ind_medi_info.procedure_name"}]}}', '1', '0', 4, '2020-05-14 09:30:43.362', '2020-05-14 09:30:49.059');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-5020002, 'S_hosp', 'ord_dial', '', 'R', '登録', 'text', 'SSI_透析オーダ受け連携', 'SSI', '透析オーダ受け連携(標準)', '1', '<root name="透析オーダ受け連携(標準 登録)">
    <item name="CRUD" len="0" col="$journal.const.crud" type="string" value="const:C"/>
    <item name="期間開始日" len="8" type="string" note="取込対象外"/>
    <item name="期間終了日" len="8" type="string" note="取込対象外"/>
    <item name="透析日" len="8" col="$journal.ord_main.treat_date" type="string"/>
    <item name="開始時刻" len="4" col="$journal.ord_main.ind_treat_start_time" type="string"/>
    <item name="患者ID" len="12" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
    <item name="患者名" len="20" col="$journal.pat_personal_main.pat_name" type="string" note="取込対象外"/>
    <item name="透析時間" len="3" col="$journal.ord_main.ind_cond_info.001.value" type="string"/>
    <item name="治療方法" len="20" col="$journal.ord_main.ind_treatment_name" type="string"/>
    <item name="ベッド-コード" len="10" col="$journal.ord_main.ind_bed_cd" type="string"/>
    <item name="ベッド-名称" len="20" col="$journal.ord_main.ind_bed_name" type="string" note="取込対象外"/>
    <item name="ダイアライザ-コード" len="10" col="$journal.ord_main.ind_cond_info.005.value" type="string"/>
    <item name="ダイアライザ-名称" len="20" col="$journal.ord_main.ind_cond_info.005.value_name_1" type="string"/>
    <item name="A針-コード" len="10" col="$journal.ord_main.ind_cond_info.010.value" type="string"/>
    <item name="A針-名称" len="40" col="$journal.ord_main.ind_cond_info.010.value_name_1" type="string"/>
    <item name="V針-コード" len="10" col="$journal.ord_main.ind_cond_info.011.value" type="string"/>
    <item name="V針-名称" len="40" col="$journal.ord_main.ind_cond_info.011.value_name_1" type="string"/>
    <item name="透析液-コード" len="10" col="$journal.ord_main.ind_cond_info.015.value" type="string"/>
    <item name="透析液-名称" len="80" col="$journal.ord_main.ind_cond_info.015.value_name_1" type="string"/>
    <item name="透析液-数量" len="7" col="$journal.ord_main.ind_cond_info.017.value" type="string"/>
    <item name="透析液-単位" len="20" col="$journal.ord_main.ind_cond_info.015.unit" type="string"/>
    <item name="抗凝固剤-コード" len="10" col="$journal.ord_main.ind_cond_info.025.value" type="string"/>
    <item name="抗凝固剤-名称" len="80" col="$journal.ord_main.ind_cond_info.025.value_name_1" type="string"/>
    <item name="抗凝固剤-ワンショット量" len="7" col="$journal.ord_main.ind_cond_info.026.value" type="string"/>
    <item name="抗凝固剤-持続注入量" len="7" col="$journal.ord_main.ind_cond_info.027.value" type="string"/>
    <item name="抗凝固剤-持続総量" len="7" col="$journal.ord_main.ind_cond_info.028.value" type="string"/>
    <item name="抗凝固剤-単位" len="20" col="$journal.ord_main.ind_cond_info.025.unit" type="string"/>
    <item name="DW" len="5" col="$journal.pat_unique.physical_info.dw" type="string" note="取込対象外"/>
    <item name="DW更新日" len="8" col="$journal.pat_unique.physical_info.exam_date" type="string" note="取込対象外"/>
    <item name="CTR" len="4" col="$journal.pat_unique.physical_info.ctr" type="string" note="取込対象外"/>
    <item name="CTR更新日" len="8" col="$journal.pat_unique.physical_info.exam_date" type="string" note="取込対象外"/>
    <item name="血流量" len="3" col="$journal.ord_main.ind_cond_info.014.value" type="string"/>
    <item name="IP速度" len="3" col="$journal.ord_main.ind_cond_info.033.value" type="string"/>
    <item name="補液量" len="3" col="$journal.ord_main.ind_cond_info.020.value" type="string"/>
    <item name="除水量制限" len="4" col="$journal.ord_main.ind_cond_info.004.value" type="string"/>
    <item name="除水速度制限" len="4" col="$journal.pat_main.device_set_info.ope.dev.A.181" type="string" note="取込対象外"/>
    <item name="ブラッドアクセスコード" len="10" col="$journal.ord_main.blood_access_info.cd" type="string" note="NTSS関連項目が無し、取込対象外"/>
    <item name="ブラッドアクセス名称" len="40" col="$journal.ord_main.blood_access_info.name" type="string" note="NTSS関連項目が無し、取込対象外"/>
    <item name="ブラッドアクセス部位" len="1" col="$journal.ord_main.blood_access_info.part" type="string" note="NTSS関連項目が無し、取込対象外"/>
    <item name="ブラッドアクセス更新日" len="8" col="$journal.ord_main.blood_access_info.up_date" type="string" note="NTSS関連項目が無し、取込対象外"/>
    <occ name="消耗品情報" len="0" repeat="10" detail="消耗品情報"/>
    <occ name="処方情報" len="0" repeat="20" detail="処方情報"/>
    <occ name="除水補正情報" len="0" repeat="5" detail="除水補正情報" note="取込対象外"/>
    <occ name="風袋情報" len="0" repeat="5" detail="風袋情報" note="取込対象外"/>
    <item name="ダイアライザ２-コード２" len="10" col="$journal.ord_main.ind_equip_info.cd" type="string"/>
    <item name="ダイアライザ２-名称２" len="20" col="$journal.ord_main.ind_equip_info.name" type="string"/>
    <item name="吸着器コード" len="10" col="$journal.ord_main.ind_cond_info.006.value" type="string"/>
    <item name="吸着器名称" len="20" col="$journal.ord_main.ind_cond_info.006.value_name_1" type="string"/>
    <item name="透析液-温度" len="3" col="$journal.ord_main.ind_cond_info.018.value" type="string"/>
    <item name="補液-コード" len="10" col="$journal.ord_main.ind_cond_info.019.value" type="string"/>
    <item name="補液-名称" len="40" col="$journal.ord_main.ind_cond_info.019.value_name_1" type="string"/>
    <item name="補液-使用数" len="3" col="$journal.ord_main.ind_cond_info.022.value" type="string"/>
    <item name="補液-速度" len="4" col="$journal.ord_main.ind_cond_info.024.value" type="string"/>
    <item name="担当医-コード" len="10" col="$journal.ord_main.ind_schedule_user_info.upd_user_id" type="string"/>
    <item name="担当医名" len="20" col="$journal.ord_main.ind_schedule_user_info.upd_user_name" type="string"/>
    <item name="CRLF" len="2" type="string"/>
</root>', '{}', '1', '0', 4, '2020-05-14 09:30:43.362', '2020-05-14 09:30:49.059');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-5020003, 'S_hosp', 'ord_dial', '', 'R', '削除', 'text', 'SSI_透析オーダ受け連携', 'SSI', '透析オーダ受け連携(標準)', '1', '<root name="透析オーダ受け連携(標準 削除)">
    <item name="CRUD" len="0" col="$journal.const.crud" type="string" value="const:D"/>
    <item name="期間開始日" len="8" type="string" note="取込対象外"/>
    <item name="期間終了日" len="8" type="string" note="取込対象外"/>
    <item name="透析日" len="8" col="$journal.ord_main.treat_date" type="string"/>
    <item name="開始時刻" len="4" col="$journal.ord_main.ind_treat_start_time" type="string"/>
    <item name="患者ID" len="12" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
    <item name="患者名" len="20" col="$journal.pat_personal_main.pat_name" type="string" note="取込対象外"/>
    <item name="透析時間" len="3" col="$journal.ord_main.ind_cond_info.001.value" type="string"/>
    <item name="治療方法" len="20" col="$journal.ord_main.ind_treatment_name" type="string"/>
    <item name="ベッド-コード" len="10" col="$journal.ord_main.ind_bed_cd" type="string"/>
    <item name="ベッド-名称" len="20" col="$journal.ord_main.ind_bed_name" type="string" note="取込対象外"/>
    <item name="ダイアライザ-コード" len="10" col="$journal.ord_main.ind_cond_info.005.value" type="string"/>
    <item name="ダイアライザ-名称" len="20" col="$journal.ord_main.ind_cond_info.005.value_name_1" type="string"/>
    <item name="A針-コード" len="10" col="$journal.ord_main.ind_cond_info.010.value" type="string"/>
    <item name="A針-名称" len="40" col="$journal.ord_main.ind_cond_info.010.value_name_1" type="string"/>
    <item name="V針-コード" len="10" col="$journal.ord_main.ind_cond_info.011.value" type="string"/>
    <item name="V針-名称" len="40" col="$journal.ord_main.ind_cond_info.011.value_name_1" type="string"/>
    <item name="透析液-コード" len="10" col="$journal.ord_main.ind_cond_info.015.value" type="string"/>
    <item name="透析液-名称" len="80" col="$journal.ord_main.ind_cond_info.015.value_name_1" type="string"/>
    <item name="透析液-数量" len="7" col="$journal.ord_main.ind_cond_info.017.value" type="string"/>
    <item name="透析液-単位" len="20" col="$journal.ord_main.ind_cond_info.015.unit" type="string"/>
    <item name="抗凝固剤-コード" len="10" col="$journal.ord_main.ind_cond_info.025.value" type="string"/>
    <item name="抗凝固剤-名称" len="80" col="$journal.ord_main.ind_cond_info.025.value_name_1" type="string"/>
    <item name="抗凝固剤-ワンショット量" len="7" col="$journal.ord_main.ind_cond_info.026.value" type="string"/>
    <item name="抗凝固剤-持続注入量" len="7" col="$journal.ord_main.ind_cond_info.027.value" type="string"/>
    <item name="抗凝固剤-持続総量" len="7" col="$journal.ord_main.ind_cond_info.028.value" type="string"/>
    <item name="抗凝固剤-単位" len="20" col="$journal.ord_main.ind_cond_info.025.unit" type="string"/>
    <item name="DW" len="5" col="$journal.pat_unique.physical_info.dw" type="string" note="取込対象外"/>
    <item name="DW更新日" len="8" col="$journal.pat_unique.physical_info.exam_date" type="string" note="取込対象外"/>
    <item name="CTR" len="4" col="$journal.pat_unique.physical_info.ctr" type="string" note="取込対象外"/>
    <item name="CTR更新日" len="8" col="$journal.pat_unique.physical_info.exam_date" type="string" note="取込対象外"/>
    <item name="血流量" len="3" col="$journal.ord_main.ind_cond_info.014.value" type="string"/>
    <item name="IP速度" len="3" col="$journal.ord_main.ind_cond_info.033.value" type="string"/>
    <item name="補液量" len="3" col="$journal.ord_main.ind_cond_info.020.value" type="string"/>
    <item name="除水量制限" len="4" col="$journal.ord_main.ind_cond_info.004.value" type="string"/>
    <item name="除水速度制限" len="4" col="$journal.pat_main.device_set_info.ope.dev.A.181" type="string" note="取込対象外"/>
    <item name="ブラッドアクセスコード" len="10" col="$journal.ord_main.blood_access_info.cd" type="string" note="NTSS関連項目が無し、取込対象外"/>
    <item name="ブラッドアクセス名称" len="40" col="$journal.ord_main.blood_access_info.name" type="string" note="NTSS関連項目が無し、取込対象外"/>
    <item name="ブラッドアクセス部位" len="1" col="$journal.ord_main.blood_access_info.part" type="string" note="NTSS関連項目が無し、取込対象外"/>
    <item name="ブラッドアクセス更新日" len="8" col="$journal.ord_main.blood_access_info.up_date" type="string" note="NTSS関連項目が無し、取込対象外"/>
    <occ name="消耗品情報" len="0" repeat="10" detail="消耗品情報"/>
    <occ name="処方情報" len="0" repeat="20" detail="処方情報"/>
    <occ name="除水補正情報" len="0" repeat="5" detail="除水補正情報" note="取込対象外"/>
    <occ name="風袋情報" len="0" repeat="5" detail="風袋情報" note="取込対象外"/>
    <item name="ダイアライザ２-コード２" len="10" col="$journal.ord_main.ind_equip_info.cd" type="string"/>
    <item name="ダイアライザ２-名称２" len="20" col="$journal.ord_main.ind_equip_info.name" type="string"/>
    <item name="吸着器コード" len="10" col="$journal.ord_main.ind_cond_info.006.value" type="string"/>
    <item name="吸着器名称" len="20" col="$journal.ord_main.ind_cond_info.006.value_name_1" type="string"/>
    <item name="透析液-温度" len="3" col="$journal.ord_main.ind_cond_info.018.value" type="string"/>
    <item name="補液-コード" len="10" col="$journal.ord_main.ind_cond_info.019.value" type="string"/>
    <item name="補液-名称" len="40" col="$journal.ord_main.ind_cond_info.019.value_name_1" type="string"/>
    <item name="補液-使用数" len="3" col="$journal.ord_main.ind_cond_info.022.value" type="string"/>
    <item name="補液-速度" len="4" col="$journal.ord_main.ind_cond_info.024.value" type="string"/>
    <item name="担当医-コード" len="10" col="$journal.ord_main.ind_schedule_user_info.upd_user_id" type="string"/>
    <item name="担当医名" len="20" col="$journal.ord_main.ind_schedule_user_info.upd_user_name" type="string"/>
    <item name="CRLF" len="2" type="string"/>
</root>', '{}', '1', '0', 4, '2020-05-14 09:30:43.362', '2020-05-14 09:30:49.059');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-5020004, 'S_hosp', 'ord_dial', '', 'R', 'pre', 'text', 'SSI_透析オーダ受け連携', 'SSI', '透析オーダ受け連携(拡張)', '1', '<root name="透析オーダ受け連携(拡張 pre)">
    <item name="期間開始日" len="8" type="string"/>
    <item name="期間終了日" len="8" type="string"/>
    <item name="透析日" len="8" type="string"/>
    <item name="開始時刻" len="4" key="shori_kbn" type="string"/>
    <item name="患者ID" len="12" type="string"/>
    <item name="患者名" len="20" type="string"/>
    <item name="透析時間" len="4" type="string"/>
    <item name="治療方法" len="20" type="string"/>
    <item name="ベッド-コード" len="10" type="string"/>
    <item name="ベッド-名称" len="20" type="string"/>
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
    <item name="DW" len="5" type="string"/>
    <item name="DW更新日" len="8" type="string"/>
    <item name="CTR" len="4" type="string"/>
    <item name="CTR更新日" len="8" type="string"/>
    <item name="血流量" len="3" type="string"/>
    <item name="IP速度" len="3" type="string"/>
    <item name="補液量" len="4" type="string"/>
    <item name="除水量制限" len="4" type="string"/>
    <item name="除水速度制限" len="4" type="string"/>
    <item name="ブラッドアクセスコード" len="10" type="string"/>
    <item name="ブラッドアクセス名称" len="40" type="string"/>
    <item name="ブラッドアクセス部位" len="1" type="string"/>
    <item name="ブラッドアクセス更新日" len="8" type="string"/>
    <occ name="消耗品情報" len="0" repeat="10" detail="消耗品情報"/>
    <occ name="処方情報" len="0" repeat="20" detail="処方情報"/>
    <occ name="除水補正情報" len="0" repeat="5" detail="除水補正情報"/>
    <occ name="風袋情報" len="0" repeat="5" detail="風袋情報"/>
    <item name="ダイアライザ２-コード２" len="10" type="string"/>
    <item name="ダイアライザ２-名称２" len="20" type="string"/>
    <item name="吸着器コード" len="10" type="string"/>
    <item name="吸着器名称" len="20" type="string"/>
    <item name="透析液-温度" len="3" type="string"/>
    <item name="補液-コード" len="10" type="string"/>
    <item name="補液-名称" len="40" type="string"/>
    <item name="補液-使用数" len="5" type="string"/>
    <item name="補液-速度" len="4" type="string"/>
    <item name="担当医-コード" len="10" type="string"/>
    <item name="担当医名" len="20" type="string"/>
    <item name="CRLF" len="2" type="string"/>
</root>', '{"key": {"shori_kbn": {"9999": "削除", "_DEFAULT": "登録"}}, "dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}], "sqlGroup2": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": 8101, "@treatDate": "$journal.ord_main.treat_date", "insertResult": "{@ordNo:'''', @patId:'''', @fnPatId:'''', @treatDate:'''', @treatWeek:'''', @facilityCd:'''', @facilityName:'''', @indVaCd:'''', @indTreatmentCd:'''', @indTreatmentName:'''', @indKurCd:'''', @indKurName:'''', @indTreatStartTime:'''', @indBedCd:'''', @indBedName:'''', @indScheduleUserInfoFlg:'''', @indScheduleUserInfo.indUserId:'''', @indScheduleUserInfo.indUserLastName:'''', @indScheduleUserInfo.indUserFirstName:'''', @indScheduleUserInfo.updUserId:'''', @indScheduleUserInfo.updUserLastName:'''', @indScheduleUserInfo.updUserFirstName:'''', @indCondInfo:''{}'', @indMediInfoValue:''[]'', @indEquipInfoValue:''[]'', @indIndCommentInfoValue:''[]'', @indTareInfoFlg:'''', @indTareInfo.name1:'''', @indTareInfo.name2:'''', @indTareInfo.name3:'''', @indTareInfo.name4:'''', @indTareInfo.name5:'''', @indTareInfo.weight1:'''', @indTareInfo.weight2:'''', @indTareInfo.weight3:'''', @indTareInfo.weight4:'''', @indTareInfo.weight5:'''', @indOffWaterInfoFlg:'''', @indOffWaterInfo.name1:'''', @indOffWaterInfo.name2:'''', @indOffWaterInfo.name3:'''', @indOffWaterInfo.name4:'''', @indOffWaterInfo.name5:'''', @indOffWaterInfo.weight1:'''', @indOffWaterInfo.weight2:'''', @indOffWaterInfo.weight3:'''', @indOffWaterInfo.weight4:'''', @indOffWaterInfo.weight5:'''', @indDeviceSetInfo:''{}'', @rstFnDialysisNo:'''', @rstRelationDialysisNo:'''', @rstEdition:''0'', @rstIsUpdateEdition:'''', @rstInputClass:'''', @rstDialysisState:''0'', @rstTreatmentCd:'''', @rstTreatmentName:'''', @rstKurCd:'''', @rstKurName:'''', @rstBedCd:'''', @rstBedName:'''', @rstMachineNo:'''', @rstMachineName:'''', @rstCondSendDate_Date:'''', @rstAcceptDate_Date:'''', @rstStartDate_Date:'''', @rstEndDate_Date:'''', @rstReturnHomeDate_Date:'''', @rstInOutClass:'''', @rstDialysisCnt:'''', @rstWardCd:'''', @rstWardName:'''', @rstCourseCd:'''', @rstCourseName:'''', @rstPunctureUserInfo:'''', @rstReturnUserInfo:'''', @rstChargeUserInfo:'''', @rstBloodCirculateTotal:'''', @rstRunningTime:'''', @rstKtV:'''', @recSetDate_Date:'''', @sendCtlNo:'''', @bloodPurifierName:'''', @pullLeaveAmount:'''', @rstCondInfo:'''', @rstMediInfo:'''', @rstEquipInfo:'''', @rstIndCommentInfo:'''', @rstTareInfo:'''', @rstOffWaterInfo:'''', @rstDeviceSetInfo:'''', @rstWeightInfo:'''', @rstVitalInfo:'''', @rstComplaintInfo:'''', @rstTreatmentInfo:'''', @rstTreatStaffInfo:'''', @rstRoundsInfo:'''', @isDel:''0'', @upDate_Date:'''', @regDate_Date:'''', @rstDw:'''', @weightScaleNo:'''', @treatType:''1'', @isConfirm:''0'', @indDw:'''', @rstPurificationCnt:'''', @additionInfo:'''', @upIndUserId:'''', @upUserId:'''', @rstEditionDate_Date:'''', @curEditionDate_Date:'''', @fnPlural:''''}", "updateResult": "{@ordNo:''ord_no'', @patId:''pat_id'', @fnPatId:''fn_pat_id'', @treatDate:''treat_date'', @treatWeek:''treat_week'', @facilityCd:''facility_cd'', @facilityName:''facility_name'', @indVaCd:''ind_va_cd'', @indTreatmentCd:''ind_treatment_cd'', @indTreatmentName:''ind_treatment_name'', @indKurCd:''ind_kur_cd'', @indKurName:''ind_kur_name'', @indTreatStartTime:''ind_treat_start_time'', @indBedCd:''ind_bed_cd'', @indBedName:''ind_bed_name'', @indScheduleUserInfoFlg:'''', @indScheduleUserInfoValue:''ind_schedule_user_info'', @indScheduleUserInfo.indUserId:'''', @indScheduleUserInfo.indUserLastName:'''', @indScheduleUserInfo.indUserFirstName:'''', @indScheduleUserInfo.updUserId:'''', @indScheduleUserInfo.updUserLastName:'''', @indScheduleUserInfo.updUserFirstName:'''', @indCondInfo:''ind_cond_info'', @indMediInfoValue:''ind_medi_info'', @indEquipInfoValue:''ind_equip_info'', @indIndCommentInfoValue:''ind_ind_comment_info'', @indTareInfoFlg:'''', @indTareInfoValue:''ind_tare_info'', @indTareInfo.name1:'''', @indTareInfo.name2:'''', @indTareInfo.name3:'''', @indTareInfo.name4:'''', @indTareInfo.name5:'''', @indTareInfo.weight1:'''', @indTareInfo.weight2:'''', @indTareInfo.weight3:'''', @indTareInfo.weight4:'''', @indTareInfo.weight5:'''', @indOffWaterInfoFlg:'''', @indOffWaterInfoValue:''ind_off_water_info'', @indOffWaterInfo.name1:'''', @indOffWaterInfo.name2:'''', @indOffWaterInfo.name3:'''', @indOffWaterInfo.name4:'''', @indOffWaterInfo.name5:'''', @indOffWaterInfo.weight1:'''', @indOffWaterInfo.weight2:'''', @indOffWaterInfo.weight3:'''', @indOffWaterInfo.weight4:'''', @indOffWaterInfo.weight5:'''', @indDeviceSetInfo:''ind_device_set_info'', @rstFnDialysisNo:''rst_fn_dialysis_no'', @rstRelationDialysisNo:''rst_relation_dialysis_no'', @rstEdition:''rst_edition'', @rstIsUpdateEdition:''rst_is_update_edition'', @rstInputClass:''rst_input_class'', @rstDialysisState:''rst_dialysis_state'', @rstTreatmentCd:''rst_treatment_cd'', @rstTreatmentName:''rst_treatment_name'', @rstKurCd:''rst_kur_cd'', @rstKurName:''rst_kur_name'', @rstBedCd:''rst_bed_cd'', @rstBedName:''rst_bed_name'', @rstMachineNo:''rst_machine_no'', @rstMachineName:''rst_machine_name'', @rstCondSendDate_Date:''rst_cond_send_date'', @rstAcceptDate_Date:''rst_accept_date'', @rstStartDate_Date:''rst_start_date'', @rstEndDate_Date:''rst_end_date'', @rstReturnHomeDate_Date:''rst_return_home_date'', @rstInOutClass:''rst_in_out_class'', @rstDialysisCnt:''rst_dialysis_cnt'', @rstWardCd:''rst_ward_cd'', @rstWardName:''rst_ward_name'', @rstCourseCd:''rst_course_cd'', @rstCourseName:''rst_course_name'', @rstPunctureUserInfo:''rst_puncture_user_info'', @rstReturnUserInfo:''rst_return_user_info'', @rstChargeUserInfo:''rst_charge_user_info'', @rstBloodCirculateTotal:''rst_blood_circulate_total'', @rstRunningTime:''rst_running_time'', @rstKtV:''rst_kt_v'', @recSetDate_Date:''rec_set_date'', @sendCtlNo:''send_ctl_no'', @bloodPurifierName:''blood_purifier_name'', @pullLeaveAmount:''pull_leave_amount'', @rstCondInfo:''rst_cond_info'', @rstMediInfo:''rst_medi_info'', @rstEquipInfo:''rst_equip_info'', @rstIndCommentInfo:''rst_ind_comment_info'', @rstTareInfo:''rst_tare_info'', @rstOffWaterInfo:''rst_off_water_info'', @rstDeviceSetInfo:''rst_device_set_info'', @rstWeightInfo:''rst_weight_info'', @rstVitalInfo:''rst_vital_info'', @rstComplaintInfo:''rst_complaint_info'', @rstTreatmentInfo:''rst_treatment_info'', @rstTreatStaffInfo:''rst_treat_staff_info'', @rstRoundsInfo:''rst_rounds_info'', @isDel:''is_del'', @upDate_Date:''up_date'', @regDate_Date:''reg_date'', @rstDw:''rst_dw'', @weightScaleNo:''weight_scale_no'', @treatType:''treat_type'', @isConfirm:''is_confirm'', @indDw:''ind_dw'', @rstPurificationCnt:''rst_purification_cnt'', @additionInfo:''addition_info'', @upIndUserId:''up_ind_user_id'', @upUserId:''up_user_id'', @rstEditionDate_Date:''rst_edition_date'', @curEditionDate_Date:''cur_edition_date'', @fnPlural:''fn_plural''}"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": 8102, "@indBedCd": "$journal.ord_main.ind_bed_cd", "@upUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@treatDate": "$journal.ord_main.treat_date", "@indBedName": "$journal.ord_main.ind_bed_name", "@indEquipInfo.cd": "$journal.ord_main.ind_equip_info.cd", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "@indEquipInfo.name": "$journal.ord_main.ind_equip_info.name", "@indTreatStartTime": "$journal.ord_main.ind_treat_start_time", "@indScheduleUserInfo.indUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@indScheduleUserInfo.updUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@indScheduleUserInfo.indUserLastName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.updUserLastName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.indUserFirstName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.updUserFirstName": "$journal.ord_main.ind_schedule_user_info.upd_user_name"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "3", "sqlCode": 8103, "@indBedCd": "$journal.ord_main.ind_bed_cd", "@upUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@treatDate": "$journal.ord_main.treat_date", "@indBedName": "$journal.ord_main.ind_bed_name", "@indEquipInfo.cd": "$journal.ord_main.ind_equip_info.cd", "@indTreatmentName": "$journal.ord_main.ind_treatment_name", "@indEquipInfo.name": "$journal.ord_main.ind_equip_info.name", "@indTreatStartTime": "$journal.ord_main.ind_treat_start_time", "@indScheduleUserInfo.indUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@indScheduleUserInfo.updUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id", "@indScheduleUserInfo.indUserLastName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.updUserLastName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.indUserFirstName": "$journal.ord_main.ind_schedule_user_info.upd_user_name", "@indScheduleUserInfo.updUserFirstName": "$journal.ord_main.ind_schedule_user_info.upd_user_name"}], "sqlGroup3": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": 8101, "@treatDate": "$journal.ord_main.treat_date", "updateResult": "{@ordNo:''ord_no''}"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": 8104, "@indCondInfo.format": "Extended", "@indCondInfo.015.unit": "$journal.ord_main.ind_cond_info.015.unit", "@indCondInfo.025.unit": "$journal.ord_main.ind_cond_info.025.unit", "@indCondInfo.001.value": "$journal.ord_main.ind_cond_info.001.value", "@indCondInfo.004.value": "$journal.ord_main.ind_cond_info.004.value", "@indCondInfo.005.value": "$journal.ord_main.ind_cond_info.005.value", "@indCondInfo.006.value": "$journal.ord_main.ind_cond_info.006.value", "@indCondInfo.010.value": "$journal.ord_main.ind_cond_info.010.value", "@indCondInfo.011.value": "$journal.ord_main.ind_cond_info.011.value", "@indCondInfo.014.value": "$journal.ord_main.ind_cond_info.014.value", "@indCondInfo.015.value": "$journal.ord_main.ind_cond_info.015.value", "@indCondInfo.017.value": "$journal.ord_main.ind_cond_info.017.value", "@indCondInfo.018.value": "$journal.ord_main.ind_cond_info.018.value", "@indCondInfo.019.value": "$journal.ord_main.ind_cond_info.019.value", "@indCondInfo.020.value": "$journal.ord_main.ind_cond_info.020.value", "@indCondInfo.022.value": "$journal.ord_main.ind_cond_info.022.value", "@indCondInfo.024.value": "$journal.ord_main.ind_cond_info.024.value", "@indCondInfo.025.value": "$journal.ord_main.ind_cond_info.025.value", "@indCondInfo.026.value": "$journal.ord_main.ind_cond_info.026.value", "@indCondInfo.027.value": "$journal.ord_main.ind_cond_info.027.value", "@indCondInfo.028.value": "$journal.ord_main.ind_cond_info.028.value", "@indCondInfo.033.value": "$journal.ord_main.ind_cond_info.033.value", "@indCondInfo.005.valueName1": "$journal.ord_main.ind_cond_info.005.value_name_1", "@indCondInfo.006.valueName1": "$journal.ord_main.ind_cond_info.006.value_name_1", "@indCondInfo.010.valueName1": "$journal.ord_main.ind_cond_info.010.value_name_1", "@indCondInfo.011.valueName1": "$journal.ord_main.ind_cond_info.011.value_name_1", "@indCondInfo.015.valueName1": "$journal.ord_main.ind_cond_info.015.value_name_1", "@indCondInfo.019.valueName1": "$journal.ord_main.ind_cond_info.019.value_name_1", "@indCondInfo.025.valueName1": "$journal.ord_main.ind_cond_info.025.value_name_1"}], "sqlGroup4": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#=#D", "table": "ord_main", "ctl_no": "1", "sqlCode": 8101, "@treatDate": "$journal.ord_main.treat_date", "updateResult": "{@ordNo:''ord_no''}"}, {"crud": "U", "kind": "1", "note": "倫理削除処理", "judge": "$journal.const.crud#=#D", "table": "ord_main", "ctl_no": "2", "sqlCode": 8105, "@upUserId": "$journal.ord_main.ind_schedule_user_info.upd_user_id"}], "sqlGroup5": [{"crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.crud#<>#D", "table": "ord_main_1", "ctl_no": "1", "sqlCode": 8101, "@treatDate": "$journal.ord_main.treat_date", "updateResult": "{@indEquipInfoFlg:'''', @indEquipInfoValue:''ind_equip_info'', @indEquipInfo.cd:'''', @indEquipInfo.name:'''', @indEquipInfo.unit:'''', @indEquipInfo.amount:'''', @indEquipInfo.classCd:'''', @indEquipInfo.className:'''', @indEquipInfo.classType:'''', @indEquipInfo.equipType:''0'', @indEquipInfo.shortName:'''', @indEquipInfo.indUserId:'''', @indEquipInfo.inputClass:''3'', @indEquipInfo.isEditable:''1'', @indEquipInfo.needleType:'''', @indEquipInfo.updUserId:'''', @indEquipInfo.copOrderNo:'''', @indEquipInfo.indUserLastName:'''', @indEquipInfo.updUserLastName:'''', @indEquipInfo.indUserFirstName:'''', @indEquipInfo.updUserFirstName:''''}"}, {"Note": "json場合、[D]の設定が必要です。しかし、消耗品情報をクリアしません。judgeに[crud#=#NG]を設定する。", "crud": "D", "kind": "1", "judge": "$journal.const.crud#=#NG", "table": "ord_main_1", "ctl_no": "2", "sqlCode": 8106}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_1", "ctl_no": "3", "sqlCode": 8107, "@indEquipInfo.cd": "$journal.detail.ord_main_1.ind_equip_info.cd", "@indEquipInfo.name": "$journal.detail.ord_main_1.ind_equip_info.name", "@indEquipInfo.amount": "$journal.detail.ord_main_1.ind_equip_info.amount", "@indEquipInfo.equipType": "0", "@indEquipInfo.inputClass": "3", "@indEquipInfo.isEditable": "1"}], "sqlGroup6": [{"crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.crud#<>#D", "table": "ord_main_2", "ctl_no": "1", "sqlCode": 8101, "@treatDate": "$journal.ord_main.treat_date", "updateResult": "{@indMediInfoFlg:'''', @indMediInfoValue:''ind_medi_info'', @indMediInfo.cd:'''', @indMediInfo.no:'''', @indMediInfo.name:'''', @indMediInfo.unit:'''', @indMediInfo.amount:'''', @indMediInfo.comment:'''', @indMediInfo.classCd:'''', @indMediInfo.initDate:'''', @indMediInfo.timingCd:'''', @indMediInfo.className:'''', @indMediInfo.classType:'''', @indMediInfo.shortName:'''', @indMediInfo.indUserId:'''', @indMediInfo.inputClass:'''', @indMediInfo.isEditable:'''', @indMediInfo.timingName:'''', @indMediInfo.updUserId:'''', @indMediInfo.copOrderNo:'''', @indMediInfo.procedureCd:'''', @indMediInfo.dateInterval:'''', @indMediInfo.medicineType:'''', @indMediInfo.procedureName:'''', @indMediInfo.indUserLastName:'''', @indMediInfo.updUserLastName:'''', @indMediInfo.indUserFirstName:'''', @indMediInfo.updUserFirstName:''''}"}, {"Note": "json場合、[D]の設定が必要です。しかし、処方情報をクリアしません。judgeに[crud#=#NG]を設定する。", "crud": "D", "kind": "1", "judge": "$journal.const.crud#=#NG", "table": "ord_main_2", "ctl_no": "2", "sqlCode": 8108}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "ord_main_2", "ctl_no": "3", "sqlCode": 8109, "@indMediInfo.cd": "$journal.detail.ord_main_2.ind_medi_info.cd", "@indMediInfo.name": "$journal.detail.ord_main_2.ind_medi_info.name", "@indMediInfo.unit": "$journal.detail.ord_main_2.ind_medi_info.unit", "@indMediInfo.amount": "$journal.detail.ord_main_2.ind_medi_info.amount", "@indMediInfo.inputClass": "3", "@indMediInfo.isEditable": "1", "@indMediInfo.procedureCd": "$journal.detail.ord_main_2.ind_medi_info.procedure_cd", "@indMediInfo.medicineType": "1", "@indMediInfo.procedureName": "$journal.detail.ord_main_2.ind_medi_info.procedure_name"}]}}', '1', '1', 4, '2020-05-14 09:30:43.362', '2020-05-14 09:30:49.059');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-5020005, 'S_hosp', 'ord_dial', '', 'R', '登録', 'text', 'SSI_透析オーダ受け連携', 'SSI', '透析オーダ受け連携(拡張)', '1', '<root name="透析オーダ受け連携(拡張 登録)">
    <item name="CRUD" len="0" col="$journal.const.crud" type="string" value="const:C"/>
    <item name="期間開始日" len="8" type="string" note="取込対象外"/>
    <item name="期間終了日" len="8" type="string" note="取込対象外"/>
    <item name="透析日" len="8" col="$journal.ord_main.treat_date" type="string"/>
    <item name="開始時刻" len="4" col="$journal.ord_main.ind_treat_start_time" type="string"/>
    <item name="患者ID" len="12" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
    <item name="患者名" len="20" col="$journal.pat_personal_main.pat_name" type="string" note="取込対象外"/>
    <item name="透析時間" len="4" col="$journal.ord_main.ind_cond_info.001.value" type="string"/>
    <item name="治療方法" len="20" col="$journal.ord_main.ind_treatment_name" type="string"/>
    <item name="ベッド-コード" len="10" col="$journal.ord_main.ind_bed_cd" type="string"/>
    <item name="ベッド-名称" len="20" col="$journal.ord_main.ind_bed_name" type="string" note="取込対象外"/>
    <item name="ダイアライザ-コード" len="10" col="$journal.ord_main.ind_cond_info.005.value" type="string"/>
    <item name="ダイアライザ-名称" len="20" col="$journal.ord_main.ind_cond_info.005.value_name_1" type="string"/>
    <item name="A針-コード" len="10" col="$journal.ord_main.ind_cond_info.010.value" type="string"/>
    <item name="A針-名称" len="40" col="$journal.ord_main.ind_cond_info.010.value_name_1" type="string"/>
    <item name="V針-コード" len="10" col="$journal.ord_main.ind_cond_info.011.value" type="string"/>
    <item name="V針-名称" len="40" col="$journal.ord_main.ind_cond_info.011.value_name_1" type="string"/>
    <item name="透析液-コード" len="10" col="$journal.ord_main.ind_cond_info.015.value" type="string"/>
    <item name="透析液-名称" len="80" col="$journal.ord_main.ind_cond_info.015.value_name_1" type="string"/>
    <item name="透析液-数量" len="7" col="$journal.ord_main.ind_cond_info.017.value" type="string"/>
    <item name="透析液-単位" len="20" col="$journal.ord_main.ind_cond_info.015.unit" type="string"/>
    <item name="抗凝固剤-コード" len="10" col="$journal.ord_main.ind_cond_info.025.value" type="string"/>
    <item name="抗凝固剤-名称" len="80" col="$journal.ord_main.ind_cond_info.025.value_name_1" type="string"/>
    <item name="抗凝固剤-ワンショット量" len="7" col="$journal.ord_main.ind_cond_info.026.value" type="string"/>
    <item name="抗凝固剤-持続注入量" len="7" col="$journal.ord_main.ind_cond_info.027.value" type="string"/>
    <item name="抗凝固剤-持続総量" len="7" col="$journal.ord_main.ind_cond_info.028.value" type="string"/>
    <item name="抗凝固剤-単位" len="20" col="$journal.ord_main.ind_cond_info.025.unit" type="string"/>
    <item name="DW" len="5" col="$journal.pat_unique.physical_info.dw" type="string" note="取込対象外"/>
    <item name="DW更新日" len="8" col="$journal.pat_unique.physical_info.exam_date" type="string" note="取込対象外"/>
    <item name="CTR" len="4" col="$journal.pat_unique.physical_info.ctr" type="string" note="取込対象外"/>
    <item name="CTR更新日" len="8" col="$journal.pat_unique.physical_info.exam_date" type="string" note="取込対象外"/>
    <item name="血流量" len="3" col="$journal.ord_main.ind_cond_info.014.value" type="string"/>
    <item name="IP速度" len="3" col="$journal.ord_main.ind_cond_info.033.value" type="string"/>
    <item name="補液量" len="4" col="$journal.ord_main.ind_cond_info.020.value" type="string"/>
    <item name="除水量制限" len="4" col="$journal.ord_main.ind_cond_info.004.value" type="string"/>
    <item name="除水速度制限" len="4" col="$journal.pat_main.device_set_info.ope.dev.A.181" type="string" note="取込対象外"/>
    <item name="ブラッドアクセスコード" len="10" col="$journal.ord_main.blood_access_info.cd" type="string" note="NTSS関連項目が無し、取込対象外"/>
    <item name="ブラッドアクセス名称" len="40" col="$journal.ord_main.blood_access_info.name" type="string" note="NTSS関連項目が無し、取込対象外"/>
    <item name="ブラッドアクセス部位" len="1" col="$journal.ord_main.blood_access_info.part" type="string" note="NTSS関連項目が無し、取込対象外"/>
    <item name="ブラッドアクセス更新日" len="8" col="$journal.ord_main.blood_access_info.up_date" type="string" note="NTSS関連項目が無し、取込対象外"/>
    <occ name="消耗品情報" len="0" repeat="10" detail="消耗品情報"/>
    <occ name="処方情報" len="0" repeat="20" detail="処方情報"/>
    <occ name="除水補正情報" len="0" repeat="5" detail="除水補正情報" note="取込対象外"/>
    <occ name="風袋情報" len="0" repeat="5" detail="風袋情報" note="取込対象外"/>
    <item name="ダイアライザ２-コード２" len="10" col="$journal.ord_main.ind_equip_info.cd" type="string"/>
    <item name="ダイアライザ２-名称２" len="20" col="$journal.ord_main.ind_equip_info.name" type="string"/>
    <item name="吸着器コード" len="10" col="$journal.ord_main.ind_cond_info.006.value" type="string"/>
    <item name="吸着器名称" len="20" col="$journal.ord_main.ind_cond_info.006.value_name_1" type="string"/>
    <item name="透析液-温度" len="3" col="$journal.ord_main.ind_cond_info.018.value" type="string"/>
    <item name="補液-コード" len="10" col="$journal.ord_main.ind_cond_info.019.value" type="string"/>
    <item name="補液-名称" len="40" col="$journal.ord_main.ind_cond_info.019.value_name_1" type="string"/>
    <item name="補液-使用数" len="5" col="$journal.ord_main.ind_cond_info.022.value" type="string"/>
    <item name="補液-速度" len="4" col="$journal.ord_main.ind_cond_info.024.value" type="string"/>
    <item name="担当医-コード" len="10" col="$journal.ord_main.ind_schedule_user_info.upd_user_id" type="string"/>
    <item name="担当医名" len="20" col="$journal.ord_main.ind_schedule_user_info.upd_user_name" type="string"/>
    <item name="CRLF" len="2" type="string"/>
</root>', '{}', '1', '1', 4, '2020-05-14 09:30:43.362', '2020-05-14 09:30:49.059');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-5020006, 'S_hosp', 'ord_dial', '', 'R', '削除', 'text', 'SSI_透析オーダ受け連携', 'SSI', '透析オーダ受け連携(拡張)', '1', '<root name="透析オーダ受け連携(拡張 削除)">
    <item name="CRUD" len="0" col="$journal.const.crud" type="string" value="const:D"/>
    <item name="期間開始日" len="8" type="string" note="取込対象外"/>
    <item name="期間終了日" len="8" type="string" note="取込対象外"/>
    <item name="透析日" len="8" col="$journal.ord_main.treat_date" type="string"/>
    <item name="開始時刻" len="4" col="$journal.ord_main.ind_treat_start_time" type="string"/>
    <item name="患者ID" len="12" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
    <item name="患者名" len="20" col="$journal.pat_personal_main.pat_name" type="string" note="取込対象外"/>
    <item name="透析時間" len="4" col="$journal.ord_main.ind_cond_info.001.value" type="string"/>
    <item name="治療方法" len="20" col="$journal.ord_main.ind_treatment_name" type="string"/>
    <item name="ベッド-コード" len="10" col="$journal.ord_main.ind_bed_cd" type="string"/>
    <item name="ベッド-名称" len="20" col="$journal.ord_main.ind_bed_name" type="string" note="取込対象外"/>
    <item name="ダイアライザ-コード" len="10" col="$journal.ord_main.ind_cond_info.005.value" type="string"/>
    <item name="ダイアライザ-名称" len="20" col="$journal.ord_main.ind_cond_info.005.value_name_1" type="string"/>
    <item name="A針-コード" len="10" col="$journal.ord_main.ind_cond_info.010.value" type="string"/>
    <item name="A針-名称" len="40" col="$journal.ord_main.ind_cond_info.010.value_name_1" type="string"/>
    <item name="V針-コード" len="10" col="$journal.ord_main.ind_cond_info.011.value" type="string"/>
    <item name="V針-名称" len="40" col="$journal.ord_main.ind_cond_info.011.value_name_1" type="string"/>
    <item name="透析液-コード" len="10" col="$journal.ord_main.ind_cond_info.015.value" type="string"/>
    <item name="透析液-名称" len="80" col="$journal.ord_main.ind_cond_info.015.value_name_1" type="string"/>
    <item name="透析液-数量" len="7" col="$journal.ord_main.ind_cond_info.017.value" type="string"/>
    <item name="透析液-単位" len="20" col="$journal.ord_main.ind_cond_info.015.unit" type="string"/>
    <item name="抗凝固剤-コード" len="10" col="$journal.ord_main.ind_cond_info.025.value" type="string"/>
    <item name="抗凝固剤-名称" len="80" col="$journal.ord_main.ind_cond_info.025.value_name_1" type="string"/>
    <item name="抗凝固剤-ワンショット量" len="7" col="$journal.ord_main.ind_cond_info.026.value" type="string"/>
    <item name="抗凝固剤-持続注入量" len="7" col="$journal.ord_main.ind_cond_info.027.value" type="string"/>
    <item name="抗凝固剤-持続総量" len="7" col="$journal.ord_main.ind_cond_info.028.value" type="string"/>
    <item name="抗凝固剤-単位" len="20" col="$journal.ord_main.ind_cond_info.025.unit" type="string"/>
    <item name="DW" len="5" col="$journal.pat_unique.physical_info.dw" type="string" note="取込対象外"/>
    <item name="DW更新日" len="8" col="$journal.pat_unique.physical_info.exam_date" type="string" note="取込対象外"/>
    <item name="CTR" len="4" col="$journal.pat_unique.physical_info.ctr" type="string" note="取込対象外"/>
    <item name="CTR更新日" len="8" col="$journal.pat_unique.physical_info.exam_date" type="string" note="取込対象外"/>
    <item name="血流量" len="3" col="$journal.ord_main.ind_cond_info.014.value" type="string"/>
    <item name="IP速度" len="3" col="$journal.ord_main.ind_cond_info.033.value" type="string"/>
    <item name="補液量" len="4" col="$journal.ord_main.ind_cond_info.020.value" type="string"/>
    <item name="除水量制限" len="4" col="$journal.ord_main.ind_cond_info.004.value" type="string"/>
    <item name="除水速度制限" len="4" col="$journal.pat_main.device_set_info.ope.dev.A.181" type="string" note="取込対象外"/>
    <item name="ブラッドアクセスコード" len="10" col="$journal.ord_main.blood_access_info.cd" type="string" note="NTSS関連項目が無し、取込対象外"/>
    <item name="ブラッドアクセス名称" len="40" col="$journal.ord_main.blood_access_info.name" type="string" note="NTSS関連項目が無し、取込対象外"/>
    <item name="ブラッドアクセス部位" len="1" col="$journal.ord_main.blood_access_info.part" type="string" note="NTSS関連項目が無し、取込対象外"/>
    <item name="ブラッドアクセス更新日" len="8" col="$journal.ord_main.blood_access_info.up_date" type="string" note="NTSS関連項目が無し、取込対象外"/>
    <occ name="消耗品情報" len="0" repeat="10" detail="消耗品情報"/>
    <occ name="処方情報" len="0" repeat="20" detail="処方情報"/>
    <occ name="除水補正情報" len="0" repeat="5" detail="除水補正情報" note="取込対象外"/>
    <occ name="風袋情報" len="0" repeat="5" detail="風袋情報" note="取込対象外"/>
    <item name="ダイアライザ２-コード２" len="10" col="$journal.ord_main.ind_equip_info.cd" type="string"/>
    <item name="ダイアライザ２-名称２" len="20" col="$journal.ord_main.ind_equip_info.name" type="string"/>
    <item name="吸着器コード" len="10" col="$journal.ord_main.ind_cond_info.006.value" type="string"/>
    <item name="吸着器名称" len="20" col="$journal.ord_main.ind_cond_info.006.value_name_1" type="string"/>
    <item name="透析液-温度" len="3" col="$journal.ord_main.ind_cond_info.018.value" type="string"/>
    <item name="補液-コード" len="10" col="$journal.ord_main.ind_cond_info.019.value" type="string"/>
    <item name="補液-名称" len="40" col="$journal.ord_main.ind_cond_info.019.value_name_1" type="string"/>
    <item name="補液-使用数" len="5" col="$journal.ord_main.ind_cond_info.022.value" type="string"/>
    <item name="補液-速度" len="4" col="$journal.ord_main.ind_cond_info.024.value" type="string"/>
    <item name="担当医-コード" len="10" col="$journal.ord_main.ind_schedule_user_info.upd_user_id" type="string"/>
    <item name="担当医名" len="20" col="$journal.ord_main.ind_schedule_user_info.upd_user_name" type="string"/>
    <item name="CRLF" len="2" type="string"/>
</root>', '{}', '1', '1', 4, '2020-05-14 09:30:43.362', '2020-05-14 09:30:49.059');
