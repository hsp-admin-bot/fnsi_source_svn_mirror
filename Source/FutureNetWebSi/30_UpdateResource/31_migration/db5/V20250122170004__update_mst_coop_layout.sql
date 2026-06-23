DELETE FROM ntss.mst_coop_layout
WHERE ctl_no IN (-3010001, -3010002, -3010003, -3010004, -3010005, -3010006, -3010007, -3010008, -3010009, -3010010, -3010011, -3010012, -3010013, -3010014, -3010015, -3010016, -3030001, -3030002, -3030003, -3040001, -3040002, -3040003, -3040004, -3040005, -3040006, -3040007, -3040008, -3040009, -3040010, -3040011, -3040012, -3070001, -3070002, -3070003, -3070004, -3070005, -3070006, -3070007, -3070008, -3070009, -3070010, -3070011, -3070012, -3080001, -3080002, -3080003, -3080004, -3080005, -3080006, -3080007, -3080008, -3080009, -3080010, -3080011, -3080013, -3080015, -3080017, -3080018, -3080019, -3090001, -3090002, -3160001);

INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010001, 'N_hosp', 'ini_dial', '', 'R', 'pre', 'text', 'NEC想定透析初回指示', 'MEGA', 'テスト用ver1/Standard', '1', '<root name="透析申込(pre)">
  <item name="空白" len="20" type="string"/>
  <item name="電文長" len="12" type="string"/>
  <item name="コマンド名" len="8" type="string" key="command_name"/>
  <item name="処理区分" len="1" type="string"/>
  <item name="病院コード" len="2" type="string"/>
  <item name="患者情報.患者番号" len="10" type="string"/>
  <item name="患者情報.患者氏名" len="40" type="string"/>
  <item name="患者情報.患者カナ氏名" len="20" type="string"/>
  <item name="患者情報.性別" len="1" type="string"/>
  <item name="患者情報.生年月日" len="8" type="string"/>
  <item name="患者情報.郵便番号１" len="7" type="string"/>
  <item name="患者情報.患者住所１" len="100" type="string"/>
  <item name="患者情報.電話番号１" len="12" type="string"/>
  <item name="患者情報.郵便番号２" len="7" type="string"/>
  <item name="患者情報.患者住所２" len="100" type="string"/>
  <item name="患者情報.電話番号２" len="12" type="string"/>
  <item name="病棟コード" len="4" type="string"/>
  <item name="病棟名称" len="20" type="string"/>
  <item name="病室コード" len="4" type="string"/>
  <item name="病室名称" len="20" type="string"/>
  <item name="看護区分" len="2" type="string"/>
  <item name="患者区分" len="2" type="string"/>
  <item name="救護区分" len="2" type="string"/>
  <item name="予備区分" len="1" type="string"/>
  <item name="障害情報" len="15" type="string"/>
  <item name="身長" len="5" type="string"/>
  <item name="体重" len="5" type="string"/>
  <item name="血液型ＡＢＯ" len="1" type="string"/>
  <item name="血液型Ｒｈ" len="1" type="string"/>
  <item name="感染情報" len="20" type="string"/>
  <item name="感染コメント" len="60" type="string"/>
  <item name="薬剤禁忌情報" len="20" type="string"/>
  <item name="禁忌コメント" len="60" type="string"/>
  <item name="妊娠日" len="8" type="string"/>
  <item name="死亡退院日" len="8" type="string"/>
  <item name="予備" len="30" type="string"/>
</root>
', '{"key": {"command_name": {"C-DIRECT": "初回指示情報", "C-KNJDEL": "患者死亡退院情報", "C-KNJUPD": "患者情報"}}, "dataset": {"sqlGroup1": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "@isDie": "0", "ctl_no": "2", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -600013, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "1", "@severityCd": "$journal.pat_personal_main.severity_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@transportCd": "$journal.pat_personal_main.transport_cd", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "3", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -600015, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "1", "@severityCd": "$journal.pat_personal_main.severity_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@transportCd": "$journal.pat_personal_main.transport_cd", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}], "sqlGroup2": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "No3": "NEC場合、病棟コードより、[入外区分]を更新する。病棟コードが空白の場合は「入外区分 = 外来」で登録、空白でない場合は「入外区分 = 入院」で登録します。", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "No3": "NEC場合、[入外区分]の更新処理、pat_personal_mainを更新する。または、pat_mainから、データを取得する。tableにpat_mainを設定しました。", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "2", "sqlCode": 9101, "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd"}], "sqlGroup3": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "No3": "NEC場合、[死亡患者、連絡先情報、透析困難情報]を更新する。", "No4": "死亡退院日が空白の場合は「死亡患者 = 対象外」で登録、空白でない場合は「死亡患者 = 対象」で登録します。", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "2", "sqlCode": 9102}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "3", "sqlCode": 9103, "@otherContactInfo.tel1": "$journal.pat_personal_main.other_contact_info.tel1", "@otherContactInfo.zipCd": "$journal.pat_personal_main.other_contact_info.zip_cd", "@otherContactInfo.address": "$journal.pat_personal_main.other_contact_info.address", "@otherContactInfo.patName": "$journal.pat_personal_main.pat_name", "@otherContactInfo.patNameKana": "$journal.pat_personal_main.pat_name_kana"}], "sqlGroup4": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201, "insertResult": "{@patId:'''',@facilityCd:'''',@isSame:'''',@isImplant:'''',@isInfect:'''',@isDiabetes:'''',@isBloodSugerExam:'''',@inOutCurrentState:'''',@inOutPlanState:'''',@inOutPlanDate_Date:'''',@patMemoInfoValue:''[]'',@additionInfoValue:''[]'',@chargeStaffInfoValue:''[]'',@patGroupInfoValue:''[]'',@tabooAllergyInfoValue:''[]'',@infectInfoValue:''[]'',@implantInfoValue:''[]'',@tareInfoValue:''{}'',@offWaterInfoValue:''{}'',@deviceSetInfoValue:''{}'',@acceptanceStatusInfoValue:''[]'',@isWheelChair:'''',@medicalCareInfoFlg:'''',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:'''',@schExtStatus:'''',@cardIdm:'''',@oldUpDate_Date:''''}", "updateResult": "{@patId:''pat_id'',@facilityCd:''facility_cd'',@isSame:''is_same'',@isImplant:''is_implant'',@isInfect:''is_infect'',@isDiabetes:''is_diabetes'',@isBloodSugerExam:''is_blood_suger_exam'',@inOutCurrentState:''in_out_current_state'',@inOutPlanState:''in_out_plan_state'',@inOutPlanDate_Date:''in_out_plan_date'',@patMemoInfoValue:''pat_memo_info'',@additionInfoValue:''addition_info'',@chargeStaffInfoValue:''charge_staff_info'',@patGroupInfoValue:''pat_group_info'',@tabooAllergyInfoValue:''taboo_allergy_info'',@infectInfoValue:''infect_info'',@implantInfoValue:''implant_info'',@tareInfoValue:''tare_info'',@offWaterInfoValue:''off_water_info'',@deviceSetInfoValue:''device_set_info'',@acceptanceStatusInfoValue:''acceptance_status_info'',@isWheelChair:''is_wheel_chair'',@medicalCareInfoFlg:'''',@medicalCareInfoValue:''medical_care_info'',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:''sch_ext_end_date'',@schExtStatus:''sch_ext_status'',@cardIdm:''card_idm'',@oldUpDate_Date:''old_up_date''}"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "2", "sqlCode": -600014, "@inOutClass": "1", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "3", "sqlCode": -600016, "@inOutClass": "1", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}], "sqlGroup5": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "2", "sqlCode": 9104}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "3", "sqlCode": 9105, "@infectInfo1": "$journal.pat_main.infect_info1", "@infectInfo2": "$journal.pat_main.infect_info2", "@infectInfo3": "$journal.pat_main.infect_info3", "@infectInfo4": "$journal.pat_main.infect_info4", "@infectInfo5": "$journal.pat_main.infect_info5", "@infectInfo6": "$journal.pat_main.infect_info6", "@infectInfo7": "$journal.pat_main.infect_info7", "@infectInfo8": "$journal.pat_main.infect_info8", "@infectInfo9": "$journal.pat_main.infect_info9", "@infectInfo10": "$journal.pat_main.infect_info10", "@infectInfo11": "$journal.pat_main.infect_info11", "@infectInfo12": "$journal.pat_main.infect_info12", "@infectInfo13": "$journal.pat_main.infect_info13", "@infectInfo14": "$journal.pat_main.infect_info14", "@infectInfo15": "$journal.pat_main.infect_info15", "@infectInfo16": "$journal.pat_main.infect_info16", "@infectInfo17": "$journal.pat_main.infect_info17", "@infectInfo18": "$journal.pat_main.infect_info18", "@infectInfo19": "$journal.pat_main.infect_info19", "@infectInfo20": "$journal.pat_main.infect_info20", "@tabooAllergyInfo": "$journal.pat_main.taboo_allergy_info", "@chargeStaffInfo.staffCd": "$journal.pat_main.charge_staff_info.staff_cd"}], "sqlGroup6": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_unique", "ctl_no": "1", "sqlCode": 1601, "insertResult": "{@patId:'''', @facilityCd:'''', @medicalHstInfoValue:''[]'', @inOutVisitHistoryInfoValue:''[]'', @physicalInfoFlg:'''', @physicalInfoValue:''[]''}"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_unique", "ctl_no": "2", "sqlCode": 9106, "@physicalInfo.dw": "$journal.pat_unique.physical_info.dw", "@physicalInfo.height": "$journal.pat_unique.physical_info.height", "@physicalInfo.ctrWeight": "$journal.pat_unique.physical_info.ctr_weight", "@physicalInfo.orderClass": "1"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_unique", "ctl_no": "3", "sqlCode": 9107, "@physicalInfo.dw": "$journal.pat_unique.physical_info.dw", "@physicalInfo.height": "$journal.pat_unique.physical_info.height", "@physicalInfo.ctrWeight": "$journal.pat_unique.physical_info.ctr_weight", "@physicalInfo.orderClass": "1"}], "sqlGroup7": [{"No1": "指示情報→登録・更新", "No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_insurance_1", "ctl_no": "1", "sqlCode": 9108, "@coopCode": "$journal.pat_insurance_1.coop_code", "insertResult": "{@insuranceCd:''0'',@patId:''0'',@facilityCd:''0'',@ctlNo:'''',@fnPatId:'''',@insuClass:'''',@insuName:'''',@insuNmShort:'''',@insuInfoFlg:'''',@insuInfo.insuNo:'''',@insuInfo.insuPatName:'''',@insuInfo.insuPatNo:'''',@insuInfo.insuKbn:'''',@insuInfo.insuPatMark:'''',@insuInfo.ckiClass:'''',@insuInfo.kkiClass:'''',@insuInfo.undSix:'''',@insuInfo.futan-g:'''',@insuInfo.futan-n:'''',@insuPubInfoFlg:'''',@insuPubInfo.insuPubName:'''',@insuPubInfo.insuPubNo:'''',@insuPubInfo.insuPubPatNo:'''',@insuSetInfoFlg:'''',@insuSetInfo.insuCd:'''',@insuSetInfo.insuPub1Cd:'''',@insuSetInfo.insuPub2Cd:'''',@insuSetInfo.insuPub3Cd:'''',@insuSetInfo.insuPub4Cd:'''',@isSelected:'''',@isDisp:''1'',@coopCode:'''',@isCoop:'''',@startDate:'''',@endDate:'''',@checkDate:'''',@oldUpDate_Date:''''}", "updateResult": "{@insuranceCd:''insurance_cd'',@patId:''pat_id'',@facilityCd:''facility_cd'',@ctlNo:''ctl_no'',@fnPatId:''fn_pat_id'',@insuClass:''insu_class'',@insuName:''insu_name'',@insuNmShort:''insu_name_short'',@insuInfoFlg:'''',@insuInfoValue:''insu_info'',@insuInfo.insuNo:'''',@insuInfo.insuPatName:'''',@insuInfo.insuPatNo:'''',@insuInfo.insuKbn:'''',@insuInfo.insuPatMark:'''',@insuInfo.ckiClass:'''',@insuInfo.kkiClass:'''',@insuInfo.undSix:'''',@insuInfo.futan-g:'''',@insuInfo.futan-n:'''',@insuPubInfoFlg:'''',@insuPubInfoValue:''insu_pub_info'',@insuPubInfo.insuPubName:'''',@insuPubInfo.insuPubNo:'''',@insuPubInfo.insuPubPatNo:'''',@insuSetInfoFlg:'''',@insuSetInfoValue:''insu_set_info'',@insuSetInfo.insuCd:'''',@insuSetInfo.insuPub1Cd:'''',@insuSetInfo.insuPub2Cd:'''',@insuSetInfo.insuPub3Cd:'''',@insuSetInfo.insuPub4Cd:'''',@isSelected:''is_selected'',@isDisp:''is_disp'',@coopCode:''coop_code'',@isCoop:''is_coop'',@startDate:''start_date'',@endDate:''end_date'',@checkDate:''check_date'',@oldUpDate_Date:''old_up_date''}"}, {"No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_insurance_1", "ctl_no": "2", "sqlCode": 9109, "@coopCode": "$journal.pat_insurance_1.coop_code"}, {"No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_insurance_1", "ctl_no": "3", "sqlCode": 9110, "@coopCode": "$journal.pat_insurance_1.coop_code"}], "sqlGroup8": [{"No1": "指示情報→登録・更新", "No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_coop_detail", "ctl_no": "1", "sqlCode": 9111, "insertResult": "{@coopSaveNo:'''', @facilityCd:'''', @patId:'''', @save1:'''', @save1Flg:'''', @save2Flg:'''', @save2.ord_no:'''', @save2.instruction_doctor_generation_no:'''', @save2.dialysis_type:'''', @save2.dialysis_course:'''', @save2.dialysis_pattern:'''', @save2.start_date_regular:'''', @save2.end_date_regular:'''', @save2.implementation_place:'''', @save2.update_terminal:'''', @save2.addition_generation_no:'''', @save2.blood_purification_method:'''', @save2.blood_purification_generation_no:'''', @save2.updater:'''', @save2.updater_generation_no:'''', @save3:'''', @save4:'''', @save5:'''', @save6:'''', @save7:'''', @save8:'''', @save9:'''', @save10:'''', @isDisp:'''', @isDel:'''', @userId:'''', @upDate_Date:'''', @regDate_Date:''''}", "updateResult": "{@coopSaveNo:''coop_save_no'', @facilityCd:''facility_cd'', @patId:''pat_id'', @save1Value:''save_1'', @save1Flg:'''', @save2Flg:'''', @save2Value:''save_2'', @save2.ord_no:'''', @save2.instruction_doctor_generation_no:'''', @save2.dialysis_type:'''', @save2.dialysis_course:'''', @save2.dialysis_pattern:'''', @save2.start_date_regular:'''', @save2.end_date_regular:'''', @save2.implementation_place:'''', @save2.update_terminal:'''', @save2.addition_generation_no:'''', @save2.blood_purification_method:'''', @save2.blood_purification_generation_no:'''', @save2.updater:'''', @save2.updater_generation_no:'''', @save3:''save_3'', @save4:''save_4'', @save5:''save_5'', @save6:''save_6'', @save7:''save_7'', @save8:''save_8'', @save9:''save_9'', @save10:''save_10'', @isDisp:''is_disp'', @isDel:''is_del'', @userId:''user_id'', @upDate_Date:''up_date'', @regDate_Date:''reg_date''}"}, {"No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_coop_detail", "ctl_no": "2", "@userId": "-1", "sqlCode": 9112, "@save2.dw": "$journal.pat_coop_detail.dw", "@save2.va3": "$journal.pat_coop_detail.va3", "@save2.ord_no": "$journal.pat_coop_detail.ord_no", "@save2.kur_cd1": "$journal.pat_coop_detail.kur_cd1", "@save2.updater": "$journal.pat_coop_detail.updater", "@save2.addition": "$journal.pat_personal_main.dial_diff_com_info.dial_diff_cd", "@save2.va_direct": "$journal.pat_coop_detail.va_direct", "@save2.dialysis_type": "$journal.pat_coop_detail.dialysis_type", "@save2.dialysis_course": "$journal.pat_coop_detail.dialysis_course", "@save2.update_terminal": "$journal.pat_coop_detail.update_terminal", "@save2.dialysis_pattern": "$journal.pat_coop_detail.dialysis_pattern", "@save2.end_date_regular": "$journal.pat_coop_detail.end_date_regular", "@save2.insurance_code_01": "$journal.pat_insurance_1.coop_code", "@save2.insurance_code_02": "$journal.pat_insurance_2.coop_code", "@save2.insurance_code_03": "$journal.pat_insurance_3.coop_code", "@save2.instruction_doctor": "$journal.pat_main.charge_staff_info.staff_cd", "@save2.start_date_regular": "$journal.pat_coop_detail.start_date_regular", "@save2.implementation_place": "$journal.pat_coop_detail.implementation_place", "@save2.updater_generation_no": "$journal.pat_coop_detail.updater_generation_no", "@save2.addition_generation_no": "$journal.pat_coop_detail.addition_generation_no", "@save2.instruction_department": "$journal.pat_main.medical_care_info.main_course_cd", "@save2.blood_purification_method": "$journal.pat_coop_detail.blood_purification_method", "@save2.blood_purification_generation_no": "$journal.pat_coop_detail.blood_purification_generation_no", "@save2.instruction_doctor_generation_no": "$journal.pat_coop_detail.instruction_doctor_generation_no"}, {"No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_coop_detail", "ctl_no": "3", "@userId": "-1", "sqlCode": 9113, "@save2.dw": "$journal.pat_coop_detail.dw", "@save2.va3": "$journal.pat_coop_detail.va3", "@save1.ord_no": "$journal.pat_coop_detail.ord_no", "@save2.ord_no": "$journal.pat_coop_detail.ord_no", "@save2.kur_cd1": "$journal.pat_coop_detail.kur_cd1", "@save2.updater": "$journal.pat_coop_detail.updater", "@save2.addition": "$journal.pat_personal_main.dial_diff_com_info.dial_diff_cd", "@save2.va_direct": "$journal.pat_coop_detail.va_direct", "@save1.dialysis_type": "$journal.pat_coop_detail.dialysis_type", "@save2.dialysis_type": "$journal.pat_coop_detail.dialysis_type", "@save1.dialysis_course": "$journal.pat_coop_detail.dialysis_course", "@save1.update_terminal": "$journal.pat_coop_detail.update_terminal", "@save2.dialysis_course": "$journal.pat_coop_detail.dialysis_course", "@save2.update_terminal": "$journal.pat_coop_detail.update_terminal", "@save1.dialysis_pattern": "$journal.pat_coop_detail.dialysis_pattern", "@save1.end_date_regular": "$journal.pat_coop_detail.end_date_regular", "@save2.dialysis_pattern": "$journal.pat_coop_detail.dialysis_pattern", "@save2.end_date_regular": "$journal.pat_coop_detail.end_date_regular", "@save2.insurance_code_01": "$journal.pat_insurance_1.coop_code", "@save2.insurance_code_02": "$journal.pat_insurance_2.coop_code", "@save2.insurance_code_03": "$journal.pat_insurance_3.coop_code", "@save1.start_date_regular": "$journal.pat_coop_detail.start_date_regular", "@save2.instruction_doctor": "$journal.pat_main.charge_staff_info.staff_cd", "@save2.start_date_regular": "$journal.pat_coop_detail.start_date_regular", "@save1.implementation_place": "$journal.pat_coop_detail.implementation_place", "@save2.implementation_place": "$journal.pat_coop_detail.implementation_place", "@save2.updater_generation_no": "$journal.pat_coop_detail.updater_generation_no", "@save2.addition_generation_no": "$journal.pat_coop_detail.addition_generation_no", "@save2.instruction_department": "$journal.pat_main.medical_care_info.main_course_cd", "@save2.blood_purification_method": "$journal.pat_coop_detail.blood_purification_method", "@save1.instruction_doctor_generation_no": "$journal.pat_coop_detail.instruction_doctor_generation_no", "@save2.blood_purification_generation_no": "$journal.pat_coop_detail.blood_purification_generation_no", "@save2.instruction_doctor_generation_no": "$journal.pat_coop_detail.instruction_doctor_generation_no"}], "sqlGroup9": [{"No1": "指示情報→登録・更新", "No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_coop_detail", "ctl_no": "1", "sqlCode": 9111, "updateResult": "{@coopSaveNo:''coop_save_no'', @facilityCd:''facility_cd'', @patId:''pat_id'', @save1:''save_1'', @save2:''save_2'', @save3Flg:'''', @save3Value:''save_3'', @save3.addition_pat_cd:'''', @save3.addition_other_cd:'''', @save3.item_comment_cd:'''', @save3.dialysis_cmt_1_cd:'''', @save3.dialysis_cmt_2_cd:'''', @save3.dialysis_cmt_3_cd:'''', @save3.addition_pat_generation_no:'''', @save3.addition_other_generation_no:'''', @save3.item_comment_generation_no:'''', @save3.dialysis_cmt_1_generation_no:'''', @save3.dialysis_cmt_2_generation_no:'''', @save3.dialysis_cmt_3_generation_no:'''', @save4:''save_4'', @save5:''save_5'', @save6:''save_6'', @save7:''save_7'', @save8:''save_8'', @save9:''save_9'', @save10:''save_10'', @isDisp:''is_disp'', @isDel:''is_del'', @userId:''user_id'', @upDate_Date:''up_date'', @regDate_Date:''reg_date''}"}, {"No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_coop_detail_1", "ctl_no": "2", "sqlCode": 9119, "@save3.speed": "$journal.detail.pat_coop_detail_1.pre_speed", "@save3.reserve": "$journal.detail.pat_coop_detail_1.pre_reserve", "@save3.item_code": "$journal.detail.pat_coop_detail_1.pre_item_code", "@save3.item_name": "$journal.detail.pat_coop_detail_1.pre_item_name", "@save3.speed_unit": "$journal.detail.pat_coop_detail_1.pre_speed_unit", "@save3.usage_unit": "$journal.detail.pat_coop_detail_1.pre_usage_unit", "@save3.item_number": "$journal.detail.pat_coop_detail_1.pre_item_number", "@save3.comment_type": "$journal.detail.pat_coop_detail_2.pre_comment_type", "@save3.free_comment": "$journal.detail.pat_coop_detail_1.pre_free_comment", "@save3.usage_amount": "$journal.detail.pat_coop_detail_1.pre_usage_amount", "@save3.function_code": "$journal.detail.pat_coop_detail_1.pre_function_code", "@save3.comment_code_1": "$journal.detail.pat_coop_detail_1.pre_comment_code_1", "@save3.comment_code_2": "$journal.detail.pat_coop_detail_1.pre_comment_code_2", "@save3.comment_code_3": "$journal.detail.pat_coop_detail_1.pre_comment_code_3", "@save3.comment_name_1": "$journal.detail.pat_coop_detail_1.pre_comment_name_1", "@save3.comment_name_2": "$journal.detail.pat_coop_detail_1.pre_comment_name_2", "@save3.comment_name_3": "$journal.detail.pat_coop_detail_1.pre_comment_name_3", "@save3.comment_number": "$journal.detail.pat_coop_detail_2.pre_comment_number", "@save3.interface_flag": "$journal.detail.pat_coop_detail_1.pre_interface_flag", "@save3.addition_pat_cd": "$journal.detail.pat_coop_detail_1.addition_pat_cd", "@save3.comment_content": "$journal.detail.pat_coop_detail_2.pre_comment_content", "@save3.item_comment_cd": "$journal.detail.pat_coop_detail_1.item_comment_cd", "@save3.item_generation": "$journal.detail.pat_coop_detail_1.pre_item_generation", "@save3.speed_unit_name": "$journal.detail.pat_coop_detail_1.pre_speed_unit_name", "@save3.usage_unit_name": "$journal.detail.pat_coop_detail_1.pre_usage_unit_name", "@save3.addition_other_cd": "$journal.detail.pat_coop_detail_1.addition_other_cd", "@save3.dialysis_cmt_1_cd": "$journal.detail.pat_coop_detail_1.dialysis_cmt_1_cd", "@save3.dialysis_cmt_2_cd": "$journal.detail.pat_coop_detail_1.dialysis_cmt_2_cd", "@save3.dialysis_cmt_3_cd": "$journal.detail.pat_coop_detail_1.dialysis_cmt_3_cd", "@save3.comment_generation_1": "$journal.detail.pat_coop_detail_1.pre_comment_generation_1", "@save3.comment_generation_2": "$journal.detail.pat_coop_detail_1.pre_comment_generation_2", "@save3.comment_generation_3": "$journal.detail.pat_coop_detail_1.pre_comment_generation_3", "@save3.addition_pat_generation_no": "$journal.detail.pat_coop_detail_1.addition_pat_generation_no", "@save3.item_comment_generation_no": "$journal.detail.pat_coop_detail_1.item_comment_generation_no", "@save3.addition_other_generation_no": "$journal.detail.pat_coop_detail_1.addition_other_generation_no", "@save3.dialysis_cmt_1_generation_no": "$journal.detail.pat_coop_detail_1.dialysis_cmt_1_generation_no", "@save3.dialysis_cmt_2_generation_no": "$journal.detail.pat_coop_detail_1.dialysis_cmt_2_generation_no", "@save3.dialysis_cmt_3_generation_no": "$journal.detail.pat_coop_detail_1.dialysis_cmt_3_generation_no"}], "sqlGroup10": [{"No1": "指示情報→登録・更新", "No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_coop_detail", "ctl_no": "1", "sqlCode": 9111, "updateResult": "{@coopSaveNo:''coop_save_no'', @facilityCd:''facility_cd'', @patId:''pat_id'', @save1:''save_1'', @save2:''save_2'', @save3Flg:'''', @save3Value:''save_3'', @save3.addition_pat_cd:'''', @save3.addition_other_cd:'''', @save3.item_comment_cd:'''', @save3.dialysis_cmt_1_cd:'''', @save3.dialysis_cmt_2_cd:'''', @save3.dialysis_cmt_3_cd:'''', @save3.addition_pat_generation_no:'''', @save3.addition_other_generation_no:'''', @save3.item_comment_generation_no:'''', @save3.dialysis_cmt_1_generation_no:'''', @save3.dialysis_cmt_2_generation_no:'''', @save3.dialysis_cmt_3_generation_no:'''', @save4:''save_4'', @save5:''save_5'', @save6:''save_6'', @save7:''save_7'', @save8:''save_8'', @save9:''save_9'', @save10:''save_10'', @isDisp:''is_disp'', @isDel:''is_del'', @userId:''user_id'', @upDate_Date:''up_date'', @regDate_Date:''reg_date''}"}, {"No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_coop_detail_2", "ctl_no": "2", "sqlCode": -600114, "@save3.comment_type": "$journal.detail.pat_coop_detail_2.pre_comment_type", "@save3.comment_number": "$journal.detail.pat_coop_detail_2.pre_comment_number", "@save3.comment_content": "$journal.detail.pat_coop_detail_2.pre_comment_content"}], "sqlGroup11": [{"No1": "患者情報→削除→更新", "No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": -600109, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@save2.ordNo": "$journal.pat_coop_detail.ord_no", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_personal_main", "ctl_no": "2", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -600015, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "1", "@severityCd": "$journal.pat_personal_main.severity_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@transportCd": "$journal.pat_personal_main.transport_cd", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}], "sqlGroup12": [{"No1": "患者情報→削除→更新", "No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "No3": "NEC場合、病棟コードより、[入外区分]を更新する。病棟コードが空白の場合は「入外区分 = 外来」で登録、空白でない場合は「入外区分 = 入院」で登録します。", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": -600109, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@save2.ordNo": "$journal.pat_coop_detail.ord_no", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "No3": "NEC場合、[入外区分]の更新処理、pat_personal_mainを更新する。または、pat_mainから、データを取得する。tableにpat_mainを設定しました。", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_main", "ctl_no": "2", "sqlCode": 9101, "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd"}], "sqlGroup13": [{"No1": "患者情報→削除→更新", "No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "No3": "NEC場合、[死亡患者、連絡先情報、透析困難情報]を更新する。", "No4": "死亡退院日が空白の場合は「死亡患者 = 対象外」で登録、空白でない場合は「死亡患者 = 対象」で登録します。", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": -600109, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@save2.ordNo": "$journal.pat_coop_detail.ord_no", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_personal_main", "ctl_no": "2", "sqlCode": 9103, "@otherContactInfo.tel1": "$journal.pat_personal_main.other_contact_info.tel1", "@otherContactInfo.zipCd": "$journal.pat_personal_main.other_contact_info.zip_cd", "@otherContactInfo.address": "$journal.pat_personal_main.other_contact_info.address", "@otherContactInfo.patName": "$journal.pat_personal_main.pat_name", "@otherContactInfo.patNameKana": "$journal.pat_personal_main.pat_name_kana"}], "sqlGroup14": [{"No1": "患者情報→削除→更新", "No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_main", "ctl_no": "1", "sqlCode": -600110, "@save2.ordNo": "$journal.pat_coop_detail.ord_no", "insertResult": "{@patId:'''',@facilityCd:'''',@isSame:'''',@isImplant:'''',@isInfect:'''',@isDiabetes:'''',@isBloodSugerExam:'''',@inOutCurrentState:'''',@inOutPlanState:'''',@inOutPlanDate_Date:'''',@patMemoInfoValue:''[]'',@additionInfoValue:''[]'',@chargeStaffInfoValue:''[]'',@patGroupInfoValue:''[]'',@tabooAllergyInfoValue:''[]'',@infectInfoValue:''[]'',@implantInfoValue:''[]'',@tareInfoValue:''{}'',@offWaterInfoValue:''{}'',@deviceSetInfoValue:''{}'',@acceptanceStatusInfoValue:''[]'',@isWheelChair:'''',@medicalCareInfoFlg:'''',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:'''',@schExtStatus:'''',@cardIdm:'''',@oldUpDate_Date:''''}", "updateResult": "{@patId:''pat_id'',@facilityCd:''facility_cd'',@isSame:''is_same'',@isImplant:''is_implant'',@isInfect:''is_infect'',@isDiabetes:''is_diabetes'',@isBloodSugerExam:''is_blood_suger_exam'',@inOutCurrentState:''in_out_current_state'',@inOutPlanState:''in_out_plan_state'',@inOutPlanDate_Date:''in_out_plan_date'',@patMemoInfoValue:''pat_memo_info'',@additionInfoValue:''addition_info'',@chargeStaffInfoValue:''charge_staff_info'',@patGroupInfoValue:''pat_group_info'',@tabooAllergyInfoValue:''taboo_allergy_info'',@infectInfoValue:''infect_info'',@implantInfoValue:''implant_info'',@tareInfoValue:''tare_info'',@offWaterInfoValue:''off_water_info'',@deviceSetInfoValue:''device_set_info'',@acceptanceStatusInfoValue:''acceptance_status_info'',@isWheelChair:''is_wheel_chair'',@medicalCareInfoFlg:'''',@medicalCareInfoValue:''medical_care_info'',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:''sch_ext_end_date'',@schExtStatus:''sch_ext_status'',@cardIdm:''card_idm'',@oldUpDate_Date:''old_up_date''}"}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_main", "ctl_no": "2", "sqlCode": -600016, "@inOutClass": "1", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}], "sqlGroup15": [{"No1": "患者情報→削除→更新", "No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_main", "ctl_no": "1", "sqlCode": -600110, "@save2.ordNo": "$journal.pat_coop_detail.ord_no"}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_main", "ctl_no": "2", "sqlCode": 9105, "@infectInfo1": "$journal.pat_main.infect_info1", "@infectInfo2": "$journal.pat_main.infect_info2", "@infectInfo3": "$journal.pat_main.infect_info3", "@infectInfo4": "$journal.pat_main.infect_info4", "@infectInfo5": "$journal.pat_main.infect_info5", "@infectInfo6": "$journal.pat_main.infect_info6", "@infectInfo7": "$journal.pat_main.infect_info7", "@infectInfo8": "$journal.pat_main.infect_info8", "@infectInfo9": "$journal.pat_main.infect_info9", "@infectInfo10": "$journal.pat_main.infect_info10", "@infectInfo11": "$journal.pat_main.infect_info11", "@infectInfo12": "$journal.pat_main.infect_info12", "@infectInfo13": "$journal.pat_main.infect_info13", "@infectInfo14": "$journal.pat_main.infect_info14", "@infectInfo15": "$journal.pat_main.infect_info15", "@infectInfo16": "$journal.pat_main.infect_info16", "@infectInfo17": "$journal.pat_main.infect_info17", "@infectInfo18": "$journal.pat_main.infect_info18", "@infectInfo19": "$journal.pat_main.infect_info19", "@infectInfo20": "$journal.pat_main.infect_info20", "@tabooAllergyInfo": "$journal.pat_main.taboo_allergy_info", "@chargeStaffInfo.staffCd": "$journal.pat_main.charge_staff_info.staff_cd"}], "sqlGroup16": [{"No1": "患者情報→削除→更新", "No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_unique", "ctl_no": "1", "sqlCode": -600111, "@save2.ordNo": "$journal.pat_coop_detail.ord_no", "insertResult": "{@patId:'''', @facilityCd:'''', @medicalHstInfoValue:''[]'', @inOutVisitHistoryInfoValue:''[]'', @physicalInfoFlg:'''', @physicalInfoValue:''[]''}"}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_unique", "ctl_no": "3", "sqlCode": 9107, "@physicalInfo.dw": "$journal.pat_unique.physical_info.dw", "@physicalInfo.height": "$journal.pat_unique.physical_info.height", "@physicalInfo.ctrWeight": "$journal.pat_unique.physical_info.ctr_weight", "@physicalInfo.orderClass": "1"}], "sqlGroup17": [{"No1": "指示情報→登録・更新", "No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_coop_detail", "ctl_no": "1", "sqlCode": 9111, "insertResult": "{@coopSaveNo:'''', @facilityCd:'''', @patId:'''', @save1:'''', @save1Flg:'''', @save2Flg:'''', @save2.ord_no:'''', @save2.instruction_doctor_generation_no:'''', @save2.dialysis_type:'''', @save2.dialysis_course:'''', @save2.dialysis_pattern:'''', @save2.start_date_regular:'''', @save2.end_date_regular:'''', @save2.implementation_place:'''', @save2.update_terminal:'''', @save2.addition_generation_no:'''', @save2.blood_purification_method:'''', @save2.blood_purification_generation_no:'''', @save2.updater:'''', @save2.updater_generation_no:'''', @save3:'''', @save4:'''', @save5:'''', @save6:'''', @save7:'''', @save8:'''', @save9:'''', @save10:'''', @isDisp:'''', @isDel:'''', @userId:'''', @upDate_Date:'''', @regDate_Date:''''}", "updateResult": "{@coopSaveNo:''coop_save_no'', @facilityCd:''facility_cd'', @patId:''pat_id'', @save1Value:''save_1'', @save1Flg:'''', @save2Flg:'''', @save2Value:''save_2'', @save2.ord_no:'''', @save2.instruction_doctor_generation_no:'''', @save2.dialysis_type:'''', @save2.dialysis_course:'''', @save2.dialysis_pattern:'''', @save2.start_date_regular:'''', @save2.end_date_regular:'''', @save2.implementation_place:'''', @save2.update_terminal:'''', @save2.addition_generation_no:'''', @save2.blood_purification_method:'''', @save2.blood_purification_generation_no:'''', @save2.updater:'''', @save2.updater_generation_no:'''', @save3:''save_3'', @save4:''save_4'', @save5:''save_5'', @save6:''save_6'', @save7:''save_7'', @save8:''save_8'', @save9:''save_9'', @save10:''save_10'', @isDisp:''is_disp'', @isDel:''is_del'', @userId:''user_id'', @upDate_Date:''up_date'', @regDate_Date:''reg_date''}"}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_coop_detail", "ctl_no": "3", "sqlCode": -600107, "@save2.ordNo": "$journal.pat_coop_detail.ord_no"}], "sqlGroup18": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "患者死亡退院情報連携", "No3": "患者の状態を『死亡』として、患者情報を登録します。", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "@isDie": "0", "ctl_no": "2", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -600013, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "2", "@severityCd": "$journal.pat_personal_main.severity_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@transportCd": "$journal.pat_personal_main.transport_cd", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}], "sqlGroup19": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "No3": "NEC場合、[死亡患者、連絡先情報、透析困難情報]を更新する。", "No4": "死亡退院日が空白の場合は「死亡患者 = 対象外」で登録、空白でない場合は「死亡患者 = 対象」で登録します。", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}, {"No2": "患者死亡退院情報連携", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "2", "sqlCode": 9102}, {"No2": "患者死亡退院情報連携", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "3", "sqlCode": 9103, "@otherContactInfo.tel1": "$journal.pat_personal_main.other_contact_info.tel1", "@otherContactInfo.zipCd": "$journal.pat_personal_main.other_contact_info.zip_cd", "@otherContactInfo.address": "$journal.pat_personal_main.other_contact_info.address", "@otherContactInfo.patName": "$journal.pat_personal_main.pat_name", "@otherContactInfo.patNameKana": "$journal.pat_personal_main.pat_name_kana"}], "sqlGroup20": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201, "insertResult": "{@patId:'''',@facilityCd:'''',@isSame:'''',@isImplant:'''',@isInfect:'''',@isDiabetes:'''',@isBloodSugerExam:'''',@inOutCurrentState:'''',@inOutPlanState:'''',@inOutPlanDate_Date:'''',@patMemoInfoValue:''[]'',@additionInfoValue:''[]'',@chargeStaffInfoValue:''[]'',@patGroupInfoValue:''[]'',@tabooAllergyInfoValue:''[]'',@infectInfoValue:''[]'',@implantInfoValue:''[]'',@tareInfoValue:''{}'',@offWaterInfoValue:''{}'',@deviceSetInfoValue:''{}'',@acceptanceStatusInfoValue:''[]'',@isWheelChair:'''',@medicalCareInfoFlg:'''',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:'''',@schExtStatus:'''',@cardIdm:'''',@oldUpDate_Date:''''}", "updateResult": "{@patId:''pat_id'',@facilityCd:''facility_cd'',@isSame:''is_same'',@isImplant:''is_implant'',@isInfect:''is_infect'',@isDiabetes:''is_diabetes'',@isBloodSugerExam:''is_blood_suger_exam'',@inOutCurrentState:''in_out_current_state'',@inOutPlanState:''in_out_plan_state'',@inOutPlanDate_Date:''in_out_plan_date'',@patMemoInfoValue:''pat_memo_info'',@additionInfoValue:''addition_info'',@chargeStaffInfoValue:''charge_staff_info'',@patGroupInfoValue:''pat_group_info'',@tabooAllergyInfoValue:''taboo_allergy_info'',@infectInfoValue:''infect_info'',@implantInfoValue:''implant_info'',@tareInfoValue:''tare_info'',@offWaterInfoValue:''off_water_info'',@deviceSetInfoValue:''device_set_info'',@acceptanceStatusInfoValue:''acceptance_status_info'',@isWheelChair:''is_wheel_chair'',@medicalCareInfoFlg:'''',@medicalCareInfoValue:''medical_care_info'',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:''sch_ext_end_date'',@schExtStatus:''sch_ext_status'',@cardIdm:''card_idm'',@oldUpDate_Date:''old_up_date''}"}, {"No2": "患者死亡退院情報連携", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "2", "sqlCode": -600014, "@inOutClass": "1", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}, {"No2": "患者死亡退院情報連携", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "3", "sqlCode": -600016, "@inOutClass": "1", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}], "sqlGroup21": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201}, {"No2": "患者死亡退院情報連携", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "2", "sqlCode": 9104}, {"No2": "患者死亡退院情報連携", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "3", "sqlCode": 9105, "@infectInfo1": "$journal.pat_main.infect_info1", "@infectInfo2": "$journal.pat_main.infect_info2", "@infectInfo3": "$journal.pat_main.infect_info3", "@infectInfo4": "$journal.pat_main.infect_info4", "@infectInfo5": "$journal.pat_main.infect_info5", "@infectInfo6": "$journal.pat_main.infect_info6", "@infectInfo7": "$journal.pat_main.infect_info7", "@infectInfo8": "$journal.pat_main.infect_info8", "@infectInfo9": "$journal.pat_main.infect_info9", "@infectInfo10": "$journal.pat_main.infect_info10", "@infectInfo11": "$journal.pat_main.infect_info11", "@infectInfo12": "$journal.pat_main.infect_info12", "@infectInfo13": "$journal.pat_main.infect_info13", "@infectInfo14": "$journal.pat_main.infect_info14", "@infectInfo15": "$journal.pat_main.infect_info15", "@infectInfo16": "$journal.pat_main.infect_info16", "@infectInfo17": "$journal.pat_main.infect_info17", "@infectInfo18": "$journal.pat_main.infect_info18", "@infectInfo19": "$journal.pat_main.infect_info19", "@infectInfo20": "$journal.pat_main.infect_info20", "@tabooAllergyInfo": "$journal.pat_main.taboo_allergy_info", "@chargeStaffInfo.staffCd": "$journal.pat_main.charge_staff_info.staff_cd"}], "sqlGroup22": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_unique", "ctl_no": "1", "sqlCode": 1601, "insertResult": "{@patId:'''', @facilityCd:'''', @medicalHstInfoValue:''[]'', @inOutVisitHistoryInfoValue:''[]'', @physicalInfoFlg:'''', @physicalInfoValue:''[]''}"}, {"No2": "患者死亡退院情報連携", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_unique", "ctl_no": "2", "sqlCode": 9106, "@physicalInfo.dw": "$journal.pat_unique.physical_info.dw", "@physicalInfo.height": "$journal.pat_unique.physical_info.height", "@physicalInfo.ctrWeight": "$journal.pat_unique.physical_info.ctr_weight", "@physicalInfo.orderClass": "1"}], "sqlGroup23": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "患者死亡退院情報連携", "No3": "患者情報更新", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "3", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -600015, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "1", "@severityCd": "$journal.pat_personal_main.severity_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@transportCd": "$journal.pat_personal_main.transport_cd", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}], "sqlGroup24": [{"No1": "患者イベント→登録", "No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_event", "ctl_no": "1", "sqlCode": -600112, "insertResult": "{@facilityCd:'''', @patId:''''}"}, {"No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_event", "ctl_no": "2", "sqlCode": -600113, "@dispUserId": "$journal.pat_main.charge_staff_info.staff_cd", "@save2.ordNo": "$journal.pat_coop_detail.ord_no"}], "sqlGroup25": [{"No1": "患者情報→登録・更新", "No2": "連携共通", "crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "連携共通", "No3": "患者の状態を『存命』から『死亡』に変更します。", "crud": "U", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "3", "sqlCode": -600105, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@dieDate_Date": "$journal.pat_personal_main.die_date"}]}, "CoopIniConvUtil": {"$journal.pat_personal_main.pat_sex": "CONV_SEX_TO_FNW", "$journal.pat_personal_main.pat_blood_type_rh": "CONV_BLOOD_RH_TO_FNW", "$journal.pat_personal_main.pat_blood_type_abo": "CONV_BLOOD_ABO_TO_FNW"}}'::jsonb, '1', '0', -1, '2019-12-13 05:44:54.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010002, 'N_hosp', 'ini_dial', '', 'R', '初回指示情報', 'text', 'NEC想定透析初回指示', 'MEGA', '初回指示情報ver1/Standard', '1', '<root name="透析申込(初回指示情報ver1)">
  <item name="空白" len="20" type="string"/>
  <item name="電文長" len="12" type="string"/>
  <item name="コマンド名" len="8" type="string" col="$journal.const.command_name" value="const:C-DIRECTVer1"/>
  <item name="処理区分" len="1" col="$journal.const.crud" type="string" value="json:{&quot;A&quot;:&quot;C&quot;,&quot;D&quot;:&quot;D&quot;,&quot;U&quot;:&quot;U&quot;,&quot;Z&quot;:&quot;Z&quot;}"/>
  <item name="病院コード" len="2" type="string"/>
  <item name="患者情報.患者番号" len="10" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
  <item name="患者情報.患者氏名" len="40" col="$journal.pat_personal_main.pat_name" type="string"/>
  <item name="患者情報.患者カナ氏名" len="20" col="$journal.pat_personal_main.pat_name_kana" type="string"/>
  <item name="患者情報.性別" len="1" col="$journal.pat_personal_main.pat_sex" type="string"/>
  <item name="患者情報.生年月日" len="8" col="$journal.pat_personal_main.pat_birthday" type="string"/>
  <item name="患者情報.郵便番号１" len="7" col="$journal.pat_personal_main.pat_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所１" len="100" col="$journal.pat_personal_main.pat_contact_info.address" type="string"/>
  <item name="患者情報.電話番号１" len="12" col="$journal.pat_personal_main.pat_contact_info.tel1" type="string"/>
  <item name="患者情報.郵便番号２" len="7" col="$journal.pat_personal_main.other_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所２" len="100" col="$journal.pat_personal_main.other_contact_info.address" type="string"/>
  <item name="患者情報.電話番号２" len="12" col="$journal.pat_personal_main.other_contact_info.tel1" type="string"/>
  <item name="病棟コード" len="4" col="$journal.pat_main.medical_care_info.ward_cd" type="string"/>
  <item name="病棟名称" len="20" type="string" info="対象外"/>
  <item name="病室コード" len="4" type="string" info="対象外"/>
  <item name="病室名称" len="20" type="string" info="対象外"/>
  <item name="看護区分" len="2" type="string" info="対象外"/>
  <item name="患者区分" len="2" col="$journal.pat_personal_main.severity_cd" type="string"/>
  <item name="救護区分" len="2" col="$journal.pat_personal_main.transport_cd" type="string"/>
  <item name="予備区分" len="1" type="string" info="対象外"/>
  <item name="障害情報" len="15" type="string" info="対象外"/>
  <item name="身長" len="5" col="$journal.pat_unique.physical_info.height" type="string" info="対象外"/>
  <item name="体重" len="5" col="$journal.pat_unique.physical_info.ctr_weight" type="string" info="対象外"/>
  <item name="血液型ＡＢＯ" len="1" col="$journal.pat_personal_main.pat_blood_type_abo" type="string"/>
  <item name="血液型Ｒｈ" len="1" col="$journal.pat_personal_main.pat_blood_type_rh" type="string"/>
  <item name="感染情報1" len="1" col="$journal.pat_main.infect_info1" type="string" info="1バイトのフラグ"/>
  <item name="感染情報2" len="1" col="$journal.pat_main.infect_info2" type="string" info="1バイトのフラグ"/>
  <item name="感染情報3" len="1" col="$journal.pat_main.infect_info3" type="string" info="1バイトのフラグ"/>
  <item name="感染情報4" len="1" col="$journal.pat_main.infect_info4" type="string" info="1バイトのフラグ"/>
  <item name="感染情報5" len="1" col="$journal.pat_main.infect_info5" type="string" info="1バイトのフラグ"/>
  <item name="感染情報6" len="1" col="$journal.pat_main.infect_info6" type="string" info="1バイトのフラグ"/>
  <item name="感染情報7" len="1" col="$journal.pat_main.infect_info7" type="string" info="1バイトのフラグ"/>
  <item name="感染情報8" len="1" col="$journal.pat_main.infect_info8" type="string" info="1バイトのフラグ"/>
  <item name="感染情報9" len="1" col="$journal.pat_main.infect_info9" type="string" info="1バイトのフラグ"/>
  <item name="感染情報10" len="1" col="$journal.pat_main.infect_info10" type="string" info="1バイトのフラグ"/>
  <item name="感染情報11" len="1" col="$journal.pat_main.infect_info11" type="string" info="1バイトのフラグ"/>
  <item name="感染情報12" len="1" col="$journal.pat_main.infect_info12" type="string" info="1バイトのフラグ"/>
  <item name="感染情報13" len="1" col="$journal.pat_main.infect_info13" type="string" info="1バイトのフラグ"/>
  <item name="感染情報14" len="1" col="$journal.pat_main.infect_info14" type="string" info="1バイトのフラグ"/>
  <item name="感染情報15" len="1" col="$journal.pat_main.infect_info15" type="string" info="1バイトのフラグ"/>
  <item name="感染情報16" len="1" col="$journal.pat_main.infect_info16" type="string" info="1バイトのフラグ"/>
  <item name="感染情報17" len="1" col="$journal.pat_main.infect_info17" type="string" info="1バイトのフラグ"/>
  <item name="感染情報18" len="1" col="$journal.pat_main.infect_info18" type="string" info="1バイトのフラグ"/>
  <item name="感染情報19" len="1" col="$journal.pat_main.infect_info19" type="string" info="1バイトのフラグ"/>
  <item name="感染情報20" len="1" col="$journal.pat_main.infect_info20" type="string" info="1バイトのフラグ"/>
  <item name="感染コメント" len="60" type="string" info="対象外"/>
  <item name="薬剤禁忌情報" len="20" col="$journal.pat_main.taboo_allergy_info" type="string" info="20バイトのフラグ"/>
  <item name="禁忌コメント" len="60" type="string"/>
  <item name="妊娠日" len="8" type="string" info="対象外"/>
  <item name="死亡退院日" len="8" col="$journal.pat_personal_main.die_date" type="string"/>
  <item name="予備" len="30" type="string" info="対象外"/>
  <item name="オーダ番号" len="16" col="$journal.pat_coop_detail.ord_no" type="string"/>
  <item name="情報区分" len="1" type="string"/>
  <item name="指示科" len="2" col="$journal.pat_main.medical_care_info.main_course_cd" type="string"/>
  <item name="指示科名称" len="20" type="string" info="対象外"/>
  <item name="指示医" len="10" col="$journal.pat_main.charge_staff_info.staff_cd" type="string"/>
  <item name="指示医名称" len="20" type="string"/>
  <item name="指示医世代番号" len="1" col="$journal.pat_coop_detail.instruction_doctor_generation_no" type="string"/>
  <item name="保険コード01" len="3" col="$journal.pat_insurance_1.coop_code" type="string"/>
  <item name="保険コード02" len="3" col="$journal.pat_insurance_2.coop_code" type="string"/>
  <item name="保険コード03" len="3" col="$journal.pat_insurance_3.coop_code" type="string"/>
  <item name="保険コード04" len="3" col="$journal.pat_insurance_4.coop_code" type="string" info="対象外"/>
  <item name="保険コード05" len="3" col="$journal.pat_insurance_5.coop_code" type="string" info="対象外"/>
  <item name="透析種別" len="1" col="$journal.pat_coop_detail.dialysis_type" type="string" info="対象外"/>
  <item name="透析コース" len="6" col="$journal.pat_coop_detail.dialysis_course" type="string" info="対象外"/>
  <item name="透析コース名称" len="60" type="string" info="対象外"/>
  <item name="透析パターン" len="6" col="$journal.pat_coop_detail.dialysis_pattern" type="string"/>
  <item name="透析パターン名称" len="60" type="string" info="対象外"/>
  <item name="開始日（定期）" len="8" col="$journal.pat_coop_detail.start_date_regular" type="string"/>
  <item name="終了日（定期）" len="8" col="$journal.pat_coop_detail.end_date_regular" type="string"/>
  <item name="透析日１（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日２（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日３（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日４（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日５（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日６（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日７（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日８（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日９（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日１０（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日１１（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日１２（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日１３（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日１４（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日１５（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析導入日" len="8" col="$journal.pat_main.medical_care_info.dialysis_start_date" type="string"/>
  <item name="実施場所" len="6" col="$journal.pat_coop_detail.implementation_place" type="string"/>
  <item name="実施場所名称" len="60" type="string" info="対象外"/>
  <item name="加算（患者に付随する加算）" len="6" col="$journal.pat_personal_main.dial_diff_com_info.dial_diff_cd" type="string"/>
  <item name="加算世代番号" len="1" col="$journal.pat_coop_detail.addition_generation_no" type="string"/>
  <item name="加算名称" len="60" type="string" info="対象外"/>
  <item name="ベッド予約番号" len="13" type="string" info="対象外"/>
  <item name="使用ベッド" len="6" type="string" info="対象外"/>
  <item name="使用ベッド名称" len="60" type="string" info="対象外"/>
  <item name="ベッド予約時間帯" len="1" col="$journal.pat_coop_detail.kur_cd1" type="string" info="対象外"/>
  <item name="ブラッドアクセス" len="6" col="$journal.pat_coop_detail.va3" type="string"/>
  <item name="ブラッドアクセス名称" len="60" type="string"/>
  <item name="部位" len="6" col="$journal.pat_coop_detail.va_direct" type="string"/>
  <item name="部位名称" len="60" type="string" info="対象外"/>
  <item name="ＤＷ" len="4" col="$journal.pat_coop_detail.dw" type="string"/>
  <item name="血液浄化法" len="6" col="$journal.pat_coop_detail.blood_purification_method" type="string"/>
  <item name="血液浄化法世代番号" len="1" col="$journal.pat_coop_detail.blood_purification_generation_no" type="string"/>
  <item name="血液浄化法名称" len="60" type="string"/>
  <item name="依頼オーダ番号" len="16" type="string" info="対象外"/>
  <item name="実施オーダ番号" len="16" type="string" info="対象外"/>
  <item name="進捗" len="2" type="string" info="対象外"/>
  <item name="血液浄化方法　医事コード" len="6" type="string" info="対象外"/>
  <item name="血液浄化方法　医事世代コード" len="1" type="string" info="対象外"/>
  <item name="新規登録日" len="8" type="string" info="対象外"/>
  <item name="新規登録時間" len="6" type="string" info="対象外"/>
  <item name="更新日" len="8" type="string" info="対象外"/>
  <item name="更新時間" len="6" type="string" info="対象外"/>
  <item name="更新端末" len="10" col="$journal.pat_coop_detail.update_terminal" type="string"/>
  <item name="更新者" len="10" col="$journal.pat_coop_detail.updater" type="string"/>
  <item name="更新者世代番号" len="1" col="$journal.pat_coop_detail.updater_generation_no" type="string"/>
  <item name="予備" len="30" type="string" info="対象外"/>
  <occ name="オーダ指示詳細数" len="5" col="$journal.detail_number" type="string" detail="透析指示オーダ明細"/>
  <occ name="オーダ指示コメント数" len="5" col="$journal.comment_number" type="string" detail="透析コメント明細"/>
</root>
', '{"json-key": {"{\"A\":\"C\",\"D\":\"D\",\"U\":\"U\",\"Z\":\"Z\"}": {"A": "C", "D": "D", "U": "U", "Z": "Z"}}}'::jsonb, '1', '0', -1, '2019-12-13 05:44:54.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010003, 'N_hosp', 'ini_dial', '', 'R', '初回指示情報', 'text', 'NEC想定透析初回指示', 'MEGA', '初回指示情報ver2/TSHPlus', '1', '<root name="透析申込(初回指示情報ver2)">
  <item name="コマンド名" len="8" type="string" col="$journal.const.command_name" value="const:C-DIRECTVer2"/>
  <item name="処理区分" len="1" type="string" col="$journal.const.crud" value="const:C"/>
  <item name="病院コード" len="2" type="string"/>
  <item name="患者情報.患者番号" len="10" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
  <item name="患者情報.患者氏名" len="40" col="$journal.pat_personal_main.pat_name" type="string"/>
  <item name="患者情報.患者カナ氏名" len="20" col="$journal.pat_personal_main.pat_name_kana" type="string"/>
  <item name="患者情報.性別" len="1" col="$journal.pat_personal_main.pat_sex" type="string"/>
  <item name="患者情報.生年月日" len="8" col="$journal.pat_personal_main.pat_birthday" type="string"/>
  <item name="患者情報.郵便番号１" len="7" col="$journal.pat_personal_main.pat_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所１" len="100" col="$journal.pat_personal_main.pat_contact_info.address" type="string"/>
  <item name="患者情報.電話番号１" len="12" col="$journal.pat_personal_main.pat_contact_info.tel1" type="string"/>
  <item name="患者情報.郵便番号２" len="7" col="$journal.pat_personal_main.other_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所２" len="100" col="$journal.pat_personal_main.other_contact_info.address" type="string"/>
  <item name="患者情報.電話番号２" len="12" col="$journal.pat_personal_main.other_contact_info.tel1" type="string"/>
  <item name="病棟コード" len="4" col="$journal.pat_main.medical_care_info.ward_cd" type="string"/>
  <item name="病棟名称" len="20" type="string" info="対象外"/>
  <item name="病室コード" len="4" type="string" info="対象外"/>
  <item name="病室名称" len="20" type="string" info="対象外"/>
  <item name="看護区分" len="2" type="string" info="対象外"/>
  <item name="患者区分" len="2" col="$journal.pat_personal_main.severity_cd" type="string"/>
  <item name="救護区分" len="2" col="$journal.pat_personal_main.transport_cd" type="string"/>
  <item name="予備区分" len="1" type="string" info="対象外"/>
  <item name="障害情報" len="15" type="string" info="対象外"/>
  <item name="身長" len="5" col="$journal.pat_unique.physical_info.height" type="string" info="対象外"/>
  <item name="体重" len="5" col="$journal.pat_unique.physical_info.ctr_weight" type="string" info="対象外"/>
  <item name="血液型ＡＢＯ" len="1" col="$journal.pat_personal_main.pat_blood_type_abo" type="string"/>
  <item name="血液型Ｒｈ" len="1" col="$journal.pat_personal_main.pat_blood_type_rh" type="string"/>
  <item name="感染情報1" len="1" col="$journal.pat_main.infect_info1" type="string" info="1バイトのフラグ"/>
  <item name="感染情報2" len="1" col="$journal.pat_main.infect_info2" type="string" info="1バイトのフラグ"/>
  <item name="感染情報3" len="1" col="$journal.pat_main.infect_info3" type="string" info="1バイトのフラグ"/>
  <item name="感染情報4" len="1" col="$journal.pat_main.infect_info4" type="string" info="1バイトのフラグ"/>
  <item name="感染情報5" len="1" col="$journal.pat_main.infect_info5" type="string" info="1バイトのフラグ"/>
  <item name="感染情報6" len="1" col="$journal.pat_main.infect_info6" type="string" info="1バイトのフラグ"/>
  <item name="感染情報7" len="1" col="$journal.pat_main.infect_info7" type="string" info="1バイトのフラグ"/>
  <item name="感染情報8" len="1" col="$journal.pat_main.infect_info8" type="string" info="1バイトのフラグ"/>
  <item name="感染情報9" len="1" col="$journal.pat_main.infect_info9" type="string" info="1バイトのフラグ"/>
  <item name="感染情報10" len="1" col="$journal.pat_main.infect_info10" type="string" info="1バイトのフラグ"/>
  <item name="感染情報11" len="1" col="$journal.pat_main.infect_info11" type="string" info="1バイトのフラグ"/>
  <item name="感染情報12" len="1" col="$journal.pat_main.infect_info12" type="string" info="1バイトのフラグ"/>
  <item name="感染情報13" len="1" col="$journal.pat_main.infect_info13" type="string" info="1バイトのフラグ"/>
  <item name="感染情報14" len="1" col="$journal.pat_main.infect_info14" type="string" info="1バイトのフラグ"/>
  <item name="感染情報15" len="1" col="$journal.pat_main.infect_info15" type="string" info="1バイトのフラグ"/>
  <item name="感染情報16" len="1" col="$journal.pat_main.infect_info16" type="string" info="1バイトのフラグ"/>
  <item name="感染情報17" len="1" col="$journal.pat_main.infect_info17" type="string" info="1バイトのフラグ"/>
  <item name="感染情報18" len="1" col="$journal.pat_main.infect_info18" type="string" info="1バイトのフラグ"/>
  <item name="感染情報19" len="1" col="$journal.pat_main.infect_info19" type="string" info="1バイトのフラグ"/>
  <item name="感染情報20" len="1" col="$journal.pat_main.infect_info20" type="string" info="1バイトのフラグ"/>
  <item name="感染コメント" len="60" type="string" info="対象外"/>
  <item name="薬剤禁忌情報" len="20" col="$journal.pat_main.taboo_allergy_info" type="string" info="20バイトのフラグ"/>
  <item name="禁忌コメント" len="60" type="string"/>
  <item name="妊娠日" len="8" type="string" info="対象外"/>
  <item name="死亡退院日" len="8" col="$journal.pat_personal_main.die_date" type="string"/>
  <item name="予備" len="30" type="string" info="対象外"/>
</root>
', '{}'::jsonb, '1', '1', -1, '2019-12-13 05:44:54.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010004, 'N_hosp', 'ini_dial', '', 'R', '患者情報', 'text', 'NEC想定透析初回指示', 'MEGA', 'テスト用ver1/Standard', '1', '<root name="透析申込(患者情報)">
  <item name="空白" len="20" type="string"/>
  <item name="電文長" len="12" type="string"/>
  <item name="コマンド名" len="8" type="string" col="$journal.const.command_name" value="const:C-KNJUPD"/>
  <item name="処理区分" len="1" type="string" col="$journal.const.crud" value="const:C" info="患者情報・患者死亡退院場合、未使用。固定値「C」を設定しました。"/>
  <item name="病院コード" len="2" type="string"/>
  <item name="患者情報.患者番号" len="10" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
  <item name="患者情報.患者氏名" len="40" col="$journal.pat_personal_main.pat_name" type="string"/>
  <item name="患者情報.患者カナ氏名" len="20" col="$journal.pat_personal_main.pat_name_kana" type="string"/>
  <item name="患者情報.性別" len="1" col="$journal.pat_personal_main.pat_sex" type="string"/>
  <item name="患者情報.生年月日" len="8" col="$journal.pat_personal_main.pat_birthday" type="string"/>
  <item name="患者情報.郵便番号１" len="7" col="$journal.pat_personal_main.pat_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所１" len="100" col="$journal.pat_personal_main.pat_contact_info.address" type="string"/>
  <item name="患者情報.電話番号１" len="12" col="$journal.pat_personal_main.pat_contact_info.tel1" type="string"/>
  <item name="患者情報.郵便番号２" len="7" col="$journal.pat_personal_main.other_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所２" len="100" col="$journal.pat_personal_main.other_contact_info.address" type="string"/>
  <item name="患者情報.電話番号２" len="12" col="$journal.pat_personal_main.other_contact_info.tel1" type="string"/>
  <item name="病棟コード" len="4" col="$journal.pat_main.medical_care_info.ward_cd" type="string"/>
  <item name="病棟名称" len="20" type="string" info="対象外"/>
  <item name="病室コード" len="4" type="string" info="対象外"/>
  <item name="病室名称" len="20" type="string" info="対象外"/>
  <item name="看護区分" len="2" type="string" info="対象外"/>
  <item name="患者区分" len="2" col="$journal.pat_personal_main.severity_cd" type="string"/>
  <item name="救護区分" len="2" col="$journal.pat_personal_main.transport_cd" type="string"/>
  <item name="予備区分" len="1" type="string" info="対象外"/>
  <item name="障害情報" len="15" type="string" info="対象外"/>
  <item name="身長" len="5" col="$journal.pat_unique.physical_info.height" type="string" info="対象外"/>
  <item name="体重" len="5" col="$journal.pat_unique.physical_info.ctr_weight" type="string" info="対象外"/>
  <item name="血液型ＡＢＯ" len="1" col="$journal.pat_personal_main.pat_blood_type_abo" type="string"/>
  <item name="血液型Ｒｈ" len="1" col="$journal.pat_personal_main.pat_blood_type_rh" type="string"/>
  <item name="感染情報1" len="1" col="$journal.pat_main.infect_info1" type="string" info="1バイトのフラグ"/>
  <item name="感染情報2" len="1" col="$journal.pat_main.infect_info2" type="string" info="1バイトのフラグ"/>
  <item name="感染情報3" len="1" col="$journal.pat_main.infect_info3" type="string" info="1バイトのフラグ"/>
  <item name="感染情報4" len="1" col="$journal.pat_main.infect_info4" type="string" info="1バイトのフラグ"/>
  <item name="感染情報5" len="1" col="$journal.pat_main.infect_info5" type="string" info="1バイトのフラグ"/>
  <item name="感染情報6" len="1" col="$journal.pat_main.infect_info6" type="string" info="1バイトのフラグ"/>
  <item name="感染情報7" len="1" col="$journal.pat_main.infect_info7" type="string" info="1バイトのフラグ"/>
  <item name="感染情報8" len="1" col="$journal.pat_main.infect_info8" type="string" info="1バイトのフラグ"/>
  <item name="感染情報9" len="1" col="$journal.pat_main.infect_info9" type="string" info="1バイトのフラグ"/>
  <item name="感染情報10" len="1" col="$journal.pat_main.infect_info10" type="string" info="1バイトのフラグ"/>
  <item name="感染情報11" len="1" col="$journal.pat_main.infect_info11" type="string" info="1バイトのフラグ"/>
  <item name="感染情報12" len="1" col="$journal.pat_main.infect_info12" type="string" info="1バイトのフラグ"/>
  <item name="感染情報13" len="1" col="$journal.pat_main.infect_info13" type="string" info="1バイトのフラグ"/>
  <item name="感染情報14" len="1" col="$journal.pat_main.infect_info14" type="string" info="1バイトのフラグ"/>
  <item name="感染情報15" len="1" col="$journal.pat_main.infect_info15" type="string" info="1バイトのフラグ"/>
  <item name="感染情報16" len="1" col="$journal.pat_main.infect_info16" type="string" info="1バイトのフラグ"/>
  <item name="感染情報17" len="1" col="$journal.pat_main.infect_info17" type="string" info="1バイトのフラグ"/>
  <item name="感染情報18" len="1" col="$journal.pat_main.infect_info18" type="string" info="1バイトのフラグ"/>
  <item name="感染情報19" len="1" col="$journal.pat_main.infect_info19" type="string" info="1バイトのフラグ"/>
  <item name="感染情報20" len="1" col="$journal.pat_main.infect_info20" type="string" info="1バイトのフラグ"/>
  <item name="感染コメント" len="60" type="string" info="対象外"/>
  <item name="薬剤禁忌情報" len="20" col="$journal.pat_main.taboo_allergy_info" type="string" info="20バイトのフラグ"/>
  <item name="禁忌コメント" len="60" type="string"/>
  <item name="妊娠日" len="8" type="string" info="対象外"/>
  <item name="死亡退院日" len="8" col="$journal.pat_personal_main.die_date" type="string"/>
  <item name="予備" len="30" type="string" info="対象外"/>
</root>
', '{}'::jsonb, '1', '0', -1, '2019-12-13 05:44:54.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010005, 'N_hosp', 'ini_dial', '', 'R', '患者死亡退院情報', 'text', 'NEC想定透析初回指示', 'MEGA', 'テスト用ver1/Standard', '1', '<root name="透析申込(患者死亡退院情報)">
  <item name="空白" len="20" type="string"/>
  <item name="電文長" len="12" type="string"/>
  <item name="コマンド名" len="8" type="string" col="$journal.const.command_name" value="const:C-KNJDEL"/>
  <item name="処理区分" len="1" type="string" col="$journal.const.crud" value="const:C" info="患者情報・患者死亡退院場合、未使用。固定値「C」を設定しました。"/>
  <item name="病院コード" len="2" type="string"/>
  <item name="患者情報.患者番号" len="10" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
  <item name="患者情報.患者氏名" len="40" col="$journal.pat_personal_main.pat_name" type="string"/>
  <item name="患者情報.患者カナ氏名" len="20" col="$journal.pat_personal_main.pat_name_kana" type="string"/>
  <item name="患者情報.性別" len="1" col="$journal.pat_personal_main.pat_sex" type="string"/>
  <item name="患者情報.生年月日" len="8" col="$journal.pat_personal_main.pat_birthday" type="string"/>
  <item name="患者情報.郵便番号１" len="7" col="$journal.pat_personal_main.pat_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所１" len="100" col="$journal.pat_personal_main.pat_contact_info.address" type="string"/>
  <item name="患者情報.電話番号１" len="12" col="$journal.pat_personal_main.pat_contact_info.tel1" type="string"/>
  <item name="患者情報.郵便番号２" len="7" col="$journal.pat_personal_main.other_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所２" len="100" col="$journal.pat_personal_main.other_contact_info.address" type="string"/>
  <item name="患者情報.電話番号２" len="12" col="$journal.pat_personal_main.other_contact_info.tel1" type="string"/>
  <item name="病棟コード" len="4" col="$journal.pat_main.medical_care_info.ward_cd" type="string"/>
  <item name="病棟名称" len="20" type="string" info="対象外"/>
  <item name="病室コード" len="4" type="string" info="対象外"/>
  <item name="病室名称" len="20" type="string" info="対象外"/>
  <item name="看護区分" len="2" type="string" info="対象外"/>
  <item name="患者区分" len="2" col="$journal.pat_personal_main.severity_cd" type="string"/>
  <item name="救護区分" len="2" col="$journal.pat_personal_main.transport_cd" type="string"/>
  <item name="予備区分" len="1" type="string" info="対象外"/>
  <item name="障害情報" len="15" type="string" info="対象外"/>
  <item name="身長" len="5" col="$journal.pat_unique.physical_info.height" type="string" info="対象外"/>
  <item name="体重" len="5" col="$journal.pat_unique.physical_info.ctr_weight" type="string" info="対象外"/>
  <item name="血液型ＡＢＯ" len="1" col="$journal.pat_personal_main.pat_blood_type_abo" type="string"/>
  <item name="血液型Ｒｈ" len="1" col="$journal.pat_personal_main.pat_blood_type_rh" type="string"/>
  <item name="感染情報1" len="1" col="$journal.pat_main.infect_info1" type="string" info="1バイトのフラグ"/>
  <item name="感染情報2" len="1" col="$journal.pat_main.infect_info2" type="string" info="1バイトのフラグ"/>
  <item name="感染情報3" len="1" col="$journal.pat_main.infect_info3" type="string" info="1バイトのフラグ"/>
  <item name="感染情報4" len="1" col="$journal.pat_main.infect_info4" type="string" info="1バイトのフラグ"/>
  <item name="感染情報5" len="1" col="$journal.pat_main.infect_info5" type="string" info="1バイトのフラグ"/>
  <item name="感染情報6" len="1" col="$journal.pat_main.infect_info6" type="string" info="1バイトのフラグ"/>
  <item name="感染情報7" len="1" col="$journal.pat_main.infect_info7" type="string" info="1バイトのフラグ"/>
  <item name="感染情報8" len="1" col="$journal.pat_main.infect_info8" type="string" info="1バイトのフラグ"/>
  <item name="感染情報9" len="1" col="$journal.pat_main.infect_info9" type="string" info="1バイトのフラグ"/>
  <item name="感染情報10" len="1" col="$journal.pat_main.infect_info10" type="string" info="1バイトのフラグ"/>
  <item name="感染情報11" len="1" col="$journal.pat_main.infect_info11" type="string" info="1バイトのフラグ"/>
  <item name="感染情報12" len="1" col="$journal.pat_main.infect_info12" type="string" info="1バイトのフラグ"/>
  <item name="感染情報13" len="1" col="$journal.pat_main.infect_info13" type="string" info="1バイトのフラグ"/>
  <item name="感染情報14" len="1" col="$journal.pat_main.infect_info14" type="string" info="1バイトのフラグ"/>
  <item name="感染情報15" len="1" col="$journal.pat_main.infect_info15" type="string" info="1バイトのフラグ"/>
  <item name="感染情報16" len="1" col="$journal.pat_main.infect_info16" type="string" info="1バイトのフラグ"/>
  <item name="感染情報17" len="1" col="$journal.pat_main.infect_info17" type="string" info="1バイトのフラグ"/>
  <item name="感染情報18" len="1" col="$journal.pat_main.infect_info18" type="string" info="1バイトのフラグ"/>
  <item name="感染情報19" len="1" col="$journal.pat_main.infect_info19" type="string" info="1バイトのフラグ"/>
  <item name="感染情報20" len="1" col="$journal.pat_main.infect_info20" type="string" info="1バイトのフラグ"/>
  <item name="感染コメント" len="60" type="string" info="対象外"/>
  <item name="薬剤禁忌情報" len="20" col="$journal.pat_main.taboo_allergy_info" type="string" info="20バイトのフラグ"/>
  <item name="禁忌コメント" len="60" type="string"/>
  <item name="妊娠日" len="8" type="string" info="対象外"/>
  <item name="死亡退院日" len="8" col="$journal.pat_personal_main.die_date" type="string"/>
  <item name="予備" len="30" type="string" info="対象外"/>
</root>
', '{}'::jsonb, '1', '0', -1, '2019-12-13 05:44:54.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010006, 'N_hosp', 'ini_dial', '', 'R', 'pre', 'text', 'NEC想定透析初回指示', 'MEGA', 'テスト用ver2/TSHPlus', '1', '<root name="透析申込(pre)">
  <item name="コマンド名" len="8" type="string" key="command_name"/>
  <item name="処理区分" len="1" type="string"/>
  <item name="病院コード" len="2" type="string"/>
  <item name="患者情報.患者番号" len="10" type="string"/>
  <item name="患者情報.患者氏名" len="40" type="string"/>
  <item name="患者情報.患者カナ氏名" len="20" type="string"/>
  <item name="患者情報.性別" len="1" type="string"/>
  <item name="患者情報.生年月日" len="8" type="string"/>
  <item name="患者情報.郵便番号１" len="7" type="string"/>
  <item name="患者情報.患者住所１" len="100" type="string"/>
  <item name="患者情報.電話番号１" len="12" type="string"/>
  <item name="患者情報.郵便番号２" len="7" type="string"/>
  <item name="患者情報.患者住所２" len="100" type="string"/>
  <item name="患者情報.電話番号２" len="12" type="string"/>
  <item name="病棟コード" len="4" type="string"/>
  <item name="病棟名称" len="20" type="string"/>
  <item name="病室コード" len="4" type="string"/>
  <item name="病室名称" len="20" type="string"/>
  <item name="看護区分" len="2" type="string"/>
  <item name="患者区分" len="2" type="string"/>
  <item name="救護区分" len="2" type="string"/>
  <item name="予備区分" len="1" type="string"/>
  <item name="障害情報" len="15" type="string"/>
  <item name="身長" len="5" type="string"/>
  <item name="体重" len="5" type="string"/>
  <item name="血液型ＡＢＯ" len="1" type="string"/>
  <item name="血液型Ｒｈ" len="1" type="string"/>
  <item name="感染情報" len="20" type="string"/>
  <item name="感染コメント" len="60" type="string"/>
  <item name="薬剤禁忌情報" len="20" type="string"/>
  <item name="禁忌コメント" len="60" type="string"/>
  <item name="妊娠日" len="8" type="string"/>
  <item name="死亡退院日" len="8" type="string"/>
  <item name="予備" len="30" type="string"/>
</root>
', '{"key": {"command_name": {"C-DIRECT": "初回指示情報", "C-KNJDEL": "患者死亡退院情報", "C-KNJUPD": "患者情報"}}, "dataset": {"sqlGroup1": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "@isDie": "0", "ctl_no": "2", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -600013, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "1", "@severityCd": "$journal.pat_personal_main.severity_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@transportCd": "$journal.pat_personal_main.transport_cd", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "3", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -600015, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "1", "@severityCd": "$journal.pat_personal_main.severity_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@transportCd": "$journal.pat_personal_main.transport_cd", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}], "sqlGroup2": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "No3": "NEC場合、病棟コードより、[入外区分]を更新する。病棟コードが空白の場合は「入外区分 = 外来」で登録、空白でない場合は「入外区分 = 入院」で登録します。", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "No3": "NEC場合、[入外区分]の更新処理、pat_personal_mainを更新する。または、pat_mainから、データを取得する。tableにpat_mainを設定しました。", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "2", "sqlCode": 9101, "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd"}], "sqlGroup3": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "No3": "NEC場合、[死亡患者、連絡先情報、透析困難情報]を更新する。", "No4": "死亡退院日が空白の場合は「死亡患者 = 対象外」で登録、空白でない場合は「死亡患者 = 対象」で登録します。", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "2", "sqlCode": 9102}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "3", "sqlCode": 9103, "@otherContactInfo.tel1": "$journal.pat_personal_main.other_contact_info.tel1", "@otherContactInfo.zipCd": "$journal.pat_personal_main.other_contact_info.zip_cd", "@otherContactInfo.address": "$journal.pat_personal_main.other_contact_info.address", "@otherContactInfo.patName": "$journal.pat_personal_main.pat_name", "@otherContactInfo.patNameKana": "$journal.pat_personal_main.pat_name_kana"}], "sqlGroup4": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201, "insertResult": "{@patId:'''',@facilityCd:'''',@isSame:'''',@isImplant:'''',@isInfect:'''',@isDiabetes:'''',@isBloodSugerExam:'''',@inOutCurrentState:'''',@inOutPlanState:'''',@inOutPlanDate_Date:'''',@patMemoInfoValue:''[]'',@additionInfoValue:''[]'',@chargeStaffInfoValue:''[]'',@patGroupInfoValue:''[]'',@tabooAllergyInfoValue:''[]'',@infectInfoValue:''[]'',@implantInfoValue:''[]'',@tareInfoValue:''{}'',@offWaterInfoValue:''{}'',@deviceSetInfoValue:''{}'',@acceptanceStatusInfoValue:''[]'',@isWheelChair:'''',@medicalCareInfoFlg:'''',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:'''',@schExtStatus:'''',@cardIdm:'''',@oldUpDate_Date:''''}", "updateResult": "{@patId:''pat_id'',@facilityCd:''facility_cd'',@isSame:''is_same'',@isImplant:''is_implant'',@isInfect:''is_infect'',@isDiabetes:''is_diabetes'',@isBloodSugerExam:''is_blood_suger_exam'',@inOutCurrentState:''in_out_current_state'',@inOutPlanState:''in_out_plan_state'',@inOutPlanDate_Date:''in_out_plan_date'',@patMemoInfoValue:''pat_memo_info'',@additionInfoValue:''addition_info'',@chargeStaffInfoValue:''charge_staff_info'',@patGroupInfoValue:''pat_group_info'',@tabooAllergyInfoValue:''taboo_allergy_info'',@infectInfoValue:''infect_info'',@implantInfoValue:''implant_info'',@tareInfoValue:''tare_info'',@offWaterInfoValue:''off_water_info'',@deviceSetInfoValue:''device_set_info'',@acceptanceStatusInfoValue:''acceptance_status_info'',@isWheelChair:''is_wheel_chair'',@medicalCareInfoFlg:'''',@medicalCareInfoValue:''medical_care_info'',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:''sch_ext_end_date'',@schExtStatus:''sch_ext_status'',@cardIdm:''card_idm'',@oldUpDate_Date:''old_up_date''}"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "2", "sqlCode": -600014, "@inOutClass": "1", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "3", "sqlCode": -600016, "@inOutClass": "1", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}], "sqlGroup5": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "2", "sqlCode": 9104}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "3", "sqlCode": 9105, "@infectInfo1": "$journal.pat_main.infect_info1", "@infectInfo2": "$journal.pat_main.infect_info2", "@infectInfo3": "$journal.pat_main.infect_info3", "@infectInfo4": "$journal.pat_main.infect_info4", "@infectInfo5": "$journal.pat_main.infect_info5", "@infectInfo6": "$journal.pat_main.infect_info6", "@infectInfo7": "$journal.pat_main.infect_info7", "@infectInfo8": "$journal.pat_main.infect_info8", "@infectInfo9": "$journal.pat_main.infect_info9", "@infectInfo10": "$journal.pat_main.infect_info10", "@infectInfo11": "$journal.pat_main.infect_info11", "@infectInfo12": "$journal.pat_main.infect_info12", "@infectInfo13": "$journal.pat_main.infect_info13", "@infectInfo14": "$journal.pat_main.infect_info14", "@infectInfo15": "$journal.pat_main.infect_info15", "@infectInfo16": "$journal.pat_main.infect_info16", "@infectInfo17": "$journal.pat_main.infect_info17", "@infectInfo18": "$journal.pat_main.infect_info18", "@infectInfo19": "$journal.pat_main.infect_info19", "@infectInfo20": "$journal.pat_main.infect_info20", "@tabooAllergyInfo": "$journal.pat_main.taboo_allergy_info", "@chargeStaffInfo.staffCd": "$journal.pat_main.charge_staff_info.staff_cd"}], "sqlGroup6": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_unique", "ctl_no": "1", "sqlCode": 1601, "insertResult": "{@patId:'''', @facilityCd:'''', @medicalHstInfoValue:''[]'', @inOutVisitHistoryInfoValue:''[]'', @physicalInfoFlg:'''', @physicalInfoValue:''[]''}"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_unique", "ctl_no": "2", "sqlCode": 9106, "@physicalInfo.dw": "$journal.pat_unique.physical_info.dw", "@physicalInfo.height": "$journal.pat_unique.physical_info.height", "@physicalInfo.ctrWeight": "$journal.pat_unique.physical_info.ctr_weight", "@physicalInfo.orderClass": "1"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_unique", "ctl_no": "3", "sqlCode": 9107, "@physicalInfo.dw": "$journal.pat_unique.physical_info.dw", "@physicalInfo.height": "$journal.pat_unique.physical_info.height", "@physicalInfo.ctrWeight": "$journal.pat_unique.physical_info.ctr_weight", "@physicalInfo.orderClass": "1"}], "sqlGroup7": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "患者死亡退院情報連携", "No3": "患者の状態を『死亡』として、患者情報を登録します。", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "@isDie": "0", "ctl_no": "2", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -600013, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "2", "@severityCd": "$journal.pat_personal_main.severity_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@transportCd": "$journal.pat_personal_main.transport_cd", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}], "sqlGroup8": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "No3": "NEC場合、[死亡患者、連絡先情報、透析困難情報]を更新する。", "No4": "死亡退院日が空白の場合は「死亡患者 = 対象外」で登録、空白でない場合は「死亡患者 = 対象」で登録します。", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}, {"No2": "患者死亡退院情報連携", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "2", "sqlCode": 9102}, {"No2": "患者死亡退院情報連携", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "3", "sqlCode": 9103, "@otherContactInfo.tel1": "$journal.pat_personal_main.other_contact_info.tel1", "@otherContactInfo.zipCd": "$journal.pat_personal_main.other_contact_info.zip_cd", "@otherContactInfo.address": "$journal.pat_personal_main.other_contact_info.address", "@otherContactInfo.patName": "$journal.pat_personal_main.pat_name", "@otherContactInfo.patNameKana": "$journal.pat_personal_main.pat_name_kana"}], "sqlGroup9": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201, "insertResult": "{@patId:'''',@facilityCd:'''',@isSame:'''',@isImplant:'''',@isInfect:'''',@isDiabetes:'''',@isBloodSugerExam:'''',@inOutCurrentState:'''',@inOutPlanState:'''',@inOutPlanDate_Date:'''',@patMemoInfoValue:''[]'',@additionInfoValue:''[]'',@chargeStaffInfoValue:''[]'',@patGroupInfoValue:''[]'',@tabooAllergyInfoValue:''[]'',@infectInfoValue:''[]'',@implantInfoValue:''[]'',@tareInfoValue:''{}'',@offWaterInfoValue:''{}'',@deviceSetInfoValue:''{}'',@acceptanceStatusInfoValue:''[]'',@isWheelChair:'''',@medicalCareInfoFlg:'''',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:'''',@schExtStatus:'''',@cardIdm:'''',@oldUpDate_Date:''''}", "updateResult": "{@patId:''pat_id'',@facilityCd:''facility_cd'',@isSame:''is_same'',@isImplant:''is_implant'',@isInfect:''is_infect'',@isDiabetes:''is_diabetes'',@isBloodSugerExam:''is_blood_suger_exam'',@inOutCurrentState:''in_out_current_state'',@inOutPlanState:''in_out_plan_state'',@inOutPlanDate_Date:''in_out_plan_date'',@patMemoInfoValue:''pat_memo_info'',@additionInfoValue:''addition_info'',@chargeStaffInfoValue:''charge_staff_info'',@patGroupInfoValue:''pat_group_info'',@tabooAllergyInfoValue:''taboo_allergy_info'',@infectInfoValue:''infect_info'',@implantInfoValue:''implant_info'',@tareInfoValue:''tare_info'',@offWaterInfoValue:''off_water_info'',@deviceSetInfoValue:''device_set_info'',@acceptanceStatusInfoValue:''acceptance_status_info'',@isWheelChair:''is_wheel_chair'',@medicalCareInfoFlg:'''',@medicalCareInfoValue:''medical_care_info'',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:''sch_ext_end_date'',@schExtStatus:''sch_ext_status'',@cardIdm:''card_idm'',@oldUpDate_Date:''old_up_date''}"}, {"No2": "患者死亡退院情報連携", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "2", "sqlCode": -600014, "@inOutClass": "1", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}, {"No2": "患者死亡退院情報連携", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "3", "sqlCode": -600016, "@inOutClass": "1", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}], "sqlGroup10": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201}, {"No2": "患者死亡退院情報連携", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "2", "sqlCode": 9104}, {"No2": "患者死亡退院情報連携", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "3", "sqlCode": 9105, "@infectInfo1": "$journal.pat_main.infect_info1", "@infectInfo2": "$journal.pat_main.infect_info2", "@infectInfo3": "$journal.pat_main.infect_info3", "@infectInfo4": "$journal.pat_main.infect_info4", "@infectInfo5": "$journal.pat_main.infect_info5", "@infectInfo6": "$journal.pat_main.infect_info6", "@infectInfo7": "$journal.pat_main.infect_info7", "@infectInfo8": "$journal.pat_main.infect_info8", "@infectInfo9": "$journal.pat_main.infect_info9", "@infectInfo10": "$journal.pat_main.infect_info10", "@infectInfo11": "$journal.pat_main.infect_info11", "@infectInfo12": "$journal.pat_main.infect_info12", "@infectInfo13": "$journal.pat_main.infect_info13", "@infectInfo14": "$journal.pat_main.infect_info14", "@infectInfo15": "$journal.pat_main.infect_info15", "@infectInfo16": "$journal.pat_main.infect_info16", "@infectInfo17": "$journal.pat_main.infect_info17", "@infectInfo18": "$journal.pat_main.infect_info18", "@infectInfo19": "$journal.pat_main.infect_info19", "@infectInfo20": "$journal.pat_main.infect_info20", "@tabooAllergyInfo": "$journal.pat_main.taboo_allergy_info", "@chargeStaffInfo.staffCd": "$journal.pat_main.charge_staff_info.staff_cd"}], "sqlGroup11": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_unique", "ctl_no": "1", "sqlCode": 1601, "insertResult": "{@patId:'''', @facilityCd:'''', @medicalHstInfoValue:''[]'', @inOutVisitHistoryInfoValue:''[]'', @physicalInfoFlg:'''', @physicalInfoValue:''[]''}"}, {"No2": "患者死亡退院情報連携", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_unique", "ctl_no": "2", "sqlCode": 9106, "@physicalInfo.dw": "$journal.pat_unique.physical_info.dw", "@physicalInfo.height": "$journal.pat_unique.physical_info.height", "@physicalInfo.ctrWeight": "$journal.pat_unique.physical_info.ctr_weight", "@physicalInfo.orderClass": "1"}], "sqlGroup12": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "患者死亡退院情報連携", "No3": "患者情報更新", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "3", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -600015, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "2", "@severityCd": "$journal.pat_personal_main.severity_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@transportCd": "$journal.pat_personal_main.transport_cd", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}], "sqlGroup13": [{"No1": "指示情報→登録・更新", "No2": "初回指示連携Ver2、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer2,$journal.const.crud#<>#D", "table": "pat_coop_detail", "ctl_no": "1", "sqlCode": 9111, "insertResult": "{@coopSaveNo:'''', @facilityCd:'''', @patId:'''', @save1:'''', @save1Flg:'''', @save2Flg:'''', @save2.ord_no:'''', @save2.instruction_doctor_generation_no:'''', @save2.dialysis_type:'''', @save2.dialysis_course:'''', @save2.dialysis_pattern:'''', @save2.start_date_regular:'''', @save2.end_date_regular:'''', @save2.implementation_place:'''', @save2.update_terminal:'''', @save2.addition_generation_no:'''', @save2.blood_purification_method:'''', @save2.blood_purification_generation_no:'''', @save2.updater:'''', @save2.updater_generation_no:'''', @save3:'''', @save4:'''', @save5:'''', @save6:'''', @save7:'''', @save8:'''', @save9:'''', @save10:'''', @isDisp:'''', @isDel:'''', @userId:'''', @upDate_Date:'''', @regDate_Date:''''}", "updateResult": "{@coopSaveNo:''coop_save_no'', @facilityCd:''facility_cd'', @patId:''pat_id'', @save1Value:''save_1'', @save1Flg:'''', @save2Flg:'''', @save2Value:''save_2'', @save2.ord_no:'''', @save2.instruction_doctor_generation_no:'''', @save2.dialysis_type:'''', @save2.dialysis_course:'''', @save2.dialysis_pattern:'''', @save2.start_date_regular:'''', @save2.end_date_regular:'''', @save2.implementation_place:'''', @save2.update_terminal:'''', @save2.addition_generation_no:'''', @save2.blood_purification_method:'''', @save2.blood_purification_generation_no:'''', @save2.updater:'''', @save2.updater_generation_no:'''', @save3:''save_3'', @save4:''save_4'', @save5:''save_5'', @save6:''save_6'', @save7:''save_7'', @save8:''save_8'', @save9:''save_9'', @save10:''save_10'', @isDisp:''is_disp'', @isDel:''is_del'', @userId:''user_id'', @upDate_Date:''up_date'', @regDate_Date:''reg_date''}"}, {"No2": "初回指示連携Ver2、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer2,$journal.const.crud#<>#D", "table": "pat_coop_detail", "ctl_no": "2", "@userId": "-1", "sqlCode": -600103}], "sqlGroup14": [{"No1": "患者情報→登録・更新", "No2": "連携共通", "crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "連携共通", "No3": "患者の状態を『存命』から『死亡』に変更します。", "crud": "U", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "3", "sqlCode": -600105, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@dieDate_Date": "$journal.pat_personal_main.die_date"}]}, "CoopIniConvUtil": {"$journal.pat_personal_main.pat_sex": "CONV_SEX_TO_FNW", "$journal.pat_personal_main.pat_blood_type_rh": "CONV_BLOOD_RH_TO_FNW", "$journal.pat_personal_main.pat_blood_type_abo": "CONV_BLOOD_ABO_TO_FNW"}}'::jsonb, '1', '0', -1, '2024-12-19 01:12:10.167', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010007, 'N_hosp', 'ini_dial', '', 'R', '患者情報', 'text', 'NEC想定透析初回指示', 'MEGA', 'テスト用ver2/TSHPlus', '1', '<root name="透析申込(患者情報)">
  <item name="コマンド名" len="8" type="string" col="$journal.const.command_name" value="const:C-KNJUPD"/>
  <item name="処理区分" len="1" type="string" col="$journal.const.crud" value="const:C"/>
  <item name="病院コード" len="2" type="string"/>
  <item name="患者情報.患者番号" len="10" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
  <item name="患者情報.患者氏名" len="40" col="$journal.pat_personal_main.pat_name" type="string"/>
  <item name="患者情報.患者カナ氏名" len="20" col="$journal.pat_personal_main.pat_name_kana" type="string"/>
  <item name="患者情報.性別" len="1" col="$journal.pat_personal_main.pat_sex" type="string"/>
  <item name="患者情報.生年月日" len="8" col="$journal.pat_personal_main.pat_birthday" type="string"/>
  <item name="患者情報.郵便番号１" len="7" col="$journal.pat_personal_main.pat_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所１" len="100" col="$journal.pat_personal_main.pat_contact_info.address" type="string"/>
  <item name="患者情報.電話番号１" len="12" col="$journal.pat_personal_main.pat_contact_info.tel1" type="string"/>
  <item name="患者情報.郵便番号２" len="7" col="$journal.pat_personal_main.other_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所２" len="100" col="$journal.pat_personal_main.other_contact_info.address" type="string"/>
  <item name="患者情報.電話番号２" len="12" col="$journal.pat_personal_main.other_contact_info.tel1" type="string"/>
  <item name="病棟コード" len="4" col="$journal.pat_main.medical_care_info.ward_cd" type="string"/>
  <item name="病棟名称" len="20" type="string" info="対象外"/>
  <item name="病室コード" len="4" type="string" info="対象外"/>
  <item name="病室名称" len="20" type="string" info="対象外"/>
  <item name="看護区分" len="2" type="string" info="対象外"/>
  <item name="患者区分" len="2" col="$journal.pat_personal_main.severity_cd" type="string"/>
  <item name="救護区分" len="2" col="$journal.pat_personal_main.transport_cd" type="string"/>
  <item name="予備区分" len="1" type="string" info="対象外"/>
  <item name="障害情報" len="15" type="string" info="対象外"/>
  <item name="身長" len="5" col="$journal.pat_unique.physical_info.height" type="string" info="対象外"/>
  <item name="体重" len="5" col="$journal.pat_unique.physical_info.ctr_weight" type="string" info="対象外"/>
  <item name="血液型ＡＢＯ" len="1" col="$journal.pat_personal_main.pat_blood_type_abo" type="string"/>
  <item name="血液型Ｒｈ" len="1" col="$journal.pat_personal_main.pat_blood_type_rh" type="string"/>
  <item name="感染情報1" len="1" col="$journal.pat_main.infect_info1" type="string" info="1バイトのフラグ"/>
  <item name="感染情報2" len="1" col="$journal.pat_main.infect_info2" type="string" info="1バイトのフラグ"/>
  <item name="感染情報3" len="1" col="$journal.pat_main.infect_info3" type="string" info="1バイトのフラグ"/>
  <item name="感染情報4" len="1" col="$journal.pat_main.infect_info4" type="string" info="1バイトのフラグ"/>
  <item name="感染情報5" len="1" col="$journal.pat_main.infect_info5" type="string" info="1バイトのフラグ"/>
  <item name="感染情報6" len="1" col="$journal.pat_main.infect_info6" type="string" info="1バイトのフラグ"/>
  <item name="感染情報7" len="1" col="$journal.pat_main.infect_info7" type="string" info="1バイトのフラグ"/>
  <item name="感染情報8" len="1" col="$journal.pat_main.infect_info8" type="string" info="1バイトのフラグ"/>
  <item name="感染情報9" len="1" col="$journal.pat_main.infect_info9" type="string" info="1バイトのフラグ"/>
  <item name="感染情報10" len="1" col="$journal.pat_main.infect_info10" type="string" info="1バイトのフラグ"/>
  <item name="感染情報11" len="1" col="$journal.pat_main.infect_info11" type="string" info="1バイトのフラグ"/>
  <item name="感染情報12" len="1" col="$journal.pat_main.infect_info12" type="string" info="1バイトのフラグ"/>
  <item name="感染情報13" len="1" col="$journal.pat_main.infect_info13" type="string" info="1バイトのフラグ"/>
  <item name="感染情報14" len="1" col="$journal.pat_main.infect_info14" type="string" info="1バイトのフラグ"/>
  <item name="感染情報15" len="1" col="$journal.pat_main.infect_info15" type="string" info="1バイトのフラグ"/>
  <item name="感染情報16" len="1" col="$journal.pat_main.infect_info16" type="string" info="1バイトのフラグ"/>
  <item name="感染情報17" len="1" col="$journal.pat_main.infect_info17" type="string" info="1バイトのフラグ"/>
  <item name="感染情報18" len="1" col="$journal.pat_main.infect_info18" type="string" info="1バイトのフラグ"/>
  <item name="感染情報19" len="1" col="$journal.pat_main.infect_info19" type="string" info="1バイトのフラグ"/>
  <item name="感染情報20" len="1" col="$journal.pat_main.infect_info20" type="string" info="1バイトのフラグ"/>
  <item name="感染コメント" len="60" type="string" info="対象外"/>
  <item name="薬剤禁忌情報" len="20" col="$journal.pat_main.taboo_allergy_info" type="string" info="20バイトのフラグ"/>
  <item name="禁忌コメント" len="60" type="string"/>
  <item name="妊娠日" len="8" type="string" info="対象外"/>
  <item name="死亡退院日" len="8" col="$journal.pat_personal_main.die_date" type="string"/>
  <item name="予備" len="30" type="string" info="対象外"/>
</root>
', '{}'::jsonb, '1', '0', -1, '2019-12-13 05:44:54.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010008, 'N_hosp', 'ini_dial', '', 'R', '患者死亡退院情報', 'text', 'NEC想定透析初回指示', 'MEGA', 'テスト用ver2/TSHPlus', '1', '<root name="透析申込(患者死亡退院情報)">
  <item name="コマンド名" len="8" type="string" col="$journal.const.command_name" value="const:C-KNJDEL"/>
  <item name="処理区分" len="1" type="string" col="$journal.const.crud" value="const:C"/>
  <item name="病院コード" len="2" type="string"/>
  <item name="患者情報.患者番号" len="10" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
  <item name="患者情報.患者氏名" len="40" col="$journal.pat_personal_main.pat_name" type="string"/>
  <item name="患者情報.患者カナ氏名" len="20" col="$journal.pat_personal_main.pat_name_kana" type="string"/>
  <item name="患者情報.性別" len="1" col="$journal.pat_personal_main.pat_sex" type="string"/>
  <item name="患者情報.生年月日" len="8" col="$journal.pat_personal_main.pat_birthday" type="string"/>
  <item name="患者情報.郵便番号１" len="7" col="$journal.pat_personal_main.pat_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所１" len="100" col="$journal.pat_personal_main.pat_contact_info.address" type="string"/>
  <item name="患者情報.電話番号１" len="12" col="$journal.pat_personal_main.pat_contact_info.tel1" type="string"/>
  <item name="患者情報.郵便番号２" len="7" col="$journal.pat_personal_main.other_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所２" len="100" col="$journal.pat_personal_main.other_contact_info.address" type="string"/>
  <item name="患者情報.電話番号２" len="12" col="$journal.pat_personal_main.other_contact_info.tel1" type="string"/>
  <item name="病棟コード" len="4" col="$journal.pat_main.medical_care_info.ward_cd" type="string"/>
  <item name="病棟名称" len="20" type="string" info="対象外"/>
  <item name="病室コード" len="4" type="string" info="対象外"/>
  <item name="病室名称" len="20" type="string" info="対象外"/>
  <item name="看護区分" len="2" type="string" info="対象外"/>
  <item name="患者区分" len="2" col="$journal.pat_personal_main.severity_cd" type="string"/>
  <item name="救護区分" len="2" col="$journal.pat_personal_main.transport_cd" type="string"/>
  <item name="予備区分" len="1" type="string" info="対象外"/>
  <item name="障害情報" len="15" type="string" info="対象外"/>
  <item name="身長" len="5" col="$journal.pat_unique.physical_info.height" type="string" info="対象外"/>
  <item name="体重" len="5" col="$journal.pat_unique.physical_info.ctr_weight" type="string" info="対象外"/>
  <item name="血液型ＡＢＯ" len="1" col="$journal.pat_personal_main.pat_blood_type_abo" type="string"/>
  <item name="血液型Ｒｈ" len="1" col="$journal.pat_personal_main.pat_blood_type_rh" type="string"/>
  <item name="感染情報1" len="1" col="$journal.pat_main.infect_info1" type="string" info="1バイトのフラグ"/>
  <item name="感染情報2" len="1" col="$journal.pat_main.infect_info2" type="string" info="1バイトのフラグ"/>
  <item name="感染情報3" len="1" col="$journal.pat_main.infect_info3" type="string" info="1バイトのフラグ"/>
  <item name="感染情報4" len="1" col="$journal.pat_main.infect_info4" type="string" info="1バイトのフラグ"/>
  <item name="感染情報5" len="1" col="$journal.pat_main.infect_info5" type="string" info="1バイトのフラグ"/>
  <item name="感染情報6" len="1" col="$journal.pat_main.infect_info6" type="string" info="1バイトのフラグ"/>
  <item name="感染情報7" len="1" col="$journal.pat_main.infect_info7" type="string" info="1バイトのフラグ"/>
  <item name="感染情報8" len="1" col="$journal.pat_main.infect_info8" type="string" info="1バイトのフラグ"/>
  <item name="感染情報9" len="1" col="$journal.pat_main.infect_info9" type="string" info="1バイトのフラグ"/>
  <item name="感染情報10" len="1" col="$journal.pat_main.infect_info10" type="string" info="1バイトのフラグ"/>
  <item name="感染情報11" len="1" col="$journal.pat_main.infect_info11" type="string" info="1バイトのフラグ"/>
  <item name="感染情報12" len="1" col="$journal.pat_main.infect_info12" type="string" info="1バイトのフラグ"/>
  <item name="感染情報13" len="1" col="$journal.pat_main.infect_info13" type="string" info="1バイトのフラグ"/>
  <item name="感染情報14" len="1" col="$journal.pat_main.infect_info14" type="string" info="1バイトのフラグ"/>
  <item name="感染情報15" len="1" col="$journal.pat_main.infect_info15" type="string" info="1バイトのフラグ"/>
  <item name="感染情報16" len="1" col="$journal.pat_main.infect_info16" type="string" info="1バイトのフラグ"/>
  <item name="感染情報17" len="1" col="$journal.pat_main.infect_info17" type="string" info="1バイトのフラグ"/>
  <item name="感染情報18" len="1" col="$journal.pat_main.infect_info18" type="string" info="1バイトのフラグ"/>
  <item name="感染情報19" len="1" col="$journal.pat_main.infect_info19" type="string" info="1バイトのフラグ"/>
  <item name="感染情報20" len="1" col="$journal.pat_main.infect_info20" type="string" info="1バイトのフラグ"/>
  <item name="感染コメント" len="60" type="string" info="対象外"/>
  <item name="薬剤禁忌情報" len="20" col="$journal.pat_main.taboo_allergy_info" type="string" info="20バイトのフラグ"/>
  <item name="禁忌コメント" len="60" type="string"/>
  <item name="妊娠日" len="8" type="string" info="対象外"/>
  <item name="死亡退院日" len="8" col="$journal.pat_personal_main.die_date" type="string"/>
  <item name="予備" len="30" type="string" info="対象外"/>
</root>
', '{}'::jsonb, '1', '0', -1, '2019-12-13 05:44:54.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010009, 'N_hosp', 'ini_dial', '', 'R', 'pre', 'text', 'NEC想定透析初回指示', 'MEGA', 'テスト用ver1/TSHPlus', '1', '<root name="透析申込(pre)">
  <item name="コマンド名" len="8" type="string" key="command_name"/>
  <item name="処理区分" len="1" type="string"/>
  <item name="病院コード" len="2" type="string"/>
  <item name="患者情報.患者番号" len="10" type="string"/>
  <item name="患者情報.患者氏名" len="40" type="string"/>
  <item name="患者情報.患者カナ氏名" len="20" type="string"/>
  <item name="患者情報.性別" len="1" type="string"/>
  <item name="患者情報.生年月日" len="8" type="string"/>
  <item name="患者情報.郵便番号１" len="7" type="string"/>
  <item name="患者情報.患者住所１" len="100" type="string"/>
  <item name="患者情報.電話番号１" len="12" type="string"/>
  <item name="患者情報.郵便番号２" len="7" type="string"/>
  <item name="患者情報.患者住所２" len="100" type="string"/>
  <item name="患者情報.電話番号２" len="12" type="string"/>
  <item name="病棟コード" len="4" type="string"/>
  <item name="病棟名称" len="20" type="string"/>
  <item name="病室コード" len="4" type="string"/>
  <item name="病室名称" len="20" type="string"/>
  <item name="看護区分" len="2" type="string"/>
  <item name="患者区分" len="2" type="string"/>
  <item name="救護区分" len="2" type="string"/>
  <item name="予備区分" len="1" type="string"/>
  <item name="障害情報" len="15" type="string"/>
  <item name="身長" len="5" type="string"/>
  <item name="体重" len="5" type="string"/>
  <item name="血液型ＡＢＯ" len="1" type="string"/>
  <item name="血液型Ｒｈ" len="1" type="string"/>
  <item name="感染情報" len="20" type="string"/>
  <item name="感染コメント" len="60" type="string"/>
  <item name="薬剤禁忌情報" len="20" type="string"/>
  <item name="禁忌コメント" len="60" type="string"/>
  <item name="妊娠日" len="8" type="string"/>
  <item name="死亡退院日" len="8" type="string"/>
  <item name="予備" len="30" type="string"/>
</root>
', '{"key": {"command_name": {"C-DIRECT": "初回指示情報", "C-KNJDEL": "患者死亡退院情報", "C-KNJUPD": "患者情報"}}, "dataset": {"sqlGroup1": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "@isDie": "0", "ctl_no": "2", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -600013, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "1", "@severityCd": "$journal.pat_personal_main.severity_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@transportCd": "$journal.pat_personal_main.transport_cd", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "3", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -600015, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "1", "@severityCd": "$journal.pat_personal_main.severity_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@transportCd": "$journal.pat_personal_main.transport_cd", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}], "sqlGroup2": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "No3": "NEC場合、病棟コードより、[入外区分]を更新する。病棟コードが空白の場合は「入外区分 = 外来」で登録、空白でない場合は「入外区分 = 入院」で登録します。", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "No3": "NEC場合、[入外区分]の更新処理、pat_personal_mainを更新する。または、pat_mainから、データを取得する。tableにpat_mainを設定しました。", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "2", "sqlCode": 9101, "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd"}], "sqlGroup3": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "No3": "NEC場合、[死亡患者、連絡先情報、透析困難情報]を更新する。", "No4": "死亡退院日が空白の場合は「死亡患者 = 対象外」で登録、空白でない場合は「死亡患者 = 対象」で登録します。", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "2", "sqlCode": 9102}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "3", "sqlCode": 9103, "@otherContactInfo.tel1": "$journal.pat_personal_main.other_contact_info.tel1", "@otherContactInfo.zipCd": "$journal.pat_personal_main.other_contact_info.zip_cd", "@otherContactInfo.address": "$journal.pat_personal_main.other_contact_info.address", "@otherContactInfo.patName": "$journal.pat_personal_main.pat_name", "@otherContactInfo.patNameKana": "$journal.pat_personal_main.pat_name_kana"}], "sqlGroup4": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201, "insertResult": "{@patId:'''',@facilityCd:'''',@isSame:'''',@isImplant:'''',@isInfect:'''',@isDiabetes:'''',@isBloodSugerExam:'''',@inOutCurrentState:'''',@inOutPlanState:'''',@inOutPlanDate_Date:'''',@patMemoInfoValue:''[]'',@additionInfoValue:''[]'',@chargeStaffInfoValue:''[]'',@patGroupInfoValue:''[]'',@tabooAllergyInfoValue:''[]'',@infectInfoValue:''[]'',@implantInfoValue:''[]'',@tareInfoValue:''{}'',@offWaterInfoValue:''{}'',@deviceSetInfoValue:''{}'',@acceptanceStatusInfoValue:''[]'',@isWheelChair:'''',@medicalCareInfoFlg:'''',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:'''',@schExtStatus:'''',@cardIdm:'''',@oldUpDate_Date:''''}", "updateResult": "{@patId:''pat_id'',@facilityCd:''facility_cd'',@isSame:''is_same'',@isImplant:''is_implant'',@isInfect:''is_infect'',@isDiabetes:''is_diabetes'',@isBloodSugerExam:''is_blood_suger_exam'',@inOutCurrentState:''in_out_current_state'',@inOutPlanState:''in_out_plan_state'',@inOutPlanDate_Date:''in_out_plan_date'',@patMemoInfoValue:''pat_memo_info'',@additionInfoValue:''addition_info'',@chargeStaffInfoValue:''charge_staff_info'',@patGroupInfoValue:''pat_group_info'',@tabooAllergyInfoValue:''taboo_allergy_info'',@infectInfoValue:''infect_info'',@implantInfoValue:''implant_info'',@tareInfoValue:''tare_info'',@offWaterInfoValue:''off_water_info'',@deviceSetInfoValue:''device_set_info'',@acceptanceStatusInfoValue:''acceptance_status_info'',@isWheelChair:''is_wheel_chair'',@medicalCareInfoFlg:'''',@medicalCareInfoValue:''medical_care_info'',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:''sch_ext_end_date'',@schExtStatus:''sch_ext_status'',@cardIdm:''card_idm'',@oldUpDate_Date:''old_up_date''}"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "2", "sqlCode": -600014, "@inOutClass": "1", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "3", "sqlCode": -600016, "@inOutClass": "1", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}], "sqlGroup5": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "2", "sqlCode": 9104}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "3", "sqlCode": 9105, "@infectInfo1": "$journal.pat_main.infect_info1", "@infectInfo2": "$journal.pat_main.infect_info2", "@infectInfo3": "$journal.pat_main.infect_info3", "@infectInfo4": "$journal.pat_main.infect_info4", "@infectInfo5": "$journal.pat_main.infect_info5", "@infectInfo6": "$journal.pat_main.infect_info6", "@infectInfo7": "$journal.pat_main.infect_info7", "@infectInfo8": "$journal.pat_main.infect_info8", "@infectInfo9": "$journal.pat_main.infect_info9", "@infectInfo10": "$journal.pat_main.infect_info10", "@infectInfo11": "$journal.pat_main.infect_info11", "@infectInfo12": "$journal.pat_main.infect_info12", "@infectInfo13": "$journal.pat_main.infect_info13", "@infectInfo14": "$journal.pat_main.infect_info14", "@infectInfo15": "$journal.pat_main.infect_info15", "@infectInfo16": "$journal.pat_main.infect_info16", "@infectInfo17": "$journal.pat_main.infect_info17", "@infectInfo18": "$journal.pat_main.infect_info18", "@infectInfo19": "$journal.pat_main.infect_info19", "@infectInfo20": "$journal.pat_main.infect_info20", "@tabooAllergyInfo": "$journal.pat_main.taboo_allergy_info", "@chargeStaffInfo.staffCd": "$journal.pat_main.charge_staff_info.staff_cd"}], "sqlGroup6": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_unique", "ctl_no": "1", "sqlCode": 1601, "insertResult": "{@patId:'''', @facilityCd:'''', @medicalHstInfoValue:''[]'', @inOutVisitHistoryInfoValue:''[]'', @physicalInfoFlg:'''', @physicalInfoValue:''[]''}"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_unique", "ctl_no": "2", "sqlCode": 9106, "@physicalInfo.dw": "$journal.pat_unique.physical_info.dw", "@physicalInfo.height": "$journal.pat_unique.physical_info.height", "@physicalInfo.ctrWeight": "$journal.pat_unique.physical_info.ctr_weight", "@physicalInfo.orderClass": "1"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_unique", "ctl_no": "3", "sqlCode": 9107, "@physicalInfo.dw": "$journal.pat_unique.physical_info.dw", "@physicalInfo.height": "$journal.pat_unique.physical_info.height", "@physicalInfo.ctrWeight": "$journal.pat_unique.physical_info.ctr_weight", "@physicalInfo.orderClass": "1"}], "sqlGroup7": [{"No1": "指示情報→登録・更新", "No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_insurance_1", "ctl_no": "1", "sqlCode": 9108, "@coopCode": "$journal.pat_insurance_1.coop_code", "insertResult": "{@insuranceCd:''0'',@patId:''0'',@facilityCd:''0'',@ctlNo:'''',@fnPatId:'''',@insuClass:'''',@insuName:'''',@insuNmShort:'''',@insuInfoFlg:'''',@insuInfo.insuNo:'''',@insuInfo.insuPatName:'''',@insuInfo.insuPatNo:'''',@insuInfo.insuKbn:'''',@insuInfo.insuPatMark:'''',@insuInfo.ckiClass:'''',@insuInfo.kkiClass:'''',@insuInfo.undSix:'''',@insuInfo.futan-g:'''',@insuInfo.futan-n:'''',@insuPubInfoFlg:'''',@insuPubInfo.insuPubName:'''',@insuPubInfo.insuPubNo:'''',@insuPubInfo.insuPubPatNo:'''',@insuSetInfoFlg:'''',@insuSetInfo.insuCd:'''',@insuSetInfo.insuPub1Cd:'''',@insuSetInfo.insuPub2Cd:'''',@insuSetInfo.insuPub3Cd:'''',@insuSetInfo.insuPub4Cd:'''',@isSelected:'''',@isDisp:''1'',@coopCode:'''',@isCoop:'''',@startDate:'''',@endDate:'''',@checkDate:'''',@oldUpDate_Date:''''}", "updateResult": "{@insuranceCd:''insurance_cd'',@patId:''pat_id'',@facilityCd:''facility_cd'',@ctlNo:''ctl_no'',@fnPatId:''fn_pat_id'',@insuClass:''insu_class'',@insuName:''insu_name'',@insuNmShort:''insu_name_short'',@insuInfoFlg:'''',@insuInfoValue:''insu_info'',@insuInfo.insuNo:'''',@insuInfo.insuPatName:'''',@insuInfo.insuPatNo:'''',@insuInfo.insuKbn:'''',@insuInfo.insuPatMark:'''',@insuInfo.ckiClass:'''',@insuInfo.kkiClass:'''',@insuInfo.undSix:'''',@insuInfo.futan-g:'''',@insuInfo.futan-n:'''',@insuPubInfoFlg:'''',@insuPubInfoValue:''insu_pub_info'',@insuPubInfo.insuPubName:'''',@insuPubInfo.insuPubNo:'''',@insuPubInfo.insuPubPatNo:'''',@insuSetInfoFlg:'''',@insuSetInfoValue:''insu_set_info'',@insuSetInfo.insuCd:'''',@insuSetInfo.insuPub1Cd:'''',@insuSetInfo.insuPub2Cd:'''',@insuSetInfo.insuPub3Cd:'''',@insuSetInfo.insuPub4Cd:'''',@isSelected:''is_selected'',@isDisp:''is_disp'',@coopCode:''coop_code'',@isCoop:''is_coop'',@startDate:''start_date'',@endDate:''end_date'',@checkDate:''check_date'',@oldUpDate_Date:''old_up_date''}"}, {"No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_insurance_1", "ctl_no": "2", "sqlCode": 9109, "@coopCode": "$journal.pat_insurance_1.coop_code"}, {"No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_insurance_1", "ctl_no": "3", "sqlCode": 9110, "@coopCode": "$journal.pat_insurance_1.coop_code"}], "sqlGroup8": [{"No1": "指示情報→登録・更新", "No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_coop_detail", "ctl_no": "1", "sqlCode": 9111, "insertResult": "{@coopSaveNo:'''', @facilityCd:'''', @patId:'''', @save1:'''', @save1Flg:'''', @save2Flg:'''', @save2.ord_no:'''', @save2.instruction_doctor_generation_no:'''', @save2.dialysis_type:'''', @save2.dialysis_course:'''', @save2.dialysis_pattern:'''', @save2.start_date_regular:'''', @save2.end_date_regular:'''', @save2.implementation_place:'''', @save2.update_terminal:'''', @save2.addition_generation_no:'''', @save2.blood_purification_method:'''', @save2.blood_purification_generation_no:'''', @save2.updater:'''', @save2.updater_generation_no:'''', @save3:'''', @save4:'''', @save5:'''', @save6:'''', @save7:'''', @save8:'''', @save9:'''', @save10:'''', @isDisp:'''', @isDel:'''', @userId:'''', @upDate_Date:'''', @regDate_Date:''''}", "updateResult": "{@coopSaveNo:''coop_save_no'', @facilityCd:''facility_cd'', @patId:''pat_id'', @save1Value:''save_1'', @save1Flg:'''', @save2Flg:'''', @save2Value:''save_2'', @save2.ord_no:'''', @save2.instruction_doctor_generation_no:'''', @save2.dialysis_type:'''', @save2.dialysis_course:'''', @save2.dialysis_pattern:'''', @save2.start_date_regular:'''', @save2.end_date_regular:'''', @save2.implementation_place:'''', @save2.update_terminal:'''', @save2.addition_generation_no:'''', @save2.blood_purification_method:'''', @save2.blood_purification_generation_no:'''', @save2.updater:'''', @save2.updater_generation_no:'''', @save3:''save_3'', @save4:''save_4'', @save5:''save_5'', @save6:''save_6'', @save7:''save_7'', @save8:''save_8'', @save9:''save_9'', @save10:''save_10'', @isDisp:''is_disp'', @isDel:''is_del'', @userId:''user_id'', @upDate_Date:''up_date'', @regDate_Date:''reg_date''}"}, {"No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_coop_detail", "ctl_no": "2", "@userId": "-1", "sqlCode": 9112, "@save2.dw": "$journal.pat_coop_detail.dw", "@save2.va3": "$journal.pat_coop_detail.va3", "@save2.ord_no": "$journal.pat_coop_detail.ord_no", "@save2.kur_cd1": "$journal.pat_coop_detail.kur_cd1", "@save2.updater": "$journal.pat_coop_detail.updater", "@save2.addition": "$journal.pat_personal_main.dial_diff_com_info.dial_diff_cd", "@save2.va_direct": "$journal.pat_coop_detail.va_direct", "@save2.dialysis_type": "$journal.pat_coop_detail.dialysis_type", "@save2.dialysis_course": "$journal.pat_coop_detail.dialysis_course", "@save2.update_terminal": "$journal.pat_coop_detail.update_terminal", "@save2.dialysis_pattern": "$journal.pat_coop_detail.dialysis_pattern", "@save2.end_date_regular": "$journal.pat_coop_detail.end_date_regular", "@save2.insurance_code_01": "$journal.pat_insurance_1.coop_code", "@save2.insurance_code_02": "$journal.pat_insurance_2.coop_code", "@save2.insurance_code_03": "$journal.pat_insurance_3.coop_code", "@save2.instruction_doctor": "$journal.pat_main.charge_staff_info.staff_cd", "@save2.start_date_regular": "$journal.pat_coop_detail.start_date_regular", "@save2.implementation_place": "$journal.pat_coop_detail.implementation_place", "@save2.updater_generation_no": "$journal.pat_coop_detail.updater_generation_no", "@save2.addition_generation_no": "$journal.pat_coop_detail.addition_generation_no", "@save2.instruction_department": "$journal.pat_main.medical_care_info.main_course_cd", "@save2.blood_purification_method": "$journal.pat_coop_detail.blood_purification_method", "@save2.blood_purification_generation_no": "$journal.pat_coop_detail.blood_purification_generation_no", "@save2.instruction_doctor_generation_no": "$journal.pat_coop_detail.instruction_doctor_generation_no"}, {"No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_coop_detail", "ctl_no": "3", "@userId": "-1", "sqlCode": 9113, "@save2.dw": "$journal.pat_coop_detail.dw", "@save2.va3": "$journal.pat_coop_detail.va3", "@save1.ord_no": "$journal.pat_coop_detail.ord_no", "@save2.ord_no": "$journal.pat_coop_detail.ord_no", "@save2.kur_cd1": "$journal.pat_coop_detail.kur_cd1", "@save2.updater": "$journal.pat_coop_detail.updater", "@save2.addition": "$journal.pat_personal_main.dial_diff_com_info.dial_diff_cd", "@save2.va_direct": "$journal.pat_coop_detail.va_direct", "@save1.dialysis_type": "$journal.pat_coop_detail.dialysis_type", "@save2.dialysis_type": "$journal.pat_coop_detail.dialysis_type", "@save1.dialysis_course": "$journal.pat_coop_detail.dialysis_course", "@save1.update_terminal": "$journal.pat_coop_detail.update_terminal", "@save2.dialysis_course": "$journal.pat_coop_detail.dialysis_course", "@save2.update_terminal": "$journal.pat_coop_detail.update_terminal", "@save1.dialysis_pattern": "$journal.pat_coop_detail.dialysis_pattern", "@save1.end_date_regular": "$journal.pat_coop_detail.end_date_regular", "@save2.dialysis_pattern": "$journal.pat_coop_detail.dialysis_pattern", "@save2.end_date_regular": "$journal.pat_coop_detail.end_date_regular", "@save2.insurance_code_01": "$journal.pat_insurance_1.coop_code", "@save2.insurance_code_02": "$journal.pat_insurance_2.coop_code", "@save2.insurance_code_03": "$journal.pat_insurance_3.coop_code", "@save1.start_date_regular": "$journal.pat_coop_detail.start_date_regular", "@save2.instruction_doctor": "$journal.pat_main.charge_staff_info.staff_cd", "@save2.start_date_regular": "$journal.pat_coop_detail.start_date_regular", "@save1.implementation_place": "$journal.pat_coop_detail.implementation_place", "@save2.implementation_place": "$journal.pat_coop_detail.implementation_place", "@save2.updater_generation_no": "$journal.pat_coop_detail.updater_generation_no", "@save2.addition_generation_no": "$journal.pat_coop_detail.addition_generation_no", "@save2.instruction_department": "$journal.pat_main.medical_care_info.main_course_cd", "@save2.blood_purification_method": "$journal.pat_coop_detail.blood_purification_method", "@save1.instruction_doctor_generation_no": "$journal.pat_coop_detail.instruction_doctor_generation_no", "@save2.blood_purification_generation_no": "$journal.pat_coop_detail.blood_purification_generation_no", "@save2.instruction_doctor_generation_no": "$journal.pat_coop_detail.instruction_doctor_generation_no"}], "sqlGroup9": [{"No1": "指示情報→登録・更新", "No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_coop_detail", "ctl_no": "1", "sqlCode": 9111, "updateResult": "{@coopSaveNo:''coop_save_no'', @facilityCd:''facility_cd'', @patId:''pat_id'', @save1:''save_1'', @save2:''save_2'', @save3Flg:'''', @save3Value:''save_3'', @save3.addition_pat_cd:'''', @save3.addition_other_cd:'''', @save3.item_comment_cd:'''', @save3.dialysis_cmt_1_cd:'''', @save3.dialysis_cmt_2_cd:'''', @save3.dialysis_cmt_3_cd:'''', @save3.addition_pat_generation_no:'''', @save3.addition_other_generation_no:'''', @save3.item_comment_generation_no:'''', @save3.dialysis_cmt_1_generation_no:'''', @save3.dialysis_cmt_2_generation_no:'''', @save3.dialysis_cmt_3_generation_no:'''', @save4:''save_4'', @save5:''save_5'', @save6:''save_6'', @save7:''save_7'', @save8:''save_8'', @save9:''save_9'', @save10:''save_10'', @isDisp:''is_disp'', @isDel:''is_del'', @userId:''user_id'', @upDate_Date:''up_date'', @regDate_Date:''reg_date''}"}, {"No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_coop_detail_1", "ctl_no": "2", "sqlCode": 9119, "@save3.speed": "$journal.detail.pat_coop_detail_1.pre_speed", "@save3.reserve": "$journal.detail.pat_coop_detail_1.pre_reserve", "@save3.item_code": "$journal.detail.pat_coop_detail_1.pre_item_code", "@save3.item_name": "$journal.detail.pat_coop_detail_1.pre_item_name", "@save3.speed_unit": "$journal.detail.pat_coop_detail_1.pre_speed_unit", "@save3.usage_unit": "$journal.detail.pat_coop_detail_1.pre_usage_unit", "@save3.item_number": "$journal.detail.pat_coop_detail_1.pre_item_number", "@save3.comment_type": "$journal.detail.pat_coop_detail_2.pre_comment_type", "@save3.free_comment": "$journal.detail.pat_coop_detail_1.pre_free_comment", "@save3.usage_amount": "$journal.detail.pat_coop_detail_1.pre_usage_amount", "@save3.function_code": "$journal.detail.pat_coop_detail_1.pre_function_code", "@save3.comment_code_1": "$journal.detail.pat_coop_detail_1.pre_comment_code_1", "@save3.comment_code_2": "$journal.detail.pat_coop_detail_1.pre_comment_code_2", "@save3.comment_code_3": "$journal.detail.pat_coop_detail_1.pre_comment_code_3", "@save3.comment_name_1": "$journal.detail.pat_coop_detail_1.pre_comment_name_1", "@save3.comment_name_2": "$journal.detail.pat_coop_detail_1.pre_comment_name_2", "@save3.comment_name_3": "$journal.detail.pat_coop_detail_1.pre_comment_name_3", "@save3.comment_number": "$journal.detail.pat_coop_detail_2.pre_comment_number", "@save3.interface_flag": "$journal.detail.pat_coop_detail_1.pre_interface_flag", "@save3.addition_pat_cd": "$journal.detail.pat_coop_detail_1.addition_pat_cd", "@save3.comment_content": "$journal.detail.pat_coop_detail_2.pre_comment_content", "@save3.item_comment_cd": "$journal.detail.pat_coop_detail_1.item_comment_cd", "@save3.item_generation": "$journal.detail.pat_coop_detail_1.pre_item_generation", "@save3.speed_unit_name": "$journal.detail.pat_coop_detail_1.pre_speed_unit_name", "@save3.usage_unit_name": "$journal.detail.pat_coop_detail_1.pre_usage_unit_name", "@save3.addition_other_cd": "$journal.detail.pat_coop_detail_1.addition_other_cd", "@save3.dialysis_cmt_1_cd": "$journal.detail.pat_coop_detail_1.dialysis_cmt_1_cd", "@save3.dialysis_cmt_2_cd": "$journal.detail.pat_coop_detail_1.dialysis_cmt_2_cd", "@save3.dialysis_cmt_3_cd": "$journal.detail.pat_coop_detail_1.dialysis_cmt_3_cd", "@save3.comment_generation_1": "$journal.detail.pat_coop_detail_1.pre_comment_generation_1", "@save3.comment_generation_2": "$journal.detail.pat_coop_detail_1.pre_comment_generation_2", "@save3.comment_generation_3": "$journal.detail.pat_coop_detail_1.pre_comment_generation_3", "@save3.addition_pat_generation_no": "$journal.detail.pat_coop_detail_1.addition_pat_generation_no", "@save3.item_comment_generation_no": "$journal.detail.pat_coop_detail_1.item_comment_generation_no", "@save3.addition_other_generation_no": "$journal.detail.pat_coop_detail_1.addition_other_generation_no", "@save3.dialysis_cmt_1_generation_no": "$journal.detail.pat_coop_detail_1.dialysis_cmt_1_generation_no", "@save3.dialysis_cmt_2_generation_no": "$journal.detail.pat_coop_detail_1.dialysis_cmt_2_generation_no", "@save3.dialysis_cmt_3_generation_no": "$journal.detail.pat_coop_detail_1.dialysis_cmt_3_generation_no"}], "sqlGroup10": [{"No1": "指示情報→登録・更新", "No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_coop_detail", "ctl_no": "1", "sqlCode": 9111, "updateResult": "{@coopSaveNo:''coop_save_no'', @facilityCd:''facility_cd'', @patId:''pat_id'', @save1:''save_1'', @save2:''save_2'', @save3Flg:'''', @save3Value:''save_3'', @save3.addition_pat_cd:'''', @save3.addition_other_cd:'''', @save3.item_comment_cd:'''', @save3.dialysis_cmt_1_cd:'''', @save3.dialysis_cmt_2_cd:'''', @save3.dialysis_cmt_3_cd:'''', @save3.addition_pat_generation_no:'''', @save3.addition_other_generation_no:'''', @save3.item_comment_generation_no:'''', @save3.dialysis_cmt_1_generation_no:'''', @save3.dialysis_cmt_2_generation_no:'''', @save3.dialysis_cmt_3_generation_no:'''', @save4:''save_4'', @save5:''save_5'', @save6:''save_6'', @save7:''save_7'', @save8:''save_8'', @save9:''save_9'', @save10:''save_10'', @isDisp:''is_disp'', @isDel:''is_del'', @userId:''user_id'', @upDate_Date:''up_date'', @regDate_Date:''reg_date''}"}, {"No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_coop_detail_2", "ctl_no": "2", "sqlCode": -600114, "@save3.comment_type": "$journal.detail.pat_coop_detail_2.pre_comment_type", "@save3.comment_number": "$journal.detail.pat_coop_detail_2.pre_comment_number", "@save3.comment_content": "$journal.detail.pat_coop_detail_2.pre_comment_content"}], "sqlGroup11": [{"No1": "患者情報→削除→更新", "No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": -600109, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@save2.ordNo": "$journal.pat_coop_detail.ord_no", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_personal_main", "ctl_no": "2", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -600015, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "1", "@severityCd": "$journal.pat_personal_main.severity_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@transportCd": "$journal.pat_personal_main.transport_cd", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}], "sqlGroup12": [{"No1": "患者情報→削除→更新", "No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "No3": "NEC場合、病棟コードより、[入外区分]を更新する。病棟コードが空白の場合は「入外区分 = 外来」で登録、空白でない場合は「入外区分 = 入院」で登録します。", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": -600109, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@save2.ordNo": "$journal.pat_coop_detail.ord_no", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "No3": "NEC場合、[入外区分]の更新処理、pat_personal_mainを更新する。または、pat_mainから、データを取得する。tableにpat_mainを設定しました。", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_main", "ctl_no": "2", "sqlCode": 9101, "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd"}], "sqlGroup13": [{"No1": "患者情報→削除→更新", "No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "No3": "NEC場合、[死亡患者、連絡先情報、透析困難情報]を更新する。", "No4": "死亡退院日が空白の場合は「死亡患者 = 対象外」で登録、空白でない場合は「死亡患者 = 対象」で登録します。", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": -600109, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@save2.ordNo": "$journal.pat_coop_detail.ord_no", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_personal_main", "ctl_no": "2", "sqlCode": 9103, "@otherContactInfo.tel1": "$journal.pat_personal_main.other_contact_info.tel1", "@otherContactInfo.zipCd": "$journal.pat_personal_main.other_contact_info.zip_cd", "@otherContactInfo.address": "$journal.pat_personal_main.other_contact_info.address", "@otherContactInfo.patName": "$journal.pat_personal_main.pat_name", "@otherContactInfo.patNameKana": "$journal.pat_personal_main.pat_name_kana"}], "sqlGroup14": [{"No1": "患者情報→削除→更新", "No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_main", "ctl_no": "1", "sqlCode": -600110, "@save2.ordNo": "$journal.pat_coop_detail.ord_no", "insertResult": "{@patId:'''',@facilityCd:'''',@isSame:'''',@isImplant:'''',@isInfect:'''',@isDiabetes:'''',@isBloodSugerExam:'''',@inOutCurrentState:'''',@inOutPlanState:'''',@inOutPlanDate_Date:'''',@patMemoInfoValue:''[]'',@additionInfoValue:''[]'',@chargeStaffInfoValue:''[]'',@patGroupInfoValue:''[]'',@tabooAllergyInfoValue:''[]'',@infectInfoValue:''[]'',@implantInfoValue:''[]'',@tareInfoValue:''{}'',@offWaterInfoValue:''{}'',@deviceSetInfoValue:''{}'',@acceptanceStatusInfoValue:''[]'',@isWheelChair:'''',@medicalCareInfoFlg:'''',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:'''',@schExtStatus:'''',@cardIdm:'''',@oldUpDate_Date:''''}", "updateResult": "{@patId:''pat_id'',@facilityCd:''facility_cd'',@isSame:''is_same'',@isImplant:''is_implant'',@isInfect:''is_infect'',@isDiabetes:''is_diabetes'',@isBloodSugerExam:''is_blood_suger_exam'',@inOutCurrentState:''in_out_current_state'',@inOutPlanState:''in_out_plan_state'',@inOutPlanDate_Date:''in_out_plan_date'',@patMemoInfoValue:''pat_memo_info'',@additionInfoValue:''addition_info'',@chargeStaffInfoValue:''charge_staff_info'',@patGroupInfoValue:''pat_group_info'',@tabooAllergyInfoValue:''taboo_allergy_info'',@infectInfoValue:''infect_info'',@implantInfoValue:''implant_info'',@tareInfoValue:''tare_info'',@offWaterInfoValue:''off_water_info'',@deviceSetInfoValue:''device_set_info'',@acceptanceStatusInfoValue:''acceptance_status_info'',@isWheelChair:''is_wheel_chair'',@medicalCareInfoFlg:'''',@medicalCareInfoValue:''medical_care_info'',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:''sch_ext_end_date'',@schExtStatus:''sch_ext_status'',@cardIdm:''card_idm'',@oldUpDate_Date:''old_up_date''}"}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_main", "ctl_no": "2", "sqlCode": -600016, "@inOutClass": "1", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}], "sqlGroup15": [{"No1": "患者情報→削除→更新", "No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_main", "ctl_no": "1", "sqlCode": -600110, "@save2.ordNo": "$journal.pat_coop_detail.ord_no"}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_main", "ctl_no": "2", "sqlCode": 9105, "@infectInfo1": "$journal.pat_main.infect_info1", "@infectInfo2": "$journal.pat_main.infect_info2", "@infectInfo3": "$journal.pat_main.infect_info3", "@infectInfo4": "$journal.pat_main.infect_info4", "@infectInfo5": "$journal.pat_main.infect_info5", "@infectInfo6": "$journal.pat_main.infect_info6", "@infectInfo7": "$journal.pat_main.infect_info7", "@infectInfo8": "$journal.pat_main.infect_info8", "@infectInfo9": "$journal.pat_main.infect_info9", "@infectInfo10": "$journal.pat_main.infect_info10", "@infectInfo11": "$journal.pat_main.infect_info11", "@infectInfo12": "$journal.pat_main.infect_info12", "@infectInfo13": "$journal.pat_main.infect_info13", "@infectInfo14": "$journal.pat_main.infect_info14", "@infectInfo15": "$journal.pat_main.infect_info15", "@infectInfo16": "$journal.pat_main.infect_info16", "@infectInfo17": "$journal.pat_main.infect_info17", "@infectInfo18": "$journal.pat_main.infect_info18", "@infectInfo19": "$journal.pat_main.infect_info19", "@infectInfo20": "$journal.pat_main.infect_info20", "@tabooAllergyInfo": "$journal.pat_main.taboo_allergy_info", "@chargeStaffInfo.staffCd": "$journal.pat_main.charge_staff_info.staff_cd"}], "sqlGroup16": [{"No1": "患者情報→削除→更新", "No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_unique", "ctl_no": "1", "sqlCode": -600111, "@save2.ordNo": "$journal.pat_coop_detail.ord_no", "insertResult": "{@patId:'''', @facilityCd:'''', @medicalHstInfoValue:''[]'', @inOutVisitHistoryInfoValue:''[]'', @physicalInfoFlg:'''', @physicalInfoValue:''[]''}"}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_unique", "ctl_no": "3", "sqlCode": 9107, "@physicalInfo.dw": "$journal.pat_unique.physical_info.dw", "@physicalInfo.height": "$journal.pat_unique.physical_info.height", "@physicalInfo.ctrWeight": "$journal.pat_unique.physical_info.ctr_weight", "@physicalInfo.orderClass": "1"}], "sqlGroup17": [{"No1": "指示情報→登録・更新", "No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_coop_detail", "ctl_no": "1", "sqlCode": 9111, "insertResult": "{@coopSaveNo:'''', @facilityCd:'''', @patId:'''', @save1:'''', @save1Flg:'''', @save2Flg:'''', @save2.ord_no:'''', @save2.instruction_doctor_generation_no:'''', @save2.dialysis_type:'''', @save2.dialysis_course:'''', @save2.dialysis_pattern:'''', @save2.start_date_regular:'''', @save2.end_date_regular:'''', @save2.implementation_place:'''', @save2.update_terminal:'''', @save2.addition_generation_no:'''', @save2.blood_purification_method:'''', @save2.blood_purification_generation_no:'''', @save2.updater:'''', @save2.updater_generation_no:'''', @save3:'''', @save4:'''', @save5:'''', @save6:'''', @save7:'''', @save8:'''', @save9:'''', @save10:'''', @isDisp:'''', @isDel:'''', @userId:'''', @upDate_Date:'''', @regDate_Date:''''}", "updateResult": "{@coopSaveNo:''coop_save_no'', @facilityCd:''facility_cd'', @patId:''pat_id'', @save1Value:''save_1'', @save1Flg:'''', @save2Flg:'''', @save2Value:''save_2'', @save2.ord_no:'''', @save2.instruction_doctor_generation_no:'''', @save2.dialysis_type:'''', @save2.dialysis_course:'''', @save2.dialysis_pattern:'''', @save2.start_date_regular:'''', @save2.end_date_regular:'''', @save2.implementation_place:'''', @save2.update_terminal:'''', @save2.addition_generation_no:'''', @save2.blood_purification_method:'''', @save2.blood_purification_generation_no:'''', @save2.updater:'''', @save2.updater_generation_no:'''', @save3:''save_3'', @save4:''save_4'', @save5:''save_5'', @save6:''save_6'', @save7:''save_7'', @save8:''save_8'', @save9:''save_9'', @save10:''save_10'', @isDisp:''is_disp'', @isDel:''is_del'', @userId:''user_id'', @upDate_Date:''up_date'', @regDate_Date:''reg_date''}"}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_coop_detail", "ctl_no": "3", "sqlCode": -600107, "@save2.ordNo": "$journal.pat_coop_detail.ord_no"}], "sqlGroup18": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "患者死亡退院情報連携", "No3": "患者の状態を『死亡』として、患者情報を登録します。", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "@isDie": "0", "ctl_no": "2", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -600013, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "2", "@severityCd": "$journal.pat_personal_main.severity_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@transportCd": "$journal.pat_personal_main.transport_cd", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}], "sqlGroup19": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "No3": "NEC場合、[死亡患者、連絡先情報、透析困難情報]を更新する。", "No4": "死亡退院日が空白の場合は「死亡患者 = 対象外」で登録、空白でない場合は「死亡患者 = 対象」で登録します。", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}, {"No2": "患者死亡退院情報連携", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "2", "sqlCode": 9102}, {"No2": "患者死亡退院情報連携", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "3", "sqlCode": 9103, "@otherContactInfo.tel1": "$journal.pat_personal_main.other_contact_info.tel1", "@otherContactInfo.zipCd": "$journal.pat_personal_main.other_contact_info.zip_cd", "@otherContactInfo.address": "$journal.pat_personal_main.other_contact_info.address", "@otherContactInfo.patName": "$journal.pat_personal_main.pat_name", "@otherContactInfo.patNameKana": "$journal.pat_personal_main.pat_name_kana"}], "sqlGroup20": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201, "insertResult": "{@patId:'''',@facilityCd:'''',@isSame:'''',@isImplant:'''',@isInfect:'''',@isDiabetes:'''',@isBloodSugerExam:'''',@inOutCurrentState:'''',@inOutPlanState:'''',@inOutPlanDate_Date:'''',@patMemoInfoValue:''[]'',@additionInfoValue:''[]'',@chargeStaffInfoValue:''[]'',@patGroupInfoValue:''[]'',@tabooAllergyInfoValue:''[]'',@infectInfoValue:''[]'',@implantInfoValue:''[]'',@tareInfoValue:''{}'',@offWaterInfoValue:''{}'',@deviceSetInfoValue:''{}'',@acceptanceStatusInfoValue:''[]'',@isWheelChair:'''',@medicalCareInfoFlg:'''',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:'''',@schExtStatus:'''',@cardIdm:'''',@oldUpDate_Date:''''}", "updateResult": "{@patId:''pat_id'',@facilityCd:''facility_cd'',@isSame:''is_same'',@isImplant:''is_implant'',@isInfect:''is_infect'',@isDiabetes:''is_diabetes'',@isBloodSugerExam:''is_blood_suger_exam'',@inOutCurrentState:''in_out_current_state'',@inOutPlanState:''in_out_plan_state'',@inOutPlanDate_Date:''in_out_plan_date'',@patMemoInfoValue:''pat_memo_info'',@additionInfoValue:''addition_info'',@chargeStaffInfoValue:''charge_staff_info'',@patGroupInfoValue:''pat_group_info'',@tabooAllergyInfoValue:''taboo_allergy_info'',@infectInfoValue:''infect_info'',@implantInfoValue:''implant_info'',@tareInfoValue:''tare_info'',@offWaterInfoValue:''off_water_info'',@deviceSetInfoValue:''device_set_info'',@acceptanceStatusInfoValue:''acceptance_status_info'',@isWheelChair:''is_wheel_chair'',@medicalCareInfoFlg:'''',@medicalCareInfoValue:''medical_care_info'',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:''sch_ext_end_date'',@schExtStatus:''sch_ext_status'',@cardIdm:''card_idm'',@oldUpDate_Date:''old_up_date''}"}, {"No2": "患者死亡退院情報連携", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "2", "sqlCode": -600014, "@inOutClass": "1", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}, {"No2": "患者死亡退院情報連携", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "3", "sqlCode": -600016, "@inOutClass": "1", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}], "sqlGroup21": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201}, {"No2": "患者死亡退院情報連携", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "2", "sqlCode": 9104}, {"No2": "患者死亡退院情報連携", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "3", "sqlCode": 9105, "@infectInfo1": "$journal.pat_main.infect_info1", "@infectInfo2": "$journal.pat_main.infect_info2", "@infectInfo3": "$journal.pat_main.infect_info3", "@infectInfo4": "$journal.pat_main.infect_info4", "@infectInfo5": "$journal.pat_main.infect_info5", "@infectInfo6": "$journal.pat_main.infect_info6", "@infectInfo7": "$journal.pat_main.infect_info7", "@infectInfo8": "$journal.pat_main.infect_info8", "@infectInfo9": "$journal.pat_main.infect_info9", "@infectInfo10": "$journal.pat_main.infect_info10", "@infectInfo11": "$journal.pat_main.infect_info11", "@infectInfo12": "$journal.pat_main.infect_info12", "@infectInfo13": "$journal.pat_main.infect_info13", "@infectInfo14": "$journal.pat_main.infect_info14", "@infectInfo15": "$journal.pat_main.infect_info15", "@infectInfo16": "$journal.pat_main.infect_info16", "@infectInfo17": "$journal.pat_main.infect_info17", "@infectInfo18": "$journal.pat_main.infect_info18", "@infectInfo19": "$journal.pat_main.infect_info19", "@infectInfo20": "$journal.pat_main.infect_info20", "@tabooAllergyInfo": "$journal.pat_main.taboo_allergy_info", "@chargeStaffInfo.staffCd": "$journal.pat_main.charge_staff_info.staff_cd"}], "sqlGroup22": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_unique", "ctl_no": "1", "sqlCode": 1601, "insertResult": "{@patId:'''', @facilityCd:'''', @medicalHstInfoValue:''[]'', @inOutVisitHistoryInfoValue:''[]'', @physicalInfoFlg:'''', @physicalInfoValue:''[]''}"}, {"No2": "患者死亡退院情報連携", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_unique", "ctl_no": "2", "sqlCode": 9106, "@physicalInfo.dw": "$journal.pat_unique.physical_info.dw", "@physicalInfo.height": "$journal.pat_unique.physical_info.height", "@physicalInfo.ctrWeight": "$journal.pat_unique.physical_info.ctr_weight", "@physicalInfo.orderClass": "1"}], "sqlGroup23": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "患者死亡退院情報連携", "No3": "患者情報更新", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "3", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -600015, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "1", "@severityCd": "$journal.pat_personal_main.severity_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@transportCd": "$journal.pat_personal_main.transport_cd", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}], "sqlGroup24": [{"No1": "患者イベント→登録", "No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_event", "ctl_no": "1", "sqlCode": -600112, "insertResult": "{@facilityCd:'''', @patId:''''}"}, {"No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_event", "ctl_no": "2", "sqlCode": -600113, "@dispUserId": "$journal.pat_main.charge_staff_info.staff_cd", "@save2.ordNo": "$journal.pat_coop_detail.ord_no"}], "sqlGroup25": [{"No1": "患者情報→登録・更新", "No2": "連携共通", "crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "連携共通", "No3": "患者の状態を『存命』から『死亡』に変更します。", "crud": "U", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "3", "sqlCode": -600105, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@dieDate_Date": "$journal.pat_personal_main.die_date"}]}, "CoopIniConvUtil": {"$journal.pat_personal_main.pat_sex": "CONV_SEX_TO_FNW", "$journal.pat_personal_main.pat_blood_type_rh": "CONV_BLOOD_RH_TO_FNW", "$journal.pat_personal_main.pat_blood_type_abo": "CONV_BLOOD_ABO_TO_FNW"}}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010010, 'N_hosp', 'ini_dial', '', 'R', '初回指示情報', 'text', 'NEC想定透析初回指示', 'MEGA', '初回指示情報ver1/TSHPlus', '1', '<root name="透析申込(初回指示情報ver1)">
  <item name="コマンド名" len="8" type="string" col="$journal.const.command_name" value="const:C-DIRECTVer1"/>
  <item name="処理区分" len="1" col="$journal.const.crud" type="string" value="json:{&quot;A&quot;:&quot;C&quot;,&quot;D&quot;:&quot;D&quot;,&quot;U&quot;:&quot;U&quot;,&quot;Z&quot;:&quot;Z&quot;}"/>
  <item name="病院コード" len="2" type="string"/>
  <item name="患者情報.患者番号" len="10" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
  <item name="患者情報.患者氏名" len="40" col="$journal.pat_personal_main.pat_name" type="string"/>
  <item name="患者情報.患者カナ氏名" len="20" col="$journal.pat_personal_main.pat_name_kana" type="string"/>
  <item name="患者情報.性別" len="1" col="$journal.pat_personal_main.pat_sex" type="string"/>
  <item name="患者情報.生年月日" len="8" col="$journal.pat_personal_main.pat_birthday" type="string"/>
  <item name="患者情報.郵便番号１" len="7" col="$journal.pat_personal_main.pat_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所１" len="100" col="$journal.pat_personal_main.pat_contact_info.address" type="string"/>
  <item name="患者情報.電話番号１" len="12" col="$journal.pat_personal_main.pat_contact_info.tel1" type="string"/>
  <item name="患者情報.郵便番号２" len="7" col="$journal.pat_personal_main.other_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所２" len="100" col="$journal.pat_personal_main.other_contact_info.address" type="string"/>
  <item name="患者情報.電話番号２" len="12" col="$journal.pat_personal_main.other_contact_info.tel1" type="string"/>
  <item name="病棟コード" len="4" col="$journal.pat_main.medical_care_info.ward_cd" type="string"/>
  <item name="病棟名称" len="20" type="string" info="対象外"/>
  <item name="病室コード" len="4" type="string" info="対象外"/>
  <item name="病室名称" len="20" type="string" info="対象外"/>
  <item name="看護区分" len="2" type="string" info="対象外"/>
  <item name="患者区分" len="2" col="$journal.pat_personal_main.severity_cd" type="string"/>
  <item name="救護区分" len="2" col="$journal.pat_personal_main.transport_cd" type="string"/>
  <item name="予備区分" len="1" type="string" info="対象外"/>
  <item name="障害情報" len="15" type="string" info="対象外"/>
  <item name="身長" len="5" col="$journal.pat_unique.physical_info.height" type="string" info="対象外"/>
  <item name="体重" len="5" col="$journal.pat_unique.physical_info.ctr_weight" type="string" info="対象外"/>
  <item name="血液型ＡＢＯ" len="1" col="$journal.pat_personal_main.pat_blood_type_abo" type="string"/>
  <item name="血液型Ｒｈ" len="1" col="$journal.pat_personal_main.pat_blood_type_rh" type="string"/>
  <item name="感染情報1" len="1" col="$journal.pat_main.infect_info1" type="string" info="1バイトのフラグ"/>
  <item name="感染情報2" len="1" col="$journal.pat_main.infect_info2" type="string" info="1バイトのフラグ"/>
  <item name="感染情報3" len="1" col="$journal.pat_main.infect_info3" type="string" info="1バイトのフラグ"/>
  <item name="感染情報4" len="1" col="$journal.pat_main.infect_info4" type="string" info="1バイトのフラグ"/>
  <item name="感染情報5" len="1" col="$journal.pat_main.infect_info5" type="string" info="1バイトのフラグ"/>
  <item name="感染情報6" len="1" col="$journal.pat_main.infect_info6" type="string" info="1バイトのフラグ"/>
  <item name="感染情報7" len="1" col="$journal.pat_main.infect_info7" type="string" info="1バイトのフラグ"/>
  <item name="感染情報8" len="1" col="$journal.pat_main.infect_info8" type="string" info="1バイトのフラグ"/>
  <item name="感染情報9" len="1" col="$journal.pat_main.infect_info9" type="string" info="1バイトのフラグ"/>
  <item name="感染情報10" len="1" col="$journal.pat_main.infect_info10" type="string" info="1バイトのフラグ"/>
  <item name="感染情報11" len="1" col="$journal.pat_main.infect_info11" type="string" info="1バイトのフラグ"/>
  <item name="感染情報12" len="1" col="$journal.pat_main.infect_info12" type="string" info="1バイトのフラグ"/>
  <item name="感染情報13" len="1" col="$journal.pat_main.infect_info13" type="string" info="1バイトのフラグ"/>
  <item name="感染情報14" len="1" col="$journal.pat_main.infect_info14" type="string" info="1バイトのフラグ"/>
  <item name="感染情報15" len="1" col="$journal.pat_main.infect_info15" type="string" info="1バイトのフラグ"/>
  <item name="感染情報16" len="1" col="$journal.pat_main.infect_info16" type="string" info="1バイトのフラグ"/>
  <item name="感染情報17" len="1" col="$journal.pat_main.infect_info17" type="string" info="1バイトのフラグ"/>
  <item name="感染情報18" len="1" col="$journal.pat_main.infect_info18" type="string" info="1バイトのフラグ"/>
  <item name="感染情報19" len="1" col="$journal.pat_main.infect_info19" type="string" info="1バイトのフラグ"/>
  <item name="感染情報20" len="1" col="$journal.pat_main.infect_info20" type="string" info="1バイトのフラグ"/>
  <item name="感染コメント" len="60" type="string" info="対象外"/>
  <item name="薬剤禁忌情報" len="20" col="$journal.pat_main.taboo_allergy_info" type="string" info="20バイトのフラグ"/>
  <item name="禁忌コメント" len="60" type="string"/>
  <item name="妊娠日" len="8" type="string" info="対象外"/>
  <item name="死亡退院日" len="8" col="$journal.pat_personal_main.die_date" type="string"/>
  <item name="予備" len="30" type="string" info="対象外"/>
  <item name="オーダ番号" len="16" col="$journal.pat_coop_detail.ord_no" type="string"/>
  <item name="情報区分" len="1" type="string"/>
  <item name="指示科" len="2" col="$journal.pat_main.medical_care_info.main_course_cd" type="string"/>
  <item name="指示科名称" len="20" type="string" info="対象外"/>
  <item name="指示医" len="10" col="$journal.pat_main.charge_staff_info.staff_cd" type="string"/>
  <item name="指示医名称" len="20" type="string"/>
  <item name="指示医世代番号" len="1" col="$journal.pat_coop_detail.instruction_doctor_generation_no" type="string"/>
  <item name="保険コード01" len="3" col="$journal.pat_insurance_1.coop_code" type="string"/>
  <item name="保険コード02" len="3" col="$journal.pat_insurance_2.coop_code" type="string"/>
  <item name="保険コード03" len="3" col="$journal.pat_insurance_3.coop_code" type="string"/>
  <item name="保険コード04" len="3" col="$journal.pat_insurance_4.coop_code" type="string" info="対象外"/>
  <item name="保険コード05" len="3" col="$journal.pat_insurance_5.coop_code" type="string" info="対象外"/>
  <item name="透析種別" len="1" col="$journal.pat_coop_detail.dialysis_type" type="string" info="対象外"/>
  <item name="透析コース" len="6" col="$journal.pat_coop_detail.dialysis_course" type="string" info="対象外"/>
  <item name="透析コース名称" len="60" type="string" info="対象外"/>
  <item name="透析パターン" len="6" col="$journal.pat_coop_detail.dialysis_pattern" type="string"/>
  <item name="透析パターン名称" len="60" type="string" info="対象外"/>
  <item name="開始日（定期）" len="8" col="$journal.pat_coop_detail.start_date_regular" type="string"/>
  <item name="終了日（定期）" len="8" col="$journal.pat_coop_detail.end_date_regular" type="string"/>
  <item name="透析日１（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日２（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日３（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日４（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日５（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日６（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日７（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日８（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日９（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日１０（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日１１（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日１２（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日１３（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日１４（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析日１５（臨時）" len="8" type="string" info="対象外"/>
  <item name="透析導入日" len="8" col="$journal.pat_main.medical_care_info.dialysis_start_date" type="string"/>
  <item name="実施場所" len="6" col="$journal.pat_coop_detail.implementation_place" type="string"/>
  <item name="実施場所名称" len="60" type="string" info="対象外"/>
  <item name="加算（患者に付随する加算）" len="6" col="$journal.pat_personal_main.dial_diff_com_info.dial_diff_cd" type="string"/>
  <item name="加算世代番号" len="1" col="$journal.pat_coop_detail.addition_generation_no" type="string"/>
  <item name="加算名称" len="60" type="string" info="対象外"/>
  <item name="ベッド予約番号" len="13" type="string" info="対象外"/>
  <item name="使用ベッド" len="6" type="string" info="対象外"/>
  <item name="使用ベッド名称" len="60" type="string" info="対象外"/>
  <item name="ベッド予約時間帯" len="1" col="$journal.pat_coop_detail.kur_cd1" type="string" info="対象外"/>
  <item name="ブラッドアクセス" len="6" col="$journal.pat_coop_detail.va3" type="string"/>
  <item name="ブラッドアクセス名称" len="60" type="string"/>
  <item name="部位" len="6" col="$journal.pat_coop_detail.va_direct" type="string"/>
  <item name="部位名称" len="60" type="string" info="対象外"/>
  <item name="ＤＷ" len="4" col="$journal.pat_coop_detail.dw" type="string"/>
  <item name="血液浄化法" len="6" col="$journal.pat_coop_detail.blood_purification_method" type="string"/>
  <item name="血液浄化法世代番号" len="1" col="$journal.pat_coop_detail.blood_purification_generation_no" type="string"/>
  <item name="血液浄化法名称" len="60" type="string"/>
  <item name="依頼オーダ番号" len="16" type="string" info="対象外"/>
  <item name="実施オーダ番号" len="16" type="string" info="対象外"/>
  <item name="進捗" len="2" type="string" info="対象外"/>
  <item name="血液浄化方法　医事コード" len="6" type="string" info="対象外"/>
  <item name="血液浄化方法　医事世代コード" len="1" type="string" info="対象外"/>
  <item name="新規登録日" len="8" type="string" info="対象外"/>
  <item name="新規登録時間" len="6" type="string" info="対象外"/>
  <item name="更新日" len="8" type="string" info="対象外"/>
  <item name="更新時間" len="6" type="string" info="対象外"/>
  <item name="更新端末" len="10" col="$journal.pat_coop_detail.update_terminal" type="string"/>
  <item name="更新者" len="10" col="$journal.pat_coop_detail.updater" type="string"/>
  <item name="更新者世代番号" len="1" col="$journal.pat_coop_detail.updater_generation_no" type="string"/>
  <item name="予備" len="30" type="string" info="対象外"/>
  <occ name="オーダ指示詳細数" len="5" col="$journal.detail_number" type="string" detail="透析指示オーダ明細"/>
  <occ name="オーダ指示コメント数" len="5" col="$journal.comment_number" type="string" detail="透析コメント明細"/>
</root>
', '{"json-key": {"{\"A\":\"C\",\"D\":\"D\",\"U\":\"U\",\"Z\":\"Z\"}": {"A": "C", "D": "D", "U": "U", "Z": "Z"}}}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010011, 'N_hosp', 'ini_dial', '', 'R', '初回指示情報', 'text', 'NEC想定透析初回指示', 'MEGA', '初回指示情報ver2/Standard', '1', '<root name="透析申込(初回指示情報ver2)">
  <item name="空白" len="20" type="string"/>
  <item name="電文長" len="12" type="string"/>
  <item name="コマンド名" len="8" type="string" col="$journal.const.command_name" value="const:C-DIRECTVer2"/>
  <item name="処理区分" len="1" type="string" col="$journal.const.crud" value="const:C"/>
  <item name="病院コード" len="2" type="string"/>
  <item name="患者情報.患者番号" len="10" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
  <item name="患者情報.患者氏名" len="40" col="$journal.pat_personal_main.pat_name" type="string"/>
  <item name="患者情報.患者カナ氏名" len="20" col="$journal.pat_personal_main.pat_name_kana" type="string"/>
  <item name="患者情報.性別" len="1" col="$journal.pat_personal_main.pat_sex" type="string"/>
  <item name="患者情報.生年月日" len="8" col="$journal.pat_personal_main.pat_birthday" type="string"/>
  <item name="患者情報.郵便番号１" len="7" col="$journal.pat_personal_main.pat_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所１" len="100" col="$journal.pat_personal_main.pat_contact_info.address" type="string"/>
  <item name="患者情報.電話番号１" len="12" col="$journal.pat_personal_main.pat_contact_info.tel1" type="string"/>
  <item name="患者情報.郵便番号２" len="7" col="$journal.pat_personal_main.other_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所２" len="100" col="$journal.pat_personal_main.other_contact_info.address" type="string"/>
  <item name="患者情報.電話番号２" len="12" col="$journal.pat_personal_main.other_contact_info.tel1" type="string"/>
  <item name="病棟コード" len="4" col="$journal.pat_main.medical_care_info.ward_cd" type="string"/>
  <item name="病棟名称" len="20" type="string" info="対象外"/>
  <item name="病室コード" len="4" type="string" info="対象外"/>
  <item name="病室名称" len="20" type="string" info="対象外"/>
  <item name="看護区分" len="2" type="string" info="対象外"/>
  <item name="患者区分" len="2" col="$journal.pat_personal_main.severity_cd" type="string"/>
  <item name="救護区分" len="2" col="$journal.pat_personal_main.transport_cd" type="string"/>
  <item name="予備区分" len="1" type="string" info="対象外"/>
  <item name="障害情報" len="15" type="string" info="対象外"/>
  <item name="身長" len="5" col="$journal.pat_unique.physical_info.height" type="string" info="対象外"/>
  <item name="体重" len="5" col="$journal.pat_unique.physical_info.ctr_weight" type="string" info="対象外"/>
  <item name="血液型ＡＢＯ" len="1" col="$journal.pat_personal_main.pat_blood_type_abo" type="string"/>
  <item name="血液型Ｒｈ" len="1" col="$journal.pat_personal_main.pat_blood_type_rh" type="string"/>
  <item name="感染情報1" len="1" col="$journal.pat_main.infect_info1" type="string" info="1バイトのフラグ"/>
  <item name="感染情報2" len="1" col="$journal.pat_main.infect_info2" type="string" info="1バイトのフラグ"/>
  <item name="感染情報3" len="1" col="$journal.pat_main.infect_info3" type="string" info="1バイトのフラグ"/>
  <item name="感染情報4" len="1" col="$journal.pat_main.infect_info4" type="string" info="1バイトのフラグ"/>
  <item name="感染情報5" len="1" col="$journal.pat_main.infect_info5" type="string" info="1バイトのフラグ"/>
  <item name="感染情報6" len="1" col="$journal.pat_main.infect_info6" type="string" info="1バイトのフラグ"/>
  <item name="感染情報7" len="1" col="$journal.pat_main.infect_info7" type="string" info="1バイトのフラグ"/>
  <item name="感染情報8" len="1" col="$journal.pat_main.infect_info8" type="string" info="1バイトのフラグ"/>
  <item name="感染情報9" len="1" col="$journal.pat_main.infect_info9" type="string" info="1バイトのフラグ"/>
  <item name="感染情報10" len="1" col="$journal.pat_main.infect_info10" type="string" info="1バイトのフラグ"/>
  <item name="感染情報11" len="1" col="$journal.pat_main.infect_info11" type="string" info="1バイトのフラグ"/>
  <item name="感染情報12" len="1" col="$journal.pat_main.infect_info12" type="string" info="1バイトのフラグ"/>
  <item name="感染情報13" len="1" col="$journal.pat_main.infect_info13" type="string" info="1バイトのフラグ"/>
  <item name="感染情報14" len="1" col="$journal.pat_main.infect_info14" type="string" info="1バイトのフラグ"/>
  <item name="感染情報15" len="1" col="$journal.pat_main.infect_info15" type="string" info="1バイトのフラグ"/>
  <item name="感染情報16" len="1" col="$journal.pat_main.infect_info16" type="string" info="1バイトのフラグ"/>
  <item name="感染情報17" len="1" col="$journal.pat_main.infect_info17" type="string" info="1バイトのフラグ"/>
  <item name="感染情報18" len="1" col="$journal.pat_main.infect_info18" type="string" info="1バイトのフラグ"/>
  <item name="感染情報19" len="1" col="$journal.pat_main.infect_info19" type="string" info="1バイトのフラグ"/>
  <item name="感染情報20" len="1" col="$journal.pat_main.infect_info20" type="string" info="1バイトのフラグ"/>
  <item name="感染コメント" len="60" type="string" info="対象外"/>
  <item name="薬剤禁忌情報" len="20" col="$journal.pat_main.taboo_allergy_info" type="string" info="20バイトのフラグ"/>
  <item name="禁忌コメント" len="60" type="string"/>
  <item name="妊娠日" len="8" type="string" info="対象外"/>
  <item name="死亡退院日" len="8" col="$journal.pat_personal_main.die_date" type="string"/>
  <item name="予備" len="30" type="string" info="対象外"/>
</root>
', '{}'::jsonb, '1', '1', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010012, 'N_hosp', 'ini_dial', '', 'R', '患者情報', 'text', 'NEC想定透析初回指示', 'MEGA', 'テスト用ver1/TSHPlus', '1', '<root name="透析申込(患者情報)">
  <item name="コマンド名" len="8" type="string" col="$journal.const.command_name" value="const:C-KNJUPD"/>
  <item name="処理区分" len="1" type="string" col="$journal.const.crud" value="const:C" info="患者情報・患者死亡退院場合、未使用。固定値「C」を設定しました。"/>
  <item name="病院コード" len="2" type="string"/>
  <item name="患者情報.患者番号" len="10" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
  <item name="患者情報.患者氏名" len="40" col="$journal.pat_personal_main.pat_name" type="string"/>
  <item name="患者情報.患者カナ氏名" len="20" col="$journal.pat_personal_main.pat_name_kana" type="string"/>
  <item name="患者情報.性別" len="1" col="$journal.pat_personal_main.pat_sex" type="string"/>
  <item name="患者情報.生年月日" len="8" col="$journal.pat_personal_main.pat_birthday" type="string"/>
  <item name="患者情報.郵便番号１" len="7" col="$journal.pat_personal_main.pat_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所１" len="100" col="$journal.pat_personal_main.pat_contact_info.address" type="string"/>
  <item name="患者情報.電話番号１" len="12" col="$journal.pat_personal_main.pat_contact_info.tel1" type="string"/>
  <item name="患者情報.郵便番号２" len="7" col="$journal.pat_personal_main.other_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所２" len="100" col="$journal.pat_personal_main.other_contact_info.address" type="string"/>
  <item name="患者情報.電話番号２" len="12" col="$journal.pat_personal_main.other_contact_info.tel1" type="string"/>
  <item name="病棟コード" len="4" col="$journal.pat_main.medical_care_info.ward_cd" type="string"/>
  <item name="病棟名称" len="20" type="string" info="対象外"/>
  <item name="病室コード" len="4" type="string" info="対象外"/>
  <item name="病室名称" len="20" type="string" info="対象外"/>
  <item name="看護区分" len="2" type="string" info="対象外"/>
  <item name="患者区分" len="2" col="$journal.pat_personal_main.severity_cd" type="string"/>
  <item name="救護区分" len="2" col="$journal.pat_personal_main.transport_cd" type="string"/>
  <item name="予備区分" len="1" type="string" info="対象外"/>
  <item name="障害情報" len="15" type="string" info="対象外"/>
  <item name="身長" len="5" col="$journal.pat_unique.physical_info.height" type="string" info="対象外"/>
  <item name="体重" len="5" col="$journal.pat_unique.physical_info.ctr_weight" type="string" info="対象外"/>
  <item name="血液型ＡＢＯ" len="1" col="$journal.pat_personal_main.pat_blood_type_abo" type="string"/>
  <item name="血液型Ｒｈ" len="1" col="$journal.pat_personal_main.pat_blood_type_rh" type="string"/>
  <item name="感染情報1" len="1" col="$journal.pat_main.infect_info1" type="string" info="1バイトのフラグ"/>
  <item name="感染情報2" len="1" col="$journal.pat_main.infect_info2" type="string" info="1バイトのフラグ"/>
  <item name="感染情報3" len="1" col="$journal.pat_main.infect_info3" type="string" info="1バイトのフラグ"/>
  <item name="感染情報4" len="1" col="$journal.pat_main.infect_info4" type="string" info="1バイトのフラグ"/>
  <item name="感染情報5" len="1" col="$journal.pat_main.infect_info5" type="string" info="1バイトのフラグ"/>
  <item name="感染情報6" len="1" col="$journal.pat_main.infect_info6" type="string" info="1バイトのフラグ"/>
  <item name="感染情報7" len="1" col="$journal.pat_main.infect_info7" type="string" info="1バイトのフラグ"/>
  <item name="感染情報8" len="1" col="$journal.pat_main.infect_info8" type="string" info="1バイトのフラグ"/>
  <item name="感染情報9" len="1" col="$journal.pat_main.infect_info9" type="string" info="1バイトのフラグ"/>
  <item name="感染情報10" len="1" col="$journal.pat_main.infect_info10" type="string" info="1バイトのフラグ"/>
  <item name="感染情報11" len="1" col="$journal.pat_main.infect_info11" type="string" info="1バイトのフラグ"/>
  <item name="感染情報12" len="1" col="$journal.pat_main.infect_info12" type="string" info="1バイトのフラグ"/>
  <item name="感染情報13" len="1" col="$journal.pat_main.infect_info13" type="string" info="1バイトのフラグ"/>
  <item name="感染情報14" len="1" col="$journal.pat_main.infect_info14" type="string" info="1バイトのフラグ"/>
  <item name="感染情報15" len="1" col="$journal.pat_main.infect_info15" type="string" info="1バイトのフラグ"/>
  <item name="感染情報16" len="1" col="$journal.pat_main.infect_info16" type="string" info="1バイトのフラグ"/>
  <item name="感染情報17" len="1" col="$journal.pat_main.infect_info17" type="string" info="1バイトのフラグ"/>
  <item name="感染情報18" len="1" col="$journal.pat_main.infect_info18" type="string" info="1バイトのフラグ"/>
  <item name="感染情報19" len="1" col="$journal.pat_main.infect_info19" type="string" info="1バイトのフラグ"/>
  <item name="感染情報20" len="1" col="$journal.pat_main.infect_info20" type="string" info="1バイトのフラグ"/>
  <item name="感染コメント" len="60" type="string" info="対象外"/>
  <item name="薬剤禁忌情報" len="20" col="$journal.pat_main.taboo_allergy_info" type="string" info="20バイトのフラグ"/>
  <item name="禁忌コメント" len="60" type="string"/>
  <item name="妊娠日" len="8" type="string" info="対象外"/>
  <item name="死亡退院日" len="8" col="$journal.pat_personal_main.die_date" type="string"/>
  <item name="予備" len="30" type="string" info="対象外"/>
</root>
', '{}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010013, 'N_hosp', 'ini_dial', '', 'R', '患者死亡退院情報', 'text', 'NEC想定透析初回指示', 'MEGA', 'テスト用ver1/TSHPlus', '1', '<root name="透析申込(患者死亡退院情報)">
  <item name="コマンド名" len="8" type="string" col="$journal.const.command_name" value="const:C-KNJDEL"/>
  <item name="処理区分" len="1" type="string" col="$journal.const.crud" value="const:C" info="患者情報・患者死亡退院場合、未使用。固定値「C」を設定しました。"/>
  <item name="病院コード" len="2" type="string"/>
  <item name="患者情報.患者番号" len="10" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
  <item name="患者情報.患者氏名" len="40" col="$journal.pat_personal_main.pat_name" type="string"/>
  <item name="患者情報.患者カナ氏名" len="20" col="$journal.pat_personal_main.pat_name_kana" type="string"/>
  <item name="患者情報.性別" len="1" col="$journal.pat_personal_main.pat_sex" type="string"/>
  <item name="患者情報.生年月日" len="8" col="$journal.pat_personal_main.pat_birthday" type="string"/>
  <item name="患者情報.郵便番号１" len="7" col="$journal.pat_personal_main.pat_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所１" len="100" col="$journal.pat_personal_main.pat_contact_info.address" type="string"/>
  <item name="患者情報.電話番号１" len="12" col="$journal.pat_personal_main.pat_contact_info.tel1" type="string"/>
  <item name="患者情報.郵便番号２" len="7" col="$journal.pat_personal_main.other_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所２" len="100" col="$journal.pat_personal_main.other_contact_info.address" type="string"/>
  <item name="患者情報.電話番号２" len="12" col="$journal.pat_personal_main.other_contact_info.tel1" type="string"/>
  <item name="病棟コード" len="4" col="$journal.pat_main.medical_care_info.ward_cd" type="string"/>
  <item name="病棟名称" len="20" type="string" info="対象外"/>
  <item name="病室コード" len="4" type="string" info="対象外"/>
  <item name="病室名称" len="20" type="string" info="対象外"/>
  <item name="看護区分" len="2" type="string" info="対象外"/>
  <item name="患者区分" len="2" col="$journal.pat_personal_main.severity_cd" type="string"/>
  <item name="救護区分" len="2" col="$journal.pat_personal_main.transport_cd" type="string"/>
  <item name="予備区分" len="1" type="string" info="対象外"/>
  <item name="障害情報" len="15" type="string" info="対象外"/>
  <item name="身長" len="5" col="$journal.pat_unique.physical_info.height" type="string" info="対象外"/>
  <item name="体重" len="5" col="$journal.pat_unique.physical_info.ctr_weight" type="string" info="対象外"/>
  <item name="血液型ＡＢＯ" len="1" col="$journal.pat_personal_main.pat_blood_type_abo" type="string"/>
  <item name="血液型Ｒｈ" len="1" col="$journal.pat_personal_main.pat_blood_type_rh" type="string"/>
  <item name="感染情報1" len="1" col="$journal.pat_main.infect_info1" type="string" info="1バイトのフラグ"/>
  <item name="感染情報2" len="1" col="$journal.pat_main.infect_info2" type="string" info="1バイトのフラグ"/>
  <item name="感染情報3" len="1" col="$journal.pat_main.infect_info3" type="string" info="1バイトのフラグ"/>
  <item name="感染情報4" len="1" col="$journal.pat_main.infect_info4" type="string" info="1バイトのフラグ"/>
  <item name="感染情報5" len="1" col="$journal.pat_main.infect_info5" type="string" info="1バイトのフラグ"/>
  <item name="感染情報6" len="1" col="$journal.pat_main.infect_info6" type="string" info="1バイトのフラグ"/>
  <item name="感染情報7" len="1" col="$journal.pat_main.infect_info7" type="string" info="1バイトのフラグ"/>
  <item name="感染情報8" len="1" col="$journal.pat_main.infect_info8" type="string" info="1バイトのフラグ"/>
  <item name="感染情報9" len="1" col="$journal.pat_main.infect_info9" type="string" info="1バイトのフラグ"/>
  <item name="感染情報10" len="1" col="$journal.pat_main.infect_info10" type="string" info="1バイトのフラグ"/>
  <item name="感染情報11" len="1" col="$journal.pat_main.infect_info11" type="string" info="1バイトのフラグ"/>
  <item name="感染情報12" len="1" col="$journal.pat_main.infect_info12" type="string" info="1バイトのフラグ"/>
  <item name="感染情報13" len="1" col="$journal.pat_main.infect_info13" type="string" info="1バイトのフラグ"/>
  <item name="感染情報14" len="1" col="$journal.pat_main.infect_info14" type="string" info="1バイトのフラグ"/>
  <item name="感染情報15" len="1" col="$journal.pat_main.infect_info15" type="string" info="1バイトのフラグ"/>
  <item name="感染情報16" len="1" col="$journal.pat_main.infect_info16" type="string" info="1バイトのフラグ"/>
  <item name="感染情報17" len="1" col="$journal.pat_main.infect_info17" type="string" info="1バイトのフラグ"/>
  <item name="感染情報18" len="1" col="$journal.pat_main.infect_info18" type="string" info="1バイトのフラグ"/>
  <item name="感染情報19" len="1" col="$journal.pat_main.infect_info19" type="string" info="1バイトのフラグ"/>
  <item name="感染情報20" len="1" col="$journal.pat_main.infect_info20" type="string" info="1バイトのフラグ"/>
  <item name="感染コメント" len="60" type="string" info="対象外"/>
  <item name="薬剤禁忌情報" len="20" col="$journal.pat_main.taboo_allergy_info" type="string" info="20バイトのフラグ"/>
  <item name="禁忌コメント" len="60" type="string"/>
  <item name="妊娠日" len="8" type="string" info="対象外"/>
  <item name="死亡退院日" len="8" col="$journal.pat_personal_main.die_date" type="string"/>
  <item name="予備" len="30" type="string" info="対象外"/>
</root>
', '{}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010014, 'N_hosp', 'ini_dial', '', 'R', 'pre', 'text', 'NEC想定透析初回指示', 'MEGA', 'テスト用ver2/Standard', '1', '<root name="透析申込(pre)">
  <item name="空白" len="20" type="string"/>
  <item name="電文長" len="12" type="string"/>
  <item name="コマンド名" len="8" type="string" key="command_name"/>
  <item name="処理区分" len="1" type="string"/>
  <item name="病院コード" len="2" type="string"/>
  <item name="患者情報.患者番号" len="10" type="string"/>
  <item name="患者情報.患者氏名" len="40" type="string"/>
  <item name="患者情報.患者カナ氏名" len="20" type="string"/>
  <item name="患者情報.性別" len="1" type="string"/>
  <item name="患者情報.生年月日" len="8" type="string"/>
  <item name="患者情報.郵便番号１" len="7" type="string"/>
  <item name="患者情報.患者住所１" len="100" type="string"/>
  <item name="患者情報.電話番号１" len="12" type="string"/>
  <item name="患者情報.郵便番号２" len="7" type="string"/>
  <item name="患者情報.患者住所２" len="100" type="string"/>
  <item name="患者情報.電話番号２" len="12" type="string"/>
  <item name="病棟コード" len="4" type="string"/>
  <item name="病棟名称" len="20" type="string"/>
  <item name="病室コード" len="4" type="string"/>
  <item name="病室名称" len="20" type="string"/>
  <item name="看護区分" len="2" type="string"/>
  <item name="患者区分" len="2" type="string"/>
  <item name="救護区分" len="2" type="string"/>
  <item name="予備区分" len="1" type="string"/>
  <item name="障害情報" len="15" type="string"/>
  <item name="身長" len="5" type="string"/>
  <item name="体重" len="5" type="string"/>
  <item name="血液型ＡＢＯ" len="1" type="string"/>
  <item name="血液型Ｒｈ" len="1" type="string"/>
  <item name="感染情報" len="20" type="string"/>
  <item name="感染コメント" len="60" type="string"/>
  <item name="薬剤禁忌情報" len="20" type="string"/>
  <item name="禁忌コメント" len="60" type="string"/>
  <item name="妊娠日" len="8" type="string"/>
  <item name="死亡退院日" len="8" type="string"/>
  <item name="予備" len="30" type="string"/>
</root>
', '{"key": {"command_name": {"C-DIRECT": "初回指示情報", "C-KNJDEL": "患者死亡退院情報", "C-KNJUPD": "患者情報"}}, "dataset": {"sqlGroup1": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "@isDie": "0", "ctl_no": "2", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -600013, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "1", "@severityCd": "$journal.pat_personal_main.severity_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@transportCd": "$journal.pat_personal_main.transport_cd", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "3", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -600015, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "1", "@severityCd": "$journal.pat_personal_main.severity_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@transportCd": "$journal.pat_personal_main.transport_cd", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}], "sqlGroup2": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "No3": "NEC場合、病棟コードより、[入外区分]を更新する。病棟コードが空白の場合は「入外区分 = 外来」で登録、空白でない場合は「入外区分 = 入院」で登録します。", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "No3": "NEC場合、[入外区分]の更新処理、pat_personal_mainを更新する。または、pat_mainから、データを取得する。tableにpat_mainを設定しました。", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "2", "sqlCode": 9101, "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd"}], "sqlGroup3": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "No3": "NEC場合、[死亡患者、連絡先情報、透析困難情報]を更新する。", "No4": "死亡退院日が空白の場合は「死亡患者 = 対象外」で登録、空白でない場合は「死亡患者 = 対象」で登録します。", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "2", "sqlCode": 9102}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "3", "sqlCode": 9103, "@otherContactInfo.tel1": "$journal.pat_personal_main.other_contact_info.tel1", "@otherContactInfo.zipCd": "$journal.pat_personal_main.other_contact_info.zip_cd", "@otherContactInfo.address": "$journal.pat_personal_main.other_contact_info.address", "@otherContactInfo.patName": "$journal.pat_personal_main.pat_name", "@otherContactInfo.patNameKana": "$journal.pat_personal_main.pat_name_kana"}], "sqlGroup4": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201, "insertResult": "{@patId:'''',@facilityCd:'''',@isSame:'''',@isImplant:'''',@isInfect:'''',@isDiabetes:'''',@isBloodSugerExam:'''',@inOutCurrentState:'''',@inOutPlanState:'''',@inOutPlanDate_Date:'''',@patMemoInfoValue:''[]'',@additionInfoValue:''[]'',@chargeStaffInfoValue:''[]'',@patGroupInfoValue:''[]'',@tabooAllergyInfoValue:''[]'',@infectInfoValue:''[]'',@implantInfoValue:''[]'',@tareInfoValue:''{}'',@offWaterInfoValue:''{}'',@deviceSetInfoValue:''{}'',@acceptanceStatusInfoValue:''[]'',@isWheelChair:'''',@medicalCareInfoFlg:'''',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:'''',@schExtStatus:'''',@cardIdm:'''',@oldUpDate_Date:''''}", "updateResult": "{@patId:''pat_id'',@facilityCd:''facility_cd'',@isSame:''is_same'',@isImplant:''is_implant'',@isInfect:''is_infect'',@isDiabetes:''is_diabetes'',@isBloodSugerExam:''is_blood_suger_exam'',@inOutCurrentState:''in_out_current_state'',@inOutPlanState:''in_out_plan_state'',@inOutPlanDate_Date:''in_out_plan_date'',@patMemoInfoValue:''pat_memo_info'',@additionInfoValue:''addition_info'',@chargeStaffInfoValue:''charge_staff_info'',@patGroupInfoValue:''pat_group_info'',@tabooAllergyInfoValue:''taboo_allergy_info'',@infectInfoValue:''infect_info'',@implantInfoValue:''implant_info'',@tareInfoValue:''tare_info'',@offWaterInfoValue:''off_water_info'',@deviceSetInfoValue:''device_set_info'',@acceptanceStatusInfoValue:''acceptance_status_info'',@isWheelChair:''is_wheel_chair'',@medicalCareInfoFlg:'''',@medicalCareInfoValue:''medical_care_info'',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:''sch_ext_end_date'',@schExtStatus:''sch_ext_status'',@cardIdm:''card_idm'',@oldUpDate_Date:''old_up_date''}"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "2", "sqlCode": -600014, "@inOutClass": "1", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "3", "sqlCode": -600016, "@inOutClass": "1", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}], "sqlGroup5": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "2", "sqlCode": 9104}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "3", "sqlCode": 9105, "@infectInfo1": "$journal.pat_main.infect_info1", "@infectInfo2": "$journal.pat_main.infect_info2", "@infectInfo3": "$journal.pat_main.infect_info3", "@infectInfo4": "$journal.pat_main.infect_info4", "@infectInfo5": "$journal.pat_main.infect_info5", "@infectInfo6": "$journal.pat_main.infect_info6", "@infectInfo7": "$journal.pat_main.infect_info7", "@infectInfo8": "$journal.pat_main.infect_info8", "@infectInfo9": "$journal.pat_main.infect_info9", "@infectInfo10": "$journal.pat_main.infect_info10", "@infectInfo11": "$journal.pat_main.infect_info11", "@infectInfo12": "$journal.pat_main.infect_info12", "@infectInfo13": "$journal.pat_main.infect_info13", "@infectInfo14": "$journal.pat_main.infect_info14", "@infectInfo15": "$journal.pat_main.infect_info15", "@infectInfo16": "$journal.pat_main.infect_info16", "@infectInfo17": "$journal.pat_main.infect_info17", "@infectInfo18": "$journal.pat_main.infect_info18", "@infectInfo19": "$journal.pat_main.infect_info19", "@infectInfo20": "$journal.pat_main.infect_info20", "@tabooAllergyInfo": "$journal.pat_main.taboo_allergy_info", "@chargeStaffInfo.staffCd": "$journal.pat_main.charge_staff_info.staff_cd"}], "sqlGroup6": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_unique", "ctl_no": "1", "sqlCode": 1601, "insertResult": "{@patId:'''', @facilityCd:'''', @medicalHstInfoValue:''[]'', @inOutVisitHistoryInfoValue:''[]'', @physicalInfoFlg:'''', @physicalInfoValue:''[]''}"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_unique", "ctl_no": "2", "sqlCode": 9106, "@physicalInfo.dw": "$journal.pat_unique.physical_info.dw", "@physicalInfo.height": "$journal.pat_unique.physical_info.height", "@physicalInfo.ctrWeight": "$journal.pat_unique.physical_info.ctr_weight", "@physicalInfo.orderClass": "1"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_unique", "ctl_no": "3", "sqlCode": 9107, "@physicalInfo.dw": "$journal.pat_unique.physical_info.dw", "@physicalInfo.height": "$journal.pat_unique.physical_info.height", "@physicalInfo.ctrWeight": "$journal.pat_unique.physical_info.ctr_weight", "@physicalInfo.orderClass": "1"}], "sqlGroup7": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "患者死亡退院情報連携", "No3": "患者の状態を『死亡』として、患者情報を登録します。", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "@isDie": "0", "ctl_no": "2", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -600013, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "2", "@severityCd": "$journal.pat_personal_main.severity_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@transportCd": "$journal.pat_personal_main.transport_cd", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}], "sqlGroup8": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "No3": "NEC場合、[死亡患者、連絡先情報、透析困難情報]を更新する。", "No4": "死亡退院日が空白の場合は「死亡患者 = 対象外」で登録、空白でない場合は「死亡患者 = 対象」で登録します。", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}, {"No2": "患者死亡退院情報連携", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "2", "sqlCode": 9102}, {"No2": "患者死亡退院情報連携", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "3", "sqlCode": 9103, "@otherContactInfo.tel1": "$journal.pat_personal_main.other_contact_info.tel1", "@otherContactInfo.zipCd": "$journal.pat_personal_main.other_contact_info.zip_cd", "@otherContactInfo.address": "$journal.pat_personal_main.other_contact_info.address", "@otherContactInfo.patName": "$journal.pat_personal_main.pat_name", "@otherContactInfo.patNameKana": "$journal.pat_personal_main.pat_name_kana"}], "sqlGroup9": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201, "insertResult": "{@patId:'''',@facilityCd:'''',@isSame:'''',@isImplant:'''',@isInfect:'''',@isDiabetes:'''',@isBloodSugerExam:'''',@inOutCurrentState:'''',@inOutPlanState:'''',@inOutPlanDate_Date:'''',@patMemoInfoValue:''[]'',@additionInfoValue:''[]'',@chargeStaffInfoValue:''[]'',@patGroupInfoValue:''[]'',@tabooAllergyInfoValue:''[]'',@infectInfoValue:''[]'',@implantInfoValue:''[]'',@tareInfoValue:''{}'',@offWaterInfoValue:''{}'',@deviceSetInfoValue:''{}'',@acceptanceStatusInfoValue:''[]'',@isWheelChair:'''',@medicalCareInfoFlg:'''',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:'''',@schExtStatus:'''',@cardIdm:'''',@oldUpDate_Date:''''}", "updateResult": "{@patId:''pat_id'',@facilityCd:''facility_cd'',@isSame:''is_same'',@isImplant:''is_implant'',@isInfect:''is_infect'',@isDiabetes:''is_diabetes'',@isBloodSugerExam:''is_blood_suger_exam'',@inOutCurrentState:''in_out_current_state'',@inOutPlanState:''in_out_plan_state'',@inOutPlanDate_Date:''in_out_plan_date'',@patMemoInfoValue:''pat_memo_info'',@additionInfoValue:''addition_info'',@chargeStaffInfoValue:''charge_staff_info'',@patGroupInfoValue:''pat_group_info'',@tabooAllergyInfoValue:''taboo_allergy_info'',@infectInfoValue:''infect_info'',@implantInfoValue:''implant_info'',@tareInfoValue:''tare_info'',@offWaterInfoValue:''off_water_info'',@deviceSetInfoValue:''device_set_info'',@acceptanceStatusInfoValue:''acceptance_status_info'',@isWheelChair:''is_wheel_chair'',@medicalCareInfoFlg:'''',@medicalCareInfoValue:''medical_care_info'',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.patDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:''sch_ext_end_date'',@schExtStatus:''sch_ext_status'',@cardIdm:''card_idm'',@oldUpDate_Date:''old_up_date''}"}, {"No2": "患者死亡退院情報連携", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "2", "sqlCode": -600014, "@inOutClass": "1", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}, {"No2": "患者死亡退院情報連携", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "3", "sqlCode": -600016, "@inOutClass": "1", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}], "sqlGroup10": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201}, {"No2": "患者死亡退院情報連携", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "2", "sqlCode": 9104}, {"No2": "患者死亡退院情報連携", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "3", "sqlCode": 9105, "@infectInfo1": "$journal.pat_main.infect_info1", "@infectInfo2": "$journal.pat_main.infect_info2", "@infectInfo3": "$journal.pat_main.infect_info3", "@infectInfo4": "$journal.pat_main.infect_info4", "@infectInfo5": "$journal.pat_main.infect_info5", "@infectInfo6": "$journal.pat_main.infect_info6", "@infectInfo7": "$journal.pat_main.infect_info7", "@infectInfo8": "$journal.pat_main.infect_info8", "@infectInfo9": "$journal.pat_main.infect_info9", "@infectInfo10": "$journal.pat_main.infect_info10", "@infectInfo11": "$journal.pat_main.infect_info11", "@infectInfo12": "$journal.pat_main.infect_info12", "@infectInfo13": "$journal.pat_main.infect_info13", "@infectInfo14": "$journal.pat_main.infect_info14", "@infectInfo15": "$journal.pat_main.infect_info15", "@infectInfo16": "$journal.pat_main.infect_info16", "@infectInfo17": "$journal.pat_main.infect_info17", "@infectInfo18": "$journal.pat_main.infect_info18", "@infectInfo19": "$journal.pat_main.infect_info19", "@infectInfo20": "$journal.pat_main.infect_info20", "@tabooAllergyInfo": "$journal.pat_main.taboo_allergy_info", "@chargeStaffInfo.staffCd": "$journal.pat_main.charge_staff_info.staff_cd"}], "sqlGroup11": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_unique", "ctl_no": "1", "sqlCode": 1601, "insertResult": "{@patId:'''', @facilityCd:'''', @medicalHstInfoValue:''[]'', @inOutVisitHistoryInfoValue:''[]'', @physicalInfoFlg:'''', @physicalInfoValue:''[]''}"}, {"No2": "患者死亡退院情報連携", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_unique", "ctl_no": "2", "sqlCode": 9106, "@physicalInfo.dw": "$journal.pat_unique.physical_info.dw", "@physicalInfo.height": "$journal.pat_unique.physical_info.height", "@physicalInfo.ctrWeight": "$journal.pat_unique.physical_info.ctr_weight", "@physicalInfo.orderClass": "1"}], "sqlGroup12": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "患者死亡退院情報連携", "No3": "患者情報更新", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "3", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -600015, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "2", "@severityCd": "$journal.pat_personal_main.severity_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@transportCd": "$journal.pat_personal_main.transport_cd", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}], "sqlGroup13": [{"No1": "指示情報→登録・更新", "No2": "初回指示連携Ver2、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer2,$journal.const.crud#<>#D", "table": "pat_coop_detail", "ctl_no": "1", "sqlCode": 9111, "insertResult": "{@coopSaveNo:'''', @facilityCd:'''', @patId:'''', @save1:'''', @save1Flg:'''', @save2Flg:'''', @save2.ord_no:'''', @save2.instruction_doctor_generation_no:'''', @save2.dialysis_type:'''', @save2.dialysis_course:'''', @save2.dialysis_pattern:'''', @save2.start_date_regular:'''', @save2.end_date_regular:'''', @save2.implementation_place:'''', @save2.update_terminal:'''', @save2.addition_generation_no:'''', @save2.blood_purification_method:'''', @save2.blood_purification_generation_no:'''', @save2.updater:'''', @save2.updater_generation_no:'''', @save3:'''', @save4:'''', @save5:'''', @save6:'''', @save7:'''', @save8:'''', @save9:'''', @save10:'''', @isDisp:'''', @isDel:'''', @userId:'''', @upDate_Date:'''', @regDate_Date:''''}", "updateResult": "{@coopSaveNo:''coop_save_no'', @facilityCd:''facility_cd'', @patId:''pat_id'', @save1Value:''save_1'', @save1Flg:'''', @save2Flg:'''', @save2Value:''save_2'', @save2.ord_no:'''', @save2.instruction_doctor_generation_no:'''', @save2.dialysis_type:'''', @save2.dialysis_course:'''', @save2.dialysis_pattern:'''', @save2.start_date_regular:'''', @save2.end_date_regular:'''', @save2.implementation_place:'''', @save2.update_terminal:'''', @save2.addition_generation_no:'''', @save2.blood_purification_method:'''', @save2.blood_purification_generation_no:'''', @save2.updater:'''', @save2.updater_generation_no:'''', @save3:''save_3'', @save4:''save_4'', @save5:''save_5'', @save6:''save_6'', @save7:''save_7'', @save8:''save_8'', @save9:''save_9'', @save10:''save_10'', @isDisp:''is_disp'', @isDel:''is_del'', @userId:''user_id'', @upDate_Date:''up_date'', @regDate_Date:''reg_date''}"}, {"No2": "初回指示連携Ver2、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer2,$journal.const.crud#<>#D", "table": "pat_coop_detail", "ctl_no": "2", "@userId": "-1", "sqlCode": -600103}], "sqlGroup14": [{"No1": "患者情報→登録・更新", "No2": "連携共通", "crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "連携共通", "No3": "患者の状態を『存命』から『死亡』に変更します。", "crud": "U", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "3", "sqlCode": -600105, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@dieDate_Date": "$journal.pat_personal_main.die_date"}]}, "CoopIniConvUtil": {"$journal.pat_personal_main.pat_sex": "CONV_SEX_TO_FNW", "$journal.pat_personal_main.pat_blood_type_rh": "CONV_BLOOD_RH_TO_FNW", "$journal.pat_personal_main.pat_blood_type_abo": "CONV_BLOOD_ABO_TO_FNW"}}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010015, 'N_hosp', 'ini_dial', '', 'R', '患者情報', 'text', 'NEC想定透析初回指示', 'MEGA', 'テスト用ver2/Standard', '1', '<root name="透析申込(患者情報)">
  <item name="空白" len="20" type="string"/>
  <item name="電文長" len="12" type="string"/>
  <item name="コマンド名" len="8" type="string" col="$journal.const.command_name" value="const:C-KNJUPD"/>
  <item name="処理区分" len="1" type="string" col="$journal.const.crud" value="const:C"/>
  <item name="病院コード" len="2" type="string"/>
  <item name="患者情報.患者番号" len="10" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
  <item name="患者情報.患者氏名" len="40" col="$journal.pat_personal_main.pat_name" type="string"/>
  <item name="患者情報.患者カナ氏名" len="20" col="$journal.pat_personal_main.pat_name_kana" type="string"/>
  <item name="患者情報.性別" len="1" col="$journal.pat_personal_main.pat_sex" type="string"/>
  <item name="患者情報.生年月日" len="8" col="$journal.pat_personal_main.pat_birthday" type="string"/>
  <item name="患者情報.郵便番号１" len="7" col="$journal.pat_personal_main.pat_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所１" len="100" col="$journal.pat_personal_main.pat_contact_info.address" type="string"/>
  <item name="患者情報.電話番号１" len="12" col="$journal.pat_personal_main.pat_contact_info.tel1" type="string"/>
  <item name="患者情報.郵便番号２" len="7" col="$journal.pat_personal_main.other_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所２" len="100" col="$journal.pat_personal_main.other_contact_info.address" type="string"/>
  <item name="患者情報.電話番号２" len="12" col="$journal.pat_personal_main.other_contact_info.tel1" type="string"/>
  <item name="病棟コード" len="4" col="$journal.pat_main.medical_care_info.ward_cd" type="string"/>
  <item name="病棟名称" len="20" type="string" info="対象外"/>
  <item name="病室コード" len="4" type="string" info="対象外"/>
  <item name="病室名称" len="20" type="string" info="対象外"/>
  <item name="看護区分" len="2" type="string" info="対象外"/>
  <item name="患者区分" len="2" col="$journal.pat_personal_main.severity_cd" type="string"/>
  <item name="救護区分" len="2" col="$journal.pat_personal_main.transport_cd" type="string"/>
  <item name="予備区分" len="1" type="string" info="対象外"/>
  <item name="障害情報" len="15" type="string" info="対象外"/>
  <item name="身長" len="5" col="$journal.pat_unique.physical_info.height" type="string" info="対象外"/>
  <item name="体重" len="5" col="$journal.pat_unique.physical_info.ctr_weight" type="string" info="対象外"/>
  <item name="血液型ＡＢＯ" len="1" col="$journal.pat_personal_main.pat_blood_type_abo" type="string"/>
  <item name="血液型Ｒｈ" len="1" col="$journal.pat_personal_main.pat_blood_type_rh" type="string"/>
  <item name="感染情報1" len="1" col="$journal.pat_main.infect_info1" type="string" info="1バイトのフラグ"/>
  <item name="感染情報2" len="1" col="$journal.pat_main.infect_info2" type="string" info="1バイトのフラグ"/>
  <item name="感染情報3" len="1" col="$journal.pat_main.infect_info3" type="string" info="1バイトのフラグ"/>
  <item name="感染情報4" len="1" col="$journal.pat_main.infect_info4" type="string" info="1バイトのフラグ"/>
  <item name="感染情報5" len="1" col="$journal.pat_main.infect_info5" type="string" info="1バイトのフラグ"/>
  <item name="感染情報6" len="1" col="$journal.pat_main.infect_info6" type="string" info="1バイトのフラグ"/>
  <item name="感染情報7" len="1" col="$journal.pat_main.infect_info7" type="string" info="1バイトのフラグ"/>
  <item name="感染情報8" len="1" col="$journal.pat_main.infect_info8" type="string" info="1バイトのフラグ"/>
  <item name="感染情報9" len="1" col="$journal.pat_main.infect_info9" type="string" info="1バイトのフラグ"/>
  <item name="感染情報10" len="1" col="$journal.pat_main.infect_info10" type="string" info="1バイトのフラグ"/>
  <item name="感染情報11" len="1" col="$journal.pat_main.infect_info11" type="string" info="1バイトのフラグ"/>
  <item name="感染情報12" len="1" col="$journal.pat_main.infect_info12" type="string" info="1バイトのフラグ"/>
  <item name="感染情報13" len="1" col="$journal.pat_main.infect_info13" type="string" info="1バイトのフラグ"/>
  <item name="感染情報14" len="1" col="$journal.pat_main.infect_info14" type="string" info="1バイトのフラグ"/>
  <item name="感染情報15" len="1" col="$journal.pat_main.infect_info15" type="string" info="1バイトのフラグ"/>
  <item name="感染情報16" len="1" col="$journal.pat_main.infect_info16" type="string" info="1バイトのフラグ"/>
  <item name="感染情報17" len="1" col="$journal.pat_main.infect_info17" type="string" info="1バイトのフラグ"/>
  <item name="感染情報18" len="1" col="$journal.pat_main.infect_info18" type="string" info="1バイトのフラグ"/>
  <item name="感染情報19" len="1" col="$journal.pat_main.infect_info19" type="string" info="1バイトのフラグ"/>
  <item name="感染情報20" len="1" col="$journal.pat_main.infect_info20" type="string" info="1バイトのフラグ"/>
  <item name="感染コメント" len="60" type="string" info="対象外"/>
  <item name="薬剤禁忌情報" len="20" col="$journal.pat_main.taboo_allergy_info" type="string" info="20バイトのフラグ"/>
  <item name="禁忌コメント" len="60" type="string"/>
  <item name="妊娠日" len="8" type="string" info="対象外"/>
  <item name="死亡退院日" len="8" col="$journal.pat_personal_main.die_date" type="string"/>
  <item name="予備" len="30" type="string" info="対象外"/>
</root>
', '{}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3010016, 'N_hosp', 'ini_dial', '', 'R', '患者死亡退院情報', 'text', 'NEC想定透析初回指示', 'MEGA', 'テスト用ver2/Standard', '1', '<root name="透析申込(患者死亡退院情報)">
  <item name="空白" len="20" type="string"/>
  <item name="電文長" len="12" type="string"/>
  <item name="コマンド名" len="8" type="string" col="$journal.const.command_name" value="const:C-KNJDEL"/>
  <item name="処理区分" len="1" type="string" col="$journal.const.crud" value="const:C"/>
  <item name="病院コード" len="2" type="string"/>
  <item name="患者情報.患者番号" len="10" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
  <item name="患者情報.患者氏名" len="40" col="$journal.pat_personal_main.pat_name" type="string"/>
  <item name="患者情報.患者カナ氏名" len="20" col="$journal.pat_personal_main.pat_name_kana" type="string"/>
  <item name="患者情報.性別" len="1" col="$journal.pat_personal_main.pat_sex" type="string"/>
  <item name="患者情報.生年月日" len="8" col="$journal.pat_personal_main.pat_birthday" type="string"/>
  <item name="患者情報.郵便番号１" len="7" col="$journal.pat_personal_main.pat_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所１" len="100" col="$journal.pat_personal_main.pat_contact_info.address" type="string"/>
  <item name="患者情報.電話番号１" len="12" col="$journal.pat_personal_main.pat_contact_info.tel1" type="string"/>
  <item name="患者情報.郵便番号２" len="7" col="$journal.pat_personal_main.other_contact_info.zip_cd" type="string"/>
  <item name="患者情報.患者住所２" len="100" col="$journal.pat_personal_main.other_contact_info.address" type="string"/>
  <item name="患者情報.電話番号２" len="12" col="$journal.pat_personal_main.other_contact_info.tel1" type="string"/>
  <item name="病棟コード" len="4" col="$journal.pat_main.medical_care_info.ward_cd" type="string"/>
  <item name="病棟名称" len="20" type="string" info="対象外"/>
  <item name="病室コード" len="4" type="string" info="対象外"/>
  <item name="病室名称" len="20" type="string" info="対象外"/>
  <item name="看護区分" len="2" type="string" info="対象外"/>
  <item name="患者区分" len="2" col="$journal.pat_personal_main.severity_cd" type="string"/>
  <item name="救護区分" len="2" col="$journal.pat_personal_main.transport_cd" type="string"/>
  <item name="予備区分" len="1" type="string" info="対象外"/>
  <item name="障害情報" len="15" type="string" info="対象外"/>
  <item name="身長" len="5" col="$journal.pat_unique.physical_info.height" type="string" info="対象外"/>
  <item name="体重" len="5" col="$journal.pat_unique.physical_info.ctr_weight" type="string" info="対象外"/>
  <item name="血液型ＡＢＯ" len="1" col="$journal.pat_personal_main.pat_blood_type_abo" type="string"/>
  <item name="血液型Ｒｈ" len="1" col="$journal.pat_personal_main.pat_blood_type_rh" type="string"/>
  <item name="感染情報1" len="1" col="$journal.pat_main.infect_info1" type="string" info="1バイトのフラグ"/>
  <item name="感染情報2" len="1" col="$journal.pat_main.infect_info2" type="string" info="1バイトのフラグ"/>
  <item name="感染情報3" len="1" col="$journal.pat_main.infect_info3" type="string" info="1バイトのフラグ"/>
  <item name="感染情報4" len="1" col="$journal.pat_main.infect_info4" type="string" info="1バイトのフラグ"/>
  <item name="感染情報5" len="1" col="$journal.pat_main.infect_info5" type="string" info="1バイトのフラグ"/>
  <item name="感染情報6" len="1" col="$journal.pat_main.infect_info6" type="string" info="1バイトのフラグ"/>
  <item name="感染情報7" len="1" col="$journal.pat_main.infect_info7" type="string" info="1バイトのフラグ"/>
  <item name="感染情報8" len="1" col="$journal.pat_main.infect_info8" type="string" info="1バイトのフラグ"/>
  <item name="感染情報9" len="1" col="$journal.pat_main.infect_info9" type="string" info="1バイトのフラグ"/>
  <item name="感染情報10" len="1" col="$journal.pat_main.infect_info10" type="string" info="1バイトのフラグ"/>
  <item name="感染情報11" len="1" col="$journal.pat_main.infect_info11" type="string" info="1バイトのフラグ"/>
  <item name="感染情報12" len="1" col="$journal.pat_main.infect_info12" type="string" info="1バイトのフラグ"/>
  <item name="感染情報13" len="1" col="$journal.pat_main.infect_info13" type="string" info="1バイトのフラグ"/>
  <item name="感染情報14" len="1" col="$journal.pat_main.infect_info14" type="string" info="1バイトのフラグ"/>
  <item name="感染情報15" len="1" col="$journal.pat_main.infect_info15" type="string" info="1バイトのフラグ"/>
  <item name="感染情報16" len="1" col="$journal.pat_main.infect_info16" type="string" info="1バイトのフラグ"/>
  <item name="感染情報17" len="1" col="$journal.pat_main.infect_info17" type="string" info="1バイトのフラグ"/>
  <item name="感染情報18" len="1" col="$journal.pat_main.infect_info18" type="string" info="1バイトのフラグ"/>
  <item name="感染情報19" len="1" col="$journal.pat_main.infect_info19" type="string" info="1バイトのフラグ"/>
  <item name="感染情報20" len="1" col="$journal.pat_main.infect_info20" type="string" info="1バイトのフラグ"/>
  <item name="感染コメント" len="60" type="string" info="対象外"/>
  <item name="薬剤禁忌情報" len="20" col="$journal.pat_main.taboo_allergy_info" type="string" info="20バイトのフラグ"/>
  <item name="禁忌コメント" len="60" type="string"/>
  <item name="妊娠日" len="8" type="string" info="対象外"/>
  <item name="死亡退院日" len="8" col="$journal.pat_personal_main.die_date" type="string"/>
  <item name="予備" len="30" type="string" info="対象外"/>
</root>
', '{}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3030001, 'N_hosp', 'staff_mst', '', 'R', 'pre', 'csv', 'NEC想定スタッフマスタ連携受信', 'MEGA', 'テスト用', '1', '<root name="スタッフマスタ連携(pre)" multi="true:CRLF/LF">
  <item name="更新区分" len="1" type="string"/>
  <item name="更新日時" len="14" type="string"/>
  <item name="病院コード" len="2" type="string"/>
  <item name="職員コード" len="10" type="string" key="shori_kbn"/>
  <item name="世代番号" len="1" type="string"/>
  <item name="有効期間開始日(変更前)" len="8" type="string"/>
  <item name="有効期間終了日(変更前)" len="8" type="string"/>
  <item name="有効期間開始日(変更後)" len="8" type="string"/>
  <item name="有効期間終了日(変更後)" len="8" type="string"/>
  <item name="パスワード" len="16" type="string"/>
  <item name="漢字氏名" len="20" type="string"/>
  <item name="カナ氏名" len="20" type="string"/>
  <item name="性別" len="1" type="string"/>
  <item name="生年月日(西暦)" len="8" type="string"/>
  <item name="職種コード" len="2" type="string"/>
  <item name="病棟コード" len="5" type="string"/>
  <item name="役職コード" len="2" type="string"/>
  <item name="免許コード1" len="16" type="string"/>
  <item name="免許日付1" len="8" type="string"/>
  <item name="免許コード2" len="16" type="string"/>
  <item name="免許日付2" len="8" type="string"/>
</root>', '{"csv": {"delim": {"item": ","}}, "key": {"shori_kbn": {"_DEFAULT": "対象", "9900000081": "対象外", "9999999901": "対象外", "9999999999": "対象外"}}, "dataset": {"sqlGroup1": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600500, "@userPassword": "$journal.mst_personal_user.user_password", "ExceptionMessage": "スタッフマスタCSVの設定に誤りがあります。パスワードが設定されていません。", "ExceptionCondition": "=1"}], "sqlGroup2": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600501, "@userName": "$journal.mst_personal_user.user_name", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。漢字氏名が設定されていません。", "ExceptionCondition": "=1"}], "sqlGroup3": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600502, "@inHospitalCd": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。職員コードに編集対象外のIDが設定されています。", "ExceptionCondition": "=1"}], "sqlGroup4": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600503, "@inHospitalCd": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。職員コードに編集対象外のIDが設定されています。", "ExceptionCondition": "=1"}], "sqlGroup5": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "@crud": "$journal.const.crud", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600504, "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。更新区分は「1：追加、2：変更、3：削除」で設定してください。", "ExceptionCondition": "=1"}], "sqlGroup6": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600505, "@inHospitalCd": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。職員コードが設定されていません。", "ExceptionCondition": "=1"}], "sqlGroup7": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600506, "@inHospitalCd": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。職員コードが規定サイズを超過しています。", "ExceptionCondition": "=1"}], "sqlGroup8": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600507, "@inHospitalCd": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。職員コードは半角英数字で設定してください。", "ExceptionCondition": "=1"}], "sqlGroup9": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600508, "@startDateAfter": "$journal.mst_personal_user.start_date_after", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。有効期間開始日（変更後）が設定されていません。", "ExceptionCondition": "=1"}], "sqlGroup10": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600509, "@startDateAfter": "$journal.mst_personal_user.start_date_after", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。有効期間開始日（変更後）に日付情報が設定されていません。", "ExceptionCondition": "=1"}], "sqlGroup11": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600510, "@endDateAfter": "$journal.mst_personal_user.end_date_after", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。有効期間終了日（変更後）が設定されていません。", "ExceptionCondition": "=1"}], "sqlGroup12": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600511, "@endDateAfter": "$journal.mst_personal_user.end_date_after", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。有効期間終了日（変更後）に日付情報が設定されていません。", "ExceptionCondition": "=1"}], "sqlGroup13": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600512, "@userPassword": "$journal.mst_personal_user.user_password", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。パスワードは半角英数字で設定してください。", "ExceptionCondition": "=1"}], "sqlGroup14": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600513, "@userPassword": "$journal.mst_personal_user.user_password", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。パスワードが規定サイズを超過しています。", "ExceptionCondition": "=1"}], "sqlGroup15": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600514, "@userName": "$journal.mst_personal_user.user_name", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。漢字氏名が規定サイズを超過しています。", "ExceptionCondition": "=1"}], "sqlGroup16": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600515, "@userKana": "$journal.mst_personal_user.user_kana", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。カナ氏名が規定サイズを超過しています。", "ExceptionCondition": "=1"}], "sqlGroup17": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_personal_user)", "crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 9401, "insertResult": "{@userId:'''', @facilityCd:'''', @userType:'''', @userLastName:'''', @userFirstName:'''', @userLastNameKana:'''', @userFirstNameKana:'''', @userLastNameAlpha:'''', @userFirstNameAlpha:'''', @userEmailAddress1:'''', @userEmailAddress2:'''', @extensionNo:'''', @homeNo:'''', @mobilePhoneNo:'''', @faxNo:'''', @zipcd3:'''', @zipcd4:'''', @address:'''', @addressKana:'''', @jobCd:'''', @regDate_Date:'''', @upDate_Date:'''', @administrator:'''', @isDisp:'''', @isDel:'''', @inHospitalCd1:'''', @inHospitalCd2:'''', @infoDispToAdmin:'''', @anesthesiologistLicenseNo:'''', @signinDate_Date:'''', @patientShared:'''', @fnStaffCd:''''}", "updateResult": "{@userId:''user_id'', @facilityCd:''facility_cd'', @userType:''user_type'', @userLastName:''user_last_name'', @userFirstName:''user_first_name'', @userLastNameKana:''user_last_name_kana'', @userFirstNameKana:''user_first_name_kana'', @userLastNameAlpha:''user_last_name_alpha'', @userFirstNameAlpha:''user_first_name_alpha'', @userEmailAddress1:''user_email_address_1'', @userEmailAddress2:''user_email_address_2'', @extensionNo:''extension_no'', @homeNo:''home_no'', @mobilePhoneNo:''mobile_phone_no'', @faxNo:''fax_no'', @zipcd3:''zipcd_3'', @zipcd4:''zipcd_4'', @address:''address'', @addressKana:''address_kana'', @jobCd:''job_cd'', @regDate_Date:''reg_date'', @upDate_Date:''up_date'', @administrator:''administrator'', @isDisp:''is_disp'', @isDel:''is_del'', @inHospitalCd1:''in_hospital_cd_1'', @inHospitalCd2:''in_hospital_cd_2'', @infoDispToAdmin:''info_disp_to_admin'', @anesthesiologistLicenseNo:''anesthesiologist_license_no'', @signinDate_Date:''signin_date'', @patientShared:''patient_shared'', @fnStaffCd:''fn_staff_cd''}", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "利用者[@inHospitalCd1]の情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "=N"}, {"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_personal_user)", "crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "@jobCd": "$journal.mst_personal_user.job_cd", "ctl_no": "2", "sqlCode": 9402, "@userKana": "$journal.mst_personal_user.user_kana", "@userName": "$journal.mst_personal_user.user_name", "@userType": "0", "@endDateAfter": "$journal.mst_personal_user.end_date_after", "@userPassword": "$journal.mst_personal_user.user_password", "@administrator": "0", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "@startDateAfter": "$journal.mst_personal_user.start_date_after"}, {"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_personal_user)", "crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "@jobCd": "$journal.mst_personal_user.job_cd", "ctl_no": "3", "sqlCode": 9403, "@userKana": "$journal.mst_personal_user.user_kana", "@userName": "$journal.mst_personal_user.user_name", "@userType": "0", "@endDateAfter": "$journal.mst_personal_user.end_date_after", "@userPassword": "$journal.mst_personal_user.user_password", "@administrator": "0", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "@startDateAfter": "$journal.mst_personal_user.start_date_after"}], "sqlGroup18": [{"No1": "更新区分が「''3''：削除」の処理。", "No2": "利用者マスタ(mst_personal_user)。", "crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 9401, "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "利用者[@inHospitalCd1]の情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "=N"}, {"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_user)", "crud": "D", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_user_authentication", "ctl_no": "2", "sqlCode": -600518, "@endDateAfter": "$journal.mst_personal_user.end_date_after", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "@startDateAfter": "$journal.mst_personal_user.start_date_after"}], "sqlGroup19": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_user_authentication)", "crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 9405, "insertResult": "{@userId:'''', @facilityCd:'''', @dispUserId:'''', @userPassword:'''', @failureCnt:'''', @regDate_Date:'''', @upDate_Date:'''', @userPasswordHistoryValue:''''}", "updateResult": "{@userId:''user_id'', @facilityCd:''facility_cd'', @dispUserId:''disp_user_id'', @userPassword:''user_password'', @failureCnt:''failure_cnt'', @regDate_Date:''reg_date'', @upDate_Date:''up_date'', @userPasswordHistoryValue:''user_password_history''}", "@endDateAfter": "$journal.mst_personal_user.end_date_after", "@startDateAfter": "$journal.mst_personal_user.start_date_after"}, {"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_user_authentication)", "crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "2", "sqlCode": 9406, "@dispUserId": "$journal.mst_personal_user.in_hospital_cd_1", "@endDateAfter": "$journal.mst_personal_user.end_date_after", "@startDateAfter": "$journal.mst_personal_user.start_date_after", "@%%passwordencoder%%_dispUserId": "$journal.mst_personal_user.in_hospital_cd_1", "@%%passwordencoder%%_userPassword": "$journal.mst_personal_user.user_password", "@%%passwordencoder%%_defaultPassword": "123456"}, {"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_user_authentication)", "crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "3", "sqlCode": 9407, "@dispUserId": "$journal.mst_personal_user.in_hospital_cd_1", "@%%passwordencoder%%_dispUserId": "$journal.mst_personal_user.in_hospital_cd_1", "@%%passwordencoder%%_userPassword": "$journal.mst_personal_user.user_password", "@%%passwordencoder%%_defaultPassword": "123456"}], "sqlGroup20": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_user)", "crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 9408, "insertResult": "{@userId:'''', @userSettingsValue:'''', @isProvisional:'''', @regDate_Date:'''', @upDate_Date:'''', @isDisp:'''', @isDel:'''', @patId:'''', @tmpLogSearchConditionValue:'''', @secretKey:'''', @isSetQrCode:'''', @cardIdm:'''', @isConsent:'''', @consentDate_Date:'''', @regPasswordDate_Date:'''', @facilityCd:''''}", "updateResult": "{@userId:''user_id'', @userSettingsValue:''user_settings'', @isProvisional:''is_provisional'', @regDate_Date:''reg_date'', @upDate_Date:''up_date'', @isDisp:''is_disp'', @isDel:''is_del'', @patId:''pat_id'', @tmpLogSearchConditionValue:''tmp_log_search_condition'', @secretKey:''secret_key'', @isSetQrCode:''is_set_qr_code'', @cardIdm:''card_idm'', @isConsent:''is_consent'', @consentDate_Date:''consent_date'', @regPasswordDate_Date:''reg_password_date'', @facilityCd:''facility_cd''}", "@endDateAfter": "$journal.mst_personal_user.end_date_after", "@startDateAfter": "$journal.mst_personal_user.start_date_after"}, {"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_user)", "crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "@jobCd": "$journal.mst_personal_user.job_cd", "ctl_no": "2", "sqlCode": 9409, "@endDateAfter": "$journal.mst_personal_user.end_date_after", "@startDateAfter": "$journal.mst_personal_user.start_date_after", "@userSettingsValue": "{\"theme\": 0, \"font_size\": 1, \"is_disp_menu\": 1, \"use_functions\": [\"005\"], \"is_split_frame\": 1, \"default_setting\": {}, \"ind_rst_pattern\": null, \"initial_function\": \"005\", \"personal_settings\": [], \"authorized_functions\": [\"005\"], \"authorized_authorities\": []}"}, {"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_user)", "crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "@jobCd": "$journal.mst_personal_user.job_cd", "ctl_no": "3", "sqlCode": 9410, "@userSettingsValue": "{\"theme\": 0, \"font_size\": 1, \"is_disp_menu\": 1, \"use_functions\": [\"005\"], \"is_split_frame\": 1, \"default_setting\": {}, \"ind_rst_pattern\": null, \"initial_function\": \"005\", \"personal_settings\": [], \"authorized_functions\": [\"005\"], \"authorized_authorities\": []}"}], "sqlGroup21": [{"No1": "更新区分が「''3''：削除」の処理。", "No2": "利用者マスタ(mst_personal_user)。", "crud": "S", "kind": "1", "judge": "$journal.const.crud#=#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 9401, "insertResult": "{@userId:''-1''}", "updateResult": "{@userId:''user_id''}", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "利用者[@inHospitalCd1]の情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "=N"}, {"No1": "更新区分が「''3''：削除」の処理。", "No2": "利用者マスタ(mst_user) 倫理削除。サブテーブル、削除処理を先に実行", "crud": "U", "kind": "1", "judge": "$journal.const.crud#=#D", "table": "mst_user", "ctl_no": "2", "sqlCode": 9413}], "sqlGroup22": [{"No1": "更新区分が「''3''：削除」の処理。", "No2": "利用者マスタ(mst_personal_user)。", "crud": "S", "kind": "1", "judge": "$journal.const.crud#=#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 9401, "insertResult": "{@userId:''-1''}", "updateResult": "{@userId:''user_id''}", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "利用者[@inHospitalCd1]の情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "=N"}, {"No1": "更新区分が「''3''：削除」の処理。", "No2": "利用者マスタ(mst_user_authentication) 物理削除。サブテーブル、削除処理を先に実行", "crud": "D", "kind": "1", "judge": "$journal.const.crud#=#D", "table": "mst_user_authentication", "ctl_no": "2", "sqlCode": 9412}], "sqlGroup23": [{"No1": "更新区分が「''3''：削除」の処理。", "No2": "利用者マスタ(mst_personal_user)。", "crud": "S", "kind": "1", "judge": "$journal.const.crud#=#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 9401, "insertResult": "{@userId:''-1''}", "updateResult": "{@userId:''user_id''}", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "利用者[@inHospitalCd1]の情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "=N"}, {"No1": "更新区分が「''3''：削除」の処理。", "No2": "利用者マスタ(mst_personal_user) 倫理削除。親テーブル、後に削除処理を実行。", "crud": "U", "kind": "1", "judge": "$journal.const.crud#=#D", "table": "mst_personal_user", "ctl_no": "2", "sqlCode": 9411}], "sqlGroup24": [{"No1": "更新区分が「''3''：削除」の処理。", "No2": "利用者マスタ(mst_personal_user)。", "crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 9401, "insertResult": "{@userId:''-1''}", "updateResult": "{@userId:''user_id''}", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "利用者[@inHospitalCd1]の情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "=N"}, {"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_user)", "crud": "D", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_user_authentication", "ctl_no": "2", "sqlCode": -600518, "@endDateAfter": "$journal.mst_personal_user.end_date_after", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "@startDateAfter": "$journal.mst_personal_user.start_date_after"}], "sqlGroup25": [{"No1": "更新区分が「''3''：削除」の処理。", "No2": "利用者マスタ(mst_personal_user)。", "crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 9401, "insertResult": "{@userId:''-1''}", "updateResult": "{@userId:''user_id''}", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "利用者[@inHospitalCd1]の情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "=N"}, {"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_user)", "crud": "U", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "2", "sqlCode": -600517, "@endDateAfter": "$journal.mst_personal_user.end_date_after", "@startDateAfter": "$journal.mst_personal_user.start_date_after"}], "sqlGroup26": [{"No1": "更新区分が「''3''：削除」の処理。", "No2": "利用者マスタ(mst_personal_user)。", "crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 9401, "insertResult": "{@userId:''-1''}", "updateResult": "{@userId:''user_id''}", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "利用者[@inHospitalCd1]の情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "=N"}, {"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_personal_user)", "crud": "U", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "2", "sqlCode": -600516, "@endDateAfter": "$journal.mst_personal_user.end_date_after", "@startDateAfter": "$journal.mst_personal_user.start_date_after"}]}}'::jsonb, '1', '0', -1, '2019-12-13 05:44:54.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3030002, 'N_hosp', 'staff_mst', '', 'R', '対象', 'csv', 'NEC想定スタッフマスタ連携受信', 'MEGA', 'テスト用', '1', '<root name="スタッフマスタ連携(対象)">
  <item name="更新区分" len="1" type="string" col="$journal.const.crud" value="json:{&quot;1&quot;:&quot;C&quot;,&quot;2&quot;:&quot;U&quot;,&quot;3&quot;:&quot;D&quot;}"/>
  <item name="更新日時" len="14" type="string" col="$journal.mst_personal_user.up_date"/>
  <item name="病院コード" len="2" type="string" col="$journal.mst_personal_user.hosp_id"/>
  <item name="職員コード" len="10" type="string" col="$journal.mst_personal_user.in_hospital_cd_1"/>
  <item name="世代番号" len="1" type="string" col="$journal.mst_personal_user.generation_cd"/>
  <item name="有効期間開始日(変更前)" len="8" type="string" col="$journal.mst_personal_user.start_date_before"/>
  <item name="有効期間終了日(変更前)" len="8" type="string" col="$journal.mst_personal_user.end_date_before"/>
  <item name="有効期間開始日(変更後)" len="8" type="string" col="$journal.mst_personal_user.start_date_after"/>
  <item name="有効期間終了日(変更後)" len="8" type="string" col="$journal.mst_personal_user.end_date_after"/>
  <item name="パスワード" len="16" type="string" col="$journal.mst_personal_user.user_password"/>
  <item name="漢字氏名" len="20" type="string" col="$journal.mst_personal_user.user_name"/>
  <item name="カナ氏名" len="20" type="string" col="$journal.mst_personal_user.user_kana"/>
  <item name="性別" len="1" type="string" col="$journal.mst_personal_user.user_sex"/>
  <item name="生年月日(西暦)" len="8" type="string" col="$journal.mst_personal_user.user_birthday"/>
  <item name="職種コード" len="2" type="string" col="$journal.mst_personal_user.job_cd"/>
  <item name="病棟コード" len="5" type="string" col="$journal.mst_personal_user.ward_cd"/>
  <item name="役職コード" len="2" type="string" col="$journal.mst_personal_user.duties_cd"/>
  <item name="免許コード1" len="16" type="string" col="$journal.mst_personal_user.license_no_1"/>
  <item name="免許日付1" len="8" type="string" col="$journal.mst_personal_user.license_date_1"/>
  <item name="免許コード2" len="16" type="string" col="$journal.mst_personal_user.license_no_2"/>
  <item name="免許日付2" len="8" type="string" col="$journal.mst_personal_user.license_date_2"/>
</root>', '{"json-key": {"{\"1\":\"C\",\"2\":\"U\",\"3\":\"D\"}": {"1": "C", "2": "U", "3": "D"}}}'::jsonb, '1', '0', -1, '2019-12-13 05:44:54.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3030003, 'N_hosp', 'staff_mst', '', 'R', '対象外', 'csv', 'NEC想定スタッフマスタ連携受信', 'MEGA', 'テスト用', '1', '<root name="スタッフマスタ連携(対象外)">
  <item name="更新区分" len="1" type="string" col="$journal.const.crud" value="const:Z"/>
  <item name="更新日時" len="14" type="string"/>
  <item name="病院コード" len="2" type="string"/>
  <item name="職員コード" len="10" type="string"/>
  <item name="世代番号" len="1" type="string"/>
  <item name="有効期間開始日(変更前)" len="8" type="string"/>
  <item name="有効期間終了日(変更前)" len="8" type="string"/>
  <item name="有効期間開始日(変更後)" len="8" type="string"/>
  <item name="有効期間終了日(変更後)" len="8" type="string"/>
  <item name="パスワード" len="16" type="string"/>
  <item name="漢字氏名" len="20" type="string"/>
  <item name="カナ氏名" len="20" type="string"/>
  <item name="性別" len="1" type="string"/>
  <item name="生年月日(西暦)" len="8" type="string"/>
  <item name="職種コード" len="2" type="string"/>
  <item name="病棟コード" len="5" type="string"/>
  <item name="役職コード" len="2" type="string"/>
  <item name="免許コード1" len="16" type="string"/>
  <item name="免許日付1" len="8" type="string"/>
  <item name="免許コード2" len="16" type="string"/>
  <item name="免許日付2" len="8" type="string"/>
</root>', '{}'::jsonb, '1', '0', -1, '2019-12-13 05:44:54.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040001, 'N_hosp', 'ind_dial', '', 'S', 'cre', 'text', 'NEC', 'MEGA', '詳細指示(Ver1)/Standard', '1', '<root name="透析予約">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSDIRE"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:A"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="dataset:-102.ind_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="dataset:-102.dialysis_type"/>
  <item name="透析コース" len="6" value="dataset:-102.dialysis_course"/>
  <item name="透析パターン" len="6" value="dataset:-102.dialysis_pattern"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="dataset:-600202.dialysis_date"/>
  <item name="透析時間" len="4" value="dataset:-600200.treatment_start_time"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="dataset:-600200.bed_reservation_time"/>
  <item name="ブラッドアクセス" len="6" value="dataset:-102.va3"/>
  <item name="部位" len="6" value="dataset:-102.va_direct"/>
  <item name="ＤＷ" len="4" value="dataset:-102.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-102.blood_purification_method"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="指示詳細" sqlCode="-204"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "1"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, '2020-05-20 10:53:24.901', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040002, 'N_hosp', 'ind_dial', '', 'S', 'upd', 'text', 'NEC', 'MEGA', '詳細指示(Ver1)/Standard', '1', '<root name="透析予約">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSDIRE"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:U"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="dataset:-102.ind_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="dataset:-102.dialysis_type"/>
  <item name="透析コース" len="6" value="dataset:-102.dialysis_course"/>
  <item name="透析パターン" len="6" value="dataset:-102.dialysis_pattern"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="dataset:-600202.dialysis_date"/>
  <item name="透析時間" len="4" value="dataset:-600200.treatment_start_time"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="dataset:-600200.bed_reservation_time"/>
  <item name="ブラッドアクセス" len="6" value="dataset:-102.va3"/>
  <item name="部位" len="6" value="dataset:-102.va_direct"/>
  <item name="ＤＷ" len="4" value="dataset:-102.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-102.blood_purification_method"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="指示詳細" sqlCode="-204"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "U", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "1"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, '2020-05-20 10:53:24.901', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040003, 'N_hosp', 'ind_dial', '', 'S', 'del', 'text', 'NEC', 'MEGA', '詳細指示(Ver1)/Standard', '1', '<root name="透析予約">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSDIRE"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:D"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="dataset:-102.ind_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="dataset:-102.dialysis_type"/>
  <item name="透析コース" len="6" value="dataset:-102.dialysis_course"/>
  <item name="透析パターン" len="6" value="dataset:-102.dialysis_pattern"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="$BLANK"/>
  <item name="透析時間" len="4" value="$BLANK"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="$BLANK"/>
  <item name="ブラッドアクセス" len="6" value="dataset:-102.va3"/>
  <item name="部位" len="6" value="dataset:-102.va_direct"/>
  <item name="ＤＷ" len="4" value="dataset:-102.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-102.blood_purification_method"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "D", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600202, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040004, 'N_hosp', 'ind_dial', '', 'S', 'cre', 'text', 'NEC', 'MEGA', '詳細指示(Ver2)/TSHPlus', '1', '<root name="透析予約">
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:A"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="const:0"/>
  <item name="保険コード01" len="3" value="$BLANK"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="const:2"/>
  <item name="透析コース" len="6" value="$BLANK"/>
  <item name="透析パターン" len="6" value="$BLANK"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="dataset:-600202.dialysis_date"/>
  <item name="透析時間" len="4" value="dataset:-600200.treatment_start_time"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-600202.bed_cd1"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="dataset:-600200.bed_reservation_time"/>
  <item name="ブラッドアクセス" len="6" value="$BLANK"/>
  <item name="部位" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600202.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-600202.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="指示詳細" sqlCode="-204"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "2"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}]}'::jsonb, '1', '0', 4, '2020-05-20 10:53:24.901', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040005, 'N_hosp', 'ind_dial', '', 'S', 'upd', 'text', 'NEC', 'MEGA', '詳細指示(Ver2)/TSHPlus', '1', '<root name="透析予約">
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:U"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="const:0"/>
  <item name="保険コード01" len="3" value="$BLANK"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="const:2"/>
  <item name="透析コース" len="6" value="$BLANK"/>
  <item name="透析パターン" len="6" value="$BLANK"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="dataset:-600202.dialysis_date"/>
  <item name="透析時間" len="4" value="dataset:-600200.treatment_start_time"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-600202.bed_cd1"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="dataset:-600200.bed_reservation_time"/>
  <item name="ブラッドアクセス" len="6" value="$BLANK"/>
  <item name="部位" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600202.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-600202.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="指示詳細" sqlCode="-204"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "U", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "2"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}]}'::jsonb, '1', '0', 4, '2020-05-20 10:53:24.901', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040006, 'N_hosp', 'ind_dial', '', 'S', 'del', 'text', 'NEC', 'MEGA', '詳細指示(Ver2)/TSHPlus', '1', '<root name="透析予約">
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:D"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="const:0"/>
  <item name="保険コード01" len="3" value="$BLANK"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="const:2"/>
  <item name="透析コース" len="6" value="$BLANK"/>
  <item name="透析パターン" len="6" value="$BLANK"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="$BLANK"/>
  <item name="透析時間" len="4" value="$BLANK"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-600202.bed_cd1"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="$BLANK"/>
  <item name="ブラッドアクセス" len="6" value="$BLANK"/>
  <item name="部位" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600202.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-600202.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "D", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}]}'::jsonb, '1', '0', 4, '2020-05-20 10:53:24.901', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040007, 'N_hosp', 'ind_dial', '', 'S', 'cre', 'text', 'NEC', 'MEGA', '詳細指示(Ver1)/TSHPlus', '1', '<root name="透析予約">
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:A"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="dataset:-102.ind_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="dataset:-102.dialysis_type"/>
  <item name="透析コース" len="6" value="dataset:-102.dialysis_course"/>
  <item name="透析パターン" len="6" value="dataset:-102.dialysis_pattern"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="dataset:-600202.dialysis_date"/>
  <item name="透析時間" len="4" value="dataset:-600200.treatment_start_time"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="dataset:-600200.bed_reservation_time"/>
  <item name="ブラッドアクセス" len="6" value="dataset:-102.va3"/>
  <item name="部位" len="6" value="dataset:-102.va_direct"/>
  <item name="ＤＷ" len="4" value="dataset:-102.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-102.blood_purification_method"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="指示詳細" sqlCode="-204"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "1"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040008, 'N_hosp', 'ind_dial', '', 'S', 'upd', 'text', 'NEC', 'MEGA', '詳細指示(Ver1)/TSHPlus', '1', '<root name="透析予約">
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:U"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="dataset:-102.ind_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="dataset:-102.dialysis_type"/>
  <item name="透析コース" len="6" value="dataset:-102.dialysis_course"/>
  <item name="透析パターン" len="6" value="dataset:-102.dialysis_pattern"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="dataset:-600202.dialysis_date"/>
  <item name="透析時間" len="4" value="dataset:-600200.treatment_start_time"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="dataset:-600200.bed_reservation_time"/>
  <item name="ブラッドアクセス" len="6" value="dataset:-102.va3"/>
  <item name="部位" len="6" value="dataset:-102.va_direct"/>
  <item name="ＤＷ" len="4" value="dataset:-102.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-102.blood_purification_method"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="指示詳細" sqlCode="-204"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "U", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "1"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040009, 'N_hosp', 'ind_dial', '', 'S', 'del', 'text', 'NEC', 'MEGA', '詳細指示(Ver1)/TSHPlus', '1', '<root name="透析予約">
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:D"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="dataset:-102.ind_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="dataset:-102.dialysis_type"/>
  <item name="透析コース" len="6" value="dataset:-102.dialysis_course"/>
  <item name="透析パターン" len="6" value="dataset:-102.dialysis_pattern"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="$BLANK"/>
  <item name="透析時間" len="4" value="$BLANK"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="$BLANK"/>
  <item name="ブラッドアクセス" len="6" value="dataset:-102.va3"/>
  <item name="部位" len="6" value="dataset:-102.va_direct"/>
  <item name="ＤＷ" len="4" value="dataset:-102.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-102.blood_purification_method"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "D", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600202, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040010, 'N_hosp', 'ind_dial', '', 'S', 'cre', 'text', 'NEC', 'MEGA', '詳細指示(Ver2)/Standard', '1', '<root name="透析予約">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSDIRE"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:A"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="const:0"/>
  <item name="保険コード01" len="3" value="$BLANK"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="const:2"/>
  <item name="透析コース" len="6" value="$BLANK"/>
  <item name="透析パターン" len="6" value="$BLANK"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="dataset:-600202.dialysis_date"/>
  <item name="透析時間" len="4" value="dataset:-600200.treatment_start_time"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-600202.bed_cd1"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="dataset:-600200.bed_reservation_time"/>
  <item name="ブラッドアクセス" len="6" value="$BLANK"/>
  <item name="部位" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600202.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-600202.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="指示詳細" sqlCode="-204"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "2"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040011, 'N_hosp', 'ind_dial', '', 'S', 'upd', 'text', 'NEC', 'MEGA', '詳細指示(Ver2)/Standard', '1', '<root name="透析予約">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSDIRE"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:U"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="const:0"/>
  <item name="保険コード01" len="3" value="$BLANK"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="const:2"/>
  <item name="透析コース" len="6" value="$BLANK"/>
  <item name="透析パターン" len="6" value="$BLANK"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="dataset:-600202.dialysis_date"/>
  <item name="透析時間" len="4" value="dataset:-600200.treatment_start_time"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-600202.bed_cd1"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="dataset:-600200.bed_reservation_time"/>
  <item name="ブラッドアクセス" len="6" value="$BLANK"/>
  <item name="部位" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600202.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-600202.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="指示詳細" sqlCode="-204"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "U", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "2"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040012, 'N_hosp', 'ind_dial', '', 'S', 'del', 'text', 'NEC', 'MEGA', '詳細指示(Ver2)/Standard', '1', '<root name="透析予約">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSDIRE"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:D"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="const:0"/>
  <item name="保険コード01" len="3" value="$BLANK"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="const:2"/>
  <item name="透析コース" len="6" value="$BLANK"/>
  <item name="透析パターン" len="6" value="$BLANK"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="$BLANK"/>
  <item name="透析時間" len="4" value="$BLANK"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-600202.bed_cd1"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="$BLANK"/>
  <item name="ブラッドアクセス" len="6" value="$BLANK"/>
  <item name="部位" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600202.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-600202.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "D", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070001, 'N_hosp', 'rst_dial', '', 'S', 'cre', 'text', 'NEC', 'MEGA', '透析実績（Ver1)/Standard', '1', '<root name="透析実績(Ver1)">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSEXEC"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:Y"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="dataset:-14.start_date8"/>
  <item name="実施開始時間" len="4" value="dataset:-14.start_date6"/>
  <item name="実施終了日" len="8" value="dataset:-14.end_date8"/>
  <item name="実施終了時間" len="4" value="dataset:-14.end_date6"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v1"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="前体重" len="5" value="dataset:-33.weight_before"/>
  <item name="後体重" len="5" value="dataset:-33.weight_after"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600303.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-600304.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="dataset:-102.blood_purification_generation_no"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="実績詳細" sqlCode="-202"/>
  <occ name="コメント詳細" len="5" detail="コメント" sqlCode="-203"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -14}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -32}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -202, "facilityCd": "facilityCd", "messageType": "1"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -203, "facilityCd": "facilityCd", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600304, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, '2020-05-19 17:01:48.871', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070002, 'N_hosp', 'rst_dial', '', 'S', 'upd', 'text', 'NEC', 'MEGA', '透析実績（Ver1)/Standard', '1', '<root name="透析実績(Ver1)">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSEXEC"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:U"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="dataset:-14.start_date8"/>
  <item name="実施開始時間" len="4" value="dataset:-14.start_date6"/>
  <item name="実施終了日" len="8" value="dataset:-14.end_date8"/>
  <item name="実施終了時間" len="4" value="dataset:-14.end_date6"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v1"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="前体重" len="5" value="dataset:-33.weight_before"/>
  <item name="後体重" len="5" value="dataset:-33.weight_after"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600303.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-600304.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="dataset:-102.blood_purification_generation_no"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="実績詳細" sqlCode="-202"/>
  <occ name="コメント詳細" len="5" detail="コメント" sqlCode="-203"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -14}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -32}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -202, "facilityCd": "facilityCd", "messageType": "1"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -203, "facilityCd": "facilityCd", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600304, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, '2020-05-19 17:01:48.871', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070003, 'N_hosp', 'rst_dial', '', 'S', 'del', 'text', 'NEC', 'MEGA', '透析実績（Ver1)/Standard', '1', '<root name="透析実績(Ver1)">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSEXEC"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:D"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="$BLANK"/>
  <item name="実施開始時間" len="4" value="$BLANK"/>
  <item name="実施終了日" len="8" value="$BLANK"/>
  <item name="実施終了時間" len="4" value="$BLANK"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_del_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v1"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="前体重" len="5" value="const:00000"/>
  <item name="後体重" len="5" value="const:00000"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="const:0000"/>
  <item name="血液浄化法" len="6" value="dataset:-102.blood_purification_method"/>
  <item name="血液浄化法世代番号" len="1" value="dataset:-102.blood_purification_generation_no"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, '2020-05-19 17:01:48.871', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070004, 'N_hosp', 'rst_dial', '', 'S', 'cre', 'text', 'NEC', 'MEGA', '透析実績（Ver2)/TSHPlus', '1', '<root name="透析実績(Ver2)">
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:Y"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="dataset:-14.start_date8"/>
  <item name="実施開始時間" len="4" value="dataset:-14.start_date6"/>
  <item name="実施終了日" len="8" value="dataset:-14.end_date8"/>
  <item name="実施終了時間" len="4" value="dataset:-14.end_date6"/>
  <item name="実施場所" len="6" value="dataset:-11.bed_cd1"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v2"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.own_medi_code"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="前体重" len="5" value="dataset:-33.weight_before"/>
  <item name="後体重" len="5" value="dataset:-33.weight_after"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600303.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-600304.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="実績詳細" sqlCode="-202"/>
  <occ name="コメント詳細" len="5" detail="コメント" sqlCode="-203"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -14}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -202, "facilityCd": "facilityCd", "messageType": "2"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -203, "facilityCd": "facilityCd", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600304, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}]}'::jsonb, '1', '0', 4, '2020-05-19 17:01:48.871', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070005, 'N_hosp', 'rst_dial', '', 'S', 'upd', 'text', 'NEC', 'MEGA', '透析実績（Ver2)/TSHPlus', '1', '<root name="透析実績(Ver2)">
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:U"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="dataset:-14.start_date8"/>
  <item name="実施開始時間" len="4" value="dataset:-14.start_date6"/>
  <item name="実施終了日" len="8" value="dataset:-14.end_date8"/>
  <item name="実施終了時間" len="4" value="dataset:-14.end_date6"/>
  <item name="実施場所" len="6" value="dataset:-11.bed_cd1"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v2"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.own_medi_code"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="前体重" len="5" value="dataset:-33.weight_before"/>
  <item name="後体重" len="5" value="dataset:-33.weight_after"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600303.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-600304.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="実績詳細" sqlCode="-202"/>
  <occ name="コメント詳細" len="5" detail="コメント" sqlCode="-203"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -14}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -202, "facilityCd": "facilityCd", "messageType": "2"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -203, "facilityCd": "facilityCd", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600304, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}]}'::jsonb, '1', '0', 4, '2020-05-19 17:01:48.871', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070006, 'N_hosp', 'rst_dial', '', 'S', 'del', 'text', 'NEC', 'MEGA', '透析実績（Ver2)/TSHPlus', '1', '<root name="透析実績(Ver2)">
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:D"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="$BLANK"/>
  <item name="実施開始時間" len="4" value="$BLANK"/>
  <item name="実施終了日" len="8" value="$BLANK"/>
  <item name="実施終了時間" len="4" value="$BLANK"/>
  <item name="実施場所" len="6" value="dataset:-11.bed_cd1"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_del_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v2"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.own_medi_code"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="前体重" len="5" value="const:00000"/>
  <item name="後体重" len="5" value="const:00000"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="const:0000"/>
  <item name="血液浄化法" len="6" value="dataset:-600304.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600304, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}]}'::jsonb, '1', '0', 4, '2020-05-19 17:01:48.871', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070007, 'N_hosp', 'rst_dial', '', 'S', 'cre', 'text', 'NEC', 'MEGA', '透析実績（Ver1)/TSHPlus', '1', '<root name="透析実績(Ver1)">
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:Y"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="dataset:-14.start_date8"/>
  <item name="実施開始時間" len="4" value="dataset:-14.start_date6"/>
  <item name="実施終了日" len="8" value="dataset:-14.end_date8"/>
  <item name="実施終了時間" len="4" value="dataset:-14.end_date6"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v1"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="前体重" len="5" value="dataset:-33.weight_before"/>
  <item name="後体重" len="5" value="dataset:-33.weight_after"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600303.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-11.treatment_cd"/>
  <item name="血液浄化法世代番号" len="1" value="dataset:-102.blood_purification_generation_no"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="実績詳細" sqlCode="-202"/>
  <occ name="コメント詳細" len="5" detail="コメント" sqlCode="-203"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -14}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -32}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -202, "facilityCd": "facilityCd", "messageType": "1"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -203, "facilityCd": "facilityCd", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070008, 'N_hosp', 'rst_dial', '', 'S', 'upd', 'text', 'NEC', 'MEGA', '透析実績（Ver1)/TSHPlus', '1', '<root name="透析実績(Ver1)">
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:U"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="dataset:-14.start_date8"/>
  <item name="実施開始時間" len="4" value="dataset:-14.start_date6"/>
  <item name="実施終了日" len="8" value="dataset:-14.end_date8"/>
  <item name="実施終了時間" len="4" value="dataset:-14.end_date6"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v1"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="前体重" len="5" value="dataset:-33.weight_before"/>
  <item name="後体重" len="5" value="dataset:-33.weight_after"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600303.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-11.treatment_cd"/>
  <item name="血液浄化法世代番号" len="1" value="dataset:-102.blood_purification_generation_no"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="実績詳細" sqlCode="-202"/>
  <occ name="コメント詳細" len="5" detail="コメント" sqlCode="-203"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -14}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -32}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -202, "facilityCd": "facilityCd", "messageType": "1"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -203, "facilityCd": "facilityCd", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070009, 'N_hosp', 'rst_dial', '', 'S', 'del', 'text', 'NEC', 'MEGA', '透析実績（Ver1)/TSHPlus', '1', '<root name="透析実績(Ver1)">
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:D"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="$BLANK"/>
  <item name="実施開始時間" len="4" value="$BLANK"/>
  <item name="実施終了日" len="8" value="$BLANK"/>
  <item name="実施終了時間" len="4" value="$BLANK"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_del_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v1"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="前体重" len="5" value="const:00000"/>
  <item name="後体重" len="5" value="const:00000"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="const:0000"/>
  <item name="血液浄化法" len="6" value="dataset:-102.blood_purification_method"/>
  <item name="血液浄化法世代番号" len="1" value="dataset:-102.blood_purification_generation_no"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070010, 'N_hosp', 'rst_dial', '', 'S', 'cre', 'text', 'NEC', 'MEGA', '透析実績（Ver2)/Standard', '1', '<root name="透析実績(Ver2)">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSEXEC"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:Y"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="dataset:-14.start_date8"/>
  <item name="実施開始時間" len="4" value="dataset:-14.start_date6"/>
  <item name="実施終了日" len="8" value="dataset:-14.end_date8"/>
  <item name="実施終了時間" len="4" value="dataset:-14.end_date6"/>
  <item name="実施場所" len="6" value="dataset:-11.bed_cd1"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v2"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.own_medi_code"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="前体重" len="5" value="dataset:-33.weight_before"/>
  <item name="後体重" len="5" value="dataset:-33.weight_after"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600303.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-11.treatment_cd"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="$JOURNAL.user_id"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="実績詳細" sqlCode="-202"/>
  <occ name="コメント詳細" len="5" detail="コメント" sqlCode="-203"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -14}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -202, "facilityCd": "facilityCd", "messageType": "2"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -203, "facilityCd": "facilityCd", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070011, 'N_hosp', 'rst_dial', '', 'S', 'upd', 'text', 'NEC', 'MEGA', '透析実績（Ver2)/Standard', '1', '<root name="透析実績(Ver2)">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSEXEC"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:U"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="dataset:-14.start_date8"/>
  <item name="実施開始時間" len="4" value="dataset:-14.start_date6"/>
  <item name="実施終了日" len="8" value="dataset:-14.end_date8"/>
  <item name="実施終了時間" len="4" value="dataset:-14.end_date6"/>
  <item name="実施場所" len="6" value="dataset:-11.bed_cd1"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v2"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.own_medi_code"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="前体重" len="5" value="dataset:-33.weight_before"/>
  <item name="後体重" len="5" value="dataset:-33.weight_after"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600303.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-11.treatment_cd"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="$JOURNAL.user_id"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="実績詳細" sqlCode="-202"/>
  <occ name="コメント詳細" len="5" detail="コメント" sqlCode="-203"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -14}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -202, "facilityCd": "facilityCd", "messageType": "2"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -203, "facilityCd": "facilityCd", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070012, 'N_hosp', 'rst_dial', '', 'S', 'del', 'text', 'NEC', 'MEGA', '透析実績（Ver2)/Standard', '1', '<root name="透析実績(Ver2)">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSEXEC"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:D"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="$BLANK"/>
  <item name="実施開始時間" len="4" value="$BLANK"/>
  <item name="実施終了日" len="8" value="$BLANK"/>
  <item name="実施終了時間" len="4" value="$BLANK"/>
  <item name="実施場所" len="6" value="dataset:-11.bed_cd1"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_del_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v2"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.own_medi_code"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="前体重" len="5" value="const:00000"/>
  <item name="後体重" len="5" value="const:00000"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="const:0000"/>
  <item name="血液浄化法" len="6" value="dataset:-11.treatment_cd"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="$JOURNAL.user_id"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3080001, 'N_hosp', 'rep_dial', '', 'S', 'cre', 'xml', 'NEC', 'NEC', '透析レポート送信Ver1', '1', '<multimedia_entry_service>
  <xmlmessage_type>
    <message_name>multimedia_entry_service</message_name>
    <message_type>reference</message_type>
    <message_version>1.0.0.0</message_version>
    <protocol_type>Send_Only</protocol_type>
  </xmlmessage_type>
  <send_message_attribute>
    <send_manufacture_name>日機装株式会社</send_manufacture_name>
    <send_application_name>FutureNet Web+Si</send_application_name>
    <send_application_version>1.0</send_application_version>
    <send_device_name>dataset:-102.device_name</send_device_name>
    <send_ip_address>dataset:-102.ip_address</send_ip_address>
    <send_datetime>$SYSDATE yyyyMMddHHmmssSSS</send_datetime>
    <additional_information/>
  </send_message_attribute>
  <application_data_section>
    <entry_data_object type="MMREF" execute="insert">
      <patient_data>
        <patient_hospital_code>dataset:-102.hosp_cd</patient_hospital_code>
        <patient_id>dataset:-600402.padding_hpid</patient_id>
        <patients_name>dataset:-600001.pat_name</patients_name>
        <patients_sex>dataset:-600001.pat_sex</patients_sex>
        <patients_birthdate>dataset:-600001.pat_birthday</patients_birthdate>
      </patient_data>
      <object_attribute>
        <object_typ>dataset:-102.obj_type</object_typ>
        <object_uid>dataset:-205.xml_key</object_uid>
        <send_system_code>dataset:-102.xml_cd</send_system_code>
        <relation_typ>URL</relation_typ>
        <me_typ>MMREF</me_typ>
        <me_styp>X</me_styp>
        <datacreater_userid>dataset:-600017.disp_user_id</datacreater_userid>
        <request_depart_code>dataset:-600403.ind_depart_code</request_depart_code>
        <request_userid>dataset:-600403.request_userid</request_userid>
        <transaction_time>dataset:-600405.start_date14</transaction_time>
        <flowsheet_starttime>dataset:-600405.start_date14</flowsheet_starttime>
        <flowsheet_endtime>dataset:-600405.end_date14</flowsheet_endtime>
        <patient_interactiontime>dataset:-600405.patient_interactiontime14</patient_interactiontime>
        <order_id/>
        <host_name>dataset:-102.update_terminal</host_name>
      </object_attribute>
      <object_data>
        <title_code>dataset:-102.title_cd</title_code>
        <title_name>dataset:-102.title_name</title_name>
        <fs_disp>dataset:-102.fs_disp</fs_disp>
        <disp_info no="n"/>
      </object_data>
      <storage_data_part mode="filename" count="1">
        <storage_data_information>
          <content_number>dataset:-102.content_number</content_number>
          <content_type>dataset:-102.content_type</content_type>
          <extent_name>dataset:-102.extent_name</extent_name>
          <data_position source="dataset:-104.pdf_file"/>
        </storage_data_information>
      </storage_data_part>
    </entry_data_object>
  </application_data_section>
</multimedia_entry_service>
', '{"dataset": [{"key0": "key0", "patId": "patId", "sqlCode": -600001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "sqlCode": -600017}, {"key0": "key0", "patId": "patId", "sqlCode": -600402, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600403, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600405, "facilityCd": "facilityCd"}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"ordNo": "ordNo", "sqlCode": -104}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -205, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "sqlCode": -104}}'::jsonb, '1', '1', -1, '2024-12-09 16:44:42.668', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3080002, 'N_hosp', 'rep_dial', '', 'S', 'cre', 'xml', 'NEC', 'NEC', '透析レポート送信Ver2', '1', '<multimedia_entry_service>
  <xmlmessage_type>
    <message_name>multimedia_entry_service</message_name>
    <message_type>reference</message_type>
    <message_version>1.0.0.0</message_version>
    <protocol_type>Send_Only</protocol_type>
  </xmlmessage_type>
  <send_message_attribute>
    <send_manufacture_name>日機装株式会社</send_manufacture_name>
    <send_application_name>FutureNet Web+Si</send_application_name>
    <send_application_version>1.0</send_application_version>
    <send_device_name>dataset:-102.device_name</send_device_name>
    <send_ip_address>dataset:-102.ip_address</send_ip_address>
    <send_datetime>$SYSDATE yyyyMMddHHmmssSSS</send_datetime>
    <additional_information/>
  </send_message_attribute>
  <application_data_section>
    <entry_data_object type="MMREF" execute="insert">
      <patient_data>
        <patient_hospital_code>dataset:-102.hosp_cd</patient_hospital_code>
        <patient_id>dataset:-600402.padding_hpid</patient_id>
        <patients_name>dataset:-600001.pat_name</patients_name>
        <patients_sex>dataset:-600001.pat_sex</patients_sex>
        <patients_birthdate>dataset:-600001.pat_birthday</patients_birthdate>
      </patient_data>
      <object_attribute>
        <object_typ>dataset:-102.obj_type</object_typ>
        <object_uid>dataset:-205.xml_key</object_uid>
        <send_system_code>dataset:-102.xml_cd</send_system_code>
        <relation_typ>URL</relation_typ>
        <me_typ>MMREF</me_typ>
        <me_styp>X</me_styp>
        <datacreater_userid>dataset:-600017.disp_user_id</datacreater_userid>
        <request_depart_code>dataset:-600403.ind_depart_code</request_depart_code>
        <request_userid>dataset:-600403.request_userid</request_userid>
        <transaction_time>dataset:-600405.start_date14</transaction_time>
        <flowsheet_starttime>dataset:-600405.start_date14</flowsheet_starttime>
        <flowsheet_endtime>dataset:-600405.end_date14</flowsheet_endtime>
        <patient_interactiontime>dataset:-600405.patient_interactiontime14</patient_interactiontime>
        <order_id/>
        <host_name>dataset:-102.update_terminal</host_name>
      </object_attribute>
      <object_data>
        <title_code>dataset:-102.title_cd</title_code>
        <title_name>dataset:-102.title_name</title_name>
        <fs_disp>dataset:-102.fs_disp</fs_disp>
        <disp_info no="n"/>
      </object_data>
      <storage_data_part mode="filename" count="1">
        <storage_data_information>
          <content_number>dataset:-102.content_number</content_number>
          <content_type>dataset:-102.content_type</content_type>
          <extent_name>dataset:-102.extent_name</extent_name>
          <data_position source="dataset:-104.pdf_file"/>
        </storage_data_information>
      </storage_data_part>
    </entry_data_object>
  </application_data_section>
</multimedia_entry_service>
', '{"dataset": [{"key0": "key0", "patId": "patId", "sqlCode": -600001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "sqlCode": -600017}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "patId": "patId", "sqlCode": -600402, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600403, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600405, "facilityCd": "facilityCd"}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"ordNo": "ordNo", "sqlCode": -104}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -205, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "sqlCode": -104}}'::jsonb, '1', '0', -1, '2024-12-09 16:44:42.668', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3080003, 'N_hosp', 'rep_dial', '', 'S', 'del', 'xml', 'NEC', 'NEC', '透析レポート送信Ver1', '1', '<multimedia_entry_service>
  <xmlmessage_type>
    <message_name>multimedia_entry_service</message_name>
    <message_type>reference</message_type>
    <message_version>1.0.0.0</message_version>
    <protocol_type>Send_Only</protocol_type>
  </xmlmessage_type>
  <send_message_attribute>
    <send_manufacture_name>日機装株式会社</send_manufacture_name>
    <send_application_name>FutureNet Web+Si</send_application_name>
    <send_application_version>1.0</send_application_version>
    <send_device_name>dataset:-102.device_name</send_device_name>
    <send_ip_address>dataset:-102.ip_address</send_ip_address>
    <send_datetime>$SYSDATE yyyyMMddHHmmssSSS</send_datetime>
    <additional_information/>
  </send_message_attribute>
  <application_data_section>
    <entry_data_object type="MMREF" execute="delete">
      <patient_data>
        <patient_hospital_code>dataset:-102.hosp_cd</patient_hospital_code>
        <patient_id>dataset:-600402.padding_hpid</patient_id>
        <patients_name>dataset:-600001.pat_name</patients_name>
        <patients_sex>dataset:-600001.pat_sex</patients_sex>
        <patients_birthdate>dataset:-600001.pat_birthday</patients_birthdate>
      </patient_data>
      <object_attribute>
        <object_typ>dataset:-102.obj_type</object_typ>
        <object_uid>dataset:-205.xml_key</object_uid>
        <send_system_code>dataset:-102.xml_cd</send_system_code>
        <datacreater_userid>dataset:-600017.disp_user_id</datacreater_userid>
        <request_depart_code>dataset:-600403.ind_depart_code</request_depart_code>
        <request_userid>dataset:-600403.request_userid</request_userid>
        <order_id/>
        <host_name>dataset:-102.update_terminal</host_name>
      </object_attribute>
    </entry_data_object>
  </application_data_section>
</multimedia_entry_service>
', '{"dataset": [{"key0": "key0", "patId": "patId", "sqlCode": -600001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "sqlCode": -600017}, {"key0": "key0", "patId": "patId", "sqlCode": -600402, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600403, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600405, "facilityCd": "facilityCd"}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"ordNo": "ordNo", "sqlCode": -104}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -205, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "sqlCode": -104}}'::jsonb, '1', '1', -1, '2024-12-09 16:44:42.668', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3080004, 'N_hosp', 'rep_dial', '', 'S', 'del', 'xml', 'NEC', 'NEC', '透析レポート送信Ver2', '1', '<multimedia_entry_service>
  <xmlmessage_type>
    <message_name>multimedia_entry_service</message_name>
    <message_type>reference</message_type>
    <message_version>1.0.0.0</message_version>
    <protocol_type>Send_Only</protocol_type>
  </xmlmessage_type>
  <send_message_attribute>
    <send_manufacture_name>日機装株式会社</send_manufacture_name>
    <send_application_name>FutureNet Web+Si</send_application_name>
    <send_application_version>1.0</send_application_version>
    <send_device_name>dataset:-102.device_name</send_device_name>
    <send_ip_address>dataset:-102.ip_address</send_ip_address>
    <send_datetime>$SYSDATE yyyyMMddHHmmssSSS</send_datetime>
    <additional_information/>
  </send_message_attribute>
  <application_data_section>
    <entry_data_object type="MMREF" execute="delete">
      <patient_data>
        <patient_hospital_code>dataset:-102.hosp_cd</patient_hospital_code>
        <patient_id>dataset:-600402.padding_hpid</patient_id>
        <patients_name>dataset:-600001.pat_name</patients_name>
        <patients_sex>dataset:-600001.pat_sex</patients_sex>
        <patients_birthdate>dataset:-600001.pat_birthday</patients_birthdate>
      </patient_data>
      <object_attribute>
        <object_typ>dataset:-102.obj_type</object_typ>
        <object_uid>dataset:-205.xml_key</object_uid>
        <send_system_code>dataset:-102.xml_cd</send_system_code>
        <datacreater_userid>dataset:-600017.disp_user_id</datacreater_userid>
        <request_depart_code>dataset:-600403.ind_depart_code</request_depart_code>
        <request_userid>dataset:-600403.request_userid</request_userid>
        <order_id/>
        <host_name>dataset:-102.update_terminal</host_name>
      </object_attribute>
    </entry_data_object>
  </application_data_section>
</multimedia_entry_service>
', '{"dataset": [{"key0": "key0", "patId": "patId", "sqlCode": -600001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "sqlCode": -600017}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "patId": "patId", "sqlCode": -600402, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600403, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600405, "facilityCd": "facilityCd"}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"ordNo": "ordNo", "sqlCode": -104}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -205, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "sqlCode": -104}}'::jsonb, '1', '0', -1, '2024-12-09 16:44:42.668', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3080005, 'N_hosp', 'rep_dial', '', 'S', 'upd', 'xml', 'NEC', 'NEC', '透析レポート送信Ver1', '1', '<multimedia_entry_service>
  <xmlmessage_type>
    <message_name>multimedia_entry_service</message_name>
    <message_type>reference</message_type>
    <message_version>1.0.0.0</message_version>
    <protocol_type>Send_Only</protocol_type>
  </xmlmessage_type>
  <send_message_attribute>
    <send_manufacture_name>日機装株式会社</send_manufacture_name>
    <send_application_name>FutureNet Web+Si</send_application_name>
    <send_application_version>1.0</send_application_version>
    <send_device_name>dataset:-102.device_name</send_device_name>
    <send_ip_address>dataset:-102.ip_address</send_ip_address>
    <send_datetime>$SYSDATE yyyyMMddHHmmssSSS</send_datetime>
    <additional_information/>
  </send_message_attribute>
  <application_data_section>
    <entry_data_object type="MMREF" execute="insert">
      <patient_data>
        <patient_hospital_code>dataset:-102.hosp_cd</patient_hospital_code>
        <patient_id>dataset:-600402.padding_hpid</patient_id>
        <patients_name>dataset:-600001.pat_name</patients_name>
        <patients_sex>dataset:-600001.pat_sex</patients_sex>
        <patients_birthdate>dataset:-600001.pat_birthday</patients_birthdate>
      </patient_data>
      <object_attribute>
        <object_typ>dataset:-102.obj_type</object_typ>
        <object_uid>dataset:-205.xml_key</object_uid>
        <send_system_code>dataset:-102.xml_cd</send_system_code>
        <relation_typ>URL</relation_typ>
        <me_typ>MMREF</me_typ>
        <me_styp>X</me_styp>
        <datacreater_userid>dataset:-600017.disp_user_id</datacreater_userid>
        <request_depart_code>dataset:-600403.ind_depart_code</request_depart_code>
        <request_userid>dataset:-600403.request_userid</request_userid>
        <transaction_time>dataset:-600405.start_date14</transaction_time>
        <flowsheet_starttime>dataset:-600405.start_date14</flowsheet_starttime>
        <flowsheet_endtime>dataset:-600405.end_date14</flowsheet_endtime>
        <patient_interactiontime>dataset:-600405.patient_interactiontime14</patient_interactiontime>
        <order_id/>
        <host_name>dataset:-102.update_terminal</host_name>
      </object_attribute>
      <object_data>
        <title_code>dataset:-102.title_cd</title_code>
        <title_name>dataset:-102.title_name</title_name>
        <fs_disp>dataset:-102.fs_disp</fs_disp>
        <disp_info no="n"/>
      </object_data>
      <storage_data_part mode="filename" count="1">
        <storage_data_information>
          <content_number>dataset:-102.content_number</content_number>
          <content_type>dataset:-102.content_type</content_type>
          <extent_name>dataset:-102.extent_name</extent_name>
          <data_position source="dataset:-104.pdf_file"/>
        </storage_data_information>
      </storage_data_part>
    </entry_data_object>
  </application_data_section>
</multimedia_entry_service>
', '{"dataset": [{"key0": "key0", "patId": "patId", "sqlCode": -600001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "sqlCode": -600017}, {"key0": "key0", "patId": "patId", "sqlCode": -600402, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600403, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600405, "facilityCd": "facilityCd"}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"ordNo": "ordNo", "sqlCode": -104}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -205, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "sqlCode": -104}}'::jsonb, '1', '1', -1, '2024-12-09 16:44:42.668', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3080006, 'N_hosp', 'rep_dial', '', 'S', 'upd', 'xml', 'NEC', 'NEC', '透析レポート送信Ver2', '1', '<multimedia_entry_service>
  <xmlmessage_type>
    <message_name>multimedia_entry_service</message_name>
    <message_type>reference</message_type>
    <message_version>1.0.0.0</message_version>
    <protocol_type>Send_Only</protocol_type>
  </xmlmessage_type>
  <send_message_attribute>
    <send_manufacture_name>日機装株式会社</send_manufacture_name>
    <send_application_name>FutureNet Web+Si</send_application_name>
    <send_application_version>1.0</send_application_version>
    <send_device_name>dataset:-102.device_name</send_device_name>
    <send_ip_address>dataset:-102.ip_address</send_ip_address>
    <send_datetime>$SYSDATE yyyyMMddHHmmssSSS</send_datetime>
    <additional_information/>
  </send_message_attribute>
  <application_data_section>
    <entry_data_object type="MMREF" execute="insert">
      <patient_data>
        <patient_hospital_code>dataset:-102.hosp_cd</patient_hospital_code>
        <patient_id>dataset:-600402.padding_hpid</patient_id>
        <patients_name>dataset:-600001.pat_name</patients_name>
        <patients_sex>dataset:-600001.pat_sex</patients_sex>
        <patients_birthdate>dataset:-600001.pat_birthday</patients_birthdate>
      </patient_data>
      <object_attribute>
        <object_typ>dataset:-102.obj_type</object_typ>
        <object_uid>dataset:-205.xml_key</object_uid>
        <send_system_code>dataset:-102.xml_cd</send_system_code>
        <relation_typ>URL</relation_typ>
        <me_typ>MMREF</me_typ>
        <me_styp>X</me_styp>
        <datacreater_userid>dataset:-600017.disp_user_id</datacreater_userid>
        <request_depart_code>dataset:-600403.ind_depart_code</request_depart_code>
        <request_userid>dataset:-600403.request_userid</request_userid>
        <transaction_time>dataset:-600405.start_date14</transaction_time>
        <flowsheet_starttime>dataset:-600405.start_date14</flowsheet_starttime>
        <flowsheet_endtime>dataset:-600405.end_date14</flowsheet_endtime>
        <patient_interactiontime>dataset:-600405.patient_interactiontime14</patient_interactiontime>
        <order_id/>
        <host_name>dataset:-102.update_terminal</host_name>
      </object_attribute>
      <object_data>
        <title_code>dataset:-102.title_cd</title_code>
        <title_name>dataset:-102.title_name</title_name>
        <fs_disp>dataset:-102.fs_disp</fs_disp>
        <disp_info no="n"/>
      </object_data>
      <storage_data_part mode="filename" count="1">
        <storage_data_information>
          <content_number>dataset:-102.content_number</content_number>
          <content_type>dataset:-102.content_type</content_type>
          <extent_name>dataset:-102.extent_name</extent_name>
          <data_position source="dataset:-104.pdf_file"/>
        </storage_data_information>
      </storage_data_part>
    </entry_data_object>
  </application_data_section>
</multimedia_entry_service>
', '{"dataset": [{"key0": "key0", "patId": "patId", "sqlCode": -600001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "sqlCode": -600017}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "patId": "patId", "sqlCode": -600402, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600403, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600405, "facilityCd": "facilityCd"}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"ordNo": "ordNo", "sqlCode": -104}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -205, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "sqlCode": -104}}'::jsonb, '1', '0', -1, '2024-12-09 16:44:42.668', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3080007, 'N_hosp', 'rep_dial', 'listxml', 'S', 'cre', 'xml', 'NEC標準(MegaOakHR) 透析レポート(listxml)', 'NEC標準(MegaOakHR)', '透析レポート送信', '1', '<rootNode DISP_PATID_LENGTH="dataset:-600010.hosp_pat_id_len">
  <PATIENT DISP_PATID="dataset:-600001.hosp_pat_id" PATID="$JOURNAL.pat_id" NAME="dataset:-600001.pat_name" KANA="dataset:-600001.pat_name_kana" SEX="dataset:-600001.pat_sex" BLOODABO="dataset:-600001.pat_blood_type_abo" BLOODRH="dataset:-600001.pat_blood_type_rh" AGE="dataset:-600001.pat_age" UPDATE_DATETIME="dataset:-600001.up_date"/>
</rootNode>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"sqlCode": -600010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}]}'::jsonb, '1', '0', -1, '2021-11-22 11:31:58.328', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3080008, 'N_hosp', 'rep_dial', 'pdf', 'S', 'upd', 'pdf', 'NEC標準(MegaOakHR) 透析レポート(pdf)', 'NEC標準(MegaOakHR)', '透析レポート送信', '1', NULL, NULL, '1', '0', -1, '2023-07-17 21:00:58.864', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3080009, 'N_hosp', 'rep_dial', 'pdf', 'S', 'cre', 'pdf', 'NEC標準(MegaOakHR) 透析レポート(pdf)', 'NEC標準(MegaOakHR)', '透析レポート送信', '1', NULL, NULL, '1', '0', -1, '2023-07-17 21:00:58.864', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3080010, 'N_hosp', 'rep_dial', 'tar', 'S', 'upd', 'xml', 'NEC標準(MegaOakHR) 透析レポート(tar)', 'NEC標準(MegaOakHR)', '透析レポート送信Ver1', '1', '<multimedia_entry_service>
  <xmlmessage_type>
    <message_name>multimedia_entry_service</message_name>
    <message_type>reference</message_type>
    <message_version>1.0.0.0</message_version>
    <protocol_type>Send_Only</protocol_type>
  </xmlmessage_type>
  <send_message_attribute>
    <send_manufacture_name>日機装株式会社</send_manufacture_name>
    <send_application_name>FutureNet Web+Si</send_application_name>
    <send_application_version>1.0</send_application_version>
    <send_device_name>dataset:-102.device_name</send_device_name>
    <send_ip_address>dataset:-102.ip_address</send_ip_address>
    <send_datetime>$SYSDATE yyyyMMddHHmmssSSS</send_datetime>
    <additional_information/>
  </send_message_attribute>
  <application_data_section>
    <entry_data_object type="MMREF" execute="insert">
      <patient_data>
        <patient_hospital_code>dataset:-102.hosp_cd</patient_hospital_code>
        <patient_id>dataset:-600402.padding_hpid</patient_id>
        <patients_name>dataset:-600001.pat_name</patients_name>
        <patients_sex>dataset:-600001.pat_sex</patients_sex>
        <patients_birthdate>dataset:-600001.pat_birthday</patients_birthdate>
      </patient_data>
      <object_attribute>
        <object_typ>dataset:-102.obj_type</object_typ>
        <object_uid>dataset:-205.tar_key</object_uid>
        <send_system_code>dataset:-102.xml_cd</send_system_code>
        <relation_typ>URL</relation_typ>
        <me_typ>MMREF</me_typ>
        <me_styp>X</me_styp>
        <datacreater_userid>dataset:-600017.disp_user_id</datacreater_userid>
        <request_depart_code>dataset:-600403.ind_depart_code</request_depart_code>
        <request_userid>dataset:-600403.request_userid</request_userid>
        <transaction_time>dataset:-600405.start_date14</transaction_time>
        <flowsheet_starttime>dataset:-600405.start_date14</flowsheet_starttime>
        <flowsheet_endtime>dataset:-600405.end_date14</flowsheet_endtime>
        <patient_interactiontime>dataset:-600405.patient_interactiontime14</patient_interactiontime>
        <order_id/>
        <host_name>dataset:-102.update_terminal</host_name>
      </object_attribute>
      <object_data>
        <title_code>dataset:-102.title_cd</title_code>
        <title_name>dataset:-102.title_name</title_name>
        <fs_disp>dataset:-102.fs_disp</fs_disp>
        <disp_info no="n"/>
      </object_data>
      <storage_data_part mode="filename" count="1">
        <storage_data_information>
          <content_number>dataset:-102.content_number</content_number>
          <content_type>dataset:-102.content_type</content_type>
          <extent_name>dataset:-102.extent_name</extent_name>
          <data_position source="dataset:-104.pdf_file"/>
        </storage_data_information>
      </storage_data_part>
    </entry_data_object>
  </application_data_section>
</multimedia_entry_service>
', '{"dataset": [{"key0": "key0", "patId": "patId", "sqlCode": -600001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "sqlCode": -600017}, {"key0": "key0", "patId": "patId", "sqlCode": -600402, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600403, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600405, "facilityCd": "facilityCd"}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"ordNo": "ordNo", "sqlCode": -104}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -205, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "sqlCode": -104}}'::jsonb, '1', '1', -1, '2024-12-09 16:44:42.668', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3080011, 'N_hosp', 'rep_dial', 'tar', 'S', 'cre', 'xml', 'NEC標準(MegaOakHR) 透析レポート(tar)', 'NEC標準(MegaOakHR)', '透析レポート送信Ver1', '1', '<multimedia_entry_service>
  <xmlmessage_type>
    <message_name>multimedia_entry_service</message_name>
    <message_type>reference</message_type>
    <message_version>1.0.0.0</message_version>
    <protocol_type>Send_Only</protocol_type>
  </xmlmessage_type>
  <send_message_attribute>
    <send_manufacture_name>日機装株式会社</send_manufacture_name>
    <send_application_name>FutureNet Web+Si</send_application_name>
    <send_application_version>1.0</send_application_version>
    <send_device_name>dataset:-102.device_name</send_device_name>
    <send_ip_address>dataset:-102.ip_address</send_ip_address>
    <send_datetime>$SYSDATE yyyyMMddHHmmssSSS</send_datetime>
    <additional_information/>
  </send_message_attribute>
  <application_data_section>
    <entry_data_object type="MMREF" execute="insert">
      <patient_data>
        <patient_hospital_code>dataset:-102.hosp_cd</patient_hospital_code>
        <patient_id>dataset:-600402.padding_hpid</patient_id>
        <patients_name>dataset:-600001.pat_name</patients_name>
        <patients_sex>dataset:-600001.pat_sex</patients_sex>
        <patients_birthdate>dataset:-600001.pat_birthday</patients_birthdate>
      </patient_data>
      <object_attribute>
        <object_typ>dataset:-102.obj_type</object_typ>
        <object_uid>dataset:-205.tar_key</object_uid>
        <send_system_code>dataset:-102.xml_cd</send_system_code>
        <relation_typ>URL</relation_typ>
        <me_typ>MMREF</me_typ>
        <me_styp>X</me_styp>
        <datacreater_userid>dataset:-600017.disp_user_id</datacreater_userid>
        <request_depart_code>dataset:-600403.ind_depart_code</request_depart_code>
        <request_userid>dataset:-600403.request_userid</request_userid>
        <transaction_time>dataset:-600405.start_date14</transaction_time>
        <flowsheet_starttime>dataset:-600405.start_date14</flowsheet_starttime>
        <flowsheet_endtime>dataset:-600405.end_date14</flowsheet_endtime>
        <patient_interactiontime>dataset:-600405.patient_interactiontime14</patient_interactiontime>
        <order_id/>
        <host_name>dataset:-102.update_terminal</host_name>
      </object_attribute>
      <object_data>
        <title_code>dataset:-102.title_cd</title_code>
        <title_name>dataset:-102.title_name</title_name>
        <fs_disp>dataset:-102.fs_disp</fs_disp>
        <disp_info no="n"/>
      </object_data>
      <storage_data_part mode="filename" count="1">
        <storage_data_information>
          <content_number>dataset:-102.content_number</content_number>
          <content_type>dataset:-102.content_type</content_type>
          <extent_name>dataset:-102.extent_name</extent_name>
          <data_position source="dataset:-104.pdf_file"/>
        </storage_data_information>
      </storage_data_part>
    </entry_data_object>
  </application_data_section>
</multimedia_entry_service>
', '{"dataset": [{"key0": "key0", "patId": "patId", "sqlCode": -600001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "sqlCode": -600017}, {"key0": "key0", "patId": "patId", "sqlCode": -600402, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600403, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600405, "facilityCd": "facilityCd"}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"ordNo": "ordNo", "sqlCode": -104}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -205, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "sqlCode": -104}}'::jsonb, '1', '1', -1, '2024-12-09 16:44:42.668', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3080013, 'N_hosp', 'rep_dial', 'xml', 'S', 'del', 'xml', 'NEC標準(MegaOakHR) 透析レポート(xml)', 'NEC標準(MegaOakHR)', '透析レポート送信', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-600001.up_date">
    <DISP_PATID>dataset:-600001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-600001.pat_name</NAME>
    <KANA>dataset:-600001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-600001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-600001.pat_age</AGE>
    <SEX>dataset:-600001.pat_sex</SEX>
    <INOUT>dataset:-600001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-600000">
  </REPORTS>
</rootNode>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"sqlCode": -600000}]}'::jsonb, '1', '0', -1, '2024-09-10 18:00:40.807', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3080015, 'N_hosp', 'rep_dial', 'listxml', 'S', 'del', 'xml', 'NEC標準(MegaOakHR) 透析レポート(listxml)', 'NEC標準(MegaOakHR)', '透析レポート送信', '1', '<rootNode DISP_PATID_LENGTH="dataset:-600010.hosp_pat_id_len">
  <PATIENT DISP_PATID="dataset:-600001.hosp_pat_id" PATID="$JOURNAL.pat_id" NAME="dataset:-600001.pat_name" KANA="dataset:-600001.pat_name_kana" SEX="dataset:-600001.pat_sex" BLOODABO="dataset:-600001.pat_blood_type_abo" BLOODRH="dataset:-600001.pat_blood_type_rh" AGE="dataset:-600001.pat_age" UPDATE_DATETIME="dataset:-600001.up_date"/>
</rootNode>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"sqlCode": -600010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}]}'::jsonb, '1', '0', -1, '2024-09-10 18:00:40.807', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3080017, 'N_hosp', 'rep_dial', 'pdf', 'S', 'del', 'pdf', 'NEC標準(MegaOakHR) 透析レポート(pdf)', 'NEC標準(MegaOakHR)', '透析レポート送信', '1', NULL, NULL, '1', '0', -1, '2024-09-10 18:00:40.807', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3080018, 'N_hosp', 'rep_dial', 'tar', 'S', 'upd', 'xml', 'NEC標準(MegaOakHR) 透析レポート(tar)', 'NEC標準(MegaOakHR)', '透析レポート送信Ver2', '1', '<multimedia_entry_service>
  <xmlmessage_type>
    <message_name>multimedia_entry_service</message_name>
    <message_type>reference</message_type>
    <message_version>1.0.0.0</message_version>
    <protocol_type>Send_Only</protocol_type>
  </xmlmessage_type>
  <send_message_attribute>
    <send_manufacture_name>日機装株式会社</send_manufacture_name>
    <send_application_name>FutureNet Web+Si</send_application_name>
    <send_application_version>1.0</send_application_version>
    <send_device_name>dataset:-102.device_name</send_device_name>
    <send_ip_address>dataset:-102.ip_address</send_ip_address>
    <send_datetime>$SYSDATE yyyyMMddHHmmssSSS</send_datetime>
    <additional_information/>
  </send_message_attribute>
  <application_data_section>
    <entry_data_object type="MMREF" execute="insert">
      <patient_data>
        <patient_hospital_code>dataset:-102.hosp_cd</patient_hospital_code>
        <patient_id>dataset:-600402.padding_hpid</patient_id>
        <patients_name>dataset:-600001.pat_name</patients_name>
        <patients_sex>dataset:-600001.pat_sex</patients_sex>
        <patients_birthdate>dataset:-600001.pat_birthday</patients_birthdate>
      </patient_data>
      <object_attribute>
        <object_typ>dataset:-102.obj_type</object_typ>
        <object_uid>dataset:-205.tar_key</object_uid>
        <send_system_code>dataset:-102.xml_cd</send_system_code>
        <relation_typ>URL</relation_typ>
        <me_typ>MMREF</me_typ>
        <me_styp>X</me_styp>
        <datacreater_userid>dataset:-600017.disp_user_id</datacreater_userid>
        <request_depart_code>dataset:-600403.ind_depart_code</request_depart_code>
        <request_userid>dataset:-600403.request_userid</request_userid>
        <transaction_time>dataset:-600405.start_date14</transaction_time>
        <flowsheet_starttime>dataset:-600405.start_date14</flowsheet_starttime>
        <flowsheet_endtime>dataset:-600405.end_date14</flowsheet_endtime>
        <patient_interactiontime>dataset:-600405.patient_interactiontime14</patient_interactiontime>
        <order_id/>
        <host_name>dataset:-102.update_terminal</host_name>
      </object_attribute>
      <object_data>
        <title_code>dataset:-102.title_cd</title_code>
        <title_name>dataset:-102.title_name</title_name>
        <fs_disp>dataset:-102.fs_disp</fs_disp>
        <disp_info no="n"/>
      </object_data>
      <storage_data_part mode="filename" count="1">
        <storage_data_information>
          <content_number>dataset:-102.content_number</content_number>
          <content_type>dataset:-102.content_type</content_type>
          <extent_name>dataset:-102.extent_name</extent_name>
          <data_position source="dataset:-104.pdf_file"/>
        </storage_data_information>
      </storage_data_part>
    </entry_data_object>
  </application_data_section>
</multimedia_entry_service>
', '{"dataset": [{"key0": "key0", "patId": "patId", "sqlCode": -600001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "sqlCode": -600017}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "patId": "patId", "sqlCode": -600402, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600403, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600405, "facilityCd": "facilityCd"}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"ordNo": "ordNo", "sqlCode": -104}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -205, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "sqlCode": -104}}'::jsonb, '1', '0', -1, '2024-12-09 16:44:42.668', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3080019, 'N_hosp', 'rep_dial', 'tar', 'S', 'cre', 'xml', 'NEC標準(MegaOakHR) 透析レポート(tar)', 'NEC標準(MegaOakHR)', '透析レポート送信Ver2', '1', '<multimedia_entry_service>
  <xmlmessage_type>
    <message_name>multimedia_entry_service</message_name>
    <message_type>reference</message_type>
    <message_version>1.0.0.0</message_version>
    <protocol_type>Send_Only</protocol_type>
  </xmlmessage_type>
  <send_message_attribute>
    <send_manufacture_name>日機装株式会社</send_manufacture_name>
    <send_application_name>FutureNet Web+Si</send_application_name>
    <send_application_version>1.0</send_application_version>
    <send_device_name>dataset:-102.device_name</send_device_name>
    <send_ip_address>dataset:-102.ip_address</send_ip_address>
    <send_datetime>$SYSDATE yyyyMMddHHmmssSSS</send_datetime>
    <additional_information/>
  </send_message_attribute>
  <application_data_section>
    <entry_data_object type="MMREF" execute="insert">
      <patient_data>
        <patient_hospital_code>dataset:-102.hosp_cd</patient_hospital_code>
        <patient_id>dataset:-600402.padding_hpid</patient_id>
        <patients_name>dataset:-600001.pat_name</patients_name>
        <patients_sex>dataset:-600001.pat_sex</patients_sex>
        <patients_birthdate>dataset:-600001.pat_birthday</patients_birthdate>
      </patient_data>
      <object_attribute>
        <object_typ>dataset:-102.obj_type</object_typ>
        <object_uid>dataset:-205.tar_key</object_uid>
        <send_system_code>dataset:-102.xml_cd</send_system_code>
        <relation_typ>URL</relation_typ>
        <me_typ>MMREF</me_typ>
        <me_styp>X</me_styp>
        <datacreater_userid>dataset:-600017.disp_user_id</datacreater_userid>
        <request_depart_code>dataset:-600403.ind_depart_code</request_depart_code>
        <request_userid>dataset:-600403.request_userid</request_userid>
        <transaction_time>dataset:-600405.start_date14</transaction_time>
        <flowsheet_starttime>dataset:-600405.start_date14</flowsheet_starttime>
        <flowsheet_endtime>dataset:-600405.end_date14</flowsheet_endtime>
        <patient_interactiontime>dataset:-600405.patient_interactiontime14</patient_interactiontime>
        <order_id/>
        <host_name>dataset:-102.update_terminal</host_name>
      </object_attribute>
      <object_data>
        <title_code>dataset:-102.title_cd</title_code>
        <title_name>dataset:-102.title_name</title_name>
        <fs_disp>dataset:-102.fs_disp</fs_disp>
        <disp_info no="n"/>
      </object_data>
      <storage_data_part mode="filename" count="1">
        <storage_data_information>
          <content_number>dataset:-102.content_number</content_number>
          <content_type>dataset:-102.content_type</content_type>
          <extent_name>dataset:-102.extent_name</extent_name>
          <data_position source="dataset:-104.pdf_file"/>
        </storage_data_information>
      </storage_data_part>
    </entry_data_object>
  </application_data_section>
</multimedia_entry_service>
', '{"dataset": [{"key0": "key0", "patId": "patId", "sqlCode": -600001, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "sqlCode": -600017}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "patId": "patId", "sqlCode": -600402, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600403, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600405, "facilityCd": "facilityCd"}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"ordNo": "ordNo", "sqlCode": -104}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -205, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "sqlCode": -104}}'::jsonb, '1', '0', -1, '2024-12-09 16:44:42.668', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3090001, 'N_hosp', 'exam_rst', '', 'R', 'all', 'text     ', 'NEC想定検査結果受信', 'MEGA', 'Standard', '1', '<root name="検査結果(all)">
  <item name="空白" len="20" type="string"/>
  <item name="電文長" len="12" type="string"/>
  <item name="コマンド名" len="8" type="string"/>
  <item name="モード" len="1" type="string"  col="$journal.const.crud"  value="json:{&quot;A&quot;:&quot;C&quot;,&quot;D&quot;:&quot;D&quot;}"/>
  <item name="オーダ番号" len="13" type="string" col="$journal.pat_exam_main.cop_order_no1"/>
  <item name="オーダサブ番号" len="3" type="string"/>
  <item name="検体番号" len="13" type="string"/>
  <item name="病院番号" len="2" type="string"/>
  <item name="患者番号" len="10" type="string" col="$journal.pat_personal_main.hosp_pat_id"/>
  <item name="採取日-採取時間" len="12" type="string" col="$journal.pat_exam_main.result_exam_date"/>
  <item name="オーダ番号" len="13" type="string"/>
  <item name="オーダサブ番号" len="3" type="string"/>
  <item name="検体番号(検査部門の番号)" len="13" type="string"/>
  <item name="送信区分" len="1" type="string"/>
  <item name="入外区分" len="1" type="string"/>
  <item name="依頼元科コード" len="2" type="string"/>
  <item name="依頼元病棟コード" len="4" type="string"/>
  <item name="部門コード" len="2" type="string"/>
  <item name="受付時間 " len="4" type="string"/>
  <item name="ラックNo" len="7" type="string"/>
  <item name="検査材料コード" len="3" type="string"/>
  <item name="緊急区分" len="1" type="string"/>
  <item name="検査区分" len="1" type="string"/>
  <item name="医師コード" len="10" type="string"/>
  <item name="蓄尿開始時間" len="2" type="string"/>
  <item name="蓄尿終了時間 " len="2" type="string"/>
  <item name="蓄尿量" len="5" type="string"/>
  <item name="負荷薬剤情報1" len="16" type="string"/>
  <item name="負荷薬剤情報2" len="16" type="string"/>
  <item name="負荷薬剤情報3" len="16" type="string"/>
  <item name="負荷薬剤情報4" len="16" type="string"/>
  <item name="オーダ依頼コメント1" len="2" type="string" col="$journal.pat_exam_main.reg_order_class1"/>
  <item name="オーダ依頼コメント2" len="2" type="string" col="$journal.pat_exam_main.reg_order_class2"/>
  <item name="オーダ依頼コメントフリー" len="60" type="string"/>
  <item name="検体コメントフリー" len="60" type="string"/>
  <item name="採取No" len="13" type="string"/>
  <item name="医師名" len="20" type="string"/>
  <item name="ベッドNo " len="7" type="string"/>
  <item name="緊急区分2 " len="1" type="string"/>
  <item name="緊急区分3" len="1" type="string"/>
  <item name="更新日付" len="14" type="string"/>
  <item name="更新端末" len="10" type="string"/>
  <item name="更新者" len="10" type="string"/>
  <item name="検体受付日" len="8" type="string"/>
  <item name="ORDERCOMMENT3" len="2" type="string"/>
  <item name="ORDERCOMMENT4" len="2" type="string"/>
  <item name="ORDERCOMMENT5" len="2" type="string"/>
  <occ name="結果項目数" len="3" detail = "検査結果詳細" col="$journal.pat_exam_main.data_count"/>
  <occ name="検査コメント数" len="3" detail="検査コメント詳細"/>
</root>', '{"dataset": {"sqlGroup1": [{"No1": "電文のモードが『D:削除』の場合、処理しません。", "No2": "受信電文のDetail数が0件の場合、処理しません。", "crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D,$journal.pat_exam_main.data_count#<>#0", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}], "sqlGroup2": [{"No1": "電文のモードが『D:削除』の場合、処理しません。", "No2": "受信電文のDetail数が0件の場合、処理しません。", "crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D,$journal.pat_exam_main.data_count#<>#0", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 9201, "insertResult": "{@examMainCd:'''', @patId:'''', @facilityCd:'''', @ordNo:'''', @fnPatId:'''', @regExamDate_Date:'''', @regOrderClass:'''', @examStatus:''1'', @orderComment:'''', @orderExamSetInfoValue:''[]'', @examOrderInfoValue:''[]'', @orderLabelInfoValue:''[]'', @dataGenClass:''2'', @resultExamDate_Date:'''', @resultComment:'''', @examResultInfoValue:''[]'', @copOrderNo1:'''', @copOrderNo2:'''', @isLock:''1'', @indUserId:'''', @isDel:'''', @regDate:'''', @regStaff:'''', @upDate:'''', @upStaff:'''', @isOrder:'''', @examWeek:'''', @examFrom:'''', @examTo:'''', @examPattern:''''}", "updateResult": "{@examMainCd:''exam_main_cd'', @patId:''pat_id'', @facilityCd:''facility_cd'', @ordNo:''ord_no'', @fnPatId:''fn_pat_id'', @regExamDate_Date:''reg_exam_date'', @regOrderClass:''reg_order_class'', @examStatus:''exam_status'', @orderComment:''order_comment'', @orderExamSetInfoValue:''order_exam_set_info'', @examOrderInfoValue:''exam_order_info'', @orderLabelInfoValue:''order_label_info'', @dataGenClass:''data_gen_class'', @resultExamDate_Date:''result_exam_date'', @resultComment:''result_comment'', @examResultInfoValue:''exam_result_info'', @copOrderNo1:''cop_order_no1'', @copOrderNo2:''cop_order_no2'', @isLock:''is_lock'', @indUserId:''ind_user_id'', @isDel:''is_del'', @regDate:''reg_date'', @regStaff:''reg_staff'', @upDate:''up_date'', @upStaff:''up_staff'', @isOrder:''is_order'', @examWeek:''exam_week'', @examFrom:''exam_from'', @examTo:''exam_to'', @examPattern:''exam_pattern'', }", "@regOrderClass1": "$journal.pat_exam_main.reg_order_class1", "@regOrderClass2": "$journal.pat_exam_main.reg_order_class2", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D,$journal.pat_exam_main.data_count#<>#0", "table": "pat_exam_main", "ctl_no": "2", "@isLock": "1", "sqlCode": 9202, "@examStatus": "1", "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1", "@dataGenClass": "2", "@regOrderClass1": "$journal.pat_exam_main.reg_order_class1", "@regOrderClass2": "$journal.pat_exam_main.reg_order_class2", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D,$journal.pat_exam_main.data_count#<>#0", "table": "pat_exam_main", "ctl_no": "3", "sqlCode": 9203, "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}], "sqlGroup3": [{"No1": "電文のモードが『D:削除』の場合、処理しません。", "No2": "受信電文のDetail数が0件の場合、処理しません。", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.crud#<>#D,$journal.pat_exam_main.data_count#<>#0", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 9201, "updateResult": "{@nextDispOrder:''next_disp_order'', @examMainCd:''exam_main_cd'', @examResultInfoFlg:'''',@examResultInfoValue:''exam_result_info'',@examResultInfo.comCd:'''', @examResultInfo.dispOrder:'''', @examResultInfo.examClass:'''', @examResultInfo.hl:'''', @examResultInfo.itemCd:'''', @examResultInfo.itemName:'''', @examResultInfo.jlac10Cd:'''', @examResultInfo.lower:'''', @examResultInfo.result:'''', @examResultInfo.resultDateresultDate_Date:'''', @examResultInfo.type:'''', @examResultInfo.unit:'''', @examResultInfo.upper:''''}", "@regOrderClass1": "$journal.pat_exam_main.reg_order_class1", "@regOrderClass2": "$journal.pat_exam_main.reg_order_class2", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}, {"Note": "json場合、[D]の設定が必要です。しかし、NECの検査結果をクリアしません。judgeに[crud#=#NG]を設定する。", "crud": "D", "kind": "1", "judge": "$journal.const.crud#=#NG", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": 9204}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D,$journal.pat_exam_main.data_count#<>#0", "table": "pat_exam_main", "ctl_no": "3", "sqlCode": 9205, "@examResultInfo.hl": "$journal.detail.pat_exam_main.exam_result_info.hl", "@examResultInfo.type": "", "@examResultInfo.unit": "", "@examResultInfo.lower": "$journal.detail.pat_exam_main.exam_result_info.lower", "@examResultInfo.upper": "$journal.detail.pat_exam_main.exam_result_info.upper", "@examResultInfo.comCd1": "$journal.detail.pat_exam_main.exam_result_info.com_cd1", "@examResultInfo.comCd2": "$journal.detail.pat_exam_main.exam_result_info.com_cd2", "@examResultInfo.itemCd": "$journal.detail.pat_exam_main.exam_result_info.item_cd", "@examResultInfo.result": "$journal.detail.pat_exam_main.exam_result_info.result", "@examResultInfo.itemName": "", "@examResultInfo.examClass": "", "@examResultInfo.resultDate_Date": "$journal.detail.pat_exam_main.exam_result_info.result_date"}], "sqlGroup4": [{"No1": "項目コードまたは編集結果値が空白の場合、該当項目(Detail単位)の登録を行いません。（登録対象外）", "No2": "登録対象項目が０件の場合は、処理しません。", "No3": "No1とNo2の内容より、検査結果情報(exam_result_info)のデータが０件場合、新規登録したデータを削除する", "crud": "D", "kind": "1", "judge": "$journal.const.crud#<>#D,$journal.pat_exam_main.data_count#<>#0", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 9206, "@regOrderClass1": "$journal.pat_exam_main.reg_order_class1", "@regOrderClass2": "$journal.pat_exam_main.reg_order_class2", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}]}, "json-key": {"{\"A\":\"C\",\"D\":\"D\"}": {"A": "C", "D": "D"}}, "CoopMstConvUtil": {"$journal.detail.pat_exam_main.exam_result_info.item_cd": {"conv_type": "mst_exam_item", "data_0_event": "null", "hospital_cd_names": ["in_hospital_cd1"]}}}'::jsonb, '1', '1', -1, '2019-12-13 05:44:54.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3090002, 'N_hosp', 'exam_rst', '', 'R', 'all', 'text     ', 'NEC想定検査結果受信', 'MEGA', 'TSHPlus', '1', '<root name="検査結果(all)">
  <item name="コマンド名" len="8" type="string"/>
  <item name="モード" len="1" type="string"  col="$journal.const.crud"  value="json:{&quot;A&quot;:&quot;C&quot;,&quot;D&quot;:&quot;D&quot;}"/>
  <item name="オーダ番号" len="13" type="string" col="$journal.pat_exam_main.cop_order_no1"/>
  <item name="オーダサブ番号" len="3" type="string"/>
  <item name="検体番号" len="13" type="string"/>
  <item name="病院番号" len="2" type="string"/>
  <item name="患者番号" len="10" type="string" col="$journal.pat_personal_main.hosp_pat_id"/>
  <item name="採取日-採取時間" len="12" type="string" col="$journal.pat_exam_main.result_exam_date"/>
  <item name="オーダ番号" len="13" type="string"/>
  <item name="オーダサブ番号" len="3" type="string"/>
  <item name="検体番号(検査部門の番号)" len="13" type="string"/>
  <item name="送信区分" len="1" type="string"/>
  <item name="入外区分" len="1" type="string"/>
  <item name="依頼元科コード" len="2" type="string"/>
  <item name="依頼元病棟コード" len="4" type="string"/>
  <item name="部門コード" len="2" type="string"/>
  <item name="受付時間 " len="4" type="string"/>
  <item name="ラックNo" len="7" type="string"/>
  <item name="検査材料コード" len="3" type="string"/>
  <item name="緊急区分" len="1" type="string"/>
  <item name="検査区分" len="1" type="string"/>
  <item name="医師コード" len="10" type="string"/>
  <item name="蓄尿開始時間" len="2" type="string"/>
  <item name="蓄尿終了時間 " len="2" type="string"/>
  <item name="蓄尿量" len="5" type="string"/>
  <item name="負荷薬剤情報1" len="16" type="string"/>
  <item name="負荷薬剤情報2" len="16" type="string"/>
  <item name="負荷薬剤情報3" len="16" type="string"/>
  <item name="負荷薬剤情報4" len="16" type="string"/>
  <item name="オーダ依頼コメント1" len="2" type="string" col="$journal.pat_exam_main.reg_order_class1"/>
  <item name="オーダ依頼コメント2" len="2" type="string" col="$journal.pat_exam_main.reg_order_class2"/>
  <item name="オーダ依頼コメントフリー" len="60" type="string"/>
  <item name="検体コメントフリー" len="60" type="string"/>
  <item name="採取No" len="13" type="string"/>
  <item name="医師名" len="20" type="string"/>
  <item name="ベッドNo " len="7" type="string"/>
  <item name="緊急区分2 " len="1" type="string"/>
  <item name="緊急区分3" len="1" type="string"/>
  <item name="更新日付" len="14" type="string"/>
  <item name="更新端末" len="10" type="string"/>
  <item name="更新者" len="10" type="string"/>
  <item name="検体受付日" len="8" type="string"/>
  <item name="ORDERCOMMENT3" len="2" type="string"/>
  <item name="ORDERCOMMENT4" len="2" type="string"/>
  <item name="ORDERCOMMENT5" len="2" type="string"/>
  <occ name="結果項目数" len="3" detail = "検査結果詳細" col="$journal.pat_exam_main.data_count"/>
  <occ name="検査コメント数" len="3" detail="検査コメント詳細"/>
</root>', '{"dataset": {"sqlGroup1": [{"No1": "電文のモードが『D:削除』の場合、処理しません。", "No2": "受信電文のDetail数が0件の場合、処理しません。", "crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D,$journal.pat_exam_main.data_count#<>#0", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}], "sqlGroup2": [{"No1": "電文のモードが『D:削除』の場合、処理しません。", "No2": "受信電文のDetail数が0件の場合、処理しません。", "crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D,$journal.pat_exam_main.data_count#<>#0", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 9201, "insertResult": "{@examMainCd:'''', @patId:'''', @facilityCd:'''', @ordNo:'''', @fnPatId:'''', @regExamDate_Date:'''', @regOrderClass:'''', @examStatus:''1'', @orderComment:'''', @orderExamSetInfoValue:''[]'', @examOrderInfoValue:''[]'', @orderLabelInfoValue:''[]'', @dataGenClass:''2'', @resultExamDate_Date:'''', @resultComment:'''', @examResultInfoValue:''[]'', @copOrderNo1:'''', @copOrderNo2:'''', @isLock:''1'', @indUserId:'''', @isDel:'''', @regDate:'''', @regStaff:'''', @upDate:'''', @upStaff:'''', @isOrder:'''', @examWeek:'''', @examFrom:'''', @examTo:'''', @examPattern:''''}", "updateResult": "{@examMainCd:''exam_main_cd'', @patId:''pat_id'', @facilityCd:''facility_cd'', @ordNo:''ord_no'', @fnPatId:''fn_pat_id'', @regExamDate_Date:''reg_exam_date'', @regOrderClass:''reg_order_class'', @examStatus:''exam_status'', @orderComment:''order_comment'', @orderExamSetInfoValue:''order_exam_set_info'', @examOrderInfoValue:''exam_order_info'', @orderLabelInfoValue:''order_label_info'', @dataGenClass:''data_gen_class'', @resultExamDate_Date:''result_exam_date'', @resultComment:''result_comment'', @examResultInfoValue:''exam_result_info'', @copOrderNo1:''cop_order_no1'', @copOrderNo2:''cop_order_no2'', @isLock:''is_lock'', @indUserId:''ind_user_id'', @isDel:''is_del'', @regDate:''reg_date'', @regStaff:''reg_staff'', @upDate:''up_date'', @upStaff:''up_staff'', @isOrder:''is_order'', @examWeek:''exam_week'', @examFrom:''exam_from'', @examTo:''exam_to'', @examPattern:''exam_pattern'', }", "@regOrderClass1": "$journal.pat_exam_main.reg_order_class1", "@regOrderClass2": "$journal.pat_exam_main.reg_order_class2", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D,$journal.pat_exam_main.data_count#<>#0", "table": "pat_exam_main", "ctl_no": "2", "@isLock": "1", "sqlCode": 9202, "@examStatus": "1", "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1", "@dataGenClass": "2", "@regOrderClass1": "$journal.pat_exam_main.reg_order_class1", "@regOrderClass2": "$journal.pat_exam_main.reg_order_class2", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D,$journal.pat_exam_main.data_count#<>#0", "table": "pat_exam_main", "ctl_no": "3", "sqlCode": 9203, "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}], "sqlGroup3": [{"No1": "電文のモードが『D:削除』の場合、処理しません。", "No2": "受信電文のDetail数が0件の場合、処理しません。", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.crud#<>#D,$journal.pat_exam_main.data_count#<>#0", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 9201, "updateResult": "{@nextDispOrder:''next_disp_order'', @examMainCd:''exam_main_cd'', @examResultInfoFlg:'''',@examResultInfoValue:''exam_result_info'',@examResultInfo.comCd:'''', @examResultInfo.dispOrder:'''', @examResultInfo.examClass:'''', @examResultInfo.hl:'''', @examResultInfo.itemCd:'''', @examResultInfo.itemName:'''', @examResultInfo.jlac10Cd:'''', @examResultInfo.lower:'''', @examResultInfo.result:'''', @examResultInfo.resultDateresultDate_Date:'''', @examResultInfo.type:'''', @examResultInfo.unit:'''', @examResultInfo.upper:''''}", "@regOrderClass1": "$journal.pat_exam_main.reg_order_class1", "@regOrderClass2": "$journal.pat_exam_main.reg_order_class2", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}, {"Note": "json場合、[D]の設定が必要です。しかし、NECの検査結果をクリアしません。judgeに[crud#=#NG]を設定する。", "crud": "D", "kind": "1", "judge": "$journal.const.crud#=#NG", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": 9204}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D,$journal.pat_exam_main.data_count#<>#0", "table": "pat_exam_main", "ctl_no": "3", "sqlCode": 9205, "@examResultInfo.hl": "$journal.detail.pat_exam_main.exam_result_info.hl", "@examResultInfo.type": "", "@examResultInfo.unit": "", "@examResultInfo.lower": "$journal.detail.pat_exam_main.exam_result_info.lower", "@examResultInfo.upper": "$journal.detail.pat_exam_main.exam_result_info.upper", "@examResultInfo.comCd1": "$journal.detail.pat_exam_main.exam_result_info.com_cd1", "@examResultInfo.comCd2": "$journal.detail.pat_exam_main.exam_result_info.com_cd2", "@examResultInfo.itemCd": "$journal.detail.pat_exam_main.exam_result_info.item_cd", "@examResultInfo.result": "$journal.detail.pat_exam_main.exam_result_info.result", "@examResultInfo.itemName": "", "@examResultInfo.examClass": "", "@examResultInfo.resultDate_Date": "$journal.detail.pat_exam_main.exam_result_info.result_date"}], "sqlGroup4": [{"No1": "項目コードまたは編集結果値が空白の場合、該当項目(Detail単位)の登録を行いません。（登録対象外）", "No2": "登録対象項目が０件の場合は、処理しません。", "No3": "No1とNo2の内容より、検査結果情報(exam_result_info)のデータが０件場合、新規登録したデータを削除する", "crud": "D", "kind": "1", "judge": "$journal.const.crud#<>#D,$journal.pat_exam_main.data_count#<>#0", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 9206, "@regOrderClass1": "$journal.pat_exam_main.reg_order_class1", "@regOrderClass2": "$journal.pat_exam_main.reg_order_class2", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}]}, "json-key": {"{\"A\":\"C\",\"D\":\"D\"}": {"A": "C", "D": "D"}}, "CoopMstConvUtil": {"$journal.detail.pat_exam_main.exam_result_info.item_cd": {"conv_type": "mst_exam_item", "data_0_event": "null", "hospital_cd_names": ["in_hospital_cd1"]}}}'::jsonb, '1', '0', -1, '2019-12-13 05:44:54.000', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3160001, 'N_hosp', 'vit_cop', '', 'S', 'cre', 'text', 'NECバイタル送信', 'MEGA', 'バイタル送信', '1', '<root name="バイタル">
    <item  name="メッセージID" len="8" value="const:R-VITAL"/>
    <item  name="種別" len="1" value="const:A"/>
    <item  name="病院コード" len="2" value="const:01"/>
    <item  name="患者ID" len="10" value="$JOURNAL.hosp_pat_id" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="送信日時" len="14" value="$SYSDATE yyyyMMddHHmmss"/>
    <item  name="予備" len="5" value="$BLANK"/>
    <occ  name="バイタル項目数" len="3" detail="バイタル" sqlCode="-201"/>
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -201, "facilityCd": "facilityCd"}], "dumpFileName": {"patId": "patId", "sqlCode": -99997}}'::jsonb, '1', '0', 4, '2020-05-15 11:01:33.529', CURRENT_TIMESTAMP, 'HR');