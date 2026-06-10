delete from "mst_coop_layout" where "ctl_no" in (-3090001,-3090002);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3090001, 'N_hosp', 'exam_rst', '', 'R', 'all', 'text     ', 'NEC想定検査結果受信', 'MEGA', 'テスト用', '1', '<root name="検査結果(all)">
  <item name="コマンド名" len="8" type="string"/>
  <item name="モード" len="1" type="string"  col="$journal.const.crud"  value="json:{&quot;A&quot;:&quot;C&quot;,&quot;D&quot;:&quot;D&quot;}"/>
  <item name="オーダ番号" len="13" type="string" col="$journal.pat_exam_main.cop_order_no1"/>
  <item name="オーダサブ番号" len="3" type="string"/>
  <item name="検体番号" len="13" type="string"/>
  <item name="病院番号" len="2" type="string"/>
  <item name="患者番号" len="10" type="string" col="$journal.pat_personal_main.hosp_pat_id"/>
  <item name="採取日-採取時間" len="12" type="string" col="$journal.pat_exam_main.result_exam_date"/>
  <item name="オーダ番号" len="13" type="string"/>
  <item name="オーダサブ番号" len="3" type="string"/>
  <item name="検体番号(検査部門の番号)" len="13" type="string"/>
  <item name="送信区分" len="1" type="string"/>
  <item name="入外区分" len="1" type="string"/>
  <item name="依頼元科コード" len="2" type="string"/>
  <item name="依頼元病棟コード" len="4" type="string"/>
  <item name="部門コード" len="2" type="string"/>
  <item name="受付時間 " len="4" type="string"/>
  <item name="ラックNo" len="7" type="string"/>
  <item name="検査材料コード" len="3" type="string"/>
  <item name="緊急区分" len="1" type="string"/>
  <item name="検査区分" len="1" type="string"/>
  <item name="医師コード" len="10" type="string"/>
  <item name="蓄尿開始時間" len="2" type="string"/>
  <item name="蓄尿終了時間 " len="2" type="string"/>
  <item name="蓄尿量" len="5" type="string"/>
  <item name="負荷薬剤情報1" len="16" type="string"/>
  <item name="負荷薬剤情報2" len="16" type="string"/>
  <item name="負荷薬剤情報3" len="16" type="string"/>
  <item name="負荷薬剤情報4" len="16" type="string"/>
  <item name="オーダ依頼コメント1" len="2" type="string" col="$journal.pat_exam_main.reg_order_class1"/>
  <item name="オーダ依頼コメント2" len="2" type="string" col="$journal.pat_exam_main.reg_order_class2"/>
  <item name="オーダ依頼コメントフリー" len="60" type="string"/>
  <item name="検体コメントフリー" len="60" type="string"/>
  <item name="採取No" len="13" type="string"/>
  <item name="医師名" len="20" type="string"/>
  <item name="ベッドNo " len="7" type="string"/>
  <item name="緊急区分2 " len="1" type="string"/>
  <item name="緊急区分3" len="1" type="string"/>
  <item name="更新日付" len="14" type="string"/>
  <item name="更新端末" len="10" type="string"/>
  <item name="更新者" len="10" type="string"/>
  <item name="検体受付日" len="8" type="string"/>
  <item name="ORDERCOMMENT3" len="2" type="string"/>
  <item name="ORDERCOMMENT4" len="2" type="string"/>
  <item name="ORDERCOMMENT5" len="2" type="string"/>
  <occ name="結果項目数" len="3" detail = "検査結果詳細" col="$journal.pat_exam_main.data_count"/>
  <occ name="検査コメント数" len="3" detail="検査コメント詳細"/>
</root>', '{"dataset": {"sqlGroup1": [{"No1": "電文のモードが『D:削除』の場合、処理しません。", "No2": "受信電文のDetail数が0件の場合、処理しません。", "crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D,$journal.pat_exam_main.data_count#<>#0", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}], "sqlGroup2": [{"No1": "電文のモードが『D:削除』の場合、処理しません。", "No2": "受信電文のDetail数が0件の場合、処理しません。", "crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D,$journal.pat_exam_main.data_count#<>#0", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 9201, "insertResult": "{@examMainCd:'''', @patId:'''', @facilityCd:'''', @ordNo:'''', @fnPatId:'''', @regExamDate_Date:'''', @regOrderClass:'''', @examStatus:''1'', @orderComment:'''', @orderExamSetInfoValue:''[]'', @examOrderInfoValue:''[]'', @orderLabelInfoValue:''[]'', @dataGenClass:''2'', @resultExamDate_Date:'''', @resultComment:'''', @examResultInfoValue:''[]'', @copOrderNo1:'''', @copOrderNo2:'''', @isLock:''1'', @indUserId:'''', @isDel:'''', @regDate:'''', @regStaff:'''', @upDate:'''', @upStaff:'''', @isOrder:'''', @examWeek:'''', @examFrom:'''', @examTo:'''', @examPattern:''''}", "updateResult": "{@examMainCd:''exam_main_cd'', @patId:''pat_id'', @facilityCd:''facility_cd'', @ordNo:''ord_no'', @fnPatId:''fn_pat_id'', @regExamDate_Date:''reg_exam_date'', @regOrderClass:''reg_order_class'', @examStatus:''exam_status'', @orderComment:''order_comment'', @orderExamSetInfoValue:''order_exam_set_info'', @examOrderInfoValue:''exam_order_info'', @orderLabelInfoValue:''order_label_info'', @dataGenClass:''data_gen_class'', @resultExamDate_Date:''result_exam_date'', @resultComment:''result_comment'', @examResultInfoValue:''exam_result_info'', @copOrderNo1:''cop_order_no1'', @copOrderNo2:''cop_order_no2'', @isLock:''is_lock'', @indUserId:''ind_user_id'', @isDel:''is_del'', @regDate:''reg_date'', @regStaff:''reg_staff'', @upDate:''up_date'', @upStaff:''up_staff'', @isOrder:''is_order'', @examWeek:''exam_week'', @examFrom:''exam_from'', @examTo:''exam_to'', @examPattern:''exam_pattern'', }", "@regOrderClass1": "$journal.pat_exam_main.reg_order_class1", "@regOrderClass2": "$journal.pat_exam_main.reg_order_class2", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D,$journal.pat_exam_main.data_count#<>#0", "table": "pat_exam_main", "ctl_no": "2", "@isLock": "1", "sqlCode": 9202, "@examStatus": "1", "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1", "@dataGenClass": "2", "@regOrderClass1": "$journal.pat_exam_main.reg_order_class1", "@regOrderClass2": "$journal.pat_exam_main.reg_order_class2", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D,$journal.pat_exam_main.data_count#<>#0", "table": "pat_exam_main", "ctl_no": "3", "sqlCode": 9203, "@copOrderNo1": "$journal.pat_exam_main.cop_order_no1", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}], "sqlGroup3": [{"No1": "電文のモードが『D:削除』の場合、処理しません。", "No2": "受信電文のDetail数が0件の場合、処理しません。", "crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.crud#<>#D,$journal.pat_exam_main.data_count#<>#0", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 9201, "updateResult": "{@nextDispOrder:''next_disp_order'', @examMainCd:''exam_main_cd'', @examResultInfoFlg:'''',@examResultInfoValue:''exam_result_info'',@examResultInfo.comCd:'''', @examResultInfo.dispOrder:'''', @examResultInfo.examClass:'''', @examResultInfo.freememo:'''', @examResultInfo.hl:'''', @examResultInfo.itemCd:'''', @examResultInfo.itemName:'''', @examResultInfo.jlac10Cd:'''', @examResultInfo.lower:'''', @examResultInfo.result:'''', @examResultInfo.resultDateresultDate_Date:'''', @examResultInfo.type:'''', @examResultInfo.unit:'''', @examResultInfo.upper:''''}", "@regOrderClass1": "$journal.pat_exam_main.reg_order_class1", "@regOrderClass2": "$journal.pat_exam_main.reg_order_class2", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}, {"Note": "json場合、[D]の設定が必要です。しかし、NECの検査結果をクリアしません。judgeに[crud#=#NG]を設定する。", "crud": "D", "kind": "1", "judge": "$journal.const.crud#=#NG", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": 9204}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D,$journal.pat_exam_main.data_count#<>#0", "table": "pat_exam_main", "ctl_no": "3", "sqlCode": 9205, "@examResultInfo.hl": "$journal.detail.pat_exam_main.exam_result_info.hl", "@examResultInfo.type": "", "@examResultInfo.unit": "", "@examResultInfo.lower": "$journal.detail.pat_exam_main.exam_result_info.lower", "@examResultInfo.upper": "$journal.detail.pat_exam_main.exam_result_info.upper", "@examResultInfo.comCd1": "$journal.detail.pat_exam_main.exam_result_info.com_cd1", "@examResultInfo.comCd2": "$journal.detail.pat_exam_main.exam_result_info.com_cd2", "@examResultInfo.itemCd": "$journal.detail.pat_exam_main.exam_result_info.item_cd", "@examResultInfo.result": "$journal.detail.pat_exam_main.exam_result_info.result", "@examResultInfo.freememo": "$journal.detail.pat_exam_main.exam_result_info.freememo", "@examResultInfo.itemName": "", "@examResultInfo.examClass": "", "@examResultInfo.resultDate_Date": "$journal.detail.pat_exam_main.exam_result_info.result_date"}], "sqlGroup4": [{"No1": "項目コードまたは編集結果値が空白の場合、該当項目(Detail単位)の登録を行いません。（登録対象外）", "No2": "登録対象項目が０件の場合は、処理しません。", "No3": "No1とNo2の内容より、検査結果情報(exam_result_info)のデータが０件場合、新規登録したデータを削除する", "crud": "D", "kind": "1", "judge": "$journal.const.crud#<>#D,$journal.pat_exam_main.data_count#<>#0", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 9206, "@regOrderClass1": "$journal.pat_exam_main.reg_order_class1", "@regOrderClass2": "$journal.pat_exam_main.reg_order_class2", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}]}, "json-key": {"{\"A\":\"C\",\"D\":\"D\"}": {"A": "C", "D": "D"}}}', '1', '0', -1, '2019-12-13 05:44:54', '2019-12-13 05:44:54');
