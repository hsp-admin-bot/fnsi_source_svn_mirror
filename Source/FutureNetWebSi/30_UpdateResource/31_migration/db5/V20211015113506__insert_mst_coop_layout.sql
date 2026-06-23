delete from "mst_coop_layout" where "ctl_no" in (-4080001,-4080002,-4080003,-4080004,-4080005,-4080006,-4080007,-4080008,-4080009,-4080010,-4080011);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4080001, 'P_hosp', 'rep_dial', '', 'S', 'cre', 'text', 'パナソニック 透析レポート', 'Medicom', 'report(※未開発)', '1', '<root name="透析レポート">
    <item  name="電文種別" len="2" value="const:VR"/>
    <item  name="レコード継続指示" len="1" value="const:E"/>
    <item  name="送信先システムコード" len="2" value="const:XX"/>
    <item  name="発信元システムコード" len="2" value="const:VN"/>
    <item  name="処理年月日" len="8" value="$SYSDATE"/>
    <item  name="処理時刻" len="6" value="$SYSTIME"/>
    <item  name="端末名" len="8" value="const:VOSERVER"/>
    <item  name="利用者番号" len="8" value="dataset:-22.staff_cd"/>
    <item  name="処理区分" len="2" value="const:01"/>
    <item  name="応答種別" len="2" value="$BLANK"/>
    <item  name="電文長" len="6" value="$LENGTH"/>
    <item  name="エラーコード" len="5" value="$BLANK"/>
    <item  name="予備" len="12" value="$BLANK"/>
    <item  name="患者番号" len="10" value="dataset:1.hosp_pat_id"/>
    <item  name="実施日時" len="14" value="dataset:-11.start_date"/>
    <item  name="オーダ番号" len="8" value="$JOURNAL.coop_ord_no"/>
    <item  name="部門発生文書番号(文書種別）" len="4" value="const:RP01"/>
    <item  name="部門発生文書番号（オーダ番号）" len="8" value="$JOURNAL.coop_ord_no"/>
    <item  name="部門発生文書番号（末尾）" len="18" value="$JOURNAL.ord_no"/>
    <item  name="オーダ番号発番日" len="8" value="const:00000000"/>
    <item  name="結果状態" len="1" value="const:1"/>
    <item  name="報告書状態" len="1" value="const:1"/>
    <item  name="入外区分" len="1" value="dataset:-11.in_out_class"/>
    <item  name="部署（診療科）" len="3" value="dataset:-11.course_cd"/>
    <item  name="病棟" len="3" value="dataset:-11.ward_cd"/>
    <item  name="文書種別" len="4" value="const:RP01"/>
    <item  name="文書タイトル" len="50" value="const:透析レポート"/>
    <item  name="コメント" len="50" value="const:コメント"/>
    <item  name="フォーマットタイプ" len="3" value="const:HTM"/>
    <item  name="ツールパラメタ" len="512" value="$BLANK"/>
    <item  name="イメージフラグ" len="1" value="const:1"/>
    <item  name="ブラウザツールID" len="4" value="$BLANK"/>
    <item  name="報告者" len="20" value="auth_id:-22.staff_cd"/>
    <item  name="報告者ID" len="8" value="dataset:-22.staff_cd"/>
    <item  name="報告部署" len="3" value="const:1"/>
    <item  name="報告日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="実施者" len="20" value="auth_id:-22.staff_cd"/>
    <item  name="実施者ID" len="8" value="dataset:-22.staff_cd"/>
    <item  name="実施部署" len="3" value="const:1"/>
    <item  name="実施日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認者" len="20" value="auth_id:-22.staff_cd"/>
    <item  name="承認者ID" len="8" value="dataset:-22.staff_cd"/>
    <item  name="承認日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認状態" len="1" value="const:1"/>
    <item  name="ComLib連携フラグ" len="1" value="const:0"/>
    <item  name="レポート情報" len="12" value="const:&lt;EMBED src=&quot;"/>
    <item  name="レポート情報" len="20" value="dataset:-104.pdf_file"/>
    <item  name="レポート情報" len="29" value="const:&quot; width=&quot;100%25&quot; height=&quot;100%25&quot;&gt;"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": 1}, {"patId": "patId", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -22}, {"ordNo": "ordNo", "sqlCode": -104}]}', '1', '0', 4, '2020-05-25 18:26:36.811', '2020-05-25 18:26:41.871');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4080002, 'P_hosp', 'rep_dial', '', 'S', 'upd', 'text', 'パナソニック 透析レポート', 'Medicom', 'report(※未開発)', '1', '<root name="透析レポート">
    <item  name="電文種別" len="2" value="const:VR"/>
    <item  name="レコード継続指示" len="1" value="const:E"/>
    <item  name="送信先システムコード" len="2" value="const:XX"/>
    <item  name="発信元システムコード" len="2" value="const:VN"/>
    <item  name="処理年月日" len="8" value="$SYSDATE"/>
    <item  name="処理時刻" len="6" value="$SYSTIME"/>
    <item  name="端末名" len="8" value="const:VOSERVER"/>
    <item  name="利用者番号" len="8" value="dataset:-22.staff_cd"/>
    <item  name="処理区分" len="2" value="const:02"/>
    <item  name="応答種別" len="2" value="$BLANK"/>
    <item  name="電文長" len="6" value="$LENGTH"/>
    <item  name="エラーコード" len="5" value="$BLANK"/>
    <item  name="予備" len="12" value="$BLANK"/>
    <item  name="患者番号" len="10" value="dataset:1.hosp_pat_id"/>
    <item  name="実施日時" len="14" value="dataset:-11.start_date"/>
    <item  name="オーダ番号" len="8" value="$JOURNAL.coop_ord_no"/>
    <item  name="部門発生文書番号(文書種別）" len="4" value="const:RP01"/>
    <item  name="部門発生文書番号（オーダ番号）" len="8" value="$JOURNAL.coop_ord_no"/>
    <item  name="部門発生文書番号（末尾）" len="18" value="$JOURNAL.ord_no"/>
    <item  name="オーダ番号発番日" len="8" value="const:00000000"/>
    <item  name="結果状態" len="1" value="const:1"/>
    <item  name="報告書状態" len="1" value="const:1"/>
    <item  name="入外区分" len="1" value="dataset:-11.in_out_class"/>
    <item  name="部署（診療科）" len="3" value="dataset:-11.course_cd"/>
    <item  name="病棟" len="3" value="dataset:-11.ward_cd"/>
    <item  name="文書種別" len="4" value="const:RP01"/>
    <item  name="文書タイトル" len="50" value="const:透析レポート"/>
    <item  name="コメント" len="50" value="const:コメント"/>
    <item  name="フォーマットタイプ" len="3" value="const:HTM"/>
    <item  name="ツールパラメタ" len="512" value="$BLANK"/>
    <item  name="イメージフラグ" len="1" value="const:1"/>
    <item  name="ブラウザツールID" len="4" value="$BLANK"/>
    <item  name="報告者" len="20" value="auth_id:-22.staff_cd"/>
    <item  name="報告者ID" len="8" value="dataset:-22.staff_cd"/>
    <item  name="報告部署" len="3" value="const:1"/>
    <item  name="報告日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="実施者" len="20" value="auth_id:-22.staff_cd"/>
    <item  name="実施者ID" len="8" value="dataset:-22.staff_cd"/>
    <item  name="実施部署" len="3" value="const:1"/>
    <item  name="実施日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認者" len="20" value="auth_id:-22.staff_cd"/>
    <item  name="承認者ID" len="8" value="dataset:-22.staff_cd"/>
    <item  name="承認日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認状態" len="1" value="const:1"/>
    <item  name="ComLib連携フラグ" len="1" value="const:0"/>
    <item  name="レポート情報" len="12" value="const:&lt;EMBED src=&quot;"/>
    <item  name="レポート情報" len="20" value="dataset:-104.pdf_file"/>
    <item  name="レポート情報" len="29" value="const:&quot; width=&quot;100$PS&quot; height=&quot;100$PS&quot;&gt;"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": 1}, {"patId": "patId", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -22}, {"ordNo": "ordNo", "sqlCode": -104}]}', '1', '0', 4, '2025-01-02 18:26:36.811', '2025-01-02 18:26:41.871');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4080003, 'P_hosp', 'rep_dial', '', 'S', 'del', 'text', 'パナソニック 透析レポート', 'Medicom', 'report(※未開発)', '1', '<root name="透析レポート">
    <item  name="電文種別" len="2" value="const:VR"/>
    <item  name="レコード継続指示" len="1" value="const:E"/>
    <item  name="送信先システムコード" len="2" value="const:XX"/>
    <item  name="発信元システムコード" len="2" value="const:VN"/>
    <item  name="処理年月日" len="8" value="$SYSDATE"/>
    <item  name="処理時刻" len="6" value="$SYSTIME"/>
    <item  name="端末名" len="8" value="const:VOSERVER"/>
    <item  name="利用者番号" len="8" value="dataset:-22.staff_cd"/>
    <item  name="処理区分" len="2" value="const:03"/>
    <item  name="応答種別" len="2" value="$BLANK"/>
    <item  name="電文長" len="6" value="$LENGTH"/>
    <item  name="エラーコード" len="5" value="$BLANK"/>
    <item  name="予備" len="12" value="$BLANK"/>
    <item  name="患者番号" len="10" value="dataset:1.hosp_pat_id"/>
    <item  name="実施日時" len="14" value="dataset:-11.start_date"/>
    <item  name="オーダ番号" len="8" value="$JOURNAL.coop_ord_no"/>
    <item  name="部門発生文書番号(文書種別）" len="4" value="const:RP01"/>
    <item  name="部門発生文書番号（オーダ番号）" len="8" value="$JOURNAL.coop_ord_no"/>
    <item  name="部門発生文書番号（末尾）" len="18" value="$JOURNAL.ord_no"/>
    <item  name="オーダ番号発番日" len="8" value="const:00000000"/>
    <item  name="結果状態" len="1" value="const:1"/>
    <item  name="報告書状態" len="1" value="const:1"/>
    <item  name="入外区分" len="1" value="dataset:-11.in_out_class"/>
    <item  name="部署（診療科）" len="3" value="dataset:-11.course_cd"/>
    <item  name="病棟" len="3" value="dataset:-11.ward_cd"/>
    <item  name="文書種別" len="4" value="const:RP01"/>
    <item  name="文書タイトル" len="50" value="const:透析レポート"/>
    <item  name="コメント" len="50" value="const:コメント"/>
    <item  name="フォーマットタイプ" len="3" value="const:HTM"/>
    <item  name="ツールパラメタ" len="512" value="$BLANK"/>
    <item  name="イメージフラグ" len="1" value="const:1"/>
    <item  name="ブラウザツールID" len="4" value="$BLANK"/>
    <item  name="報告者" len="20" value="auth_id:-22.staff_cd"/>
    <item  name="報告者ID" len="8" value="dataset:-22.staff_cd"/>
    <item  name="報告部署" len="3" value="const:1"/>
    <item  name="報告日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="実施者" len="20" value="auth_id:-22.staff_cd"/>
    <item  name="実施者ID" len="8" value="dataset:-22.staff_cd"/>
    <item  name="実施部署" len="3" value="const:1"/>
    <item  name="実施日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認者" len="20" value="auth_id:-22.staff_cd"/>
    <item  name="承認者ID" len="8" value="dataset:-22.staff_cd"/>
    <item  name="承認日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認状態" len="1" value="const:1"/>
    <item  name="ComLib連携フラグ" len="1" value="const:0"/>
    <item  name="レポート情報" len="12" value="const:&lt;EMBED src=&quot;"/>
    <item  name="レポート情報" len="20" value="dataset:-104.pdf_file"/>
    <item  name="レポート情報" len="29" value="const:&quot; width=&quot;100%25&quot; height=&quot;100%25&quot;&gt;"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": 1}, {"patId": "patId", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -22}, {"ordNo": "ordNo", "sqlCode": -104}]}', '1', '0', 4, '2025-01-02 18:26:36.811', '2025-01-02 18:26:41.871');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4080004, 'P_hosp', 'rep_dial', 'pdf', 'S', 'cre', 'pdf', 'パナソニック 透析レポート(pdf)', 'Medicom', 'report', '1', NULL, NULL, '1', '0', 4, '2020-05-25 18:26:36.811', '2020-05-25 18:26:41.871');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4080005, 'P_hosp', 'rep_dial', 'pdf', 'S', 'upd', 'pdf', 'パナソニック 透析レポート(pdf)', 'Medicom', 'report', '1', NULL, NULL, '1', '0', 4, '2020-05-25 18:26:36.811', '2020-05-25 18:26:41.871');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4080006, 'P_hosp', 'rep_dial', 'xml', 'S', 'cre', 'xml', 'パナソニック 透析レポート(xml)', 'Medicom', 'report', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-300001.up_date">
    <DISP_PATID>dataset:-300001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-300001.pat_name</NAME>
    <KANA>dataset:-300001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-300001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-300001.pat_age</AGE>
    <SEX>dataset:-300001.pat_sex</SEX>
    <INOUT>dataset:-300001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-300000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -300001}, {"sqlCode": -300000}]}', '1', '0', 4, '2020-05-25 18:26:36.811', '2020-05-25 18:26:41.871');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4080007, 'P_hosp', 'rep_dial', 'xml', 'S', 'upd', 'xml', 'パナソニック 透析レポート(xml)', 'Medicom', 'report', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-300001.up_date">
    <DISP_PATID>dataset:-300001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-300001.pat_name</NAME>
    <KANA>dataset:-300001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-300001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-300001.pat_age</AGE>
    <SEX>dataset:-300001.pat_sex</SEX>
    <INOUT>dataset:-300001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-300000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -300001}, {"sqlCode": -300000}]}', '1', '0', 4, '2020-05-25 18:26:36.811', '2020-05-25 18:26:41.871');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4080008, 'P_hosp', 'rep_dial', 'listxml', 'S', 'cre', 'xml', 'パナソニック 透析レポート(listxml)', 'Medicom', 'report', '1', '<rootNode DISP_PATID_LENGTH="dataset:-300010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-300001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-300001.pat_name" KANA="dataset:-300001.pat_name_kana"  SEX="dataset:-300001.pat_sex" BLOODABO="dataset:-300001.pat_blood_type_abo" BLOODRH="dataset:-300001.pat_blood_type_rh" AGE="dataset:-300001.pat_age" UPDATE_DATETIME="dataset:-300001.up_date"></PATIENT>
</rootNode>
', '{"dataset": [{"patId": "patId", "sqlCode": -300001}, {"sqlCode": -300010, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2020-05-25 18:26:36.811', '2020-05-25 18:26:41.871');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4080009, 'P_hosp', 'rep_dial', 'listxml', 'S', 'upd', 'xml', 'パナソニック 透析レポート(listxml)', 'Medicom', 'report', '1', '<rootNode DISP_PATID_LENGTH="dataset:-300010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-300001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-300001.pat_name" KANA="dataset:-300001.pat_name_kana"  SEX="dataset:-300001.pat_sex" BLOODABO="dataset:-300001.pat_blood_type_abo" BLOODRH="dataset:-300001.pat_blood_type_rh" AGE="dataset:-300001.pat_age" UPDATE_DATETIME="dataset:-300001.up_date"></PATIENT>
</rootNode>
', '{"dataset": [{"patId": "patId", "sqlCode": -300001}, {"sqlCode": -300010, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2020-05-25 18:26:36.811', '2020-05-25 18:26:41.871');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4080010, 'P_hosp', 'rep_dial', 'tar', 'S', 'cre', 'xml', 'パナソニック 透析レポート(tar)', 'Medicom', 'report', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-300001.up_date">
    <DISP_PATID>dataset:-300001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-300001.pat_name</NAME>
    <KANA>dataset:-300001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-300001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-300001.pat_age</AGE>
    <SEX>dataset:-300001.pat_sex</SEX>
    <INOUT>dataset:-300001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-300000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -300001}, {"sqlCode": -300000}]}', '1', '0', 4, '2020-05-25 18:26:36.811', '2020-05-25 18:26:41.871');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4080011, 'P_hosp', 'rep_dial', 'tar', 'S', 'upd', 'xml', 'パナソニック 透析レポート(tar)', 'Medicom', 'report', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-300001.up_date">
    <DISP_PATID>dataset:-300001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-300001.pat_name</NAME>
    <KANA>dataset:-300001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-300001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-300001.pat_age</AGE>
    <SEX>dataset:-300001.pat_sex</SEX>
    <INOUT>dataset:-300001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS _detail="report" _sqlCode="-300000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -300001}, {"sqlCode": -300000}]}', '1', '0', 4, '2020-05-25 18:26:36.811', '2020-05-25 18:26:41.871');
