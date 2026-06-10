-- sys_master_define定義用
delete from sys_master_define where master_physical_name='mst_function_report';
insert into sys_master_define
  (
    master_physical_name
    ,master_name
    ,disp_class
    ,mode
    ,allow_sort
    ,allow_add_record
    ,disp_order
    ,column_info
    ,combo_data
    ,reg_date
    ,up_date
    ,reference_combo_def
    ,edit_level
   ) values (
    'mst_function_report'
    ,'機能帳票マスタ'
    ,'2'
    ,'1'
    ,'1'
    ,'1'
    ,null
    ,'{"fields": [{"type": "number", "alias": "code", "title": "機能帳票コード", "format": null, "hidden": "true", "editable": "false", "validation": {"max": null, "min": null, "required": "true", "maxlength": null}, "physical_name": "function_report_cd"}, {"type": "combo1", "alias": null, "title": "機能コード", "format": null, "hidden": "false", "locked": "false", "editable": "true", "validation": {"max": null, "min": null, "required": true, "maxlength": null}, "physical_name": "function_cd"}, {"type": "combo2", "alias": null, "title": "帳票名", "format": null, "hidden": "false", "editable": "true", "validation": {"max": null, "min": null, "required": true, "maxlength": null}, "physical_name": "report_cd"}, {"type": "disp", "alias": null, "title": "削除", "format": null, "hidden": "false", "editable": "true", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "is_disp"}, {"type": "del", "alias": null, "title": "削除フラグ", "format": null, "hidden": "true", "editable": "true", "validation": {"max": null, "min": null, "required": null, "maxlength": null}, "physical_name": "is_del"}]}'
    ,'{"combos": [{"values": [{"text": "稼働監視（施設一覧）", "value": "00101"}, {"text": "装置一覧", "value": "00102"}, {"text": "装置記録", "value": "00103"}, {"text": "装置記録詳細", "value": "00104"}, {"text": "生体モニタリング", "value": "00201"}, {"text": "デバイスエッジ稼働監視", "value": "00301"}, {"text": "患者経過総合ビューア", "value": "00401"}, {"text": "マスタ一覧", "value": "00501"}, {"text": "マスタ編集", "value": "00502"}, {"text": "治療記録", "value": "00601"}, {"text": "治療記録（実績情報）", "value": "00602"}, {"text": "治療記録（バイタル）", "value": "00603"}, {"text": "治療記録（モニタ）", "value": "00604"}, {"text": "治療記録（愁訴処置）", "value": "00605"}, {"text": "治療記録（体重）", "value": "00606"}, {"text": "治療記録（治療条件）", "value": "00607"}, {"text": "治療記録（投与薬剤）", "value": "00608"}, {"text": "治療記録（医療材料）", "value": "00609"}, {"text": "治療記録（指示コメント）", "value": "00610"}, {"text": "治療記録（装置設定）", "value": "00611"}, {"text": "治療記録（回診記録）", "value": "00612"}, {"text": "治療記録（観察記録）", "value": "00613"}, {"text": "患者情報", "value": "00701"}, {"text": "マルチ患者一覧", "value": "00801"}, {"text": "スケジュール表", "value": "00901"}, {"text": "装置設定", "value": "01001"}, {"text": "治療状況リスト", "value": "01101"}, {"text": "治療状況リスト（警報・注意一覧）", "value": "01102"}, {"text": "治療状況リスト（大画面表示）", "value": "01103"}, {"text": "治療状況マップ", "value": "01201"}, {"text": "治療状況ベッドレイアウト", "value": "01202"}, {"text": "体重計", "value": "01301"}, {"text": "条件送信", "value": "01302"}, {"text": "車いすマスタ", "value": "01303"}, {"text": "体重計測定記録", "value": "01401"}, {"text": "チェックリスト", "value": "01501"}, {"text": "観察記録", "value": "01601"}, {"text": "観察記録詳細", "value": "01602"}, {"text": "患者新規登録", "value": "01701"}, {"text": "検査結果", "value": "01801"}, {"text": "掲示板登録情報", "value": "02001"}, {"text": "検査依頼", "value": "02101"}, {"text": "放射線検査依頼", "value": "02201"}, {"text": "患者グループ", "value": "02301"}, {"text": "患者グループ（新規）", "value": "02302"}, {"text": "患者グループ（編集）", "value": "02303"}, {"text": "患者カレンダ", "value": "02401"}, {"text": "帳票", "value": "01901"}, {"text": "患者イベント", "value": "02701"}, {"text": "患者イベント（詳細）", "value": "02702"}], "physical_name": "function_cd"}]}'
    ,now()
    ,now()
    ,'{"combos": [{"target_table": {"name": "mst_report", "identifier": "report_cd", "display_column": "report_name", "referenced_column": "report_cd"}, "physical_name": "report_cd"}]}'
    ,'1');
