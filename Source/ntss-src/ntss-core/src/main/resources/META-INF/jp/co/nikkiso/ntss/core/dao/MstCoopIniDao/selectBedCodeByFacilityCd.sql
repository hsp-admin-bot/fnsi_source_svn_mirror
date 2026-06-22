SELECT 0                                                            AS order_no
     , COALESCE(NULLIF(info ->> 'value', ''), info ->> 'default_v') AS bed_code_kbn
FROM mst_coop_ini AS ini
         CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
WHERE facility_cd = /*facilityCd*/'0'

  AND is_del = '0'
-- add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  AND COALESCE(info->>'key0', '') = /* key0 */''
-- add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  AND info ->> 'key1' = 'FJI_COM_INFO'
  AND info ->> 'key2' = 'BED_CODE_CONV'
UNION
SELECT 1  AS order_no
     , '' AS bed_code_kbn
ORDER BY order_no ASC
LIMIT 1
