--よく使う施設
  select
      /*%expand "A" */*
  from
    mst_favorite_facility A   --テーブル名
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
    /*%if facilityCd != null */
                         facility_cd = /* facilityCd*/'0'
                 and
    /*%end */
                         master_physical_name = 'mst_favorite_facility' --テーブル名
         ) ms
      where
             A.facility_cd = ms.facility_cd
       and
            A.facility_cd = /* facilityCd*/'0'
       and
             A.master_cd = ms.code --コードのカラム
       and
             A.is_disp = '1'
      order by
             ms.index
;
