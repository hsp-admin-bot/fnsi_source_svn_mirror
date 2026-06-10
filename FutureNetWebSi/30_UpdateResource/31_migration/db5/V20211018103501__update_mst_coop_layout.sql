delete from "mst_coop_layout" where "facility_cd" = 'P_hosp' and "coop_cd" = 'profile';
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4030001, 'P_hosp', 'profile', '', 'R', 'pre', 'text     ', 'パナソニック 患者プロファイル', 'Medicom', '患者プロファイル', '1', '<root name="患者情報(pre)">
    <item  name="STX" len="1" type="string"/>
    <item  name="拡張部" len="2" type="string"/>
    <item  name="電文区分" len="4" type="string" key="shori_kbn"/>
    <item  name="ブロック区分" len="3" type="string"/>
    <item  name="予備" len="1" type="string"/>
    <item  name="データ区分" len="3" type="string"/>
    <item  name="サブ区分" len="1" type="string"/>
    <item  name="情報種別" len="1" type="string"/>
    <item  name="患者コード" len="13" type="string"/>
    <item  name="患者詳細情報.主科" len="3" type="string"/>
    <item  name="患者詳細情報.外来/入院" len="1" type="string"/>
    <item  name="患者詳細情報.保険組No" len="3" type="string"/>
    <item  name="患者詳細情報.予備" len="2" type="string"/>
    <item  name="患者詳細情報.年齢区分" len="1" type="string"/>
    <item  name="患者詳細情報.所得区分" len="1" type="string"/>
    <item  name="患者詳細情報.認定区分" len="1" type="string"/>
    <item  name="患者詳細情報.医療/介護フラグ" len="1" type="string"/>
    <item  name="患者詳細情報.予備" len="13" type="string"/>
    <item  name="患者詳細情報.頭書登録順No" len="6" type="string"/>
    <item  name="最終来院年月" len="6" type="string"/>
    <item  name="カナ氏名" len="30" type="string"/>
    <item  name="氏名" len="34" type="string"/>
    <item  name="性別" len="1" type="string"/>
    <item  name="生年元号" len="8" type="string"/>
    <item  name="生年月日" len="8" type="string"/>
    <item  name="予備" len="1" type="string"/>
    <item  name="郵便番号" len="8" type="string"/>
    <item  name="住所（1行目_2行目）" len="88" type="string"/>
    <item  name="電話番号" len="12" type="string"/>
    <item  name="連絡先電話番号" len="12" type="string"/>
    <item  name="職業" len="14" type="string"/>
    <item  name="個人コメント（漢字）" len="44" type="string"/>
    <item  name="予備" len="1" type="string"/>
    <item  name="本人/家族" len="1" type="string"/>
    <item  name="続柄" len="10" type="string"/>
    <item  name="保険者番号" len="8" type="string"/>
    <item  name="被保険者証・記号" len="44" type="string"/>
    <item  name="被保険者証・番号" len="44" type="string"/>
    <item  name="保険証有効期限" len="8" type="string"/>
    <item  name="第1公費負担者番号" len="8" type="string"/>
    <item  name="第1公費受給者番号" len="8" type="string"/>
    <item  name="第1公費有効期限" len="8" type="string"/>
    <item  name="第2公費負担者番号" len="8" type="string"/>
    <item  name="第2公費受給者番号" len="8" type="string"/>
    <item  name="第2公費有効期限" len="8" type="string"/>
    <item  name="第3公費負担者番号" len="8" type="string"/>
    <item  name="第3公費受給者番号" len="8" type="string"/>
    <item  name="第3公費有効期限" len="8" type="string"/>
    <item  name="保険名称" len="14" type="string"/>
    <item  name="分類A" len="4" type="string"/>
    <item  name="分類B" len="4" type="string"/>
    <item  name="分類C" len="4" type="string"/>
    <item  name="分類D" len="4" type="string"/>
    <item  name="保険区分" len="3" type="string"/>
    <item  name="予備" len="1" type="string"/>
    <item  name="ETX" len="1" type="string"/>
</root>', '{"key": {"shori_kbn": {"MDT0": "cre"}}, "dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"crud": "C", "kind": "0", "judge": "$journal.pat_personal_main.hosp_pat_id#=#123", "table": "pat_personal_main", "ctl_no": "2", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": 1102, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "$journal.pat_personal_main.in_out_class", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_last_name", "@patFirstName": "$journal.pat_personal_main.pat_last_name", "@patLastNmKana": "$journal.pat_personal_main.pat_last_name_kana", "@patFirstNmKana": "$journal.pat_personal_main.pat_last_name_kana", "@patContactInfo.tel": "$journal.pat_personal_main.pat_contact_info.tel", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address", "@patContactInfo.workTel": "$journal.pat_personal_main.pat_contact_info.work_tel"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "3", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": 1103, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "$journal.pat_personal_main.in_out_class", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_last_name", "@patFirstName": "$journal.pat_personal_main.pat_last_name", "@patLastNmKana": "$journal.pat_personal_main.pat_last_name_kana", "@patFirstNmKana": "$journal.pat_personal_main.pat_last_name_kana", "@patContactInfo.tel": "$journal.pat_personal_main.pat_contact_info.tel", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address", "@patContactInfo.workTel": "$journal.pat_personal_main.pat_contact_info.work_tel"}], "sqlGroup2": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_insurance", "@ctlNo": "$journal.pat_insurance.ctl_no", "ctl_no": "1", "sqlCode": 1301, "insertResult": "{@patId:''0'',@facilityCd:''0'',@ctlNo:'''',@fnPatId:'''',@insuClass:'''',@insuName:'''',@insuNmShort:'''',@insuInfoFlg:'''',@insuInfo.insuNo:'''',@insuInfo.insuPatName:'''',@insuInfo.insuPatNo:'''',@insuInfo.insuKbn:'''',@insuInfo.insuPatMark:'''',@insuInfo.ckiClass:'''',@insuInfo.kkiClass:'''',@insuInfo.undSix:'''',@insuInfo.futan-g:'''',@insuInfo.futan-n:'''',@insuPubInfoFlg:'''',@insuPubInfo.insuPubName:'''',@insuPubInfo.insuPubNo:'''',@insuPubInfo.insuPubPatNo:'''',@insuSetInfoFlg:'''',@insuSetInfo.insuCd:'''',@insuSetInfo.insuPub1Cd:'''',@insuSetInfo.insuPub2Cd:'''',@insuSetInfo.insuPub3Cd:'''',@insuSetInfo.insuPub4Cd:'''',@isSelected:'''',@isDisp:''1'',@coopCode:'''',@isCoop:'''',@startDate:'''',@endDate:'''',@checkDate:'''',@oldUpDate_Date:''''}", "updateResult": "{@patId:''pat_id'',@facilityCd:''facility_cd'',@ctlNo:''ctl_no'',@fnPatId:''fn_pat_id'',@insuClass:''insu_class'',@insuName:''insu_name'',@insuNmShort:''insu_name_short'',@insuInfoFlg:'''',@insuInfoValue:''insu_info'',@insuInfo.insuNo:'''',@insuInfo.insuPatName:'''',@insuInfo.insuPatNo:'''',@insuInfo.insuKbn:'''',@insuInfo.insuPatMark:'''',@insuInfo.ckiClass:'''',@insuInfo.kkiClass:'''',@insuInfo.undSix:'''',@insuInfo.futan-g:'''',@insuInfo.futan-n:'''',@insuPubInfoFlg:'''',@insuPubInfoValue:''insu_pub_info'',@insuPubInfo.insuPubName:'''',@insuPubInfo.insuPubNo:'''',@insuPubInfo.insuPubPatNo:'''',@insuSetInfoFlg:'''',@insuSetInfoValue:''insu_set_info'',@insuSetInfo.insuCd:'''',@insuSetInfo.insuPub1Cd:'''',@insuSetInfo.insuPub2Cd:'''',@insuSetInfo.insuPub3Cd:'''',@insuSetInfo.insuPub4Cd:'''',@isSelected:''is_selected'',@isDisp:''is_disp'',@coopCode:''coop_code'',@isCoop:''is_coop'',@startDate:''start_date'',@endDate:''end_date'',@checkDate:''check_date'',@oldUpDate_Date:''old_up_date''}"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_insurance", "@ctlNo": "$journal.pat_insurance.ctl_no", "ctl_no": "2", "sqlCode": 1302, "@insuName": "$journal.pat_insurance.insu_name", "@insuInfo.insuNo": "$journal.pat_insurance.insu_info.insu_no"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_insurance", "@ctlNo": "$journal.pat_insurance.ctl_no", "ctl_no": "3", "sqlCode": 1303, "@insuName": "$journal.pat_insurance.insu_name", "@insuInfo.insuNo": "$journal.pat_insurance.insu_info.insu_no"}]}}', '1', '0', 4126, '2019-12-13 05:44:54', '2020-01-14 11:01:43');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4030002, 'P_hosp', 'profile', '', 'R', 'cre', 'text     ', 'パナソニック 患者プロファイル', 'Medicom', '患者プロファイル', '1', '<root name="患者情報">
    <item  name="STX" len="1" type="string"/>
    <item  name="拡張部" len="2" type="string"/>
    <item  name="電文区分" len="4" col="$journal.const.crud" type="string"  value="const:C"/>
    <item  name="ブロック区分" len="3" type="string"/>
    <item  name="予備" len="1" type="string"/>
    <item  name="データ区分" len="3" type="string"/>
    <item  name="サブ区分" len="1" type="string"/>
    <item  name="情報種別" len="1" type="string"/>
    <item  name="患者コード" len="13" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
    <item  name="患者詳細情報.主科" len="3" type="string"/>
    <item  name="患者詳細情報.外来/入院" len="1" col="$journal.pat_personal_main.in_out_class" type="string"/>
    <item  name="患者詳細情報.保険組No" len="3"  col="$journal.pat_insurance.ctl_no" type="string"/>
    <item  name="患者詳細情報.予備" len="2" type="string"/>
    <item  name="患者詳細情報.年齢区分" len="1" type="string"/>
    <item  name="患者詳細情報.所得区分" len="1" type="string"/>
    <item  name="患者詳細情報.認定区分" len="1" type="string"/>
    <item  name="患者詳細情報.医療/介護フラグ" len="1" type="string"/>
    <item  name="患者詳細情報.予備" len="13" type="string"/>
    <item  name="患者詳細情報.頭書登録順No" len="6" type="string"/>
    <item  name="最終来院年月" len="6" type="string"/>
    <item  name="カナ氏名" len="30" col="$journal.pat_personal_main.pat_last_name_kana" type="string"/>
    <item  name="氏名" len="34" col="$journal.pat_personal_main.pat_last_name" type="string"/>
    <item  name="性別" len="1" col="$journal.pat_personal_main.pat_sex" type="string"/>
    <item  name="生年元号" len="8" type="string"/>
    <item  name="生年月日" len="8" col="$journal.pat_personal_main.pat_birthday" type="string"/>
    <item  name="予備" len="1" type="string"/>
    <item  name="郵便番号" len="8" col="$journal.pat_personal_main.pat_contact_info.zip_cd" type="string"/>
    <item  name="住所（1行目_2行目）" len="88" col="$journal.pat_personal_main.pat_contact_info.address" type="string"/>
    <item  name="電話番号" len="12" col="$journal.pat_personal_main.pat_contact_info.tel" type="string"/>
    <item  name="連絡先電話番号" len="12" col="$journal.pat_personal_main.pat_contact_info.work_tel" type="string"/>
    <item  name="職業" len="14" type="string"/>
    <item  name="個人コメント（漢字）" len="44" type="string"/>
    <item  name="予備" len="1" type="string"/>
    <item  name="本人/家族" len="1" type="string"/>
    <item  name="続柄" len="10" type="string"/>
    <item  name="保険者番号" len="8" col="$journal.pat_insurance.insu_info.insu_no" type="string"/>
    <item  name="被保険者証・記号" len="44" type="string"/>
    <item  name="被保険者証・番号" len="44" type="string"/>
    <item  name="保険証有効期限" len="8" type="string"/>
    <item  name="第1公費負担者番号" len="8" type="string"/>
    <item  name="第1公費受給者番号" len="8" type="string"/>
    <item  name="第1公費有効期限" len="8" type="string"/>
    <item  name="第2公費負担者番号" len="8" type="string"/>
    <item  name="第2公費受給者番号" len="8" type="string"/>
    <item  name="第2公費有効期限" len="8" type="string"/>
    <item  name="第3公費負担者番号" len="8" type="string"/>
    <item  name="第3公費受給者番号" len="8" type="string"/>
    <item  name="第3公費有効期限" len="8" type="string"/>
    <item  name="保険名称" len="14" col="$journal.pat_insurance.insu_name" type="string"/>
    <item  name="分類A" len="4" type="string"/>
    <item  name="分類B" len="4" type="string"/>
    <item  name="分類C" len="4" type="string"/>
    <item  name="分類D" len="4" type="string"/>
    <item  name="保険区分" len="3" type="string"/>
    <item  name="予備" len="1" type="string"/>
    <item  name="ETX" len="1" type="string"/>
</root>', '{}', '1', '0', 4126, '2019-12-13 05:44:54', '2020-01-14 11:01:43');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4030003, 'P_hosp', 'profile', '', 'S', 'cre', 'text     ', 'パナソニック 患者プロファイル', 'Medicom', '患者プロファイル', '1', '<root name="患者情報要求">
    <item  name="ヘッダー部.STX" len="1" value="$STX"/>
    <item  name="ヘッダー部.拡張部" len="2" value="const:00"/>
    <item  name="ヘッダー部.電文区分" len="4" value="const:SRD0"/>
    <item  name="ヘッダー部.ブロック区分" len="3" value="const:E01"/>
    <item  name="ヘッダー部.予備" len="1" value="const: "/>
    <item  name="ヘッダー部.データ区分" len="3" value="const:A61"/>
    <item  name="ヘッダー部.サブ区分" len="1" value="const:0"/>
    <item  name="ヘッダー部.情報種別" len="1" value="const:C"/>
    <item  name="内容部患者コード" len="13" value="$JOURNAL.hosp_pat_id" />
    <item  name="内容部特定情報" len="7" value="const:       "/>
    <item  name="内容部予備" len="6" value="const:      "/>
    <item  name="ETX" len="1" value="$ETX"/>
</root>', '{}', '1', '0', -2, '2020-01-21 08:29:41.74', '2020-01-21 08:29:41.74');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4030005, 'P_hosp', 'profile', 'send_time', 'S', 'cre', 'text     ', '定時一括送信機能（パナソニック  患者プロファイル用）', 'Medicom', '患者プロファイル(定時)', '1', NULL, '{"dataset": [{"sqlCode": -2400, "facilityCd": "facilityCd", "PreSqlInfoItem": ["@ord_no", "@pat_id"]}]}', '1', '0', -2, '2020-01-21 08:29:41.74', '2020-01-21 08:29:41.74');
