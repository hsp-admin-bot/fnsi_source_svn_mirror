DELETE FROM mst_coop_layout
WHERE ctl_no IN (-3030001, -3040001,-3040002,-3040003,-3040004,-3040005,-3040006,-3040007,-3040008,-3040009,-3040010,-3040011,-3040012);

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
</root>', '{"csv": {"delim": {"item": ","}}, "key": {"shori_kbn": {"_DEFAULT": "対象", "9900000081": "対象外", "9999999901": "対象外", "9999999999": "対象外"}}, "dataset": {"sqlGroup1": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600500, "@userPassword": "$journal.mst_personal_user.user_password", "ExceptionMessage": "スタッフマスタCSVの設定に誤りがあります。パスワードが設定されていません。", "ExceptionCondition": "=1"}], "sqlGroup2": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600501, "@userName": "$journal.mst_personal_user.user_name", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。漢字氏名が設定されていません。", "ExceptionCondition": "=1"}], "sqlGroup3": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600502, "@inHospitalCd": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。職員コードに編集対象外のIDが設定されています。", "ExceptionCondition": "=1"}], "sqlGroup4": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600503, "@inHospitalCd": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。職員コードに編集対象外のIDが設定されています。", "ExceptionCondition": "=1"}], "sqlGroup5": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "@crud": "$journal.const.crud", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600504, "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。更新区分は「1：追加、2：変更、3：削除」で設定してください。", "ExceptionCondition": "=1"}], "sqlGroup6": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600505, "@inHospitalCd": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。職員コードが設定されていません。", "ExceptionCondition": "=1"}], "sqlGroup7": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600506, "@inHospitalCd": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。職員コードが規定サイズを超過しています。", "ExceptionCondition": "=1"}], "sqlGroup8": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600507, "@inHospitalCd": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。職員コードは半角英数字で設定してください。", "ExceptionCondition": "=1"}], "sqlGroup9": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600508, "@startDateAfter": "$journal.mst_personal_user.start_date_after", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。有効期間開始日（変更後）が設定されていません。", "ExceptionCondition": "=1"}], "sqlGroup10": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600509, "@startDateAfter": "$journal.mst_personal_user.start_date_after", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。有効期間開始日（変更後）に日付情報が設定されていません。", "ExceptionCondition": "=1"}], "sqlGroup11": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600510, "@endDateAfter": "$journal.mst_personal_user.end_date_after", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。有効期間終了日（変更後）が設定されていません。", "ExceptionCondition": "=1"}], "sqlGroup12": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600511, "@endDateAfter": "$journal.mst_personal_user.end_date_after", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。有効期間終了日（変更後）に日付情報が設定されていません。", "ExceptionCondition": "=1"}], "sqlGroup13": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600512, "@userPassword": "$journal.mst_personal_user.user_password", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。パスワードは半角英数字で設定してください。", "ExceptionCondition": "=1"}], "sqlGroup14": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600513, "@userPassword": "$journal.mst_personal_user.user_password", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。パスワードが規定サイズを超過しています。", "ExceptionCondition": "=1"}], "sqlGroup15": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600514, "@userName": "$journal.mst_personal_user.user_name", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。漢字氏名が規定サイズを超過しています。", "ExceptionCondition": "=1"}], "sqlGroup16": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "連携設定マスタ(mst_coop_ini)", "crud": "S", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": -600515, "@userKana": "$journal.mst_personal_user.user_kana", "ExceptionMessage": "職員マスタCSVの設定に誤りがあります。カナ氏名が規定サイズを超過しています。", "ExceptionCondition": "=1"}], "sqlGroup17": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_personal_user)", "crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 9401, "insertResult": "{@userId:'''', @facilityCd:'''', @userType:'''', @userLastName:'''', @userFirstName:'''', @userLastNameKana:'''', @userFirstNameKana:'''', @userLastNameAlpha:'''', @userFirstNameAlpha:'''', @userEmailAddress1:'''', @userEmailAddress2:'''', @extensionNo:'''', @homeNo:'''', @mobilePhoneNo:'''', @faxNo:'''', @zipcd3:'''', @zipcd4:'''', @address:'''', @addressKana:'''', @jobCd:'''', @regDate_Date:'''', @upDate_Date:'''', @administrator:'''', @isDisp:'''', @isDel:'''', @inHospitalCd1:'''', @inHospitalCd2:'''', @infoDispToAdmin:'''', @anesthesiologistLicenseNo:'''', @signinDate_Date:'''', @patientShared:'''', @fnStaffCd:''''}", "updateResult": "{@userId:''user_id'', @facilityCd:''facility_cd'', @userType:''user_type'', @userLastName:''user_last_name'', @userFirstName:''user_first_name'', @userLastNameKana:''user_last_name_kana'', @userFirstNameKana:''user_first_name_kana'', @userLastNameAlpha:''user_last_name_alpha'', @userFirstNameAlpha:''user_first_name_alpha'', @userEmailAddress1:''user_email_address_1'', @userEmailAddress2:''user_email_address_2'', @extensionNo:''extension_no'', @homeNo:''home_no'', @mobilePhoneNo:''mobile_phone_no'', @faxNo:''fax_no'', @zipcd3:''zipcd_3'', @zipcd4:''zipcd_4'', @address:''address'', @addressKana:''address_kana'', @jobCd:''job_cd'', @regDate_Date:''reg_date'', @upDate_Date:''up_date'', @administrator:''administrator'', @isDisp:''is_disp'', @isDel:''is_del'', @inHospitalCd1:''in_hospital_cd_1'', @inHospitalCd2:''in_hospital_cd_2'', @infoDispToAdmin:''info_disp_to_admin'', @anesthesiologistLicenseNo:''anesthesiologist_license_no'', @signinDate_Date:''signin_date'', @patientShared:''patient_shared'', @fnStaffCd:''fn_staff_cd''}", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "利用者[@inHospitalCd1]の情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "=N"}, {"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_personal_user)", "crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "@jobCd": "$journal.mst_personal_user.job_cd", "ctl_no": "2", "sqlCode": 9402, "@userKana": "$journal.mst_personal_user.user_kana", "@userName": "$journal.mst_personal_user.user_name", "@userType": "0", "@endDateAfter": "$journal.mst_personal_user.end_date_after", "@userPassword": "$journal.mst_personal_user.user_password", "@administrator": "0", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "@startDateAfter": "$journal.mst_personal_user.start_date_after"}, {"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_personal_user)", "crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "@jobCd": "$journal.mst_personal_user.job_cd", "ctl_no": "3", "sqlCode": 9403, "@userKana": "$journal.mst_personal_user.user_kana", "@userName": "$journal.mst_personal_user.user_name", "@userType": "0", "@endDateAfter": "$journal.mst_personal_user.end_date_after", "@userPassword": "$journal.mst_personal_user.user_password", "@administrator": "0", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "@startDateAfter": "$journal.mst_personal_user.start_date_after"}], "sqlGroup18": [{"No1": "更新区分が「''3''：削除」の処理。", "No2": "利用者マスタ(mst_personal_user)。", "crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 9401, "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "利用者[@inHospitalCd1]の情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "=N"}, {"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_user)", "crud": "D", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_user_authentication", "ctl_no": "2", "sqlCode": -600518, "@endDateAfter": "$journal.mst_personal_user.end_date_after", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "@startDateAfter": "$journal.mst_personal_user.start_date_after"}], "sqlGroup19": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_user_authentication)", "crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 9405, "insertResult": "{@userId:'''', @facilityCd:'''', @dispUserId:'''', @userPassword:'''', @failureCnt:'''', @regDate_Date:'''', @upDate_Date:'''', @userPasswordHistoryValue:''''}", "updateResult": "{@userId:''user_id'', @facilityCd:''facility_cd'', @dispUserId:''disp_user_id'', @userPassword:''user_password'', @failureCnt:''failure_cnt'', @regDate_Date:''reg_date'', @upDate_Date:''up_date'', @userPasswordHistoryValue:''user_password_history''}", "@endDateAfter": "$journal.mst_personal_user.end_date_after", "@startDateAfter": "$journal.mst_personal_user.start_date_after"}, {"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_user_authentication)", "crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "2", "sqlCode": 9406, "@dispUserId": "$journal.mst_personal_user.in_hospital_cd_1", "@endDateAfter": "$journal.mst_personal_user.end_date_after", "@startDateAfter": "$journal.mst_personal_user.start_date_after", "@%%passwordencoder%%_dispUserId": "$journal.mst_personal_user.in_hospital_cd_1", "@%%passwordencoder%%_userPassword": "$journal.mst_personal_user.user_password"}, {"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_user_authentication)", "crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "3", "sqlCode": 9407, "@dispUserId": "$journal.mst_personal_user.in_hospital_cd_1", "@%%passwordencoder%%_dispUserId": "$journal.mst_personal_user.in_hospital_cd_1", "@%%passwordencoder%%_userPassword": "$journal.mst_personal_user.user_password"}], "sqlGroup20": [{"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_user)", "crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 9408, "insertResult": "{@userId:'''', @userSettingsValue:'''', @isProvisional:'''', @regDate_Date:'''', @upDate_Date:'''', @isDisp:'''', @isDel:'''', @patId:'''', @tmpLogSearchConditionValue:'''', @secretKey:'''', @isSetQrCode:'''', @cardIdm:'''', @isConsent:'''', @consentDate_Date:'''', @regPasswordDate_Date:'''', @facilityCd:''''}", "updateResult": "{@userId:''user_id'', @userSettingsValue:''user_settings'', @isProvisional:''is_provisional'', @regDate_Date:''reg_date'', @upDate_Date:''up_date'', @isDisp:''is_disp'', @isDel:''is_del'', @patId:''pat_id'', @tmpLogSearchConditionValue:''tmp_log_search_condition'', @secretKey:''secret_key'', @isSetQrCode:''is_set_qr_code'', @cardIdm:''card_idm'', @isConsent:''is_consent'', @consentDate_Date:''consent_date'', @regPasswordDate_Date:''reg_password_date'', @facilityCd:''facility_cd''}", "@endDateAfter": "$journal.mst_personal_user.end_date_after", "@startDateAfter": "$journal.mst_personal_user.start_date_after"}, {"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_user)", "crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "@jobCd": "$journal.mst_personal_user.job_cd", "ctl_no": "2", "sqlCode": 9409, "@endDateAfter": "$journal.mst_personal_user.end_date_after", "@startDateAfter": "$journal.mst_personal_user.start_date_after", "@userSettingsValue": "{\"theme\": 0, \"font_size\": 1, \"is_disp_menu\": 1, \"use_functions\": [\"005\"], \"is_split_frame\": 1, \"default_setting\": {}, \"ind_rst_pattern\": null, \"initial_function\": \"005\", \"personal_settings\": [], \"authorized_functions\": [\"005\"], \"authorized_authorities\": []}"}, {"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_user)", "crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "@jobCd": "$journal.mst_personal_user.job_cd", "ctl_no": "3", "sqlCode": 9410, "@userSettingsValue": "{\"theme\": 0, \"font_size\": 1, \"is_disp_menu\": 1, \"use_functions\": [\"005\"], \"is_split_frame\": 1, \"default_setting\": {}, \"ind_rst_pattern\": null, \"initial_function\": \"005\", \"personal_settings\": [], \"authorized_functions\": [\"005\"], \"authorized_authorities\": []}"}], "sqlGroup21": [{"No1": "更新区分が「''3''：削除」の処理。", "No2": "利用者マスタ(mst_personal_user)。", "crud": "S", "kind": "1", "judge": "$journal.const.crud#=#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 9401, "insertResult": "{@userId:''-1''}", "updateResult": "{@userId:''user_id''}", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "利用者[@inHospitalCd1]の情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "=N"}, {"No1": "更新区分が「''3''：削除」の処理。", "No2": "利用者マスタ(mst_user) 倫理削除。サブテーブル、削除処理を先に実行", "crud": "U", "kind": "1", "judge": "$journal.const.crud#=#D", "table": "mst_user", "ctl_no": "2", "sqlCode": 9413}], "sqlGroup22": [{"No1": "更新区分が「''3''：削除」の処理。", "No2": "利用者マスタ(mst_personal_user)。", "crud": "S", "kind": "1", "judge": "$journal.const.crud#=#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 9401, "insertResult": "{@userId:''-1''}", "updateResult": "{@userId:''user_id''}", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "利用者[@inHospitalCd1]の情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "=N"}, {"No1": "更新区分が「''3''：削除」の処理。", "No2": "利用者マスタ(mst_user_authentication) 物理削除。サブテーブル、削除処理を先に実行", "crud": "D", "kind": "1", "judge": "$journal.const.crud#=#D", "table": "mst_user_authentication", "ctl_no": "2", "sqlCode": 9412}], "sqlGroup23": [{"No1": "更新区分が「''3''：削除」の処理。", "No2": "利用者マスタ(mst_personal_user)。", "crud": "S", "kind": "1", "judge": "$journal.const.crud#=#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 9401, "insertResult": "{@userId:''-1''}", "updateResult": "{@userId:''user_id''}", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "利用者[@inHospitalCd1]の情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "=N"}, {"No1": "更新区分が「''3''：削除」の処理。", "No2": "利用者マスタ(mst_personal_user) 倫理削除。親テーブル、後に削除処理を実行。", "crud": "U", "kind": "1", "judge": "$journal.const.crud#=#D", "table": "mst_personal_user", "ctl_no": "2", "sqlCode": 9411}], "sqlGroup24": [{"No1": "更新区分が「''3''：削除」の処理。", "No2": "利用者マスタ(mst_personal_user)。", "crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 9401, "insertResult": "{@userId:''-1''}", "updateResult": "{@userId:''user_id''}", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "利用者[@inHospitalCd1]の情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "=N"}, {"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_user)", "crud": "D", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_user_authentication", "ctl_no": "2", "sqlCode": -600518, "@endDateAfter": "$journal.mst_personal_user.end_date_after", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "@startDateAfter": "$journal.mst_personal_user.start_date_after"}], "sqlGroup25": [{"No1": "更新区分が「''3''：削除」の処理。", "No2": "利用者マスタ(mst_personal_user)。", "crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 9401, "insertResult": "{@userId:''-1''}", "updateResult": "{@userId:''user_id''}", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "利用者[@inHospitalCd1]の情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "=N"}, {"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_user)", "crud": "U", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "2", "sqlCode": -600517, "@endDateAfter": "$journal.mst_personal_user.end_date_after", "@startDateAfter": "$journal.mst_personal_user.start_date_after"}], "sqlGroup26": [{"No1": "更新区分が「''3''：削除」の処理。", "No2": "利用者マスタ(mst_personal_user)。", "crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 9401, "insertResult": "{@userId:''-1''}", "updateResult": "{@userId:''user_id''}", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "利用者[@inHospitalCd1]の情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "=N"}, {"No1": "更新区分が「''1''：追加、''2''：変更」の処理。", "No2": "利用者マスタ(mst_personal_user)", "crud": "U", "kind": "0", "judge": "$journal.const.crud#<>#D", "table": "mst_personal_user", "ctl_no": "2", "sqlCode": -600516, "@endDateAfter": "$journal.mst_personal_user.end_date_after", "@startDateAfter": "$journal.mst_personal_user.start_date_after"}]}}'::jsonb, '1', '0', -1, '2019-12-13 05:44:54.000', CURRENT_TIMESTAMP, 'HR');


INSERT INTO ntss.mst_coop_layout
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
  <item name="オーダ番号" len="16" value="dataset:-600203.ind_ord_no"/>
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
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "1"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -600203, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', 4, '2020-05-20 10:53:24.901', CURRENT_TIMESTAMP, 'HR');
INSERT INTO ntss.mst_coop_layout
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
  <item name="オーダ番号" len="16" value="dataset:-600203.ind_ord_no"/>
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
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "U", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "1"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -600203, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', 4, '2020-05-20 10:53:24.901', CURRENT_TIMESTAMP, 'HR');
INSERT INTO ntss.mst_coop_layout
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
  <item name="オーダ番号" len="16" value="dataset:-600203.ind_ord_no"/>
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
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "D", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -600203, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', 4, '2020-05-20 10:53:24.901', CURRENT_TIMESTAMP, 'HR');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040004, 'N_hosp', 'ind_dial', '', 'S', 'cre', 'text', 'NEC', 'MEGA', '詳細指示(Ver2)/TSHPlus', '1', '<root name="透析予約">
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:A"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600203.ind_ord_no"/>
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
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "2"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -600203, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, '2020-05-20 10:53:24.901', CURRENT_TIMESTAMP, 'HR');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040005, 'N_hosp', 'ind_dial', '', 'S', 'upd', 'text', 'NEC', 'MEGA', '詳細指示(Ver2)/TSHPlus', '1', '<root name="透析予約">
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:U"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600203.ind_ord_no"/>
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
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "U", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "2"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -600203, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, '2020-05-20 10:53:24.901', CURRENT_TIMESTAMP, 'HR');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040006, 'N_hosp', 'ind_dial', '', 'S', 'del', 'text', 'NEC', 'MEGA', '詳細指示(Ver2)/TSHPlus', '1', '<root name="透析予約">
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:D"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600203.ind_ord_no"/>
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
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "D", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -600203, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, '2020-05-20 10:53:24.901', CURRENT_TIMESTAMP, 'HR');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040007, 'N_hosp', 'ind_dial', '', 'S', 'cre', 'text', 'NEC', 'MEGA', '詳細指示(Ver1)/TSHPlus', '1', '<root name="透析予約">
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:A"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600203.ind_ord_no"/>
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
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "1"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -600203, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, '2025-02-20 12:07:51.405', CURRENT_TIMESTAMP, 'HR');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040008, 'N_hosp', 'ind_dial', '', 'S', 'upd', 'text', 'NEC', 'MEGA', '詳細指示(Ver1)/TSHPlus', '1', '<root name="透析予約">
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:U"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600203.ind_ord_no"/>
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
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "U", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "1"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -600203, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, '2025-02-20 12:07:51.405', CURRENT_TIMESTAMP, 'HR');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040009, 'N_hosp', 'ind_dial', '', 'S', 'del', 'text', 'NEC', 'MEGA', '詳細指示(Ver1)/TSHPlus', '1', '<root name="透析予約">
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:D"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600203.ind_ord_no"/>
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
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "D", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -600203, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, '2025-02-20 12:07:51.405', CURRENT_TIMESTAMP, 'HR');
INSERT INTO ntss.mst_coop_layout
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
  <item name="オーダ番号" len="16" value="dataset:-600203.ind_ord_no"/>
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
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "2"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -600203, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, '2025-02-20 12:07:51.405', CURRENT_TIMESTAMP, 'HR');
INSERT INTO ntss.mst_coop_layout
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
  <item name="オーダ番号" len="16" value="dataset:-600203.ind_ord_no"/>
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
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "U", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "2"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -600203, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, '2025-02-20 12:07:51.405', CURRENT_TIMESTAMP, 'HR');
INSERT INTO ntss.mst_coop_layout
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
  <item name="オーダ番号" len="16" value="dataset:-600203.ind_ord_no"/>
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
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "D", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -600203, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, '2025-02-20 12:07:51.405', CURRENT_TIMESTAMP, 'HR');