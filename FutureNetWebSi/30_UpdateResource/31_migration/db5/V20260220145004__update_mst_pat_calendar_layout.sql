-- #10419 患者カレンダー表示内容修正
-- 旧構造(disp_item_info)のレコードを削除
UPDATE mst_pat_calendar_layout 
SET is_disp = '0',
  is_del = '1',
  up_date = CURRENT_TIMESTAMP
WHERE
  disp_class IS NULL
;
