-- 装置設定：静的静脈圧
UPDATE
	pat_main
SET
	device_set_info = jsonb_merge_recursive(device_set_info, '{"iap":{"dev":{"A":{"468":80,"469":0.5,"470":"1","471":"0"}}}}'::jsonb)
;