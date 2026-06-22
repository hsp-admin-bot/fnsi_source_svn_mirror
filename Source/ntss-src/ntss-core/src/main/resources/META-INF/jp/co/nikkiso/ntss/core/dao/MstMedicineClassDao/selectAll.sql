--薬剤分類
  select
      /*%expand "A" */*
  from
    mst_medicine_class A   --テーブル名
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
                         master_physical_name = 'mst_medicine_class' --テーブル名
                 /*%if params.facilityCd != null */
                 and
                         facility_cd = /* params.facilityCd*/'0'
                 /*%end */
         ) ms
      where
           A.class_cd = ms.code --コードのカラム
       and
           A.facility_cd = ms.facility_cd
       and
           A.is_del = '0'
       and
           A.is_disp = '1'
      order by
             ms.index
;
