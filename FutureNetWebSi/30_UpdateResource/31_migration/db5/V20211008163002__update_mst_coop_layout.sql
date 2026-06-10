delete from "mst_coop_layout" where "ctl_no" in (-2030001,-6010003,-6020001,-6020002,-6020003,-6050001,-6050002,-6050003);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2030001, 'F_hosp', 'profile', '', 'R', 'pre', 'text     ', '富士通想定患者プロファイル', 'Egmain-GX', 'テスト用', '1', '<root name="患者プロファイル(pre)">
    <item  name="電文種別" len="2" col="電文種別" type="string"/>
    <item  name="レコード継続指示" len="1" col="レコード継続指示" type="string"/>
    <item  name="送信先システムコード" len="2" col="送信先システムコード" type="string"/>
    <item  name="発信元システムコード" len="2" col="発信元システムコード" type="string"/>
    <item  name="処理情報.処理年月日" len="8" col="処理情報.処理年月日" type="string"/>
    <item  name="処理情報.処理時刻" len="6" col="処理情報.処理時刻" type="string"/>
    <item  name="端末名" len="8" col="端末名" type="string"/>
    <item  name="利用者番号" len="8" col="利用者番号" type="string"/>
    <item  name="処理区分" len="2" col="処理区分" type="string"/>
    <item  name="応答種別" len="2" col="応答種別" key="応答種別" type="string"/>
    <item  name="電文長" len="6" col="電文長" type="string"/>
    <item  name="エラーコード" len="5" col="エラーコード" type="string"/>
    <item  name="予備" len="12" col="予備" type="string"/>
    <item  name="患者情報.患者番号" len="10" col="患者情報.患者番号" type="string"/>
    <item  name="患者情報.患者漢字氏名" len="30" col="患者情報.患者漢字氏名" type="string"/>
    <item  name="患者情報.患者カナ氏名" len="60" col="患者情報.患者カナ氏名" type="string"/>
    <item  name="患者情報.患者性別" len="1" col="患者情報.患者性別" type="string"/>
    <item  name="患者情報.患者生年月日" len="8" col="患者情報.患者生年月日" type="string"/>
    <item  name="患者情報.郵便番号１" len="3" col="患者情報.郵便番号１" type="string"/>
    <item  name="患者情報.郵便番号２" len="4" col="患者情報.郵便番号２" type="string"/>
    <item  name="患者情報.患者住所" len="40" col="患者情報.患者住所" type="string"/>
    <item  name="患者情報.患者住所詳細" len="60" col="患者情報.患者住所詳細" type="string"/>
    <item  name="患者情報.電話番号" len="15" col="患者情報.電話番号" type="string"/>
    <item  name="入院情報.入外区分" len="1" col="入院情報.入外区分" type="string"/>
    <item  name="入院情報.入院診療科コード" len="3" col="入院情報.入院診療科コード" type="string"/>
    <item  name="入院情報.入院中病棟" len="3" col="入院情報.入院中病棟" type="string"/>
    <item  name="入院情報.入院中部屋" len="5" col="入院情報.入院中部屋" type="string"/>
    <item  name="入院情報.入院中ベッドコード" len="2" col="入院情報.入院中ベッドコード" type="string"/>
    <occ  name="保険情報" len="0" repeat="30" detail="保険情報詳細"/>
    <occ  name="患者プロファイル" len="2" detail="患者プロファイル詳細"/>
    <item  name="終端" len="1" col="終端" type="string"/>
</root>', '{"key": {"応答種別": {"N1": "正常以外", "N2": "正常以外", "N3": "正常以外", "N4": "正常以外", "NG": "正常以外", "OK": "正常"}}, "dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"crud": "C", "kind": "0", "judge": "$journal.pat_personal_main.hosp_pat_id#=#123", "table": "pat_personal_main", "ctl_no": "2", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": 1102, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "$journal.pat_personal_main.in_out_class", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_last_name", "@patFirstName": "$journal.pat_personal_main.pat_last_name", "@patLastNmKana": "$journal.pat_personal_main.pat_last_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_last_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel": "$journal.pat_personal_main.pat_contact_info.tel", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "3", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": 1103, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "$journal.pat_personal_main.in_out_class", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_last_name", "@patFirstName": "$journal.pat_personal_main.pat_last_name", "@patLastNmKana": "$journal.pat_personal_main.pat_last_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_last_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel": "$journal.pat_personal_main.pat_contact_info.tel", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}], "sqlGroup2": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201, "insertResult": "{@patId:'''',@facilityCd:'''',@isSame:'''',@isImplant:'''',@isInfect:'''',@isDiabetes:'''',@isBloodSugerExam:'''',@inOutCurrentState:'''',@inOutPlanState:'''',@inOutPlanDate_Date:'''',@patMemoInfoValue:''[]'',@additionInfoValue:''[]'',@chargeStaffInfoValue:''[]'',@patGroupInfoValue:''[]'',@tabooAllergyInfoValue:''[]'',@infectInfoValue:''[]'',@implantInfoValue:''[]'',@tareInfoValue:''{}'',@offWaterInfoValue:''{}'',@deviceSetInfoValue:''{}'',@acceptanceStatusInfoValue:''[]'',@isWheelChair:'''',@medicalCareInfoFlg:'''',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:'''',@schExtStatus:'''',@cardIdm:'''',@oldUpDate_Date:''''}", "updateResult": "{@patId:''pat_id'',@facilityCd:''facility_cd'',@isSame:''is_same'',@isImplant:''is_implant'',@isInfect:''is_infect'',@isDiabetes:''is_diabetes'',@isBloodSugerExam:''is_blood_suger_exam'',@inOutCurrentState:''in_out_current_state'',@inOutPlanState:''in_out_plan_state'',@inOutPlanDate_Date:''in_out_plan_date'',@patMemoInfoValue:''pat_memo_info'',@additionInfoValue:''addition_info'',@chargeStaffInfoValue:''charge_staff_info'',@patGroupInfoValue:''pat_group_info'',@tabooAllergyInfoValue:''taboo_allergy_info'',@infectInfoValue:''infect_info'',@implantInfoValue:''implant_info'',@tareInfoValue:''tare_info'',@offWaterInfoValue:''off_water_info'',@deviceSetInfoValue:''device_set_info'',@acceptanceStatusInfoValue:''acceptance_status_info'',@isWheelChair:''is_wheel_chair'',@medicalCareInfoFlg:'''',@medicalCareInfoValue:''medical_care_info'',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:''sch_ext_end_date'',@schExtStatus:''sch_ext_status'',@cardIdm:''card_idm'',@oldUpDate_Date:''old_up_date''}"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "2", "sqlCode": 1202, "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "3", "sqlCode": 1203, "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd"}], "sqlGroup3": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_insurance", "@ctlNo": "$journal.detail.pat_insurance.ctl_no", "ctl_no": "1", "sqlCode": 1301, "insertResult": "{@patId:''0'',@facilityCd:''0'',@ctlNo:'''',@fnPatId:'''',@insuClass:'''',@insuName:'''',@insuNmShort:'''',@insuInfoFlg:'''',@insuInfo.insuNo:'''',@insuInfo.insuPatName:'''',@insuInfo.insuPatNo:'''',@insuInfo.insuKbn:'''',@insuInfo.insuPatMark:'''',@insuInfo.ckiClass:'''',@insuInfo.kkiClass:'''',@insuInfo.undSix:'''',@insuInfo.futan-g:'''',@insuInfo.futan-n:'''',@insuPubInfoFlg:'''',@insuPubInfo.insuPubName:'''',@insuPubInfo.insuPubNo:'''',@insuPubInfo.insuPubPatNo:'''',@insuSetInfoFlg:'''',@insuSetInfo.insuCd:'''',@insuSetInfo.insuPub1Cd:'''',@insuSetInfo.insuPub2Cd:'''',@insuSetInfo.insuPub3Cd:'''',@insuSetInfo.insuPub4Cd:'''',@isSelected:'''',@isDisp:''1'',@coopCode:'''',@isCoop:'''',@startDate:'''',@endDate:'''',@checkDate:'''',@oldUpDate_Date:''''}", "updateResult": "{@patId:''pat_id'',@facilityCd:''facility_cd'',@ctlNo:''ctl_no'',@fnPatId:''fn_pat_id'',@insuClass:''insu_class'',@insuName:''insu_name'',@insuNmShort:''insu_name_short'',@insuInfoFlg:'''',@insuInfoValue:''insu_info'',@insuInfo.insuNo:'''',@insuInfo.insuPatName:'''',@insuInfo.insuPatNo:'''',@insuInfo.insuKbn:'''',@insuInfo.insuPatMark:'''',@insuInfo.ckiClass:'''',@insuInfo.kkiClass:'''',@insuInfo.undSix:'''',@insuInfo.futan-g:'''',@insuInfo.futan-n:'''',@insuPubInfoFlg:'''',@insuPubInfoValue:''insu_pub_info'',@insuPubInfo.insuPubName:'''',@insuPubInfo.insuPubNo:'''',@insuPubInfo.insuPubPatNo:'''',@insuSetInfoFlg:'''',@insuSetInfoValue:''insu_set_info'',@insuSetInfo.insuCd:'''',@insuSetInfo.insuPub1Cd:'''',@insuSetInfo.insuPub2Cd:'''',@insuSetInfo.insuPub3Cd:'''',@insuSetInfo.insuPub4Cd:'''',@isSelected:''is_selected'',@isDisp:''is_disp'',@coopCode:''coop_code'',@isCoop:''is_coop'',@startDate:''start_date'',@endDate:''end_date'',@checkDate:''check_date'',@oldUpDate_Date:''old_up_date''}"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_insurance", "@ctlNo": "$journal.detail.pat_insurance.ctl_no", "ctl_no": "2", "sqlCode": 1302, "@endDate": "$journal.detail.pat_insurance.end_date", "@insuName": "$journal.detail.pat_insurance.insu_name", "@startDate": "$journal.detail.pat_insurance.start_date", "@insuInfo.insuNo": "$journal.detail.pat_insurance.insu_info.insu_no", "@insuInfo.futan-g": "$journal.detail.pat_insurance.insu_info.futan-g", "@insuInfo.futan-n": "$journal.detail.pat_insurance.insu_info.futan-n", "@insuInfo.insuKbn": "$journal.detail.pat_insurance.insu_info.insu_kbn", "@insuPubInfo.insuPubNo": "$journal.detail.pat_insurance.insu_pub_info.insu_pub_no"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_insurance", "@ctlNo": "$journal.detail.pat_insurance.ctl_no", "ctl_no": "3", "sqlCode": 1303, "@endDate": "$journal.detail.pat_insurance.end_date", "@insuName": "$journal.detail.pat_insurance.insu_name", "@startDate": "$journal.detail.pat_insurance.start_date", "@insuInfo.insuNo": "$journal.detail.pat_insurance.insu_info.insu_no", "@insuInfo.futan-g": "$journal.detail.pat_insurance.insu_info.futan-g", "@insuInfo.futan-n": "$journal.detail.pat_insurance.insu_info.futan-n", "@insuInfo.insuKbn": "$journal.detail.pat_insurance.insu_info.insu_kbn", "@insuPubInfo.insuPubNo": "$journal.detail.pat_insurance.insu_pub_info.insu_pub_no"}], "sqlGroup4": [{"crud": "S", "kind": "0", "type": "json", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1401, "updateResult": "{@dialDiffComInfoFlg:'''',@dialDiffComInfoValue:''dial_diff_com_info'',@dialDiffComInfo.ctlNo:'''',@dialDiffComInfo.dialDiffCd:'''',@dialDiffComInfo.isMain:'''',@dialDiffComInfo.isDialDiff:'''',@dialDiffComInfo.regDate:'''',@otherContactInfoFlg:'''',@otherContactInfoValue:''other_contact_info'',@otherContactInfo.ctlNo:'''',@otherContactInfo.dispOrder:'''',@otherContactInfo.isKeyPerson:'''',@otherContactInfo.patId:'''',@otherContactInfo.lastName:'''',@otherContactInfo.firstName:'''',@otherContactInfo.lastNmKana:'''',@otherContactInfo.firstNmKana:'''',@otherContactInfo.relationCd:'''',@otherContactInfo.relationName:'''',@otherContactInfo.zipCd:'''',@otherContactInfo.address:'''',@otherContactInfo.eMail:'''',@otherContactInfo.workName:'''',@otherContactInfo.workTel:'''',@otherContactInfo.tel1:'''',@otherContactInfo.tel2:'''',@otherContactInfo.fax:'''',@otherContactInfo.memo1:'''',@otherContactInfo.memo2:'''',@vendorContactInfoFlg:'''',@vendorContactInfoValue:''vendor_contact_info'',@vendorContactInfo.ctlNo:'''',@vendorContactInfo.dispOrder:'''',@vendorContactInfo.companyName:'''',@vendorContactInfo.zipCd:'''',@vendorContactInfo.address:'''',@vendorContactInfo.companyTel:'''',@vendorContactInfo.fax:'''',@vendorContactInfo.workerLastName:'''',@vendorContactInfo.workerFirstName:'''',@vendorContactInfo.workerTel:'''',@vendorContactInfo.workerEMail:'''',@vendorContactInfo.memo1:'''',@vendorContactInfo.memo2:'''',@insuranceInfoFlg:'''',@insuranceInfoValue:''insurance_info'',@insuranceInfo.insuranceNo:'''',@insuranceInfo.insuranceClass:'''',@insuranceInfo.insuredCd:'''',@insuranceInfo.insuredNo:'''',@insuranceInfo.insuranceRatio:'''',@insuranceInfo.pubInsuNo1:'''',@insuranceInfo.pubInsuNo2:'''',@insuranceInfo.pubInsuRecNo1:'''',@insuranceInfo.pubInsuRecNo2:'''',@insuranceInfo.insuranceMemo1:'''',@insuranceInfo.insuranceMemo2:'''',@insuranceInfo.disabilityNo:''''}"}, {"crud": "D", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "2", "sqlCode": 1402}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "3", "sqlCode": 1403, "@otherContactInfo.tel1": "$journal.detail.pat_personal_main.other_contact_info.tel1", "@otherContactInfo.tel2": "$journal.detail.pat_personal_main.other_contact_info.tel2", "@otherContactInfo.memo1": "$journal.detail.pat_personal_main.other_contact_info.memo1", "@otherContactInfo.lastName": "$journal.detail.pat_personal_main.other_contact_info.last_name", "@otherContactInfo.relationCd": "$journal.detail.pat_personal_main.other_contact_info.relation_cd"}], "sqlGroup5": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1501}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_personal_main", "@isDie": "$journal.detail.pat_personal_main.is_die", "ctl_no": "3", "sqlCode": 1502, "@dieDate_Date": "$journal.detail.pat_personal_main.die_date"}], "sqlGroup6": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_unique", "ctl_no": "1", "sqlCode": 1601, "insertResult": "{@patId:'''', @facilityCd:'''', @medicalHstInfoValue:''[]'', @inOutVisitHistoryInfoValue:''[]'', @physicalInfoFlg:'''', @physicalInfoValue:''[]''}"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_unique", "ctl_no": "2", "sqlCode": 1602}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_unique", "ctl_no": "3", "sqlCode": 1603}], "sqlGroup7": [{"crud": "S", "kind": "0", "type": "json", "judge": "", "table": "pat_unique", "ctl_no": "1", "sqlCode": 1701, "updateResult": "{@nextCtlNo1:''next_ctl_no_1'', @physicalInfoFlg:'''', @physicalInfoValue:''physical_info'', @physicalInfo.ctlNo:'''', @physicalInfo.examDate:'''', @physicalInfo.orderClass:'''', @physicalInfo.height:'''', @physicalInfo.ctrWeight:'''', @physicalInfo.breastDia:'''', @physicalInfo.chestDia:'''', @physicalInfo.ctr:'''', @physicalInfo.dw:'''', @physicalInfo.indicatorCd:'''', @physicalInfo.indicatorStartDate:'''', @physicalInfo.memo:'''', @physicalInfo.preScaleUpper:'''', @physicalInfo.preScaleLower:'''', @physicalInfo.targetWeight:'''', @physicalInfo.facilityCd:''''}"}, {"crud": "D", "kind": "0", "judge": "", "table": "pat_unique", "ctl_no": "2", "sqlCode": 1702}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_unique", "ctl_no": "3", "sqlCode": 1703, "@physicalInfo.height": "$journal.detail.pat_unique.physical_info.height", "@physicalInfo.examDate": "$journal.detail.pat_unique.physical_info.exam_date", "@physicalInfo.facilityCd": "$journal.detail.pat_unique.physical_info.facility_cd"}], "sqlGroup8": [{"crud": "S", "kind": "0", "type": "json", "judge": "", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201, "updateResult": "{@nextCtlNo3:''next_ctl_no_3'', @tabooAllergyInfoFlg:'''', @tabooAllergyInfoValue:''taboo_allergy_info'', @tabooAllergyInfo.memo:'''', @tabooAllergyInfo.ctlNo:'''', @tabooAllergyInfo.content:'''', @tabooAllergyInfo.dispOrder:'''', @tabooAllergyInfo.categoryClass:'''', @tabooAllergyInfo.tabooAllergyCd:'''', @tabooAllergyInfo.tabooAllergyClass:''''}"}, {"crud": "D", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "2", "sqlCode": 1801}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "3", "sqlCode": 1802, "@tabooAllergyInfo.memo": "$journal.pat_main.taboo_allergy_info.memo", "@tabooAllergyInfo.taboo_allergy_cd": "$journal.pat_main.taboo_allergy_info.taboo_allergy_cd"}]}}', '1', '0', -1, '2019-12-23 06:35:38', '2020-01-14 11:01:43.398');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6010003, 'C_hosp', 'profile', '', 'R', 'all', 'xml', 'CSI患者プロファイル', 'MIRAIs', 'テスト用', '1', '<rootNode>
    <CRUD>col:$journal.const.crud,json:{&quot;1&quot;:&quot;&quot;,&quot;2&quot;:&quot;&quot;,&quot;3&quot;:&quot;&quot;}</CRUD>
    <PAT_BASIC_INFO>
        <DISP_PATID>col:$journal.pat_personal_main.hosp_pat_id</DISP_PATID>
        <!-- 患者番号 -->
        <NAME>col:$journal.pat_personal_main.pat_last_name</NAME>
        <!-- 患者氏名 -->
        <NAME_KANA>col:$journal.pat_personal_main.pat_last_name_kana</NAME_KANA>
        <!-- 患者カナ氏名 -->
        <BIRTHDAY>col:$journal.pat_personal_main.pat_birthday</BIRTHDAY>
        <!-- 生年月日 -->
        <SEX_CD>col:$journal.pat_personal_main.pat_sex</SEX_CD>
        <!-- 性別 -->
        <BLOOD_TYPE_ABO>col:$journal.pat_personal_main.pat_blood_type_abo</BLOOD_TYPE_ABO>
        <!-- ABO式コード -->
        <BLOOD_TYPE_RH>col:$journal.pat_personal_main.pat_blood_type_rh</BLOOD_TYPE_RH>
        <!-- RH式コード -->
        <INOUT_FLG>col:$journal.pat_personal_main.in_out_class</INOUT_FLG>
        <!-- 入外区分 -->
        <COURSE_CD>col:$journal.pat_main.medical_care_info.main_course_cd</COURSE_CD>
        <!-- 診療科コード -->
        <WARD_CD>col:$journal.pat_main.medical_care_info.ward_cd</WARD_CD>
        <!-- 病棟コード -->
        <DIE_DATE>col:$journal.pat_personal_main.die_date</DIE_DATE>
        <!-- 死亡日 -->
        <DIE_FLG>col:$journal.pat_personal_main.is_die</DIE_FLG>
        <!-- 死亡フラグ -->
    </PAT_BASIC_INFO>
    <PAT_CONTACT detail="患者連絡先情報,ID"></PAT_CONTACT>
    <PAT_INFECT detail="患者感染症情報,ID"></PAT_INFECT>
</rootNode>', '{"key": {"患者感染症情報": {"_DEFAULT": "all"}, "患者連絡先情報": {"1": "本人", "2": "勤務先", "3": "その他", "_DEFAULT": "その他"}}, "dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_personal_main", "@isDie": "$journal.pat_personal_main.is_die", "ctl_no": "2", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": 1102, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "$journal.pat_personal_main.in_out_class", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_last_name", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_last_name", "@patLastNmKana": "$journal.pat_personal_main.pat_last_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_last_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_personal_main", "@isDie": "$journal.pat_personal_main.is_die", "ctl_no": "3", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": 1103, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "$journal.pat_personal_main.in_out_class", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_last_name", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_last_name", "@patLastNmKana": "$journal.pat_personal_main.pat_last_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_last_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}], "sqlGroup2": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201, "insertResult": "{@patId:'''',@facilityCd:'''',@isSame:'''',@isImplant:'''',@isInfect:'''',@isDiabetes:'''',@isBloodSugerExam:'''',@inOutCurrentState:'''',@inOutPlanState:'''',@inOutPlanDate_Date:'''',@patMemoInfoValue:''[]'',@additionInfoValue:''[]'',@chargeStaffInfoValue:''[]'',@patGroupInfoValue:''[]'',@tabooAllergyInfoValue:''[]'',@infectInfoValue:''[]'',@implantInfoValue:''[]'',@tareInfoValue:''{}'',@offWaterInfoValue:''{}'',@deviceSetInfoValue:''{}'',@acceptanceStatusInfoValue:''[]'',@isWheelChair:'''',@medicalCareInfoFlg:'''',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:'''',@schExtStatus:'''',@cardIdm:'''',@oldUpDate_Date:''''}", "updateResult": "{@patId:''pat_id'',@facilityCd:''facility_cd'',@isSame:''is_same'',@isImplant:''is_implant'',@isInfect:''is_infect'',@isDiabetes:''is_diabetes'',@isBloodSugerExam:''is_blood_suger_exam'',@inOutCurrentState:''in_out_current_state'',@inOutPlanState:''in_out_plan_state'',@inOutPlanDate_Date:''in_out_plan_date'',@patMemoInfoValue:''pat_memo_info'',@additionInfoValue:''addition_info'',@chargeStaffInfoValue:''charge_staff_info'',@patGroupInfoValue:''pat_group_info'',@tabooAllergyInfoValue:''taboo_allergy_info'',@infectInfoValue:''infect_info'',@implantInfoValue:''implant_info'',@tareInfoValue:''tare_info'',@offWaterInfoValue:''off_water_info'',@deviceSetInfoValue:''device_set_info'',@acceptanceStatusInfoValue:''acceptance_status_info'',@isWheelChair:''is_wheel_chair'',@medicalCareInfoFlg:'''',@medicalCareInfoValue:''medical_care_info'',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:''sch_ext_end_date'',@schExtStatus:''sch_ext_status'',@cardIdm:''card_idm'',@oldUpDate_Date:''old_up_date''}"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "2", "sqlCode": 1202, "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "3", "sqlCode": 1203, "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd"}], "sqlGroup3": [{"crud": "S", "kind": "0", "type": "json", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1401, "updateResult": "{@otherContactInfoFlg:'''', @otherContactInfoValue:''other_contact_info'', @otherContactInfo.ctlNo:'''', @otherContactInfo.dispOrder:'''', @otherContactInfo.isKeyPerson:'''', @otherContactInfo.patId:'''', @otherContactInfo.lastName:'''', @otherContactInfo.firstName:'''', @otherContactInfo.lastNmKana:'''', @otherContactInfo.firstNmKana:'''', @otherContactInfo.relationCd:'''', @otherContactInfo.relationName:'''', @otherContactInfo.zipCd:'''', @otherContactInfo.address:'''', @otherContactInfo.eMail:'''', @otherContactInfo.workName:'''', @otherContactInfo.workTel:'''', @otherContactInfo.tel1:'''', @otherContactInfo.tel2:'''', @otherContactInfo.fax:'''', @otherContactInfo.memo1:'''', @otherContactInfo.memo2:'''', @vendorContactInfoFlg:'''', @vendorContactInfoValue:''vendor_contact_info'', @vendorContactInfo.ctlNo:'''', @vendorContactInfo.dispOrder:'''', @vendorContactInfo.companyName:'''', @vendorContactInfo.zipCd:'''', @vendorContactInfo.address:'''', @vendorContactInfo.companyTel:'''', @vendorContactInfo.fax:'''', @vendorContactInfo.workerLastName:'''', @vendorContactInfo.workerFirstName:'''', @vendorContactInfo.workerTel:'''', @vendorContactInfo.workerEMail:'''', @vendorContactInfo.memo1:'''', @vendorContactInfo.memo2:''''}"}, {"crud": "D", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "2", "sqlCode": 4101}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "3", "sqlCode": 4102, "@otherContactInfo.tel1": "$journal.detail.pat_personal_main.other_contact_info.tel1", "@otherContactInfo.ctlNo": "$journal.detail.pat_personal_main.other_contact_info.ctl_no", "@otherContactInfo.zipCd": "$journal.detail.pat_personal_main.other_contact_info.zip_cd", "@otherContactInfo.address": "$journal.detail.pat_personal_main.other_contact_info.address", "@otherContactInfo.lastName": "$journal.detail.pat_personal_main.other_contact_info.name", "@otherContactInfo.dispOrder": "$journal.detail.pat_personal_main.other_contact_info.disp_order", "@otherContactInfo.relationCd": "$journal.detail.pat_personal_main.other_contact_info.relation_cd"}], "sqlGroup4": [{"crud": "S", "kind": "0", "type": "json", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1401, "updateResult": "{@otherContactInfoFlg:'''', @otherContactInfoValue:''other_contact_info'', @otherContactInfo.ctlNo:'''', @otherContactInfo.dispOrder:'''', @otherContactInfo.isKeyPerson:'''', @otherContactInfo.patId:'''', @otherContactInfo.lastName:'''', @otherContactInfo.firstName:'''', @otherContactInfo.lastNmKana:'''', @otherContactInfo.firstNmKana:'''', @otherContactInfo.relationCd:'''', @otherContactInfo.relationName:'''', @otherContactInfo.zipCd:'''', @otherContactInfo.address:'''', @otherContactInfo.eMail:'''', @otherContactInfo.workName:'''', @otherContactInfo.workTel:'''', @otherContactInfo.tel1:'''', @otherContactInfo.tel2:'''', @otherContactInfo.fax:'''', @otherContactInfo.memo1:'''', @otherContactInfo.memo2:'''', @vendorContactInfoFlg:'''', @vendorContactInfoValue:''vendor_contact_info'', @vendorContactInfo.ctlNo:'''', @vendorContactInfo.dispOrder:'''', @vendorContactInfo.companyName:'''', @vendorContactInfo.zipCd:'''', @vendorContactInfo.address:'''', @vendorContactInfo.companyTel:'''', @vendorContactInfo.fax:'''', @vendorContactInfo.workerLastName:'''', @vendorContactInfo.workerFirstName:'''', @vendorContactInfo.workerTel:'''', @vendorContactInfo.workerEMail:'''', @vendorContactInfo.memo1:'''', @vendorContactInfo.memo2:''''}"}, {"crud": "D", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "2", "sqlCode": 4103}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "3", "sqlCode": 4104, "@vendorContactInfo.ctlNo": "$journal.detail.pat_personal_main.vendor_contact_info.ctl_no", "@vendorContactInfo.zipCd": "$journal.detail.pat_personal_main.vendor_contact_info.zip_cd", "@vendorContactInfo.address": "$journal.detail.pat_personal_main.vendor_contact_info.address", "@vendorContactInfo.dispOrder": "$journal.detail.pat_personal_main.vendor_contact_info.disp_order", "@vendorContactInfo.workerTel": "$journal.detail.pat_personal_main.vendor_contact_info.worker_tel", "@vendorContactInfo.workerLastName": "$journal.detail.pat_personal_main.vendor_contact_info.name"}], "sqlGroup5": [{"crud": "S", "kind": "0", "type": "json", "judge": "", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201, "updateResult": "{@nextCtlNo4:''next_ctl_no_4'', @infectInfoFlg:'''', @infectInfoValue:''infect_info'', @infectInfo.ctlNo:'''', @infectInfo.infectionCd:'''', @infectInfo.infect:'''', @infectInfo.examDate:'''', @infectInfo.upDate:''''}"}, {"crud": "D", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "2", "sqlCode": 4201}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "3", "sqlCode": 4202, "@infectInfo.infect": "$journal.detail.pat_main.infect_info.infect", "@infectInfo.infectionCd": "$journal.detail.pat_main.infect_info.infection_cd"}]}, "json-key": {"{\"1\":\"\",\"2\":\"\",\"3\":\"\"}": {"1": "C", "2": "U", "3": "D"}}}', '1', '0', -1, '2021-09-01 07:38:44.069', '2021-09-01 07:38:44.069');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6020001, 'C_hosp', 'ind_dial', '', 'S', 'cre', 'xml', 'CSI透析予約', 'MIRAIs', '透析予約', '1', '<coop_info>
    <!-- 電文種別 -->
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <!-- 電文種別 -->
    <coop_cd>ind_dial</coop_cd>
    <!-- 作成更新区分 -->
    <crud>1</crud>
    <!-- 向き（送受信） -->
    <direction>S</direction>
    <!-- （連携先)オーダ番号 -->
    <coop_ord_no>$JOURNAL.coop_ord_no</coop_ord_no>
    <!-- 患者番号（連携用） -->
    <hosp_pat_id>dataset:-200001.hosp_pat_id</hosp_pat_id>
    <!-- 電文内容 -->
    <dump>
        <rootNode>
            <!-- 患者情報 -->
            <PAT_BASIC_INFO>
                <!-- 表示用患者ID -->
                <DISP_PATID>dataset:-200001.hosp_pat_id</DISP_PATID>
                <!-- 患者ID -->
                <PATID>$JOURNAL.pat_id</PATID>
                <!-- 患者名 -->
                <NAME>dataset:-200001.pat_name</NAME>
                <!-- 医師1 -->
                <DOCTOR_CD1>dataset:-436.staff_cd1</DOCTOR_CD1>
                <!-- 医師2 -->
                <DOCTOR_CD2>dataset:-436.staff_cd2</DOCTOR_CD2>
                <MST_PAT_GROUP>
                    <!-- 科コード -->
                    <IN_HOSPITAL_CD>dataset:-436.course_cd1</IN_HOSPITAL_CD>
                </MST_PAT_GROUP>
            </PAT_BASIC_INFO>
            <!-- 透析スケジュール -->
            <SCH_DIALYSIS_PLAN>
                <!-- ベッド番号 -->
                <BED_NO>dataset:-436.bed_cd1</BED_NO>
                <!-- クールコード -->
                <KUR_CD>dataset:-436.kur_cd1</KUR_CD>
                <!-- 透析日 -->
                <DIALYSIS_DATE>dataset:-436.treat_date</DIALYSIS_DATE>
                <!-- クールマスタ -->
                <MST_KUR>
                    <!-- クール内標準開始時間 -->
                    <STANDARD_START_TIME>dataset:-436.kur_standard_start_time</STANDARD_START_TIME>
                </MST_KUR>
                <!-- ベッドマスタ -->
                <MST_BED>
                    <!-- ベッド名 -->
                    <BED_NAME>dataset:-436.bed_name</BED_NAME>
                </MST_BED>
            </SCH_DIALYSIS_PLAN>
            <IND_DIALYSIS_COND DIALYSIS_ITEM_CD="dataset:-437.item_cd" NAME="dataset:-437.item_name" VALUE="dataset:-437.item_value" _sqlCode="-437">
            <!-- 条件指示 詳細：項目番号, 項目名, 設定値-->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-437.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値 -->
                <MST_STAFF STAFF_CD="dataset:-437.ind_user_id">
                    <!-- 職種コード -->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-437.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-437.up_date</UP_DATE>
                <!-- 装置:モード -->
                <MST_TREAT_ITEM DEVICE_MODE="dataset:-437.add_item"/>
            </IND_DIALYSIS_COND>
            <IND_DIALYSIS_PLAN CTL_NO="$COUNT" _sqlCode="-438">
            <!-- 予約指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-438.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-438.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-438.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-438.up_date</UP_DATE>
            </IND_DIALYSIS_PLAN>
            <IND_DIALYSIS_MEDI CTL_NO="$COUNT" _sqlCode="-439">
            <!-- 投薬指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-439.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-439.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-439.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-439.up_date</UP_DATE>
            </IND_DIALYSIS_MEDI>
            <IND_DIALYSIS_EQUIP CTL_NO="$COUNT" _sqlCode="-440">
            <!-- 材料指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-440.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-440.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-440.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-440.up_date</UP_DATE>
            </IND_DIALYSIS_EQUIP>
            <IND_DIALYSIS_ADD CTL_NO="$COUNT" _sqlCode="-441">
            <!-- 指示簿指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-441.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-441.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-441.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-441.up_date</UP_DATE>
            </IND_DIALYSIS_ADD>
            <SYS_COOP_EXEC_DATA>
                <A00001>
                    <SYS_STAFF_AUTH>
                        <ACL>1</ACL>
                    </SYS_STAFF_AUTH>
                </A00001>
                <A00002>
                    <MST_BED>
                        <BED_NO>1</BED_NO>
                    </MST_BED>
                </A00002>
                <A10001></A10001>
                <A10002>
                    <USER_TABLES>
                        <TABLE_NAME>COOP_LAYOUT</TABLE_NAME>
                    </USER_TABLES>
                </A10002>
            </SYS_COOP_EXEC_DATA>
        </rootNode>
    </dump>
</coop_info>
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -436}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -437}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -438}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -439}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -440}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -441}], "dumpFileName": {"patId": "patId", "sqlCode": -102}}', '1', '0', -1, '2021-09-06 11:38:27', '2021-09-06 11:38:31');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6020002, 'C_hosp', 'ind_dial', '', 'S', 'upd', 'xml', 'CSI透析予約', 'MIRAIs', '透析予約', '1', '<coop_info>
    <!-- 電文種別 -->
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <!-- 電文種別 -->
    <coop_cd>ind_dial</coop_cd>
    <!-- 作成更新区分 -->
    <crud>2</crud>
    <!-- 向き（送受信） -->
    <direction>S</direction>
    <!-- （連携先)オーダ番号 -->
    <coop_ord_no>$JOURNAL.coop_ord_no</coop_ord_no>
    <!-- 患者番号（連携用） -->
    <hosp_pat_id>dataset:-200001.hosp_pat_id</hosp_pat_id>
    <!-- 電文内容 -->
    <dump>
        <rootNode>
            <!-- 患者情報 -->
            <PAT_BASIC_INFO>
                <!-- 表示用患者ID -->
                <DISP_PATID>dataset:-200001.hosp_pat_id</DISP_PATID>
                <!-- 患者ID -->
                <PATID>$JOURNAL.pat_id</PATID>
                <!-- 患者名 -->
                <NAME>dataset:-200001.pat_name</NAME>
                <!-- 医師1 -->
                <DOCTOR_CD1>dataset:-436.staff_cd1</DOCTOR_CD1>
                <!-- 医師2 -->
                <DOCTOR_CD2>dataset:-436.staff_cd2</DOCTOR_CD2>
                <MST_PAT_GROUP>
                    <!-- 科コード -->
                    <IN_HOSPITAL_CD>dataset:-436.course_cd1</IN_HOSPITAL_CD>
                </MST_PAT_GROUP>
            </PAT_BASIC_INFO>
            <!-- 透析スケジュール -->
            <SCH_DIALYSIS_PLAN>
                <!-- ベッド番号 -->
                <BED_NO>dataset:-436.bed_cd1</BED_NO>
                <!-- クールコード -->
                <KUR_CD>dataset:-436.kur_cd1</KUR_CD>
                <!-- 透析日 -->
                <DIALYSIS_DATE>dataset:-436.treat_date</DIALYSIS_DATE>
                <!-- クールマスタ -->
                <MST_KUR>
                    <!-- クール内標準開始時間 -->
                    <STANDARD_START_TIME>dataset:-436.kur_standard_start_time</STANDARD_START_TIME>
                </MST_KUR>
                <!-- ベッドマスタ -->
                <MST_BED>
                    <!-- ベッド名 -->
                    <BED_NAME>dataset:-436.bed_name</BED_NAME>
                </MST_BED>
            </SCH_DIALYSIS_PLAN>
            <IND_DIALYSIS_COND DIALYSIS_ITEM_CD="dataset:-437.item_cd" NAME="dataset:-437.item_name" VALUE="dataset:-437.item_value" _sqlCode="-437">
            <!-- 条件指示 詳細：項目番号, 項目名, 設定値-->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-437.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値 -->
                <MST_STAFF STAFF_CD="dataset:-437.ind_user_id">
                    <!-- 職種コード -->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-437.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-437.up_date</UP_DATE>
                <!-- 装置:モード -->
                <MST_TREAT_ITEM DEVICE_MODE="dataset:-437.add_item"/>
            </IND_DIALYSIS_COND>
            <IND_DIALYSIS_PLAN CTL_NO="$COUNT" _sqlCode="-438">
            <!-- 予約指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-438.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-438.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-438.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-438.up_date</UP_DATE>
            </IND_DIALYSIS_PLAN>
            <IND_DIALYSIS_MEDI CTL_NO="$COUNT" _sqlCode="-439">
            <!-- 投薬指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-439.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-439.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-439.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-439.up_date</UP_DATE>
            </IND_DIALYSIS_MEDI>
            <IND_DIALYSIS_EQUIP CTL_NO="$COUNT" _sqlCode="-440">
            <!-- 材料指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-440.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-440.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-440.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-440.up_date</UP_DATE>
            </IND_DIALYSIS_EQUIP>
            <IND_DIALYSIS_ADD CTL_NO="$COUNT" _sqlCode="-441">
            <!-- 指示簿指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-441.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-441.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-441.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-441.up_date</UP_DATE>
            </IND_DIALYSIS_ADD>
            <SYS_COOP_EXEC_DATA>
                <A00001>
                    <SYS_STAFF_AUTH>
                        <ACL>1</ACL>
                    </SYS_STAFF_AUTH>
                </A00001>
                <A00002>
                    <MST_BED>
                        <BED_NO>1</BED_NO>
                    </MST_BED>
                </A00002>
                <A10001></A10001>
                <A10002>
                    <USER_TABLES>
                        <TABLE_NAME>COOP_LAYOUT</TABLE_NAME>
                    </USER_TABLES>
                </A10002>
            </SYS_COOP_EXEC_DATA>
        </rootNode>
    </dump>
</coop_info>
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -436}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -437}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -438}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -439}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -440}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -441}], "dumpFileName": {"patId": "patId", "sqlCode": -102}}', '1', '0', -1, '2021-09-06 11:38:27', '2021-09-06 11:38:31');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6020003, 'C_hosp', 'ind_dial', '', 'S', 'del', 'xml', 'CSI透析予約', 'MIRAIs', '透析予約', '1', '<coop_info>
    <!-- 電文種別 -->
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <!-- 電文種別 -->
    <coop_cd>ind_dial</coop_cd>
    <!-- 作成更新区分 -->
    <crud>3</crud>
    <!-- 向き（送受信） -->
    <direction>S</direction>
    <!-- （連携先)オーダ番号 -->
    <coop_ord_no>$JOURNAL.coop_ord_no</coop_ord_no>
    <!-- 患者番号（連携用） -->
    <hosp_pat_id>dataset:-200001.hosp_pat_id</hosp_pat_id>
    <!-- 電文内容 -->
    <dump>
        <rootNode>
            <!-- 患者情報 -->
            <PAT_BASIC_INFO>
                <!-- 表示用患者ID -->
                <DISP_PATID>dataset:-200001.hosp_pat_id</DISP_PATID>
                <!-- 患者ID -->
                <PATID>$JOURNAL.pat_id</PATID>
                <!-- 患者名 -->
                <NAME>dataset:-200001.pat_name</NAME>
                <!-- 医師1 -->
                <DOCTOR_CD1>dataset:-436.staff_cd1</DOCTOR_CD1>
                <!-- 医師2 -->
                <DOCTOR_CD2>dataset:-436.staff_cd2</DOCTOR_CD2>
                <MST_PAT_GROUP>
                    <!-- 科コード -->
                    <IN_HOSPITAL_CD>dataset:-436.course_cd1</IN_HOSPITAL_CD>
                </MST_PAT_GROUP>
            </PAT_BASIC_INFO>
            <!-- 透析スケジュール -->
            <SCH_DIALYSIS_PLAN>
                <!-- ベッド番号 -->
                <BED_NO>dataset:-436.bed_cd1</BED_NO>
                <!-- クールコード -->
                <KUR_CD>dataset:-436.kur_cd1</KUR_CD>
                <!-- 透析日 -->
                <DIALYSIS_DATE>dataset:-436.treat_date</DIALYSIS_DATE>
                <!-- クールマスタ -->
                <MST_KUR>
                    <!-- クール内標準開始時間 -->
                    <STANDARD_START_TIME>dataset:-436.kur_standard_start_time</STANDARD_START_TIME>
                </MST_KUR>
                <!-- ベッドマスタ -->
                <MST_BED>
                    <!-- ベッド名 -->
                    <BED_NAME>dataset:-436.bed_name</BED_NAME>
                </MST_BED>
            </SCH_DIALYSIS_PLAN>
            <IND_DIALYSIS_COND DIALYSIS_ITEM_CD="dataset:-437.item_cd" NAME="dataset:-437.item_name" VALUE="dataset:-437.item_value" _sqlCode="-437">
            <!-- 条件指示 詳細：項目番号, 項目名, 設定値-->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-437.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値 -->
                <MST_STAFF STAFF_CD="dataset:-437.ind_user_id">
                    <!-- 職種コード -->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-437.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-437.up_date</UP_DATE>
                <!-- 装置:モード -->
                <MST_TREAT_ITEM DEVICE_MODE="dataset:-437.add_item"/>
            </IND_DIALYSIS_COND>
            <IND_DIALYSIS_PLAN CTL_NO="$COUNT" _sqlCode="-438">
            <!-- 予約指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-438.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-438.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-438.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-438.up_date</UP_DATE>
            </IND_DIALYSIS_PLAN>
            <IND_DIALYSIS_MEDI CTL_NO="$COUNT" _sqlCode="-439">
            <!-- 投薬指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-439.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-439.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-439.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-439.up_date</UP_DATE>
            </IND_DIALYSIS_MEDI>
            <IND_DIALYSIS_EQUIP CTL_NO="$COUNT" _sqlCode="-440">
            <!-- 材料指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-440.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-440.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-440.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-440.up_date</UP_DATE>
            </IND_DIALYSIS_EQUIP>
            <IND_DIALYSIS_ADD CTL_NO="$COUNT" _sqlCode="-441">
            <!-- 指示簿指示 詳細:番号 -->
                <!-- 指示者 -->
                <INDICATOR_CD>dataset:-441.ind_user_id</INDICATOR_CD>
                <!-- スタッフマスタ：指示者の値-->
                <MST_STAFF STAFF_CD="dataset:-441.ind_user_id">
                    <!-- 職種コード-->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 更新者 -->
                <UPDATE_STAFF_CD>dataset:-441.upd_user_id</UPDATE_STAFF_CD>
                <!-- 更新時間 -->
                <UP_DATE>dataset:-441.up_date</UP_DATE>
            </IND_DIALYSIS_ADD>
            <SYS_COOP_EXEC_DATA>
                <A00001>
                    <SYS_STAFF_AUTH>
                        <ACL>1</ACL>
                    </SYS_STAFF_AUTH>
                </A00001>
                <A00002>
                    <MST_BED>
                        <BED_NO>1</BED_NO>
                    </MST_BED>
                </A00002>
                <A10001></A10001>
                <A10002>
                    <USER_TABLES>
                        <TABLE_NAME>COOP_LAYOUT</TABLE_NAME>
                    </USER_TABLES>
                </A10002>
            </SYS_COOP_EXEC_DATA>
        </rootNode>
    </dump>
</coop_info>
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -436}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -437}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -438}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -439}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -440}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -441}], "dumpFileName": {"patId": "patId", "sqlCode": -102}}', '1', '0', -1, '2021-09-06 11:38:27', '2021-09-06 11:38:31');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6050001, 'C_hosp', 'exam_ord', '', 'S', 'cre', 'xml', 'CSI検査オーダ', 'MIRAIs', '検査オーダ', '1', '<coop_info>
    <!-- 電文種別 -->
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <!-- 電文種別 -->
    <coop_cd>exam_ord</coop_cd>
    <!-- 作成更新区分 -->
    <crud>1</crud>
    <!-- 向き（送受信） -->
    <direction>S</direction>
    <!-- （連携先)オーダ番号 -->
    <coop_ord_no>$JOURNAL.coop_ord_no</coop_ord_no>
    <!-- 患者番号（連携用） -->
    <hosp_pat_id>dataset:-200001.hosp_pat_id</hosp_pat_id>
    <!-- 電文内容 -->
    <dump>
        <rootNode>
            <!-- 患者情報 -->
            <PAT_BASIC_INFO>
                <!-- 表示用患者ID -->
                <DISP_PATID>dataset:-200001.hosp_pat_id</DISP_PATID>
                <!-- 患者ID -->
                <PATID>$JOURNAL.pat_id</PATID>
                <!-- 患者名 -->
                <NAME>dataset:-200001.pat_name</NAME>
                <!-- 医師1 -->
                <DOCTOR_CD1>dataset:-442.staff_cd1</DOCTOR_CD1>
                <!-- 医師2 -->
                <DOCTOR_CD2>dataset:-442.staff_cd2</DOCTOR_CD2>
                <MST_PAT_GROUP>
                    <!-- 科コード -->
                    <IN_HOSPITAL_CD>dataset:-442.course_cd1</IN_HOSPITAL_CD>
                </MST_PAT_GROUP>
            </PAT_BASIC_INFO>
            <!-- 検査スケジュール -->
            <PAT_EXAMIN_SCHEDULE>
                <!-- 指示者 -->
                <DOCTOR_CODE>dataset:-442.ind_user_id</DOCTOR_CODE>
                <!-- スタッフマスタ：指示者の値 -->
                <MST_STAFF STAFF_CD="dataset:-442.ind_user_id">
                    <!-- 職種コード -->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 検査区分 -->
                <EXAM_DIVISION>dataset:-442.reg_order_class</EXAM_DIVISION>
                <!-- オーダ日時 -->
                <UP_DATE>dataset:-442.up_date</UP_DATE>
                <!-- オーダ入力者 -->
                <ORDER_STAFF>dataset:-442.reg_staff</ORDER_STAFF>
                <!-- 更新者 -->
                <UPDATE_CODE>dataset:-442.up_staff</UPDATE_CODE>
                <!-- 検査予定日 -->
                <EXAM_DATE>dataset:-442.reg_exam_date</EXAM_DATE>
                <!-- 検査セット -->
                <MST_EXAM_SET>
                    <MST_EXAM_SET_DETAIL>
                        <MST_EXAM_ITEM>
                            <!-- 検査項目 -->
                            <IN_HOSPITAL_CD2 _sqlCode="-443" NAME="dataset:-443.item_name">dataset:-443.in_hospital_cd1</IN_HOSPITAL_CD2>
                        </MST_EXAM_ITEM>
                    </MST_EXAM_SET_DETAIL>
                    <!-- その他開始時刻 -->
                    <OTHER_EXAM_TIME>dataset:-442.other_exam_time</OTHER_EXAM_TIME>
                </MST_EXAM_SET>
            </PAT_EXAMIN_SCHEDULE>
            <!-- 透析後/透析後 -->
            <SCH_DIALYSIS_PLAN>
                <MST_KUR>
                    <!-- クール標準開始時間 -->
                    <STANDARD_START_TIME>dataset:-442.standard_start_time</STANDARD_START_TIME>
                </MST_KUR>
                <BED_NO>???</BED_NO>
            </SCH_DIALYSIS_PLAN>
            <!-- 透析後:CTL_NO="002" -->
            <IND_DIALYSIS_COND CTL_NO="002">
                <!-- 予定透析時間 -->
                <VALUE>dataset:-442.ind_dialysis_time</VALUE>
            </IND_DIALYSIS_COND>
            <RST_DIALYSIS_HST>
                <!-- 透析番号 -->
                <DIALYSIS_NO>???</DIALYSIS_NO>
                <!-- 版番 -->
                <EDITION>???</EDITION>
            </RST_DIALYSIS_HST>
            <!-- 血液検査送信 BLOOD_EXAM_SEND_INFO-->
            <血液検査送信>
                <!--検査日 -->
                <EXAM_DATE>dataset:-442.reg_exam_date</EXAM_DATE>
                <!-- 検査区分 -->
                <EXAM_DIVISION>dataset:-442.reg_order_class</EXAM_DIVISION>
                <!-- 検査セットコード -->
                <EXAM_SET_CD>dataset:-442.exam_set_cd</EXAM_SET_CD>
            </血液検査送信>
            <SYS_COOP_EXEC_DATA>
                <A00001>
                    <PAT_EXAMIN_SCHEDULE>
                        <UPDATE_CODE>100</UPDATE_CODE>
                    </PAT_EXAMIN_SCHEDULE>
                </A00001>
                <A00002>
                    <PAT_EXAMIN_SCHEDULE>
                        <UPDATE_CODE>200</UPDATE_CODE>
                    </PAT_EXAMIN_SCHEDULE>
                </A00002>
                <A00003>
                    <SYS_STAFF_AUTH>
                        <ACL>1000</ACL>
                    </SYS_STAFF_AUTH>
                </A00003>
                <A00004>
                    <MST_BED>
                        <BED_NO>PAT_GROUP_FLG</BED_NO>
                    </MST_BED>
                </A00004>
                <A10002>
                    <USER_TABLES>
                        <TABLE_NAME>IF_EVENT_LOG</TABLE_NAME>
                    </USER_TABLES>
                </A10002>
            </SYS_COOP_EXEC_DATA>
        </rootNode>
    </dump>
</coop_info>', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -442}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -443}]}', '1', '0', -1, '2021-09-06 11:38:27', '2021-09-06 11:38:31');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6050002, 'C_hosp', 'exam_ord', '', 'S', 'upd', 'xml', 'CSI検査オーダ', 'MIRAIs', '検査オーダ', '1', '<coop_info>
    <!-- 電文種別 -->
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <!-- 電文種別 -->
    <coop_cd>exam_ord</coop_cd>
    <!-- 作成更新区分 -->
    <crud>2</crud>
    <!-- 向き（送受信） -->
    <direction>S</direction>
    <!-- （連携先)オーダ番号 -->
    <coop_ord_no>$JOURNAL.coop_ord_no</coop_ord_no>
    <!-- 患者番号（連携用） -->
    <hosp_pat_id>dataset:-200001.hosp_pat_id</hosp_pat_id>
    <!-- 電文内容 -->
    <dump>
        <rootNode>
            <!-- 患者情報 -->
            <PAT_BASIC_INFO>
                <!-- 表示用患者ID -->
                <DISP_PATID>dataset:-200001.hosp_pat_id</DISP_PATID>
                <!-- 患者ID -->
                <PATID>$JOURNAL.pat_id</PATID>
                <!-- 患者名 -->
                <NAME>dataset:-200001.pat_name</NAME>
                <!-- 医師1 -->
                <DOCTOR_CD1>dataset:-442.staff_cd1</DOCTOR_CD1>
                <!-- 医師2 -->
                <DOCTOR_CD2>dataset:-442.staff_cd2</DOCTOR_CD2>
                <MST_PAT_GROUP>
                    <!-- 科コード -->
                    <IN_HOSPITAL_CD>dataset:-442.course_cd1</IN_HOSPITAL_CD>
                </MST_PAT_GROUP>
            </PAT_BASIC_INFO>
            <!-- 検査スケジュール -->
            <PAT_EXAMIN_SCHEDULE>
                <!-- 指示者 -->
                <DOCTOR_CODE>dataset:-442.ind_user_id</DOCTOR_CODE>
                <!-- スタッフマスタ：指示者の値 -->
                <MST_STAFF STAFF_CD="dataset:-442.ind_user_id">
                    <!-- 職種コード -->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 検査区分 -->
                <EXAM_DIVISION>dataset:-442.reg_order_class</EXAM_DIVISION>
                <!-- オーダ日時 -->
                <UP_DATE>dataset:-442.up_date</UP_DATE>
                <!-- オーダ入力者 -->
                <ORDER_STAFF>dataset:-442.reg_staff</ORDER_STAFF>
                <!-- 更新者 -->
                <UPDATE_CODE>dataset:-442.up_staff</UPDATE_CODE>
                <!-- 検査予定日 -->
                <EXAM_DATE>dataset:-442.reg_exam_date</EXAM_DATE>
                <!-- 検査セット -->
                <MST_EXAM_SET>
                    <MST_EXAM_SET_DETAIL>
                        <MST_EXAM_ITEM>
                            <!-- 検査項目 -->
                            <IN_HOSPITAL_CD2 _sqlCode="-443" NAME="dataset:-443.item_name">dataset:-443.in_hospital_cd1</IN_HOSPITAL_CD2>
                        </MST_EXAM_ITEM>
                    </MST_EXAM_SET_DETAIL>
                    <!-- その他開始時刻 -->
                    <OTHER_EXAM_TIME>dataset:-442.other_exam_time</OTHER_EXAM_TIME>
                </MST_EXAM_SET>
            </PAT_EXAMIN_SCHEDULE>
            <!-- 透析後/透析後 -->
            <SCH_DIALYSIS_PLAN>
                <MST_KUR>
                    <!-- クール標準開始時間 -->
                    <STANDARD_START_TIME>dataset:-442.standard_start_time</STANDARD_START_TIME>
                </MST_KUR>
                <BED_NO>???</BED_NO>
            </SCH_DIALYSIS_PLAN>
            <!-- 透析後:CTL_NO="002" -->
            <IND_DIALYSIS_COND CTL_NO="002">
                <!-- 予定透析時間 -->
                <VALUE>dataset:-442.ind_dialysis_time</VALUE>
            </IND_DIALYSIS_COND>
            <RST_DIALYSIS_HST>
                <!-- 透析番号 -->
                <DIALYSIS_NO>???</DIALYSIS_NO>
                <!-- 版番 -->
                <EDITION>???</EDITION>
            </RST_DIALYSIS_HST>
            <!-- 血液検査送信 BLOOD_EXAM_SEND_INFO-->
            <血液検査送信>
                <!--検査日 -->
                <EXAM_DATE>dataset:-442.reg_exam_date</EXAM_DATE>
                <!-- 検査区分 -->
                <EXAM_DIVISION>dataset:-442.reg_order_class</EXAM_DIVISION>
                <!-- 検査セットコード -->
                <EXAM_SET_CD>dataset:-442.exam_set_cd</EXAM_SET_CD>
            </血液検査送信>
            <SYS_COOP_EXEC_DATA>
                <A00001>
                    <PAT_EXAMIN_SCHEDULE>
                        <UPDATE_CODE>100</UPDATE_CODE>
                    </PAT_EXAMIN_SCHEDULE>
                </A00001>
                <A00002>
                    <PAT_EXAMIN_SCHEDULE>
                        <UPDATE_CODE>200</UPDATE_CODE>
                    </PAT_EXAMIN_SCHEDULE>
                </A00002>
                <A00003>
                    <SYS_STAFF_AUTH>
                        <ACL>1000</ACL>
                    </SYS_STAFF_AUTH>
                </A00003>
                <A00004>
                    <MST_BED>
                        <BED_NO>PAT_GROUP_FLG</BED_NO>
                    </MST_BED>
                </A00004>
                <A10002>
                    <USER_TABLES>
                        <TABLE_NAME>IF_EVENT_LOG</TABLE_NAME>
                    </USER_TABLES>
                </A10002>
            </SYS_COOP_EXEC_DATA>
        </rootNode>
    </dump>
</coop_info>', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -442}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -443}]}', '1', '0', -1, '2021-09-06 11:38:27', '2021-09-06 11:38:31');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-6050003, 'C_hosp', 'exam_ord', '', 'S', 'del', 'xml', 'CSI検査オーダ', 'MIRAIs', '検査オーダ', '1', '<coop_info>
    <!-- 電文種別 -->
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <!-- 電文種別 -->
    <coop_cd>exam_ord</coop_cd>
    <!-- 作成更新区分 -->
    <crud>3</crud>
    <!-- 向き（送受信） -->
    <direction>S</direction>
    <!-- （連携先)オーダ番号 -->
    <coop_ord_no>$JOURNAL.coop_ord_no</coop_ord_no>
    <!-- 患者番号（連携用） -->
    <hosp_pat_id>dataset:-200001.hosp_pat_id</hosp_pat_id>
    <!-- 電文内容 -->
    <dump>
        <rootNode>
            <!-- 患者情報 -->
            <PAT_BASIC_INFO>
                <!-- 表示用患者ID -->
                <DISP_PATID>dataset:-200001.hosp_pat_id</DISP_PATID>
                <!-- 患者ID -->
                <PATID>$JOURNAL.pat_id</PATID>
                <!-- 患者名 -->
                <NAME>dataset:-200001.pat_name</NAME>
                <!-- 医師1 -->
                <DOCTOR_CD1>dataset:-442.staff_cd1</DOCTOR_CD1>
                <!-- 医師2 -->
                <DOCTOR_CD2>dataset:-442.staff_cd2</DOCTOR_CD2>
                <MST_PAT_GROUP>
                    <!-- 科コード -->
                    <IN_HOSPITAL_CD>dataset:-442.course_cd1</IN_HOSPITAL_CD>
                </MST_PAT_GROUP>
            </PAT_BASIC_INFO>
            <!-- 検査スケジュール -->
            <PAT_EXAMIN_SCHEDULE>
                <!-- 指示者 -->
                <DOCTOR_CODE>dataset:-442.ind_user_id</DOCTOR_CODE>
                <!-- スタッフマスタ：指示者の値 -->
                <MST_STAFF STAFF_CD="dataset:-442.ind_user_id">
                    <!-- 職種コード -->
                    <JOB_CLASS_CD></JOB_CLASS_CD>
                </MST_STAFF>
                <!-- 検査区分 -->
                <EXAM_DIVISION>dataset:-442.reg_order_class</EXAM_DIVISION>
                <!-- オーダ日時 -->
                <UP_DATE>dataset:-442.up_date</UP_DATE>
                <!-- オーダ入力者 -->
                <ORDER_STAFF>dataset:-442.reg_staff</ORDER_STAFF>
                <!-- 更新者 -->
                <UPDATE_CODE>dataset:-442.up_staff</UPDATE_CODE>
                <!-- 検査予定日 -->
                <EXAM_DATE>dataset:-442.reg_exam_date</EXAM_DATE>
                <!-- 検査セット -->
                <MST_EXAM_SET>
                    <MST_EXAM_SET_DETAIL>
                        <MST_EXAM_ITEM>
                            <!-- 検査項目 -->
                            <IN_HOSPITAL_CD2 _sqlCode="-443" NAME="dataset:-443.item_name">dataset:-443.in_hospital_cd1</IN_HOSPITAL_CD2>
                        </MST_EXAM_ITEM>
                    </MST_EXAM_SET_DETAIL>
                    <!-- その他開始時刻 -->
                    <OTHER_EXAM_TIME>dataset:-442.other_exam_time</OTHER_EXAM_TIME>
                </MST_EXAM_SET>
            </PAT_EXAMIN_SCHEDULE>
            <!-- 透析後/透析後 -->
            <SCH_DIALYSIS_PLAN>
                <MST_KUR>
                    <!-- クール標準開始時間 -->
                    <STANDARD_START_TIME>dataset:-442.standard_start_time</STANDARD_START_TIME>
                </MST_KUR>
                <BED_NO>???</BED_NO>
            </SCH_DIALYSIS_PLAN>
            <!-- 透析後:CTL_NO="002" -->
            <IND_DIALYSIS_COND CTL_NO="002">
                <!-- 予定透析時間 -->
                <VALUE>dataset:-442.ind_dialysis_time</VALUE>
            </IND_DIALYSIS_COND>
            <RST_DIALYSIS_HST>
                <!-- 透析番号 -->
                <DIALYSIS_NO>???</DIALYSIS_NO>
                <!-- 版番 -->
                <EDITION>???</EDITION>
            </RST_DIALYSIS_HST>
            <!-- 血液検査送信 BLOOD_EXAM_SEND_INFO-->
            <血液検査送信>
                <!--検査日 -->
                <EXAM_DATE>dataset:-442.reg_exam_date</EXAM_DATE>
                <!-- 検査区分 -->
                <EXAM_DIVISION>dataset:-442.reg_order_class</EXAM_DIVISION>
                <!-- 検査セットコード -->
                <EXAM_SET_CD>dataset:-442.exam_set_cd</EXAM_SET_CD>
            </血液検査送信>
            <SYS_COOP_EXEC_DATA>
                <A00001>
                    <PAT_EXAMIN_SCHEDULE>
                        <UPDATE_CODE>100</UPDATE_CODE>
                    </PAT_EXAMIN_SCHEDULE>
                </A00001>
                <A00002>
                    <PAT_EXAMIN_SCHEDULE>
                        <UPDATE_CODE>200</UPDATE_CODE>
                    </PAT_EXAMIN_SCHEDULE>
                </A00002>
                <A00003>
                    <SYS_STAFF_AUTH>
                        <ACL>1000</ACL>
                    </SYS_STAFF_AUTH>
                </A00003>
                <A00004>
                    <MST_BED>
                        <BED_NO>PAT_GROUP_FLG</BED_NO>
                    </MST_BED>
                </A00004>
                <A10002>
                    <USER_TABLES>
                        <TABLE_NAME>IF_EVENT_LOG</TABLE_NAME>
                    </USER_TABLES>
                </A10002>
            </SYS_COOP_EXEC_DATA>
        </rootNode>
    </dump>
</coop_info>', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -442}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -443}]}', '1', '0', -1, '2021-09-06 11:38:27', '2021-09-06 11:38:31');
