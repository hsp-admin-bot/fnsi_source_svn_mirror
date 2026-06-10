SELECT /*%expand*/*
  FROM ord_checklist                                            -- チェックリスト実績
 WHERE facility_cd = /*facilityCd*/null                         -- 施設コード
   AND is_del = '0'                                             -- 削除フラグ
   AND is_disp = '1'                                            -- 表示フラグ
   AND is_check = '1'                                           -- 実施状態
   AND rst_class = 0                                            -- 実績区分
   AND list_cd = /*listCd*/null                                 -- リストコード
   AND rst_checklist_info -> 'item_number' = /*itemNumber*/null -- チェックリスト項目情報 -> チェックリストマスタ.チェックリスト設定.機能リスト.項目番号
;
