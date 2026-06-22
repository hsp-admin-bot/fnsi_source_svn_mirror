DELETE
FROM
	ord_checklist
WHERE
	rst_checklist_info -> 'class_cd' != 'null'
	AND rst_checklist_info -> 'code' != 'null'
	AND rst_checklist_info -> 'medicine_type' != 'null'
	AND func_class in /*funcClassList*/(1,2,3)
	AND ( rst_checklist_info -> 'medicine_type' ) :: NUMERIC = /*medicineType*/null
	AND ( rst_checklist_info -> 'code' ) :: NUMERIC = /*code*/null
	AND facility_cd = /*facilityCd*/null
	AND  ord_no in /* ordNos */(null)
