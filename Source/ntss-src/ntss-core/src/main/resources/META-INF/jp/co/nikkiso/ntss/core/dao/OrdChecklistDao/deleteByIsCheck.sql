-- add 9324 治療情報を異なる状態で変更した後のord_checklistの再編成共通方法 gjn start
DELETE FROM ord_checklist
WHERE
	facility_cd = /*facilityCd*/'999999'
	AND ord_no = /*ordNo*/'1542'
	AND is_check = 0
-- add 9324 治療情報を異なる状態で変更した後のord_checklistの再編成共通方法 gjn end
