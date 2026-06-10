DELETE FROM ord_checklist
-- mod #9539 チェックリストマスタの設定を変更して保存しても保存できない dengshen start
-- WHERE checklist_ctl_no IN /*checklistCtlNoList*/(null)
WHERE checklist_ctl_no IN (
    SELECT checklist_ctl_no
      FROM ord_checklist                                            -- チェックリスト実績
     WHERE facility_cd = /*facilityCd*/null                         -- 施設コード
       AND is_del = '0'                                             -- 削除フラグ
       AND is_disp = '1'                                            -- 表示フラグ
       AND list_cd = /*listCd*/null                                 -- リストコード
       AND rst_checklist_info -> 'item_number' = /*itemNumber*/null -- チェックリスト項目情報 -> チェックリストマスタ.チェックリスト設定.機能リスト.項目番号
       AND ord_no in /* ordNoList */(null)                          -- リストコード
   )
-- mod #9539 チェックリストマスタの設定を変更して保存しても保存できない dengshen end
;
