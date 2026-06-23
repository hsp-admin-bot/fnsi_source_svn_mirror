delete from "mst_coop_layout" where ctl_no in (-7080006,-7080007,-3080006,-3080007,-5010006,-5010007,-1010006,-1010007,-1010013,-4080008,-4080009,-6040006,-6040007,-2080008,-2080009,-2080010,-2080011,-2080012);
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-1010006, 'nkknkk', 'rep_dial', 'listxml', 'S', 'upd', 'xml', '日機装 透析レポート(listxml)', '日機装', 'テスト用report', '1', '<rootNode DISP_PATID_LENGTH="dataset:-400010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-400001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-400001.pat_name" KANA="dataset:-400001.pat_name_kana"  SEX="dataset:-400001.pat_sex" BLOODABO="dataset:-400001.pat_blood_type_abo" BLOODRH="dataset:-400001.pat_blood_type_rh" AGE="dataset:-400001.pat_age" UPDATE_DATETIME="dataset:-400001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -400001}, {"sqlCode": -400010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}]}', '1', '0', -1, '2021-09-01 07:38:44.069', CURRENT_TIMESTAMP, '');
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-1010007, 'nkknkk', 'rep_dial', 'listxml', 'S', 'cre', 'xml', '日機装 透析レポート(listxml)', '日機装', 'テスト用report', '1', '<rootNode DISP_PATID_LENGTH="dataset:-400010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-400001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-400001.pat_name" KANA="dataset:-400001.pat_name_kana"  SEX="dataset:-400001.pat_sex" BLOODABO="dataset:-400001.pat_blood_type_abo" BLOODRH="dataset:-400001.pat_blood_type_rh" AGE="dataset:-400001.pat_age" UPDATE_DATETIME="dataset:-400001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -400001}, {"sqlCode": -400010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}]}', '1', '0', -1, '2021-09-01 07:38:44.069', CURRENT_TIMESTAMP, '');
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-1010013, 'nkknkk', 'rep_dial', 'listxml', 'S', 'del', 'xml', '日機装 透析レポート(listxml)', '日機装', 'テスト用report', '1', '<rootNode DISP_PATID_LENGTH="dataset:-400010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-400001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-400001.pat_name" KANA="dataset:-400001.pat_name_kana"  SEX="dataset:-400001.pat_sex" BLOODABO="dataset:-400001.pat_blood_type_abo" BLOODRH="dataset:-400001.pat_blood_type_rh" AGE="dataset:-400001.pat_age" UPDATE_DATETIME="dataset:-400001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -400001}, {"sqlCode": -400010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}]}', '1', '0', -1, '2022-07-04 12:22:10.543', CURRENT_TIMESTAMP, '');
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-2080008, 'F_hosp', 'rep_dial', 'nkklistxml', 'S', 'cre', 'xml', 'listxml', 'fujitsu', '透析レポート（URL連携→日機装（LISTXMLとXMLとPDFファイルの送信））→report_type(nkk_rep)', '1', '<rootNode DISP_PATID_LENGTH="dataset:-100010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-100001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-100001.pat_name" KANA="dataset:-100001.pat_name_kana"  SEX="dataset:-100001.pat_sex" BLOODABO="dataset:-100001.pat_blood_type_abo" BLOODRH="dataset:-100001.pat_blood_type_rh" AGE="dataset:-100001.pat_age" UPDATE_DATETIME="dataset:-100001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -100001}, {"sqlCode": -100010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}]}', '1', '0', 4, '2020-05-25 18:26:36.811', CURRENT_TIMESTAMP, '');
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-2080009, 'F_hosp', 'rep_dial', 'nkklistxml', 'S', 'upd', 'xml', 'listxml', 'fujitsu', '透析レポート（URL連携→日機装（LISTXMLとXMLとPDFファイルの送信））→report_type(nkk_rep)', '1', '<rootNode DISP_PATID_LENGTH="dataset:-100010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-100001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-100001.pat_name" KANA="dataset:-100001.pat_name_kana"  SEX="dataset:-100001.pat_sex" BLOODABO="dataset:-100001.pat_blood_type_abo" BLOODRH="dataset:-100001.pat_blood_type_rh" AGE="dataset:-100001.pat_age" UPDATE_DATETIME="dataset:-100001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -100001}, {"sqlCode": -100010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}]}', '1', '0', 4, '2020-05-25 18:26:36.811', CURRENT_TIMESTAMP, '');
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-2080010, 'F_hosp', 'rep_dial', '', 'S', 'cre', 'text', 'fujitsu', 'fujitsu', 'report(URL連携)→report_type(none)', '1', '<root name="透析レポート(URL連携)">
    <item  name="電文種別" len="2" value="const:VR"/>
    <item  name="レコード継続指示" len="1" value="const:E"/>
    <item  name="送信先システムコード" len="2" value="const:XX"/>
    <item  name="発信元システムコード" len="2" value="const:VN"/>
    <item  name="処理年月日" len="8" value="$SYSDATE"/>
    <item  name="処理時刻" len="6" value="$SYSTIME"/>
    <item  name="端末名" len="8" value="const:VOSERVER"/>
    <item  name="利用者番号" len="8" value="dataset:-88.disp_user_id"/>
    <item  name="処理区分" len="2" value="const:01"/>
    <item  name="応答種別" len="2" value="$BLANK"/>
    <item  name="電文長" len="6" value="$LENGTH"/>
    <item  name="エラーコード" len="5" value="$BLANK"/>
    <item  name="予備" len="12" value="$BLANK"/>
    <item  name="患者番号" len="10" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="実施日時" len="14" value="dataset:-11.start_date14"/>
    <item  name="オーダ番号" len="8" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="部門発生文書番号(文書種別）" len="4" value="dataset:-55.sentence_type"/>
    <item  name="部門発生文書番号（オーダ番号）" len="8" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left"  subMode="R"/>
    <item  name="部門発生文書番号（末尾）" len="18" value="dataset:-55.ord_no"/>
    <item  name="オーダ番号発番日" len="8" value="const:00000000"/>
    <item  name="結果状態" len="1" value="const:1"/>
    <item  name="報告書状態" len="1" value="const:1"/>
    <item  name="入外区分" len="1" value="dataset:-11.in_out_f"/>
    <item  name="部署（診療科）" len="3" value="dataset:-52.course_cd"/>
    <item  name="病棟" len="3" value="dataset:-52.ward_cd"/>
    <item  name="文書種別" len="4" value="const:RP01"/>
    <item  name="文書タイトル" len="50" value="const:透析レポート"/>
    <item  name="コメント" len="50" value="const:コメント"/>
    <item  name="フォーマットタイプ" len="3" value="$BLANK"/>
    <item  name="ツールパラメタ" len="512" value="dataset:-63.filename"/>
    <item  name="イメージフラグ" len="1" value="const:0"/>
    <item  name="ブラウザツールID" len="4" value="const:1003"/>
    <item  name="報告者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="報告者ID" len="8" value="dataset:-88.disp_user_id"/>
    <item  name="報告部署" len="3" value="dataset:-60.report_post"/>
    <item  name="報告日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="実施者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="実施者ID" len="8" value="dataset:-88.disp_user_id"/>
    <item  name="実施部署" len="3" value="dataset:-60.execution_post"/>
    <item  name="実施日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="承認者ID" len="8" value="dataset:-88.disp_user_id"/>
    <item  name="承認日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認状態" len="1" value="const:1"/>
    <item  name="ComLib連携フラグ" len="1" value="const:0"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -55, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -22}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -62}, {"key0": "key0", "sqlCode": -60, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -52, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -61, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -63, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -68, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -87, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -88, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -89, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2020-05-25 18:26:36.811', CURRENT_TIMESTAMP, '');
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-2080011, 'F_hosp', 'rep_dial', '', 'S', 'upd', 'text', 'fujitsu', 'fujitsu', 'report(URL連携)→report_type(none)', '1', '<root name="透析レポート(URL連携)">
    <item  name="電文種別" len="2" value="const:VR"/>
    <item  name="レコード継続指示" len="1" value="const:E"/>
    <item  name="送信先システムコード" len="2" value="const:XX"/>
    <item  name="発信元システムコード" len="2" value="const:VN"/>
    <item  name="処理年月日" len="8" value="$SYSDATE"/>
    <item  name="処理時刻" len="6" value="$SYSTIME"/>
    <item  name="端末名" len="8" value="const:VOSERVER"/>
    <item  name="利用者番号" len="8" value="dataset:-88.disp_user_id"/>
    <item  name="処理区分" len="2" value="const:02"/>
    <item  name="応答種別" len="2" value="$BLANK"/>
    <item  name="電文長" len="6" value="$LENGTH"/>
    <item  name="エラーコード" len="5" value="$BLANK"/>
    <item  name="予備" len="12" value="$BLANK"/>
    <item  name="患者番号" len="10" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="実施日時" len="14" value="dataset:-11.start_date14"/>
    <item  name="オーダ番号" len="8" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="部門発生文書番号(文書種別）" len="4" value="dataset:-55.sentence_type"/>
    <item  name="部門発生文書番号（オーダ番号）" len="8" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left"  subMode="R"/>
    <item  name="部門発生文書番号（末尾）" len="18" value="dataset:-55.ord_no"/>
    <item  name="オーダ番号発番日" len="8" value="const:00000000"/>
    <item  name="結果状態" len="1" value="const:1"/>
    <item  name="報告書状態" len="1" value="const:1"/>
    <item  name="入外区分" len="1" value="dataset:-11.in_out_f"/>
    <item  name="部署（診療科）" len="3" value="dataset:-52.course_cd"/>
    <item  name="病棟" len="3" value="dataset:-52.ward_cd"/>
    <item  name="文書種別" len="4" value="const:RP01"/>
    <item  name="文書タイトル" len="50" value="const:透析レポート"/>
    <item  name="コメント" len="50" value="const:コメント"/>
    <item  name="フォーマットタイプ" len="3" value="$BLANK"/>
    <item  name="ツールパラメタ" len="512" value="dataset:-63.filename"/>
    <item  name="イメージフラグ" len="1" value="const:0"/>
    <item  name="ブラウザツールID" len="4" value="const:1003"/>
    <item  name="報告者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="報告者ID" len="8" value="dataset:-88.disp_user_id"/>
    <item  name="報告部署" len="3" value="dataset:-60.report_post"/>
    <item  name="報告日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="実施者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="実施者ID" len="8" value="dataset:-88.disp_user_id"/>
    <item  name="実施部署" len="3" value="dataset:-60.execution_post"/>
    <item  name="実施日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="承認者ID" len="8" value="dataset:-88.disp_user_id"/>
    <item  name="承認日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認状態" len="1" value="const:1"/>
    <item  name="ComLib連携フラグ" len="1" value="const:0"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -55, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -22}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -62}, {"key0": "key0", "sqlCode": -60, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -52, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -61, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -63, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -68, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -87, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -88, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -89, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2025-01-02 18:26:36.811', CURRENT_TIMESTAMP, '');
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-2080012, 'F_hosp', 'rep_dial', '', 'S', 'del', 'text', 'fujitsu', 'fujitsu', 'report(URL連携)→report_type(none)', '1', '<root name="透析レポート(URL連携)">
    <item  name="電文種別" len="2" value="const:VR"/>
    <item  name="レコード継続指示" len="1" value="const:E"/>
    <item  name="送信先システムコード" len="2" value="const:XX"/>
    <item  name="発信元システムコード" len="2" value="const:VN"/>
    <item  name="処理年月日" len="8" value="$SYSDATE"/>
    <item  name="処理時刻" len="6" value="$SYSTIME"/>
    <item  name="端末名" len="8" value="const:VOSERVER"/>
    <item  name="利用者番号" len="8" value="dataset:-88.disp_user_id"/>
    <item  name="処理区分" len="2" value="const:03"/>
    <item  name="応答種別" len="2" value="$BLANK"/>
    <item  name="電文長" len="6" value="$LENGTH"/>
    <item  name="エラーコード" len="5" value="$BLANK"/>
    <item  name="予備" len="12" value="$BLANK"/>
    <item  name="患者番号" len="10" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="実施日時" len="14" value="dataset:-70.start_date14"/>
    <item  name="オーダ番号" len="8" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="部門発生文書番号(文書種別）" len="4" value="dataset:-55.sentence_type"/>
    <item  name="部門発生文書番号（オーダ番号）" len="8" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left"  subMode="R"/>
    <item  name="部門発生文書番号（末尾）" len="18" value="dataset:-55.ord_no"/>
    <item  name="オーダ番号発番日" len="8" value="const:00000000"/>
    <item  name="結果状態" len="1" value="const:1"/>
    <item  name="報告書状態" len="1" value="const:1"/>
    <item  name="入外区分" len="1" value="dataset:-70.in_out_f"/>
    <item  name="部署（診療科）" len="3" value="dataset:-69.course_cd"/>
    <item  name="病棟" len="3" value="dataset:-69.ward_cd"/>
    <item  name="文書種別" len="4" value="const:RP01"/>
    <item  name="文書タイトル" len="50" value="const:透析レポート"/>
    <item  name="コメント" len="50" value="const:コメント"/>
    <item  name="フォーマットタイプ" len="3" value="$BLANK"/>
    <item  name="ツールパラメタ" len="512" value="dataset:-63.filename"/>
    <item  name="イメージフラグ" len="1" value="const:0"/>
    <item  name="ブラウザツールID" len="4" value="const:1003"/>
    <item  name="報告者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="報告者ID" len="8" value="dataset:-88.disp_user_id"/>
    <item  name="報告部署" len="3" value="dataset:-60.report_post"/>
    <item  name="報告日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="実施者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="実施者ID" len="8" value="dataset:-88.disp_user_id"/>
    <item  name="実施部署" len="3" value="dataset:-60.execution_post"/>
    <item  name="実施日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="承認者ID" len="8" value="dataset:-88.disp_user_id"/>
    <item  name="承認日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認状態" len="1" value="const:1"/>
    <item  name="ComLib連携フラグ" len="1" value="const:0"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -55, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -70, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -22}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -62}, {"key0": "key0", "sqlCode": -60, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -69, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -61, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -63, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -87, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -88, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -89, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2025-01-02 18:26:36.811', CURRENT_TIMESTAMP, '');
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-3080006, 'N_hosp', 'rep_dial', 'listxml', 'S', 'upd', 'xml', 'NEC標準(MegaOakHR) 透析レポート(listxml)', 'NEC標準(MegaOakHR)', '透析レポート送信', '1', '<rootNode DISP_PATID_LENGTH="dataset:-600010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-600001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-600001.pat_name" KANA="dataset:-600001.pat_name_kana"  SEX="dataset:-600001.pat_sex" BLOODABO="dataset:-600001.pat_blood_type_abo" BLOODRH="dataset:-600001.pat_blood_type_rh" AGE="dataset:-600001.pat_age" UPDATE_DATETIME="dataset:-600001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"sqlCode": -600010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}]}', '1', '0', -1, '2021-11-22 11:31:58.328', CURRENT_TIMESTAMP, '');
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-3080007, 'N_hosp', 'rep_dial', 'listxml', 'S', 'cre', 'xml', 'NEC標準(MegaOakHR) 透析レポート(listxml)', 'NEC標準(MegaOakHR)', '透析レポート送信', '1', '<rootNode DISP_PATID_LENGTH="dataset:-600010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-600001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-600001.pat_name" KANA="dataset:-600001.pat_name_kana"  SEX="dataset:-600001.pat_sex" BLOODABO="dataset:-600001.pat_blood_type_abo" BLOODRH="dataset:-600001.pat_blood_type_rh" AGE="dataset:-600001.pat_age" UPDATE_DATETIME="dataset:-600001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"sqlCode": -600010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}]}', '1', '0', -1, '2021-11-22 11:31:58.328', CURRENT_TIMESTAMP, '');
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-4080008, 'P_hosp', 'rep_dial', 'listxml', 'S', 'cre', 'xml', 'パナソニック 透析レポート(listxml)', 'Medicom', 'report', '1', '<rootNode DISP_PATID_LENGTH="dataset:-300010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-300001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-300001.pat_name" KANA="dataset:-300001.pat_name_kana"  SEX="dataset:-300001.pat_sex" BLOODABO="dataset:-300001.pat_blood_type_abo" BLOODRH="dataset:-300001.pat_blood_type_rh" AGE="dataset:-300001.pat_age" UPDATE_DATETIME="dataset:-300001.up_date"></PATIENT>
</rootNode>
', '{"dataset": [{"patId": "patId", "sqlCode": -300001}, {"sqlCode": -300010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}]}', '1', '0', 4, '2020-05-25 18:26:36.811', CURRENT_TIMESTAMP, '');
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-4080009, 'P_hosp', 'rep_dial', 'listxml', 'S', 'upd', 'xml', 'パナソニック 透析レポート(listxml)', 'Medicom', 'report', '1', '<rootNode DISP_PATID_LENGTH="dataset:-300010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-300001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-300001.pat_name" KANA="dataset:-300001.pat_name_kana"  SEX="dataset:-300001.pat_sex" BLOODABO="dataset:-300001.pat_blood_type_abo" BLOODRH="dataset:-300001.pat_blood_type_rh" AGE="dataset:-300001.pat_age" UPDATE_DATETIME="dataset:-300001.up_date"></PATIENT>
</rootNode>
', '{"dataset": [{"patId": "patId", "sqlCode": -300001}, {"sqlCode": -300010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}]}', '1', '0', 4, '2020-05-25 18:26:36.811', CURRENT_TIMESTAMP, '');
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-5010006, 'S_hosp', 'rep_dial', 'listxml', 'S', 'upd', 'xml', 'SSI 透析レポート(listxml)', 'SSI', 'テスト用report', '1', '<rootNode DISP_PATID_LENGTH="dataset:-500010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-500001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-500001.pat_name" KANA="dataset:-500001.pat_name_kana"  SEX="dataset:-500001.pat_sex" BLOODABO="dataset:-500001.pat_blood_type_abo" BLOODRH="dataset:-500001.pat_blood_type_rh" AGE="dataset:-500001.pat_age" UPDATE_DATETIME="dataset:-500001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"sqlCode": -500010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}]}', '1', '0', -1, '2021-09-01 07:38:44.069', CURRENT_TIMESTAMP, '');
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-5010007, 'S_hosp', 'rep_dial', 'listxml', 'S', 'cre', 'xml', 'SSI 透析レポート(listxml)', 'SSI', 'テスト用report', '1', '<rootNode DISP_PATID_LENGTH="dataset:-500010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-500001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-500001.pat_name" KANA="dataset:-500001.pat_name_kana"  SEX="dataset:-500001.pat_sex" BLOODABO="dataset:-500001.pat_blood_type_abo" BLOODRH="dataset:-500001.pat_blood_type_rh" AGE="dataset:-500001.pat_age" UPDATE_DATETIME="dataset:-500001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -500001}, {"sqlCode": -500010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}]}', '1', '0', -1, '2021-09-01 07:38:44.069', CURRENT_TIMESTAMP, '');
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-6040006, 'C_hosp', 'rep_dial', 'listxml', 'S', 'upd', 'xml', 'CSI透析レポート(listxml)', 'MIRAIs', 'テスト用report', '1', '<rootNode DISP_PATID_LENGTH="dataset:-200010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-200001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-200001.pat_name" KANA="dataset:-200001.pat_name_kana"  SEX="dataset:-200001.pat_sex" BLOODABO="dataset:-200001.pat_blood_type_abo" BLOODRH="dataset:-200001.pat_blood_type_rh" AGE="dataset:-200001.pat_age" UPDATE_DATETIME="dataset:-200001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"sqlCode": -200010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}]}', '1', '0', -1, '2021-09-01 07:38:44.069', CURRENT_TIMESTAMP, '');
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-6040007, 'C_hosp', 'rep_dial', 'listxml', 'S', 'cre', 'xml', 'CSI透析レポート(listxml)', 'MIRAIs', 'テスト用report', '1', '<rootNode DISP_PATID_LENGTH="dataset:-200010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-200001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-200001.pat_name" KANA="dataset:-200001.pat_name_kana"  SEX="dataset:-200001.pat_sex" BLOODABO="dataset:-200001.pat_blood_type_abo" BLOODRH="dataset:-200001.pat_blood_type_rh" AGE="dataset:-200001.pat_age" UPDATE_DATETIME="dataset:-200001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"sqlCode": -200010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}]}', '1', '0', -1, '2021-09-01 07:38:44.069', CURRENT_TIMESTAMP, '');
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-7080006, 'NEC-iS', 'rep_dial', 'listxml', 'S', 'upd', 'xml', 'NEC-iS(MegaOakiS) 透析レポート(listxml)', 'NEC-iS(MegaOakiS)', '透析レポート送信', '1', '<rootNode DISP_PATID_LENGTH="dataset:-700010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-700001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-700001.pat_name" KANA="dataset:-700001.pat_name_kana"  SEX="dataset:-700001.pat_sex" BLOODABO="dataset:-700001.pat_blood_type_abo" BLOODRH="dataset:-700001.pat_blood_type_rh" AGE="dataset:-700001.pat_age" UPDATE_DATETIME="dataset:-700001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -700001}, {"sqlCode": -700010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}]}', '1', '0', -1, '2021-12-13 11:51:34.469', CURRENT_TIMESTAMP, '');
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-7080007, 'NEC-iS', 'rep_dial', 'listxml', 'S', 'cre', 'xml', 'NEC-iS(MegaOakiS) 透析レポート(listxml)', 'NEC-iS(MegaOakiS)', '透析レポート送信', '1', '<rootNode DISP_PATID_LENGTH="dataset:-700010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-700001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-700001.pat_name" KANA="dataset:-700001.pat_name_kana"  SEX="dataset:-700001.pat_sex" BLOODABO="dataset:-700001.pat_blood_type_abo" BLOODRH="dataset:-700001.pat_blood_type_rh" AGE="dataset:-700001.pat_age" UPDATE_DATETIME="dataset:-700001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -700001}, {"sqlCode": -700010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}]}', '1', '0', -1, '2021-12-13 11:51:34.469', CURRENT_TIMESTAMP, '');
