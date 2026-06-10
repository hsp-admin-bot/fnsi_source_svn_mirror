SELECT value ->> 'key0'      key0,
       value ->> 'key1'      key1,
       value ->> 'key2'      key2,
       value ->> 'value'     val,
       value ->> 'comment'   com,
       value ->> 'default_v' default_v,
       value ->> 'is_effect' is_effect
FROM mst_coop_ini AS ini
         CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
WHERE facility_cd = /*facilityCd*/'999999'
  AND is_del = '0'
  AND COALESCE(info->>'key0', '') = /* key0 */''
  AND info ->> 'key1' = /*key1*/''
ORDER BY
  CASE
    WHEN info->>'key2' ~ '^\d+$' THEN CAST(info->>'key2' AS INTEGER)
    ELSE NULL
  END ASC NULLS LAST;