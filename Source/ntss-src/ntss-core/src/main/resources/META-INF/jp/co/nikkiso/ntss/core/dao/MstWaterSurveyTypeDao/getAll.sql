SELECT 
  /*%expand "wt" */*
FROM 
  mst_water_survey_type as wt,
  (
    select
      mss.facility_cd, ms.*, row_number() over() as index
    from
      mst_selector mss
      cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
      (
        code bigint,
        name text
      )
    where
    /*%if facilityCd != null */
      facility_cd = /*facilityCd*/'0'
      and
    /*%end */
      master_physical_name = 'mst_water_survey_type' --テーブル名
  ) ms
WHERE
  wt.facility_cd= ms.facility_cd
  AND wt.survey_type_cd = ms.code --コードのカラム
  AND wt.is_disp = '1'
  AND wt.is_del = '0'
ORDER BY ms.index