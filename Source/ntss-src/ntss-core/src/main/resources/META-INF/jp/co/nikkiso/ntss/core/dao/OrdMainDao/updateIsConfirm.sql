-- 指定ord_noでis_confirmが「updateTargetIsConfirm」の場合に「IsConfirm」に更新する
UPDATE
  ord_main
SET
  is_confirm = /*isConfirm*/'0',
  up_date = CURRENT_TIMESTAMP
WHERE
  ord_no = /*ordNo*/0
AND
  is_confirm = /*updateTargetIsConfirm*/'1'
