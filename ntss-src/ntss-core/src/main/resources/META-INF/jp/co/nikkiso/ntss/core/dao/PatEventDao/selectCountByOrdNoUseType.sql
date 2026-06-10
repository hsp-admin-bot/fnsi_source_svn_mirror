-- 患者イベント実績情報から指定したオーダー番号、利用種別で件数取得
select
  ord_no,count(pat_event_cd) as count
from
  pat_event
where
  ord_no in /*ordNoList*/(0)
and
  facility_cd = /*facilityCd*/null
and
  -- 利用種別
  use_type = /*useType*/1
and
  -- 状況区分 1：実績
  event_status = '1'
 and
  is_newest = '1'
and
  is_del = '0'
-- 治療状況リスト性能改善 劉 start
group by ord_no
-- 治療状況リスト性能改善 劉 end
;
