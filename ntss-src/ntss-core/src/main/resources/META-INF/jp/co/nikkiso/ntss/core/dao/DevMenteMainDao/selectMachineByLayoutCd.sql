WITH mml_detail AS (
  SELECT
    (di ->> 'cd')::bigint as cd
  FROM
    mst_mainte_layout as mml,
    jsonb_array_elements(mml.detail_info_1) as di
  WHERE
    mml.is_disp = '1'
    AND
    mml.is_del = '0'
    AND
    mml.mainte_layout_cd = /* layoutCd */'0'
    AND
    (di ->> 'isDisp') = 'true'
),
mmc_type_info AS (
  SELECT
    coalesce(mmc.detail -> 'type_info', jsonb_build_array()) as type_info
  FROM
    mst_mainte_category as mmc,
    mml_detail
  WHERE
    mmc.is_disp = '1'
    AND
    mmc.is_del = '0'
    AND
    mmc.mainte_category_cd = mml_detail.cd
),
mt_filtered AS (
  SELECT
    mmt.machine_type,
    mmt.machine_type_cd
  FROM
    mst_machine_type as mmt
  WHERE
    EXISTS (
      SELECT type_info
      FROM mmc_type_info
      WHERE jsonb_array_length(type_info) = 0
    )
    OR
    mmt.machine_type_cd in (
      SELECT type_cd
      FROM
        mmc_type_info as ti,
        jsonb_array_elements_text(ti.type_info) as type_cd
    )
),
mm_filtered AS (
  SELECT
    mm.machine_no,
    mm.machine_serial,
    mm.machine_name,
    mt.machine_type,
    mt.machine_type_cd
  FROM
    mst_machine as mm
    CROSS JOIN mt_filtered as mt
  WHERE
    mm.facility_cd = /* facilityCd */'000000'
    AND
    mm.is_disp = '1'
    AND
    mm.is_del = '0'
    AND
    mm.machine_type_cd = mt.machine_type_cd
)

SELECT
  mm.machine_no,
  mm.machine_serial,
  mm.machine_name,
  mm.machine_type,
  mm.machine_type_cd,
  mb.bed_name
FROM
  mm_filtered as mm
  LEFT OUTER JOIN mst_bed as mb ON
    mb.is_disp = '1'
    AND
    mb.is_del = '0'
    AND
    mb.machine_no = mm.machine_no
ORDER BY mm.machine_no ASC
;
