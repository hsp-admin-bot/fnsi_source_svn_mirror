SELECT
  A.equipment_set_cd        AS "equipmentSetCd",
  A.facility_cd             AS "facilityCd",
  A.equipment_set_name      AS "equipmentSetName",
  A.equipment_set_short_name AS "equipmentSetShortName",
  A.set_info                AS "setInfo",
  A.is_disp                 AS "isDisp",
  A.is_del                  AS "isDel",
  A.reg_date                AS "regDate",
  A.up_date                 AS "upDate"
FROM mst_equipment_set A
WHERE A.equipment_set_cd IN /* codeList */(0)
ORDER BY A.equipment_set_cd
;

