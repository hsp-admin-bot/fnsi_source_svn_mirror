--搬送区分
  select
      /*%expand "A" */*
  from
    mst_transport A   --テーブル名
         ,(
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
    /*%if params.facilityCd != null */  
                         facility_cd = /* params.facilityCd*/'0'
                 and
    /*%end */
                         master_physical_name = 'mst_transport' --テーブル名
         ) ms
      where
             A.facility_cd = ms.facility_cd
       and
             A.transport_cd = ms.code --コードのカラム
      order by
             ms.index
;