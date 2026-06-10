-- mod #6227 2022-08-11 ord_mainの削除データ不正 赵鑫宇 start
-- UPDATE
  -- ord_main
-- SET
  -- is_del = '1',
  -- up_date = CURRENT_TIMESTAMP
-- WHERE
  -- pat_id = /*patId*/0
DELETE FROM
  ord_main
WHERE
  pat_id = /*patId*/0
;
-- mod #6227 2022-08-11 ord_mainの削除データ不正 赵鑫宇 end
