--診療科
  select
      /*%expand "A" */*
  from
    mst_course A   --テーブル名
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
                         master_physical_name = 'mst_course' --テーブル名
         ) ms
      on
             A.facility_cd = ms.facility_cd
       and
             A.course_cd = ms.code --コードのカラム
       where A.facility_cd = /* params.facilityCd*/'0'
      order by
             ms.index
;
