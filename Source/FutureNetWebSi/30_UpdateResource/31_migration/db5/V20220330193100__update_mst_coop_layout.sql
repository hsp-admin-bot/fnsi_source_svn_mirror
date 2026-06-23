delete from "mst_coop_layout" where "ctl_no" in (-4060001,-4060002,-4060003);
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4060003, 'P_hosp', 'accept', '', 'S', 'del', 'text', 'パナソニック 受付情報', 'Medicom', '受付情報', '1', '<root name="再来受付">
    <item  name="再受機No" len="2" value="dataset:-457.reconnection"/>
    <item  name="患者コード" len="13" value="dataset:-300001.hosp_pat_id"/>
    <item  name="保険種別" len="3" value="$BLANK"/>
    <item  name="外/入" len="1" value="const:1"/>
    <item  name="初/再" len="1" value="const:2"/>
    <item  name="来院理由" len="4" value="dataset:-457.in_hosptial_reason"/>
    <item  name="初回来院" len="1" value="$BLANK"/>
    <item  name="保険追加" len="1" value="$BLANK"/>
    <item  name="頭書修正" len="1" value="$BLANK"/>
    <item  name="予備" len="1" value="$BLANK"/>
    <item  name="予約/緊急" len="1" value="$BLANK"/>
    <item  name="医師１" len="4" value="dataset:-457.staff_cd"/>
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
    <item  name="コメント" len="40" value="dataset:-455.comment" padding_format="fblank" padding_position="right" subMode="L"/>
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
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -300001}, {"patId": "patId", "sqlCode": -455}, {"ordNo": "ordNo", "sqlCode": -456, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -457, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -1001}], "dumpFileName": {"patId": "patId", "sqlCode": -99998}}', '1', '0', -2, '2020-03-17 16:25:14.394', CURRENT_TIMESTAMP);
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4060001, 'P_hosp', 'accept', '', 'S', 'cre', 'text', 'パナソニック 受付情報', 'Medicom', '受付情報', '1', '<root name="再来受付">
    <item  name="再受機No" len="2" value="dataset:-457.reconnection"/>
    <item  name="患者コード" len="13" value="dataset:-300001.hosp_pat_id"/>
    <item  name="保険種別" len="3" value="$BLANK"/>
    <item  name="外/入" len="1" value="const:1"/>
    <item  name="初/再" len="1" value="const:2"/>
    <item  name="来院理由" len="4" value="dataset:-457.in_hosptial_reason"/>
    <item  name="初回来院" len="1" value="$BLANK"/>
    <item  name="保険追加" len="1" value="$BLANK"/>
    <item  name="頭書修正" len="1" value="$BLANK"/>
    <item  name="予備" len="1" value="$BLANK"/>
    <item  name="予約/緊急" len="1" value="$BLANK"/>
    <item  name="医師１" len="4" value="dataset:-457.staff_cd"/>
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
    <item  name="コメント" len="40" value="dataset:-455.comment" padding_format="fblank" padding_position="right" subMode="L"/>
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
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -300001}, {"patId": "patId", "sqlCode": -455}, {"ordNo": "ordNo", "sqlCode": -456, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -457, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -1001}], "dumpFileName": {"patId": "patId", "sqlCode": -99998}}', '1', '0', -2, '2020-03-17 16:25:14.394', CURRENT_TIMESTAMP);
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4060002, 'P_hosp', 'accept', '', 'S', 'upd', 'text', 'パナソニック 受付情報', 'Medicom', '受付情報', '1', '<root name="再来受付">
    <item  name="再受機No" len="2" value="dataset:-457.reconnection"/>
    <item  name="患者コード" len="13" value="dataset:-300001.hosp_pat_id"/>
    <item  name="保険種別" len="3" value="$BLANK"/>
    <item  name="外/入" len="1" value="const:1"/>
    <item  name="初/再" len="1" value="const:2"/>
    <item  name="来院理由" len="4" value="dataset:-457.in_hosptial_reason"/>
    <item  name="初回来院" len="1" value="$BLANK"/>
    <item  name="保険追加" len="1" value="$BLANK"/>
    <item  name="頭書修正" len="1" value="$BLANK"/>
    <item  name="予備" len="1" value="$BLANK"/>
    <item  name="予約/緊急" len="1" value="$BLANK"/>
    <item  name="医師１" len="4" value="dataset:-457.staff_cd"/>
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
    <item  name="コメント" len="40" value="dataset:-455.comment" padding_format="fblank" padding_position="right" subMode="L"/>
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
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -300001}, {"patId": "patId", "sqlCode": -455}, {"ordNo": "ordNo", "sqlCode": -456, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -457, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -1001}], "dumpFileName": {"patId": "patId", "sqlCode": -99998}}', '1', '0', -2, '2020-03-17 16:25:14.394', CURRENT_TIMESTAMP);

