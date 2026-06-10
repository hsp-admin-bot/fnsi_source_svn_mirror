DELETE FROM mst_coop_layout
WHERE ctl_no IN (-4030001,-4030002);

INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4030001, 'P_hosp', 'profile', '', 'R', 'pre', 'text', 'パナソニック 患者プロファイル', 'Medicom', '患者プロファイル', '1', '<root name="患者情報(pre)">
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
    <item  name="住所（1行目）" len="44" type="string"/>
    <item  name="住所（2行目）" len="44" type="string"/>
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
</root>', '{"key": {"shori_kbn": {"MDT0": "cre"}}, "dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"crud": "C", "kind": "0", "judge": "$journal.pat_personal_main.hosp_pat_id#=#123", "table": "pat_personal_main", "ctl_no": "2", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -303101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "$journal.pat_personal_main.in_out_class", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_last_name", "@patLastNmKana": "$journal.pat_personal_main.pat_last_name_kana", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.tel2": "$journal.pat_personal_main.pat_contact_info.tel2", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@patContactInfo.address1": "$journal.pat_personal_main.pat_contact_info.address1", "@patContactInfo.address2": "$journal.pat_personal_main.pat_contact_info.address2"}], "sqlGroup2": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "1", "sqlCode": -303002, "insertResult": "{@patId:'''',@facilityCd:'''',@patMemoInfoValue:''[]'',@additionInfoValue:''[]''}"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "2", "sqlCode": -303102}], "sqlGroup3": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_unique", "ctl_no": "1", "sqlCode": 1601, "insertResult": "{@patId:'''', @facilityCd:'''', @medicalHstInfoValue:''[]'', @inOutVisitHistoryInfoValue:''[]'', @physicalInfoFlg:'''', @physicalInfoValue:''[]''}"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_unique", "ctl_no": "2", "sqlCode": 1602}], "sqlGroup4": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_unique", "ctl_no": "1", "sqlCode": 1601}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_unique", "@isDie": "0", "ctl_no": "2", "sqlCode": 1705, "@inOutClass": "$journal.pat_personal_main.in_out_class"}], "sqlGroup5": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "3", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -303201, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@inOutClass": "$journal.pat_personal_main.in_out_class", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_last_name", "@patLastNmKana": "$journal.pat_personal_main.pat_last_name_kana", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.tel2": "$journal.pat_personal_main.pat_contact_info.tel2", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@patContactInfo.address1": "$journal.pat_personal_main.pat_contact_info.address1", "@patContactInfo.address2": "$journal.pat_personal_main.pat_contact_info.address2"}], "sqlGroup6": [{"No1": "登録・更新", "crud": "S", "kind": "0", "judge": "", "table": "pat_coop_detail", "ctl_no": "1", "sqlCode": -303004, "@save2.insuNo": "$journal.pat_coop_detail.save_2.insu_no", "@save2.insuName": "$journal.pat_coop_detail.save_2.insu_name", "@save2.insuSetNo": "$journal.pat_coop_detail.save_2.insu_set_no"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_coop_detail", "ctl_no": "2", "sqlCode": -303103, "@save2.insuNo": "$journal.pat_coop_detail.save_2.insu_no", "@save2.insuName": "$journal.pat_coop_detail.save_2.insu_name", "@save2.insuSetNo": "$journal.pat_coop_detail.save_2.insu_set_no"}]}, "CoopIniConvUtil": {"$journal.pat_personal_main.pat_sex": "CONV_SEX_TO_FNW", "$journal.pat_personal_main.in_out_class": "CONV_INOUT_TO_FNW"}}'::jsonb, '1', '0', -1, '2019-12-13 05:44:54.000', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4030002, 'P_hosp', 'profile', '', 'R', 'cre', 'text', 'パナソニック 患者プロファイル', 'Medicom', '患者プロファイル', '1', '<root name="患者情報">
  <item name="STX" len="1" type="string"/>
  <item name="拡張部" len="2" type="string"/>
  <item name="電文区分" len="4" col="$journal.const.crud" type="string" value="const:C"/>
  <item name="ブロック区分" len="3" type="string"/>
  <item name="予備" len="1" type="string"/>
  <item name="データ区分" len="3" type="string"/>
  <item name="サブ区分" len="1" type="string"/>
  <item name="情報種別" len="1" type="string"/>
  <item name="患者コード" len="13" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
  <item name="患者詳細情報.主科" len="3" type="string"/>
  <item name="患者詳細情報.外来/入院" len="1" col="$journal.pat_personal_main.in_out_class" type="string"/>
  <item name="患者詳細情報.保険組No" len="3" col="$journal.pat_coop_detail.save_2.insu_set_no" type="string"/>
  <item name="患者詳細情報.予備" len="2" type="string"/>
  <item name="患者詳細情報.年齢区分" len="1" type="string"/>
  <item name="患者詳細情報.所得区分" len="1" type="string"/>
  <item name="患者詳細情報.認定区分" len="1" type="string"/>
  <item name="患者詳細情報.医療/介護フラグ" len="1" type="string"/>
  <item name="患者詳細情報.予備" len="13" type="string"/>
  <item name="患者詳細情報.頭書登録順No" len="6" type="string"/>
  <item name="最終来院年月" len="6" type="string"/>
  <item name="カナ氏名" len="30" col="$journal.pat_personal_main.pat_last_name_kana" type="string"/>
  <item name="氏名" len="34" col="$journal.pat_personal_main.pat_last_name" type="string"/>
  <item name="性別" len="1" col="$journal.pat_personal_main.pat_sex" type="string"/>
  <item name="生年元号" len="8" type="string"/>
  <item name="生年月日" len="8" col="$journal.pat_personal_main.pat_birthday" type="string"/>
  <item name="予備" len="1" type="string"/>
  <item name="郵便番号" len="8" col="$journal.pat_personal_main.pat_contact_info.zip_cd" type="string"/>
  <item name="住所（1行目）" len="44" col="$journal.pat_personal_main.pat_contact_info.address1" type="string"/>
  <item name="住所（2行目）" len="44" col="$journal.pat_personal_main.pat_contact_info.address2" type="string"/>
  <item name="電話番号" len="12" col="$journal.pat_personal_main.pat_contact_info.tel1" type="string"/>
  <item name="連絡先電話番号" len="12" col="$journal.pat_personal_main.pat_contact_info.tel2" type="string"/>
  <item name="職業" len="14" type="string"/>
  <item name="個人コメント（漢字）" len="44" type="string"/>
  <item name="予備" len="1" type="string"/>
  <item name="本人/家族" len="1" type="string"/>
  <item name="続柄" len="10" type="string"/>
  <item name="保険者番号" len="8" col="$journal.pat_coop_detail.save_2.insu_no" type="string"/>
  <item name="被保険者証・記号" len="44" type="string"/>
  <item name="被保険者証・番号" len="44" type="string"/>
  <item name="保険証有効期限" len="8" type="string"/>
  <item name="第1公費負担者番号" len="8" type="string"/>
  <item name="第1公費受給者番号" len="8" type="string"/>
  <item name="第1公費有効期限" len="8" type="string"/>
  <item name="第2公費負担者番号" len="8" type="string"/>
  <item name="第2公費受給者番号" len="8" type="string"/>
  <item name="第2公費有効期限" len="8" type="string"/>
  <item name="第3公費負担者番号" len="8" type="string"/>
  <item name="第3公費受給者番号" len="8" type="string"/>
  <item name="第3公費有効期限" len="8" type="string"/>
  <item name="保険名称" len="14" col="$journal.pat_coop_detail.save_2.insu_name" type="string"/>
  <item name="分類A" len="4" type="string"/>
  <item name="分類B" len="4" type="string"/>
  <item name="分類C" len="4" type="string"/>
  <item name="分類D" len="4" type="string"/>
  <item name="保険区分" len="3" type="string"/>
  <item name="予備" len="1" type="string"/>
  <item name="ETX" len="1" type="string"/>
</root>
', '{}'::jsonb, '1', '0', -1, '2019-12-13 05:44:54.000', CURRENT_TIMESTAMP, 'MED');