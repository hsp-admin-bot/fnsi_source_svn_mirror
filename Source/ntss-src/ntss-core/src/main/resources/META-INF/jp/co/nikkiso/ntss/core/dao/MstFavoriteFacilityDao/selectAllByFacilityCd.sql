--よく使う施設
--   select
--       /*%expand "A" */*
--   from
--     mst_favorite_facility A   --テーブル名
--          ,(
--                  select
--                          mss.facility_cd, ms.*, row_number() over() as index
--                  from
--                          mst_selector mss
--                  cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
--                  (
--                          code bigint,
--                          name text
--                  )
--                  where
--     /*%if facilityCd != null */
--                          facility_cd = /* facilityCd*/'0'
--                  and
--     /*%end */
--                          master_physical_name = 'mst_favorite_facility' --テーブル名
--          ) ms
--       where
--              A.facility_cd = ms.facility_cd
--        and
--              A.master_cd = ms.code --コードのカラム
--        and
--              A.is_disp = '1'
--       order by
--              ms.index
-- ;
-- add FNSI-よく使う施設の変更 関 start
select
--     A.*,B.pref_name
--         /*%expand "A" */*
    A.facility_cd, A.facility_name, A.facility_name_kana, B.pref_cd, B.pref_name
from
    mst_facility A   --テーブル名
left join sys_prefectures B
on A.prefectures_cd = B.pref_cd
WHERE A.facility_cd in (
	select C.favorite_facility_cd from mst_favorite_facility C where c.facility_cd = /* facilityCd*/'0'
)
;
-- add FNSI-よく使う施設の変更 関 start
