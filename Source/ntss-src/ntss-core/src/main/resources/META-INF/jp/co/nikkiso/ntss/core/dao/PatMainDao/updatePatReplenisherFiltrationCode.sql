UPDATE pat_main
SET device_set_info = jsonb_set(device_set_info, '{ope,dev,A,389}', '"0"'::jsonb),
    up_date         = CURRENT_TIMESTAMP
WHERE facility_cd = /* facilityCd */null
  -- add #12651 施設設定マスタ>No.114濾過率から算出有効化設定をON/OFFした際の動作について fang start
  -- is_del=1の患者は変更しない。
  AND is_del <> '1'
  -- add #12651 施設設定マスタ>No.114濾過率から算出有効化設定をON/OFFした際の動作について fang end
  AND (device_set_info -> 'ope' -> 'dev' -> 'A' ->> '389')::text = '3'
;
