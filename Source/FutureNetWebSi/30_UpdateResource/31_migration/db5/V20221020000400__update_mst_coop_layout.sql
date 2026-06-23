delete from "mst_coop_layout" where "ctl_no" in (-2080001,-2080002,-2080003,-2080004,-2080005,-2080006,-2080007,-2080008,-2080009,-2080010,-2080011,-2080012,-2080013,-2080014,-2080015,-2080016,-2080017,-2080018,-2080019,-2080020,-2080021,-2080022);
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080001, 'F_hosp', 'rep_dial', 'yobi1', 'S', 'cre', 'text', 'fujitsu', 'fujitsu', 'report(HTML本文送信)→report_type(yobi1)', '1', '<root name="透析レポート(HTML本文送信)">
    <item  name="電文種別" len="2" value="const:VR"/>
    <item  name="レコード継続指示" len="1" value="const:E"/>
    <item  name="送信先システムコード" len="2" value="const:XX"/>
    <item  name="発信元システムコード" len="2" value="const:VN"/>
    <item  name="処理年月日" len="8" value="$SYSDATE"/>
    <item  name="処理時刻" len="6" value="$SYSTIME"/>
    <item  name="端末名" len="8" value="const:VOSERVER"/>
    <item  name="利用者番号" len="8" value="dataset:-68.disp_user_id"/>
    <item  name="処理区分" len="2" value="const:01"/>
    <item  name="応答種別" len="2" value="$BLANK"/>
    <item  name="電文長" len="6" value="$LENGTH"/>
    <item  name="エラーコード" len="5" value="$BLANK"/>
    <item  name="予備" len="12" value="$BLANK"/>
    <item  name="患者番号" len="10" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="実施日時" len="14" value="dataset:-11.start_date14"/>
    <item  name="オーダ番号(固定)" len="2" value="const:99"/>
    <item  name="オーダ番号" len="6" value="$JOURNAL.ord_no" padding_format="zero" padding_position="left" subMode="R"/>
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
    <item  name="フォーマットタイプ" len="3" value="const:HTM"/>
    <item  name="ツールパラメタ" len="512" value="$BLANK"/>
    <item  name="イメージフラグ" len="1" value="const:1"/>
    <item  name="ブラウザツールID" len="4" value="$BLANK"/>
    <item  name="報告者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="報告者ID" len="8" value="dataset:-68.disp_user_id"/>
    <item  name="報告部署" len="3" value="dataset:-60.report_post"/>
    <item  name="報告日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="実施者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="実施者ID" len="8" value="dataset:-68.disp_user_id"/>
    <item  name="実施部署" len="3" value="dataset:-60.execution_post"/>
    <item  name="実施日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="承認者ID" len="8" value="dataset:-68.disp_user_id"/>
    <item  name="承認日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認状態" len="1" value="const:1"/>
    <item  name="ComLib連携フラグ" len="1" value="const:0"/>
    <item  name="レポート情報" len="12" value="const:&lt;EMBED src=&quot;"/>
    <item  name="レポート情報" len="32" value="dataset:-62.filename"/>
    <item  name="レポート情報" len="29" value="const:&quot; width=&quot;100%25&quot; height=&quot;100%25&quot;&gt;"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -55, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -22}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -62}, {"sqlCode": -60, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -52, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -61, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -68, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2020-05-25 18:26:36.811', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080002, 'F_hosp', 'rep_dial', 'yobi1', 'S', 'upd', 'text', 'fujitsu', 'fujitsu', 'report(HTML本文送信)→report_type(yobi1)', '1', '<root name="透析レポート(HTML本文送信)">
    <item  name="電文種別" len="2" value="const:VR"/>
    <item  name="レコード継続指示" len="1" value="const:E"/>
    <item  name="送信先システムコード" len="2" value="const:XX"/>
    <item  name="発信元システムコード" len="2" value="const:VN"/>
    <item  name="処理年月日" len="8" value="$SYSDATE"/>
    <item  name="処理時刻" len="6" value="$SYSTIME"/>
    <item  name="端末名" len="8" value="const:VOSERVER"/>
    <item  name="利用者番号" len="8" value="dataset:-68.disp_user_id"/>
    <item  name="処理区分" len="2" value="const:02"/>
    <item  name="応答種別" len="2" value="$BLANK"/>
    <item  name="電文長" len="6" value="$LENGTH"/>
    <item  name="エラーコード" len="5" value="$BLANK"/>
    <item  name="予備" len="12" value="$BLANK"/>
    <item  name="患者番号" len="10" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="実施日時" len="14" value="dataset:-11.start_date14"/>
    <item  name="オーダ番号(固定)" len="2" value="const:99"/>
    <item  name="オーダ番号" len="6" value="$JOURNAL.ord_no" padding_format="zero" padding_position="left" subMode="R"/>
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
    <item  name="フォーマットタイプ" len="3" value="const:HTM"/>
    <item  name="ツールパラメタ" len="512" value="$BLANK"/>
    <item  name="イメージフラグ" len="1" value="const:1"/>
    <item  name="ブラウザツールID" len="4" value="$BLANK"/>
    <item  name="報告者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="報告者ID" len="8" value="dataset:-68.disp_user_id"/>
    <item  name="報告部署" len="3" value="dataset:-60.report_post"/>
    <item  name="報告日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="実施者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="実施者ID" len="8" value="dataset:-68.disp_user_id"/>
    <item  name="実施部署" len="3" value="dataset:-60.execution_post"/>
    <item  name="実施日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="承認者ID" len="8" value="dataset:-68.disp_user_id"/>
    <item  name="承認日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認状態" len="1" value="const:1"/>
    <item  name="ComLib連携フラグ" len="1" value="const:0"/>
    <item  name="レポート情報" len="12" value="const:&lt;EMBED src=&quot;"/>
    <item  name="レポート情報" len="32" value="dataset:-62.filename"/>
    <item  name="レポート情報" len="29" value="const:&quot; width=&quot;100%25&quot; height=&quot;100%25&quot;&gt;"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -55, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -22}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -62}, {"sqlCode": -60, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -52, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -61, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -68, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2025-01-02 18:26:36.811', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080003, 'F_hosp', 'rep_dial', 'yobi1', 'S', 'del', 'text', 'fujitsu', 'fujitsu', 'report(HTML本文送信)→report_type(yobi1)', '1', '<root name="透析レポート(HTML本文送信)">
    <item  name="電文種別" len="2" value="const:VR"/>
    <item  name="レコード継続指示" len="1" value="const:E"/>
    <item  name="送信先システムコード" len="2" value="const:XX"/>
    <item  name="発信元システムコード" len="2" value="const:VN"/>
    <item  name="処理年月日" len="8" value="$SYSDATE"/>
    <item  name="処理時刻" len="6" value="$SYSTIME"/>
    <item  name="端末名" len="8" value="const:VOSERVER"/>
    <item  name="利用者番号" len="8" value="dataset:-68.disp_user_id"/>
    <item  name="処理区分" len="2" value="const:03"/>
    <item  name="応答種別" len="2" value="$BLANK"/>
    <item  name="電文長" len="6" value="$LENGTH"/>
    <item  name="エラーコード" len="5" value="$BLANK"/>
    <item  name="予備" len="12" value="$BLANK"/>
    <item  name="患者番号" len="10" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="実施日時" len="14" value="dataset:-70.start_date14"/>
    <item  name="オーダ番号" len="8" value="$JOURNAL.ord_no" padding_format="zero" padding_position="left" subMode="R"/>
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
    <item  name="フォーマットタイプ" len="3" value="const:HTM"/>
    <item  name="ツールパラメタ" len="512" value="$BLANK"/>
    <item  name="イメージフラグ" len="1" value="const:1"/>
    <item  name="ブラウザツールID" len="4" value="$BLANK"/>
    <item  name="報告者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="報告者ID" len="8" value="dataset:-68.disp_user_id"/>
    <item  name="報告部署" len="3" value="dataset:-60.report_post"/>
    <item  name="報告日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="実施者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="実施者ID" len="8" value="dataset:-68.disp_user_id"/>
    <item  name="実施部署" len="3" value="dataset:-60.execution_post"/>
    <item  name="実施日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="承認者ID" len="8" value="dataset:-68.disp_user_id"/>
    <item  name="承認日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認状態" len="1" value="const:1"/>
    <item  name="ComLib連携フラグ" len="1" value="const:0"/>
    <item  name="レポート情報" len="12" value="const:&lt;EMBED src=&quot;"/>
    <item  name="レポート情報" len="32" value="dataset:-77.filename"/>
    <item  name="レポート情報" len="29" value="const:&quot; width=&quot;100%25&quot; height=&quot;100%25&quot;&gt;"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -55, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -70, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -22}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -77}, {"sqlCode": -60, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -69, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -61, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -68, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2025-01-02 18:26:36.811', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080004, 'F_hosp', 'rep_dial', 'nkkpdf', 'S', 'cre', 'pdf', 'pdf', 'fujitsu', '透析レポート（URL連携→日機装（LISTXMLとXMLとPDFファイルの送信））→report_type(nkk_rep)', '1', '<rootNode>
 </rootNode>
 ', NULL, '1', '0', 4, '2020-05-25 18:26:36.811', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080005, 'F_hosp', 'rep_dial', 'nkkpdf', 'S', 'upd', 'pdf', 'pdf', 'fujitsu', '透析レポート（URL連携→日機装（LISTXMLとXMLとPDFファイルの送信））→report_type(nkk_rep)', '1', '<rootNode>
 </rootNode>
 ', '{}', '1', '0', 4, '2020-05-25 18:26:36.811', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080006, 'F_hosp', 'rep_dial', 'nkkxml', 'S', 'cre', 'xml', 'xml', 'fujitsu', '透析レポート（URL連携→日機装（LISTXMLとXMLとPDFファイルの送信））→report_type(nkk_rep)', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-100001.up_date">
    <DISP_PATID>dataset:-100001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-100001.pat_name</NAME>
    <KANA>dataset:-100001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-100001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-100001.pat_age</AGE>
    <SEX>dataset:-100001.pat_sex</SEX>
    <INOUT>dataset:-100001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-100000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -100001}, {"sqlCode": -100000}]}', '1', '0', 4, '2020-05-25 18:26:36.811', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080007, 'F_hosp', 'rep_dial', 'nkkxml', 'S', 'upd', 'xml', 'xml', 'fujitsu', '透析レポート（URL連携→日機装（LISTXMLとXMLとPDFファイルの送信））→report_type(nkk_rep)', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-100001.up_date">
    <DISP_PATID>dataset:-100001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-100001.pat_name</NAME>
    <KANA>dataset:-100001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-100001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-100001.pat_age</AGE>
    <SEX>dataset:-100001.pat_sex</SEX>
    <INOUT>dataset:-100001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-100000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -100001}, {"sqlCode": -100000}]}', '1', '0', 4, '2020-05-25 18:26:36.811', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080008, 'F_hosp', 'rep_dial', 'nkklistxml', 'S', 'cre', 'xml', 'listxml', 'fujitsu', '透析レポート（URL連携→日機装（LISTXMLとXMLとPDFファイルの送信））→report_type(nkk_rep)', '1', '<rootNode DISP_PATID_LENGTH="dataset:-100010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-100001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-100001.pat_name" KANA="dataset:-100001.pat_name_kana"  SEX="dataset:-100001.pat_sex" BLOODABO="dataset:-100001.pat_blood_type_abo" BLOODRH="dataset:-100001.pat_blood_type_rh" AGE="dataset:-100001.pat_age" UPDATE_DATETIME="dataset:-100001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -100001}, {"sqlCode": -100010, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2020-05-25 18:26:36.811', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080009, 'F_hosp', 'rep_dial', 'nkklistxml', 'S', 'upd', 'xml', 'listxml', 'fujitsu', '透析レポート（URL連携→日機装（LISTXMLとXMLとPDFファイルの送信））→report_type(nkk_rep)', '1', '<rootNode DISP_PATID_LENGTH="dataset:-100010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-100001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-100001.pat_name" KANA="dataset:-100001.pat_name_kana"  SEX="dataset:-100001.pat_sex" BLOODABO="dataset:-100001.pat_blood_type_abo" BLOODRH="dataset:-100001.pat_blood_type_rh" AGE="dataset:-100001.pat_age" UPDATE_DATETIME="dataset:-100001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -100001}, {"sqlCode": -100010, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2020-05-25 18:26:36.811', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080010, 'F_hosp', 'rep_dial', '', 'S', 'cre', 'text', 'fujitsu', 'fujitsu', 'report(URL連携)→report_type(none)', '1', '<root name="透析レポート(URL連携)">
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
    <item  name="オーダ番号(固定)" len="2" value="const:99"/>
    <item  name="オーダ番号" len="6" value="$JOURNAL.ord_no" padding_format="zero" padding_position="left" subMode="R"/>
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
    <item  name="報告者ID" len="8" value="dataset:-89.disp_user_id"/>
    <item  name="報告部署" len="3" value="dataset:-60.report_post"/>
    <item  name="報告日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="実施者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="実施者ID" len="8" value="dataset:-89.disp_user_id"/>
    <item  name="実施部署" len="3" value="dataset:-60.execution_post"/>
    <item  name="実施日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="承認者ID" len="8" value="dataset:-89.disp_user_id"/>
    <item  name="承認日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認状態" len="1" value="const:1"/>
    <item  name="ComLib連携フラグ" len="1" value="const:0"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -55, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -22}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -62}, {"sqlCode": -60, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -52, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -61, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -63, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -68, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -87, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -88, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -89, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2020-05-25 18:26:36.811', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080011, 'F_hosp', 'rep_dial', '', 'S', 'upd', 'text', 'fujitsu', 'fujitsu', 'report(URL連携)→report_type(none)', '1', '<root name="透析レポート(URL連携)">
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
    <item  name="オーダ番号(固定)" len="2" value="const:99"/>
    <item  name="オーダ番号" len="6" value="$JOURNAL.ord_no" padding_format="zero" padding_position="left" subMode="R"/>
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
    <item  name="報告者ID" len="8" value="dataset:-89.disp_user_id"/>
    <item  name="報告部署" len="3" value="dataset:-60.report_post"/>
    <item  name="報告日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="実施者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="実施者ID" len="8" value="dataset:-89.disp_user_id"/>
    <item  name="実施部署" len="3" value="dataset:-60.execution_post"/>
    <item  name="実施日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="承認者ID" len="8" value="dataset:-89.disp_user_id"/>
    <item  name="承認日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認状態" len="1" value="const:1"/>
    <item  name="ComLib連携フラグ" len="1" value="const:0"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -55, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -22}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -62}, {"sqlCode": -60, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -52, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -61, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -63, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -68, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -87, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -88, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -89, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2025-01-02 18:26:36.811', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080012, 'F_hosp', 'rep_dial', '', 'S', 'del', 'text', 'fujitsu', 'fujitsu', 'report(URL連携)→report_type(none)', '1', '<root name="透析レポート(URL連携)">
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
    <item  name="オーダ番号" len="8" value="$JOURNAL.ord_no" padding_format="zero" padding_position="left" subMode="R"/>
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
    <item  name="報告者ID" len="8" value="dataset:-89.disp_user_id"/>
    <item  name="報告部署" len="3" value="dataset:-60.report_post"/>
    <item  name="報告日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="実施者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="実施者ID" len="8" value="dataset:-89.disp_user_id"/>
    <item  name="実施部署" len="3" value="dataset:-60.execution_post"/>
    <item  name="実施日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="承認者ID" len="8" value="dataset:-89.disp_user_id"/>
    <item  name="承認日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認状態" len="1" value="const:1"/>
    <item  name="ComLib連携フラグ" len="1" value="const:0"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -55, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -70, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -22}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -62}, {"sqlCode": -60, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -69, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -61, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -63, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -87, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -88, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -89, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2025-01-02 18:26:36.811', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080013, 'F_hosp', 'rep_dial', 'tar', 'S', 'cre', 'xml', 'xml', 'fujitsu', '透析レポート（のみTARファイルの送信）→report_type(tar)', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-100001.up_date">
    <DISP_PATID>dataset:-100001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-100001.pat_name</NAME>
    <KANA>dataset:-100001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-100001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-100001.pat_age</AGE>
    <SEX>dataset:-100001.pat_sex</SEX>
    <INOUT>dataset:-100001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-100000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -100001}, {"sqlCode": -100000}]}', '1', '0', 4, '2020-05-25 18:26:36.811', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080014, 'F_hosp', 'rep_dial', 'tar', 'S', 'upd', 'xml', 'xml', 'fujitsu', '透析レポート（のみTARファイルの送信）→report_type(tar)', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-100001.up_date">
    <DISP_PATID>dataset:-100001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-100001.pat_name</NAME>
    <KANA>dataset:-100001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-100001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-100001.pat_age</AGE>
    <SEX>dataset:-100001.pat_sex</SEX>
    <INOUT>dataset:-100001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-100000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -100001}, {"sqlCode": -100000}]}', '1', '0', 4, '2020-05-25 18:26:36.811', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080015, 'F_hosp', 'rep_dial', 'pdf', 'S', 'cre', 'pdf', 'pdf', 'fujitsu', '透析レポート（HTML本文送信→のみPDFファイルの送信）→report_type(pdf)', '1', '<rootNode>
 </rootNode>
 ', NULL, '1', '0', 4, '2020-05-25 18:26:36.811', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080016, 'F_hosp', 'rep_dial', 'pdf', 'S', 'upd', 'pdf', 'pdf', 'fujitsu', '透析レポート（HTML本文送信→のみPDFファイルの送信）→report_type(pdf)', '1', '<rootNode>
 </rootNode>
 ', '{}', '1', '0', 4, '2020-05-25 18:26:36.811', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080017, 'F_hosp', 'rep_dial', 'xml', 'S', 'cre', 'xml', 'xml', 'fujitsu', '透析レポート（のみXMLファイルの送信）→report_type(xml)', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-100001.up_date">
    <DISP_PATID>dataset:-100001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-100001.pat_name</NAME>
    <KANA>dataset:-100001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-100001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-100001.pat_age</AGE>
    <SEX>dataset:-100001.pat_sex</SEX>
    <INOUT>dataset:-100001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-100000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -100001}, {"sqlCode": -100000}]}', '1', '0', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080018, 'F_hosp', 'rep_dial', 'xml', 'S', 'upd', 'xml', 'xml', 'fujitsu', '透析レポート（のみXMLファイルの送信）→report_type(xml)', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-100001.up_date">
    <DISP_PATID>dataset:-100001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-100001.pat_name</NAME>
    <KANA>dataset:-100001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-100001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-100001.pat_age</AGE>
    <SEX>dataset:-100001.pat_sex</SEX>
    <INOUT>dataset:-100001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-100000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -100001}, {"sqlCode": -100000}]}', '1', '0', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080019, 'F_hosp', 'rep_dial', 'necpdf', 'S', 'cre', 'pdf', 'pdf', 'fujitsu', '透析レポート（XMLとPDFのファイル送信）→report_type(nec_rep)', '1', '<rootNode>
 </rootNode>
 ', NULL, '1', '0', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080020, 'F_hosp', 'rep_dial', 'necpdf', 'S', 'upd', 'pdf', 'pdf', 'fujitsu', '透析レポート（XMLとPDFのファイル送信）→report_type(nec_rep)', '1', '<rootNode>
 </rootNode>
 ', '{}', '1', '0', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080021, 'F_hosp', 'rep_dial', 'necxml', 'S', 'cre', 'xml', 'xml', 'fujitsu', '透析レポート（XMLとPDFのファイル送信）→report_type(nec_rep)', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-100001.up_date">
    <DISP_PATID>dataset:-100001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-100001.pat_name</NAME>
    <KANA>dataset:-100001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-100001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-100001.pat_age</AGE>
    <SEX>dataset:-100001.pat_sex</SEX>
    <INOUT>dataset:-100001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-100000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -100001}, {"sqlCode": -100000}]}', '1', '0', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080022, 'F_hosp', 'rep_dial', 'necxml', 'S', 'upd', 'xml', 'xml', 'fujitsu', '透析レポート（XMLとPDFのファイル送信）→report_type(nec_rep)', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-100001.up_date">
    <DISP_PATID>dataset:-100001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-100001.pat_name</NAME>
    <KANA>dataset:-100001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-100001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-100001.pat_age</AGE>
    <SEX>dataset:-100001.pat_sex</SEX>
    <INOUT>dataset:-100001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-100000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -100001}, {"sqlCode": -100000}]}', '1', '0', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
