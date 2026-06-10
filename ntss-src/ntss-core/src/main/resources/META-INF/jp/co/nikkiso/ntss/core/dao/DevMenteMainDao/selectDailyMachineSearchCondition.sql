WITH MSB AS (
  SELECT
    ms.code AS bed_cd,
    row_number() over() AS bed_order_index
  FROM mst_selector mss
    CROSS JOIN lateral jsonb_to_recordset(mss.order_settings->'items')
      AS ms( code bigint )
  WHERE
    mss.master_physical_name = 'mst_bed'
    AND
    mss.facility_cd = /* facilityCd */'000000'
),
MSM AS (
  SELECT
    ms.code AS machine_no,
    row_number() over() AS machine_order_index
  FROM mst_selector mss
    CROSS JOIN lateral jsonb_to_recordset(mss.order_settings->'items')
      as ms( code bigint )
  WHERE
    mss.master_physical_name = 'mst_machine'
    AND
    mss.facility_cd = /* facilityCd */'000000'
)

SELECT
  MM.machine_no,
  MM.machine_serial,
  MM.machine_name,
  MMT.machine_type,
  MMT.machine_type_cd,
  MMT.model,
  MB.bed_name,
  MSB.bed_order_index,
  MSM.machine_order_index

FROM mst_machine MM
  INNER JOIN mst_machine_type MMT ON
    MM.facility_cd = /* facilityCd */'000000'
    AND
    MM.is_disp = '1'
    AND
    MM.is_del = '0'
    AND
    MM.machine_type_cd = MMT.machine_type_cd

  LEFT OUTER JOIN mst_bed MB ON
    MM.machine_no = MB.machine_no
    AND
    MB.is_disp = '1'
    AND
    MB.is_del = '0'

  LEFT OUTER JOIN MSB ON MB.bed_cd = MSB.bed_cd
  LEFT OUTER JOIN MSM ON MM.machine_no = MSM.machine_no

WHERE
  /*%if machineTypeList != null && machineTypeList.size() != 0 */
  MMT.machine_type_cd in /* machineTypeList */('0')
  /*%end */
  /*%if keyword != null */
  AND
  (
    MM.machine_name like '%' || /* keyword */null || '%'
    OR
    MM.machine_serial like '%' || /* keyword */null || '%'
    OR
    MMT.machine_type like '%' || /* keyword */null || '%'
  )
  /*%end */
  /*%if listBedCd != null && listBedCd.size() != 0 */
  AND
  MB.bed_cd in /* listBedCd */(0)
  /*%end */

ORDER BY
  model ASC,
  bed_order_index ASC NULLS LAST,
  machine_order_index ASC
;
