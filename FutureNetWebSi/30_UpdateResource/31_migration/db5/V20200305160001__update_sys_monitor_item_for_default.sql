-- モニタ項目データの論理削除
-- 52:ＢＰＭ関連データ９
-- 53:ＢＰＭ関連データ１０
-- 82:ＢＰＭ関連データ１
-- 83:ＢＰＭ関連データ２
-- 84:ＢＰＭ関連データ３
-- 87:ＢＰＭ関連データ６
update
  sys_monitor_item
set
  is_disp = '0'
  ,up_date = current_timestamp
where
  moni_data_no in (
    '52','53','82','83','84','87'
  )
 ;
