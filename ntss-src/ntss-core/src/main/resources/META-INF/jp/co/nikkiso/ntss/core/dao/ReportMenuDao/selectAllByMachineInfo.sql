SELECT
    machine_no,
    machine_type_cd,
	machine_serial,
	machine_name
FROM
  mst_machine
WHERE
  is_del = '0'
  AND facility_cd = /*facilityCd*/''
  AND machine_no IN /*machineNo*/(null)
ORDER BY
/*%if "asc" != sortValue */
  /*%if "装置名称" == sortId */
    COALESCE(machine_name, '') DESC
  /*%elseif "装置番号" == sortId */
    machine_no DESC
  /*%elseif "製造番号" == sortId */
    machine_serial DESC
  /*%else*/
    machine_type_cd DESC
  /*%end*/
/*%else*/
  /*%if "装置名称" == sortId */
    COALESCE(machine_name, '') ASC
  /*%elseif "装置番号" == sortId */
    machine_no ASC
  /*%elseif "製造番号" == sortId */
    machine_serial ASC
  /*%else*/
    machine_type_cd ASC
  /*%end*/
/*%end*/

