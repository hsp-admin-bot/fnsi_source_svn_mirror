SELECT
  tmp.facility_cd,
  tmp.weight_cd,
  tmp.setting->'item_bed_cd' AS item_bed_cd
FROM
(
  SELECT
    mw.facility_cd,
    mw.weight_cd,
    jsonb_array_elements(mw.scale_bed_setting) as setting
  FROM
    mst_weight mw
  WHERE
    mw.facility_cd = /*facilityCd*/'999999' and
    mw.weight_type = 1 and
    mw.scale_bed_setting is not null and
    mw.scale_Bed_setting <> '{}'::jsonb and
    mw.is_del <> '1'
) tmp
;
