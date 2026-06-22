select info ->> 'key2' as key2,
       (case info ->> 'key2'
          when 'TREATMENT' then (case COALESCE(NULLIF(info ->> 'value', ''), info ->> 'default_v')
                                   when '4' then 'in_hospital_cd_a4'
                                   when '3' then 'in_hospital_cd_a3'
                                   when '2' then 'in_hospital_cd_a2'
                                   else 'in_hospital_cd_a1' end)
          else (case COALESCE(NULLIF(info ->> 'value', ''), info ->> 'default_v')
                  when '3' then 'in_hospital_cd_3'
                  when '2' then 'in_hospital_cd_2'
                  else 'in_hospital_cd_1' end) end) as val
FROM mst_coop_ini AS ini
       CROSS JOIN LATERAL jsonb_array_elements(coop_ini_info) info
WHERE facility_cd = /*facilityCd*/'999999'
  AND is_del = '0'
-- add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  AND COALESCE(info->>'key0', '') = /* key0 */''
-- add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  AND info ->> 'key1' = /*key1*/''
  AND info ->> 'key2' = /*key2*/''
