DELETE FROM
  ord_material_save
WHERE
    facility_cd = /*facilityCd*/null
  /*%if patId != null */
  AND pat_id = /*patId*/null
  /*%end */
  AND supplies_base_no in /*suppliesBaseNos*/(null)
  /*%if suppliesSourceClass != null */
  AND supplies_source_class = /*suppliesSourceClass*/null
  /*%end */
  AND ind_rst_class IN /*indRstClassList*/(null)
  /*%if editEquipCodeList != null && editEquipCodeList.size() >0 */
  AND (
    /*%for ec: editEquipCodeList */
      supplies_cd = /*ec.getEquipCdCond()*/null AND supplies_class = /*ec.equipType*/null
      /*%if ec_has_next */
        /*# " or " */
      /*%end */
    /*%end*/
  )
  /*%end*/
