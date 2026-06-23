DELETE  FROM "ntss"."mst_coop_layout" WHERE ctl_no IN (-2120003);
INSERT INTO "ntss"."mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-2120003, 'F_hosp', 'staff_mst', '', 'R', 'pre', 'csv', '富士通スタッフマスタ連携', 'Egmain-GX', 'テスト用', '1', '<root name="スタッフマスタ連携"  multi="true:CRLF/LFCR/CR/LF" >
    <item  name="利用者番号" len="8"  col="$journal.mst_personal_user.in_hospital_cd_1" type="string"/>
    <item  name="パスワード" len="64"  col="$journal.mst_user_authentication.user_password" type="string"/>
    <item  name="利用者漢字氏名" len="20" col="$journal.mst_personal_user.pat_name" type="string"/>
    <item  name="利用者カナ氏名" len="40" col="$journal.mst_personal_user.pat_name_kana" type="string"/>
    <item  name="利用者英字氏名" len="40" type="string"/>
    <item  name="生年月日" len="8" type="string"/>
    <item  name="性別" len="1"  type="string"/>
    <item  name="電子メールアドレス" len="80"  type="string"/>
    <item  name="ポケットベル番号" len="20"  type="string"/>
    <item  name="利用者職種情報.職種コード" len="3" col="$journal.mst_personal_user.job_cd" type="string"/>
    <item  name="利用者職種情報.担当入外区分" len="1" type="string"/>
    <item  name="利用者職種情報.依頼医入力必須区分" len="1" type="string"/>
    <item  name="利用者職種情報.麻薬施用者番号" len="228"  type="string"/>
    <item  name="利用者職種情報.人事ID" len="10" type="string"/>
    <item  name="利用者職種情報.病歴室ID" len="10" type="string"/>
    <item  name="利用者所属情報.所属部科コード1" len="3"  type="string" />
    <item  name="利用者所属情報.所属病棟コード1" len="3"  type="string" />
    <item  name="利用者所属情報.所属病室コード1" len="3"  type="string" />
    <item  name="利用者所属情報.職制コード1" len="3"  type="string" />
    <item  name="利用者所属情報.有効開始日1" len="8"  type="string" />
    <item  name="利用者所属情報.有効終了日1" len="8" type="string"/>
    <item  name="利用者所属情報.所属部科コード2" len="3"  type="string" />
    <item  name="利用者所属情報.所属病棟コード2" len="3"  type="string" />
    <item  name="利用者所属情報.所属病室コード2" len="3"  type="string" />
    <item  name="利用者所属情報.職制コード2" len="3"  type="string" />
    <item  name="利用者所属情報.有効開始日2" len="8"  type="string" />
    <item  name="利用者所属情報.有効終了日2" len="8" type="string"/>
    <item  name="利用者所属情報.所属部科コード3" len="3"  type="string" />
    <item  name="利用者所属情報.所属病棟コード3" len="3"  type="string" />
    <item  name="利用者所属情報.所属病室コード3" len="3"  type="string" />
    <item  name="利用者所属情報.職制コード3" len="3"  type="string" />
    <item  name="利用者所属情報.有効開始日3" len="8"  type="string" />
    <item  name="利用者所属情報.有効終了日3" len="8" type="string"/>
    <item  name="利用者所属情報.所属部科コード4" len="3"  type="string" />
    <item  name="利用者所属情報.所属病棟コード4" len="3"  type="string" />
    <item  name="利用者所属情報.所属病室コード4" len="3"  type="string" />
    <item  name="利用者所属情報.職制コード4" len="3"  type="string" />
    <item  name="利用者所属情報.有効開始日4" len="8"  type="string" />
    <item  name="利用者所属情報.有効終了日4" len="8" type="string"/>
    <item  name="利用者所属情報.所属部科コード5" len="3"  type="string" />
    <item  name="利用者所属情報.所属病棟コード5" len="3"  type="string" />
    <item  name="利用者所属情報.所属病室コード5" len="3"  type="string" />
    <item  name="利用者所属情報.職制コード5" len="3"  type="string" />
    <item  name="利用者所属情報.有効開始日5" len="8"  type="string" />
    <item  name="利用者所属情報.有効終了日5" len="8" type="string"/>
    <item  name="利用者特別職情報.特別職コード1" len="3" type="string"/>
    <item  name="利用者特別職情報.特別職コード2" len="3" type="string"/>
    <item  name="利用者特別職情報.特別職コード3" len="3" type="string"/>
    <item  name="利用者特別職情報.特別職コード4" len="3" type="string"/>
    <item  name="利用者特別職情報.特別職コード5" len="3" type="string"/>
    <item  name="利用者職種情報.情報種別アクセス権限情報.情報種別アクセス権限テーブル.情報種別アクセス権限" len="500" type="string"/>
    <item  name="利用者職種情報.ツールアクセス権限情報.ツールアクセス権限テーブル.ツールアクセス権限" len="500" type="string"/>
    <item  name="利用者職種情報.プロファイルアクセス権限情報.プロファイルアクセス権限テーブル.プロファイルアクセス権限" len="100" type="string"/>
    <item  name="利用者職種情報.モニターアクセス権限情報.モニターアクセス権限テーブル.モニターアクセス権限" len="100" type="string"/>
    <item  name="利用者有効期間.有効期間開始日時" col="$journal.tag.indatestart" len="8" type="string"/>
    <item  name="利用者有効期間.有効期間終了日時" col="$journal.tag.indatesend" len="8" type="string"/>
    <item  name="緊急フラグ" len="1" type="string" col="$journal.const.crud" value="const:C"/>
    <item  name="解放領域.ユーザ解放領域" len="50" type="string"/>
    <item  name="解放領域.システム予備領域" len="46" type="string"/>
    <item  name="パスワード有効期間終了日" len="8" type="string"/>
    <item  name="動作条件環境.発行入外区分" len="1" type="string"/>
    <item  name="動作条件環境.発行部科コード" len="3" type="string"/>
    <item  name="動作条件環境.発行病棟コード" len="3" type="string"/>
    <item  name="前回使用情報.前回使用日" len="8" type="string"/>
    <item  name="前回使用情報.前回使用時刻" len="8" type="string"/>
    <item  name="前回使用情報.前回使用端末" len="8" type="string"/>
    <item  name="前回停止情報.前回停止日" len="8" type="string"/>
    <item  name="前回停止情報.前回停止時刻" len="8" type="string"/>
    <item  name="廃止情報.廃止日" len="8" type="string"/>
    <item  name="廃止情報.廃止時刻" len="8" type="string"/>
    <item  name="更新者情報.更新者番号" len="8" type="string"/>
    <item  name="更新者情報.廃止時刻" len="8" type="string"/>
    <item  name="更新者情報.作成日付" len="8" type="string"/>
    <item  name="作成者情報.更新者番号" len="8" type="string"/>
    <item  name="作成者情報.廃止時刻" len="8" type="string"/>
    <item  name="作成者情報.作成日付" len="8" type="string"/>
    <item  name="使用停止フラグ" len="1" col="$journal.tag.stoptag" type="string"/>
    <item  name="廃止フラグ" len="1" col="$journal.tag.abolishtag" type="string"/>
    <item  name="医師免許番号" len="20" type="string"/>
    <item  name="麻薬施用者番号２" len="10" type="string"/>
    <item  name="麻薬施用者番号開始" len="8" type="string"/>
    <item  name="麻薬施用者番号開始" len="8" type="string"/>
    <item  name="麻薬施用者番号２開始" len="8" type="string"/>
    <item  name="麻薬施用者番号２終了" len="8" type="string"/>
</root>', '{"csv": {"delim": {"item": ","}}, "dataset": {"sqlGroup1": [{"No1": "「取り込み条件不満足,取り込みしない", "No2": "利用者マスタ(mst_personal_user)", "crud": "S", "kind": "0", "judge": "", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 10013, "@stopTag": "$journal.tag.stoptag", "@abolishTag": "$journal.tag.abolishtag", "@indatesEnd": "$journal.tag.indatesend", "@indateStart": "$journal.tag.indatestart", "ExceptionMessage": "取り込み条件不満足", "ExceptionCondition": "<>0"}], "sqlGroup2": [{"No1": "「削除済みスタッフの更新フラグ」が“0：更新しない。", "No2": "利用者マスタ(mst_personal_user)", "crud": "S", "kind": "0", "judge": "", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 10003, "insertResult": "{@userId:'''', @facilityCd:'''', @userType:'''', @userLastName:'''', @userFirstName:'''', @userLastNameKana:'''', @userFirstNameKana:'''', @userLastNameAlpha:'''', @userFirstNameAlpha:'''', @userEmailAddress1:'''', @userEmailAddress2:'''', @extensionNo:'''', @homeNo:'''', @mobilePhoneNo:'''', @faxNo:'''', @zipcd3:'''', @zipcd4:'''', @address:'''', @addressKana:'''', @jobCd:'''', @regDate_Date:'''', @upDate_Date:'''', @administrator:'''', @isDisp:'''', @isDel:'''', @inHospitalCd1:'''', @inHospitalCd2:'''', @infoDispToAdmin:'''', @anesthesiologistLicenseNo:'''', @signinDate_Date:'''', @patientShared:'''', @fnStaffCd:''''}", "updateResult": "{@userId:''user_id'', @facilityCd:''facility_cd'', @userType:''user_type'', @userLastName:''user_last_name'', @userFirstName:''user_first_name'', @userLastNameKana:''user_last_name_kana'', @userFirstNameKana:''user_first_name_kana'', @userLastNameAlpha:''user_last_name_alpha'', @userFirstNameAlpha:''user_first_name_alpha'', @userEmailAddress1:''user_email_address_1'', @userEmailAddress2:''user_email_address_2'', @extensionNo:''extension_no'', @homeNo:''home_no'', @mobilePhoneNo:''mobile_phone_no'', @faxNo:''fax_no'', @zipcd3:''zipcd_3'', @zipcd4:''zipcd_4'', @address:''address'', @addressKana:''address_kana'', @jobCd:''job_cd'', @regDate_Date:''reg_date'', @upDate_Date:''up_date'', @administrator:''administrator'', @isDisp:''is_disp'', @isDel:''is_del'', @inHospitalCd1:''in_hospital_cd_1'', @inHospitalCd2:''in_hospital_cd_2'', @infoDispToAdmin:''info_disp_to_admin'', @anesthesiologistLicenseNo:''anesthesiologist_license_no'', @signinDate_Date:''signin_date'', @patientShared:''patient_shared'', @fnStaffCd:''fn_staff_cd''}", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "利用者[@inHospitalCd1]の情報は一つではなく、[@dataCnt]つのデータがあります。「削除済みスタッフの更新フラグ」が“0：更新しない”設定のとき,ＦＮISのスタッフマスタにて、利用者番号が一致するレコードが存在し、かつ最新データの削除フラグが“1：削除”である、更新を行いません", "ExceptionCondition": "<>0"}], "sqlGroup3": [{"No1": "「同じ利用者が存在します,取り込みしない。」", "No2": "利用者マスタ(mst_personal_user)", "crud": "S", "kind": "0", "judge": "", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 10010, "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "利用者[@inHospitalCd1]の情報。同じ利用者が存在します,取り込みしない。", "ExceptionCondition": "<>0"}], "sqlGroup4": [{"No1": "「''1''：新規、''2''：更新」の処理。", "No2": "利用者マスタ(mst_personal_user)", "crud": "S", "kind": "0", "judge": "", "table": "mst_personal_user", "ctl_no": "1", "sqlCode": 10002, "insertResult": "{@userId:'''', @facilityCd:'''', @userType:'''', @userLastName:'''', @userFirstName:'''', @userLastNameKana:'''', @userFirstNameKana:'''', @userLastNameAlpha:'''', @userFirstNameAlpha:'''', @userEmailAddress1:'''', @userEmailAddress2:'''', @extensionNo:'''', @homeNo:'''', @mobilePhoneNo:'''', @faxNo:'''', @zipcd3:'''', @zipcd4:'''', @address:'''', @addressKana:'''', @jobCd:'''', @regDate_Date:'''', @upDate_Date:'''', @administrator:'''', @isDisp:'''', @isDel:'''', @inHospitalCd1:'''', @inHospitalCd2:'''', @infoDispToAdmin:'''', @anesthesiologistLicenseNo:'''', @signinDate_Date:'''', @patientShared:'''', @fnStaffCd:''''}", "updateResult": "{@userId:''user_id'', @facilityCd:''facility_cd'', @userType:''user_type'', @userLastName:''user_last_name'', @userFirstName:''user_first_name'', @userLastNameKana:''user_last_name_kana'', @userFirstNameKana:''user_first_name_kana'', @userLastNameAlpha:''user_last_name_alpha'', @userFirstNameAlpha:''user_first_name_alpha'', @userEmailAddress1:''user_email_address_1'', @userEmailAddress2:''user_email_address_2'', @extensionNo:''extension_no'', @homeNo:''home_no'', @mobilePhoneNo:''mobile_phone_no'', @faxNo:''fax_no'', @zipcd3:''zipcd_3'', @zipcd4:''zipcd_4'', @address:''address'', @addressKana:''address_kana'', @jobCd:''job_cd'', @regDate_Date:''reg_date'', @upDate_Date:''up_date'', @administrator:''administrator'', @isDisp:''is_disp'', @isDel:''is_del'', @inHospitalCd1:''in_hospital_cd_1'', @inHospitalCd2:''in_hospital_cd_2'', @infoDispToAdmin:''info_disp_to_admin'', @anesthesiologistLicenseNo:''anesthesiologist_license_no'', @signinDate_Date:''signin_date'', @patientShared:''patient_shared'', @fnStaffCd:''fn_staff_cd''}", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "ExceptionMessage": "利用者[@inHospitalCd1]の情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "=N"}, {"No1": "「''1''：新規」の処理", "No2": "利用者マスタ(mst_personal_user)", "crud": "C", "kind": "0", "judge": "", "table": "mst_personal_user", "@jobCd": "$journal.mst_personal_user.job_cd", "ctl_no": "2", "sqlCode": 10000, "@userKana": "$journal.mst_personal_user.pat_name_kana", "@userName": "$journal.mst_personal_user.pat_name", "@userType": "0", "@administrator": "0", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "@userNamealpha": "$journal.mst_personal_user.pat_name_alpha", "@anesthesiologist_license_no": "$journal.mst_personal_user.anesthesiologist_license_no"}, {"No1": "「''2''：更新」の処理。", "No2": "利用者マスタ(mst_personal_user)", "crud": "U", "kind": "0", "judge": "", "table": "mst_personal_user", "@jobCd": "$journal.mst_personal_user.job_cd", "ctl_no": "3", "sqlCode": 10001, "@userKana": "$journal.mst_personal_user.pat_name_kana", "@userName": "$journal.mst_personal_user.pat_name", "@userType": "0", "@administrator": "0", "@inHospitalCd1": "$journal.mst_personal_user.in_hospital_cd_1", "@userNamealpha": "$journal.mst_personal_user.pat_name_alpha", "@anesthesiologist_license_no": "$journal.mst_personal_user.anesthesiologist_license_no"}], "sqlGroup5": [{"No1": "「''1''：新規、''2''：更新」の処理。", "No2": "利用者マスタ(mst_user_authentication)", "crud": "S", "kind": "0", "judge": "", "table": "mst_user_authentication", "ctl_no": "1", "sqlCode": 10008, "insertResult": "{@userId:'''', @facilityCd:'''', @dispUserId:'''', @userPassword:'''', @failureCnt:'''', @regDate_Date:'''', @upDate_Date:'''', @userPasswordHistoryValue:''''}", "updateResult": "{@userId:''user_id'', @facilityCd:''facility_cd'', @dispUserId:''disp_user_id'', @userPassword:''user_password'', @failureCnt:''failure_cnt'', @regDate_Date:''reg_date'', @upDate_Date:''up_date'', @userPasswordHistoryValue:''user_password_history''}"}, {"No1": "「''1''：新規」の処理。", "No2": "利用者マスタ(mst_user_authentication)", "crud": "C", "kind": "0", "judge": "", "table": "mst_user_authentication", "ctl_no": "2", "sqlCode": 10006, "@dispUserId": "$journal.mst_personal_user.in_hospital_cd_1", "@%%passwordencoder%%_dispUserId": "$journal.mst_personal_user.in_hospital_cd_1", "@%%passwordencoder%%_userPassword": "$journal.mst_user_authentication.user_password", "@%%passwordencoder%%_defaultPassword": "123456"}, {"No1": "「''2''：更新」の処理。", "No2": "利用者マスタ(mst_user_authentication)", "crud": "U", "kind": "0", "judge": "", "table": "mst_user_authentication", "ctl_no": "3", "sqlCode": 10007, "@dispUserId": "$journal.mst_personal_user.in_hospital_cd_1", "@%%passwordencoder%%_dispUserId": "123456789", "@%%passwordencoder%%_userPassword": "$journal.mst_user_authentication.user_password", "@%%passwordencoder%%_defaultPassword": "123456"}], "sqlGroup6": [{"No1": "「更新」の処理。", "No2": "職種マスタ(mst_job)", "crud": "D", "kind": "0", "judge": "", "table": "mst_job", "@jobCd": "$journal.mst_personal_user.job_cd", "ctl_no": "1", "sqlCode": 10012}], "sqlGroup7": [{"No1": "「''1''：新規、''2''：更新」の処理。", "No2": "利用者マスタ(mst_user)", "crud": "S", "kind": "0", "judge": "", "table": "mst_user", "ctl_no": "1", "sqlCode": 10011, "insertResult": "{@userId:'''', @userSettingsValue:'''', @isProvisional:'''', @regDate_Date:'''', @upDate_Date:'''', @isDisp:'''', @isDel:'''', @patId:'''', @tmpLogSearchConditionValue:'''', @secretKey:'''', @isSetQrCode:'''', @cardIdm:'''', @isConsent:'''', @consentDate_Date:'''', @regPasswordDate_Date:'''', @facilityCd:''''}", "updateResult": "{@userId:''user_id'', @userSettingsValue:''user_settings'', @isProvisional:''is_provisional'', @regDate_Date:''reg_date'', @upDate_Date:''up_date'', @isDisp:''is_disp'', @isDel:''is_del'', @patId:''pat_id'', @tmpLogSearchConditionValue:''tmp_log_search_condition'', @secretKey:''secret_key'', @isSetQrCode:''is_set_qr_code'', @cardIdm:''card_idm'', @isConsent:''is_consent'', @consentDate_Date:''consent_date'', @regPasswordDate_Date:''reg_password_date'', @facilityCd:''facility_cd''}"}, {"No1": "「''1''：新規」の処理。", "No2": "利用者マスタ(mst_user)", "crud": "C", "kind": "0", "judge": "", "table": "mst_user", "@jobCd": "$journal.mst_personal_user.job_cd", "ctl_no": "2", "sqlCode": 10009, "@userSettingsValue": "{\"theme\": 0, \"font_size\": 1, \"is_disp_menu\": 1, \"use_functions\": [\"005\"], \"is_split_frame\": 1, \"default_setting\": {}, \"ind_rst_pattern\": null, \"initial_function\": \"005\", \"personal_settings\": [], \"authorized_functions\": [\"005\"], \"authorized_authorities\": []}"}]}}', '1', '0', 7228, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'gx001');

