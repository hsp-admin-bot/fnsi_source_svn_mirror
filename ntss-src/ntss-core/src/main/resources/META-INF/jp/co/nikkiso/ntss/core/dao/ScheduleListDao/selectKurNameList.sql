  with query1 as (
    select
      (jsonb_array_elements(order_settings->'items')->'code'->>0)::numeric as code,
      jsonb_array_elements(order_settings->'items')->'name'->>0 as name
    from
      mst_selector
    where
      master_physical_name = 'mst_kur'
      and
      facility_cd=/*facilityCd*/0
  )
select
  /*%expand "kur" */*
from
  mst_kur kur, query1 q1
where
  facility_cd = /*facilityCd*/1
  and
  is_del = '0'
  and
  kur.kur_cd = q1.code