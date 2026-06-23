DELETE FROM ntss.mst_coop_layout
WHERE ctl_no IN (-1090001)
;
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1090001, 'nkknkk', 'exam_rst', '', 'R', 'all', 'text', '日機装標準', 'nikkiso', '検査結果受信', '1', '<root name="検査結果" multi="true:CRLF/LFCR/CR/LF">
    <item  name="レコード区分" len="2" type="string" col="$journal.const.crud" value="const:C"/>
    <item  name="センターコード" len="6" type="string"/>
    <item  name="採取日-採取時刻" len="12" col="$journal.pat_exam_main.result_exam_date" type="string"/>
    <item  name="透析前後" len="1" col="$journal.pat_exam_main.reg_order_class" type="string"/>
    <item  name="予備" len="7" type="string"/>
    <item  name="受諾者KEY" len="20" type="string"/>
    <item  name="患者ID" len="12" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
    <item  name="予備" len="8" type="string"/>
    <item  name="報告状況" len="1" type="string"/>
    <item  name="乳ビ" len="3" type="string"/>
    <item  name="溶血" len="3" type="string"/>
    <item  name="ビリルビン" len="3" type="string"/>
    <occ  name="検査結果情報" len="0" repeat="5" detail="検査結果"/>
    <item  name="空白" len="18" type="string"/>
</root>', '{
  "dataset": {
    "sqlGroup1": [
      {
        "crud": "S",
        "kind": "0",
        "judge": "",
        "table": "pat_personal_main",
        "ctl_no": "1",
        "sqlCode": 1101,
        "@hospPatId": "$journal.pat_personal_main.hosp_pat_id"
      }
    ],
    "sqlGroup2": [
      {
        "crud": "S",
        "kind": "0",
        "judge": "",
        "table": "pat_exam_main",
        "ctl_no": "1",
        "sqlCode": 7401,
        "@regExamDate": "$journal.pat_exam_main.result_exam_date",
        "insertResult": "{@examMainCd:'''', @patId:'''', @facilityCd:'''', @ordNo:'''', @fnPatId:'''', @regExamDate_Date:'''', @regOrderClass:'''', @examStatus:''1'', @orderComment:'''', @orderExamSetInfoValue:''[]'', @examOrderInfoValue:''[]'', @orderLabelInfoValue:''[]'', @dataGenClass:''2'', @resultExamDate_Date:'''', @resultComment:'''', @examResultInfoValue:''[]'', @copOrderNo1:'''', @copOrderNo2:'''', @isLock:''1'', @indUserId:'''', @isDel:'''', @regDate:'''', @regStaff:'''', @upDate:'''', @upStaff:'''', @isOrder:''0'', @examWeek:'''', @examFrom:'''', @examTo:'''', @examPattern:''''}",
        "updateResult": "{@examMainCd:''exam_main_cd'', @patId:''pat_id'', @facilityCd:''facility_cd'', @ordNo:''ord_no'', @fnPatId:''fn_pat_id'', @regExamDate_Date:''reg_exam_date'', @regOrderClass:''reg_order_class'', @examStatus:''exam_status'', @orderComment:''order_comment'', @orderExamSetInfoValue:''order_exam_set_info'', @examOrderInfoValue:''exam_order_info'', @orderLabelInfoValue:''order_label_info'', @dataGenClass:''data_gen_class'', @resultExamDate_Date:''result_exam_date'', @resultComment:''result_comment'', @examResultInfoValue:''exam_result_info'', @copOrderNo1:''cop_order_no1'', @copOrderNo2:''cop_order_no2'', @isLock:''is_lock'', @indUserId:''ind_user_id'', @isDel:''is_del'', @regDate:''reg_date'', @regStaff:''reg_staff'', @upDate:''up_date'', @upStaff:''up_staff'', @isOrder:''is_order'', @examWeek:''exam_week'', @examFrom:''exam_from'', @examTo:''exam_to'', @examPattern:''exam_pattern'', }",
        "@regOrderClass": "$journal.pat_exam_main.reg_order_class",
        "@resultExamDate": "$journal.pat_exam_main.result_exam_date",
        "@examResultInfo.itemCd": "$journal.detail.pat_exam_main.exam_result_info.item_cd"
      },
      {
        "crud": "C",
        "kind": "0",
        "judge": "",
        "table": "pat_exam_main",
        "ctl_no": "2",
        "sqlCode": 7402,
        "@regExamDate": "$journal.pat_exam_main.result_exam_date",
        "@regOrderClass": "$journal.pat_exam_main.reg_order_class",
        "@resultExamDate": "$journal.pat_exam_main.result_exam_date",
        "@examResultInfo.hl": "$journal.detail.pat_exam_main.exam_result_info.hl"
      },
      {
        "crud": "U",
        "kind": "1",
        "judge": "$journal.const.crud#=#NG ",
        "table": "pat_exam_main",
        "ctl_no": "3",
        "sqlCode": 7403,
        "@regExamDate": "$journal.pat_exam_main.result_exam_date",
        "@regOrderClass": "$journal.pat_exam_main.reg_order_class",
        "@resultExamDate": "$journal.pat_exam_main.result_exam_date"
      }
    ],
    "sqlGroup3": [
      {
        "crud": "S",
        "kind": "0",
        "type": "json",
        "judge": "",
        "table": "pat_exam_main",
        "ctl_no": "1",
        "sqlCode": 7401,
        "@regExamDate": "$journal.pat_exam_main.reg_exam_date",
        "updateResult": "{@nextDispOrder:''next_disp_order'', @examMainCd:''exam_main_cd'', @examResultInfoFlg:'''',@examResultInfoValue:''exam_result_info'',@examResultInfo.comCd:'''', @examResultInfo.dispOrder:'''', @examResultInfo.examClass:'''', @examResultInfo.freememo:'''', @examResultInfo.hl:'''', @examResultInfo.itemCd:'''', @examResultInfo.itemName:'''', @examResultInfo.jlac10Cd:'''', @examResultInfo.lower:'''', @examResultInfo.result:'''', @examResultInfo.resultDate:'''', @examResultInfo.type:'''', @examResultInfo.unit:'''', @examResultInfo.upper:''''}",
        "@regOrderClass": "$journal.pat_exam_main.reg_order_class",
        "@resultExamDate": "$journal.pat_exam_main.reg_exam_date",
        "@examResultInfo.itemCd": "$journal.detail.pat_exam_main.exam_result_info.item_cd"
      },
      {
        "crud": "U",
        "kind": "0",
        "judge": "",
        "table": "pat_exam_main",
        "ctl_no": "2",
        "sqlCode": 7406,
        "@examResultInfo.hl": "$journal.detail.pat_exam_main.exam_result_info.hl",
        "@resultExamDate_Date": "$journal.pat_exam_main.reg_exam_date",
        "@examResultInfo.comCd1": "$journal.detail.pat_exam_main.exam_result_info.com_cd1",
        "@examResultInfo.comCd2": "$journal.detail.pat_exam_main.exam_result_info.com_cd2",
        "@examResultInfo.itemCd": "$journal.detail.pat_exam_main.exam_result_info.item_cd",
        "@examResultInfo.result": "$journal.detail.pat_exam_main.exam_result_info.result",
        "@examResultInfo.itemName": "$journal.detail.pat_exam_main.exam_result_info.item_name",
        "@examResultInfo.examClass": "$journal.pat_exam_main.reg_order_class"
      }
    ],
    "sqlGroup4": [
      {
        "crud": "S",
        "kind": "0",
        "type": "json",
        "judge": "",
        "table": "pat_exam_main",
        "ctl_no": "1",
        "sqlCode": 7401,
        "@regExamDate": "$journal.pat_exam_main.reg_exam_date",
        "updateResult": "{@nextDispOrder:''next_disp_order'', @examMainCd:''exam_main_cd'', @examResultInfoFlg:'''',@examResultInfoValue:''exam_result_info'',@examResultInfo.comCd:'''', @examResultInfo.dispOrder:'''', @examResultInfo.examClass:'''', @examResultInfo.freememo:'''', @examResultInfo.hl:'''', @examResultInfo.itemCd:'''', @examResultInfo.itemName:'''', @examResultInfo.jlac10Cd:'''', @examResultInfo.lower:'''', @examResultInfo.result:'''', @examResultInfo.resultDate:'''', @examResultInfo.type:'''', @examResultInfo.unit:'''', @examResultInfo.upper:''''}",
        "@regOrderClass": "$journal.pat_exam_main.reg_order_class",
        "@resultExamDate": "$journal.pat_exam_main.reg_exam_date",
        "@examResultInfo.itemCd": "$journal.detail.pat_exam_main.exam_result_info.item_cd"
      },
      {
        "Note": "json場合、[D]の設定が必要です。しかし、日機装の検査結果をクリアしません。judgeに[crud#=#NG]を設定する。",
        "crud": "D",
        "kind": "1",
        "judge": "$journal.const.crud#=#NG",
        "table": "pat_exam_main",
        "ctl_no": "2",
        "sqlCode": 7404
      },
      {
        "crud": "U",
        "kind": "0",
        "judge": "",
        "table": "pat_exam_main",
        "ctl_no": "3",
        "sqlCode": 7405,
        "@examResultInfo.hl": "$journal.detail.pat_exam_main.exam_result_info.hl",
        "@examResultInfo.comCd1": "$journal.detail.pat_exam_main.exam_result_info.com_cd1",
        "@examResultInfo.comCd2": "$journal.detail.pat_exam_main.exam_result_info.com_cd2",
        "@examResultInfo.itemCd": "$journal.detail.pat_exam_main.exam_result_info.item_cd",
        "@examResultInfo.result": "$journal.detail.pat_exam_main.exam_result_info.result",
        "@examResultInfo.itemName": "$journal.detail.pat_exam_main.exam_result_info.item_name"
      }
    ],
    "sqlGroup5": [
      {
        "crud": "S",
        "kind": "0",
        "type": "json",
        "judge": "",
        "table": "pat_exam_main",
        "ctl_no": "1",
        "sqlCode": 7408,
        "updateResult": "{@nextDispOrder:''next_disp_order'', @infectCd:''infection_cd''}",
        "@examResultInfo.itemCd": "$journal.detail.pat_exam_main.exam_result_info.item_cd",
        "@examResultInfo.result": "$journal.detail.pat_exam_main.exam_result_info.result"
      },
      {
        "crud": "U",
        "kind": "0",
        "judge": "",
        "table": "pat_exam_main",
        "ctl_no": "2",
        "sqlCode": 7409,
        "@regExamDate": "$journal.pat_exam_main.result_exam_date",
        "@examResultInfo.itemCd": "$journal.detail.pat_exam_main.exam_result_info.item_cd",
        "@examResultInfo.result": "$journal.detail.pat_exam_main.exam_result_info.result"
      }
    ]
  },
  "CoopMstConvUtil": {
    "$journal.detail.pat_exam_main.exam_result_info.item_cd": {
      "conv_type": "mst_exam_item",
      "data_0_event": "null",
      "hospital_cd_names": [
        "in_hospital_cd1"
      ]
    }
  }
}'::jsonb, '1', '0', 4, '2020-05-26 11:07:45.331', CURRENT_TIMESTAMP, '');