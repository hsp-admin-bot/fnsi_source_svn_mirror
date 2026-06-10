-- add 9324 治療情報を異なる状態で変更した後のord_checklistの再編成共通方法 gjn start
DELETE FROM
  ord_checklist
WHERE
  checklist_ctl_no IN /*checklistCtlNo*/(0)
;
-- add 9324 治療情報を異なる状態で変更した後のord_checklistの再編成共通方法 gjn end
