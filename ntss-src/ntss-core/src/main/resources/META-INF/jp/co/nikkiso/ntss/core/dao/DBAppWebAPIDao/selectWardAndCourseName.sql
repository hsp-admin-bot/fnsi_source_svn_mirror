with query1_2 as 
(
  -- 病棟名の取得(存在しなくても必ず1件(null)を返す)
  with query1 as (
    SELECT ward_name FROM mst_ward WHERE facility_cd = /*facility_cd*/'' and ward_cd = /*ward_cd*/0
  )
  select ward_name from query1
  union all
  select null WHERE NOT EXISTS(select * from query1)
),
query2_2 as
(
  -- 診療科名の取得(存在しなくても必ず1件(null)を返す)
  with query2 as (
    SELECT course_name FROM mst_course WHERE facility_cd = /*facility_cd*/'' and course_cd = /*course_cd*/0
  )
  select course_name from query2
  union all
  select null WHERE NOT EXISTS(select * from query2)
)
select
  query1_2.ward_name as ward_name,
  query2_2.course_name as course_name
from
  query1_2,query2_2 
