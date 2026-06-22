select
  exam_item_cd,
  -- add #6736 総タンパク、ヘマトクリットの検査結果が装置設定に反映されない 鄭爽 start
  dialysis_progress_flag
 -- add #6736 総タンパク、ヘマトクリットの検査結果が装置設定に反映されない 鄭爽 end
from
  mst_exam_item
where
  facility_cd = /*facilityCd*/1
and
  is_disp = '1'
and
  is_del = '0'
  -- del #6736 総タンパク、ヘマトクリットの検査結果が装置設定に反映されない 鄭爽 start
--and
  --dialysis_progress_flag = '1'
  -- del #6736 総タンパク、ヘマトクリットの検査結果が装置設定に反映されない 鄭爽 end
and
  default_calc_exam_item_cd = '14'
and
  free_calc is null
ORDER BY up_date DESC;
