delete from "mst_coop_layout" where "ctl_no" = -2090001 or "ctl_no" = -2090002 or "ctl_no" = -2090003 or "ctl_no" = -2090004 or "ctl_no" = -2090005;
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2090001, 'F_hosp', 'exam_rst', '', 'R', 'pre', 'text     ', '富士通想定透析初回申し込み', 'Egmain-GX', 'テスト用', '1', '<root name="検査結果(pre)">

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

</root>', '{"key": {"レポート種別": {"ER01": "検体検査", "ER02": "一般細菌", "ER03": "抗酸菌", "ER04": "その他細菌"}}, "dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は存在しません。", "ExceptionCondition": "0"}], "sqlGroup2": [{"crud": "S", "kind": "1", "judge": "$journal.pat_exam_main.crud#=#D", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 2101, "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1", "updateResult": "{@examMainCd:''exam_main_cd'', @patId:''pat_id'', @facilityCd:''facility_cd'', @ordNo:''ord_no'', @fnPatId:''fn_pat_id'', @regExamDate:''reg_exam_date'', @regOrderClass:''reg_order_class'', @examStatus:''exam_status'', @orderComment:''order_comment'', @orderExamSetInfoValue:''order_exam_set_info'', @examOrderInfoValue:''exam_order_info'', @orderLabelInfoValue:''order_label_info'', @dataGenClass:''data_gen_class'', @resultExamDate:''result_exam_date'', @resultComment:''result_comment'', @examResultInfoValue:''exam_result_info'', @copOrderNo1:''cop_order_no1'', @copOrderNo2:''cop_order_no2'', @isLock:''is_lock'', @indUserId:''ind_user_id'', @isDel:''is_del'', @regDate:''reg_date'', @regStaff:''reg_staff'', @upDate:''up_date'', @upStaff:''up_staff'', @isOrder:''is_order'', @examWeek:''exam_week'', @examFrom:''exam_from'', @examTo:''exam_to'', @examPattern:''exam_pattern'', }"}, {"crud": "U", "kind": "1", "note": "倫理削除処理", "judge": "$journal.pat_exam_main.crud#=#D", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": 2104, "@indUserId": "$journal.pat_exam_main.ind_user_id", "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1"}], "sqlGroup3": [{"crud": "S", "kind": "1", "judge": "$journal.pat_exam_main.crud#<>#D", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 2101, "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1", "insertResult": "{@examMainCd:'''', @patId:'''', @facilityCd:'''', @ordNo:'''', @fnPatId:'''', @regExamDate:'''', @regOrderClass:'''', @examStatus:''1'', @orderComment:'''', @orderExamSetInfoValue:''[]'', @examOrderInfoValue:''[]'', @orderLabelInfoValue:''[]'', @dataGenClass:''2'', @resultExamDate:'''', @resultComment:'''', @examResultInfoValue:''[]'', @copOrderNo1:'''', @copOrderNo2:'''', @isLock:''1'', @indUserId:'''', @isDel:'''', @regDate:'''', @regStaff:'''', @upDate:'''', @upStaff:'''', @isOrder:'''', @examWeek:'''', @examFrom:'''', @examTo:'''', @examPattern:''''}", "updateResult": "{@examMainCd:''exam_main_cd'', @patId:''pat_id'', @facilityCd:''facility_cd'', @ordNo:''ord_no'', @fnPatId:''fn_pat_id'', @regExamDate:''reg_exam_date'', @regOrderClass:''reg_order_class'', @examStatus:''exam_status'', @orderComment:''order_comment'', @orderExamSetInfoValue:''order_exam_set_info'', @examOrderInfoValue:''exam_order_info'', @orderLabelInfoValue:''order_label_info'', @dataGenClass:''data_gen_class'', @resultExamDate:''result_exam_date'', @resultComment:''result_comment'', @examResultInfoValue:''exam_result_info'', @copOrderNo1:''cop_order_no1'', @copOrderNo2:''cop_order_no2'', @isLock:''is_lock'', @indUserId:''ind_user_id'', @isDel:''is_del'', @regDate:''reg_date'', @regStaff:''reg_staff'', @upDate:''up_date'', @upStaff:''up_staff'', @isOrder:''is_order'', @examWeek:''exam_week'', @examFrom:''exam_from'', @examTo:''exam_to'', @examPattern:''exam_pattern'', }"}, {"crud": "C", "kind": "1", "judge": "$journal.pat_exam_main.crud#<>#D", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": 2102, "@indUserId": "$journal.pat_exam_main.ind_user_id", "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1", "@regExamDate": "$journal.pat_exam_main.result_exam_date", "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@resultComment": "$journal.pat_exam_main.result_comment", "@resultExamDate": "$journal.pat_exam_main.result_exam_date"}, {"crud": "U", "kind": "1", "judge": "$journal.pat_exam_main.crud#<>#D", "table": "pat_exam_main", "ctl_no": "3", "sqlCode": 2103, "@indUserId": "$journal.pat_exam_main.ind_user_id", "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1", "@regExamDate": "$journal.pat_exam_main.result_exam_date", "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@resultComment": "$journal.pat_exam_main.result_comment", "@resultExamDate": "$journal.pat_exam_main.result_exam_date"}], "sqlGroup4": [{"crud": "S", "kind": "1", "type": "json", "judge": "$journal.pat_exam_main.crud#<>#D", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 2101, "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1", "updateResult": "{@nextDispOrder:''next_disp_order'', @examMainCd:''exam_main_cd'', @examResultInfoFlg:'''',@examResultInfoValue:''exam_result_info'',@examResultInfo.comCd:'''', @examResultInfo.dispOrder:'''', @examResultInfo.examClass:'''', @examResultInfo.freememo:'''', @examResultInfo.hl:'''', @examResultInfo.itemCd:'''', @examResultInfo.itemName:'''', @examResultInfo.jlac10Cd:'''', @examResultInfo.lower:'''', @examResultInfo.result:'''', @examResultInfo.resultDate:'''', @examResultInfo.type:'''', @examResultInfo.unit:'''', @examResultInfo.upper:''''}"}, {"crud": "D", "kind": "1", "judge": "$journal.pat_exam_main.crud#<>#D", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": 2105}, {"crud": "U", "kind": "1", "judge": "$journal.pat_exam_main.crud#<>#D", "table": "pat_exam_main", "ctl_no": "3", "sqlCode": 2106, "@examResultInfo.hl": "$journal.detail.pat_exam_main.exam_result_info.hl", "@examResultInfo.comCd": "$journal.detail.pat_exam_main.exam_result_info.com_cd1", "@examResultInfo.itemCd": "$journal.detail.pat_exam_main.exam_result_info.item_cd", "@examResultInfo.result": "$journal.detail.pat_exam_main.exam_result_info.result", "@examResultInfo.freememo": "$journal.detail.pat_exam_main.exam_result_info.freememo"}]}}', '1', '0', -1, '2019-12-13 05:44:54', '2019-12-13 05:44:54');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2090002, 'F_hosp', 'exam_rst', '', 'R', '検体検査', 'text     ', '富士通想定透析初回申し込み', 'Egmain-GX', 'テスト用', '1', '<root name="検査結果(検体検査)">

    <item  name="電文種別" len="2" type="string"/>

    <item  name="レコード継続指示" len="1" type="string"/>

    <item  name="送信先システムコード" len="2" type="string"/>

    <item  name="発信元システムコード" len="2" type="string"/>

    <item  name="処理情報.処理年月日" len="8" type="string"/>

    <item  name="処理情報.処理時刻" len="6" type="string"/>

    <item  name="端末名" len="8" type="string"/>

    <item  name="利用者番号" len="8" type="string"/>

    <item  name="処理区分" len="2" col="$journal.pat_exam_main.crud" type="string" value="json:{&quot;01&quot;:&quot;&quot;,&quot;02&quot;:&quot;&quot;,&quot;03&quot;:&quot;1&quot;}"/>

    <item  name="応答種別" len="2" type="string"/>

    <item  name="電文長" len="6" type="string"/>

    <item  name="エラーコード" len="5" type="string"/>

    <item  name="予備" len="12" type="string"/>

    <item  name="検査状態" len="2" col="$journal.pat_exam_main.reg_order_class" type="string"/>

    <item  name="伝票情報.レポート種別" len="4" type="string"/>

    <item  name="伝票情報.文書番号" len="30" type="string"/>

    <item  name="版数" len="2" type="string"/>

    <item  name="枝番" len="4" type="string"/>

    <item  name="オーダ番号" len="8" col="$journal.pat_exam_main.cop_order_no1" type="string"/>

    <item  name="依頼日" len="8" type="string"/>

    <item  name="患者番号" len="10" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>

    <item  name="科コード" len="3" type="string"/>

    <item  name="入外区分" len="1" type="string"/>

    <item  name="病棟コード" len="3" type="string"/>

    <item  name="採取日_採取時間" len="14" col="$journal.pat_exam_main.result_exam_date" type="string"/>

    <item  name="依頼コメントコード" len="20" type="string"/>

    <item  name="ドクタコード" len="8" col="$journal.pat_exam_main.ind_user_id" type="string"/>

    <item  name="フリーコメント" len="50" col="$journal.pat_exam_main.result_comment" type="string"/>

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

</root>', '{"json-key": {"{\"01\":\"\",\"02\":\"\",\"03\":\"1\"}": {"01": "C", "02": "U", "03": "D"}}}', '1', '0', -1, '2019-12-13 05:44:54', '2019-12-13 05:44:54');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2090003, 'F_hosp', 'exam_rst', '', 'R', '一般細菌', 'text     ', '富士通想定透析初回申し込み', 'Egmain-GX', 'テスト用', '1', '<root name="検査結果(一般細菌)">

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

    <item  name="伝票情報.レポート種別" len="4" type="string"/>

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

    <occ  name="結果情報" len="0" repeat="300" detail="結果情報詳細_空"/>

    <item  name="終端" len="1" type="string"/>

</root>', '{}', '1', '0', -1, '2019-12-13 05:44:54', '2019-12-13 05:44:54');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2090004, 'F_hosp', 'exam_rst', '', 'R', '抗酸菌', 'text     ', '富士通想定透析初回申し込み', 'Egmain-GX', 'テスト用', '1', '<root name="検査結果(抗酸菌)">

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

    <item  name="伝票情報.レポート種別" len="4" type="string"/>

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

    <occ  name="結果情報" len="0" repeat="300" detail="結果情報詳細_空"/>

    <item  name="終端" len="1" type="string"/>

</root>', '{}', '1', '0', -1, '2019-12-13 05:44:54', '2019-12-13 05:44:54');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-2090005, 'F_hosp', 'exam_rst', '', 'R', 'その他細菌', 'text     ', '富士通想定透析初回申し込み', 'Egmain-GX', 'テスト用', '1', '<root name="検査結果(その他細菌)">

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

    <item  name="伝票情報.レポート種別" len="4" type="string"/>

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

    <occ  name="結果情報" len="0" repeat="300" detail="結果情報詳細_空"/>

    <item  name="終端" len="1" type="string"/>

</root>', '{}', '1', '0', -1, '2019-12-13 05:44:54', '2019-12-13 05:44:54');
