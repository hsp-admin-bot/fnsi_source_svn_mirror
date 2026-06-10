--治療方法
  select
      /*%expand "A" */*
  from
    mst_treatment A   --テーブル名
    left join (
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
                         master_physical_name = 'mst_treatment' --テーブル名
        ) ms
        on A.facility_cd = ms.facility_cd and A.treatment_cd = ms.code --コードのカラム
  where
    /*%if params.facilityCd != null */  
        A.facility_cd = /* params.facilityCd*/'0'
    /*%end */
  order by
    ms.index
;
