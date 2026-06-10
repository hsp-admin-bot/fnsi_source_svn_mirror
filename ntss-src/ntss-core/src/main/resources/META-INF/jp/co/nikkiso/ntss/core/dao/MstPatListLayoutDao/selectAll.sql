--マルチ患者一覧レイアウト
  select
      /*%expand "A" */*
  from
    mst_pat_list_layout A   --テーブル名
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
                         master_physical_name = 'mst_pat_list_layout' --テーブル名
         ) ms
      where
           A.facility_cd = ms.facility_cd
       and
           A.pat_list_layout_cd = ms.code --コードのカラム
       and
           A.is_del = '0'
       and
           A.is_disp = '1'
      order by
             ms.index
;