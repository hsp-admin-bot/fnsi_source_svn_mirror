DELETE  FROM "ntss"."mst_coop_layout" WHERE ctl_no IN (-666663,
-666662,
-666661);
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-666663, 'F_hosp', 'phy_ord', '', 'S', 'del', 'text', '透析心電図', 'fujitsu', '透析心電図送信', '1', '<root name="透析心電図">
    <item  name="電文種別" len="2" value="const:VO"/>
    <item  name="レコード継続指示" len="1" value="const:E"/>
    <item  name="送信先システムコード" len="2" value="const:XX"/>
    <item  name="発信元システムコード"  len="2" value="const:VN"/>
    <item  name="処理情報.処理年月日" len="8" value="$SYSDATE"/>
    <item  name="処理情報.処理時刻" len="6" value="$SYSTIME"/>
    <item  name="端末名" len="8" value="const:VOSERVER"/>
    <item  name="利用者番号" len="8" value="dataset:-66673.disp_user_id"/>
    <item  name="処理区分" len="2" value="const:03"/>
    <item  name="応答種別" len="2" value="$BLANK"/>
    <item  name="電文長" len="6" value="$LENGTH"/>
    <item  name="エラーコード" len="5" value="$BLANK"/>
    <item  name="予備" len="12" value="$BLANK"/>
    <item  name="情報種別" len="2" value="const:05"/>
    <item  name="患者情報.患者番号" len="10" value="dataset:-66663.hosp_pat_id" padding_format="zero" padding_position="left"/>
		<item  name="伝票情報.オーダ番号(固定)" len="2" value="const:99"/>
    <item  name="伝票情報.オーダ番号" len="6" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="伝票情報.文書番号(先頭8文字）" len="8" value="const:VOSERVER"/>
    <item  name="伝票情報.文書番号(患者番号)" len="12" value="dataset:-66663.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="伝票情報.オーダ番号(固定)" len="2" value="const:99"/>
		<item  name="伝票情報.文書番号(オーダ番号)" len="6" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="伝票情報.文書番号(後2文字）" len="2" value="dataset:-66664.document_no"/>
    <item  name="伝票情報.文書版数" len="2" value="const:00"/>
    <item  name="伝票情報.関連オーダ番号" len="8" value="$BLANK"/>
    <item  name="伝票情報.オーダ日付" len="8" value="dataset:-66669.exam_date"/>
    <item  name="伝票情報.オーダ時間" len="6" value="dataset:-66669.exam_start_time"/>
    <item  name="伝票情報.保険パターン番号" len="2" value="dataset:-66666.insu_no"/>
    <item  name="伝票情報.入外区分" len="1" value="dataset:-66675.exam_in_out"/>
    <item  name="伝票情報.診療科コード" len="3" value="dataset:-66667.course_cd"/>
    <item  name="伝票情報.病棟コード" len="3" value="dataset:-66667.ward_cd"/>
    <item  name="伝票情報.利用者番号" len="8" value="dataset:-66674.disp_user_id"/>
    <item  name="伝票情報.伝票コード" len="4" value="dataset:-66668.slip_code"/>
    <item  name="伝票情報.伝票名称" len="50" value="dataset:-66668.slip_name"/>
    <item  name="予約情報.予約グループCD" len="4" value="$BLANK"/>
    <item  name="予約情報.予約枠コード" len="8" value="$BLANK" />
    <item  name="予約情報.予約開始日" len="8" value="$BLANK"/>
    <item  name="予約情報.予約開始時間" len="6" value="$BLANK"/>
    <item  name="予約情報.予約終了日" len="8" value="$BLANK"/>
    <item  name="予約情報.予約終了時間" len="6" value="$BLANK"/>
    <occ  name="明細行数" len="4" detail="透析心電図詳細del" sqlCode="-66671" padding_format="zero" padding_position="left"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -66663}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -66669, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -66673, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -66674, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -66664, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -66668, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -66675}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -66666, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -66667, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -66671, "facilityCd": "facilityCd"}]}', '1', '0', -1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, 'gx002');
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-666662, 'F_hosp', 'phy_ord', '', 'S', 'cre', 'text', '透析心電図', 'fujitsu', '透析心電図送信', '1', '<root name="透析心電図">
    <item  name="電文種別" len="2" value="const:VO"/>
    <item  name="レコード継続指示" len="1" value="const:E"/>
    <item  name="送信先システムコード" len="2" value="const:XX"/>
    <item  name="発信元システムコード"  len="2" value="const:VN"/>
    <item  name="処理情報.処理年月日" len="8" value="$SYSDATE"/>
    <item  name="処理情報.処理時刻" len="6" value="$SYSTIME"/>
    <item  name="端末名" len="8" value="const:VOSERVER"/>
    <item  name="利用者番号" len="8" value="dataset:-66661.disp_user_id"/>
    <item  name="処理区分" len="2" value="const:01"/>
    <item  name="応答種別" len="2" value="$BLANK"/>
    <item  name="電文長" len="6" value="$LENGTH"/>
    <item  name="エラーコード" len="5" value="$BLANK"/>
    <item  name="予備" len="12" value="$BLANK"/>
    <item  name="情報種別" len="2" value="const:05"/>
    <item  name="患者情報.患者番号" len="10" value="dataset:-66663.hosp_pat_id" padding_format="zero" padding_position="left"/>
		<item  name="伝票情報.オーダ番号(固定)" len="2" value="const:99"/>
    <item  name="伝票情報.オーダ番号" len="6" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="伝票情報.文書番号(先頭8文字）" len="8" value="const:VOSERVER"/>
    <item  name="伝票情報.文書番号(患者番号)" len="12" value="dataset:-66663.hosp_pat_id" padding_format="zero" padding_position="left"/>
   	<item  name="伝票情報.オーダ番号(固定)" len="2" value="const:99"/>
	  <item  name="伝票情報.文書番号(オーダ番号)" len="6" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="伝票情報.文書番号(後2文字）" len="2" value="dataset:-66664.document_no"/>
    <item  name="伝票情報.文書版数" len="2" value="const:00"/>
    <item  name="伝票情報.関連オーダ番号" len="8" value="$BLANK"/>
    <item  name="伝票情報.オーダ日付" len="8" value="dataset:-66665.exam_date"/>
    <item  name="伝票情報.オーダ時間" len="6" value="dataset:-66665.exam_start_time"/>
    <item  name="伝票情報.保険パターン番号" len="2" value="dataset:-66666.insu_no"/>
    <item  name="伝票情報.入外区分" len="1" value="dataset:-66675.exam_in_out"/>
    <item  name="伝票情報.診療科コード" len="3" value="dataset:-66667.course_cd"/>
    <item  name="伝票情報.病棟コード" len="3" value="dataset:-66667.ward_cd"/>
    <item  name="伝票情報.利用者番号" len="8" value="dataset:-66662.disp_user_id"/>
    <item  name="伝票情報.伝票コード" len="4" value="dataset:-66668.slip_code"/>
    <item  name="伝票情報.伝票名称" len="50" value="dataset:-66668.slip_name"/>
    <item  name="予約情報.予約グループCD" len="4" value="$BLANK"/>
    <item  name="予約情報.予約枠コード" len="8" value="$BLANK" />
    <item  name="予約情報.予約開始日" len="8" value="$BLANK"/>
    <item  name="予約情報.予約開始時間" len="6" value="$BLANK"/>
    <item  name="予約情報.予約終了日" len="8" value="$BLANK"/>
    <item  name="予約情報.予約終了時間" len="6" value="$BLANK"/>
    <occ  name="明細行数" len="4" detail="透析心電図詳細" sqlCode="-66670" padding_format="zero" padding_position="left"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -66663}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -66665, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -66661, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -66662, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -66664, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -66668, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -66666, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}, {"patId": "patId", "sqlCode": -66675}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -66667, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -66670, "facilityCd": "facilityCd"}]}', '1', '0', -1, CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, 'gx002');
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-666661, 'F_hosp', 'phy_ord', '', 'S', 'upd', 'text', '透析心電図', 'fujitsu', '透析心電図送信', '1', '<root name="透析心電図">
    <item  name="電文種別" len="2" value="const:VO"/>
    <item  name="レコード継続指示" len="1" value="const:E"/>
    <item  name="送信先システムコード" len="2" value="const:XX"/>
    <item  name="発信元システムコード"  len="2" value="const:VN"/>
    <item  name="処理情報.処理年月日" len="8" value="$SYSDATE"/>
    <item  name="処理情報.処理時刻" len="6" value="$SYSTIME"/>
    <item  name="端末名" len="8" value="const:VOSERVER"/>
    <item  name="利用者番号" len="8" value="dataset:-66661.disp_user_id"/>
    <item  name="処理区分" len="2" value="const:02"/>
    <item  name="応答種別" len="2" value="$BLANK"/>
    <item  name="電文長" len="6" value="$LENGTH"/>
    <item  name="エラーコード" len="5" value="$BLANK"/>
    <item  name="予備" len="12" value="$BLANK"/>
    <item  name="情報種別" len="2" value="const:05"/>
    <item  name="患者情報.患者番号" len="10" value="dataset:-66663.hosp_pat_id" padding_format="zero" padding_position="left"/>
		<item  name="伝票情報.オーダ番号(固定)" len="2" value="const:99"/>
    <item  name="伝票情報.オーダ番号" len="6" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="伝票情報.文書番号(先頭8文字）" len="8" value="const:VOSERVER"/>
    <item  name="伝票情報.文書番号(患者番号)" len="12" value="dataset:-66663.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="伝票情報.オーダ番号(固定)" len="2" value="const:99"/>
		<item  name="伝票情報.文書番号(オーダ番号)" len="6" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="伝票情報.文書番号(後2文字）" len="2" value="dataset:-66664.document_no"/>
    <item  name="伝票情報.文書版数" len="2" value="const:00"/>
    <item  name="伝票情報.関連オーダ番号" len="8" value="$BLANK"/>
    <item  name="伝票情報.オーダ日付" len="8" value="dataset:-66665.exam_date"/>
    <item  name="伝票情報.オーダ時間" len="6" value="dataset:-66665.exam_start_time"/>
    <item  name="伝票情報.保険パターン番号" len="2" value="dataset:-66666.insu_no"/>
    <item  name="伝票情報.入外区分" len="1" value="dataset:-66675.exam_in_out"/>
    <item  name="伝票情報.診療科コード" len="3" value="dataset:-66667.course_cd"/>
    <item  name="伝票情報.病棟コード" len="3" value="dataset:-66667.ward_cd"/>
    <item  name="伝票情報.利用者番号" len="8" value="dataset:-66662.disp_user_id"/>
    <item  name="伝票情報.伝票コード" len="4" value="dataset:-66668.slip_code"/>
    <item  name="伝票情報.伝票名称" len="50" value="dataset:-66668.slip_name"/>
    <item  name="予約情報.予約グループCD" len="4" value="$BLANK"/>
    <item  name="予約情報.予約枠コード" len="8" value="$BLANK" />
    <item  name="予約情報.予約開始日" len="8" value="$BLANK"/>
    <item  name="予約情報.予約開始時間" len="6" value="$BLANK"/>
    <item  name="予約情報.予約終了日" len="8" value="$BLANK"/>
    <item  name="予約情報.予約終了時間" len="6" value="$BLANK"/>
    <occ  name="明細行数" len="4" detail="透析心電図詳細" sqlCode="-66670" padding_format="zero" padding_position="left"/>
    <item  name="終端" len="1" value="$CR"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -66663}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -66665, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -66661, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -66662, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -66664, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -66668, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -66675}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -66666, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -66667, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -66670, "facilityCd": "facilityCd"}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'gx002');
