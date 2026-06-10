DELETE FROM "ntss"."mst_coop_layout" where "ctl_no" IN (-2080003, -2080001, -2080002);
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080002, 'F_hosp', 'rep_dial', '', 'S', 'upd', 'text', 'fujitsu', 'fujitsu', 'report(HTML本文送信)', '1', '<root name="透析レポート(HTML本文送信)">
    <item  name="電文種別" len="2" value="const:VR"/>
    <item  name="レコード継続指示" len="1" value="const:E"/>
    <item  name="送信先システムコード" len="2" value="const:XX"/>
    <item  name="発信元システムコード" len="2" value="const:VN"/>
    <item  name="処理年月日" len="8" value="$SYSDATE"/>
    <item  name="処理時刻" len="6" value="$SYSTIME"/>
    <item  name="端末名" len="8" value="const:VOSERVER"/>
    <item  name="利用者番号" len="8" value="in_hospital_cd_1:-61.staff_cd_comm"/>
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
    <item  name="報告者ID" len="8" value="in_hospital_cd_1:-61.staff_cd_comm"/>
    <item  name="報告部署" len="3" value="dataset:-60.report_post"/>
    <item  name="報告日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="実施者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="実施者ID" len="8" value="in_hospital_cd_1:-61.staff_cd_comm"/>
    <item  name="実施部署" len="3" value="dataset:-60.execution_post"/>
    <item  name="実施日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="承認者ID" len="8" value="in_hospital_cd_1:-61.staff_cd_comm"/>
    <item  name="承認日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認状態" len="1" value="const:1"/>
    <item  name="ComLib連携フラグ" len="1" value="const:0"/>
    <item  name="レポート情報" len="12" value="const:&lt;EMBED src=&quot;"/>
    <item  name="レポート情報" len="32" value="dataset:-62.pdf_file"/>
    <item  name="レポート情報" len="29" value="const:&quot; width=&quot;100%25&quot; height=&quot;100%25&quot;&gt;"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -55, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -22}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -62}, {"sqlCode": -60, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -52, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -61, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2025-01-02 18:26:36.811', CURRENT_TIMESTAMP);
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080003, 'F_hosp', 'rep_dial', '', 'S', 'del', 'text', 'fujitsu', 'fujitsu', 'report(HTML本文送信)', '1', '<root name="透析レポート(HTML本文送信)">
    <item  name="電文種別" len="2" value="const:VR"/>
    <item  name="レコード継続指示" len="1" value="const:E"/>
    <item  name="送信先システムコード" len="2" value="const:XX"/>
    <item  name="発信元システムコード" len="2" value="const:VN"/>
    <item  name="処理年月日" len="8" value="$SYSDATE"/>
    <item  name="処理時刻" len="6" value="$SYSTIME"/>
    <item  name="端末名" len="8" value="const:VOSERVER"/>
    <item  name="利用者番号" len="8" value="in_hospital_cd_1:-61.staff_cd_comm"/>
    <item  name="処理区分" len="2" value="const:03"/>
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
    <item  name="報告者ID" len="8" value="in_hospital_cd_1:-61.staff_cd_comm"/>
    <item  name="報告部署" len="3" value="dataset:-60.report_post"/>
    <item  name="報告日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="実施者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="実施者ID" len="8" value="in_hospital_cd_1:-61.staff_cd_comm"/>
    <item  name="実施部署" len="3" value="dataset:-60.execution_post"/>
    <item  name="実施日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="承認者ID" len="8" value="in_hospital_cd_1:-61.staff_cd_comm"/>
    <item  name="承認日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認状態" len="1" value="const:1"/>
    <item  name="ComLib連携フラグ" len="1" value="const:0"/>
    <item  name="レポート情報" len="12" value="const:&lt;EMBED src=&quot;"/>
    <item  name="レポート情報" len="32" value="dataset:-62.pdf_file"/>
    <item  name="レポート情報" len="29" value="const:&quot; width=&quot;100%25&quot; height=&quot;100%25&quot;&gt;"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -55, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -22}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -62}, {"sqlCode": -60, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -52, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -61, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2025-01-02 18:26:36.811', CURRENT_TIMESTAMP);
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2080001, 'F_hosp', 'rep_dial', '', 'S', 'cre', 'text', 'fujitsu', 'fujitsu', 'report(HTML本文送信)', '1', '<root name="透析レポート(HTML本文送信)">
    <item  name="電文種別" len="2" value="const:VR"/>
    <item  name="レコード継続指示" len="1" value="const:E"/>
    <item  name="送信先システムコード" len="2" value="const:XX"/>
    <item  name="発信元システムコード" len="2" value="const:VN"/>
    <item  name="処理年月日" len="8" value="$SYSDATE"/>
    <item  name="処理時刻" len="6" value="$SYSTIME"/>
    <item  name="端末名" len="8" value="const:VOSERVER"/>
    <item  name="利用者番号" len="8" value="in_hospital_cd_1:-61.staff_cd_comm"/>
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
    <item  name="報告者ID" len="8" value="in_hospital_cd_1:-61.staff_cd_comm"/>
    <item  name="報告部署" len="3" value="dataset:-60.report_post"/>
    <item  name="報告日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="実施者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="実施者ID" len="8" value="in_hospital_cd_1:-61.staff_cd_comm"/>
    <item  name="実施部署" len="3" value="dataset:-60.execution_post"/>
    <item  name="実施日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認者" len="20" value="staff_name:-61.staff_name_comm"/>
    <item  name="承認者ID" len="8" value="in_hospital_cd_1:-61.staff_cd_comm"/>
    <item  name="承認日時" len="14" value="dataset:-11.up_date14"/>
    <item  name="承認状態" len="1" value="const:1"/>
    <item  name="ComLib連携フラグ" len="1" value="const:0"/>
    <item  name="レポート情報" len="12" value="const:&lt;EMBED src=&quot;"/>
    <item  name="レポート情報" len="32" value="dataset:-62.pdf_file"/>
    <item  name="レポート情報" len="29" value="const:&quot; width=&quot;100%25&quot; height=&quot;100%25&quot;&gt;"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -55, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -22}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -62}, {"sqlCode": -60, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -52, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -61, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2020-05-25 18:26:36.811', CURRENT_TIMESTAMP);
