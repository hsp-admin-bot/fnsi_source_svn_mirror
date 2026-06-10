--投与薬剤セット
SELECT /*%expand "A" */*
FROM
  mst_medicine_group A, --テーブル名
  (
    SELECT mss.facility_cd, ms.*, row_number() over() AS index
    FROM mst_selector mss
    CROSS JOIN lateral jsonb_to_recordset(mss.order_settings->'items') AS ms
    (
      code bigint,
      name text
    )
    WHERE
      /*%if params.facilityCd != null */  
        facility_cd = /* params.facilityCd*/'0' AND
      /*%end */
      master_physical_name = 'mst_medicine_group' --テーブル名
  ) ms
WHERE
  A.facility_cd = ms.facility_cd
  AND A.medicine_group_cd = ms.code --コードのカラム
  AND A.is_del = '0'
  AND A.is_disp = '1'
  ORDER BY ms.index;
