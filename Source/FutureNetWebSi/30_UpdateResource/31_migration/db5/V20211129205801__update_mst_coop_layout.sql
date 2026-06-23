delete from "mst_coop_layout" where "ctl_no" in (-3010001,-3010002,-3010003,-3010004,-3010005);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010001, 'N_hosp', 'ini_dial', '', 'R', 'pre', 'text     ', 'NEC想定透析初回指示', 'MEGA', 'テスト用', '1', '<root name="透析申込(pre)">
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
  <item name="オーダ番号" len="16" type="string"/>
  <item name="情報区分" len="1" type="string"/>
  <item name="指示科" len="2" type="string"/>
  <item name="指示科名称" len="20" type="string"/>
  <item name="指示医" len="10" type="string"/>
  <item name="指示医名称" len="20" type="string"/>
  <item name="指示医世代番号" len="1" type="string"/>
  <item name="保険コード01" len="3" type="string"/>
  <item name="保険コード02" len="3" type="string"/>
  <item name="保険コード03" len="3" type="string"/>
  <item name="保険コード04" len="3" type="string"/>
  <item name="保険コード05" len="3" type="string"/>
  <item name="透析種別" len="1" type="string"/>
  <item name="透析コース" len="6" type="string"/>
  <item name="透析コース名称" len="60" type="string"/>
  <item name="透析パターン" len="6" type="string"/>
  <item name="透析パターン名称" len="60" type="string"/>
  <item name="開始日（定期）" len="8" type="string"/>
  <item name="終了日（定期）" len="8" type="string"/>
  <item name="透析日１（臨時）" len="8" type="string"/>
  <item name="透析日２（臨時）" len="8" type="string"/>
  <item name="透析日３（臨時）" len="8" type="string"/>
  <item name="透析日４（臨時）" len="8" type="string"/>
  <item name="透析日５（臨時）" len="8" type="string"/>
  <item name="透析日６（臨時）" len="8" type="string"/>
  <item name="透析日７（臨時）" len="8" type="string"/>
  <item name="透析日８（臨時）" len="8" type="string"/>
  <item name="透析日９（臨時）" len="8" type="string"/>
  <item name="透析日１０（臨時）" len="8" type="string"/>
  <item name="透析日１１（臨時）" len="8" type="string"/>
  <item name="透析日１２（臨時）" len="8" type="string"/>
  <item name="透析日１３（臨時）" len="8" type="string"/>
  <item name="透析日１４（臨時）" len="8" type="string"/>
  <item name="透析日１５（臨時）" len="8" type="string"/>
  <item name="透析導入日" len="8" type="string"/>
  <item name="実施場所" len="6" type="string"/>
  <item name="実施場所名称" len="60" type="string"/>
  <item name="加算（患者に付随する加算）" len="6" type="string"/>
  <item name="加算世代番号" len="1" type="string"/>
  <item name="加算名称" len="60" type="string"/>
  <item name="ベッド予約番号" len="13" type="string"/>
  <item name="使用ベッド" len="6" type="string"/>
  <item name="使用ベッド名称" len="60" type="string"/>
  <item name="ベッド予約時間帯" len="1" type="string"/>
  <item name="ブラッドアクセス" len="6" type="string"/>
  <item name="ブラッドアクセス名称" len="60" type="string"/>
  <item name="部位" len="6" type="string"/>
  <item name="部位名称" len="60" type="string"/>
  <item name="ＤＷ" len="4" type="string"/>
  <item name="血液浄化法" len="6" type="string"/>
  <item name="血液浄化法世代番号" len="1" type="string"/>
  <item name="血液浄化法名称" len="60" type="string"/>
  <item name="依頼オーダ番号" len="16" type="string"/>
  <item name="実施オーダ番号" len="16" type="string"/>
  <item name="進捗" len="2" type="string"/>
  <item name="血液浄化方法　医事コード" len="6" type="string"/>
  <item name="血液浄化方法　医事世代コード" len="1" type="string"/>
  <item name="新規登録日" len="8" type="string"/>
  <item name="新規登録時間" len="6" type="string"/>
  <item name="更新日" len="8" type="string"/>
  <item name="更新時間" len="6" type="string"/>
  <item name="更新端末" len="10" type="string"/>
  <item name="更新者" len="10" type="string"/>
  <item name="更新者世代番号" len="1" type="string"/>
  <item name="予備" len="30" type="string"/>
  <occ name="オーダ指示詳細数" len="5" type="string" detail="透析指示オーダ明細"/>
  <occ name="オーダ指示コメント数" len="5" type="string" detail="透析コメント明細"/>
</root>', '{"key": {"command_name": {"C-DIRECT": "初回指示情報", "C-KNJDEL": "患者死亡退院情報", "C-KNJUPD": "患者情報"}}, "dataset": {"sqlGroup1": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "@isDie": "0", "ctl_no": "2", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": 1102, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "1", "@severityCd": "$journal.pat_personal_main.severity_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@transportCd": "$journal.pat_personal_main.transport_cd", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "@isDie": "0", "ctl_no": "3", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": 1103, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "1", "@severityCd": "$journal.pat_personal_main.severity_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@transportCd": "$journal.pat_personal_main.transport_cd", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}], "sqlGroup2": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "No3": "NEC場合、病棟コードより、[入外区分]を更新する。病棟コードが空白の場合は「入外区分 = 外来」で登録、空白でない場合は「入外区分 = 入院」で登録します。", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "No3": "NEC場合、[入外区分]の更新処理、pat_personal_mainを更新する。または、pat_mainから、データを取得する。tableにpat_mainを設定しました。", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "2", "sqlCode": 9101, "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd"}], "sqlGroup3": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "No3": "NEC場合、[死亡患者、連絡先情報、透析困難情報]を更新する。", "No4": "死亡退院日が空白の場合は「死亡患者 = 対象外」で登録、空白でない場合は「死亡患者 = 対象」で登録します。", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "2", "sqlCode": 9102}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_personal_main", "ctl_no": "3", "sqlCode": 9103, "@dieDate_Date": "$journal.pat_personal_main.die_date", "@otherContactInfo.tel1": "$journal.pat_personal_main.other_contact_info.tel1", "@dialDiffComInfo.isMain": "1", "@otherContactInfo.zipCd": "$journal.pat_personal_main.other_contact_info.zip_cd", "@otherContactInfo.address": "$journal.pat_personal_main.other_contact_info.address", "@otherContactInfo.patName": "$journal.pat_personal_main.pat_name", "@dialDiffComInfo.dialDiffCd": "$journal.pat_personal_main.dial_diff_com_info.dial_diff_cd", "@dialDiffComInfo.isDialDiff": "1", "@otherContactInfo.relationCd": "6", "@otherContactInfo.patNameKana": "$journal.pat_personal_main.pat_name_kana"}], "sqlGroup4": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201, "insertResult": "{@patId:'''',@facilityCd:'''',@isSame:'''',@isImplant:'''',@isInfect:'''',@isDiabetes:'''',@isBloodSugerExam:'''',@inOutCurrentState:'''',@inOutPlanState:'''',@inOutPlanDate_Date:'''',@patMemoInfoValue:''[]'',@additionInfoValue:''[]'',@chargeStaffInfoValue:''[]'',@patGroupInfoValue:''[]'',@tabooAllergyInfoValue:''[]'',@infectInfoValue:''[]'',@implantInfoValue:''[]'',@tareInfoValue:''{}'',@offWaterInfoValue:''{}'',@deviceSetInfoValue:''{}'',@acceptanceStatusInfoValue:''[]'',@isWheelChair:'''',@medicalCareInfoFlg:'''',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:'''',@schExtStatus:'''',@cardIdm:'''',@oldUpDate_Date:''''}", "updateResult": "{@patId:''pat_id'',@facilityCd:''facility_cd'',@isSame:''is_same'',@isImplant:''is_implant'',@isInfect:''is_infect'',@isDiabetes:''is_diabetes'',@isBloodSugerExam:''is_blood_suger_exam'',@inOutCurrentState:''in_out_current_state'',@inOutPlanState:''in_out_plan_state'',@inOutPlanDate_Date:''in_out_plan_date'',@patMemoInfoValue:''pat_memo_info'',@additionInfoValue:''addition_info'',@chargeStaffInfoValue:''charge_staff_info'',@patGroupInfoValue:''pat_group_info'',@tabooAllergyInfoValue:''taboo_allergy_info'',@infectInfoValue:''infect_info'',@implantInfoValue:''implant_info'',@tareInfoValue:''tare_info'',@offWaterInfoValue:''off_water_info'',@deviceSetInfoValue:''device_set_info'',@acceptanceStatusInfoValue:''acceptance_status_info'',@isWheelChair:''is_wheel_chair'',@medicalCareInfoFlg:'''',@medicalCareInfoValue:''medical_care_info'',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:''sch_ext_end_date'',@schExtStatus:''sch_ext_status'',@cardIdm:''card_idm'',@oldUpDate_Date:''old_up_date''}"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "2", "sqlCode": 1202, "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "3", "sqlCode": 1203, "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}], "sqlGroup5": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "2", "sqlCode": 9104}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_main", "ctl_no": "3", "sqlCode": 9105, "@infectInfo": "$journal.pat_main.infect_info", "@tabooAllergyInfo": "$journal.pat_main.taboo_allergy_info", "@chargeStaffInfo.staffCd": "$journal.pat_main.charge_staff_info.staff_cd"}], "sqlGroup6": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_unique", "ctl_no": "1", "sqlCode": 1601, "insertResult": "{@patId:'''', @facilityCd:'''', @medicalHstInfoValue:''[]'', @inOutVisitHistoryInfoValue:''[]'', @physicalInfoFlg:'''', @physicalInfoValue:''[]''}"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_unique", "ctl_no": "2", "sqlCode": 9106, "@physicalInfo.dw": "$journal.pat_unique.physical_info.dw", "@physicalInfo.height": "$journal.pat_unique.physical_info.height", "@physicalInfo.ctrWeight": "$journal.pat_unique.physical_info.ctr_weight", "@physicalInfo.orderClass": "1"}, {"No2": "患者死亡退院情報連携以外(初回指示連携Ver1、初回指示連携Ver2、患者情報)、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#<>#C-KNJDEL,$journal.const.crud#<>#D", "table": "pat_unique", "ctl_no": "3", "sqlCode": 9107, "@physicalInfo.dw": "$journal.pat_unique.physical_info.dw", "@physicalInfo.height": "$journal.pat_unique.physical_info.height", "@physicalInfo.ctrWeight": "$journal.pat_unique.physical_info.ctr_weight", "@physicalInfo.orderClass": "1"}], "sqlGroup7": [{"No1": "指示情報→登録・更新", "No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_insurance_1", "ctl_no": "1", "sqlCode": 9108, "@coopCode": "$journal.detail.pat_insurance_1.coop_code", "insertResult": "{@insuranceCd:''0'',@patId:''0'',@facilityCd:''0'',@ctlNo:'''',@fnPatId:'''',@insuClass:'''',@insuName:'''',@insuNmShort:'''',@insuInfoFlg:'''',@insuInfo.insuNo:'''',@insuInfo.insuPatName:'''',@insuInfo.insuPatNo:'''',@insuInfo.insuKbn:'''',@insuInfo.insuPatMark:'''',@insuInfo.ckiClass:'''',@insuInfo.kkiClass:'''',@insuInfo.undSix:'''',@insuInfo.futan-g:'''',@insuInfo.futan-n:'''',@insuPubInfoFlg:'''',@insuPubInfo.insuPubName:'''',@insuPubInfo.insuPubNo:'''',@insuPubInfo.insuPubPatNo:'''',@insuSetInfoFlg:'''',@insuSetInfo.insuCd:'''',@insuSetInfo.insuPub1Cd:'''',@insuSetInfo.insuPub2Cd:'''',@insuSetInfo.insuPub3Cd:'''',@insuSetInfo.insuPub4Cd:'''',@isSelected:'''',@isDisp:''1'',@coopCode:'''',@isCoop:'''',@startDate:'''',@endDate:'''',@checkDate:'''',@oldUpDate_Date:''''}", "updateResult": "{@insuranceCd:''insurance_cd'',@patId:''pat_id'',@facilityCd:''facility_cd'',@ctlNo:''ctl_no'',@fnPatId:''fn_pat_id'',@insuClass:''insu_class'',@insuName:''insu_name'',@insuNmShort:''insu_name_short'',@insuInfoFlg:'''',@insuInfoValue:''insu_info'',@insuInfo.insuNo:'''',@insuInfo.insuPatName:'''',@insuInfo.insuPatNo:'''',@insuInfo.insuKbn:'''',@insuInfo.insuPatMark:'''',@insuInfo.ckiClass:'''',@insuInfo.kkiClass:'''',@insuInfo.undSix:'''',@insuInfo.futan-g:'''',@insuInfo.futan-n:'''',@insuPubInfoFlg:'''',@insuPubInfoValue:''insu_pub_info'',@insuPubInfo.insuPubName:'''',@insuPubInfo.insuPubNo:'''',@insuPubInfo.insuPubPatNo:'''',@insuSetInfoFlg:'''',@insuSetInfoValue:''insu_set_info'',@insuSetInfo.insuCd:'''',@insuSetInfo.insuPub1Cd:'''',@insuSetInfo.insuPub2Cd:'''',@insuSetInfo.insuPub3Cd:'''',@insuSetInfo.insuPub4Cd:'''',@isSelected:''is_selected'',@isDisp:''is_disp'',@coopCode:''coop_code'',@isCoop:''is_coop'',@startDate:''start_date'',@endDate:''end_date'',@checkDate:''check_date'',@oldUpDate_Date:''old_up_date''}"}, {"No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_insurance_1", "ctl_no": "2", "sqlCode": 9109, "@coopCode": "$journal.detail.pat_insurance_1.coop_code"}, {"No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_insurance_1", "ctl_no": "3", "sqlCode": 9110, "@coopCode": "$journal.detail.pat_insurance_1.coop_code"}], "sqlGroup8": [{"No1": "指示情報→登録・更新", "No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_coop_detail", "ctl_no": "1", "sqlCode": 9111, "insertResult": "{@coopSaveNo:'''', @facilityCd:'''', @patId:'''', @save1Flg:'''', @save1.key01:'''', @save1.key02:'''', @save1.key03:'''', @save1.key04:'''', @save1.key05:'''', @save1.key06:'''', @save1.key07:'''', @save1.key08:'''', @save1.key09:'''', @save1.key10:'''', @save2:'''', @save3:'''', @save4:'''', @save5:'''', @save6:'''', @save7:'''', @save8:'''', @save9:'''', @save10:'''', @isDisp:'''', @isDel:'''', @userId:'''', @upDate_Date:'''', @regDate_Date:''''}", "updateResult": "{@coopSaveNo:''coop_save_no'', @facilityCd:''facility_cd'', @patId:''pat_id'', @save1Flg:'''', @save1Value:''save_1'', @save1.key01:'''', @save1.key02:'''', @save1.key03:'''', @save1.key04:'''', @save1.key05:'''', @save1.key06:'''', @save1.key07:'''', @save1.key08:'''', @save1.key09:'''', @save1.key10:'''', @save2:''save_2'', @save3:''save_3'', @save4:''save_4'', @save5:''save_5'', @save6:''save_6'', @save7:''save_7'', @save8:''save_8'', @save9:''save_9'', @save10:''save_10'', @isDisp:''is_disp'', @isDel:''is_del'', @userId:''user_id'', @upDate_Date:''up_date'', @regDate_Date:''reg_date'', }"}, {"No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_coop_detail", "ctl_no": "2", "@userId": "-1", "sqlCode": 9112, "@save1.key01": "$journal.pat_coop_detail.save_1.key_01", "@save1.key02": "$journal.pat_coop_detail.save_1.key_02", "@save1.key03": "$journal.pat_coop_detail.save_1.key_03", "@save1.key04": "$journal.pat_coop_detail.save_1.key_04", "@save1.key05": "$journal.pat_coop_detail.save_1.key_05", "@save1.key06": "$journal.pat_coop_detail.save_1.key_06", "@save1.key07": "$journal.pat_coop_detail.save_1.key_07", "@save1.key08": "$journal.pat_coop_detail.save_1.key_08", "@save1.key09": "$journal.pat_coop_detail.save_1.key_09"}, {"No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "pat_coop_detail", "ctl_no": "3", "@userId": "-1", "sqlCode": 9113, "@save1.key01": "$journal.pat_coop_detail.save_1.key_01", "@save1.key02": "$journal.pat_coop_detail.save_1.key_02", "@save1.key03": "$journal.pat_coop_detail.save_1.key_03", "@save1.key04": "$journal.pat_coop_detail.save_1.key_04", "@save1.key05": "$journal.pat_coop_detail.save_1.key_05", "@save1.key06": "$journal.pat_coop_detail.save_1.key_06", "@save1.key07": "$journal.pat_coop_detail.save_1.key_07", "@save1.key08": "$journal.pat_coop_detail.save_1.key_08", "@save1.key09": "$journal.pat_coop_detail.save_1.key_09"}], "sqlGroup9": [{"No1": "指示情報→登録・更新", "No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": 9114, "@treatDate": "$journal.pat_coop_detail.save_1.key_06", "insertResult": "{@ordNo:'''', @patId:'''', @fnPatId:'''', @treatDate:'''', @treatWeek:'''', @facilityCd:'''', @facilityName:'''', @indVaCd:'''', @indTreatmentCd:'''', @indTreatmentName:'''', @indKurCd:'''', @indKurName:'''', @indTreatStartTime:'''', @indBedCd:'''', @indBedName:'''', @indScheduleUserInfoFlg:'''', @indScheduleUserInfo.indUserId:'''', @indScheduleUserInfo.indUserLastName:'''', @indScheduleUserInfo.indUserFirstName:'''', @indScheduleUserInfo.updUserId:'''', @indScheduleUserInfo.updUserLastName:'''', @indScheduleUserInfo.updUserFirstName:'''', @indCondInfo:''{}'', @indMediInfoValue:''[]'', @indEquipInfoValue:''[]'', @indIndCommentInfoValue:''[]'', @indTareInfoFlg:'''', @indTareInfo.name1:'''', @indTareInfo.name2:'''', @indTareInfo.name3:'''', @indTareInfo.name4:'''', @indTareInfo.name5:'''', @indTareInfo.weight1:'''', @indTareInfo.weight2:'''', @indTareInfo.weight3:'''', @indTareInfo.weight4:'''', @indTareInfo.weight5:'''', @indOffWaterInfoFlg:'''', @indOffWaterInfo.name1:'''', @indOffWaterInfo.name2:'''', @indOffWaterInfo.name3:'''', @indOffWaterInfo.name4:'''', @indOffWaterInfo.name5:'''', @indOffWaterInfo.weight1:'''', @indOffWaterInfo.weight2:'''', @indOffWaterInfo.weight3:'''', @indOffWaterInfo.weight4:'''', @indOffWaterInfo.weight5:'''', @indDeviceSetInfo:''{}'', @rstFnDialysisNo:'''', @rstRelationDialysisNo:'''', @rstEdition:''0'', @rstIsUpdateEdition:'''', @rstInputClass:'''', @rstDialysisState:''0'', @rstTreatmentCd:'''', @rstTreatmentName:'''', @rstKurCd:'''', @rstKurName:'''', @rstBedCd:'''', @rstBedName:'''', @rstMachineNo:'''', @rstMachineName:'''', @rstCondSendDate_Date:'''', @rstAcceptDate_Date:'''', @rstStartDate_Date:'''', @rstEndDate_Date:'''', @rstReturnHomeDate_Date:'''', @rstInOutClass:'''', @rstDialysisCnt:'''', @rstWardCd:'''', @rstWardName:'''', @rstCourseCd:'''', @rstCourseName:'''', @rstPunctureUserInfo:'''', @rstReturnUserInfo:'''', @rstChargeUserInfo:'''', @rstBloodCirculateTotal:'''', @rstRunningTime:'''', @rstKtV:'''', @recSetDate_Date:'''', @sendCtlNo:'''', @bloodPurifierName:'''', @pullLeaveAmount:'''', @rstCondInfo:'''', @rstMediInfo:'''', @rstEquipInfo:'''', @rstIndCommentInfo:'''', @rstTareInfo:'''', @rstOffWaterInfo:'''', @rstDeviceSetInfo:'''', @rstWeightInfo:'''', @rstVitalInfo:'''', @rstComplaintInfo:'''', @rstTreatmentInfo:'''', @rstTreatStaffInfo:'''', @rstRoundsInfo:'''', @isDel:''0'', @upDate_Date:'''', @regDate_Date:'''', @rstDw:'''', @weightScaleNo:'''', @treatType:''1'', @isConfirm:''0'', @indDw:'''', @rstPurificationCnt:'''', @additionInfo:'''', @upIndUserId:'''', @upUserId:'''', @rstEditionDate_Date:'''', @curEditionDate_Date:'''', @fnPlural:''''}", "updateResult": "{@ordNo:''ord_no'', @patId:''pat_id'', @fnPatId:''fn_pat_id'', @treatDate:''treat_date'', @treatWeek:''treat_week'', @facilityCd:''facility_cd'', @facilityName:''facility_name'', @indVaCd:''ind_va_cd'', @indTreatmentCd:''ind_treatment_cd'', @indTreatmentName:''ind_treatment_name'', @indKurCd:''ind_kur_cd'', @indKurName:''ind_kur_name'', @indTreatStartTime:''ind_treat_start_time'', @indBedCd:''ind_bed_cd'', @indBedName:''ind_bed_name'', @indScheduleUserInfoFlg:'''', @indScheduleUserInfoValue:''ind_schedule_user_info'', @indScheduleUserInfo.indUserId:'''', @indScheduleUserInfo.indUserLastName:'''', @indScheduleUserInfo.indUserFirstName:'''', @indScheduleUserInfo.updUserId:'''', @indScheduleUserInfo.updUserLastName:'''', @indScheduleUserInfo.updUserFirstName:'''', @indCondInfo:''ind_cond_info'', @indMediInfoValue:''ind_medi_info'', @indEquipInfoValue:''ind_equip_info'', @indIndCommentInfoValue:''ind_ind_comment_info'', @indTareInfoFlg:'''', @indTareInfoValue:''ind_tare_info'', @indTareInfo.name1:'''', @indTareInfo.name2:'''', @indTareInfo.name3:'''', @indTareInfo.name4:'''', @indTareInfo.name5:'''', @indTareInfo.weight1:'''', @indTareInfo.weight2:'''', @indTareInfo.weight3:'''', @indTareInfo.weight4:'''', @indTareInfo.weight5:'''', @indOffWaterInfoFlg:'''', @indOffWaterInfoValue:''ind_off_water_info'', @indOffWaterInfo.name1:'''', @indOffWaterInfo.name2:'''', @indOffWaterInfo.name3:'''', @indOffWaterInfo.name4:'''', @indOffWaterInfo.name5:'''', @indOffWaterInfo.weight1:'''', @indOffWaterInfo.weight2:'''', @indOffWaterInfo.weight3:'''', @indOffWaterInfo.weight4:'''', @indOffWaterInfo.weight5:'''', @indDeviceSetInfo:''ind_device_set_info'', @rstFnDialysisNo:''rst_fn_dialysis_no'', @rstRelationDialysisNo:''rst_relation_dialysis_no'', @rstEdition:''rst_edition'', @rstIsUpdateEdition:''rst_is_update_edition'', @rstInputClass:''rst_input_class'', @rstDialysisState:''rst_dialysis_state'', @rstTreatmentCd:''rst_treatment_cd'', @rstTreatmentName:''rst_treatment_name'', @rstKurCd:''rst_kur_cd'', @rstKurName:''rst_kur_name'', @rstBedCd:''rst_bed_cd'', @rstBedName:''rst_bed_name'', @rstMachineNo:''rst_machine_no'', @rstMachineName:''rst_machine_name'', @rstCondSendDate_Date:''rst_cond_send_date'', @rstAcceptDate_Date:''rst_accept_date'', @rstStartDate_Date:''rst_start_date'', @rstEndDate_Date:''rst_end_date'', @rstReturnHomeDate_Date:''rst_return_home_date'', @rstInOutClass:''rst_in_out_class'', @rstDialysisCnt:''rst_dialysis_cnt'', @rstWardCd:''rst_ward_cd'', @rstWardName:''rst_ward_name'', @rstCourseCd:''rst_course_cd'', @rstCourseName:''rst_course_name'', @rstPunctureUserInfo:''rst_puncture_user_info'', @rstReturnUserInfo:''rst_return_user_info'', @rstChargeUserInfo:''rst_charge_user_info'', @rstBloodCirculateTotal:''rst_blood_circulate_total'', @rstRunningTime:''rst_running_time'', @rstKtV:''rst_kt_v'', @recSetDate_Date:''rec_set_date'', @sendCtlNo:''send_ctl_no'', @bloodPurifierName:''blood_purifier_name'', @pullLeaveAmount:''pull_leave_amount'', @rstCondInfo:''rst_cond_info'', @rstMediInfo:''rst_medi_info'', @rstEquipInfo:''rst_equip_info'', @rstIndCommentInfo:''rst_ind_comment_info'', @rstTareInfo:''rst_tare_info'', @rstOffWaterInfo:''rst_off_water_info'', @rstDeviceSetInfo:''rst_device_set_info'', @rstWeightInfo:''rst_weight_info'', @rstVitalInfo:''rst_vital_info'', @rstComplaintInfo:''rst_complaint_info'', @rstTreatmentInfo:''rst_treatment_info'', @rstTreatStaffInfo:''rst_treat_staff_info'', @rstRoundsInfo:''rst_rounds_info'', @isDel:''is_del'', @upDate_Date:''up_date'', @regDate_Date:''reg_date'', @rstDw:''rst_dw'', @weightScaleNo:''weight_scale_no'', @treatType:''treat_type'', @isConfirm:''is_confirm'', @indDw:''ind_dw'', @rstPurificationCnt:''rst_purification_cnt'', @additionInfo:''addition_info'', @upIndUserId:''up_ind_user_id'', @upUserId:''up_user_id'', @rstEditionDate_Date:''rst_edition_date'', @curEditionDate_Date:''cur_edition_date'', @fnPlural:''fn_plural''}"}, {"No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": 9115, "@indBedCd": "0", "@indKurCd": "0", "@upUserId": "-1", "@treatDate": "$journal.pat_coop_detail.save_1.key_06", "@indTreatmentCd": "$journal.ord_main.ind_treatment_cd", "@indTreatmentName": "$journal.ord_main.ind_treatment_name"}, {"No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "3", "sqlCode": 9116, "@indBedCd": "0", "@indKurCd": "0", "@upUserId": "-1", "@treatDate": "$journal.pat_coop_detail.save_1.key_06", "@indTreatmentCd": "$journal.ord_main.ind_treatment_cd", "@indTreatmentName": "$journal.ord_main.ind_treatment_name"}], "sqlGroup10": [{"No1": "指示情報→登録・更新", "No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": 9114, "@treatDate": "$journal.pat_coop_detail.save_1.key_06", "updateResult": "{@ordNo:''ord_no''}"}, {"No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "2", "sqlCode": 9117, "@treatDate": "$journal.pat_coop_detail.save_1.key_06", "@indCondInfo.27.unit": "$journal.ord_main.ind_cond_info.27.unit", "@indCondInfo.28.unit": "$journal.ord_main.ind_cond_info.28.unit", "@indCondInfo.9.value": "$journal.ord_main.ind_cond_info.9.value", "@indCondInfo.25.value": "$journal.ord_main.ind_cond_info.25.value", "@indCondInfo.27.value": "$journal.ord_main.ind_cond_info.27.value", "@indCondInfo.28.value": "$journal.ord_main.ind_cond_info.28.value", "@indCondInfo.27.unitName": "$journal.ord_main.ind_cond_info.27.unit_name", "@indCondInfo.28.unitName": "$journal.ord_main.ind_cond_info.28.unit_name", "@indCondInfo.9.valueName1": "$journal.ord_main.ind_cond_info.9.value_name_1", "@indCondInfo.25.valueName1": "$journal.ord_main.ind_cond_info.25.valueName1"}], "sqlGroup11": [{"No1": "指示情報→登録・更新", "No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "ord_main", "ctl_no": "1", "sqlCode": 9114, "@treatDate": "$journal.pat_coop_detail.save_1.key_06", "updateResult": "{@additionInfoFlg:'''', @additionInfoValue:''addition_info'', @additionInfo.cd:'''', @additionInfo.name:'''', @additionInfo.kind:''''}"}, {"No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "ord_main_1", "ctl_no": "2", "sqlCode": 9118}, {"No2": "初回指示連携Ver1、かつ、処理区分<>[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#<>#D", "table": "ord_main_1", "ctl_no": "3", "sqlCode": 9119, "@treatDate": "$journal.pat_coop_detail.save_1.key_06", "@additionInfo.cd": "$journal.detail.ord_main_1.addition_info.cd", "@additionInfo.kind": "2", "@additionInfo.name": "$journal.detail.ord_main_1.addition_info.name"}], "sqlGroup12": [{"No1": "患者情報→削除→更新", "No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_personal_main", "@isDie": "0", "ctl_no": "2", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": 1103, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "1", "@severityCd": "$journal.pat_personal_main.severity_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@transportCd": "$journal.pat_personal_main.transport_cd", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}], "sqlGroup13": [{"No1": "患者情報→削除→更新", "No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "No3": "NEC場合、病棟コードより、[入外区分]を更新する。病棟コードが空白の場合は「入外区分 = 外来」で登録、空白でない場合は「入外区分 = 入院」で登録します。", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "No3": "NEC場合、[入外区分]の更新処理、pat_personal_mainを更新する。または、pat_mainから、データを取得する。tableにpat_mainを設定しました。", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_main", "ctl_no": "2", "sqlCode": 9101, "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd"}], "sqlGroup14": [{"No1": "患者情報→削除→更新", "No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "No3": "NEC場合、[死亡患者、連絡先情報、透析困難情報]を更新する。", "No4": "死亡退院日が空白の場合は「死亡患者 = 対象外」で登録、空白でない場合は「死亡患者 = 対象」で登録します。", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_personal_main", "ctl_no": "2", "sqlCode": 9102}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_personal_main", "ctl_no": "3", "sqlCode": 9103, "@dieDate_Date": "$journal.pat_personal_main.die_date", "@otherContactInfo.tel1": "$journal.pat_personal_main.other_contact_info.tel1", "@dialDiffComInfo.isMain": "1", "@otherContactInfo.zipCd": "$journal.pat_personal_main.other_contact_info.zip_cd", "@otherContactInfo.address": "$journal.pat_personal_main.other_contact_info.address", "@otherContactInfo.patName": "$journal.pat_personal_main.pat_name", "@dialDiffComInfo.dialDiffCd": "$journal.pat_personal_main.dial_diff_com_info.dial_diff_cd", "@dialDiffComInfo.isDialDiff": "1", "@otherContactInfo.relationCd": "6", "@otherContactInfo.patNameKana": "$journal.pat_personal_main.pat_name_kana"}], "sqlGroup15": [{"No1": "患者情報→削除→更新", "No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201, "insertResult": "{@patId:'''',@facilityCd:'''',@isSame:'''',@isImplant:'''',@isInfect:'''',@isDiabetes:'''',@isBloodSugerExam:'''',@inOutCurrentState:'''',@inOutPlanState:'''',@inOutPlanDate_Date:'''',@patMemoInfoValue:''[]'',@additionInfoValue:''[]'',@chargeStaffInfoValue:''[]'',@patGroupInfoValue:''[]'',@tabooAllergyInfoValue:''[]'',@infectInfoValue:''[]'',@implantInfoValue:''[]'',@tareInfoValue:''{}'',@offWaterInfoValue:''{}'',@deviceSetInfoValue:''{}'',@acceptanceStatusInfoValue:''[]'',@isWheelChair:'''',@medicalCareInfoFlg:'''',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:'''',@schExtStatus:'''',@cardIdm:'''',@oldUpDate_Date:''''}", "updateResult": "{@patId:''pat_id'',@facilityCd:''facility_cd'',@isSame:''is_same'',@isImplant:''is_implant'',@isInfect:''is_infect'',@isDiabetes:''is_diabetes'',@isBloodSugerExam:''is_blood_suger_exam'',@inOutCurrentState:''in_out_current_state'',@inOutPlanState:''in_out_plan_state'',@inOutPlanDate_Date:''in_out_plan_date'',@patMemoInfoValue:''pat_memo_info'',@additionInfoValue:''addition_info'',@chargeStaffInfoValue:''charge_staff_info'',@patGroupInfoValue:''pat_group_info'',@tabooAllergyInfoValue:''taboo_allergy_info'',@infectInfoValue:''infect_info'',@implantInfoValue:''implant_info'',@tareInfoValue:''tare_info'',@offWaterInfoValue:''off_water_info'',@deviceSetInfoValue:''device_set_info'',@acceptanceStatusInfoValue:''acceptance_status_info'',@isWheelChair:''is_wheel_chair'',@medicalCareInfoFlg:'''',@medicalCareInfoValue:''medical_care_info'',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:''sch_ext_end_date'',@schExtStatus:''sch_ext_status'',@cardIdm:''card_idm'',@oldUpDate_Date:''old_up_date''}"}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_main", "ctl_no": "2", "sqlCode": 1202, "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_main", "ctl_no": "3", "sqlCode": 1203, "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}], "sqlGroup16": [{"No1": "患者情報→削除→更新", "No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_main", "ctl_no": "2", "sqlCode": 9104}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_main", "ctl_no": "3", "sqlCode": 9105, "@infectInfo": "$journal.pat_main.infect_info", "@tabooAllergyInfo": "$journal.pat_main.taboo_allergy_info", "@chargeStaffInfo.staffCd": "$journal.pat_main.charge_staff_info.staff_cd"}], "sqlGroup17": [{"No1": "患者情報→削除→更新", "No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_unique", "ctl_no": "1", "sqlCode": 1601, "insertResult": "{@patId:'''', @facilityCd:'''', @medicalHstInfoValue:''[]'', @inOutVisitHistoryInfoValue:''[]'', @physicalInfoFlg:'''', @physicalInfoValue:''[]''}"}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_unique", "ctl_no": "2", "sqlCode": 9106, "@physicalInfo.dw": "$journal.pat_unique.physical_info.dw", "@physicalInfo.height": "$journal.pat_unique.physical_info.height", "@physicalInfo.ctrWeight": "$journal.pat_unique.physical_info.ctr_weight", "@physicalInfo.orderClass": "1"}, {"No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "pat_unique", "ctl_no": "3", "sqlCode": 9107, "@physicalInfo.dw": "$journal.pat_unique.physical_info.dw", "@physicalInfo.height": "$journal.pat_unique.physical_info.height", "@physicalInfo.ctrWeight": "$journal.pat_unique.physical_info.ctr_weight", "@physicalInfo.orderClass": "1"}], "sqlGroup18": [{"No1": "指示情報→削除→ord_main_restoreに移動する", "No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "ord_main", "ctl_no": "1", "sqlCode": 9120}], "sqlGroup19": [{"No1": "指示情報→削除→ord_mainに削除する", "No2": "初回指示連携Ver1、かつ、処理区分=[D:削除]", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#=#C-DIRECTVer1,$journal.const.crud#=#D", "table": "ord_main", "ctl_no": "1", "sqlCode": 9121}], "sqlGroup20": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"No2": "患者死亡退院情報連携", "No3": "患者の状態を『死亡』として、患者情報を登録します。", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "@isDie": "1", "ctl_no": "2", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": 1102, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "2", "@severityCd": "$journal.pat_personal_main.severity_cd", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@transportCd": "$journal.pat_personal_main.transport_cd", "@dieDate_Date": "$journal.pat_personal_main.die_date", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeRh": "$journal.pat_personal_main.pat_blood_type_rh", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patBloodTypeAbo": "$journal.pat_personal_main.pat_blood_type_abo", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}, {"No2": "患者死亡退院情報連携", "No3": "患者の状態を『存命』から『死亡』に変更します。", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "@isDie": "1", "ctl_no": "3", "sqlCode": 1103, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "2"}], "sqlGroup21": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "No3": "NEC場合、[死亡患者、連絡先情報、透析困難情報]を更新する。", "No4": "死亡退院日が空白の場合は「死亡患者 = 対象外」で登録、空白でない場合は「死亡患者 = 対象」で登録します。", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}, {"No2": "患者死亡退院情報連携", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "2", "sqlCode": 9102}, {"No2": "患者死亡退院情報連携", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_personal_main", "ctl_no": "3", "sqlCode": 9103, "@dieDate_Date": "$journal.pat_personal_main.die_date", "@otherContactInfo.tel1": "$journal.pat_personal_main.other_contact_info.tel1", "@dialDiffComInfo.isMain": "1", "@otherContactInfo.zipCd": "$journal.pat_personal_main.other_contact_info.zip_cd", "@otherContactInfo.address": "$journal.pat_personal_main.other_contact_info.address", "@otherContactInfo.patName": "$journal.pat_personal_main.pat_name", "@dialDiffComInfo.dialDiffCd": "$journal.pat_personal_main.dial_diff_com_info.dial_diff_cd", "@dialDiffComInfo.isDialDiff": "1", "@otherContactInfo.relationCd": "6", "@otherContactInfo.patNameKana": "$journal.pat_personal_main.pat_name_kana"}], "sqlGroup22": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201, "insertResult": "{@patId:'''',@facilityCd:'''',@isSame:'''',@isImplant:'''',@isInfect:'''',@isDiabetes:'''',@isBloodSugerExam:'''',@inOutCurrentState:'''',@inOutPlanState:'''',@inOutPlanDate_Date:'''',@patMemoInfoValue:''[]'',@additionInfoValue:''[]'',@chargeStaffInfoValue:''[]'',@patGroupInfoValue:''[]'',@tabooAllergyInfoValue:''[]'',@infectInfoValue:''[]'',@implantInfoValue:''[]'',@tareInfoValue:''{}'',@offWaterInfoValue:''{}'',@deviceSetInfoValue:''{}'',@acceptanceStatusInfoValue:''[]'',@isWheelChair:'''',@medicalCareInfoFlg:'''',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:'''',@schExtStatus:'''',@cardIdm:'''',@oldUpDate_Date:''''}", "updateResult": "{@patId:''pat_id'',@facilityCd:''facility_cd'',@isSame:''is_same'',@isImplant:''is_implant'',@isInfect:''is_infect'',@isDiabetes:''is_diabetes'',@isBloodSugerExam:''is_blood_suger_exam'',@inOutCurrentState:''in_out_current_state'',@inOutPlanState:''in_out_plan_state'',@inOutPlanDate_Date:''in_out_plan_date'',@patMemoInfoValue:''pat_memo_info'',@additionInfoValue:''addition_info'',@chargeStaffInfoValue:''charge_staff_info'',@patGroupInfoValue:''pat_group_info'',@tabooAllergyInfoValue:''taboo_allergy_info'',@infectInfoValue:''infect_info'',@implantInfoValue:''implant_info'',@tareInfoValue:''tare_info'',@offWaterInfoValue:''off_water_info'',@deviceSetInfoValue:''device_set_info'',@acceptanceStatusInfoValue:''acceptance_status_info'',@isWheelChair:''is_wheel_chair'',@medicalCareInfoFlg:'''',@medicalCareInfoValue:''medical_care_info'',@medicalCareInfo.mainCourseCd:'''',@medicalCareInfo.dialysisCourseCd:'''',@medicalCareInfo.wardCd:'''',@medicalCareInfo.dialysisCount:'''',@medicalCareInfo.purificationCount:'''',@medicalCareInfo.otherDialysisCount:'''',@medicalCareInfo.facilityCd:'''',@medicalCareInfo.dialysisStartDate:'''',@medicalCareInfo.hospitalStartDate:'''',@schExtEndDate:''sch_ext_end_date'',@schExtStatus:''sch_ext_status'',@cardIdm:''card_idm'',@oldUpDate_Date:''old_up_date''}"}, {"No2": "患者死亡退院情報連携", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "2", "sqlCode": 1202, "@medicalCareInfo.wardCd": "$journal.pat_main.medical_care_info.ward_cd", "@medicalCareInfo.mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd", "@medicalCareInfo.dialysisStartDate": "$journal.pat_main.medical_care_info.dialysis_start_date"}], "sqlGroup23": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201}, {"No2": "患者死亡退院情報連携", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "2", "sqlCode": 9104}, {"No2": "患者死亡退院情報連携", "crud": "U", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_main", "ctl_no": "3", "sqlCode": 9105, "@infectInfo": "$journal.pat_main.infect_info", "@tabooAllergyInfo": "$journal.pat_main.taboo_allergy_info", "@chargeStaffInfo.staffCd": "$journal.pat_main.charge_staff_info.staff_cd"}], "sqlGroup24": [{"No1": "患者情報→登録・更新", "No2": "患者死亡退院情報連携", "crud": "S", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_unique", "ctl_no": "1", "sqlCode": 1601, "insertResult": "{@patId:'''', @facilityCd:'''', @medicalHstInfoValue:''[]'', @inOutVisitHistoryInfoValue:''[]'', @physicalInfoFlg:'''', @physicalInfoValue:''[]''}"}, {"No2": "患者死亡退院情報連携", "crud": "C", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "pat_unique", "ctl_no": "2", "sqlCode": 9106, "@physicalInfo.dw": "$journal.pat_unique.physical_info.dw", "@physicalInfo.height": "$journal.pat_unique.physical_info.height", "@physicalInfo.ctrWeight": "$journal.pat_unique.physical_info.ctr_weight", "@physicalInfo.orderClass": "1"}], "sqlGroup25": [{"No1": "指示情報→削除→ord_main_restoreに移動する", "No2": "患者死亡退院情報連携", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "ord_main", "ctl_no": "1", "sqlCode": 9120}], "sqlGroup26": [{"No1": "指示情報→削除→ord_mainに削除する", "No2": "患者死亡退院情報連携", "crud": "D", "kind": "1", "judge": "$journal.const.command_name#=#C-KNJDEL", "table": "ord_main", "ctl_no": "1", "sqlCode": 9121}]}, "CoopIniConvUtil": {"$journal.pat_personal_main.pat_sex": "CONV_SEX_TO_FNW", "$journal.pat_personal_main.pat_blood_type_rh": "CONV_BLOOD_RH_TO_FNW", "$journal.pat_personal_main.pat_blood_type_abo": "CONV_BLOOD_ABO_TO_FNW"}}', '1', '0', -1, '2019-12-13 05:44:54', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010002, 'N_hosp', 'ini_dial', '', 'R', '初回指示情報', 'text     ', 'NEC想定透析初回指示', 'MEGA', '初回指示情報ver1', '1', '<root name="透析申込(初回指示情報ver1)">
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
  <item name="患者区分" len="2" col="$journal.pat_personal_main.transport_cd" type="string"/>
  <item name="救護区分" len="2" col="$journal.pat_personal_main.severity_cd" type="string"/>
  <item name="予備区分" len="1" type="string" info="対象外"/>
  <item name="障害情報" len="15" type="string" info="対象外"/>
  <item name="身長" len="5" col="$journal.pat_unique.physical_info.height" type="string" info="対象外"/>
  <item name="体重" len="5" col="$journal.pat_unique.physical_info.ctr_weight" type="string" info="対象外"/>
  <item name="血液型ＡＢＯ" len="1" col="$journal.pat_personal_main.pat_blood_type_abo" type="string"/>
  <item name="血液型Ｒｈ" len="1" col="$journal.pat_personal_main.pat_blood_type_rh" type="string"/>
  <item name="感染情報" len="20" col="$journal.pat_main.infect_info" type="string" info="20バイトのフラグ"/>
  <item name="感染コメント" len="60" type="string" info="対象外"/>
  <item name="薬剤禁忌情報" len="20" col="$journal.pat_main.taboo_allergy_info" type="string" info="20バイトのフラグ"/>
  <item name="禁忌コメント" len="60" type="string"/>
  <item name="妊娠日" len="8" type="string" info="対象外"/>
  <item name="死亡退院日" len="8" col="$journal.pat_personal_main.die_date" type="string"/>
  <item name="予備" len="30" type="string" info="対象外"/>
  <item name="オーダ番号" len="16" col="$journal.pat_coop_detail.save_1.key_01" type="string"/>
  <item name="情報区分" len="1" type="string"/>
  <item name="指示科" len="2" col="$journal.pat_main.medical_care_info.main_course_cd" type="string"/>
  <item name="指示科名称" len="20" type="string" info="対象外"/>
  <item name="指示医" len="10" col="$journal.pat_main.charge_staff_info.staff_cd" type="string"/>
  <item name="指示医名称" len="20" type="string"/>
  <item name="指示医世代番号" len="1" col="$journal.pat_coop_detail.save_1.key_02" type="string"/>
  <item name="保険コード01" len="3" col="$journal.detail.pat_insurance_1.coop_code" type="string"/>
  <item name="保険コード02" len="3" col="$journal.detail.pat_insurance_1.coop_code" type="string"/>
  <item name="保険コード03" len="3" col="$journal.detail.pat_insurance_1.coop_code" type="string"/>
  <item name="保険コード04" len="3" col="$journal.detail.pat_insurance_1.coop_code" type="string" info="対象外"/>
  <item name="保険コード05" len="3" col="$journal.detail.pat_insurance_1.coop_code" type="string" info="対象外"/>
  <item name="透析種別" len="1" col="$journal.pat_coop_detail.save_1.key_03" type="string" info="対象外"/>
  <item name="透析コース" len="6" col="$journal.pat_coop_detail.save_1.key_04" type="string" info="対象外"/>
  <item name="透析コース名称" len="60" type="string" info="対象外"/>
  <item name="透析パターン" len="6" col="$journal.pat_coop_detail.save_1.key_05" type="string"/>
  <item name="透析パターン名称" len="60" type="string" info="対象外"/>
  <item name="開始日（定期）" len="8" col="$journal.pat_coop_detail.save_1.key_06" type="string"/>
  <item name="終了日（定期）" len="8" col="$journal.pat_coop_detail.save_1.key_07" type="string"/>
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
  <item name="実施場所" len="6" col="$journal.pat_coop_detail.save_1.key_08" type="string"/>
  <item name="実施場所名称" len="60" type="string" info="対象外"/>
  <item name="加算（患者に付随する加算）" len="6" col="$journal.pat_personal_main.dial_diff_com_info.dial_diff_cd" type="string"/>
  <item name="加算世代番号" len="1" type="string"/>
  <item name="加算名称" len="60" type="string" info="対象外"/>
  <item name="ベッド予約番号" len="13" type="string" info="対象外"/>
  <item name="使用ベッド" len="6" type="string" info="対象外"/>
  <item name="使用ベッド名称" len="60" type="string" info="対象外"/>
  <item name="ベッド予約時間帯" len="1" type="string" info="対象外"/>
  <item name="ブラッドアクセス" len="6" type="string"/>
  <item name="ブラッドアクセス名称" len="60" type="string"/>
  <item name="部位" len="6" type="string"/>
  <item name="部位名称" len="60" type="string" info="対象外"/>
  <item name="ＤＷ" len="4" col="$journal.pat_unique.physical_info.dw" type="string"/>
  <item name="血液浄化法" len="6" type="string"/>
  <item name="血液浄化法世代番号" len="1" type="string"/>
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
  <item name="更新端末" len="10" col="$journal.pat_coop_detail.save_1.key_09" type="string"/>
  <item name="更新者" len="10" type="string"/>
  <item name="更新者世代番号" len="1" type="string"/>
  <item name="予備" len="30" type="string" info="対象外"/>
  <occ name="オーダ指示詳細数" len="5" type="string" detail="透析指示オーダ明細"/>
  <occ name="オーダ指示コメント数" len="5" type="string" detail="透析コメント明細"/>
</root>', '{"json-key": {"{\"A\":\"C\",\"D\":\"D\",\"U\":\"U\",\"Z\":\"Z\"}": {"A": "C", "D": "D", "U": "U", "Z": "Z"}}}', '1', '0', -1, '2019-12-13 05:44:54', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010003, 'N_hosp', 'ini_dial', '', 'R', '初回指示情報', 'text     ', 'NEC想定透析初回指示', 'MEGA', '初回指示情報ver2', '1', '<root name="透析申込(初回指示情報ver2)">
  <item name="空白" len="20" type="string"/>
  <item name="電文長" len="12" type="string"/>
  <item name="コマンド名" len="8" type="string" col="$journal.const.command_name" value="const:C-DIRECTVer2"/>
  <item name="処理区分" len="1" col="$journal.const.crud" type="string" value="json:{&quot;&quot;:&quot;C&quot;,&quot;E&quot;:&quot;C&quot;}"/>
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
  <item name="患者区分" len="2" col="$journal.pat_personal_main.transport_cd" type="string"/>
  <item name="救護区分" len="2" col="$journal.pat_personal_main.severity_cd" type="string"/>
  <item name="予備区分" len="1" type="string" info="対象外"/>
  <item name="障害情報" len="15" type="string" info="対象外"/>
  <item name="身長" len="5" col="$journal.pat_unique.physical_info.height" type="string" info="対象外"/>
  <item name="体重" len="5" col="$journal.pat_unique.physical_info.ctr_weight" type="string" info="対象外"/>
  <item name="血液型ＡＢＯ" len="1" col="$journal.pat_personal_main.pat_blood_type_abo" type="string"/>
  <item name="血液型Ｒｈ" len="1" col="$journal.pat_personal_main.pat_blood_type_rh" type="string"/>
  <item name="感染情報" len="20" col="$journal.pat_main.infect_info" type="string" info="20バイトのフラグ"/>
  <item name="感染コメント" len="60" type="string" info="対象外"/>
  <item name="薬剤禁忌情報" len="20" col="$journal.pat_main.taboo_allergy_info" type="string" info="20バイトのフラグ"/>
  <item name="禁忌コメント" len="60" type="string"/>
  <item name="妊娠日" len="8" type="string" info="対象外"/>
  <item name="死亡退院日" len="8" col="$journal.pat_personal_main.die_date" type="string"/>
  <item name="予備" len="30" type="string" info="対象外"/>
  <item name="オーダ番号" len="16" type="string"/>
  <item name="情報区分" len="1" type="string"/>
  <item name="指示科" len="2" type="string"/>
  <item name="指示科名称" len="20" type="string" info="対象外"/>
  <item name="指示医" len="10" type="string"/>
  <item name="指示医名称" len="20" type="string"/>
  <item name="指示医世代番号" len="1" type="string"/>
  <item name="保険コード01" len="3" type="string"/>
  <item name="保険コード02" len="3" type="string"/>
  <item name="保険コード03" len="3" type="string"/>
  <item name="保険コード04" len="3" type="string" info="対象外"/>
  <item name="保険コード05" len="3" type="string" info="対象外"/>
  <item name="透析種別" len="1" type="string" info="対象外"/>
  <item name="透析コース" len="6" type="string" info="対象外"/>
  <item name="透析コース名称" len="60" type="string" info="対象外"/>
  <item name="透析パターン" len="6" type="string"/>
  <item name="透析パターン名称" len="60" type="string" info="対象外"/>
  <item name="開始日（定期）" len="8" type="string"/>
  <item name="終了日（定期）" len="8" type="string"/>
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
  <item name="透析導入日" len="8" type="string"/>
  <item name="実施場所" len="6" type="string"/>
  <item name="実施場所名称" len="60" type="string" info="対象外"/>
  <item name="加算（患者に付随する加算）" len="6" col="$journal.pat_personal_main.dial_diff_com_info.dial_diff_cd" value="const:" type="string" info="データを取得しません。SQL[9103]の必須項目、空設定。"/>
  <item name="加算世代番号" len="1" type="string"/>
  <item name="加算名称" len="60" type="string" info="対象外"/>
  <item name="ベッド予約番号" len="13" type="string" info="対象外"/>
  <item name="使用ベッド" len="6" type="string" info="対象外"/>
  <item name="使用ベッド名称" len="60" type="string" info="対象外"/>
  <item name="ベッド予約時間帯" len="1" type="string" info="対象外"/>
  <item name="ブラッドアクセス" len="6" type="string"/>
  <item name="ブラッドアクセス名称" len="60" type="string"/>
  <item name="部位" len="6" type="string"/>
  <item name="部位名称" len="60" type="string" info="対象外"/>
  <item name="ＤＷ" len="4" type="string"/>
  <item name="血液浄化法" len="6" type="string"/>
  <item name="血液浄化法世代番号" len="1" type="string"/>
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
  <item name="更新端末" len="10" type="string"/>
  <item name="更新者" len="10" type="string"/>
  <item name="更新者世代番号" len="1" type="string"/>
  <item name="予備" len="30" type="string" info="対象外"/>
  <occ name="オーダ指示詳細数" len="5" type="string" detail="透析指示オーダ明細_空白"/>
  <occ name="オーダ指示コメント数" len="5" type="string" detail="透析コメント明細_空白"/>
</root>', '{"json-key": {"{\"\":\"C\",\"E\":\"C\"}": {"": "C", "E": "C"}}}', '1', '1', -1, '2019-12-13 05:44:54', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010004, 'N_hosp', 'ini_dial', '', 'R', '患者情報', 'text     ', 'NEC想定透析初回指示', 'MEGA', 'テスト用', '1', '<root name="透析申込(患者情報)">
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
  <item name="患者区分" len="2" col="$journal.pat_personal_main.transport_cd" type="string"/>
  <item name="救護区分" len="2" col="$journal.pat_personal_main.severity_cd" type="string"/>
  <item name="予備区分" len="1" type="string" info="対象外"/>
  <item name="障害情報" len="15" type="string" info="対象外"/>
  <item name="身長" len="5" col="$journal.pat_unique.physical_info.height" type="string" info="対象外"/>
  <item name="体重" len="5" col="$journal.pat_unique.physical_info.ctr_weight" type="string" info="対象外"/>
  <item name="血液型ＡＢＯ" len="1" col="$journal.pat_personal_main.pat_blood_type_abo" type="string"/>
  <item name="血液型Ｒｈ" len="1" col="$journal.pat_personal_main.pat_blood_type_rh" type="string"/>
  <item name="感染情報" len="20" col="$journal.pat_main.infect_info" type="string" info="20バイトのフラグ"/>
  <item name="感染コメント" len="60" type="string" info="対象外"/>
  <item name="薬剤禁忌情報" len="20" col="$journal.pat_main.taboo_allergy_info" type="string" info="20バイトのフラグ"/>
  <item name="禁忌コメント" len="60" type="string"/>
  <item name="妊娠日" len="8" type="string" info="対象外"/>
  <item name="死亡退院日" len="8" col="$journal.pat_personal_main.die_date" type="string"/>
  <item name="予備" len="30" type="string" info="対象外"/>
  <item name="オーダ番号" len="16" type="string"/>
  <item name="情報区分" len="1" type="string"/>
  <item name="指示科" len="2" type="string"/>
  <item name="指示科名称" len="20" type="string" info="対象外"/>
  <item name="指示医" len="10" type="string"/>
  <item name="指示医名称" len="20" type="string"/>
  <item name="指示医世代番号" len="1" type="string"/>
  <item name="保険コード01" len="3" type="string"/>
  <item name="保険コード02" len="3" type="string"/>
  <item name="保険コード03" len="3" type="string"/>
  <item name="保険コード04" len="3" type="string" info="対象外"/>
  <item name="保険コード05" len="3" type="string" info="対象外"/>
  <item name="透析種別" len="1" type="string" info="対象外"/>
  <item name="透析コース" len="6" type="string" info="対象外"/>
  <item name="透析コース名称" len="60" type="string" info="対象外"/>
  <item name="透析パターン" len="6" type="string"/>
  <item name="透析パターン名称" len="60" type="string" info="対象外"/>
  <item name="開始日（定期）" len="8" type="string"/>
  <item name="終了日（定期）" len="8" type="string"/>
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
  <item name="透析導入日" len="8" type="string"/>
  <item name="実施場所" len="6" type="string"/>
  <item name="実施場所名称" len="60" type="string" info="対象外"/>
  <item name="加算（患者に付随する加算）" len="6" col="$journal.pat_personal_main.dial_diff_com_info.dial_diff_cd" value="const:" type="string" info="データを取得しません。SQL[9103]の必須項目、空設定。"/>
  <item name="加算世代番号" len="1" type="string"/>
  <item name="加算名称" len="60" type="string" info="対象外"/>
  <item name="ベッド予約番号" len="13" type="string" info="対象外"/>
  <item name="使用ベッド" len="6" type="string" info="対象外"/>
  <item name="使用ベッド名称" len="60" type="string" info="対象外"/>
  <item name="ベッド予約時間帯" len="1" type="string" info="対象外"/>
  <item name="ブラッドアクセス" len="6" type="string"/>
  <item name="ブラッドアクセス名称" len="60" type="string"/>
  <item name="部位" len="6" type="string"/>
  <item name="部位名称" len="60" type="string" info="対象外"/>
  <item name="ＤＷ" len="4" type="string"/>
  <item name="血液浄化法" len="6" type="string"/>
  <item name="血液浄化法世代番号" len="1" type="string"/>
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
  <item name="更新端末" len="10" type="string"/>
  <item name="更新者" len="10" type="string"/>
  <item name="更新者世代番号" len="1" type="string"/>
  <item name="予備" len="30" type="string" info="対象外"/>
  <occ name="オーダ指示詳細数" len="5" type="string" detail="透析指示オーダ明細_空白"/>
  <occ name="オーダ指示コメント数" len="5" type="string" detail="透析コメント明細_空白"/>
</root>', '{}', '1', '0', -1, '2019-12-13 05:44:54', '2021-11-23 12:12:12');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3010005, 'N_hosp', 'ini_dial', '', 'R', '患者死亡退院情報', 'text     ', 'NEC想定透析初回指示', 'MEGA', 'テスト用', '1', '<root name="透析申込(患者死亡退院情報)">
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
  <item name="患者区分" len="2" col="$journal.pat_personal_main.transport_cd" type="string"/>
  <item name="救護区分" len="2" col="$journal.pat_personal_main.severity_cd" type="string"/>
  <item name="予備区分" len="1" type="string" info="対象外"/>
  <item name="障害情報" len="15" type="string" info="対象外"/>
  <item name="身長" len="5" col="$journal.pat_unique.physical_info.height" type="string" info="対象外"/>
  <item name="体重" len="5" col="$journal.pat_unique.physical_info.ctr_weight" type="string" info="対象外"/>
  <item name="血液型ＡＢＯ" len="1" col="$journal.pat_personal_main.pat_blood_type_abo" type="string"/>
  <item name="血液型Ｒｈ" len="1" col="$journal.pat_personal_main.pat_blood_type_rh" type="string"/>
  <item name="感染情報" len="20" col="$journal.pat_main.infect_info" type="string" info="20バイトのフラグ"/>
  <item name="感染コメント" len="60" type="string" info="対象外"/>
  <item name="薬剤禁忌情報" len="20" col="$journal.pat_main.taboo_allergy_info" type="string" info="20バイトのフラグ"/>
  <item name="禁忌コメント" len="60" type="string"/>
  <item name="妊娠日" len="8" type="string" info="対象外"/>
  <item name="死亡退院日" len="8" col="$journal.pat_personal_main.die_date" type="string"/>
  <item name="予備" len="30" type="string" info="対象外"/>
  <item name="オーダ番号" len="16" type="string"/>
  <item name="情報区分" len="1" type="string"/>
  <item name="指示科" len="2" type="string"/>
  <item name="指示科名称" len="20" type="string" info="対象外"/>
  <item name="指示医" len="10" type="string"/>
  <item name="指示医名称" len="20" type="string"/>
  <item name="指示医世代番号" len="1" type="string"/>
  <item name="保険コード01" len="3" type="string"/>
  <item name="保険コード02" len="3" type="string"/>
  <item name="保険コード03" len="3" type="string"/>
  <item name="保険コード04" len="3" type="string" info="対象外"/>
  <item name="保険コード05" len="3" type="string" info="対象外"/>
  <item name="透析種別" len="1" type="string" info="対象外"/>
  <item name="透析コース" len="6" type="string" info="対象外"/>
  <item name="透析コース名称" len="60" type="string" info="対象外"/>
  <item name="透析パターン" len="6" type="string"/>
  <item name="透析パターン名称" len="60" type="string" info="対象外"/>
  <item name="開始日（定期）" len="8" type="string"/>
  <item name="終了日（定期）" len="8" type="string"/>
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
  <item name="透析導入日" len="8" type="string"/>
  <item name="実施場所" len="6" type="string"/>
  <item name="実施場所名称" len="60" type="string" info="対象外"/>
  <item name="加算（患者に付随する加算）" len="6" col="$journal.pat_personal_main.dial_diff_com_info.dial_diff_cd" value="const:" type="string" info="データを取得しません。SQL[9103]の必須項目、空設定。"/>
  <item name="加算世代番号" len="1" type="string"/>
  <item name="加算名称" len="60" type="string" info="対象外"/>
  <item name="ベッド予約番号" len="13" type="string" info="対象外"/>
  <item name="使用ベッド" len="6" type="string" info="対象外"/>
  <item name="使用ベッド名称" len="60" type="string" info="対象外"/>
  <item name="ベッド予約時間帯" len="1" type="string" info="対象外"/>
  <item name="ブラッドアクセス" len="6" type="string"/>
  <item name="ブラッドアクセス名称" len="60" type="string"/>
  <item name="部位" len="6" type="string"/>
  <item name="部位名称" len="60" type="string" info="対象外"/>
  <item name="ＤＷ" len="4" type="string"/>
  <item name="血液浄化法" len="6" type="string"/>
  <item name="血液浄化法世代番号" len="1" type="string"/>
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
  <item name="更新端末" len="10" type="string"/>
  <item name="更新者" len="10" type="string"/>
  <item name="更新者世代番号" len="1" type="string"/>
  <item name="予備" len="30" type="string" info="対象外"/>
  <occ name="オーダ指示詳細数" len="5" type="string" detail="透析指示オーダ明細_空白"/>
  <occ name="オーダ指示コメント数" len="5" type="string" detail="透析コメント明細_空白"/>
</root>', '{}', '1', '0', -1, '2019-12-13 05:44:54', '2021-11-23 12:12:12');
