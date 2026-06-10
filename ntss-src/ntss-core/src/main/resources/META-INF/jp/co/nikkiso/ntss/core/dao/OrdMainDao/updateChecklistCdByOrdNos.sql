UPDATE ord_checklist
SET rst_checklist_info = jsonb_set(rst_checklist_info, '{checklist_cd}', /* checklistCd */'0' ::jsonb),
up_date = CURRENT_TIMESTAMP
WHERE facility_cd = /* facilityCd */null and ord_no in /* ordNos */(null);
