WITH mmg AS (
   SELECT
      jsonb_array_elements ( reg_medicine_info :: jsonb ) ->> 'cd' AS cd,
      jsonb_array_elements ( reg_medicine_info :: jsonb ) ->> 'conVal' AS conVal,
      jsonb_array_elements ( reg_medicine_info :: jsonb ) ->> 'mediFlg' AS mediFlg
   FROM
      mst_medicine_group
   WHERE
      medicine_group_cd = /*cd*/'2'
   )
SELECT
   SUM ( to_number( tab.conVal, '999999999.99' ) * to_number( tab.ind_rst_value, '999999999.99' ) ) AS sum_value
FROM
   (
      (
      SELECT
         mmg.cd,
         mmg.conVal,
         oms.ind_rst_value
      FROM
         mmg,
         ord_material_save oms
      WHERE
         oms.facility_cd = /*facilityCd*/'1'
         AND mmg.cd = oms.supplies_cd
         AND oms.supplies_base_date = /*baseDate*/'20200609'
         AND mmg.mediflg = '0'
         AND oms.pat_id = /*patId*/'33'
         AND oms.ind_rst_class = '2'
         AND oms.supplies_source_class != '5'
      ) UNION (
      SELECT
         mmg.cd,
         mmg.conVal,
         oms.ind_rst_value
      FROM
         mmg,
         ord_material_save oms
      WHERE
      oms.facility_cd = /*facilityCd*/'1'
         AND mmg.cd = oms.medicine_mix_cd
         AND oms.supplies_base_date = /*baseDate*/'20200609'
         AND mmg.mediflg = '2'
         AND oms.pat_id = /*patId*/'33'
         AND oms.ind_rst_class = '2'
         AND oms.supplies_source_class != '5'
      )
   ) AS tab
