delete from "mst_coop_layout" where "ctl_no" in (-2040001,-2040002,-2040003);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2040001, 'F_hosp', 'ind_dial', '', 'S', 'cre', 'text', '富士通予約', 'fujitsu', '予約送信', '1', ' <root name="富士通透析予約">
<item name="電文種別" len="2" value="const:VO"/>
<item name="レコード継続指示" len="1" value="const:E"/>
<item name="送信先システムコード" len="2" value="const:XX"/>
<item name="発信元システムコード" len="2" value="const:VN"/>
<item name="処理情報.処理年月日" len="8" value="$SYSDATE"/>
<item name="処理情報.処理時刻" len="6" value="$SYSTIME"/>
<item name="端末名" len="8" value="const:VOSERVER"/>
<item name="利用者番号" len="8" value="dataset:-22.staff_id"/>
<item name="処理区分" len="2" value="const:01"/>
<item name="応答種別" len="2" value="$BLANK"/>
<item name="電文長" len="6" value="$LENGTH"/>
<item name="エラーコード" len="5" value="$BLANK"/>
<item name="予備" len="12" value="$BLANK"/>
<item name="情報種別" len="2" value="const:01"/>
<item name="患者情報.患者番号" len="10" value="dataset:1.hosp_pat_id"/>
<item name="伝票情報.オーダ番号" len="8" value="$JOURNAL.coop_ord_no" padding_format="zero"/>
<item name="伝票情報.文書番号(先頭8文字）" len="8" value="const:VOSERVER"/>
<item name="伝票情報.文書番号" len="20" value="$JOURNAL.ord_no" padding_format="zero" padding_position="right"/>
<item name="伝票情報.文書番号(後2文字）" len="2" value="const:00"/>
<item name="伝票情報.文書版数" len="2" value="const:00"/>
<item name="伝票情報.関連オーダ番号" len="8" value="dataset:-102.param01"/>
<item name="伝票情報.オーダ日付" len="8" value="dataset:-14.start_date8"/>
<item name="伝票情報.オーダ時間" len="6" value="dataset:-14.start_date6"/>
<item name="伝票情報.保険パターン番号" len="2" value="const:10"/>
<item name="伝票情報.入外区分" len="1" value="dataset:-11.in_out_f"/>
<item name="伝票情報.診療科コード" len="3" value="dataset:19.main_course_name"/>
<item name="伝票情報.病棟コード" len="3" value="dataset:19.ward_name"/>
<item name="伝票情報.利用者番号" len="8" value="dataset:-22.staff_id"/>
<item name="伝票情報.伝票コード" len="4" value="const:V002"/>
<item name="伝票情報.伝票名称" len="50" value="const:血液浄化予定"/>
<item name="予約情報.予約グループCD" len="4" value="const:V"/>
<item name="予約情報.予約枠コード(頭）" len="2" value="const:V"/>
<item name="予約情報.予約枠コード" len="6" value="dataset:45.bed_cd" padding_format="zero"/>
<item name="予約情報.予約開始日" len="8" value="$BLANK"/>
<item name="予約情報.予約開始時間" len="6" value="$BLANK"/>
<item name="予約情報.予約終了日" len="8" value="$BLANK"/>
<item name="予約情報.予約終了時間" len="6" value="$BLANK"/>
<occ name="明細行数" len="4" detail="予約詳細" sqlCode="-103"/>
<item name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": 1}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -102}, {"patId": "patId", "sqlCode": 19}, {"ordNo": "ordNo", "sqlCode": -103}, {"ordNo": "ordNo", "sqlCode": -13}, {"ordNo": "ordNo", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": 45}, {"ordNo": "ordNo", "sqlCode": -22}], "dumpFileName": {"patId": "patId", "sqlCode": -102}}', '1', '0', 4, '2020-05-01 10:15:53.808', '2020-05-01 10:16:00.803');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2040002, 'F_hosp', 'ind_dial', '', 'S', 'upd', 'text', '富士通予約', 'fujitsu', '予約送信', '1', ' <root name="富士通透析予約">
<item name="電文種別" len="2" value="const:VO"/>
<item name="レコード継続指示" len="1" value="const:E"/>
<item name="送信先システムコード" len="2" value="const:XX"/>
<item name="発信元システムコード" len="2" value="const:VN"/>
<item name="処理情報.処理年月日" len="8" value="$SYSDATE"/>
<item name="処理情報.処理時刻" len="6" value="$SYSTIME"/>
<item name="端末名" len="8" value="const:VOSERVER"/>
<item name="利用者番号" len="8" value="dataset:-22.staff_id"/>
<item name="処理区分" len="2" value="const:02"/>
<item name="応答種別" len="2" value="$BLANK"/>
<item name="電文長" len="6" value="$LENGTH"/>
<item name="エラーコード" len="5" value="$BLANK"/>
<item name="予備" len="12" value="$BLANK"/>
<item name="情報種別" len="2" value="const:01"/>
<item name="患者情報.患者番号" len="10" value="dataset:1.hosp_pat_id"/>
<item name="伝票情報.オーダ番号" len="8" value="$JOURNAL.coop_ord_no" padding_format="zero"/>
<item name="伝票情報.文書番号(先頭8文字）" len="8" value="const:VOSERVER"/>
<item name="伝票情報.文書番号" len="20" value="$JOURNAL.ord_no" padding_format="zero" padding_position="right"/>
<item name="伝票情報.文書番号(後2文字）" len="2" value="const:00"/>
<item name="伝票情報.文書版数" len="2" value="const:00"/>
<item name="伝票情報.関連オーダ番号" len="8" value="dataset:-102.param01"/>
<item name="伝票情報.オーダ日付" len="8" value="dataset:-14.start_date8"/>
<item name="伝票情報.オーダ時間" len="6" value="dataset:-14.start_date6"/>
<item name="伝票情報.保険パターン番号" len="2" value="const:10"/>
<item name="伝票情報.入外区分" len="1" value="dataset:-11.in_out_f"/>
<item name="伝票情報.診療科コード" len="3" value="dataset:19.main_course_name"/>
<item name="伝票情報.病棟コード" len="3" value="dataset:19.ward_name"/>
<item name="伝票情報.利用者番号" len="8" value="dataset:-22.staff_id"/>
<item name="伝票情報.伝票コード" len="4" value="const:V002"/>
<item name="伝票情報.伝票名称" len="50" value="const:血液浄化予定"/>
<item name="予約情報.予約グループCD" len="4" value="const:V"/>
<item name="予約情報.予約枠コード(頭）" len="2" value="const:V"/>
<item name="予約情報.予約枠コード" len="6" value="dataset:45.bed_cd" padding_format="zero"/>
<item name="予約情報.予約開始日" len="8" value="$BLANK"/>
<item name="予約情報.予約開始時間" len="6" value="$BLANK"/>
<item name="予約情報.予約終了日" len="8" value="$BLANK"/>
<item name="予約情報.予約終了時間" len="6" value="$BLANK"/>
<occ name="明細行数" len="4" detail="予約詳細" sqlCode="-103"/>
<item name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": 1}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -102}, {"patId": "patId", "sqlCode": 19}, {"ordNo": "ordNo", "sqlCode": -103}, {"ordNo": "ordNo", "sqlCode": -13}, {"ordNo": "ordNo", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": 45}, {"ordNo": "ordNo", "sqlCode": -22}], "dumpFileName": {"patId": "patId", "sqlCode": -102}}', '1', '0', 4, '2020-05-01 10:15:53.808', '2020-05-01 10:16:00.803');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2040003, 'F_hosp', 'ind_dial', '', 'S', 'del', 'text', '富士通予約', 'fujitsu', '予約送信', '1', ' <root name="富士通透析予約">
<item name="電文種別" len="2" value="const:VO"/>
<item name="レコード継続指示" len="1" value="const:E"/>
<item name="送信先システムコード" len="2" value="const:XX"/>
<item name="発信元システムコード" len="2" value="const:VN"/>
<item name="処理情報.処理年月日" len="8" value="$SYSDATE"/>
<item name="処理情報.処理時刻" len="6" value="$SYSTIME"/>
<item name="端末名" len="8" value="const:VOSERVER"/>
<item name="利用者番号" len="8" value="dataset:-22.staff_id"/>
<item name="処理区分" len="2" value="const:03"/>
<item name="応答種別" len="2" value="$BLANK"/>
<item name="電文長" len="6" value="$LENGTH"/>
<item name="エラーコード" len="5" value="$BLANK"/>
<item name="予備" len="12" value="$BLANK"/>
<item name="情報種別" len="2" value="const:01"/>
<item name="患者情報.患者番号" len="10" value="dataset:1.hosp_pat_id"/>
<item name="伝票情報.オーダ番号" len="8" value="$JOURNAL.coop_ord_no" padding_format="zero"/>
<item name="伝票情報.文書番号(先頭8文字）" len="8" value="const:VOSERVER"/>
<item name="伝票情報.文書番号" len="20" value="$JOURNAL.ord_no" padding_format="zero" padding_position="right"/>
<item name="伝票情報.文書番号(後2文字）" len="2" value="const:00"/>
<item name="伝票情報.文書版数" len="2" value="const:00"/>
<item name="伝票情報.関連オーダ番号" len="8" value="dataset:-102.param01"/>
<item name="伝票情報.オーダ日付" len="8" value="dataset:-14.start_date8"/>
<item name="伝票情報.オーダ時間" len="6" value="dataset:-14.start_date6"/>
<item name="伝票情報.保険パターン番号" len="2" value="const:10"/>
<item name="伝票情報.入外区分" len="1" value="dataset:-11.in_out_f"/>
<item name="伝票情報.診療科コード" len="3" value="dataset:19.main_course_name"/>
<item name="伝票情報.病棟コード" len="3" value="dataset:19.ward_name"/>
<item name="伝票情報.利用者番号" len="8" value="dataset:-22.staff_id"/>
<item name="伝票情報.伝票コード" len="4" value="const:V002"/>
<item name="伝票情報.伝票名称" len="50" value="const:血液浄化予定"/>
<item name="予約情報.予約グループCD" len="4" value="const:V"/>
<item name="予約情報.予約枠コード(頭）" len="2" value="const:V"/>
<item name="予約情報.予約枠コード" len="6" value="dataset:45.bed_cd" padding_format="zero"/>
<item name="予約情報.予約開始日" len="8" value="$BLANK"/>
<item name="予約情報.予約開始時間" len="6" value="$BLANK"/>
<item name="予約情報.予約終了日" len="8" value="$BLANK"/>
<item name="予約情報.予約終了時間" len="6" value="$BLANK"/>
<occ name="明細行数" len="4" detail="予約詳細" sqlCode="-103"/>
<item name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": 1}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -102}, {"patId": "patId", "sqlCode": 19}, {"ordNo": "ordNo", "sqlCode": -103}, {"ordNo": "ordNo", "sqlCode": -13}, {"ordNo": "ordNo", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": 45}, {"ordNo": "ordNo", "sqlCode": -22}], "dumpFileName": {"patId": "patId", "sqlCode": -102}}', '1', '0', 4, '2020-05-01 10:15:53.808', '2020-05-01 10:16:00.803');
