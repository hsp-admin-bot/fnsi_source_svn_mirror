select
  pat_id,is_same
from
  pat_main
  where
--   add 8220 施設イベント詳細画面の表示が遅い 関 start
  is_same = '1'
  and
--   add 8220 施設イベント詳細画面の表示が遅い 関  end
  is_del = '0'
  and facility_cd in /* facilityCdList */(null)

  -- add by chamaojia 2026-02-05 [11893] キャッシュ軽減対応  --start
  /*%if 0 != patIds.size()*/
  and pat_id in /* patIds */(null)
  /*%end*/
  -- add by chamaojia 2026-02-05 [11893] キャッシュ軽減対応  --end
;
