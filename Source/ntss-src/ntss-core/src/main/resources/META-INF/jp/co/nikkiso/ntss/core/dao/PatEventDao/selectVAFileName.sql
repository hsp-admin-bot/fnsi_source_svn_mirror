-- 患者イベント実績情報から患者、VA名が一致するVA画像ファイル名を指定件数取得
select
  pat_event_cd,
  pat_id,
  substring(to_timestamp(ev2.event_start_date, 'YYYYMMDD')::text, 1, 10) as event_start_date,
  up_date,
  format_class,
  result_value,
  idx,
  idx2,
  result_value::json ->> 'name' as name,
  result_value::json ->> 'is_send_va' as is_send_va,
  result_value::json ->> 'file_path' as file_path
from
  (select
    pat_event_cd,
    pat_id,
    event_start_date,
    up_date,
    result,
    idx,
    result ->> 'format_class' as format_class,
    result ->> 'result_value' as result_values
  from
    pat_event as ev1
  -- result_params分解
  cross join lateral json_array_elements (ev1.result_params :: json)
  with ordinality as T ( result, idx)
  where
    pat_id = /*patId*/0
  and
    -- 利用種別 1：VA
    use_type = 1
  and
    -- 状況区分 1：実績
    event_status = '1'
  and
    is_newest = '1'
  and
    is_del = '0'
  and
    result_params is not null
  and
    -- 項目種別 2：画像
    result ->> 'format_class' ='2'
-- add #11470 by shiyw 20250314 start
  and -- VA名が一致
    result ->> 'va_name' = /*vaName*/'VA'
-- add #11470 by shiyw 20250314 end
  ) ev2
-- result_values分解
cross join lateral json_array_elements ( ev2.result_values :: json)
with ordinality as T (result_value ,idx2)
where
  result_values is not null
-- del #11470 by shiyw 20250314 start
-- and
--   -- VA名が一致
--   result_value::json ->> 'name' = /*vaName*/'VA'
-- del #11470 by shiyw 20250314 end
and
  -- VA転送対象フラグ 1：対象
  result_value::json ->> 'is_send_va' = '1'
and
  -- VA画像ファイル名あり
  result_value::json ->> 'file_path' is not null
order by
  event_start_date desc
  , up_date desc
  , idx
  , idx2
limit /*limitCount*/1 offset 0
;