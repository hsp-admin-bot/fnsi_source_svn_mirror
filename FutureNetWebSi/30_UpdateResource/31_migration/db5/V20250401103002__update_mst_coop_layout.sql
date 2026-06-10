DELETE FROM mst_coop_layout
WHERE ctl_no IN (-4090001, -4090002);

INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4090001, 'P_hosp', 'exam_rst', '', 'R', 'pre', 'text', 'パナソニック 検査結果', 'Medicom', '検査結果受信（新版）', '1', '<root name="検査結果（新版）" multi="true:CRLF/LFCR/CR/LF">
    <item  name="レコード区分" len="2" type="string"  key="exam_kbn"/>
    <item  name="センターコード" len="6" type="string"/>
    <item  name="カルテNo." len="10" type="string"/>
    <item  name="外来･入院" len="1" type="string"/>
    <item  name="透析情報" len="1" type="string"/>
    <item  name="空白" len="28" type="string"/>
    <item  name="患者名" len="20" type="string"/>
    <item  name="報告状況" len="1" type="string"/>
    <item  name="乳ビ" len="3" type="string"/>
    <item  name="溶血" len="3" type="string"/>
    <item  name="ビリルビン" len="3" type="string"/>
    <occ  name="検査結果情報" len="0" repeat="5" detail="検査結果"/>
    <item  name="採取日" len="10" type="string"/>
    <item  name="異常値有無" len="1" type="string"/>
    <item  name="異常値1" len="1" type="string"/>
    <item  name="異常値2" len="1" type="string"/>
    <item  name="異常値3" len="1" type="string"/>
    <item  name="異常値4" len="1" type="string"/>
    <item  name="異常値5" len="1" type="string"/>
    <item  name="空白" len="2" type="string"/>
</root>', '{"key": {"exam_kbn": {"A1": "検査結果"}}, "dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "ExceptionMessage": "患者[@hospPatId]の個人情報は一つではなく、[@dataCnt]つのデータがあります。", "ExceptionCondition": "<>1"}], "sqlGroup2": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": -309001, "ExceptionMessage": "[検査結果情報連携]【失敗】 採取日が未設定です。", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "ExceptionCondition": "=1"}], "sqlGroup3": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": -309002, "@centerCode": "$journal.pat_exam_main.center_code", "ExceptionMessage": "[検査結果情報連携]【対象外】センターコードが対象外です。", "ExceptionCondition": "=0"}], "sqlGroup4": [{"crud": "S", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 6101, "insertResult": "{@examMainCd:'''', @patId:'''', @facilityCd:'''', @ordNo:'''', @fnPatId:'''', @regExamDate_Date:'''', @regOrderClass:'''', @examStatus:''1'', @orderComment:'''', @orderExamSetInfoValue:''[]'', @examOrderInfoValue:''[]'', @orderLabelInfoValue:''[]'', @dataGenClass:''2'', @resultExamDate_Date:'''', @resultComment:'''', @examResultInfoValue:''[]'', @copOrderNo1:'''', @copOrderNo2:'''', @isLock:''1'', @indUserId:'''', @isDel:'''', @regDate:'''', @regStaff:'''', @upDate:'''', @upStaff:'''', @isOrder:'''', @examWeek:'''', @examFrom:'''', @examTo:'''', @examPattern:''''}", "updateResult": "{@examMainCd:''exam_main_cd'', @patId:''pat_id'', @facilityCd:''facility_cd'', @ordNo:''ord_no'', @fnPatId:''fn_pat_id'', @regExamDate_Date:''reg_exam_date'', @regOrderClass:''reg_order_class'', @examStatus:''exam_status'', @orderComment:''order_comment'', @orderExamSetInfoValue:''order_exam_set_info'', @examOrderInfoValue:''exam_order_info'', @orderLabelInfoValue:''order_label_info'', @dataGenClass:''data_gen_class'', @resultExamDate_Date:''result_exam_date'', @resultComment:''result_comment'', @examResultInfoValue:''exam_result_info'', @copOrderNo1:''cop_order_no1'', @copOrderNo2:''cop_order_no2'', @isLock:''is_lock'', @indUserId:''ind_user_id'', @isDel:''is_del'', @regDate:''reg_date'', @regStaff:''reg_staff'', @upDate:''up_date'', @upStaff:''up_staff'', @isOrder:''is_order'', @examWeek:''exam_week'', @examFrom:''exam_from'', @examTo:''exam_to'', @examPattern:''exam_pattern'', }", "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@resultComment1": "$journal.pat_exam_main.result_comment1", "@resultComment2": "$journal.pat_exam_main.result_comment2", "@resultComment3": "$journal.pat_exam_main.result_comment3", "@resultComment4": "$journal.pat_exam_main.result_comment4", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}, {"crud": "C", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": -309101, "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@resultComment1": "$journal.pat_exam_main.result_comment1", "@resultComment2": "$journal.pat_exam_main.result_comment2", "@resultComment3": "$journal.pat_exam_main.result_comment3", "@resultComment4": "$journal.pat_exam_main.result_comment4", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "3", "sqlCode": 6103, "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@resultComment1": "$journal.pat_exam_main.result_comment1", "@resultComment2": "$journal.pat_exam_main.result_comment2", "@resultComment3": "$journal.pat_exam_main.result_comment3", "@resultComment4": "$journal.pat_exam_main.result_comment4", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}], "sqlGroup5": [{"crud": "S", "kind": "1", "type": "json", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "1", "sqlCode": 6101, "updateResult": "{@nextDispOrder:''next_disp_order'', @examMainCd:''exam_main_cd'', @examResultInfoFlg:'''',@examResultInfoValue:''exam_result_info'',@examResultInfo.comCd:'''', @examResultInfo.dispOrder:'''', @examResultInfo.examClass:'''', @examResultInfo.freememo:'''', @examResultInfo.hl:'''', @examResultInfo.itemCd:'''', @examResultInfo.itemName:'''', @examResultInfo.jlac10Cd:'''', @examResultInfo.lower:'''', @examResultInfo.result:'''', @examResultInfo.resultDate:'''', @examResultInfo.type:'''', @examResultInfo.unit:'''', @examResultInfo.upper:''''}", "@regOrderClass": "$journal.pat_exam_main.reg_order_class", "@regExamDate_Date": "$journal.pat_exam_main.result_exam_date", "@resultExamDate_Date": "$journal.pat_exam_main.result_exam_date"}, {"Note": "json場合、[D]の設定が必要です。しかし、CSIの検査結果をクリアしません。judgeに[crud#=#NG]woを設定する。", "crud": "D", "kind": "1", "judge": "$journal.const.crud#=#NG", "table": "pat_exam_main", "ctl_no": "2", "sqlCode": 6201}, {"crud": "U", "kind": "1", "judge": "$journal.const.crud#<>#D", "table": "pat_exam_main", "ctl_no": "3", "sqlCode": 6202, "@examResultInfo.hl": "$journal.detail.pat_exam_main.exam_result_info.hl", "@examResultInfo.comCd1": "$journal.detail.pat_exam_main.exam_result_info.com_cd1", "@examResultInfo.comCd2": "$journal.detail.pat_exam_main.exam_result_info.com_cd2", "@examResultInfo.itemCd": "$journal.detail.pat_exam_main.exam_result_info.item_cd", "@examResultInfo.result": "$journal.detail.pat_exam_main.exam_result_info.result"}]}}'::jsonb, '1', '0', -1, '2020-05-26 11:07:41.699', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4090002, 'P_hosp', 'exam_rst', '', 'R', '検査結果', 'text', 'パナソニック 検査結果', 'Medicom', '検査結果受信（新版）', '1', '<root name="検査結果（新版）" multi="true:CRLF/LFCR/CR/LF">
  <item name="レコード区分" len="2" type="string" col="$journal.const.crud" value="const:C"/>
  <item name="センターコード" len="6" col="$journal.pat_exam_main.center_code" type="string"/>
  <item name="カルテNo." len="10" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
  <item name="外来･入院" len="1" type="string"/>
  <item name="透析情報" len="1" col="$journal.pat_exam_main.reg_order_class" type="string"/>
  <item name="空白" len="28" type="string"/>
  <item name="患者名" len="20" type="string"/>
  <item name="報告状況" len="1" type="string"/>
  <item name="乳ビ" len="3" type="string"/>
  <item name="溶血" len="3" type="string"/>
  <item name="ビリルビン" len="3" type="string"/>
  <occ name="検査結果情報" len="0" repeat="5" detail="検査結果"/>
  <item name="採取日" len="10" col="$journal.pat_exam_main.result_exam_date" type="string"/>
  <item name="異常値有無" len="1" type="string"/>
  <item name="異常値1" len="1" col="$journal.pat_exam_main.result_comment1" type="string"/>
  <item name="異常値2" len="1" col="$journal.pat_exam_main.result_comment2" type="string"/>
  <item name="異常値3" len="1" col="$journal.pat_exam_main.result_comment3" type="string"/>
  <item name="異常値4" len="1" col="$journal.pat_exam_main.result_comment4" type="string"/>
  <item name="異常値5" len="1" col="$journal.pat_exam_main.result_comment5" type="string"/>
  <item name="空白" len="2" type="string"/>
</root>
', '{}'::jsonb, '1', '0', -1, '2020-05-26 11:07:45.331', CURRENT_TIMESTAMP, 'MED');