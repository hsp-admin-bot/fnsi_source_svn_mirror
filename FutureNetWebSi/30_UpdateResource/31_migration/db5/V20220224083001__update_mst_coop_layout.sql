delete from "mst_coop_layout" where "ctl_no" in (-2100001,-2100002,-2100003,-2110001,-2110002,-2110003);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2100001, 'F_hosp', 'exam_ord', '', 'S', 'cre', 'text', '富士通検査依頼', 'fujitsu', '検体検査依頼', '1', '<root name="検査依頼">
    <item  name="電文種別" len="2" value="const:VO"/>
    <item  name="レコード継続指示" len="1" value="const:E"/>
    <item  name="送信先システムコード" len="2" value="const:XX"/>
    <item  name="発信元システムコード" len="2" value="const:VN"/>
    <item  name="処理情報.処理年月日" len="8" value="$SYSDATE"/>
    <item  name="処理情報.処理時刻" len="6" value="$SYSTIME"/>
    <item  name="端末名" len="8" value="const:VOSERVER"/>
    <item  name="利用者番号" len="8" value="in_hospital_cd_1:-26.staff_cd_comm"/>
    <item  name="処理区分" len="2" value="const:01"/>
    <item  name="応答種別" len="2" value="$BLANK"/>
    <item  name="電文長" len="6" value="$LENGTH"/>
    <item  name="エラーコード" len="5" value="$BLANK"/>
    <item  name="予備" len="12" value="$BLANK"/>
    <item  name="情報種別" len="2" value="const:03"/>
    <item  name="患者情報.患者番号" len="10" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="伝票情報.オーダ番号(固定)" len="2" value="const:99"/>
    <item  name="伝票情報.オーダ番号" len="6" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="伝票情報.文書番号(先頭8文字）" len="8" value="const:VOSERVER"/>
    <item  name="伝票情報.文書番号(患者番号)" len="12" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="伝票情報.文書番号(オーダ番号(固定))" len="2" value="const:99"/>
    <item  name="伝票情報.文書番号(オーダ番号)" len="6" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="伝票情報.文書番号(後2文字）" len="2" value="dataset:-48.document_no"/>
    <item  name="伝票情報.文書版数" len="2" value="const:00"/>
    <item  name="伝票情報.関連オーダ番号" len="8" value="$BLANK"/>
    <item  name="伝票情報.オーダ日付" len="8" value="dataset:-23.exam_date"/>
    <item  name="伝票情報.オーダ時間" len="6" value="dataset:-23.exam_start_time"/>
    <item  name="伝票情報.保険パターン番号" len="2" value="dataset:-54.insu_no"/>
    <item  name="伝票情報.入外区分" len="1" value="dataset:-20.exam_in_out"/>
    <item  name="伝票情報.診療科コード" len="3" value="dataset:-39.course_cd"/>
    <item  name="伝票情報.病棟コード" len="3" value="dataset:-39.ward_cd"/>
    <item  name="伝票情報.利用者番号" len="8" value="in_hospital_cd_1:-26.staff_cd_data"/>
    <item  name="伝票情報.伝票コード" len="4" value="dataset:-49.slip_code"/>
    <item  name="伝票情報.伝票名称" len="50" value="dataset:-49.slip_name"/>
    <item  name="予約情報.予約グループCD" len="4" value="$BLANK"/>
    <item  name="予約情報.予約枠コード(頭）" len="2" value="$BLANK"/>
    <item  name="予約情報.予約枠コード" len="6" value="$BLANK"/>
    <item  name="予約情報.予約開始日" len="8" value="$BLANK"/>
    <item  name="予約情報.予約開始時間" len="6" value="$BLANK"/>
    <item  name="予約情報.予約終了日" len="8" value="$BLANK"/>
    <item  name="予約情報.予約終了時間" len="6" value="$BLANK"/>
    <occ  name="明細行数" len="4" detail="検査項目" sqlCode="-25" padding_format="zero" padding_position="left"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -54, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -20}, {"ordNo": "ordNo", "sqlCode": -23, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -25, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -26, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -39, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"sqlCode": -48, "facilityCd": "facilityCd"}, {"sqlCode": -49, "facilityCd": "facilityCd"}]}', '1', '0', -1, '2022-01-13 08:11:32.235', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2100002, 'F_hosp', 'exam_ord', '', 'S', 'upd', 'text', '富士通検査依頼', 'fujitsu', '検体検査依頼', '1', '<root name="検査依頼">
    <item  name="電文種別" len="2" value="const:VO"/>
    <item  name="レコード継続指示" len="1" value="const:E"/>
    <item  name="送信先システムコード" len="2" value="const:XX"/>
    <item  name="発信元システムコード" len="2" value="const:VN"/>
    <item  name="処理情報.処理年月日" len="8" value="$SYSDATE"/>
    <item  name="処理情報.処理時刻" len="6" value="$SYSTIME"/>
    <item  name="端末名" len="8" value="const:VOSERVER"/>
    <item  name="利用者番号" len="8" value="in_hospital_cd_1:-26.staff_cd_comm"/>
    <item  name="処理区分" len="2" value="const:02"/>
    <item  name="応答種別" len="2" value="$BLANK"/>
    <item  name="電文長" len="6" value="$LENGTH"/>
    <item  name="エラーコード" len="5" value="$BLANK"/>
    <item  name="予備" len="12" value="$BLANK"/>
    <item  name="情報種別" len="2" value="const:03"/>
    <item  name="患者情報.患者番号" len="10" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="伝票情報.オーダ番号(固定)" len="2" value="const:99"/>
    <item  name="伝票情報.オーダ番号" len="6" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="伝票情報.文書番号(先頭8文字）" len="8" value="const:VOSERVER"/>
    <item  name="伝票情報.文書番号(患者番号)" len="12" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="伝票情報.文書番号(オーダ番号(固定))" len="2" value="const:99"/>
    <item  name="伝票情報.文書番号(オーダ番号)" len="6" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="伝票情報.文書番号(後2文字）" len="2" value="dataset:-48.document_no"/>
    <item  name="伝票情報.文書版数" len="2" value="const:00"/>
    <item  name="伝票情報.関連オーダ番号" len="8" value="$BLANK"/>
    <item  name="伝票情報.オーダ日付" len="8" value="dataset:-23.exam_date"/>
    <item  name="伝票情報.オーダ時間" len="6" value="dataset:-23.exam_start_time"/>
    <item  name="伝票情報.保険パターン番号" len="2" value="dataset:-54.insu_no"/>
    <item  name="伝票情報.入外区分" len="1" value="dataset:-20.exam_in_out"/>
    <item  name="伝票情報.診療科コード" len="3" value="dataset:-39.course_cd"/>
    <item  name="伝票情報.病棟コード" len="3" value="dataset:-39.ward_cd"/>
    <item  name="伝票情報.利用者番号" len="8" value="in_hospital_cd_1:-26.staff_cd_data"/>
    <item  name="伝票情報.伝票コード" len="4" value="dataset:-49.slip_code"/>
    <item  name="伝票情報.伝票名称" len="50" value="dataset:-49.slip_name"/>
    <item  name="予約情報.予約グループCD" len="4" value="$BLANK"/>
    <item  name="予約情報.予約枠コード(頭）" len="2" value="$BLANK"/>
    <item  name="予約情報.予約枠コード" len="6" value="$BLANK"/>
    <item  name="予約情報.予約開始日" len="8" value="$BLANK"/>
    <item  name="予約情報.予約開始時間" len="6" value="$BLANK"/>
    <item  name="予約情報.予約終了日" len="8" value="$BLANK"/>
    <item  name="予約情報.予約終了時間" len="6" value="$BLANK"/>
    <occ  name="明細行数" len="4" detail="検査項目" sqlCode="-25" padding_format="zero" padding_position="left"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -54, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -20}, {"ordNo": "ordNo", "sqlCode": -23, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -25, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -26, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -39, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"sqlCode": -48, "facilityCd": "facilityCd"}, {"sqlCode": -49, "facilityCd": "facilityCd"}]}', '1', '0', -1, '2022-01-13 08:11:32.285', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2100003, 'F_hosp', 'exam_ord', '', 'S', 'del', 'text', '富士通検査依頼', 'fujitsu', '検体検査依頼', '1', '<root name="検査依頼">
    <item  name="電文種別" len="2" value="const:VO"/>
    <item  name="レコード継続指示" len="1" value="const:E"/>
    <item  name="送信先システムコード" len="2" value="const:XX"/>
    <item  name="発信元システムコード" len="2" value="const:VN"/>
    <item  name="処理情報.処理年月日" len="8" value="$SYSDATE"/>
    <item  name="処理情報.処理時刻" len="6" value="$SYSTIME"/>
    <item  name="端末名" len="8" value="const:VOSERVER"/>
    <item  name="利用者番号" len="8" value="in_hospital_cd_1:-44.staff_cd_comm"/>
    <item  name="処理区分" len="2" value="const:03"/>
    <item  name="応答種別" len="2" value="$BLANK"/>
    <item  name="電文長" len="6" value="$LENGTH"/>
    <item  name="エラーコード" len="5" value="$BLANK"/>
    <item  name="予備" len="12" value="$BLANK"/>
    <item  name="情報種別" len="2" value="const:03"/>
    <item  name="患者情報.患者番号" len="10" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="伝票情報.オーダ番号(固定)" len="2" value="const:99"/>
    <item  name="伝票情報.オーダ番号" len="6" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="伝票情報.文書番号(先頭8文字）" len="8" value="const:VOSERVER"/>
    <item  name="伝票情報.文書番号(患者番号)" len="12" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="伝票情報.文書番号(オーダ番号(固定))" len="2" value="const:99"/>
    <item  name="伝票情報.文書番号(オーダ番号)" len="6" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="伝票情報.文書番号(後2文字）" len="2" value="dataset:-48.document_no"/>
    <item  name="伝票情報.文書版数" len="2" value="const:00"/>
    <item  name="伝票情報.関連オーダ番号" len="8" value="$BLANK"/>
    <item  name="伝票情報.オーダ日付" len="8" value="dataset:-42.exam_date"/>
    <item  name="伝票情報.オーダ時間" len="6" value="dataset:-42.exam_start_time"/>
    <item  name="伝票情報.保険パターン番号" len="2" value="dataset:-54.insu_no"/>
    <item  name="伝票情報.入外区分" len="1" value="dataset:-20.exam_in_out"/>
    <item  name="伝票情報.診療科コード" len="3" value="dataset:-39.course_cd"/>
    <item  name="伝票情報.病棟コード" len="3" value="dataset:-39.ward_cd"/>
    <item  name="伝票情報.利用者番号" len="8" value="in_hospital_cd_1:-44.staff_cd_data"/>
    <item  name="伝票情報.伝票コード" len="4" value="dataset:-49.slip_code"/>
    <item  name="伝票情報.伝票名称" len="50" value="dataset:-49.slip_name"/>
    <item  name="予約情報.予約グループCD" len="4" value="$BLANK"/>
    <item  name="予約情報.予約枠コード(頭）" len="2" value="$BLANK"/>
    <item  name="予約情報.予約枠コード" len="6" value="$BLANK"/>
    <item  name="予約情報.予約開始日" len="8" value="$BLANK"/>
    <item  name="予約情報.予約開始時間" len="6" value="$BLANK"/>
    <item  name="予約情報.予約終了日" len="8" value="$BLANK"/>
    <item  name="予約情報.予約終了時間" len="6" value="$BLANK"/>
    <occ  name="明細行数" len="4" detail="検査項目_削除" sqlCode="-43" padding_format="zero" padding_position="left"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -54, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -20}, {"ordNo": "ordNo", "sqlCode": -42, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -43, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -44, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -39, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"sqlCode": -48, "facilityCd": "facilityCd"}, {"sqlCode": -49, "facilityCd": "facilityCd"}]}', '1', '0', -1, '2022-01-13 08:11:32.335', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2110001, 'F_hosp', 'rad_ord', '', 'S', 'cre', 'text', '富士通撮影依頼', 'fujitsu', '撮影依頼', '1', '<root name="撮影依頼">
    <item  name="電文種別" len="2" value="const:VO"/>
    <item  name="レコード継続指示" len="1" value="const:E"/>
    <item  name="送信先システムコード" len="2" value="const:XX"/>
    <item  name="発信元システムコード" len="2" value="const:VN"/>
    <item  name="処理情報.処理年月日" len="8" value="$SYSDATE"/>
    <item  name="処理情報.処理時刻" len="6" value="$SYSTIME"/>
    <item  name="端末名" len="8" value="const:VOSERVER"/>
    <item  name="利用者番号" len="8" value="in_hospital_cd_1:-28.staff_cd_comm"/>
    <item  name="処理区分" len="2" value="const:01"/>
    <item  name="応答種別" len="2" value="$BLANK"/>
    <item  name="電文長" len="6" value="$LENGTH"/>
    <item  name="エラーコード" len="5" value="$BLANK"/>
    <item  name="予備" len="12" value="$BLANK"/>
    <item  name="情報種別" len="2" value="const:04"/>
    <item  name="患者情報.患者番号" len="10" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="伝票情報.オーダ番号(固定)" len="2" value="const:99"/>
    <item  name="伝票情報.オーダ番号" len="6" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="伝票情報.文書番号(先頭8文字）" len="8" value="const:VOSERVER"/>
    <item  name="伝票情報.文書番号(患者番号)" len="12" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="伝票情報.文書番号(オーダ番号(固定))" len="2" value="const:99"/>
    <item  name="伝票情報.文書番号(オーダ番号)" len="6" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="伝票情報.文書番号(後2文字）" len="2" value="dataset:-48.document_no"/>
    <item  name="伝票情報.文書版数" len="2" value="const:00"/>
    <item  name="伝票情報.関連オーダ番号" len="8" value="$BLANK"/>
    <item  name="伝票情報.オーダ日付" len="8" value="dataset:-40.exam_date"/>
    <item  name="伝票情報.オーダ時間" len="6" value="dataset:-40.exam_start_time"/>
    <item  name="伝票情報.保険パターン番号" len="2" value="dataset:-54.insu_no"/>
    <item  name="伝票情報.入外区分" len="1" value="dataset:-20.exam_in_out"/>
    <item  name="伝票情報.診療科コード" len="3" value="dataset:-41.course_cd"/>
    <item  name="伝票情報.病棟コード" len="3" value="dataset:-41.ward_cd"/>
    <item  name="伝票情報.利用者番号" len="8" value="in_hospital_cd_1:-28.staff_cd_data"/>
    <item  name="伝票情報.伝票コード" len="4" value="dataset:-50.slip_code"/>
    <item  name="伝票情報.伝票名称" len="50" value="dataset:-50.slip_name"/>
    <item  name="予約情報.予約グループCD" len="4" value="$BLANK"/>
    <item  name="予約情報.予約枠コード(頭）" len="2" value="$BLANK"/>
    <item  name="予約情報.予約枠コード" len="6" value="$BLANK"/>
    <item  name="予約情報.予約開始日" len="8" value="$BLANK"/>
    <item  name="予約情報.予約開始時間" len="6" value="$BLANK"/>
    <item  name="予約情報.予約終了日" len="8" value="$BLANK"/>
    <item  name="予約情報.予約終了時間" len="6" value="$BLANK"/>
    <occ  name="明細行数" len="4" detail="撮影項目" sqlCode="-27" padding_format="zero" padding_position="left"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -54, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -20}, {"ordNo": "ordNo", "sqlCode": -40, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -27, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -28, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -41, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"sqlCode": -48, "facilityCd": "facilityCd"}, {"sqlCode": -50, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2022-01-14 18:29:49', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2110002, 'F_hosp', 'rad_ord', '', 'S', 'upd', 'text', '富士通撮影依頼', 'fujitsu', '撮影依頼', '1', '<root name="撮影依頼">
    <item  name="電文種別" len="2" value="const:VO"/>
    <item  name="レコード継続指示" len="1" value="const:E"/>
    <item  name="送信先システムコード" len="2" value="const:XX"/>
    <item  name="発信元システムコード" len="2" value="const:VN"/>
    <item  name="処理情報.処理年月日" len="8" value="$SYSDATE"/>
    <item  name="処理情報.処理時刻" len="6" value="$SYSTIME"/>
    <item  name="端末名" len="8" value="const:VOSERVER"/>
    <item  name="利用者番号" len="8" value="in_hospital_cd_1:-28.staff_cd_comm"/>
    <item  name="処理区分" len="2" value="const:02"/>
    <item  name="応答種別" len="2" value="$BLANK"/>
    <item  name="電文長" len="6" value="$LENGTH"/>
    <item  name="エラーコード" len="5" value="$BLANK"/>
    <item  name="予備" len="12" value="$BLANK"/>
    <item  name="情報種別" len="2" value="const:04"/>
    <item  name="患者情報.患者番号" len="10" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="伝票情報.オーダ番号(固定)" len="2" value="const:99"/>
    <item  name="伝票情報.オーダ番号" len="6" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="伝票情報.文書番号(先頭8文字）" len="8" value="const:VOSERVER"/>
    <item  name="伝票情報.文書番号(患者番号)" len="12" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="伝票情報.文書番号(オーダ番号(固定))" len="2" value="const:99"/>
    <item  name="伝票情報.文書番号(オーダ番号)" len="6" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="伝票情報.文書番号(後2文字）" len="2" value="dataset:-48.document_no"/>
    <item  name="伝票情報.文書版数" len="2" value="const:00"/>
    <item  name="伝票情報.関連オーダ番号" len="8" value="$BLANK"/>
    <item  name="伝票情報.オーダ日付" len="8" value="dataset:-40.exam_date"/>
    <item  name="伝票情報.オーダ時間" len="6" value="dataset:-40.exam_start_time"/>
    <item  name="伝票情報.保険パターン番号" len="2" value="dataset:-54.insu_no"/>
    <item  name="伝票情報.入外区分" len="1" value="dataset:-20.exam_in_out"/>
    <item  name="伝票情報.診療科コード" len="3" value="dataset:-41.course_cd"/>
    <item  name="伝票情報.病棟コード" len="3" value="dataset:-41.ward_cd"/>
    <item  name="伝票情報.利用者番号" len="8" value="in_hospital_cd_1:-28.staff_cd_data"/>
    <item  name="伝票情報.伝票コード" len="4" value="dataset:-50.slip_code"/>
    <item  name="伝票情報.伝票名称" len="50" value="dataset:-50.slip_name"/>
    <item  name="予約情報.予約グループCD" len="4" value="$BLANK"/>
    <item  name="予約情報.予約枠コード(頭）" len="2" value="$BLANK"/>
    <item  name="予約情報.予約枠コード" len="6" value="$BLANK"/>
    <item  name="予約情報.予約開始日" len="8" value="$BLANK"/>
    <item  name="予約情報.予約開始時間" len="6" value="$BLANK"/>
    <item  name="予約情報.予約終了日" len="8" value="$BLANK"/>
    <item  name="予約情報.予約終了時間" len="6" value="$BLANK"/>
    <occ  name="明細行数" len="4" detail="撮影項目" sqlCode="-27" padding_format="zero" padding_position="left"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -54, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -20}, {"ordNo": "ordNo", "sqlCode": -40, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -27, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -28, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -41, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"sqlCode": -48, "facilityCd": "facilityCd"}, {"sqlCode": -50, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2022-01-14 18:29:49', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2110003, 'F_hosp', 'rad_ord', '', 'S', 'del', 'text', '富士通撮影依頼', 'fujitsu', '撮影依頼', '1', '<root name="撮影依頼">
    <item  name="電文種別" len="2" value="const:VO"/>
    <item  name="レコード継続指示" len="1" value="const:E"/>
    <item  name="送信先システムコード" len="2" value="const:XX"/>
    <item  name="発信元システムコード" len="2" value="const:VN"/>
    <item  name="処理情報.処理年月日" len="8" value="$SYSDATE"/>
    <item  name="処理情報.処理時刻" len="6" value="$SYSTIME"/>
    <item  name="端末名" len="8" value="const:VOSERVER"/>
    <item  name="利用者番号" len="8" value="in_hospital_cd_1:-47.staff_cd_comm"/>
    <item  name="処理区分" len="2" value="const:03"/>
    <item  name="応答種別" len="2" value="$BLANK"/>
    <item  name="電文長" len="6" value="$LENGTH"/>
    <item  name="エラーコード" len="5" value="$BLANK"/>
    <item  name="予備" len="12" value="$BLANK"/>
    <item  name="情報種別" len="2" value="const:04"/>
    <item  name="患者情報.患者番号" len="10" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="伝票情報.オーダ番号(固定)" len="2" value="const:99"/>
    <item  name="伝票情報.オーダ番号" len="6" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="伝票情報.文書番号(先頭8文字）" len="8" value="const:VOSERVER"/>
    <item  name="伝票情報.文書番号(患者番号)" len="12" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="伝票情報.文書番号(オーダ番号(固定))" len="2" value="const:99"/>
    <item  name="伝票情報.文書番号(オーダ番号)" len="6" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="伝票情報.文書番号(後2文字）" len="2" value="dataset:-48.document_no"/>
    <item  name="伝票情報.文書版数" len="2" value="const:00"/>
    <item  name="伝票情報.関連オーダ番号" len="8" value="$BLANK"/>
    <item  name="伝票情報.オーダ日付" len="8" value="dataset:-45.exam_date"/>
    <item  name="伝票情報.オーダ時間" len="6" value="dataset:-45.exam_start_time"/>
    <item  name="伝票情報.保険パターン番号" len="2" value="dataset:-54.insu_no"/>
    <item  name="伝票情報.入外区分" len="1" value="dataset:-20.exam_in_out"/>
    <item  name="伝票情報.診療科コード" len="3" value="dataset:-41.course_cd"/>
    <item  name="伝票情報.病棟コード" len="3" value="dataset:-41.ward_cd"/>
    <item  name="伝票情報.利用者番号" len="8" value="in_hospital_cd_1:-47.staff_cd_data"/>
    <item  name="伝票情報.伝票コード" len="4" value="dataset:-50.slip_code"/>
    <item  name="伝票情報.伝票名称" len="50" value="dataset:-50.slip_name"/>
    <item  name="予約情報.予約グループCD" len="4" value="$BLANK"/>
    <item  name="予約情報.予約枠コード(頭）" len="2" value="$BLANK"/>
    <item  name="予約情報.予約枠コード" len="6" value="$BLANK"/>
    <item  name="予約情報.予約開始日" len="8" value="$BLANK"/>
    <item  name="予約情報.予約開始時間" len="6" value="$BLANK"/>
    <item  name="予約情報.予約終了日" len="8" value="$BLANK"/>
    <item  name="予約情報.予約終了時間" len="6" value="$BLANK"/>
    <occ  name="明細行数" len="4" detail="撮影項目_削除" sqlCode="-46" padding_format="zero" padding_position="left"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -54, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -20}, {"ordNo": "ordNo", "sqlCode": -45, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -46, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -47, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -41, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -100001}, {"sqlCode": -48, "facilityCd": "facilityCd"}, {"sqlCode": -50, "facilityCd": "facilityCd"}]}', '1', '0', 4, '2022-01-14 18:29:49', CURRENT_TIMESTAMP);
