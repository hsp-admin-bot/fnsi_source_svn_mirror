--病名
  select
      /*%expand "A" */*
  from
    mst_disease A   --テーブル名
    -- mod #8592 加算マスタの詳細表示に時間がかかる by zhangruixue 2023-05-11 start
--     left join (
--                  select
--                          mss.facility_cd, ms.*, row_number() over() as index
--                  from
--                          mst_selector mss
--                  cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
--                  (
--                          code bigint,
--                          name text
--                  )
--                  where
--                          master_physical_name = 'mst_disease' --テーブル名
--                         /*%if params.facilityCd != null */
--                         and mss.facility_cd = /* params.facilityCd*/'0'
--                         /*%end */
--          ) ms
--         on A.facility_cd = ms.facility_cd and A.disease_cd = ms.code --コードのカラム
    -- mod #8592 加算マスタの詳細表示に時間がかかる by zhangruixue 2023-05-11 end
  where
    /*%if params.facilityCd != null */
        A.facility_cd = /* params.facilityCd*/'0'
    /*%end */
--   order by
--     ms.index
;
