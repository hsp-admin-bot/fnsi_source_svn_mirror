--医療材料
SELECT
  /*%expand "A" */*
FROM
  mst_equipment A   --テーブル名
WHERE
  facility_cd = /* params.facilityCd*/'0'
;
