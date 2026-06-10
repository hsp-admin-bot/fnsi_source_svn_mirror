DELETE FROM ntss.mst_coop_layout
WHERE ctl_no IN (-4030001, -4030002, -4030003, -4030005, -4060001, -4060002, -4060003, -4061001, -4090001, -4090002, -4090003, -4090004, -4100001, -4100002, -4100003, -4170001, -4170002);

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
</root>', '{"key": {"shori_kbn": {"MDT0": "cre"}}, "dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"crud": "C", "kind": "0", "judge": "$journal.pat_personal_main.hosp_pat_id#=#123", "table": "pat_personal_main", "ctl_no": "2", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -303101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_last_name", "@patLastNmKana": "$journal.pat_personal_main.pat_last_name_kana", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.tel2": "$journal.pat_personal_main.pat_contact_info.tel2", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@patContactInfo.address1": "$journal.pat_personal_main.pat_contact_info.address1", "@patContactInfo.address2": "$journal.pat_personal_main.pat_contact_info.address2"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "3", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -303201, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_last_name", "@patLastNmKana": "$journal.pat_personal_main.pat_last_name_kana", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.tel2": "$journal.pat_personal_main.pat_contact_info.tel2", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@patContactInfo.address1": "$journal.pat_personal_main.pat_contact_info.address1", "@patContactInfo.address2": "$journal.pat_personal_main.pat_contact_info.address2"}], "sqlGroup2": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "1", "sqlCode": -303002, "insertResult": "{@patId:'''',@facilityCd:'''',@patMemoInfoValue:''[]'',@additionInfoValue:''[]''}"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_main", "ctl_no": "2", "sqlCode": -303102}], "sqlGroup3": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_unique", "ctl_no": "1", "sqlCode": 1601, "insertResult": "{@patId:'''', @facilityCd:'''', @medicalHstInfoValue:''[]'', @inOutVisitHistoryInfoValue:''[]'', @physicalInfoFlg:'''', @physicalInfoValue:''[]''}"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_unique", "ctl_no": "2", "sqlCode": 1602}], "sqlGroup4": [{"No1": "登録・更新", "crud": "S", "kind": "0", "judge": "", "table": "pat_coop_detail", "ctl_no": "1", "sqlCode": -303004, "@save2.insuNo": "$journal.pat_coop_detail.save_2.insu_no", "@save2.insuName": "$journal.pat_coop_detail.save_2.insu_name", "@save2.insuSetNo": "$journal.pat_coop_detail.save_2.insu_set_no"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_coop_detail", "ctl_no": "2", "sqlCode": -303103, "@save2.insuNo": "$journal.pat_coop_detail.save_2.insu_no", "@save2.insuName": "$journal.pat_coop_detail.save_2.insu_name", "@save2.insuSetNo": "$journal.pat_coop_detail.save_2.insu_set_no"}]}}'::jsonb, '1', '0', -1, '2019-12-13 05:44:54.000', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4030002, 'P_hosp', 'profile', '', 'R', 'cre', 'text', 'パナソニック 患者プロファイル', 'Medicom', '患者プロファイル', '1', '<root name="患者情報">
    <item  name="STX" len="1" type="string"/>
    <item  name="拡張部" len="2" type="string"/>
    <item  name="電文区分" len="4" col="$journal.const.crud" type="string" value="const:C"/>
    <item  name="ブロック区分" len="3" type="string"/>
    <item  name="予備" len="1" type="string"/>
    <item  name="データ区分" len="3" type="string"/>
    <item  name="サブ区分" len="1" type="string"/>
    <item  name="情報種別" len="1" type="string"/>
    <item  name="患者コード" len="13" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
    <item  name="患者詳細情報.主科" len="3" type="string"/>
    <item  name="患者詳細情報.外来/入院" len="1" type="string"/>
    <item  name="患者詳細情報.保険組No" len="3"  col="$journal.pat_coop_detail.save_2.insu_set_no" type="string"/>
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
    <item  name="住所（1行目）" len="44" col="$journal.pat_personal_main.pat_contact_info.address1" type="string"/>
    <item  name="住所（2行目）" len="44" col="$journal.pat_personal_main.pat_contact_info.address2" type="string"/>
    <item  name="電話番号" len="12" col="$journal.pat_personal_main.pat_contact_info.tel1" type="string"/>
    <item  name="連絡先電話番号" len="12" col="$journal.pat_personal_main.pat_contact_info.tel2" type="string"/>
    <item  name="職業" len="14" type="string"/>
    <item  name="個人コメント（漢字）" len="44" type="string"/>
    <item  name="予備" len="1" type="string"/>
    <item  name="本人/家族" len="1" type="string"/>
    <item  name="続柄" len="10" type="string"/>
    <item  name="保険者番号" len="8" col="$journal.pat_coop_detail.save_2.insu_no" type="string"/>
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
    <item  name="保険名称" len="14" col="$journal.pat_coop_detail.save_2.insu_name" type="string"/>
    <item  name="分類A" len="4" type="string"/>
    <item  name="分類B" len="4" type="string"/>
    <item  name="分類C" len="4" type="string"/>
    <item  name="分類D" len="4" type="string"/>
    <item  name="保険区分" len="3" type="string"/>
    <item  name="予備" len="1" type="string"/>
    <item  name="ETX" len="1" type="string"/>
</root>', '{}'::jsonb, '1', '0', -1, '2019-12-13 05:44:54.000', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4030003, 'P_hosp', 'profile', '', 'S', 'cre', 'text', 'パナソニック 患者プロファイル', 'Medicom', '患者プロファイル', '1', '<root name="患者情報要求">
    <item  name="ヘッダー部.STX" len="1" value="$STX"/>
    <item  name="ヘッダー部.拡張部" len="2" value="const:00"/>
    <item  name="ヘッダー部.電文区分" len="4" value="const:SRD0"/>
    <item  name="ヘッダー部.ブロック区分" len="3" value="const:E01"/>
    <item  name="ヘッダー部.予備" len="1" value="$BLANK"/>
    <item  name="ヘッダー部.データ区分" len="3" value="const:A61"/>
    <item  name="ヘッダー部.サブ区分" len="1" value="const:0"/>
    <item  name="ヘッダー部.情報種別" len="1" value="const:C"/>
    <item  name="内容部患者コード" len="13" value="$JOURNAL.hosp_pat_id" />
    <item  name="内容部特定情報" len="7" value="$BLANK"/>
    <item  name="内容部予備" len="6" value="$BLANK"/>
    <item  name="ETX" len="1" value="$ETX"/>
</root>', '{}'::jsonb, '1', '0', -1, '2020-01-21 08:29:41.740', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4030005, 'P_hosp', 'profile', 'send_time', 'S', 'cre', 'text', '定時一括送信機能（パナソニック  患者プロファイル用）', 'Medicom', '患者プロファイル(定時)', '1', '<rootnode></rootnode>', '{"dataset": [{"sqlCode": -2400, "facilityCd": "facilityCd", "PreSqlInfoItem": ["@ord_no", "@pat_id"]}]}'::jsonb, '1', '0', -1, '2020-01-21 08:29:41.740', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4060001, 'P_hosp', 'accept', '', 'S', 'cre', 'text', 'パナソニック 受付情報', 'Medicom', '受付情報', '1', '<root name="再来受付">
  <item name="再受機No" len="2" value="dataset:-457.reconnection"/>
  <item name="患者コード" len="13" value="dataset:-306001.hosp_pat_id"/>
  <item name="保険種別" len="3" value="$BLANK"/>
  <item name="外/入" len="1" value="const:1"/>
  <item name="初/再" len="1" value="const:2"/>
  <item name="来院理由" len="4" value="dataset:-457.in_hosptial_reason"/>
  <item name="初回来院" len="1" value="$BLANK"/>
  <item name="保険追加" len="1" value="$BLANK"/>
  <item name="頭書修正" len="1" value="$BLANK"/>
  <item name="予備" len="1" value="$BLANK"/>
  <item name="予約/緊急" len="1" value="$BLANK"/>
  <item name="医師１" len="4" value="dataset:-306103.staff_cd"/>
  <item name="予備" len="4" value="$BLANK"/>
  <item name="予備" len="4" value="$BLANK"/>
  <item name="予備" len="4" value="$BLANK"/>
  <item name="処理フラグ" len="1" value="$BLANK"/>
  <item name="当日外フラグ" len="1" value="$BLANK"/>
  <item name="抹消フラグ" len="1" value="$BLANK"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="受付処理.年" len="4" value="dataset:-456.date_year"/>
  <item name="受付処理.月日" len="4" value="dataset:-456.date_month_day"/>
  <item name="受付時間" len="6" value="dataset:-456.date_time"/>
  <item name="コメント" len="40" value="dataset:-306101.comment" padding_format="fblank" padding_position="right" subMode="L"/>
  <item name="受診科１" len="3" value="dataset:-456.in_hospital_cd"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="主科" len="3" value="$BLANK"/>
  <item name="受付番号種別" len="1" value="const:K"/>
  <item name="受付番号" len="4" value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="予約年月日" len="8" value="dataset:-1001.treat_date"/>
  <item name="予約時間" len="4" value="dataset:-1001.ind_treat_start_time"/>
  <item name="予備" len="20" value="$BLANK"/>
  <item name="終端" len="1" value="$CR"/>
  <item name="終端" len="1" value="$LF"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -306001}, {"patId": "patId", "sqlCode": -455}, {"ordNo": "ordNo", "sqlCode": -456, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -457, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1001, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -306101, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -306103, "facilityCd": "facilityCd"}], "dumpFileName": {"patId": "patId", "sqlCode": -306102}}'::jsonb, '1', '0', 5843, '2025-03-07 12:00:13.562', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4060002, 'P_hosp', 'accept', '', 'S', 'upd', 'text', 'パナソニック 受付情報', 'Medicom', '受付情報', '1', '<root name="再来受付">
  <item name="再受機No" len="2" value="dataset:-457.reconnection"/>
  <item name="患者コード" len="13" value="dataset:-306001.hosp_pat_id"/>
  <item name="保険種別" len="3" value="$BLANK"/>
  <item name="外/入" len="1" value="const:1"/>
  <item name="初/再" len="1" value="const:2"/>
  <item name="来院理由" len="4" value="dataset:-457.in_hosptial_reason"/>
  <item name="初回来院" len="1" value="$BLANK"/>
  <item name="保険追加" len="1" value="$BLANK"/>
  <item name="頭書修正" len="1" value="$BLANK"/>
  <item name="予備" len="1" value="$BLANK"/>
  <item name="予約/緊急" len="1" value="$BLANK"/>
  <item name="医師１" len="4" value="dataset:-457.staff_cd"/>
  <item name="予備" len="4" value="$BLANK"/>
  <item name="予備" len="4" value="$BLANK"/>
  <item name="予備" len="4" value="$BLANK"/>
  <item name="処理フラグ" len="1" value="$BLANK"/>
  <item name="当日外フラグ" len="1" value="$BLANK"/>
  <item name="抹消フラグ" len="1" value="$BLANK"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="受付処理.年" len="4" value="dataset:-456.date_year"/>
  <item name="受付処理.月日" len="4" value="dataset:-456.date_month_day"/>
  <item name="受付時間" len="6" value="dataset:-456.date_time"/>
  <item name="コメント" len="40" value="dataset:-455.comment" padding_format="fblank" padding_position="right" subMode="L"/>
  <item name="受診科１" len="3" value="dataset:-456.in_hospital_cd"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="主科" len="3" value="$BLANK"/>
  <item name="受付番号種別" len="1" value="const:K"/>
  <item name="受付番号" len="4" value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="予約年月日" len="8" value="dataset:-1001.treat_date"/>
  <item name="予約時間" len="4" value="dataset:-1001.ind_treat_start_time"/>
  <item name="予備" len="20" value="$BLANK"/>
  <item name="終端" len="1" value="$CR"/>
  <item name="終端" len="1" value="$LF"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -306001}, {"patId": "patId", "sqlCode": -455}, {"ordNo": "ordNo", "sqlCode": -456, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -457, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1001, "facilityCd": "facilityCd"}], "dumpFileName": {"patId": "patId", "sqlCode": -99998}}'::jsonb, '1', '0', 5843, '2025-03-07 12:00:13.562', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4060003, 'P_hosp', 'accept', '', 'S', 'del', 'text', 'パナソニック 受付情報', 'Medicom', '受付情報', '1', '<root name="再来受付">
  <item name="再受機No" len="2" value="dataset:-457.reconnection"/>
  <item name="患者コード" len="13" value="dataset:-306001.hosp_pat_id"/>
  <item name="保険種別" len="3" value="$BLANK"/>
  <item name="外/入" len="1" value="const:1"/>
  <item name="初/再" len="1" value="const:2"/>
  <item name="来院理由" len="4" value="dataset:-457.in_hosptial_reason"/>
  <item name="初回来院" len="1" value="$BLANK"/>
  <item name="保険追加" len="1" value="$BLANK"/>
  <item name="頭書修正" len="1" value="$BLANK"/>
  <item name="予備" len="1" value="$BLANK"/>
  <item name="予約/緊急" len="1" value="$BLANK"/>
  <item name="医師１" len="4" value="dataset:-457.staff_cd"/>
  <item name="予備" len="4" value="$BLANK"/>
  <item name="予備" len="4" value="$BLANK"/>
  <item name="予備" len="4" value="$BLANK"/>
  <item name="処理フラグ" len="1" value="$BLANK"/>
  <item name="当日外フラグ" len="1" value="$BLANK"/>
  <item name="抹消フラグ" len="1" value="$BLANK"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="受付処理.年" len="4" value="dataset:-456.date_year"/>
  <item name="受付処理.月日" len="4" value="dataset:-456.date_month_day"/>
  <item name="受付時間" len="6" value="dataset:-456.date_time"/>
  <item name="コメント" len="40" value="dataset:-455.comment" padding_format="fblank" padding_position="right" subMode="L"/>
  <item name="受診科１" len="3" value="dataset:-456.in_hospital_cd"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="主科" len="3" value="$BLANK"/>
  <item name="受付番号種別" len="1" value="const:K"/>
  <item name="受付番号" len="4" value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="予約年月日" len="8" value="dataset:-1001.treat_date"/>
  <item name="予約時間" len="4" value="dataset:-1001.ind_treat_start_time"/>
  <item name="予備" len="20" value="$BLANK"/>
  <item name="終端" len="1" value="$CR"/>
  <item name="終端" len="1" value="$LF"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -306001}, {"patId": "patId", "sqlCode": -455}, {"ordNo": "ordNo", "sqlCode": -456, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -457, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1001, "facilityCd": "facilityCd"}], "dumpFileName": {"patId": "patId", "sqlCode": -99998}}'::jsonb, '1', '0', 5843, '2025-03-07 12:00:13.562', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4061001, 'P_hosp', 'accept', '', 'S', 'cre', 'text', 'パナソニック 受付情報', 'Medicom', '受付情報', '1', '<root name="再来受付">
    <item  name="再受機No" len="2" value="dataset:-457.reconnection"/>
    <item  name="患者コード" len="13" value="dataset:-306001.hosp_pat_id"/>
    <item  name="保険種別" len="3" value="$BLANK"/>
    <item  name="外/入" len="1" value="const:1"/>
    <item  name="初/再" len="1" value="const:2"/>
    <item  name="来院理由" len="4" value="dataset:-457.in_hosptial_reason"/>
    <item  name="初回来院" len="1" value="$BLANK"/>
    <item  name="保険追加" len="1" value="$BLANK"/>
    <item  name="頭書修正" len="1" value="$BLANK"/>
    <item  name="予備" len="1" value="$BLANK"/>
    <item  name="予約/緊急" len="1" value="$BLANK"/>
    <item  name="医師１" len="4" value="dataset:-306103.staff_cd"/>
    <item  name="予備" len="4" value="$BLANK"/>
    <item  name="予備" len="4" value="$BLANK"/>
    <item  name="予備" len="4" value="$BLANK"/>
    <item  name="処理フラグ" len="1" value="$BLANK"/>
    <item  name="当日外フラグ" len="1" value="$BLANK"/>
    <item  name="抹消フラグ" len="1" value="$BLANK"/>
    <item  name="予備" len="3" value="$BLANK"/>
    <item  name="受付処理.年" len="4" value="dataset:-456.date_year"/>
    <item  name="受付処理.月日" len="4" value="dataset:-456.date_month_day"/>
    <item  name="受付時間" len="6" value="dataset:-456.date_time"/>
    <item  name="コメント" len="40" value="dataset:-306101.comment" padding_format="fblank" padding_position="right" subMode="L"/>
    <item  name="受診科１" len="3" value="dataset:-456.in_hospital_cd"/>
    <item  name="予備" len="3" value="$BLANK"/>
    <item  name="予備" len="3" value="$BLANK"/>
    <item  name="予備" len="3" value="$BLANK"/>
    <item  name="主科" len="3" value="$BLANK"/>
    <item  name="受付番号種別" len="1" value="const:K"/>
    <item  name="受付番号" len="4"  value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/>
    <item  name="予備" len="3" value="$BLANK"/>
    <item  name="予約年月日" len="8" value="dataset:-1001.treat_date"/>
    <item  name="予約時間" len="4" value="dataset:-1001.kur_standard_start_time"/>
    <item  name="予備" len="20" value="$BLANK"/>
    <item  name="終端" len="1" value="$CR"/>
    <item  name="終端" len="1" value="$LF"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -306001}, {"patId": "patId", "sqlCode": -455}, {"ordNo": "ordNo", "sqlCode": -456, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -457, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -1001}], "dumpFileName": {"patId": "patId", "sqlCode": -306102}}'::jsonb, '1', '0', -2, '2020-03-17 16:25:14.394', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4090001, 'P_hosp', 'exam_rst', '', 'R', 'pre', 'text', 'パナソニック 検査結果', 'Medicom', '検査結果受信（新版）', '1', '<root name="検査結果（新版）" multi="true:CRLF/LFCR/CR/LF">
    <item  name="レコード区分" len="2" type="string"  key="exam_kbn"/>
    <item  name="センターコード" len="6" type="string"/>
    <item  name="カルテNo." len="10" type="string"/>
    <item  name="外来･入院" len="1" type="string"/>
    <item  name="透析情報" len="1" type="string"/>
    <item  name="空白" len="28" type="string"/>
    <item  name="患者名" len="20" type="string"/>
    <item  name="報告状況" len="1" type="string"/>
    <item  name="乳ビ" len="3" type="string"/>
    <item  name="溶血" len="3" type="string"/>
    <item  name="ビリルビン" len="3" type="string"/>
    <occ  name="検査結果情報" len="0" repeat="5" detail="検査結果"/>
    <item  name="採取日" len="10" type="string"/>
    <item  name="異常値有無" len="1" type="string"/>
    <item  name="異常値1" len="1" type="string"/>
    <item  name="異常値2" len="1" type="string"/>
    <item  name="異常値3" len="1" type="string"/>
    <item  name="異常値4" len="1" type="string"/>
    <item  name="異常値5" len="1" type="string"/>
    <item  name="空白" len="2" type="string"/>
</root>', '{"key": {"exam_kbn": {"A1": "検査結果"}}, "dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}], "sqlGroup2": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": -309001, "ExceptionMessage": "[検査結果情報連携]【失敗】 採取日が未設定です。", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "ExceptionCondition": "=1"}], "sqlGroup3": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": -309002, "@centerCode": "$journal.pat_exam_main.center_code", "ExceptionMessage": "[検査結果情報連携]【対象外】センターコードが対象外です。", "ExceptionCondition": "=0"}], "sqlGroup4": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 6101, "insertResult": "{@examMainCd:'''', @patId:'''', @facilityCd:'''', @ordNo:'''', @fnPatId:'''', @regExamDate_Date:'''', @regOrderClass:'''', @examStatus:''1'', @orderComment:'''', @orderExamSetInfoValue:''[]'', @examOrderInfoValue:''[]'', @orderLabelInfoValue:''[]'', @dataGenClass:''2'', @resultExamDate_Date:'''', @resultComment:'''', @examResultInfoValue:''[]'', @copOrderNo1:'''', @copOrderNo2:'''', @isLock:''1'', @indUserId:'''', @isDel:'''', @regDate:'''', @regStaff:'''', @upDate:'''', @upStaff:'''', @isOrder:'''', @examWeek:'''', @examFrom:'''', @examTo:'''', @examPattern:''''}", "updateResult": "{@examMainCd:''exam_main_cd'', @patId:''pat_id'', @facilityCd:''facility_cd'', @ordNo:''ord_no'', @fnPatId:''fn_pat_id'', @regExamDate_Date:''reg_exam_date'', @regOrderClass:''reg_order_class'', @examStatus:''exam_status'', @orderComment:''order_comment'', @orderExamSetInfoValue:''order_exam_set_info'', @examOrderInfoValue:''exam_order_info'', @orderLabelInfoValue:''order_label_info'', @dataGenClass:''data_gen_class'', @resultExamDate_Date:''result_exam_date'', @resultComment:''result_comment'', @examResultInfoValue:''exam_result_info'', @copOrderNo1:''cop_order_no1'', @copOrderNo2:''cop_order_no2'', @isLock:''is_lock'', @indUserId:''ind_user_id'', @isDel:''is_del'', @regDate:''reg_date'', @regStaff:''reg_staff'', @upDate:''up_date'', @upStaff:''up_staff'', @isOrder:''is_order'', @examWeek:''exam_week'', @examFrom:''exam_from'', @examTo:''exam_to'', @examPattern:''exam_pattern'', }", "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@resultComment1": "$journal.pat_exam_main.result_comment1", "@resultComment2": "$journal.pat_exam_main.result_comment2", "@resultComment3": "$journal.pat_exam_main.result_comment3", "@resultComment4": "$journal.pat_exam_main.result_comment4", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": -309101, "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@resultComment1": "$journal.pat_exam_main.result_comment1", "@resultComment2": "$journal.pat_exam_main.result_comment2", "@resultComment3": "$journal.pat_exam_main.result_comment3", "@resultComment4": "$journal.pat_exam_main.result_comment4", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "3", "sqlCode": 6103, "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@resultComment1": "$journal.pat_exam_main.result_comment1", "@resultComment2": "$journal.pat_exam_main.result_comment2", "@resultComment3": "$journal.pat_exam_main.result_comment3", "@resultComment4": "$journal.pat_exam_main.result_comment4", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}], "sqlGroup5": [{"crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 6101, "updateResult": "{@nextDispOrder:''next_disp_order'', @examMainCd:''exam_main_cd'', @examResultInfoFlg:'''',@examResultInfoValue:''exam_result_info'',@examResultInfo.comCd:'''', @examResultInfo.dispOrder:'''', @examResultInfo.examClass:'''', @examResultInfo.freememo:'''', @examResultInfo.hl:'''', @examResultInfo.itemCd:'''', @examResultInfo.itemName:'''', @examResultInfo.jlac10Cd:'''', @examResultInfo.lower:'''', @examResultInfo.result:'''', @examResultInfo.resultDate:'''', @examResultInfo.type:'''', @examResultInfo.unit:'''', @examResultInfo.upper:''''}", "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}, {"Note": "json場合、[D]の設定が必要です。しかし、CSIの検査結果をクリアしません。judgeに[crud#=#NG]woを設定する。", "crud": "D", "kind": "1", "judge": "$journal.const.crud#=#NG", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": 6201}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "3", "sqlCode": 6202, "@examResultInfo.hl": "$journal.detail.pat_exam_main.exam_result_info.hl", "@examResultInfo.comCd1": "$journal.detail.pat_exam_main.exam_result_info.com_cd1", "@examResultInfo.comCd2": "$journal.detail.pat_exam_main.exam_result_info.com_cd2", "@examResultInfo.itemCd": "$journal.detail.pat_exam_main.exam_result_info.item_cd", "@examResultInfo.result": "$journal.detail.pat_exam_main.exam_result_info.result"}]}}'::jsonb, '1', '0', -1, '2020-05-26 11:07:41.699', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4090002, 'P_hosp', 'exam_rst', '', 'R', '検査結果', 'text', 'パナソニック 検査結果', 'Medicom', '検査結果受信（新版）', '1', '<root name="検査結果（新版）" multi="true:CRLF/LFCR/CR/LF">
  <item name="レコード区分" len="2" type="string" col="$journal.const.crud" value="const:C"/>
  <item name="センターコード" len="6" col="$journal.pat_exam_main.center_code" type="string"/>
  <item name="カルテNo." len="10" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
  <item name="外来･入院" len="1" type="string"/>
  <item name="透析情報" len="1" col="$journal.pat_exam_main.reg_order_class" type="string"/>
  <item name="空白" len="28" type="string"/>
  <item name="患者名" len="20" type="string"/>
  <item name="報告状況" len="1" type="string"/>
  <item name="乳ビ" len="3" type="string"/>
  <item name="溶血" len="3" type="string"/>
  <item name="ビリルビン" len="3" type="string"/>
  <occ name="検査結果情報" len="0" repeat="5" detail="検査結果"/>
  <item name="採取日" len="10" col="$journal.pat_exam_main.result_exam_date" type="string"/>
  <item name="異常値有無" len="1" type="string"/>
  <item name="異常値1" len="1" col="$journal.pat_exam_main.result_comment1" type="string"/>
  <item name="異常値2" len="1" col="$journal.pat_exam_main.result_comment2" type="string"/>
  <item name="異常値3" len="1" col="$journal.pat_exam_main.result_comment3" type="string"/>
  <item name="異常値4" len="1" col="$journal.pat_exam_main.result_comment4" type="string"/>
  <item name="異常値5" len="1" col="$journal.pat_exam_main.result_comment5" type="string"/>
  <item name="空白" len="2" type="string"/>
</root>
', '{}'::jsonb, '1', '0', -1, '2020-05-26 11:07:45.331', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4090003, 'P_hosp', 'exam_rst', '', 'R', 'pre', 'text', 'パナソニック 検査結果', 'Medicom', '検査結果受信（旧版）', '1', '<root name="検査結果（旧版）" multi="true:CRLF/LFCR/CR/LF">
    <item  name="レコード区分" len="2" type="string"  key="exam_kbn"/>
    <item  name="センターコード" len="6" type="string"/>
    <item  name="カルテNo." len="10" type="string"/>
    <item  name="外来･入院" len="1" type="string"/>
    <item  name="空白" len="29" type="string"/>
    <item  name="患者名" len="20" type="string"/>
    <item  name="報告状況" len="1" type="string"/>
    <item  name="乳ビ" len="3" type="string"/>
    <item  name="溶血" len="3" type="string"/>
    <item  name="ビリルビン" len="3" type="string"/>
    <occ  name="検査結果情報" len="0" repeat="5" detail="検査結果"/>
    <item  name="採取日" len="8" type="string"/>
    <item  name="透析情報1" len="1" type="string"/>
    <item  name="透析情報2" len="1" type="string"/>
    <item  name="異常値有無" len="1" type="string"/>
    <item  name="異常値1" len="1" type="string"/>
    <item  name="異常値2" len="1" type="string"/>
    <item  name="異常値3" len="1" type="string"/>
    <item  name="異常値4" len="1" type="string"/>
    <item  name="異常値5" len="1" type="string"/>
    <item  name="空白" len="2" type="string"/>
</root>', '{"key": {"exam_kbn": {"A1": "検査結果"}}, "dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}], "sqlGroup2": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 6101, "insertResult": "{@examMainCd:'''', @patId:'''', @facilityCd:'''', @ordNo:'''', @fnPatId:'''', @regExamDate_Date:'''', @regOrderClass:'''', @examStatus:''1'', @orderComment:'''', @orderExamSetInfoValue:''[]'', @examOrderInfoValue:''[]'', @orderLabelInfoValue:''[]'', @dataGenClass:''2'', @resultExamDate_Date:'''', @resultComment:'''', @examResultInfoValue:''[]'', @copOrderNo1:'''', @copOrderNo2:'''', @isLock:''1'', @indUserId:'''', @isDel:'''', @regDate:'''', @regStaff:'''', @upDate:'''', @upStaff:'''', @isOrder:'''', @examWeek:'''', @examFrom:'''', @examTo:'''', @examPattern:''''}", "updateResult": "{@examMainCd:''exam_main_cd'', @patId:''pat_id'', @facilityCd:''facility_cd'', @ordNo:''ord_no'', @fnPatId:''fn_pat_id'', @regExamDate_Date:''reg_exam_date'', @regOrderClass:''reg_order_class'', @examStatus:''exam_status'', @orderComment:''order_comment'', @orderExamSetInfoValue:''order_exam_set_info'', @examOrderInfoValue:''exam_order_info'', @orderLabelInfoValue:''order_label_info'', @dataGenClass:''data_gen_class'', @resultExamDate_Date:''result_exam_date'', @resultComment:''result_comment'', @examResultInfoValue:''exam_result_info'', @copOrderNo1:''cop_order_no1'', @copOrderNo2:''cop_order_no2'', @isLock:''is_lock'', @indUserId:''ind_user_id'', @isDel:''is_del'', @regDate:''reg_date'', @regStaff:''reg_staff'', @upDate:''up_date'', @upStaff:''up_staff'', @isOrder:''is_order'', @examWeek:''exam_week'', @examFrom:''exam_from'', @examTo:''exam_to'', @examPattern:''exam_pattern'', }", "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@resultComment1": "$journal.pat_exam_main.result_comment1", "@resultComment2": "$journal.pat_exam_main.result_comment2", "@resultComment3": "$journal.pat_exam_main.result_comment3", "@resultComment4": "$journal.pat_exam_main.result_comment4", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": -309101, "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@resultComment1": "$journal.pat_exam_main.result_comment1", "@resultComment2": "$journal.pat_exam_main.result_comment2", "@resultComment3": "$journal.pat_exam_main.result_comment3", "@resultComment4": "$journal.pat_exam_main.result_comment4", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "3", "sqlCode": 6103, "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@resultComment1": "$journal.pat_exam_main.result_comment1", "@resultComment2": "$journal.pat_exam_main.result_comment2", "@resultComment3": "$journal.pat_exam_main.result_comment3", "@resultComment4": "$journal.pat_exam_main.result_comment4", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}], "sqlGroup3": [{"crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 6101, "updateResult": "{@nextDispOrder:''next_disp_order'', @examMainCd:''exam_main_cd'', @examResultInfoFlg:'''',@examResultInfoValue:''exam_result_info'',@examResultInfo.comCd:'''', @examResultInfo.dispOrder:'''', @examResultInfo.examClass:'''', @examResultInfo.freememo:'''', @examResultInfo.hl:'''', @examResultInfo.itemCd:'''', @examResultInfo.itemName:'''', @examResultInfo.jlac10Cd:'''', @examResultInfo.lower:'''', @examResultInfo.result:'''', @examResultInfo.resultDate:'''', @examResultInfo.type:'''', @examResultInfo.unit:'''', @examResultInfo.upper:''''}", "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}, {"Note": "json場合、[D]の設定が必要です。しかし、CSIの検査結果をクリアしません。judgeに[crud#=#NG]woを設定する。", "crud": "D", "kind": "1", "judge": "$journal.const.crud#=#NG", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": 6201}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "3", "sqlCode": 6202, "@examResultInfo.hl": "$journal.detail.pat_exam_main.exam_result_info.hl", "@examResultInfo.comCd1": "$journal.detail.pat_exam_main.exam_result_info.com_cd1", "@examResultInfo.comCd2": "$journal.detail.pat_exam_main.exam_result_info.com_cd2", "@examResultInfo.itemCd": "$journal.detail.pat_exam_main.exam_result_info.item_cd", "@examResultInfo.result": "$journal.detail.pat_exam_main.exam_result_info.result"}]}}'::jsonb, '1', '1', 4, '2020-05-26 11:07:41.699', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4090004, 'P_hosp', 'exam_rst', '', 'R', '検査結果', 'text', 'パナソニック 検査結果', 'Medicom', '検査結果受信（旧版）', '1', '<root name="検査結果（旧版）" multi="true:CRLF/LFCR/CR/LF">
    <item  name="レコード区分" len="2" type="string" col="$journal.const.crud" value="const:C"/>
    <item  name="センターコード" len="6" type="string"/>
    <item  name="カルテNo." len="10" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
    <item  name="外来･入院" len="1" type="string"/>
    <item  name="空白" len="29" type="string"/>
    <item  name="患者名" len="20" type="string"/>
    <item  name="報告状況" len="1" type="string"/>
    <item  name="乳ビ" len="3" type="string"/>
    <item  name="溶血" len="3" type="string"/>
    <item  name="ビリルビン" len="3" type="string"/>
    <occ  name="検査結果情報" len="0" repeat="5" detail="検査結果"/>
    <item  name="採取日" len="8" col="$journal.pat_exam_main.result_exam_date" type="string"/>
    <item  name="透析情報1" len="1" type="string"/>
    <item  name="透析情報2" len="1" col="$journal.pat_exam_main.reg_order_class" type="string"/>
    <item  name="異常値有無" len="1" type="string"/>
    <item  name="異常値1" len="1" col="$journal.pat_exam_main.result_comment1" type="string"/>
    <item  name="異常値2" len="1" col="$journal.pat_exam_main.result_comment2" type="string"/>
    <item  name="異常値3" len="1" col="$journal.pat_exam_main.result_comment3" type="string"/>
    <item  name="異常値4" len="1" col="$journal.pat_exam_main.result_comment4" type="string"/>
    <item  name="異常値5" len="1" col="$journal.pat_exam_main.result_comment5" type="string"/>
    <item  name="空白" len="2" type="string"/>
</root>', '{}'::jsonb, '1', '1', 4, '2020-05-26 11:07:45.331', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4100001, 'P_hosp', 'exam_ord', '', 'S', 'cre', 'text', 'Medicom検査オーダ', 'Medicom', '検査オーダ', '1', '<root name="検査依頼">
  <item name="レコード区分" len="2" value="const:O1"/>
  <item name="検査機関コード" len="6" value="dataset:-310001.exam_institution_cd"/>
  <item name="依頼者KEY（日付）" len="6" value="$SYSDATE" subMode="R"/>
  <item name="依頼者KEY（受付番号）" len="4" value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/>
  <item name="RSV" len="10" value="$BLANK"/>
  <item name="科コード・科名" len="15" value="dataset:-310003.course_in_hospital_cd"/>
  <item name="病棟コード・病棟名" len="15" value="dataset:-310003.ward_in_hospital_cd"/>
  <item name="入院外来区分" len="1" value="dataset:-310004.in_out_class"/>
  <item name="提出医" len="10" value="dataset:-310009.user_name"/>
  <item name="披験者ID" len="10" value="dataset:-310005.hosp_pat_id"/>
  <item name="RSV" len="5" value="$BLANK"/>
  <item name="カルテNO" len="10" value="dataset:-310005.hosp_pat_id"/>
  <item name="RSV" len="5" value="$BLANK"/>
  <item name="被験者名" len="20" value="dataset:-310005.pat_name_kana"/>
  <item name="性別" len="1" value="dataset:-310005.pat_sex"/>
  <item name="年齢区分" len="1" value="const:Y"/>
  <item name="年齢" len="3" value="dataset:-310004.pat_age"/>
  <item name="生年月日区分" len="1" value="$BLANK"/>
  <item name="生年月日" len="8" value="dataset:-310004.pat_birthday_yyyymmdd"/>
  <item name="採取日" len="8" value="dataset:-310006.exam_date"/>
  <item name="採取時間" len="4" value="dataset:-310006.exam_time"/>
  <item name="項目数" len="3" value="dataset:-310011.exam_set_cnt"/>
  <item name="身長" len="4" value="$BLANK"/>
  <item name="体重" len="4" value="$BLANK"/>
  <item name="尿量（量）" len="4" value="$BLANK"/>
  <item name="尿量（単位）" len="2" value="$BLANK"/>
  <item name="妊娠週数" len="2" value="$BLANK"/>
  <item name="透析前後" len="1" value="dataset:-310006.exam_timing"/>
  <item name="至急報告" len="1" value="$BLANK"/>
  <item name="依頼コメント内容" len="50" value="$BLANK"/>
  <item name="施設NO" len="6" value="dataset:-310002.facility_no"/>
  <item name="RSV" len="30" value="$BLANK"/>
  <item name="ベッド番号" len="4" value="dataset:-310006.bed_cd"/>
  <item name="改行" len="1" value="$CR"/>
  <occ name="明細.検査項目" len="0" detail="検査項目" sqlCode="-310010"/>
</root>
', '{"dataset": [{"ordNo": "ordNo", "patId": "patId", "sqlCode": -310016, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"patId": "patId", "sqlCode": -310004}, {"key0": "key0", "patId": "patId", "sqlCode": -310003, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -310002, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -310005, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310010, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310011, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310006, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -310008, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -310009, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -310001, "facilityCd": "facilityCd"}], "dumpFileName": {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -310007, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', -1, '2020-05-13 18:35:00.661', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4100002, 'P_hosp', 'exam_ord', '', 'S', 'upd', 'text', 'Medicom検査オーダ', 'Medicom', '検査オーダ', '1', '<root name="検査依頼">
  <item name="レコード区分" len="2" value="dataset:-310012.kbn"/>
  <item name="検査機関コード" len="6" value="dataset:-310001.exam_institution_cd"/>
  <item name="依頼者KEY（日付）" len="6" value="$SYSDATE" subMode="R"/>
  <item name="依頼者KEY（受付番号）" len="4" value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/>
  <item name="RSV" len="10" value="$BLANK"/>
  <item name="科コード・科名" len="15" value="dataset:-310003.course_in_hospital_cd"/>
  <item name="病棟コード・病棟名" len="15" value="dataset:-310003.ward_in_hospital_cd"/>
  <item name="入院外来区分" len="1" value="dataset:-310004.in_out_class"/>
  <item name="提出医" len="10" value="dataset:-310009.user_name"/>
  <item name="披験者ID" len="10" value="dataset:-310005.hosp_pat_id"/>
  <item name="RSV" len="5" value="$BLANK"/>
  <item name="カルテNO" len="10" value="dataset:-310005.hosp_pat_id"/>
  <item name="RSV" len="5" value="$BLANK"/>
  <item name="被験者名" len="20" value="dataset:-310005.pat_name_kana"/>
  <item name="性別" len="1" value="dataset:-310005.pat_sex"/>
  <item name="年齢区分" len="1" value="const:Y"/>
  <item name="年齢" len="3" value="dataset:-310004.pat_age"/>
  <item name="生年月日区分" len="1" value="$BLANK"/>
  <item name="生年月日" len="8" value="dataset:-310004.pat_birthday_yyyymmdd"/>
  <item name="採取日" len="8" value="dataset:-310006.exam_date"/>
  <item name="採取時間" len="4" value="dataset:-310006.exam_time"/>
  <item name="項目数" len="3" value="dataset:-310011.exam_set_cnt"/>
  <item name="身長" len="4" value="$BLANK"/>
  <item name="体重" len="4" value="$BLANK"/>
  <item name="尿量（量）" len="4" value="$BLANK"/>
  <item name="尿量（単位）" len="2" value="$BLANK"/>
  <item name="妊娠週数" len="2" value="$BLANK"/>
  <item name="透析前後" len="1" value="dataset:-310006.exam_timing"/>
  <item name="至急報告" len="1" value="$BLANK"/>
  <item name="依頼コメント内容" len="50" value="$BLANK"/>
  <item name="施設NO" len="6" value="dataset:-310002.facility_no"/>
  <item name="RSV" len="30" value="$BLANK"/>
  <item name="ベッド番号" len="4" value="dataset:-310006.bed_cd"/>
  <item name="改行" len="1" value="$CR"/>
  <occ name="明細.検査項目" len="0" detail="検査項目" sqlCode="-310010"/>
</root>
', '{"dataset": [{"ordNo": "ordNo", "patId": "patId", "sqlCode": -310016, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310012, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"patId": "patId", "sqlCode": -310004}, {"key0": "key0", "patId": "patId", "sqlCode": -310003, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -310002, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -310005, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310010, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310011, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310006, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -310008, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -310009, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -310001, "facilityCd": "facilityCd"}], "dumpFileName": {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -310007, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', -1, '2020-05-13 18:35:00.661', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4100003, 'P_hosp', 'exam_ord', '', 'S', 'del', 'text', 'Medicom検査オーダ', 'Medicom', '検査オーダ', '1', '<root name="検査依頼">
  <item name="レコード区分" len="2" value="dataset:-310013.O1"/>
  <item name="検査機関コード" len="6" value="dataset:-310001.exam_institution_cd"/>
  <item name="依頼者KEY（日付）" len="6" value="$SYSDATE" subMode="R"/>
  <item name="依頼者KEY（受付番号）" len="4" value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/>
  <item name="RSV" len="10" value="$BLANK"/>
  <item name="科コード・科名" len="15" value="dataset:-310003.course_in_hospital_cd" padding_format="blank" padding_position="left"/>
  <item name="病棟コード・病棟名" len="15" value="dataset:-310003.ward_in_hospital_cd"/>
  <item name="入院外来区分" len="1" value="dataset:-310004.in_out_class"/>
  <item name="提出医" len="10" value="dataset:-310009.user_name"/>
  <item name="披験者ID" len="10" value="dataset:-310005.hosp_pat_id"/>
  <item name="RSV" len="5" value="$BLANK"/>
  <item name="カルテNO" len="10" value="dataset:-310005.hosp_pat_id"/>
  <item name="RSV" len="5" value="$BLANK"/>
  <item name="被験者名" len="20" value="dataset:-310005.pat_name"/>
  <item name="性別" len="1" value="dataset:-310005.pat_sex"/>
  <item name="年齢区分" len="1" value="const:Y"/>
  <item name="年齢" len="3" value="dataset:-310004.pat_age"/>
  <item name="生年月日区分" len="1" value="$BLANK"/>
  <item name="生年月日" len="8" value="dataset:-310004.pat_birthday_yyyymmdd"/>
  <item name="採取日" len="8" value="dataset:-310006.exam_date"/>
  <item name="採取時間" len="4" value="dataset:-310006.exam_time"/>
  <item name="項目数" len="3" value="dataset:-310011.exam_set_cnt"/>
  <item name="身長" len="4" value="$BLANK"/>
  <item name="体重" len="4" value="$BLANK"/>
  <item name="尿量（量）" len="4" value="$BLANK"/>
  <item name="尿量（単位）" len="2" value="$BLANK"/>
  <item name="妊娠週数" len="2" value="$BLANK"/>
  <item name="透析前後" len="1" value="dataset:-310006.exam_timing"/>
  <item name="至急報告" len="1" value="$BLANK"/>
  <item name="依頼コメント内容" len="50" value="$BLANK"/>
  <item name="施設NO" len="6" value="dataset:-310002.facility_no"/>
  <item name="RSV" len="30" value="$BLANK"/>
  <item name="ベッド番号" len="4" value="dataset:-310006.bed_cd"/>
  <item name="改行" len="1" value="$CR"/>
  <occ name="明細.検査項目" len="0" detail="検査項目" sqlCode="-310013"/>
</root>
', '{"dataset": [{"ordNo": "ordNo", "patId": "patId", "sqlCode": -310016, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"sqlCode": -310013, "is_zero_end": "true"}, {"patId": "patId", "sqlCode": -310004}, {"key0": "key0", "patId": "patId", "sqlCode": -310003, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -310002, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -310005, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310010, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310011, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -310006, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -310008, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -310009, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -310001, "facilityCd": "facilityCd"}], "dumpFileName": {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -310007, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', -1, '2020-05-13 18:35:00.661', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4170001, 'P_hosp', 'karte_ord', '', 'S', 'cre', 'xml', 'カルテ記載(透析経過データ連携)', 'medicom', 'Medicomのカルテ記載(透析経過データ連携)', '1', '<MCSSData ver="Ver.03.02 2010-01-20">
  <Header>
    <ContentType>dataset:-317124.e03</ContentType>
    <FileVersion>dataset:-317141.e01</FileVersion>
    <InPatientFlag>dataset:-11.in_out_class</InPatientFlag>
    <DepartmentName>dataset:-317104.e12</DepartmentName>
    <DoctorName>dataset:-317111.e01</DoctorName>
    <ConsultationDate>dataset:-14.start_date8a</ConsultationDate>
    <ConsultationTime>dataset:-14.start_date6a</ConsultationTime>
    <ExaminationDate>dataset:-14.start_date8a</ExaminationDate>
    <ExaminationTime>dataset:-14.start_date6a</ExaminationTime>
    <Comment>dataset:-317124.e01</Comment>
    <PatientCode>dataset:-317102.e01</PatientCode>
    <InquirylnpDataFileID>dataset:-317124.e02</InquirylnpDataFileID>
  </Header>
  <Content>
    <Row RowCount="$ROW_COUNT" MasterID="88" detail="血液浄化法">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="89" detail="透析日">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e02</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="90" detail="予定時間">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e03</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="91" detail="開始時刻">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e04</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="92" detail="終了時刻">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e05</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="93" detail="透析時間">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e06</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="94" detail="透析回数">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e07</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="95" detail="血流量">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e08</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="96" detail="CTR">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e09</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="97" detail="穿刺者">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317112">dataset:-317112.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="98" detail="回収者">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317113">dataset:-317113.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="99" detail="担当者">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317114">dataset:-317114.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="100" detail="ダイアライザ">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e10</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="101" detail="バスキュラーアクセス">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e11</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="102" detail="透析導入日">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-417">dataset:-417.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="103" detail="感染症情報">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-418">dataset:-418.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="104" detail="血液">
      <INPUTDATA SeqNo="1">dataset:-317116.abo</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317116.rh</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="105" detail="透析困難コメント">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-421">dataset:-421.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="124" detail="SOAP" _detail="soap" _sqlCode="-317121" _isZeroDisp="true">
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="125" detail="看護メモ" _detail="nurse_memo" _sqlCode="-317122" _isZeroDisp="true">
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="126" detail="問診記録" _detail="medical_record" _sqlCode="-317123" _isZeroDisp="true">
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="122" detail="Ｄｒ">
      <INPUTDATA SeqNo="1">dataset:-317118.e01</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317118.e02</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-317118.e03</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-317118.e04</INPUTDATA>
      <INPUTDATA SeqNo="5">dataset:-317118.e05</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="123" detail="担当Ｎｓ">
      <INPUTDATA SeqNo="1">dataset:-317120.e01</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317120.e02</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-317120.e03</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-317120.e04</INPUTDATA>
      <INPUTDATA SeqNo="5">dataset:-317120.e05</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="110" detail="体重管理">
      <INPUTDATA SeqNo="1">dataset:-426.e01</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-426.e02</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-426.e03</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-426.e04</INPUTDATA>
      <INPUTDATA SeqNo="5">dataset:-426.e05</INPUTDATA>
      <INPUTDATA SeqNo="6">dataset:-426.e06</INPUTDATA>
      <INPUTDATA SeqNo="7">dataset:-426.e07</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="111" detail="除水">
      <INPUTDATA SeqNo="1">dataset:-427.e01</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-427.e02</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-427.e03</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="112" detail="前・脈・血圧">
      <INPUTDATA SeqNo="1">dataset:-317107.bp_high</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317107.bp_low</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-317107.bp_ave</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-317107.pulse</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="113" detail="後・脈・血圧">
      <INPUTDATA SeqNo="1">dataset:-317108.bp_high</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317108.bp_low</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-317108.bp_ave</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-317108.pulse</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="114" detail="抗凝固剤">
      <INPUTDATA SeqNo="1">dataset:-317104.e13</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317104.e14</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-317104.e15</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-317104.e16</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="115" detail="拮抗剤"/>
  </Content>
</MCSSData>
', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -417}, {"patId": "patId", "sqlCode": -418}, {"patId": "patId", "sqlCode": -421}, {"ordNo": "ordNo", "sqlCode": -426}, {"ordNo": "ordNo", "sqlCode": -427}, {"patId": "patId", "sqlCode": -317102}, {"ordNo": "ordNo", "sqlCode": -317104, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -317105}, {"ordNo": "ordNo", "sqlCode": -317107}, {"ordNo": "ordNo", "sqlCode": -317108}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317111, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -317112, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -317113, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -317114, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -317115}, {"key0": "key0", "patId": "patId", "sqlCode": -317116, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317118, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317120, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317121, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317122, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317123, "facilityCd": "facilityCd"}, {"sqlCode": -317124, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -317141, "facilityCd": "facilityCd", "is_zero_end": "true"}], "dumpFileName": {"sqlCode": -317106, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', 5843, '2025-04-07 15:30:21.282', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4170002, 'P_hosp', 'karte_ord', '', 'S', 'upd', 'xml', 'カルテ記載(透析経過データ連携)', 'medicom', 'Medicomのカルテ記載(透析経過データ連携)', '1', '<MCSSData ver="Ver.03.02 2010-01-20">
  <Header>
    <ContentType>dataset:-317124.e03</ContentType>
    <FileVersion>dataset:-317141.e01</FileVersion>
    <InPatientFlag>dataset:-11.in_out_class</InPatientFlag>
    <DepartmentName>dataset:-317104.e12</DepartmentName>
    <DoctorName>dataset:-317111.e01</DoctorName>
    <ConsultationDate>dataset:-14.start_date8a</ConsultationDate>
    <ConsultationTime>dataset:-14.start_date6a</ConsultationTime>
    <ExaminationDate>dataset:-14.start_date8a</ExaminationDate>
    <ExaminationTime>dataset:-14.start_date6a</ExaminationTime>
    <Comment>dataset:-317124.e01</Comment>
    <PatientCode>dataset:-317102.e01</PatientCode>
    <InquirylnpDataFileID>dataset:-317124.e02</InquirylnpDataFileID>
  </Header>
  <Content>
    <Row RowCount="$ROW_COUNT" MasterID="88" detail="血液浄化法">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="89" detail="透析日">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e02</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="90" detail="予定時間">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e03</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="91" detail="開始時刻">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e04</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="92" detail="終了時刻">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e05</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="93" detail="透析時間">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e06</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="94" detail="透析回数">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e07</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="95" detail="血流量">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e08</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="96" detail="CTR">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e09</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="97" detail="穿刺者">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317112">dataset:-317112.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="98" detail="回収者">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317113">dataset:-317113.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="99" detail="担当者">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317114">dataset:-317114.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="100" detail="ダイアライザ">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e10</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="101" detail="バスキュラーアクセス">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-317104">dataset:-317104.e11</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="102" detail="透析導入日">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-417">dataset:-417.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="103" detail="感染症情報">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-418">dataset:-418.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="104" detail="血液">
      <INPUTDATA SeqNo="1">dataset:-317116.abo</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317116.rh</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="105" detail="透析困難コメント">
      <INPUTDATA SeqNo="$COUNT" _sqlCode="-421">dataset:-421.e01</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="124" detail="SOAP" _detail="soap" _sqlCode="-317121" _isZeroDisp="true">
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="125" detail="看護メモ" _detail="nurse_memo" _sqlCode="-317122" _isZeroDisp="true">
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="126" detail="問診記録" _detail="medical_record" _sqlCode="-317123" _isZeroDisp="true">
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="122" detail="Ｄｒ">
      <INPUTDATA SeqNo="1">dataset:-317118.e01</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317118.e02</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-317118.e03</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-317118.e04</INPUTDATA>
      <INPUTDATA SeqNo="5">dataset:-317118.e05</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="123" detail="担当Ｎｓ">
      <INPUTDATA SeqNo="1">dataset:-317120.e01</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317120.e02</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-317120.e03</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-317120.e04</INPUTDATA>
      <INPUTDATA SeqNo="5">dataset:-317120.e05</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="110" detail="体重管理">
      <INPUTDATA SeqNo="1">dataset:-426.e01</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-426.e02</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-426.e03</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-426.e04</INPUTDATA>
      <INPUTDATA SeqNo="5">dataset:-426.e05</INPUTDATA>
      <INPUTDATA SeqNo="6">dataset:-426.e06</INPUTDATA>
      <INPUTDATA SeqNo="7">dataset:-426.e07</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="111" detail="除水">
      <INPUTDATA SeqNo="1">dataset:-427.e01</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-427.e02</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-427.e03</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="112" detail="前・脈・血圧">
      <INPUTDATA SeqNo="1">dataset:-317107.bp_high</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317107.bp_low</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-317107.bp_ave</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-317107.pulse</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="113" detail="後・脈・血圧">
      <INPUTDATA SeqNo="1">dataset:-317108.bp_high</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317108.bp_low</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-317108.bp_ave</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-317108.pulse</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="114" detail="抗凝固剤">
      <INPUTDATA SeqNo="1">dataset:-317104.e13</INPUTDATA>
      <INPUTDATA SeqNo="2">dataset:-317104.e14</INPUTDATA>
      <INPUTDATA SeqNo="3">dataset:-317104.e15</INPUTDATA>
      <INPUTDATA SeqNo="4">dataset:-317104.e16</INPUTDATA>
    </Row>
    <Row RowCount="$ROW_COUNT" MasterID="115" detail="拮抗剤"/>
  </Content>
</MCSSData>
', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -417}, {"patId": "patId", "sqlCode": -418}, {"patId": "patId", "sqlCode": -421}, {"ordNo": "ordNo", "sqlCode": -426}, {"ordNo": "ordNo", "sqlCode": -427}, {"patId": "patId", "sqlCode": -317102}, {"ordNo": "ordNo", "sqlCode": -317104, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -317105}, {"ordNo": "ordNo", "sqlCode": -317107}, {"ordNo": "ordNo", "sqlCode": -317108}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317111, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -317112, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -317113, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -317114, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -317115}, {"key0": "key0", "patId": "patId", "sqlCode": -317116, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317118, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317120, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317121, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317122, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -317123, "facilityCd": "facilityCd"}, {"sqlCode": -317124, "facilityCd": "facilityCd"}, {"sqlCode": -317019, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"patId": "patId", "sqlCode": -317141, "facilityCd": "facilityCd", "is_zero_end": "true"}], "dumpFileName": {"sqlCode": -317106, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', 5843, '2025-04-07 15:30:21.282', CURRENT_TIMESTAMP, 'MED');