--在宅機能の無効化
UPDATE mst_status_map_bed_layout
SET
  is_home_dialysis = '0',
  up_date = now()
WHERE is_home_dialysis != '0';
