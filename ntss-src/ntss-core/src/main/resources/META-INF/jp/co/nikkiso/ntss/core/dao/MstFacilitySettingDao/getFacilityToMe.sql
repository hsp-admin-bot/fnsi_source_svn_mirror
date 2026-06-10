SELECT facility_cd
FROM mst_facility_setting
WHERE facility_setting_no =  /*facilitySettingNo*/'4001'
  AND value::jsonb @> /*jsonValue*/'["0"]'::jsonb
