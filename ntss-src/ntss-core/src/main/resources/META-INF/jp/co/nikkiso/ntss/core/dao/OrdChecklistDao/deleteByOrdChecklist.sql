DELETE FROM ord_checklist A
WHERE
  A.facility_cd = /* param.facilityCd */'000000'
and A.ord_no in (
	select 
		ord_no 
	from ord_main 
	where 
		facility_cd = /* param.facilityCd */'000000' 
	and 
		rst_dialysis_state = '0'
)
/*%if param.listCd != null */
and
  A.list_cd = /*param.listCd*/0
/*%end*/
/*%if param.rstChecklistInfo != null */
    /*%if param.funcClass != null */
    and
      A.func_class = /*param.funcClass*/0
    /*%end*/
    /*%if param.rstChecklistInfo.itemNumber != null */
    and
      A.rst_checklist_info->>'item_number' = to_char(/*param.rstChecklistInfo.itemNumber*/0, 'FM99')
    /*%end*/
    /*%if param.rstChecklistInfo.code != null */
    and
      A.rst_checklist_info->>'code' = to_char(/*param.rstChecklistInfo.code*/0, 'FM99')
    /*%end*/
/*%end*/
;
