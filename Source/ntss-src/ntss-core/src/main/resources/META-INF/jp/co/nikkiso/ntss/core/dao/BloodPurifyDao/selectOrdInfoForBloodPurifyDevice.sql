WITH kur_do AS (
  SELECT
    one_json->>'code' AS cd, json_idx AS kur_disp_order
  FROM
    mst_selector CROSS JOIN LATERAL jsonb_array_elements(order_settings->'items') WITH ORDINALITY AS tmp(one_json, json_idx)
  WHERE
    facility_cd = /*facilityCd*/1 AND master_physical_name = 'mst_kur'
)
, bed_do AS (
  SELECT
    one_json->>'code' AS cd, json_idx AS bed_disp_order
  FROM
    mst_selector CROSS JOIN LATERAL jsonb_array_elements(order_settings->'items') WITH ORDINALITY AS tmp(one_json, json_idx)
  WHERE
    facility_cd = /*facilityCd*/1 AND master_physical_name = 'mst_bed'
)

SELECT
  om.ord_no, om.pat_id, om.treat_date, om.rst_treatment_cd, om.rst_kur_cd
  ,om.rst_bed_name, om.rst_dialysis_state, om.reg_date, om.up_date
  ,pm.is_same, mk.kur_name, mk.kur_start_time, mk.kur_end_time ,mt.device_mode,om.rst_treatment_name
FROM
  ord_main AS om

  INNER JOIN
  (SELECT pat_id, is_same FROM pat_main WHERE is_del = '0') AS pm
  ON om.pat_id = pm.pat_id

  INNER JOIN
  (SELECT kur_cd, kur_name, kur_start_time, kur_end_time FROM mst_kur WHERE facility_cd = /*facilityCd*/1 AND is_del = '0') AS mk
  ON om.rst_kur_cd = mk.kur_cd

  INNER JOIN
  (SELECT treatment_cd, device_mode  FROM mst_treatment WHERE facility_cd = /*facilityCd*/1 AND is_del = '0' AND is_disp = '1') AS mt
  ON om.rst_treatment_cd = mt.treatment_cd

  INNER JOIN kur_do ON om.rst_kur_cd::text = kur_do.cd

  INNER JOIN bed_do ON om.rst_bed_cd::text = bed_do.cd
WHERE
  facility_cd = /*facilityCd*/1
  AND treat_date = /*treatDate*/2
  AND is_del = '0'
  /*%if isNkkDevice */
  AND device_mode <> 9
  AND rst_machine_no IN (SELECT machine_no FROM mst_machine WHERE facility_cd = /*facilityCd*/1 AND is_del = '0' AND is_disp = '1' AND com_type = 0)
  /*%else */
  AND device_mode = 9
  /*%end */
  AND rst_dialysis_state >= '1'
ORDER BY
  kur_disp_order nulls last, bed_disp_order nulls last
;
