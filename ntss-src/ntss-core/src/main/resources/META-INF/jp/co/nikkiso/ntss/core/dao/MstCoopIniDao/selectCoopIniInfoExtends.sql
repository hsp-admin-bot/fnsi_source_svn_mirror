select (case info ->> 'key2'
          when 'MEDICINE' then 'mst_medicine'
          when 'EQUIPMENT' then 'mst_equipment'
          when 'DIALYZER' then 'mst_dialyzer' end)                                       as key2,
       -- mod 6996 【デグレ】profile連携で受信した禁忌情報登録 20230119 zhaoqi start
       'in_hospital_cd_' || COALESCE(NULLIF(info ->> 'value', ''), info ->> 'default_v') AS val
       -- mod 6996 【デグレ】profile連携で受信した禁忌情報登録 20230119 zhaoqi end
FROM mst_coop_ini AS ini
       CROSS JOIN LATERAL jsonb_array_elements(coop_ini_info) info
WHERE facility_cd = /*facilityCd*/'999999'
  AND is_del = '0'
-- add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  AND COALESCE(info ->> 'key0', '') = /* key0 */''
-- add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  AND info ->> 'key1' = /*key1*/''
