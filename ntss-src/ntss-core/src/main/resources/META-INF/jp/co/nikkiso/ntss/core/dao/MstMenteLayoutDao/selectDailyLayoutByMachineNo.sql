WITH mm_filtered AS (
  SELECT
    mm.machine_type_cd
  FROM
    mst_machine as mm
  WHERE
    mm.facility_cd = /* facilityCd */'000000'
    AND
    mm.is_disp = '1'
    AND
    mm.is_del = '0'
    AND
    mm.machine_no = /* machineNo */'0'
),
mmc_type_info AS (
  SELECT
    mmc.mainte_category_cd,
    coalesce(mmc.detail -> 'type_info', jsonb_build_array()) as type_info
  FROM
    mst_mainte_category as mmc
  WHERE
    mmc.is_disp = '1'
    AND
    mmc.is_del = '0'
    AND
    mmc.mainte_class = '1'
),
ti_filtered AS (
  SELECT
    ti.mainte_category_cd,
    ti.type_info
  FROM
    mmc_type_info as ti
  WHERE
    jsonb_array_length(ti.type_info) = 0
    OR
    EXISTS (
      SELECT type_cd
      FROM
        jsonb_array_elements_text(ti.type_info) as type_cd
      WHERE
        type_cd in (
          SELECT machine_type_cd
          FROM mm_filtered
        )
    )
)

SELECT
  mml.mainte_layout_cd,
  mml.edition_no,
  mml.facility_cd,
  mml.layout_class,
  mml.layout_name,
  mml.type_info,
  mml.detail_info_1,
  mml.detail_info_2,
  mml.is_disp,
  mml.is_del,
  mml.up_date,
  mml.reg_date,
  mml.layout_header
FROM
  mst_mainte_layout mml,
  (
    SELECT
      mss.facility_cd,
      msi.*,
      row_number() over() as index
    FROM
      mst_selector mss
      CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> 'items') as msi
      (
        code bigint,
        name text
      )
    WHERE
      mss.master_physical_name = 'mst_mainte_layout'
      /*%if facilityCd != null */
      AND
      mss.facility_cd = /* facilityCd */'000000'
      /*%end */
  ) ms
WHERE
  mml.facility_cd = ms.facility_cd
  AND
  mml.mainte_layout_cd = ms.code
  AND
  mml.layout_class = '1'
  AND
  mml.is_del = '0'
  AND
  mml.is_disp = '1'
  AND
  EXISTS (
    SELECT detail_info
    FROM
      jsonb_array_elements(mml.detail_info_1) as detail_info
    WHERE
      detail_info ->> 'isDisp' = 'true'
      AND
      (detail_info ->> 'cd')::bigint in (
        SELECT mainte_category_cd
        FROM ti_filtered
      )
  )
ORDER BY
  ms.index
;
