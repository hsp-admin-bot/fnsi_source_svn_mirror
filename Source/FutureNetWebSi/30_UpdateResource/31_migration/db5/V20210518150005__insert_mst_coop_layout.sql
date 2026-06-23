DELETE FROM "mst_coop_layout" WHERE "ctl_no"  = -2030003;INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2030003, 'F_hosp', 'profile', '', 'R', '正常以外', 'text     ', '富士通想定患者プロファイル', 'Egmain-GX', 'テスト用', '1', '<root name="患者プロファイル(接続異常)">



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



    <item  name="患者情報.患者番号" len="10" type="string"/>



    <item  name="患者情報.患者漢字氏名" len="30" type="string"/>



    <item  name="患者情報.患者カナ氏名" len="60" type="string"/>



    <item  name="患者情報.患者性別" len="1" type="string"/>



    <item  name="患者情報.患者生年月日" len="8" type="string"/>



    <item  name="患者情報.郵便番号１" len="3" type="string"/>



    <item  name="患者情報.郵便番号２" len="4" type="string"/>



    <item  name="患者情報.患者住所" len="40" type="string"/>



    <item  name="患者情報.患者住所詳細" len="60" type="string"/>



    <item  name="患者情報.電話番号" len="15" type="string"/>



    <item  name="入院情報.入外区分" len="1" type="string"/>



    <item  name="入院情報.入院診療科コード" len="3" type="string"/>



    <item  name="入院情報.入院中病棟" len="3" type="string"/>



    <item  name="入院情報.入院中部屋" len="5" type="string"/>



    <item  name="入院情報.入院中ベッドコード" len="2" type="string"/>



    <item  name="保険情報" len="3270" type="string"/>



    <item  name="患者プロファイル情報数" len="2" type="string"/>



    <item  name="患者プロファイル" len="10593" type="string"/>



    <item  name="終端" len="1" type="string"/>



</root>



', '{}', '1', '0', -1, '2019-12-23 06:35:38', '2020-01-14 11:01:43.398');
DELETE FROM "mst_coop_layout" WHERE "ctl_no"  = -2030002;INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2030002, 'F_hosp', 'profile', '', 'R', '正常', 'text     ', '富士通想定患者プロファイル', 'Egmain-GX', 'テスト用', '1', '<root name="患者プロファイル(正常)">
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
</root>', '{}', '1', '0', -1, '2019-12-23 06:35:38', '2020-01-14 11:01:43.398');
DELETE FROM "mst_coop_layout" WHERE "ctl_no"  = -2030001;
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



</root>', '{"key": {"応答種別": {"N1": "正常以外", "N2": "正常以外", "N3": "正常以外", "N4": "正常以外", "NG": "正常以外", "OK": "正常"}}, "dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id"}, {"@tel": "$journal.pat_personal_main.pat_contact_info.tel", "crud": "C", "kind": "0", "judge": "$journal.pat_personal_main.hosp_pat_id#=#123", "table": "pat_personal_main", "@zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "ctl_no": "2", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": 1102, "@address": "$journal.pat_personal_main.pat_contact_info.address", "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "$journal.pat_personal_main.in_out_class", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_last_name", "@patLastNmKana": "$journal.pat_personal_main.pat_last_name_kana"}, {"@tel": "$journal.pat_personal_main.pat_contact_info.tel", "crud": "U", "kind": "0", "judge": "", "table": "pat_personal_main", "@zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "ctl_no": "3", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": 1103, "@address": "$journal.pat_personal_main.pat_contact_info.address", "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "$journal.pat_personal_main.in_out_class", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_last_name", "@patLastNmKana": "$journal.pat_personal_main.pat_last_name_kana"}], "sqlGroup2": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "1", "sqlCode": 1201}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "2", "@wardCd": "$journal.pat_main.medical_care_info.ward_cd", "sqlCode": 1202, "@mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "3", "@wardCd": "$journal.pat_main.medical_care_info.ward_cd", "sqlCode": 1203, "@mainCourseCd": "$journal.pat_main.medical_care_info.main_course_cd"}], "sqlGroup3": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_insurance", "@ctlNo": "$journal.detail.pat_insurance.ctl_no", "ctl_no": "1", "sqlCode": 1301}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_insurance", "@ctlNo": "$journal.detail.pat_insurance.ctl_no", "ctl_no": "2", "@insuNo": "$journal.detail.pat_insurance.insu_info.insu_no", "sqlCode": 1302, "@endDate": "$journal.detail.pat_insurance.end_date", "@futan-g": "$journal.detail.pat_insurance.insu_info.futan-g", "@futan-n": "$journal.detail.pat_insurance.insu_info.futan-n", "@insuKbn": "$journal.detail.pat_insurance.insu_info.insu_kbn", "@insuName": "$journal.detail.pat_insurance.insu_name", "@insuPubNo": "$journal.detail.pat_insurance.insu_pub_info.insu_pub_no", "@startDate": "$journal.detail.pat_insurance.start_date"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_insurance", "@ctlNo": "$journal.detail.pat_insurance.ctl_no", "ctl_no": "3", "@insuNo": "$journal.detail.pat_insurance.insu_info.insu_no", "sqlCode": 1303, "@endDate": "$journal.detail.pat_insurance.end_date", "@futan-g": "$journal.detail.pat_insurance.insu_info.futan-g", "@futan-n": "$journal.detail.pat_insurance.insu_info.futan-n", "@insuKbn": "$journal.detail.pat_insurance.insu_info.insu_kbn", "@insuName": "$journal.detail.pat_insurance.insu_name", "@insuPubNo": "$journal.detail.pat_insurance.insu_pub_info.insu_pub_no", "@startDate": "$journal.detail.pat_insurance.start_date"}], "sqlGroup4": [{"crud": "S", "kind": "0", "type": "json", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1401}, {"crud": "D", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "2", "sqlCode": 1402}, {"crud": "U", "kind": "0", "@tel1": "$journal.detail.pat_personal_main.other_contact_info.tel1", "@tel2": "$journal.detail.pat_personal_main.other_contact_info.tel2", "judge": "", "table": "pat_personal_main", "@memo1": "$journal.detail.pat_personal_main.other_contact_info.memo1", "ctl_no": "3", "sqlCode": 1403, "@lastName": "$journal.detail.pat_personal_main.other_contact_info.last_name", "@relationCd": "$journal.detail.pat_personal_main.other_contact_info.relation_cd"}], "sqlGroup5": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1501}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_personal_main", "@isDie": "$journal.detail.pat_personal_main.is_die", "ctl_no": "3", "sqlCode": 1502, "@dieDate_Date": "$journal.detail.pat_personal_main.die_date"}]}}', '1', '0', -1, '2019-12-23 06:35:38', '2020-01-14 11:01:43.398');
