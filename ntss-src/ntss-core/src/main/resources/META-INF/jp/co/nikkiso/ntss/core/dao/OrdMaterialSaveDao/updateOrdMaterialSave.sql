UPDATE
  ord_material_save
SET
  supplies_base_date = tmp.suppliesBaseDate,
  reg_date = now(),
  up_date = now()
FROM (VALUES
    /*%for oms : updateOrdMaterialSaveList */
      (
      /*oms.suppliesBaseNo*/null,
      /*oms.suppliesBaseDate*/null
      )
     /*%if oms_has_next */
     /*# "," */
     /*%end */
    /*%end*/
) AS tmp (suppliesBaseNo, suppliesBaseDate)
WHERE
  supplies_base_no = tmp.suppliesBaseNo
