--薬効換算マスタ(削除済を含む)
  select
      /*%expand "A" */*
  from
    mst_medicine_group A   --テーブル名
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
    /*%if params.facilityCd != null */
                         facility_cd = /* params.facilityCd*/'0'
                 and
    /*%end */
                         master_physical_name = 'mst_medicine_group' --テーブル名
         ) ms
         on  A.facility_cd = ms.facility_cd and A.medicine_group_cd = ms.code
      order by
           ms.index, A.medicine_group_cd
;
