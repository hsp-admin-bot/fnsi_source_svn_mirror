UPDATE mst_coop_distribute
SET
  distribute_setting =
    jsonb_set(distribute_setting, '{protocolInfo, retryMax}', '3', true)
  , up_date = CURRENT_TIMESTAMP
WHERE distribute_setting -> 'protocolInfo' ->> 'retryMax' IS NULL
AND is_del = '0'
AND is_disp = '1'
