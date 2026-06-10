  select
      /*%expand "A" */*
  from
    mst_obs_kind A   --テーブル名
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
                         facility_cd = /* params.facilityCd*/null
                 and
    /*%end */
                         master_physical_name = 'mst_obs_kind' --テーブル名
         ) ms
      where
             A.facility_cd = ms.facility_cd
       and
             A.kind_no = ms.code --コードのカラム
       and
           A.is_del = '0'
       and
           A.is_disp = '1'
      order by
             ms.index
;
