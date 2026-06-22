-- mod #11435 並び替えキー「医材／薬剤」の仕様見直し 高 start
SELECT
  facility_setting_no,
  value
FROM
  mst_facility_setting
WHERE
    facility_setting_no IN ('3131')
  AND
    facility_cd = /*facilityCd*/null
-- mod #11435 並び替えキー「医材／薬剤」の仕様見直し 高 end
