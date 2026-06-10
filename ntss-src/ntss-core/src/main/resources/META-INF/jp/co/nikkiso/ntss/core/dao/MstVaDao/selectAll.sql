--VA
  select
     -- /*%expand "A" */*
     A.va_cd
,A.facility_cd
,A.fn_va_cd
,A.va_name
,A.va_direct
,A.in_hospital_cd_1
,A.in_hospital_cd_2
,A.is_disp
,A.is_del
,A.reg_date
,A.up_date
  from
    mst_va A   --テーブル名
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
                         master_physical_name = 'mst_va' --テーブル名
         ) ms
      where
           A.facility_cd = ms.facility_cd
       and
           A.va_cd = ms.code --コードのカラム
       and
           A.is_del = '0'
       and
           A.is_disp = '1'
      order by
             ms.index
;

