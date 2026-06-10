UPDATE mst_coop_layout
SET coop_ext_setting = $json$
    {
	"key": {
		"応答種別": {
			"N1": "正常以外",
			"N2": "正常以外",
			"N3": "正常以外",
			"N4": "正常以外",
			"NG": "正常以外",
			"OK": "正常"
		}
	},
	"dataset": {
		"sqlGroup1": [{
			"crud": "S",
			"kind": "0",
			"judge": "",
			"table": "pat_personal_main",
			"ctl_no": "1",
			"sqlCode": 1101,
			"@hospPatId": "$journal.pat_personal_main.hosp_pat_id",
			"insertResult": "{@fnPatId:'',@hospPatId:'',@nkkPatId:'',@facilityCd:'',@patLastName:'',@patFirstName:'',@patLastNmKana:'',@patFirstNmKana:'',@patLastNmAlpha:'',@patFirstNmAlpha:'',@patBirthName:'',@patBirthNmKana:'',@patBirthNmAlpha:'',@patBirthday:'',@patSex:'',@nationality:'',@patBloodTypeAbo:'',@patBloodTypeRh:'',@patBloodTypeSerovar:'',@inOutClass:'',@isDie:'',@dieCd:'',@dieDate_Date:'',@dialDiffComInfoValue:'[]',@severityCd:'',@transportCd:'',@patContactInfoFlg:'',@patContactInfo.zipCd:'',@patContactInfo.address:'',@patContactInfo.tel1:'',@patContactInfo.tel2:'',@patContactInfo.fax:'',@patContactInfo.eMail:'',@patContactInfo.workName:'',@patContactInfo.workAddress:'',@patContactInfo.workTel:'',@patContactInfo.memo1:'',@patContactInfo.memo2:'',@otherContactInfoValue:'[]',@vendorContactInfoValue:'[]',@insuranceInfoValue:'[]',@primaryDiseaseCd:'',@remoteMonitorService:'',@remoteMonitorUserId:'',@remoteMonitorUserPw:''}",
			"updateResult": "{@fnPatId:'fn_pat_id',@hospPatId:'hosp_pat_id',@nkkPatId:'nkk_pat_id',@facilityCd:'facility_cd',@patLastName:'pat_last_name',@patFirstName:'pat_first_name',@patLastNmKana:'pat_last_name_kana',@patFirstNmKana:'pat_first_name_kana',@patLastNmAlpha:'pat_last_name_alpha',@patFirstNmAlpha:'pat_first_name_alpha',@patBirthName:'pat_birth_name',@patBirthNmKana:'pat_birth_name_kana',@patBirthNmAlpha:'pat_birth_name_alpha',@patBirthday:'pat_birthday',@patSex:'pat_sex',@nationality:'nationality',@patBloodTypeAbo:'pat_blood_type_abo',@patBloodTypeRh:'pat_blood_type_rh',@patBloodTypeSerovar:'pat_blood_type_serovar',@inOutClass:'in_out_class',@isDie:'is_die',@dieCd:'die_cd',@dieDate_Date:'die_date',@dialDiffComInfoValue:'dial_diff_com_info',@severityCd:'severity_cd',@transportCd:'transport_cd',@patContactInfoFlg:'',@patContactInfoValue:'pat_contact_info',@patContactInfo.zipCd:'',@patContactInfo.address:'',@patContactInfo.tel1:'',@patContactInfo.tel2:'',@patContactInfo.fax:'',@patContactInfo.eMail:'',@patContactInfo.workName:'',@patContactInfo.workAddress:'',@patContactInfo.workTel:'',@patContactInfo.memo1:'',@patContactInfo.memo2:'',@otherContactInfoValue:'other_contact_info',@vendorContactInfoValue:'vendor_contact_info',@insuranceInfoValue:'insurance_info',@regDate:'reg_date',@primaryDiseaseCd:'primary_disease_cd',@remoteMonitorService:'remote_monitor_service',@remoteMonitorUserId:'remote_monitor_user_id',@remoteMonitorUserPw:'remote_monitor_user_pw'}",
			"ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。",
			"ExceptionCondition": "=N"
		},
		{
			"crud": "C",
			"kind": "0",
			"judge": "$journal.pat_personal_main.hosp_pat_id#=#123",
			"table": "pat_personal_main",
			"ctl_no": "2",
			"@patSex": "$journal.pat_personal_main.pat_sex",
			"sqlCode": 1102,
			"@hospPatId": "$journal.pat_personal_main.hosp_pat_id",
			"@inOutClass": "$journal.pat_personal_main.in_out_class",
			"@patBirthday": "$journal.pat_personal_main.pat_birthday",
			"@patLastName": "$journal.pat_personal_main.pat_last_name",
			"@patFirstName": "$journal.pat_personal_main.pat_last_name",
			"@patLastNmKana": "$journal.pat_personal_main.pat_last_name_kana",
			"@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh",
			"@patFirstNmKana": "$journal.pat_personal_main.pat_last_name_kana",
			"@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo",
			"@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1",
			"@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd",
			"@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address",
			"@patContactInfo.detailsAddress": "$journal.pat_personal_main.pat_contact_info.details_address"
		}],
		"sqlGroup2": [{
			"crud": "S",
			"kind": "0",
			"judge": "",
			"table": "pat_unique",
			"ctl_no": "1",
			"sqlCode": 1601,
			"insertResult": "{@patId:'', @facilityCd:'', @medicalHstInfoValue:'[]', @inOutVisitHistoryInfoValue:'[]', @physicalInfoFlg:'', @physicalInfoValue:'[]'}"
		},
		{
			"crud": "C",
			"kind": "0",
			"judge": "",
			"table": "pat_unique",
			"ctl_no": "2",
			"sqlCode": 1602
		},
		{
			"Note": "患者固有情報_更新処理が無し。",
			"crud": "U",
			"kind": "1",
			"judge": "$journal.const.crud#=#NG",
			"table": "pat_unique",
			"ctl_no": "3",
			"sqlCode": 0
		}],
		"sqlGroup3": [{
			"Note": "患者固有情報_入外・転入出情報(死亡以外)",
			"crud": "S",
			"kind": "1",
			"judge": "$journal.pat_personal_main.is_die#<>#1",
			"table": "pat_unique",
			"ctl_no": "1",
			"sqlCode": 1701
		},
		{
			"Note": "死亡以外の場合、処理が有り。",
			"crud": "U",
			"kind": "1",
			"judge": "$journal.pat_personal_main.is_die#<>#1",
			"table": "pat_unique",
			"@isDie": "$journal.pat_personal_main.is_die",
			"ctl_no": "2",
			"sqlCode": 1705,
			"@syoriDate": "$journal.const.date_yyyymmdd",
			"@syoriTime": "$journal.const.time_hhmmss",
			"@inOutClass": "$journal.pat_personal_main.in_out_class"
		}],
		"sqlGroup4": [{
			"crud": "S",
			"kind": "0",
			"judge": "",
			"table": "pat_personal_main",
			"ctl_no": "1",
			"sqlCode": 1101,
			"@hospPatId": "$journal.pat_personal_main.hosp_pat_id",
			"insertResult": "{@fnPatId:'',@hospPatId:'',@nkkPatId:'',@facilityCd:'',@patLastName:'',@patFirstName:'',@patLastNmKana:'',@patFirstNmKana:'',@patLastNmAlpha:'',@patFirstNmAlpha:'',@patBirthName:'',@patBirthNmKana:'',@patBirthNmAlpha:'',@patBirthday:'',@patSex:'',@nationality:'',@patBloodTypeAbo:'',@patBloodTypeRh:'',@patBloodTypeSerovar:'',@inOutClass:'',@isDie:'',@dieCd:'',@dieDate_Date:'',@dialDiffComInfoValue:'[]',@severityCd:'',@transportCd:'',@patContactInfoFlg:'',@patContactInfo.zipCd:'',@patContactInfo.address:'',@patContactInfo.tel1:'',@patContactInfo.tel2:'',@patContactInfo.fax:'',@patContactInfo.eMail:'',@patContactInfo.workName:'',@patContactInfo.workAddress:'',@patContactInfo.workTel:'',@patContactInfo.memo1:'',@patContactInfo.memo2:'',@otherContactInfoValue:'[]',@vendorContactInfoValue:'[]',@insuranceInfoValue:'[]',@primaryDiseaseCd:'',@remoteMonitorService:'',@remoteMonitorUserId:'',@remoteMonitorUserPw:''}",
			"updateResult": "{@fnPatId:'fn_pat_id',@hospPatId:'hosp_pat_id',@nkkPatId:'nkk_pat_id',@facilityCd:'facility_cd',@patLastName:'pat_last_name',@patFirstName:'pat_first_name',@patLastNmKana:'pat_last_name_kana',@patFirstNmKana:'pat_first_name_kana',@patLastNmAlpha:'pat_last_name_alpha',@patFirstNmAlpha:'pat_first_name_alpha',@patBirthName:'pat_birth_name',@patBirthNmKana:'pat_birth_name_kana',@patBirthNmAlpha:'pat_birth_name_alpha',@patBirthday:'pat_birthday',@patSex:'pat_sex',@nationality:'nationality',@patBloodTypeAbo:'pat_blood_type_abo',@patBloodTypeRh:'pat_blood_type_rh',@patBloodTypeSerovar:'pat_blood_type_serovar',@inOutClass:'in_out_class',@isDie:'is_die',@dieCd:'die_cd',@dieDate_Date:'die_date',@dialDiffComInfoValue:'dial_diff_com_info',@severityCd:'severity_cd',@transportCd:'transport_cd',@patContactInfoFlg:'',@patContactInfoValue:'pat_contact_info',@patContactInfo.zipCd:'',@patContactInfo.address:'',@patContactInfo.tel1:'',@patContactInfo.tel2:'',@patContactInfo.fax:'',@patContactInfo.eMail:'',@patContactInfo.workName:'',@patContactInfo.workAddress:'',@patContactInfo.workTel:'',@patContactInfo.memo1:'',@patContactInfo.memo2:'',@otherContactInfoValue:'other_contact_info',@vendorContactInfoValue:'vendor_contact_info',@insuranceInfoValue:'insurance_info',@regDate:'reg_date',@primaryDiseaseCd:'primary_disease_cd',@remoteMonitorService:'remote_monitor_service',@remoteMonitorUserId:'remote_monitor_user_id',@remoteMonitorUserPw:'remote_monitor_user_pw'}",
			"ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。",
			"ExceptionCondition": "=N"
		},
		{
			"crud": "U",
			"kind": "0",
			"judge": "",
			"table": "pat_personal_main",
			"ctl_no": "3",
			"@patSex": "$journal.pat_personal_main.pat_sex",
			"sqlCode": 1103,
			"@hospPatId": "$journal.pat_personal_main.hosp_pat_id",
			"@inOutClass": "$journal.pat_personal_main.in_out_class",
			"@patBirthday": "$journal.pat_personal_main.pat_birthday",
			"@patLastName": "$journal.pat_personal_main.pat_last_name",
			"@patFirstName": "$journal.pat_personal_main.pat_last_name",
			"@patLastNmKana": "$journal.pat_personal_main.pat_last_name_kana",
			"@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh",
			"@patFirstNmKana": "$journal.pat_personal_main.pat_last_name_kana",
			"@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo",
			"@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1",
			"@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd",
			"@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address",
			"@patContactInfo.detailsAddress": "$journal.pat_personal_main.pat_contact_info.details_address"
		}],
		"sqlGroup5": [{
			"crud": "S",
			"kind": "0",
			"judge": "",
			"table": "pat_main",
			"ctl_no": "1",
			"sqlCode": 1201,
			"insertResult": "{@patId:'',@facilityCd:'',@isSame:'',@isImplant:'',@isInfect:'',@isDiabetes:'',@isBloodSugerExam:'',@inOutCurrentState:'',@inOutPlanState:'',@inOutPlanDate_Date:'',@patMemoInfoValue:'[]',@additionInfoValue:'[]',@chargeStaffInfoValue:'[]',@patGroupInfoValue:'[]',@tabooAllergyInfoValue:'[]',@infectInfoValue:'[]',@implantInfoValue:'[]',@tareInfoValue:'{}',@offWaterInfoValue:'{}',@deviceSetInfoValue:'{}',@acceptanceStatusInfoValue:'[]',@isWheelChair:'',@medicalCareInfoFlg:'',@medicalCareInfo.mainCourseCd:'',@medicalCareInfo.dialysisCourseCd:'',@medicalCareInfo.wardCd:'',@medicalCareInfo.dialysisCount:'',@medicalCareInfo.purificationCount:'',@medicalCareInfo.otherDialysisCount:'',@medicalCareInfo.patDialysisCount:'',@medicalCareInfo.facilityCd:'',@medicalCareInfo.dialysisStartDate:'',@medicalCareInfo.hospitalStartDate:'',@schExtEndDate:'',@schExtStatus:'',@cardIdm:'',@oldUpDate_Date:''}",
			"updateResult": "{@patId:'pat_id',@facilityCd:'facility_cd',@isSame:'is_same',@isImplant:'is_implant',@isInfect:'is_infect',@isDiabetes:'is_diabetes',@isBloodSugerExam:'is_blood_suger_exam',@inOutCurrentState:'in_out_current_state',@inOutPlanState:'in_out_plan_state',@inOutPlanDate_Date:'in_out_plan_date',@patMemoInfoValue:'pat_memo_info',@additionInfoValue:'addition_info',@chargeStaffInfoValue:'charge_staff_info',@patGroupInfoValue:'pat_group_info',@tabooAllergyInfoValue:'taboo_allergy_info',@infectInfoValue:'infect_info',@implantInfoValue:'implant_info',@tareInfoValue:'tare_info',@offWaterInfoValue:'off_water_info',@deviceSetInfoValue:'device_set_info',@acceptanceStatusInfoValue:'acceptance_status_info',@isWheelChair:'is_wheel_chair',@medicalCareInfoFlg:'',@medicalCareInfoValue:'medical_care_info',@medicalCareInfo.mainCourseCd:'',@medicalCareInfo.dialysisCourseCd:'',@medicalCareInfo.wardCd:'',@medicalCareInfo.dialysisCount:'',@medicalCareInfo.purificationCount:'',@medicalCareInfo.otherDialysisCount:'',@medicalCareInfo.patDialysisCount:'',@medicalCareInfo.facilityCd:'',@medicalCareInfo.dialysisStartDate:'',@medicalCareInfo.hospitalStartDate:'',@schExtEndDate:'sch_ext_end_date',@schExtStatus:'sch_ext_status',@cardIdm:'card_idm',@oldUpDate_Date:'old_up_date'}"
		},
		{
			"crud": "C",
			"kind": "0",
			"judge": "",
			"table": "pat_main",
			"@isDie": "$journal.pat_personal_main.is_die",
			"ctl_no": "2",
			"sqlCode": 1202,
			"@inOutClass": "$journal.pat_personal_main.in_out_class",
			"@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd",
			"@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd"
		},
		{
			"crud": "U",
			"kind": "0",
			"judge": "",
			"table": "pat_main",
			"@isDie": "$journal.pat_personal_main.is_die",
			"ctl_no": "3",
			"sqlCode": 1203,
			"@inOutClass": "$journal.pat_personal_main.in_out_class",
			"@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd",
			"@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd"
		}],
		"sqlGroup6": [{
			"crud": "S",
			"kind": "0",
			"judge": "",
			"table": "pat_insurance",
			"@ctlNo": "$journal.detail.pat_insurance.ctl_no",
			"ctl_no": "1",
			"sqlCode": 1301,
			"insertResult": "{@patId:'0',@facilityCd:'0',@ctlNo:'',@fnPatId:'',@insuClass:'',@insuName:'',@insuNmShort:'',@insuInfoFlg:'',@insuInfo.insuNo:'',@insuInfo.insuPatName:'',@insuInfo.insuPatNo:'',@insuInfo.insuKbn:'',@insuInfo.insuPatMark:'',@insuInfo.ckiClass:'',@insuInfo.kkiClass:'',@insuInfo.undSix:'',@insuInfo.futan-g:'',@insuInfo.futan-n:'',@insuPubInfoFlg:'',@insuPubInfo.insuPubName:'',@insuPubInfo.insuPubNo:'',@insuPubInfo.insuPubPatNo:'',@insuSetInfoFlg:'',@insuSetInfo.insuCd:'',@insuSetInfo.insuPub1Cd:'',@insuSetInfo.insuPub2Cd:'',@insuSetInfo.insuPub3Cd:'',@insuSetInfo.insuPub4Cd:'',@isSelected:'',@isDisp:'1',@coopCode:'',@isCoop:'',@startDate:'',@endDate:'',@checkDate:'',@oldUpDate_Date:''}",
			"updateResult": "{@patId:'pat_id',@facilityCd:'facility_cd',@ctlNo:'ctl_no',@fnPatId:'fn_pat_id',@insuClass:'insu_class',@insuName:'insu_name',@insuNmShort:'insu_name_short',@insuInfoFlg:'',@insuInfoValue:'insu_info',@insuInfo.insuNo:'',@insuInfo.insuPatName:'',@insuInfo.insuPatNo:'',@insuInfo.insuKbn:'',@insuInfo.insuPatMark:'',@insuInfo.ckiClass:'',@insuInfo.kkiClass:'',@insuInfo.undSix:'',@insuInfo.futan-g:'',@insuInfo.futan-n:'',@insuPubInfoFlg:'',@insuPubInfoValue:'insu_pub_info',@insuPubInfo.insuPubName:'',@insuPubInfo.insuPubNo:'',@insuPubInfo.insuPubPatNo:'',@insuSetInfoFlg:'',@insuSetInfoValue:'insu_set_info',@insuSetInfo.insuCd:'',@insuSetInfo.insuPub1Cd:'',@insuSetInfo.insuPub2Cd:'',@insuSetInfo.insuPub3Cd:'',@insuSetInfo.insuPub4Cd:'',@isSelected:'is_selected',@isDisp:'is_disp',@coopCode:'coop_code',@isCoop:'is_coop',@startDate:'start_date',@endDate:'end_date',@checkDate:'check_date',@oldUpDate_Date:'old_up_date'}"
		},
		{
			"crud": "C",
			"kind": "0",
			"judge": "",
			"table": "pat_insurance",
			"@ctlNo": "$journal.detail.pat_insurance.ctl_no",
			"ctl_no": "2",
			"sqlCode": 1302,
			"@endDate": "$journal.detail.pat_insurance.end_date",
			"@insuName": "$journal.detail.pat_insurance.insu_name",
			"@startDate": "$journal.detail.pat_insurance.start_date",
			"@insuInfo.insuNo": "$journal.detail.pat_insurance.insu_info.insu_no",
			"@insuInfo.futan-g": "$journal.detail.pat_insurance.insu_info.futan-g",
			"@insuInfo.futan-n": "$journal.detail.pat_insurance.insu_info.futan-n",
			"@insuInfo.insuKbn": "$journal.detail.pat_insurance.insu_info.insu_kbn",
			"@insuPubInfo.insuPubNo": "$journal.detail.pat_insurance.insu_pub_info.insu_pub_no"
		},
		{
			"crud": "U",
			"kind": "0",
			"judge": "",
			"table": "pat_insurance",
			"@ctlNo": "$journal.detail.pat_insurance.ctl_no",
			"ctl_no": "3",
			"sqlCode": 1303,
			"@endDate": "$journal.detail.pat_insurance.end_date",
			"@insuName": "$journal.detail.pat_insurance.insu_name",
			"@startDate": "$journal.detail.pat_insurance.start_date",
			"@insuInfo.insuNo": "$journal.detail.pat_insurance.insu_info.insu_no",
			"@insuInfo.futan-g": "$journal.detail.pat_insurance.insu_info.futan-g",
			"@insuInfo.futan-n": "$journal.detail.pat_insurance.insu_info.futan-n",
			"@insuInfo.insuKbn": "$journal.detail.pat_insurance.insu_info.insu_kbn",
			"@insuPubInfo.insuPubNo": "$journal.detail.pat_insurance.insu_pub_info.insu_pub_no"
		}],
		"sqlGroup7": [{
			"crud": "S",
			"kind": "0",
			"type": "json",
			"judge": "",
			"table": "pat_personal_main_1",
			"ctl_no": "1",
			"sqlCode": 1101
		},
		{
			"crud": "U",
			"kind": "0",
			"judge": "",
			"table": "pat_personal_main_1",
			"ctl_no": "2",
			"sqlCode": 1403,
			"@otherContactInfo.tel1": "$journal.detail.pat_personal_main_1.other_contact_info.tel1",
			"@otherContactInfo.tel2": "$journal.detail.pat_personal_main_1.other_contact_info.tel2",
			"@otherContactInfo.memo1": "$journal.detail.pat_personal_main_1.other_contact_info.memo1",
			"@otherContactInfo.lastName": "$journal.detail.pat_personal_main_1.other_contact_info.last_name",
			"@otherContactInfo.relationCd": "$journal.detail.pat_personal_main_1.other_contact_info.relation_cd"
		}],
		"sqlGroup8": [{
			"crud": "S",
			"kind": "0",
			"judge": "",
			"table": "pat_personal_main",
			"ctl_no": "1",
			"sqlCode": 1101
		},
		{
			"Note": "患者固有情報_生存の有無登録",
			"crud": "U",
			"kind": "0",
			"judge": "",
			"table": "pat_personal_main",
			"@isDie": "$journal.pat_personal_main.is_die",
			"ctl_no": "3",
			"sqlCode": 1502,
			"@dieDate_Date": "$journal.pat_personal_main.die_date"
		}],
		"sqlGroup9": [{
			"Note": "患者固有情報_身体情報",
			"crud": "S",
			"kind": "0",
			"judge": "",
			"table": "pat_unique",
			"ctl_no": "1",
			"sqlCode": 1701
		},
		{
			"crud": "U",
			"kind": "0",
			"judge": "",
			"table": "pat_unique",
			"ctl_no": "2",
			"sqlCode": 1703,
			"@physicalInfo.height": "$journal.detail.pat_unique.physical_info.height",
			"@physicalInfo.ctrWeight": "$journal.detail.pat_unique.physical_info.ctr_weight",
			"@physicalInfo.examDate1_GMTDate": "$journal.detail.pat_unique.physical_info.exam_date1",
			"@physicalInfo.examDate2_GMTDate": "$journal.detail.pat_unique.physical_info.exam_date2"
		}],
		"sqlGroup10": [{
			"Note": "患者固有情報_入外・転入出情報(死亡)",
			"crud": "S",
			"kind": "1",
			"judge": "$journal.pat_personal_main.is_die#=#1",
			"table": "pat_unique",
			"ctl_no": "1",
			"sqlCode": 1701
		},
		{
			"Note": "死亡の場合、処理が有り。",
			"crud": "U",
			"kind": "1",
			"judge": "$journal.pat_personal_main.is_die#=#1",
			"table": "pat_unique",
			"@isDie": "$journal.pat_personal_main.is_die",
			"ctl_no": "2",
			"sqlCode": 1706,
			"@syoriDate": "$journal.const.date_yyyymmdd",
			"@syoriTime": "$journal.const.time_hhmmss",
			"@dieDate_Date": "$journal.pat_personal_main.die_date"
		}],
		"sqlGroup11": [{
			"Note": "患者固有情報_既往歴情報(死亡)",
			"crud": "S",
			"kind": "1",
			"judge": "$journal.pat_personal_main.is_die#=#1",
			"table": "pat_unique",
			"ctl_no": "1",
			"sqlCode": 1701
		},
		{
			"Note": "死亡の場合、処理が有り。",
			"crud": "U",
			"kind": "1",
			"judge": "$journal.pat_personal_main.is_die#=#1",
			"table": "pat_unique",
			"@isDie": "$journal.pat_personal_main.is_die",
			"ctl_no": "2",
			"sqlCode": 1707,
			"@dieDate_Date": "$journal.pat_personal_main.die_date"
		}],
		"sqlGroup12": [{
			"crud": "S",
			"kind": "0",
			"type": "json",
			"judge": "",
			"table": "pat_main",
			"ctl_no": "1",
			"sqlCode": 1201,
			"updateResult": "{@nextCtlNo3:'next_ctl_no_3', @tabooAllergyInfoFlg:'', @tabooAllergyInfoValue:'taboo_allergy_info', @tabooAllergyInfo.memo:'', @tabooAllergyInfo.ctlNo:'', @tabooAllergyInfo.content:'', @tabooAllergyInfo.dispOrder:'', @tabooAllergyInfo.categoryClass:'', @tabooAllergyInfo.tabooAllergyCd:'', @tabooAllergyInfo.tabooAllergyClass:''}"
		},
		{
			"Note": "禁忌情報:マスタに99999999以外の連携コードが存在しない場合、変更後のコードが「null:空」です、無効なデータ。",
			"crud": "U",
			"kind": "0",
			"judge": "",
			"table": "pat_main",
			"ctl_no": "3",
			"sqlCode": 1802,
			"@tabooAllergyInfo.memo": "$journal.detail.pat_main.taboo_allergy_info.memo",
			"@tabooAllergyInfo.content": "$journal.detail.pat_main.taboo_allergy_info.content",
			"@tabooAllergyInfo.symptom": "$journal.detail.pat_main.taboo_allergy_info.symptom",
			"@tabooAllergyInfo.stopFlag": "$journal.detail.pat_main.taboo_allergy_info.stop_flag",
			"@tabooAllergyInfo.startDate": "$journal.detail.pat_main.taboo_allergy_info.start_date",
			"@tabooAllergyInfo.categoryClass": "0",
			"@tabooAllergyInfo.tabooAllergyCd": "$journal.detail.pat_main.taboo_allergy_info.taboo_allergy_cd",
			"@tabooAllergyInfo.tabooAllergyClass": "1"
		}],
		"sqlGroup13": [{
			"Note": "sqlGroup6:感染症情報を更新すう",
			"crud": "S",
			"kind": "0",
			"type": "json",
			"judge": "",
			"table": "pat_main_1",
			"ctl_no": "1",
			"sqlCode": 1201
		},
		{
			"Note": "json場合、[D]の設定が必要です。しかし、感染症情報をクリアしません。judgeに[crud#=#NG]を設定する。",
			"crud": "D",
			"kind": "1",
			"judge": "$journal.const.crud#=#NG",
			"table": "pat_main_1",
			"ctl_no": "2",
			"sqlCode": 0
		},
		{
			"crud": "U",
			"kind": "0",
			"judge": "",
			"table": "pat_main_1",
			"ctl_no": "3",
			"sqlCode": 7206,
			"@infectInfo.name": "$journal.detail.pat_main_1.infect_info.name",
			"@infectInfo.infect": "$journal.detail.pat_main_1.infect_info.infect",
			"@infectInfo.infectionCd": "$journal.detail.pat_main_1.infect_info.infection_cd",
			"@infectInfo.examDate_Date": "$journal.detail.pat_main_1.infect_info.exam_date"
		}]
	},
	"CoopIniConvUtil": {
		"$journal.pat_personal_main.pat_sex": "CONV_SEX_TO_FNW",
		"$journal.pat_personal_main.in_out_class": "CONV_INOUT_TO_FNW",
		"$journal.pat_personal_main.pat_blood_type_rh": "CONV_BLOOD_RH_TO_FNW",
		"$journal.detail.pat_main_1.infect_info.infect": "CONV_INFECTION_TO_FNW",
		"$journal.pat_personal_main.pat_blood_type_abo": "CONV_BLOOD_ABO_TO_FNW"
	},
	"CoopMstConvUtil": {
		"$journal.pat_main.medical_care_info.ward_cd": {
			"conv_type": "mst_ward",
			"hospital_cd_names": ["in_hospital_cd_1"],
			"master_data_settings": {
				"in_hospital_cd_1": "$journal.pat_main.medical_care_info.ward_cd"
			}
		},
		"$journal.pat_main.medical_care_info.main_course_cd": {
			"conv_type": "mst_course",
			"hospital_cd_names": ["in_hospital_cd_1"],
			"master_data_settings": {
				"in_hospital_cd_1": "$journal.pat_main.medical_care_info.main_course_cd"
			}
		},
		"$journal.detail.pat_main_1.infect_info.infection_cd": {
			"conv_type": "mst_infection",
			"hospital_cd_names": ["in_hospital_cd_1"],
			"master_data_settings": {
				"name": "$journal.detail.pat_main_1.infect_info.name",
				"in_hospital_cd_1": "$journal.detail.pat_main_1.infect_info.infection_cd"
			}
		},
		"$journal.detail.pat_personal_main_1.other_contact_info.relation_cd": {
			"conv_type": "mst_relationship",
			"hospital_cd_names": ["in_hospital_cd_1"],
			"master_data_settings": {
				"name": "$journal.detail.pat_personal_main_1.other_contact_info.relation_cd",
				"in_hospital_cd_1": "$journal.detail.pat_personal_main_1.other_contact_info.relation_cd"
			}
		}
	}
}
$json$::jsonb
WHERE ctl_no = -2030001;
