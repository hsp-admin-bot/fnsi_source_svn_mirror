delete from "mst_coop_layout" where "ctl_no" = -2090001;
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2090001, 'F_hosp', 'exam_rst', '', 'R', 'pre', 'text', '富士通想定透析初回申し込み', 'Egmain-GX', 'テスト用', '1', '<root name="検査結果(pre)">
    <item  name="電文種別" len="2" type="string"/>
    <item  name="レコード継続指示" len="1" type="string"/>
    <item  name="送信先システムコード" len="2" type="string"/>
    <item  name="発信元システムコード" len="2" type="string"/>
    <item  name="処理情報.処理年月日" len="8" type="string"/>
    <item  name="処理情報.処理時刻" len="6" type="string"/>
    <item  name="端末名" len="8" type="string"/>
    <item  name="利用者番号" len="8" type="string"/>
    <item  name="処理区分" len="2" type="string"/>
    <item  name="応答種別" len="2" type="string"/>
    <item  name="電文長" len="6" type="string"/>
    <item  name="エラーコード" len="5" type="string"/>
    <item  name="予備" len="12" type="string"/>
    <item  name="検査状態" len="2" type="string"/>
    <item  name="伝票情報.レポート種別" len="4" key="レポート種別" type="string"/>
    <item  name="伝票情報.文書番号" len="30" type="string"/>
    <item  name="版数" len="2" type="string"/>
    <item  name="枝番" len="4" type="string"/>
    <item  name="オーダ番号" len="8" type="string"/>
    <item  name="依頼日" len="8" type="string"/>
    <item  name="患者番号" len="10" type="string"/>
    <item  name="科コード" len="3" type="string"/>
    <item  name="入外区分" len="1" type="string"/>
    <item  name="病棟コード" len="3" type="string"/>
    <item  name="採取日_採取時間" len="14" type="string"/>
    <item  name="依頼コメントコード" len="20" type="string"/>
    <item  name="ドクタコード" len="8" type="string"/>
    <item  name="フリーコメント" len="50" type="string"/>
    <item  name="フリーコメント" len="50" type="string"/>
    <item  name="画像フラグ" len="1" type="string"/>
    <item  name="生体情報.身長" len="5" type="string"/>
    <item  name="生体情報.体重" len="5" type="string"/>
    <item  name="生体情報.畜尿量" len="5" type="string"/>
    <item  name="負荷情報.負荷物コード" len="2" type="string"/>
    <item  name="負荷情報.負荷量" len="4" type="string"/>
    <item  name="負荷情報.負荷時間" len="4" type="string"/>
    <item  name="負荷情報.負荷物コード" len="2" type="string"/>
    <item  name="負荷情報.負荷量" len="4" type="string"/>
    <item  name="負荷情報.負荷時間" len="4" type="string"/>
    <item  name="負荷情報.負荷物コード" len="2" type="string"/>
    <item  name="負荷情報.負荷量" len="4" type="string"/>
    <item  name="負荷情報.負荷時間" len="4" type="string"/>
    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>
    <item  name="投与薬剤情報.投与日" len="8" type="string"/>
    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>
    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>
    <item  name="投与薬剤情報.投与日" len="8" type="string"/>
    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>
    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>
    <item  name="投与薬剤情報.投与日" len="8" type="string"/>
    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>
    <occ  name="検体情報" len="0" repeat="50" detail="検体情報詳細"/>
    <occ  name="結果情報" len="0" repeat="300" detail="結果情報詳細"/>
    <item  name="終端" len="1" type="string"/>
</root>', '{"key": {"レポート種別": {"ER01": "検体検査", "ER02": "一般細菌", "ER03": "抗酸菌", "ER04": "その他細菌"}}, "dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}], "sqlGroup2": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#=#D", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 2101, "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1", "@regExamDate": "$journal.pat_exam_main.result_exam_date", "updateResult": "{@examMainCd:''exam_main_cd'', @patId:''pat_id'', @facilityCd:''facility_cd'', @ordNo:''ord_no'', @fnPatId:''fn_pat_id'', @regExamDate:''reg_exam_date'', @regOrderClass:''reg_order_class'', @examStatus:''exam_status'', @orderComment:''order_comment'', @orderExamSetInfoValue:''order_exam_set_info'', @examOrderInfoValue:''exam_order_info'', @orderLabelInfoValue:''order_label_info'', @dataGenClass:''data_gen_class'', @resultExamDate:''result_exam_date'', @resultComment:''result_comment'', @examResultInfoValue:''exam_result_info'', @copOrderNo1:''cop_order_no1'', @copOrderNo2:''cop_order_no2'', @isLock:''is_lock'', @indUserId:''ind_user_id'', @isDel:''is_del'', @regDate:''reg_date'', @regStaff:''reg_staff'', @upDate:''up_date'', @upStaff:''up_staff'', @isOrder:''is_order'', @examWeek:''exam_week'', @examFrom:''exam_from'', @examTo:''exam_to'', @examPattern:''exam_pattern'', }", "@regOrderClass": "$journal.pat_exam_main.reg_order_class"}, {"crud": "U", "kind": "1", "note": "倫理削除処理", "judge": "$journal.const.crud#=#D", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": 2104, "@indUserId": "$journal.pat_exam_main.ind_user_id", "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1"}], "sqlGroup3": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 2101, "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1", "@regExamDate": "$journal.pat_exam_main.result_exam_date", "insertResult": "{@examMainCd:'''', @patId:'''', @facilityCd:'''', @ordNo:'''', @fnPatId:'''', @regExamDate:'''', @regOrderClass:'''', @examStatus:''1'', @orderComment:'''', @orderExamSetInfoValue:''[]'', @examOrderInfoValue:''[]'', @orderLabelInfoValue:''[]'', @dataGenClass:''2'', @resultExamDate:'''', @resultComment:'''', @examResultInfoValue:''[]'', @copOrderNo1:'''', @copOrderNo2:'''', @isLock:''0'', @indUserId:'''', @isDel:'''', @regDate:'''', @regStaff:'''', @upDate:'''', @upStaff:'''', @isOrder:'''', @examWeek:'''', @examFrom:'''', @examTo:'''', @examPattern:''''}", "updateResult": "{@examMainCd:''exam_main_cd'', @patId:''pat_id'', @facilityCd:''facility_cd'', @ordNo:''ord_no'', @fnPatId:''fn_pat_id'', @regExamDate:''reg_exam_date'', @regOrderClass:''reg_order_class'', @examStatus:''exam_status'', @orderComment:''order_comment'', @orderExamSetInfoValue:''order_exam_set_info'', @examOrderInfoValue:''exam_order_info'', @orderLabelInfoValue:''order_label_info'', @dataGenClass:''data_gen_class'', @resultExamDate:''result_exam_date'', @resultComment:''result_comment'', @examResultInfoValue:''exam_result_info'', @copOrderNo1:''cop_order_no1'', @copOrderNo2:''cop_order_no2'', @isLock:''is_lock'', @indUserId:''ind_user_id'', @isDel:''is_del'', @regDate:''reg_date'', @regStaff:''reg_staff'', @upDate:''up_date'', @upStaff:''up_staff'', @isOrder:''is_order'', @examWeek:''exam_week'', @examFrom:''exam_from'', @examTo:''exam_to'', @examPattern:''exam_pattern'', }", "@regOrderClass": "$journal.pat_exam_main.reg_order_class"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": 2102, "@indUserId": "$journal.pat_exam_main.ind_user_id", "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1", "@regExamDate": "$journal.pat_exam_main.result_exam_date", "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@resultComment": "$journal.pat_exam_main.result_comment", "@resultExamDate": "$journal.pat_exam_main.result_exam_date"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "3", "sqlCode": 2103, "@indUserId": "$journal.pat_exam_main.ind_user_id", "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1", "@regExamDate": "$journal.pat_exam_main.result_exam_date", "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@resultComment": "$journal.pat_exam_main.result_comment", "@resultExamDate": "$journal.pat_exam_main.result_exam_date"}], "sqlGroup4": [{"crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 2101, "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1", "@regExamDate": "$journal.pat_exam_main.result_exam_date", "updateResult": "{@nextDispOrder:''next_disp_order'', @examMainCd:''exam_main_cd'', @examResultInfoFlg:'''',@examResultInfoValue:''exam_result_info'',@examResultInfo.comCd:'''', @examResultInfo.dispOrder:'''', @examResultInfo.examClass:'''', @examResultInfo.freememo:'''', @examResultInfo.hl:'''', @examResultInfo.itemCd:'''', @examResultInfo.itemName:'''', @examResultInfo.jlac10Cd:'''', @examResultInfo.lower:'''', @examResultInfo.result:'''', @examResultInfo.resultDate:'''', @examResultInfo.type:'''', @examResultInfo.unit:'''', @examResultInfo.upper:''''}", "@regOrderClass": "$journal.pat_exam_main.reg_order_class"}, {"Note": "json場合、[D]の設定が必要です。しかし、患者検査結果をクリアしません。judgeに[crud#=#NG]を設定する。", "crud": "D", "kind": "1", "judge": "$journal.const.crud#=#NG", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": 0}, {"Note": "検査項目マスタに一致する連携コードがないものは、取り込み対象外とする。judgeに[$journal.detail.pat_exam_main.exam_result_info.item_cd#<>#]を追加する。", "crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D,$journal.detail.pat_exam_main.exam_result_info.item_cd#<>#", "table": "pat_exam_main", "ctl_no": "3", "sqlCode": 2106, "@examResultInfo.hl": "$journal.detail.pat_exam_main.exam_result_info.hl", "@examResultInfo.itemCd": "$journal.detail.pat_exam_main.exam_result_info.item_cd", "@examResultInfo.result": "$journal.detail.pat_exam_main.exam_result_info.result", "@examResultInfo.freememo": "$journal.detail.pat_exam_main.exam_result_info.freememo", "@examResultInfo.resultDate": "$journal.pat_exam_main.result_exam_date", "@examResultInfo.resultComment1Code": "$journal.detail.pat_exam_main.exam_result_info.result_comment1_code", "@examResultInfo.resultComment2Code": "$journal.detail.pat_exam_main.exam_result_info.result_comment2_code"}]}, "CoopMstConvUtil": {"$journal.pat_exam_main.ind_user_id": {"conv_type": "mst_personal_user", "hospital_cd_names": ["in_hospital_cd_1"], "master_data_settings": {"user_last_name": "連携　００", "user_first_name": "連携　００"}}, "$journal.detail.pat_exam_main.exam_result_info.item_cd": {"conv_type": "mst_exam_item", "data_0_event": "null", "hospital_cd_names": ["in_hospital_cd1"], "master_data_settings": {"data_type": "1", "in_hospital_cd1": "$journal.detail.pat_exam_main.exam_result_info.item_cd"}}}}', '1', '0', -1, '2019-12-13 05:44:54', '2019-12-13 05:44:54');
