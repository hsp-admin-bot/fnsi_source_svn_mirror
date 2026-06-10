delete from "mst_coop_layout" where "ctl_no" = -2090001 or "ctl_no" = -2090002 or "ctl_no" = -2030002 or "ctl_no" = -2030001;
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
</root>', '{"key": {"応答種別": {"N1": "正常以外", "N2": "正常以外", "N3": "正常以外", "N4": "正常以外", "NG": "正常以外", "OK": "正常"}}, "dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"crud": "C", "kind": "0", "judge": "$journal.pat_personal_main.hosp_pat_id#=#123", "table": "pat_personal_main", "ctl_no": "2", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": 1102, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "$journal.pat_personal_main.in_out_class", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_last_name", "@patLastNmKana": "$journal.pat_personal_main.pat_last_name_kana", "@patContactInfo.tel": "$journal.pat_personal_main.pat_contact_info.tel", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "3", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": 1103, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "$journal.pat_personal_main.in_out_class", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_last_name", "@patLastNmKana": "$journal.pat_personal_main.pat_last_name_kana", "@patContactInfo.tel": "$journal.pat_personal_main.pat_contact_info.tel", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}], "sqlGroup2": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201, "insertResult": "{@patId:'''',@facilityCd:'''',@isSame:'''',@isImplant:'''',@isInfect:'''',@isDiabetes:'''',@isBloodSugerExam:'''',@inOutCurrentState:'''',@inOutPlanState:'''',@inOutPlanDate_Date:'''',@patMemoInfoValue:''[]'',@additionInfoValue:''[]'',@chargeStaffInfoValue:''[]'',@patGroupInfoValue:''[]'',@tabooAllergyInfoValue:''[]'',@infectInfoValue:''[]'',@implantInfoValue:''[]'',@tareInfoValue:''[]'',@offWaterInfoValue:''[]'',@deviceSetInfoValue:''[]'',@acceptanceStatusInfoValue:''[]'',@isWheelChair:'''',@medicalCareInfoFlg:'''',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:'''',@schExtStatus:'''',@cardIdm:'''',@oldUpDate_Date:''''}", "updateResult": "{@patId:''pat_id'',@facilityCd:''facility_cd'',@isSame:''is_same'',@isImplant:''is_implant'',@isInfect:''is_infect'',@isDiabetes:''is_diabetes'',@isBloodSugerExam:''is_blood_suger_exam'',@inOutCurrentState:''in_out_current_state'',@inOutPlanState:''in_out_plan_state'',@inOutPlanDate_Date:''in_out_plan_date'',@patMemoInfoValue:''pat_memo_info'',@additionInfoValue:''addition_info'',@chargeStaffInfoValue:''charge_staff_info'',@patGroupInfoValue:''pat_group_info'',@tabooAllergyInfoValue:''taboo_allergy_info'',@infectInfoValue:''infect_info'',@implantInfoValue:''implant_info'',@tareInfoValue:''tare_info'',@offWaterInfoValue:''off_water_info'',@deviceSetInfoValue:''device_set_info'',@acceptanceStatusInfoValue:''acceptance_status_info'',@isWheelChair:''is_wheel_chair'',@medicalCareInfoFlg:'''',@medicalCareInfoValue:''medical_care_info'',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:''sch_ext_end_date'',@schExtStatus:''sch_ext_status'',@cardIdm:''card_idm'',@oldUpDate_Date:''old_up_date''}"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "2", "sqlCode": 1202, "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "3", "sqlCode": 1203, "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd"}], "sqlGroup3": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_insurance", "@ctlNo": "$journal.detail.pat_insurance.ctl_no", "ctl_no": "1", "sqlCode": 1301, "insertResult": "{@patId:''0'',@facilityCd:''0'',@ctlNo:'''',@fnPatId:'''',@insuClass:'''',@insuName:'''',@insuNmShort:'''',@insuInfoFlg:'''',@insuInfo.insuNo:'''',@insuInfo.insuPatName:'''',@insuInfo.insuPatNo:'''',@insuInfo.insuKbn:'''',@insuInfo.insuPatMark:'''',@insuInfo.ckiClass:'''',@insuInfo.kkiClass:'''',@insuInfo.undSix:'''',@insuInfo.futan-g:'''',@insuInfo.futan-n:'''',@insuPubInfoFlg:'''',@insuPubInfo.insuPubName:'''',@insuPubInfo.insuPubNo:'''',@insuPubInfo.insuPubPatNo:'''',@insuSetInfoFlg:'''',@insuSetInfo.insuCd:'''',@insuSetInfo.insuPub1Cd:'''',@insuSetInfo.insuPub2Cd:'''',@insuSetInfo.insuPub3Cd:'''',@insuSetInfo.insuPub4Cd:'''',@isSelected:'''',@isDisp:''1'',@coopCode:'''',@isCoop:'''',@startDate:'''',@endDate:'''',@checkDate:'''',@oldUpDate_Date:''''}", "updateResult": "{@patId:''pat_id'',@facilityCd:''facility_cd'',@ctlNo:''ctl_no'',@fnPatId:''fn_pat_id'',@insuClass:''insu_class'',@insuName:''insu_name'',@insuNmShort:''insu_name_short'',@insuInfoFlg:'''',@insuInfoValue:''insu_info'',@insuInfo.insuNo:'''',@insuInfo.insuPatName:'''',@insuInfo.insuPatNo:'''',@insuInfo.insuKbn:'''',@insuInfo.insuPatMark:'''',@insuInfo.ckiClass:'''',@insuInfo.kkiClass:'''',@insuInfo.undSix:'''',@insuInfo.futan-g:'''',@insuInfo.futan-n:'''',@insuPubInfoFlg:'''',@insuPubInfoValue:''insu_pub_info'',@insuPubInfo.insuPubName:'''',@insuPubInfo.insuPubNo:'''',@insuPubInfo.insuPubPatNo:'''',@insuSetInfoFlg:'''',@insuSetInfoValue:''insu_set_info'',@insuSetInfo.insuCd:'''',@insuSetInfo.insuPub1Cd:'''',@insuSetInfo.insuPub2Cd:'''',@insuSetInfo.insuPub3Cd:'''',@insuSetInfo.insuPub4Cd:'''',@isSelected:''is_selected'',@isDisp:''is_disp'',@coopCode:''coop_code'',@isCoop:''is_coop'',@startDate:''start_date'',@endDate:''end_date'',@checkDate:''check_date'',@oldUpDate_Date:''old_up_date''}"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_insurance", "@ctlNo": "$journal.detail.pat_insurance.ctl_no", "ctl_no": "2", "sqlCode": 1302, "@endDate": "$journal.detail.pat_insurance.end_date", "@insuName": "$journal.detail.pat_insurance.insu_name", "@startDate": "$journal.detail.pat_insurance.start_date", "@insuInfo.insuNo": "$journal.detail.pat_insurance.insu_info.insu_no", "@insuInfo.futan-g": "$journal.detail.pat_insurance.insu_info.futan-g", "@insuInfo.futan-n": "$journal.detail.pat_insurance.insu_info.futan-n", "@insuInfo.insuKbn": "$journal.detail.pat_insurance.insu_info.insu_kbn", "@insuPubInfo.insuPubNo": "$journal.detail.pat_insurance.insu_pub_info.insu_pub_no"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_insurance", "@ctlNo": "$journal.detail.pat_insurance.ctl_no", "ctl_no": "3", "sqlCode": 1303, "@endDate": "$journal.detail.pat_insurance.end_date", "@insuName": "$journal.detail.pat_insurance.insu_name", "@startDate": "$journal.detail.pat_insurance.start_date", "@insuInfo.insuNo": "$journal.detail.pat_insurance.insu_info.insu_no", "@insuInfo.futan-g": "$journal.detail.pat_insurance.insu_info.futan-g", "@insuInfo.futan-n": "$journal.detail.pat_insurance.insu_info.futan-n", "@insuInfo.insuKbn": "$journal.detail.pat_insurance.insu_info.insu_kbn", "@insuPubInfo.insuPubNo": "$journal.detail.pat_insurance.insu_pub_info.insu_pub_no"}], "sqlGroup4": [{"crud": "S", "kind": "0", "type": "json", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1401, "updateResult": "{@dialDiffComInfoFlg:'''',@dialDiffComInfoValue:''dial_diff_com_info'',@dialDiffComInfo.ctlNo:'''',@dialDiffComInfo.dialDiffCd:'''',@dialDiffComInfo.isMain:'''',@dialDiffComInfo.isDialDiff:'''',@dialDiffComInfo.regDate:'''',@otherContactInfoFlg:'''',@otherContactInfoValue:''other_contact_info'',@otherContactInfo.ctlNo:'''',@otherContactInfo.dispOrder:'''',@otherContactInfo.isKeyPerson:'''',@otherContactInfo.patId:'''',@otherContactInfo.lastName:'''',@otherContactInfo.firstName:'''',@otherContactInfo.lastNmKana:'''',@otherContactInfo.firstNmKana:'''',@otherContactInfo.relationCd:'''',@otherContactInfo.relationName:'''',@otherContactInfo.zipCd:'''',@otherContactInfo.address:'''',@otherContactInfo.eMail:'''',@otherContactInfo.workName:'''',@otherContactInfo.workTel:'''',@otherContactInfo.tel1:'''',@otherContactInfo.tel2:'''',@otherContactInfo.fax:'''',@otherContactInfo.memo1:'''',@otherContactInfo.memo2:'''',@vendorContactInfoFlg:'''',@vendorContactInfoValue:''vendor_contact_info'',@vendorContactInfo.ctlNo:'''',@vendorContactInfo.dispOrder:'''',@vendorContactInfo.companyName:'''',@vendorContactInfo.zipCd:'''',@vendorContactInfo.address:'''',@vendorContactInfo.companyTel:'''',@vendorContactInfo.fax:'''',@vendorContactInfo.workerLastName:'''',@vendorContactInfo.workerFirstName:'''',@vendorContactInfo.workerTel:'''',@vendorContactInfo.workerEMail:'''',@vendorContactInfo.memo1:'''',@vendorContactInfo.memo2:'''',@insuranceInfoFlg:'''',@insuranceInfoValue:''insurance_info'',@insuranceInfo.insuranceNo:'''',@insuranceInfo.insuranceClass:'''',@insuranceInfo.insuredCd:'''',@insuranceInfo.insuredNo:'''',@insuranceInfo.insuranceRatio:'''',@insuranceInfo.pubInsuNo1:'''',@insuranceInfo.pubInsuNo2:'''',@insuranceInfo.pubInsuRecNo1:'''',@insuranceInfo.pubInsuRecNo2:'''',@insuranceInfo.insuranceMemo1:'''',@insuranceInfo.insuranceMemo2:'''',@insuranceInfo.disabilityNo:''''}"}, {"crud": "D", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "2", "sqlCode": 1402}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "3", "sqlCode": 1403, "@otherContactInfo.tel1": "$journal.detail.pat_personal_main.other_contact_info.tel1", "@otherContactInfo.tel2": "$journal.detail.pat_personal_main.other_contact_info.tel2", "@otherContactInfo.memo1": "$journal.detail.pat_personal_main.other_contact_info.memo1", "@otherContactInfo.lastName": "$journal.detail.pat_personal_main.other_contact_info.last_name", "@otherContactInfo.relationCd": "$journal.detail.pat_personal_main.other_contact_info.relation_cd"}], "sqlGroup5": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1501}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_personal_main", "@isDie": "$journal.detail.pat_personal_main.is_die", "ctl_no": "3", "sqlCode": 1502, "@dieDate_Date": "$journal.detail.pat_personal_main.die_date"}], "sqlGroup6": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_unique", "ctl_no": "1", "sqlCode": 1601, "insertResult": "{@patId:'''', @facilityCd:'''', @medicalHstInfoValue:''[]'', @inOutVisitHistoryInfoValue:''[]'', @physicalInfoFlg:'''', @physicalInfoValue:''[]''}"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_unique", "ctl_no": "2", "sqlCode": 1602}], "sqlGroup7": [{"crud": "S", "kind": "0", "type": "json", "judge": "", "table": "pat_unique", "ctl_no": "1", "sqlCode": 1701, "updateResult": "{@physicalInfoFlg:'''', @physicalInfoValue:''physical_info'', @physicalInfo.ctlNo:'''', @physicalInfo.examDate:'''', @physicalInfo.orderClass:'''', @physicalInfo.height:'''', @physicalInfo.ctrWeight:'''', @physicalInfo.breastDia:'''', @physicalInfo.chestDia:'''', @physicalInfo.ctr:'''', @physicalInfo.dw:'''', @physicalInfo.indicatorCd:'''', @physicalInfo.indicatorStartDate:'''', @physicalInfo.memo:'''', @physicalInfo.preScaleUpper:'''', @physicalInfo.preScaleLower:'''', @physicalInfo.targetWeight:'''', @physicalInfo.facilityCd:''''}"}, {"crud": "D", "kind": "0", "judge": "", "table": "pat_unique", "ctl_no": "2", "sqlCode": 1702}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_unique", "ctl_no": "3", "sqlCode": 1703, "@physicalInfo.height": "$journal.detail.pat_unique.physical_info.height", "@physicalInfo.examDate": "$journal.detail.pat_unique.physical_info.exam_date", "@physicalInfo.facilityCd": "$journal.detail.pat_unique.physical_info.facility_cd"}]}}', '1', '0', -1, '2019-12-23 06:35:38', '2020-01-14 11:01:43.398');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2030002, 'F_hosp', 'profile', '', 'R', '正常', 'text     ', '富士通想定患者プロファイル', 'Egmain-GX', 'テスト用', '1', '<root name="患者プロファイル(正常)">
    <item  name="電文種別" len="2" type="string"/>
    <item  name="レコード継続指示" len="1" type="string"/>
    <item  name="送信先システムコード" len="2" type="string"/>
    <item  name="発信元システムコード" len="2" type="string"/>
    <item  name="処理情報.処理年月日" len="8" type="string"/>
    <item  name="処理情報.処理時刻" len="6" type="string"/>
    <item  name="端末名" len="8" type="string"/>
    <item  name="利用者番号" len="8" type="string"/>
    <item  name="処理区分" len="2" col="$journal.const.crud" type="string" value="json:{&quot;01&quot;:&quot;&quot;,&quot;02&quot;:&quot;&quot;,&quot;03&quot;:&quot;1&quot;}"/>
    <item  name="応答種別" len="2" type="string"/>
    <item  name="電文長" len="6" type="string"/>
    <item  name="エラーコード" len="5" type="string"/>
    <item  name="予備" len="12" type="string"/>
    <item  name="患者情報.患者番号" len="10" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
    <item  name="患者情報.患者漢字氏名" len="30" col="$journal.pat_personal_main.pat_last_name" type="string"/>
    <item  name="患者情報.患者カナ氏名" len="60" col="$journal.pat_personal_main.pat_last_name_kana" type="string"/>
    <item  name="患者情報.患者性別" len="1" col="$journal.pat_personal_main.pat_sex" type="string"/>
    <item  name="患者情報.患者生年月日" len="8" col="$journal.pat_personal_main.pat_birthday" type="string"/>
    <item  name="患者情報.郵便番号" len="7" col="$journal.pat_personal_main.pat_contact_info.zip_cd" type="string"/>
    <item  name="患者情報.患者住所" len="100" col="$journal.pat_personal_main.pat_contact_info.address" type="string"/>
    <item  name="患者情報.電話番号" len="15" col="$journal.pat_personal_main.pat_contact_info.tel" type="string"/>
    <item  name="入院情報.入外区分" len="1" col="$journal.pat_personal_main.in_out_class" type="string"/>
    <item  name="入院情報.入院診療科コード" len="3" col="$journal.pat_main.medical_care_info.main_course_cd" type="string"/>
    <item  name="入院情報.入院中病棟" len="3" col="$journal.pat_main.medical_care_info.ward_cd" type="string"/>
    <item  name="入院情報.入院中部屋" len="5" type="string"/>
    <item  name="入院情報.入院中ベッドコード" len="2" type="string"/>
    <occ  name="保険情報" len="0" repeat="30" detail="保険情報詳細"/>
    <occ  name="患者プロファイル" len="2" detail="患者プロファイル詳細"/>
    <item  name="終端" len="1" type="string"/>
</root>', '{"json-key": {"{\"01\":\"\",\"02\":\"\",\"03\":\"1\"}": {"01": "C", "02": "U", "03": "D"}}}', '1', '0', -1, '2019-12-23 06:35:38', '2020-01-14 11:01:43.398');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2090001, 'F_hosp', 'exam_rst', '', 'R', 'pre', 'text     ', '富士通想定透析初回申し込み', 'Egmain-GX', 'テスト用', '1', '<root name="検査結果(pre)">
    <item  name="電文種別" len="2" type="string"/>
    <item  name="レコード継続指示" len="1" type="string"/>
    <item  name="送信先システムコード" len="2" type="string"/>
    <item  name="発信元システムコード" len="2" type="string"/>
    <item  name="処理情報.処理年月日" len="8" type="string"/>
    <item  name="処理情報.処理時刻" len="6" type="string"/>
    <item  name="端末名" len="8" type="string"/>
    <item  name="利用者番号" len="8" type="string"/>
    <item  name="処理区分" len="2" type="string"/>
    <item  name="応答種別" len="2" type="string"/>
    <item  name="電文長" len="6" type="string"/>
    <item  name="エラーコード" len="5" type="string"/>
    <item  name="予備" len="12" type="string"/>
    <item  name="検査状態" len="2" type="string"/>
    <item  name="伝票情報.レポート種別" len="4" key="レポート種別" type="string"/>
    <item  name="伝票情報.文書番号" len="30" type="string"/>
    <item  name="版数" len="2" type="string"/>
    <item  name="枝番" len="4" type="string"/>
    <item  name="オーダ番号" len="8" type="string"/>
    <item  name="依頼日" len="8" type="string"/>
    <item  name="患者番号" len="10" type="string"/>
    <item  name="科コード" len="3" type="string"/>
    <item  name="入外区分" len="1" type="string"/>
    <item  name="病棟コード" len="3" type="string"/>
    <item  name="採取日_採取時間" len="14" type="string"/>
    <item  name="依頼コメントコード" len="20" type="string"/>
    <item  name="ドクタコード" len="8" type="string"/>
    <item  name="フリーコメント" len="50" type="string"/>
    <item  name="フリーコメント" len="50" type="string"/>
    <item  name="画像フラグ" len="1" type="string"/>
    <item  name="生体情報.身長" len="5" type="string"/>
    <item  name="生体情報.体重" len="5" type="string"/>
    <item  name="生体情報.畜尿量" len="5" type="string"/>
    <item  name="負荷情報.負荷物コード" len="2" type="string"/>
    <item  name="負荷情報.負荷量" len="4" type="string"/>
    <item  name="負荷情報.負荷時間" len="4" type="string"/>
    <item  name="負荷情報.負荷物コード" len="2" type="string"/>
    <item  name="負荷情報.負荷量" len="4" type="string"/>
    <item  name="負荷情報.負荷時間" len="4" type="string"/>
    <item  name="負荷情報.負荷物コード" len="2" type="string"/>
    <item  name="負荷情報.負荷量" len="4" type="string"/>
    <item  name="負荷情報.負荷時間" len="4" type="string"/>
    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>
    <item  name="投与薬剤情報.投与日" len="8" type="string"/>
    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>
    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>
    <item  name="投与薬剤情報.投与日" len="8" type="string"/>
    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>
    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>
    <item  name="投与薬剤情報.投与日" len="8" type="string"/>
    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>
    <occ  name="検体情報" len="0" repeat="50" detail="検体情報詳細"/>
    <occ  name="結果情報" len="0" repeat="300" detail="結果情報詳細"/>
    <item  name="終端" len="1" type="string"/>
</root>', '{"key": {"レポート種別": {"ER01": "検体検査", "ER02": "一般細菌", "ER03": "抗酸菌", "ER04": "その他細菌"}}, "dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}], "sqlGroup2": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#=#D", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 2101, "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1", "updateResult": "{@examMainCd:''exam_main_cd'', @patId:''pat_id'', @facilityCd:''facility_cd'', @ordNo:''ord_no'', @fnPatId:''fn_pat_id'', @regExamDate:''reg_exam_date'', @regOrderClass:''reg_order_class'', @examStatus:''exam_status'', @orderComment:''order_comment'', @orderExamSetInfoValue:''order_exam_set_info'', @examOrderInfoValue:''exam_order_info'', @orderLabelInfoValue:''order_label_info'', @dataGenClass:''data_gen_class'', @resultExamDate:''result_exam_date'', @resultComment:''result_comment'', @examResultInfoValue:''exam_result_info'', @copOrderNo1:''cop_order_no1'', @copOrderNo2:''cop_order_no2'', @isLock:''is_lock'', @indUserId:''ind_user_id'', @isDel:''is_del'', @regDate:''reg_date'', @regStaff:''reg_staff'', @upDate:''up_date'', @upStaff:''up_staff'', @isOrder:''is_order'', @examWeek:''exam_week'', @examFrom:''exam_from'', @examTo:''exam_to'', @examPattern:''exam_pattern'', }"}, {"crud": "U", "kind": "1", "note": "倫理削除処理", "judge": "$journal.const.crud#=#D", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": 2104, "@indUserId": "$journal.pat_exam_main.ind_user_id", "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1"}], "sqlGroup3": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 2101, "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1", "insertResult": "{@examMainCd:'''', @patId:'''', @facilityCd:'''', @ordNo:'''', @fnPatId:'''', @regExamDate:'''', @regOrderClass:'''', @examStatus:''1'', @orderComment:'''', @orderExamSetInfoValue:''[]'', @examOrderInfoValue:''[]'', @orderLabelInfoValue:''[]'', @dataGenClass:''2'', @resultExamDate:'''', @resultComment:'''', @examResultInfoValue:''[]'', @copOrderNo1:'''', @copOrderNo2:'''', @isLock:''1'', @indUserId:'''', @isDel:'''', @regDate:'''', @regStaff:'''', @upDate:'''', @upStaff:'''', @isOrder:'''', @examWeek:'''', @examFrom:'''', @examTo:'''', @examPattern:''''}", "updateResult": "{@examMainCd:''exam_main_cd'', @patId:''pat_id'', @facilityCd:''facility_cd'', @ordNo:''ord_no'', @fnPatId:''fn_pat_id'', @regExamDate:''reg_exam_date'', @regOrderClass:''reg_order_class'', @examStatus:''exam_status'', @orderComment:''order_comment'', @orderExamSetInfoValue:''order_exam_set_info'', @examOrderInfoValue:''exam_order_info'', @orderLabelInfoValue:''order_label_info'', @dataGenClass:''data_gen_class'', @resultExamDate:''result_exam_date'', @resultComment:''result_comment'', @examResultInfoValue:''exam_result_info'', @copOrderNo1:''cop_order_no1'', @copOrderNo2:''cop_order_no2'', @isLock:''is_lock'', @indUserId:''ind_user_id'', @isDel:''is_del'', @regDate:''reg_date'', @regStaff:''reg_staff'', @upDate:''up_date'', @upStaff:''up_staff'', @isOrder:''is_order'', @examWeek:''exam_week'', @examFrom:''exam_from'', @examTo:''exam_to'', @examPattern:''exam_pattern'', }"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": 2102, "@indUserId": "$journal.pat_exam_main.ind_user_id", "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1", "@regExamDate": "$journal.pat_exam_main.result_exam_date", "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@resultComment": "$journal.pat_exam_main.result_comment", "@resultExamDate": "$journal.pat_exam_main.result_exam_date"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "3", "sqlCode": 2103, "@indUserId": "$journal.pat_exam_main.ind_user_id", "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1", "@regExamDate": "$journal.pat_exam_main.result_exam_date", "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@resultComment": "$journal.pat_exam_main.result_comment", "@resultExamDate": "$journal.pat_exam_main.result_exam_date"}], "sqlGroup4": [{"crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 2101, "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1", "updateResult": "{@nextDispOrder:''next_disp_order'', @examMainCd:''exam_main_cd'', @examResultInfoFlg:'''',@examResultInfoValue:''exam_result_info'',@examResultInfo.comCd:'''', @examResultInfo.dispOrder:'''', @examResultInfo.examClass:'''', @examResultInfo.freememo:'''', @examResultInfo.hl:'''', @examResultInfo.itemCd:'''', @examResultInfo.itemName:'''', @examResultInfo.jlac10Cd:'''', @examResultInfo.lower:'''', @examResultInfo.result:'''', @examResultInfo.resultDate:'''', @examResultInfo.type:'''', @examResultInfo.unit:'''', @examResultInfo.upper:''''}"}, {"crud": "D", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": 2105}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "3", "sqlCode": 2106, "@examResultInfo.hl": "$journal.detail.pat_exam_main.exam_result_info.hl", "@examResultInfo.comCd": "$journal.detail.pat_exam_main.exam_result_info.com_cd1", "@examResultInfo.itemCd": "$journal.detail.pat_exam_main.exam_result_info.item_cd", "@examResultInfo.result": "$journal.detail.pat_exam_main.exam_result_info.result", "@examResultInfo.freememo": "$journal.detail.pat_exam_main.exam_result_info.freememo"}]}}', '1', '0', -1, '2019-12-13 05:44:54', '2019-12-13 05:44:54');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2090002, 'F_hosp', 'exam_rst', '', 'R', '検体検査', 'text     ', '富士通想定透析初回申し込み', 'Egmain-GX', 'テスト用', '1', '<root name="検査結果(検体検査)">
    <item  name="電文種別" len="2" type="string"/>
    <item  name="レコード継続指示" len="1" type="string"/>
    <item  name="送信先システムコード" len="2" type="string"/>
    <item  name="発信元システムコード" len="2" type="string"/>
    <item  name="処理情報.処理年月日" len="8" type="string"/>
    <item  name="処理情報.処理時刻" len="6" type="string"/>
    <item  name="端末名" len="8" type="string"/>
    <item  name="利用者番号" len="8" type="string"/>
    <item  name="処理区分" len="2" col="$journal.const.crud" type="string" value="json:{&quot;01&quot;:&quot;&quot;,&quot;02&quot;:&quot;&quot;,&quot;03&quot;:&quot;1&quot;}"/>
    <item  name="応答種別" len="2" type="string"/>
    <item  name="電文長" len="6" type="string"/>
    <item  name="エラーコード" len="5" type="string"/>
    <item  name="予備" len="12" type="string"/>
    <item  name="検査状態" len="2" col="$journal.pat_exam_main.reg_order_class" type="string"/>
    <item  name="伝票情報.レポート種別" len="4" type="string"/>
    <item  name="伝票情報.文書番号" len="30" type="string"/>
    <item  name="版数" len="2" type="string"/>
    <item  name="枝番" len="4" type="string"/>
    <item  name="オーダ番号" len="8" col="$journal.pat_exam_main.cop_order_no1" type="string"/>
    <item  name="依頼日" len="8" type="string"/>
    <item  name="患者番号" len="10" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
    <item  name="科コード" len="3" type="string"/>
    <item  name="入外区分" len="1" type="string"/>
    <item  name="病棟コード" len="3" type="string"/>
    <item  name="採取日_採取時間" len="14" col="$journal.pat_exam_main.result_exam_date" type="string"/>
    <item  name="依頼コメントコード" len="20" type="string"/>
    <item  name="ドクタコード" len="8" col="$journal.pat_exam_main.ind_user_id" type="string"/>
    <item  name="フリーコメント" len="50" col="$journal.pat_exam_main.result_comment" type="string"/>
    <item  name="フリーコメント" len="50" type="string"/>
    <item  name="画像フラグ" len="1" type="string"/>
    <item  name="生体情報.身長" len="5" type="string"/>
    <item  name="生体情報.体重" len="5" type="string"/>
    <item  name="生体情報.畜尿量" len="5" type="string"/>
    <item  name="負荷情報.負荷物コード" len="2" type="string"/>
    <item  name="負荷情報.負荷量" len="4" type="string"/>
    <item  name="負荷情報.負荷時間" len="4" type="string"/>
    <item  name="負荷情報.負荷物コード" len="2" type="string"/>
    <item  name="負荷情報.負荷量" len="4" type="string"/>
    <item  name="負荷情報.負荷時間" len="4" type="string"/>
    <item  name="負荷情報.負荷物コード" len="2" type="string"/>
    <item  name="負荷情報.負荷量" len="4" type="string"/>
    <item  name="負荷情報.負荷時間" len="4" type="string"/>
    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>
    <item  name="投与薬剤情報.投与日" len="8" type="string"/>
    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>
    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>
    <item  name="投与薬剤情報.投与日" len="8" type="string"/>
    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>
    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>
    <item  name="投与薬剤情報.投与日" len="8" type="string"/>
    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>
    <occ  name="検体情報" len="0" repeat="50" detail="検体情報詳細"/>
    <occ  name="結果情報" len="0" repeat="300" detail="結果情報詳細"/>
    <item  name="終端" len="1" type="string"/>
</root>', '{"json-key": {"{\"01\":\"\",\"02\":\"\",\"03\":\"1\"}": {"01": "C", "02": "U", "03": "D"}}}', '1', '0', -1, '2019-12-13 05:44:54', '2019-12-13 05:44:54');
