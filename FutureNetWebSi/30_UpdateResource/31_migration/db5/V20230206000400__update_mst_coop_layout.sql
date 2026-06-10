delete from "mst_coop_layout" where "ctl_no" in(-2070001,-2070002,-2080002,
-2080003,
-2080001,
-2080010,
-2080011,
-2080012);
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-2080012, 'F_hosp', 'rep_dial', '', 'S', 'del', 'text', 'fujitsu', 'fujitsu', 'report(URL連携)→report_type(none)', '1', '<root name="透析レポート(URL連携)">
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
</root>', '{"dataset": [{"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -55, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -70, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -11, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -22}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -62}, {"key0": "key0", "sqlCode": -60, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -69, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -61, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -63, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -87, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -88, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -89, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2025-01-02 18:26:36.811',CURRENT_TIMESTAMP, '');
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-2080011, 'F_hosp', 'rep_dial', '', 'S', 'upd', 'text', 'fujitsu', 'fujitsu', 'report(URL連携)→report_type(none)', '1', '<root name="透析レポート(URL連携)">
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
</root>', '{"dataset": [{"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -55, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -11, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -22}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -62}, {"key0": "key0", "sqlCode": -60, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -52, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -61, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -63, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -68, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -87, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -88, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -89, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2025-01-02 18:26:36.811',CURRENT_TIMESTAMP, '');
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-2080010, 'F_hosp', 'rep_dial', '', 'S', 'cre', 'text', 'fujitsu', 'fujitsu', 'report(URL連携)→report_type(none)', '1', '<root name="透析レポート(URL連携)">
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
</root>', '{"dataset": [{"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -55, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -11, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -22}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -62}, {"key0": "key0", "sqlCode": -60, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -52, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -61, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -63, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -68, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -87, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -88, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -89, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2020-05-25 18:26:36.811',CURRENT_TIMESTAMP, '');
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-2080003, 'F_hosp', 'rep_dial', 'yobi1', 'S', 'del', 'text', 'fujitsu', 'fujitsu', 'report(HTML本文送信)→report_type(yobi1)', '1', '<root name="透析レポート(HTML本文送信)">
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
</root>', '{"dataset": [{"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -55, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -70, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -11, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -22}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -77}, {"key0": "key0", "sqlCode": -60, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -69, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -61, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -68, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2025-01-02 18:26:36.811',CURRENT_TIMESTAMP, '');
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-2080002, 'F_hosp', 'rep_dial', 'yobi1', 'S', 'upd', 'text', 'fujitsu', 'fujitsu', 'report(HTML本文送信)→report_type(yobi1)', '1', '<root name="透析レポート(HTML本文送信)">
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
</root>', '{"dataset": [{"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -55, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -11, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -22}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -62}, {"key0": "key0", "sqlCode": -60, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -52, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -61, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -68, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2025-01-02 18:26:36.811',CURRENT_TIMESTAMP, '');
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-2080001, 'F_hosp', 'rep_dial', 'yobi1', 'S', 'cre', 'text', 'fujitsu', 'fujitsu', 'report(HTML本文送信)→report_type(yobi1)', '1', '<root name="透析レポート(HTML本文送信)">
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
</root>', '{"dataset": [{"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -55, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -22}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -62}, {"key0": "key0", "sqlCode": -60, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -52, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -61, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -68, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2020-05-25 18:26:36.811',CURRENT_TIMESTAMP, '');
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-2070002, 'F_hosp', 'rst_dial', '', 'S', 'upd', 'text', '富士通実績', 'fujitsu', '実績送信', '1', '<root name="富士通透析実績">
    <item  name="電文種別" len="2" value="const:VO"/>
    <item  name="レコード継続指示" len="1" value="const:E"/>
    <item  name="送信先システムコード" len="2" value="const:XX"/>
    <item  name="発信元システムコード"  len="2" value="const:VN"/>
    <item  name="処理情報.処理年月日" len="8" value="$SYSDATE"/>
    <item  name="処理情報.処理時刻" len="6" value="$SYSTIME"/>
    <item  name="端末名" len="8" value="const:VOSERVER"/>
    <item  name="利用者番号" len="8" value="dataset:-71.disp_user_id"/>
    <item  name="処理区分" len="2" value="const:02"/>
    <item  name="応答種別" len="2" value="$BLANK"/>
    <item  name="電文長" len="6" value="$LENGTH"/>
    <item  name="エラーコード" len="5" value="$BLANK"/>
    <item  name="予備" len="12" value="$BLANK"/>
    <item  name="情報種別" len="2" value="const:02"/>
    <item  name="患者情報.患者番号" len="10" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="伝票情報.オーダ番号" len="8" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="伝票情報.文書番号(先頭8文字）" len="8" value="const:VOSERVER"/>
    <item  name="伝票情報.文書番号" len="20" value="dataset:-82.document_no" />
    <item  name="伝票情報.文書番号(後2文字）" len="2" value="dataset:-48.document_no"/>
    <item  name="伝票情報.文書版数" len="2" value="const:00"/>
    <item  name="伝票情報.関連オーダ番号" len="8" value="dataset:-54.ord_no"/>
    <item  name="伝票情報.オーダ日付" len="8" value="dataset:-14.start_date8"/>
    <item  name="伝票情報.オーダ時間" len="6" value="dataset:-14.start_date6"/>
    <item  name="伝票情報.保険パターン番号" len="2" value="dataset:-54.insu_no"/>
    <item  name="伝票情報.入外区分" len="1" value="dataset:-11.in_out_f"/>
    <item  name="伝票情報.診療科コード" len="3" value="dataset:-52.course_cd"/>
    <item  name="伝票情報.病棟コード" len="3" value="dataset:-52.ward_cd"/>
    <item  name="伝票情報.利用者番号" len="8" value="dataset:-72.disp_user_id"/>
    <item  name="伝票情報.伝票コード" len="4" value="const:V002"/>
    <item  name="伝票情報.伝票名称" len="50" value="const:血液浄化実施"/>
    <item  name="予約情報.予約グループCD" len="4" value="const:V"/>
    <item  name="予約情報.予約枠コード" len="8" value="dataset:-57.bed_cd" />
    <item  name="予約情報.予約開始日" len="8" value="$BLANK"/>
    <item  name="予約情報.予約開始時間" len="6" value="$BLANK"/>
    <item  name="予約情報.予約終了日" len="8" value="$BLANK"/>
    <item  name="予約情報.予約終了時間" len="6" value="$BLANK"/>
    <occ  name="明細行数" len="4" detail="実績詳細" sqlCode="-101" padding_format="zero" padding_position="left" />
    <item  name="終端" value="$CR"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -100001}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -101, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -14}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -11, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -71, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -72, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -48, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -54, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -52, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -57, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -82, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}]}', '1', '0', 4, '2020-05-01 10:15:53.808',CURRENT_TIMESTAMP, '');
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-2070001, 'F_hosp', 'rst_dial', '', 'S', 'cre', 'text', '富士通実績', 'fujitsu', '実績送信', '1', '<root name="富士通透析実績">
    <item  name="電文種別" len="2" value="const:VO"/>
    <item  name="レコード継続指示" len="1" value="const:E"/>
    <item  name="送信先システムコード" len="2" value="const:XX"/>
    <item  name="発信元システムコード"  len="2" value="const:VN"/>
    <item  name="処理情報.処理年月日" len="8" value="$SYSDATE"/>
    <item  name="処理情報.処理時刻" len="6" value="$SYSTIME"/>
    <item  name="端末名" len="8" value="const:VOSERVER"/>
    <item  name="利用者番号" len="8" value="dataset:-71.disp_user_id"/>
    <item  name="処理区分" len="2" value="const:01"/>
    <item  name="応答種別" len="2" value="$BLANK"/>
    <item  name="電文長" len="6" value="$LENGTH"/>
    <item  name="エラーコード" len="5" value="$BLANK"/>
    <item  name="予備" len="12" value="$BLANK"/>
    <item  name="情報種別" len="2" value="const:02"/>
    <item  name="患者情報.患者番号" len="10" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="伝票情報.オーダ番号" len="8" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="伝票情報.文書番号(先頭8文字）" len="8" value="const:VOSERVER"/>
    <item  name="伝票情報.文書番号" len="20" value="dataset:-82.document_no" />
    <item  name="伝票情報.文書番号(後2文字）" len="2" value="dataset:-48.document_no"/>
    <item  name="伝票情報.文書版数" len="2" value="const:00"/>
    <item  name="伝票情報.関連オーダ番号" len="8" value="dataset:-54.ord_no"/>
    <item  name="伝票情報.オーダ日付" len="8" value="dataset:-14.start_date8"/>
    <item  name="伝票情報.オーダ時間" len="6" value="dataset:-14.start_date6"/>
    <item  name="伝票情報.保険パターン番号" len="2" value="dataset:-54.insu_no"/>
    <item  name="伝票情報.入外区分" len="1" value="dataset:-11.in_out_f"/>
    <item  name="伝票情報.診療科コード" len="3" value="dataset:-52.course_cd"/>
    <item  name="伝票情報.病棟コード" len="3" value="dataset:-52.ward_cd"/>
    <item  name="伝票情報.利用者番号" len="8" value="dataset:-72.disp_user_id"/>
    <item  name="伝票情報.伝票コード" len="4" value="const:V002"/>
    <item  name="伝票情報.伝票名称" len="50" value="const:血液浄化実施"/>
    <item  name="予約情報.予約グループCD" len="4" value="const:V"/>
    <item  name="予約情報.予約枠コード" len="8" value="dataset:-57.bed_cd"/>
    <item  name="予約情報.予約開始日" len="8" value="$BLANK"/>
    <item  name="予約情報.予約開始時間" len="6" value="$BLANK"/>
    <item  name="予約情報.予約終了日" len="8" value="$BLANK"/>
    <item  name="予約情報.予約終了時間" len="6" value="$BLANK"/>
    <occ  name="明細行数" len="4" detail="実績詳細" sqlCode="-101" padding_format="zero" padding_position="left"/>
    <item  name="終端" value="$CR"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -100001}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -101, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -14}, {"ordNo": "ordNo", "sqlCode": -11}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -71, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -72, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -48, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -54, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -52, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -57, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -82, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}]}', '1', '0', 4, '2020-05-01 10:15:53.808',CURRENT_TIMESTAMP, '');
