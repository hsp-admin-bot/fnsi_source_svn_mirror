update mst_checklist
SET is_del = 1, is_disp = 0
WHERE
  checklist_cd = /*checklistCd*/0
;