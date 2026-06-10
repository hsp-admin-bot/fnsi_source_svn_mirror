select
    /*%expand "A" */*
from
    ord_checklist A
where
        A.ord_no = /*param.ordNo*/0
  and
        A.list_cd = /*param.listCd*/0
  and
        A.func_class = /*param.funcClass*/'0'
  and
        A.rst_checklist_info->>'item_number' = to_char(/*param.rstChecklistInfo.itemNumber*/0, 'FM99')
  and
    A.is_disp = '1'
  and
    A.is_del = '0'
  and
    A.rst_class = /*param.rstClass*/'0'
  and
/*%if param.rstChecklistInfo.name != null */
    A.rst_checklist_info->>'name' = /*param.rstChecklistInfo.name*/null :: text
/*%else*/
    A.rst_checklist_info->>'name' IS NULL
/*%end*/
;
