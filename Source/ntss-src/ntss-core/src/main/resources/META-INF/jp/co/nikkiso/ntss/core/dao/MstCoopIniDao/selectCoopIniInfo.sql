select value ->> 'key0'      key0,
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
-- add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  AND COALESCE(info->>'key0', '') = /* key0 */''
-- add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  AND info ->> 'key1' = /*key1*/''
  AND info ->> 'key2' = /*key2*/''
