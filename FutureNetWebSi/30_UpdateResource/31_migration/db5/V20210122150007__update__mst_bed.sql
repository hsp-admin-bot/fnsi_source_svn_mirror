--在宅機能の無効化
UPDATE mst_bed
SET
  is_home_dialysis = '0',
  up_date = now()
WHERE is_home_dialysis != '0';
