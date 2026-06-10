select coalesce(info ->> 'value', info ->> 'default_v') as value
FROM mst_coop_ini AS ini
       CROSS JOIN LATERAL jsonb_array_elements(coop_ini_info) info
WHERE facility_cd = /*facilityCd*/'999999'
  AND is_del = '0'
  AND COALESCE(info->>'key0', '') = /* key0 */''
  AND info ->> 'key1' = /*key1*/''
  AND info ->> 'key2' = /*key2*/'';
