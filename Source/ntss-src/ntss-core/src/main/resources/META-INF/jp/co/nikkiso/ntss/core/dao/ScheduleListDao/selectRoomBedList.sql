  with query1 as (
--   mod 8646 【デグレ】スケジュール表のベッドグループの表示が不正 張 start
--     select
--       (jsonb_array_elements(order_settings->'items')->'code'->>0)::numeric as code,
--       jsonb_array_elements(order_settings->'items')->'name'->>0 as name
--     from
--       mst_selector
--     where
--       master_physical_name = 'mst_room_bed_group'
--       and
--       facility_cd=/*facilityCd*/0
      SELECT
        ms.*
        , ROW_NUMBER() OVER () AS INDEX
      FROM
        mst_selector mss
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> 'items') AS ms(code BIGINT, NAME TEXT)
      WHERE
        facility_cd = /*facilityCd*/0
        AND master_physical_name = 'mst_room_bed_group'
--   mod 8646 【デグレ】スケジュール表のベッドグループの表示が不正 張 end
  )
select
  /*%expand "bedg" */*
from
   mst_room_bed_group bedg,query1 q1
where
  facility_cd = /*facilityCd*/'1'
--   del 8646 【デグレ】スケジュール表のベッドグループの表示が不正 張 start
--   and
--   group_class in ( 1,2 )
--   del 8646 【デグレ】スケジュール表のベッドグループの表示が不正 張 end
  and
  bedg.room_bed_group_cd = q1.code
  and
  bedg.is_disp = '1'
  and
  bedg.is_del = '0'
--   add 8646 【デグレ】スケジュール表のベッドグループの表示が不正 張 start
  ORDER BY q1.INDEX
--   add 8646 【デグレ】スケジュール表のベッドグループの表示が不正 張 end
