select
  /*%expand "A" */*
from
  ord_checklist A
where
/*%if param.checklistCtlNo != null */
  A.checklist_ctl_no = /*param.checklistCtlNo*/0 AND
/*%end*/
  A.ord_no = /*param.ordNo*/0
and
  A.list_cd = /*param.listCd*/0
and
  A.func_class = /*param.funcClass*/'0'
and
  A.rst_checklist_info->>'item_number' = to_char(/*param.rstChecklistInfo.itemNumber*/0, 'FM99')
and
/*%if param.rstChecklistInfo.classCd != null */
  A.rst_checklist_info->>'class_cd' = to_char(/*param.rstChecklistInfo.classCd*/null, 'FM9999999999')
/*%else*/
  A.rst_checklist_info->>'class_cd' IS NULL
/*%end*/
and
/*%if param.rstChecklistInfo.medicineType != null */
    A.rst_checklist_info->>'medicine_type' = to_char(/*param.rstChecklistInfo.medicineType*/null, 'FM99') and
/*%end*/
/*%if param.rstChecklistInfo.equipType != null */
    A.rst_checklist_info->>'equip_type' = to_char(/*param.rstChecklistInfo.equipType*/null, 'FM99') and
/*%end*/
/*%if param.rstChecklistInfo.code != null */
  A.rst_checklist_info->>'code' =  to_char(/*param.rstChecklistInfo.code*/null, 'FM9999999999')
/*%else*/
  A.rst_checklist_info->>'code' IS NULL
/*%end*/
-- del 10310 needle _ typeの使用を削除するには gjn start
-- and
-- /*%if param.rstChecklistInfo.needleType != null */
  -- A.rst_checklist_info->>'needle_type' = to_char(/*param.rstChecklistInfo.needleType*/null, 'FM9')
-- /*%else*/
  --A.rst_checklist_info->>'needle_type' IS NULL
-- /*%end*/
-- del 10310 needle _ typeの使用を削除するには gjn end
and
  A.is_disp = '1'
and
  A.is_del = '0'
;
