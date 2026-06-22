WITH jsonbA_origin AS (SELECT (device_set_info -> 'ord' -> 'ihdf' -> 'dev' -> 'A') - '1001' -'1002' AS json_a, facility_cd FROM mst_device_set_info_default WHERE facility_cd = /* facility_cd */'NKKSBR' )
select
  jsonb_set (d.device_set_info, '{ord,ihdf,dev,A}', o.json_a) AS device_set_info
from
  mst_device_set_info_default d
    inner join jsonbA_origin o
    ON d.facility_cd = o.facility_cd
where
  d.facility_cd = /* facility_cd */'NKKSBR'
