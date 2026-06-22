--クール
  select
      --/*%expand "A" */*
       A.kur_cd
,A.facility_cd
,A.fn_kur_cd
,A.kur_name
,A.kur_start_time
,A.kur_end_time
,A.kur_standard_start_time
,A.in_hospital_cd_1
,A.is_del
,A.reg_date
,A.up_date
,A.mst_user_authentication
from
  mst_kur A   --テーブル名
left join
       (
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
  /*%if facility_cd != null */
                       facility_cd = /* facility_cd*/'0'
               and
  /*%end */
                       master_physical_name = 'mst_kur' --テーブル名
       ) ms
    on
           A.facility_cd = ms.facility_cd
     and
           A.kur_cd = ms.code --コードのカラム
where
           A.facility_cd = /* facility_cd*/'0'
/*%if null != is_del */
       and
             A.is_del = '0'
/*%end*/
       order by
             ms.index
;
