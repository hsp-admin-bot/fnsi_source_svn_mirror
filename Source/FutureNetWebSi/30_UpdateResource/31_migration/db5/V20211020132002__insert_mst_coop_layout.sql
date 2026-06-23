delete from "mst_coop_layout" where "facility_cd"= 'P_hosp' and "coop_cd" = 'exam_ord';
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4100003, 'P_hosp', 'exam_ord', '', 'S', 'del', 'text', 'Medicom検査オーダ', 'Medicom', '検査オーダ', '1', '<root name="検査依頼">
    <item  name="レコード区分" len="2" value="const:01"/>
    <item  name="検査機関コード" len="6" value="const:000000"/>
    <item  name="依頼者KEY（日付）" len="6 " value="$SYSDATE" subMode="R"/>
    <item  name="依頼者KEY（受付番号）" len="4 " value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/>
    <item  name="RSV" len="10" value="$BLANK"/>
    <item  name="科コード・科名" len="15" value="$SYSDATE" padding_format="blank" padding_position="right"/>
    <item  name="病棟コード・病棟名" len="15" value="dataset:-452.ward_cd"/>
    <item  name="入院外来区分" len="1" value="dataset:-300001.in_out_class"/>
    <item  name="提出医" len="10" value="dataset:-24.staff_cd"/>
    <item  name="披験者ID" len="10" value="dataset:-300001.hosp_pat_id"/>
    <item  name="RSV" len="5" value="$BLANK"/>
    <item  name="カルテNO" len="10" value="dataset:-300001.hosp_pat_id"/>
    <item  name="RSV" len="5" value="$BLANK"/>
    <item  name="被験者名" len="20" value="dataset:-300001.pat_name"/>
    <item  name="性別" len="1" value="dataset:-300001.pat_sex"/>
    <item  name="年齢区分" len="1" value="const:Y"/>
    <item  name="年齢" len="3" value="dataset:-300001.pat_age"/>
    <item  name="生年月日区分" len="1" value="$BLANK"/>
    <item  name="生年月日" len="8" value="dataset:-300001.pat_birthday_yyyymmdd"/>
    <item  name="採取日" len="8" value="dataset:-23.exam_date"/>
    <item  name="採取時間" len="4" value="dataset:-23.exam_start_time"/>
    <item  name="項目数" len="3" value="dataset:-454.exam_set_cnt"/>
    <item  name="身長" len="4" value="$BLANK"/>
    <item  name="体重" len="4" value="$BLANK"/>
    <item  name="尿量（量）" len="4" value="$BLANK"/>
    <item  name="尿量（単位）" len="2" value="$BLANK"/>
    <item  name="妊娠週数" len="2" value="$BLANK"/>
    <item  name="透析前後" len="1" value="dataset:-31.exam_timing"/>
    <item  name="至急報告" len="1" value="$BLANK"/>
    <item  name="依頼コメント内容" len="50" value="$BLANK"/>
    <item  name="施設NO" len="6" value="const:000000"/>
    <item  name="RSV" len="30" value="$BLANK"/>
    <item  name="ベッド番号" len="4" value="dataset:-31.bed_cd"/>
    <item  name="改行" len="1" value="$CR"/>
    <occ  name="明細.検査項目" len="0" detail="検査項目" sqlCode="-453"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -300001}, {"patId": "patId", "sqlCode": -452}, {"ordNo": "ordNo", "sqlCode": -453}, {"ordNo": "ordNo", "sqlCode": -454}, {"ordNo": "ordNo", "sqlCode": -24}, {"ordNo": "ordNo", "sqlCode": -23}, {"ordNo": "ordNo", "sqlCode": -31}], "dumpFileName": {"ctlNo": "ctlNo", "patId": "patId", "sqlCode": -99995}}', '1', '0', 4, '2020-05-13 18:35:00.661', '2020-05-13 18:38:04.593');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4100002, 'P_hosp', 'exam_ord', '', 'S', 'upd', 'text', 'Medicom検査オーダ', 'Medicom', '検査オーダ', '1', '<root name="検査依頼">
    <item  name="レコード区分" len="2" value="const:01"/>
    <item  name="検査機関コード" len="6" value="const:000000"/>
    <item  name="依頼者KEY（日付）" len="6 " value="$SYSDATE" subMode="R"/>
    <item  name="依頼者KEY（受付番号）" len="4 " value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/>
    <item  name="RSV" len="10" value="$BLANK"/>
    <item  name="科コード・科名" len="15" value="$SYSDATE" padding_format="blank" padding_position="right"/>
    <item  name="病棟コード・病棟名" len="15" value="dataset:-452.ward_cd"/>
    <item  name="入院外来区分" len="1" value="dataset:-300001.in_out_class"/>
    <item  name="提出医" len="10" value="dataset:-24.staff_cd"/>
    <item  name="披験者ID" len="10" value="dataset:-300001.hosp_pat_id"/>
    <item  name="RSV" len="5" value="$BLANK"/>
    <item  name="カルテNO" len="10" value="dataset:-300001.hosp_pat_id"/>
    <item  name="RSV" len="5" value="$BLANK"/>
    <item  name="被験者名" len="20" value="dataset:-300001.pat_name"/>
    <item  name="性別" len="1" value="dataset:-300001.pat_sex"/>
    <item  name="年齢区分" len="1" value="const:Y"/>
    <item  name="年齢" len="3" value="dataset:-300001.pat_age"/>
    <item  name="生年月日区分" len="1" value="$BLANK"/>
    <item  name="生年月日" len="8" value="dataset:-300001.pat_birthday_yyyymmdd"/>
    <item  name="採取日" len="8" value="dataset:-23.exam_date"/>
    <item  name="採取時間" len="4" value="dataset:-23.exam_start_time"/>
    <item  name="項目数" len="3" value="dataset:-454.exam_set_cnt"/>
    <item  name="身長" len="4" value="$BLANK"/>
    <item  name="体重" len="4" value="$BLANK"/>
    <item  name="尿量（量）" len="4" value="$BLANK"/>
    <item  name="尿量（単位）" len="2" value="$BLANK"/>
    <item  name="妊娠週数" len="2" value="$BLANK"/>
    <item  name="透析前後" len="1" value="dataset:-31.exam_timing"/>
    <item  name="至急報告" len="1" value="$BLANK"/>
    <item  name="依頼コメント内容" len="50" value="$BLANK"/>
    <item  name="施設NO" len="6" value="const:000000"/>
    <item  name="RSV" len="30" value="$BLANK"/>
    <item  name="ベッド番号" len="4" value="dataset:-31.bed_cd"/>
    <item  name="改行" len="1" value="$CR"/>
    <occ  name="明細.検査項目" len="0" detail="検査項目" sqlCode="-453"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -300001}, {"patId": "patId", "sqlCode": -452}, {"ordNo": "ordNo", "sqlCode": -453}, {"ordNo": "ordNo", "sqlCode": -454}, {"ordNo": "ordNo", "sqlCode": -24}, {"ordNo": "ordNo", "sqlCode": -23}, {"ordNo": "ordNo", "sqlCode": -31}], "dumpFileName": {"ctlNo": "ctlNo", "patId": "patId", "sqlCode": -99995}}', '1', '0', 4, '2020-05-13 18:35:00.661', '2020-05-13 18:38:04.593');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4100001, 'P_hosp', 'exam_ord', '', 'S', 'cre', 'text', 'Medicom検査オーダ', 'Medicom', '検査オーダ', '1', '<root name="検査依頼">
    <item  name="レコード区分" len="2" value="const:01"/>
    <item  name="検査機関コード" len="6" value="const:000000"/>
    <item  name="依頼者KEY（日付）" len="6 " value="$SYSDATE" subMode="R"/>
    <item  name="依頼者KEY（受付番号）" len="4 " value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/>
    <item  name="RSV" len="10" value="$BLANK"/>
    <item  name="科コード・科名" len="15" value="$SYSDATE" padding_format="blank" padding_position="right"/>
    <item  name="病棟コード・病棟名" len="15" value="dataset:-452.ward_cd"/>
    <item  name="入院外来区分" len="1" value="dataset:-300001.in_out_class"/>
    <item  name="提出医" len="10" value="dataset:-24.staff_cd"/>
    <item  name="披験者ID" len="10" value="dataset:-300001.hosp_pat_id"/>
    <item  name="RSV" len="5" value="$BLANK"/>
    <item  name="カルテNO" len="10" value="dataset:-300001.hosp_pat_id"/>
    <item  name="RSV" len="5" value="$BLANK"/>
    <item  name="被験者名" len="20" value="dataset:-300001.pat_name"/>
    <item  name="性別" len="1" value="dataset:-300001.pat_sex"/>
    <item  name="年齢区分" len="1" value="const:Y"/>
    <item  name="年齢" len="3" value="dataset:-300001.pat_age"/>
    <item  name="生年月日区分" len="1" value="$BLANK"/>
    <item  name="生年月日" len="8" value="dataset:-300001.pat_birthday_yyyymmdd"/>
    <item  name="採取日" len="8" value="dataset:-23.exam_date"/>
    <item  name="採取時間" len="4" value="dataset:-23.exam_start_time"/>
    <item  name="項目数" len="3" value="dataset:-454.exam_set_cnt"/>
    <item  name="身長" len="4" value="$BLANK"/>
    <item  name="体重" len="4" value="$BLANK"/>
    <item  name="尿量（量）" len="4" value="$BLANK"/>
    <item  name="尿量（単位）" len="2" value="$BLANK"/>
    <item  name="妊娠週数" len="2" value="$BLANK"/>
    <item  name="透析前後" len="1" value="dataset:-31.exam_timing"/>
    <item  name="至急報告" len="1" value="$BLANK"/>
    <item  name="依頼コメント内容" len="50" value="$BLANK"/>
    <item  name="施設NO" len="6" value="const:000000"/>
    <item  name="RSV" len="30" value="$BLANK"/>
    <item  name="ベッド番号" len="4" value="dataset:-31.bed_cd"/>
    <item  name="改行" len="1" value="$CR"/>
    <occ  name="明細.検査項目" len="0" detail="検査項目" sqlCode="-453"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -300001}, {"patId": "patId", "sqlCode": -452}, {"ordNo": "ordNo", "sqlCode": -453}, {"ordNo": "ordNo", "sqlCode": -454}, {"ordNo": "ordNo", "sqlCode": -24}, {"ordNo": "ordNo", "sqlCode": -23}, {"ordNo": "ordNo", "sqlCode": -31}], "dumpFileName": {"ctlNo": "ctlNo", "patId": "patId", "sqlCode": -99995}}', '1', '0', 4, '2020-05-13 18:35:00.661', '2020-05-13 18:38:04.593');
