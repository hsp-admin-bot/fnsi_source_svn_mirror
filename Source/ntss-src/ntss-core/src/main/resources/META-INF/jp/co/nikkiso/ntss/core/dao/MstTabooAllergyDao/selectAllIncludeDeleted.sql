--  mod 2020/2/23 liang
  --禁忌・アレルギー(削除済を含む)
  select
      /*%expand "A" */*
  from
    mst_taboo_allergy A   --テーブル名
    --should use left join modify by maxueqiang
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
                         master_physical_name = 'mst_taboo_allergy' --テーブル名
         ) ms
    on  A.facility_cd = ms.facility_cd and A.taboo_allergy_cd = ms.code
  where
      /*%if params.facilityCd != null */
          A.facility_cd = /* params.facilityCd*/'0'
      /*%end */
  order by
    ms.index, A.taboo_allergy_cd
;

