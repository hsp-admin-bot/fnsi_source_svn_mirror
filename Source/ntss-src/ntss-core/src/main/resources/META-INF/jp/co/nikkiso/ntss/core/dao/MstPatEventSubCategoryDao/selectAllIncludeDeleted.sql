  select
      /*%expand "A" */*
  from
    mst_pat_event_sub_category A 
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
                         master_physical_name = 'mst_pat_event_sub_category' 
         ) ms
        on A.facility_cd = ms.facility_cd and A.sub_category_cd = ms.code --コードのカラム
  where
    /*%if facilityCd != null */  
        A.facility_cd = /* facilityCd*/'0'
    /*%end */
  order by
    ms.index
;  
