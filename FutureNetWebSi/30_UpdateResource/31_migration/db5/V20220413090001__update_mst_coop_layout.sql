DELETE FROM "ntss"."mst_coop_layout" where "ctl_no" IN (-2040001,-2040002,-2040003);
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2040003, 'F_hosp', 'ind_dial', '', 'S', 'del', 'text', '富士通予約', 'fujitsu', '予約送信', '1', '<root name="富士通透析予約">
<item name="電文種別" len="2" value="const:VO"/>
<item name="レコード継続指示" len="1" value="const:E"/>
<item name="送信先システムコード" len="2" value="const:XX"/>
<item name="発信元システムコード" len="2" value="const:VN"/>
<item name="処理情報.処理年月日" len="8" value="$SYSDATE"/>
<item name="処理情報.処理時刻" len="6" value="$SYSTIME"/>
<item name="端末名" len="8" value="const:VOSERVER"/>
<item name="利用者番号" len="8" value="dataset:-8.staff_cd_comm"/>
<item name="処理区分" len="2" value="const:03"/>
<item name="応答種別" len="2" value="$BLANK"/>
<item name="電文長" len="6" value="$LENGTH"/>
<item name="エラーコード" len="5" value="$BLANK"/>
<item name="予備" len="12" value="$BLANK"/>
<item name="情報種別" len="2" value="const:01"/>
<item name="患者情報.患者番号" len="10" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
<item name="伝票情報.オーダ番号(固定)" len="2" value="const:99"/>
<item name="伝票情報.オーダ番号" len="6" value="$JOURNAL.ord_no" padding_format="zero" padding_position="left" subMode="R"/>
<item name="伝票情報.文書番号(先頭8文字）" len="8" value="const:VOSERVER"/>
<item name="伝票情報.文書番号(患者番号)" len="12" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
<item name="伝票情報.文書番号(オーダ番号)" len="10" value="dataset:-64.ord_no"/>
<item name="伝票情報.文書版数" len="2" value="const:00"/>
<item name="伝票情報.関連オーダ番号" len="8" value="dataset:-54.ord_no"/>
<item name="伝票情報.オーダ日付" len="8" value="dataset:-59.treat_date"/>
<item name="伝票情報.オーダ時間" len="6" value="dataset:-59.start_time"/>
<item name="伝票情報.保険パターン番号" len="2" value="dataset:-54.insu_no"/>
<item name="伝票情報.入外区分" len="1" value="dataset:-20.exam_in_out"/>
<item name="伝票情報.診療科コード" len="3" value="dataset:-51.course_cd"/>
<item name="伝票情報.病棟コード" len="3" value="dataset:-51.ward_cd"/>
<item name="伝票情報.利用者番号" len="8" value="dataset:-8.staff_cd_data"/>
<item name="伝票情報.伝票コード" len="4" value="const:V002"/>
<item name="伝票情報.伝票名称" len="50" value="const:血液浄化予定"/>
<item name="予約情報.予約グループCD" len="4" value="const:V"/>
<item name="予約情報.予約枠コード" len="8" value="dataset:-58.in_hospital_cd"/>
<item name="予約情報.予約開始日" len="8" value="dataset:-53.start_date"/>
<item name="予約情報.予約開始時間" len="6" value="dataset:-53.start_time"/>
<item name="予約情報.予約終了日" len="8" value="dataset:-53.end_date"/>
<item name="予約情報.予約終了時間" len="6" value="dataset:-53.end_time"/>
<occ name="明細行数" len="4" detail="予約詳細" sqlCode="-103" padding_format="zero" padding_position="left"/>
<item name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -100001}, {"ordNo": "ordNo", "sqlCode": -59, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -54, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -53, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -51, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -103, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -13}, {"ordNo": "ordNo", "sqlCode": -58, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -8, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -64, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -20}], "dumpFileName": {"patId": "patId", "sqlCode": -102}}', '1', '0', 4, '2020-05-01 10:15:53.808', CURRENT_TIMESTAMP);
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2040002, 'F_hosp', 'ind_dial', '', 'S', 'upd', 'text', '富士通予約', 'fujitsu', '予約送信', '1', '<root name="富士通透析予約">
<item name="電文種別" len="2" value="const:VO"/>
<item name="レコード継続指示" len="1" value="const:E"/>
<item name="送信先システムコード" len="2" value="const:XX"/>
<item name="発信元システムコード" len="2" value="const:VN"/>
<item name="処理情報.処理年月日" len="8" value="$SYSDATE"/>
<item name="処理情報.処理時刻" len="6" value="$SYSTIME"/>
<item name="端末名" len="8" value="const:VOSERVER"/>
<item name="利用者番号" len="8" value="dataset:-8.staff_cd_comm"/>
<item name="処理区分" len="2" value="const:02"/>
<item name="応答種別" len="2" value="$BLANK"/>
<item name="電文長" len="6" value="$LENGTH"/>
<item name="エラーコード" len="5" value="$BLANK"/>
<item name="予備" len="12" value="$BLANK"/>
<item name="情報種別" len="2" value="const:01"/>
<item name="患者情報.患者番号" len="10" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
<item name="伝票情報.オーダ番号(固定)" len="2" value="const:99"/>
<item name="伝票情報.オーダ番号" len="6" value="$JOURNAL.ord_no" padding_format="zero" padding_position="left" subMode="R"/>
<item name="伝票情報.文書番号(先頭8文字）" len="8" value="const:VOSERVER"/>
<item name="伝票情報.文書番号(患者番号)" len="12" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
<item name="伝票情報.文書番号(オーダ番号)" len="10" value="dataset:-64.ord_no"/>
<item name="伝票情報.文書版数" len="2" value="const:00"/>
<item name="伝票情報.関連オーダ番号" len="8" value="dataset:-54.ord_no"/>
<item name="伝票情報.オーダ日付" len="8" value="dataset:-59.treat_date"/>
<item name="伝票情報.オーダ時間" len="6" value="dataset:-59.start_time"/>
<item name="伝票情報.保険パターン番号" len="2" value="dataset:-54.insu_no"/>
<item name="伝票情報.入外区分" len="1" value="dataset:-20.exam_in_out"/>
<item name="伝票情報.診療科コード" len="3" value="dataset:-51.course_cd"/>
<item name="伝票情報.病棟コード" len="3" value="dataset:-51.ward_cd"/>
<item name="伝票情報.利用者番号" len="8" value="dataset:-8.staff_cd_data"/>
<item name="伝票情報.伝票コード" len="4" value="const:V002"/>
<item name="伝票情報.伝票名称" len="50" value="const:血液浄化予定"/>
<item name="予約情報.予約グループCD" len="4" value="const:V"/>
<item name="予約情報.予約枠コード" len="8" value="dataset:-58.in_hospital_cd"/>
<item name="予約情報.予約開始日" len="8" value="dataset:-53.start_date"/>
<item name="予約情報.予約開始時間" len="6" value="dataset:-53.start_time"/>
<item name="予約情報.予約終了日" len="8" value="dataset:-53.end_date"/>
<item name="予約情報.予約終了時間" len="6" value="dataset:-53.end_time"/>
<occ name="明細行数" len="4" detail="予約詳細" sqlCode="-103" padding_format="zero" padding_position="left"/>
<item name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -100001}, {"ordNo": "ordNo", "sqlCode": -59, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -54, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -53, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -51, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -103, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -13}, {"ordNo": "ordNo", "sqlCode": -58, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -8, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -64, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -20}], "dumpFileName": {"patId": "patId", "sqlCode": -102}}', '1', '0', 4, '2020-05-01 10:15:53.808', CURRENT_TIMESTAMP);
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2040001, 'F_hosp', 'ind_dial', '', 'S', 'cre', 'text', '富士通予約', 'fujitsu', '予約送信', '1', '<root name="富士通透析予約">
<item name="電文種別" len="2" value="const:VO"/>
<item name="レコード継続指示" len="1" value="const:E"/>
<item name="送信先システムコード" len="2" value="const:XX"/>
<item name="発信元システムコード" len="2" value="const:VN"/>
<item name="処理情報.処理年月日" len="8" value="$SYSDATE"/>
<item name="処理情報.処理時刻" len="6" value="$SYSTIME"/>
<item name="端末名" len="8" value="const:VOSERVER"/>
<item name="利用者番号" len="8" value="dataset:-8.staff_cd_comm"/>
<item name="処理区分" len="2" value="const:01"/>
<item name="応答種別" len="2" value="$BLANK"/>
<item name="電文長" len="6" value="$LENGTH"/>
<item name="エラーコード" len="5" value="$BLANK"/>
<item name="予備" len="12" value="$BLANK"/>
<item name="情報種別" len="2" value="const:01"/>
<item name="患者情報.患者番号" len="10" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
<item name="伝票情報.オーダ番号(固定)" len="2" value="const:99"/>
<item name="伝票情報.オーダ番号" len="6" value="$JOURNAL.ord_no" padding_format="zero" padding_position="left" subMode="R"/>
<item name="伝票情報.文書番号(先頭8文字）" len="8" value="const:VOSERVER"/>
<item name="伝票情報.文書番号(患者番号)" len="12" value="dataset:-100001.hosp_pat_id" padding_format="zero" padding_position="left"/>
<item name="伝票情報.文書番号(オーダ番号)" len="10" value="dataset:-64.ord_no"/>
<item name="伝票情報.文書版数" len="2" value="const:00"/>
<item name="伝票情報.関連オーダ番号" len="8" value="dataset:-54.ord_no"/>
<item name="伝票情報.オーダ日付" len="8" value="dataset:-59.treat_date"/>
<item name="伝票情報.オーダ時間" len="6" value="dataset:-59.start_time"/>
<item name="伝票情報.保険パターン番号" len="2" value="dataset:-54.insu_no"/>
<item name="伝票情報.入外区分" len="1" value="dataset:-20.exam_in_out"/>
<item name="伝票情報.診療科コード" len="3" value="dataset:-51.course_cd"/>
<item name="伝票情報.病棟コード" len="3" value="dataset:-51.ward_cd"/>
<item name="伝票情報.利用者番号" len="8" value="dataset:-8.staff_cd_data"/>
<item name="伝票情報.伝票コード" len="4" value="const:V002"/>
<item name="伝票情報.伝票名称" len="50" value="const:血液浄化予定"/>
<item name="予約情報.予約グループCD" len="4" value="const:V"/>
<item name="予約情報.予約枠コード" len="8" value="dataset:-58.in_hospital_cd"/>
<item name="予約情報.予約開始日" len="8" value="dataset:-53.start_date"/>
<item name="予約情報.予約開始時間" len="6" value="dataset:-53.start_time"/>
<item name="予約情報.予約終了日" len="8" value="dataset:-53.end_date"/>
<item name="予約情報.予約終了時間" len="6" value="dataset:-53.end_time"/>
<occ name="明細行数" len="4" detail="予約詳細" sqlCode="-103" padding_format="zero" padding_position="left"/>
<item name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -100001}, {"ordNo": "ordNo", "sqlCode": -59, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -54, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -53, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -51, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -103, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -13}, {"ordNo": "ordNo", "sqlCode": -58, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -8, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -64, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -20}], "dumpFileName": {"patId": "patId", "sqlCode": -102}}', '1', '0', 4, '2020-05-01 10:15:53.808', CURRENT_TIMESTAMP);
