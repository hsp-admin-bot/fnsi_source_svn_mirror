SELECT
  mm.medicine_cd,
  mm.medicine_name,
  oms.ind_rst_value
FROM
  ord_material_save oms, mst_medicine mm
WHERE
  oms.facility_cd = /*facilityCd*/'1'
  AND to_number(oms.supplies_cd, '999999999') = mm.medicine_cd
  AND oms.pat_id = /*patId*/'33'
  AND oms.supplies_base_date = /*baseDate*/'20200609'
  AND oms.medicine_mix_cd = /*cd*/'16'
  AND oms.supplies_source_class != '5'
  AND oms.supplies_cd in (
    SELECT
      jsonb_array_elements ( mix_info :: jsonb ) ->> 'cd' AS detail_info_value
    FROM
      mst_medicine_mix mmm
    WHERE
      mmm.medicine_mix_cd = /*cd*/'16'
  )
