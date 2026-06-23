-- 経過時間のupperを72時間に修正
UPDATE
  sys_monitor_item
SET
  upper = 4320.00,
  up_date = CURRENT_TIMESTAMP
WHERE
  moni_data_no IN ('1', '2', '3', '4', '30', '78')
;
