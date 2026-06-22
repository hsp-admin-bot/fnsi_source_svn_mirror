--薬剤分類(削除済を含む)
  select
      /*%expand "A" */*
  from
    mst_medicine_class A   --テーブル名
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
                         master_physical_name = 'mst_medicine_class' --テーブル名
                 /*%if params.facilityCd != null */
                 and
                         facility_cd = /* params.facilityCd*/'0'
                 /*%end */
         ) ms
      on  A.facility_cd = ms.facility_cd and A.class_cd = ms.code
      where
            /*%if params.facilityCd != null */
                A.facility_cd = /* params.facilityCd*/'0'
            /*%end */
      order by
             ms.index, A.class_cd
