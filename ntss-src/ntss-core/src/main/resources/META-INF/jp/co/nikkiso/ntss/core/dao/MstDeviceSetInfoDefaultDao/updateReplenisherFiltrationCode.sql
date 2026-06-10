UPDATE mst_device_set_info_default
SET device_set_info = jsonb_set(device_set_info, '{pat,ope,dev,A,389}', '"0"'::jsonb),
    up_date         = CURRENT_TIMESTAMP
WHERE facility_cd = /* facilityCd */null
  AND (device_set_info -> 'pat' -> 'ope' -> 'dev' -> 'A' ->> '389')::text = '3'
;