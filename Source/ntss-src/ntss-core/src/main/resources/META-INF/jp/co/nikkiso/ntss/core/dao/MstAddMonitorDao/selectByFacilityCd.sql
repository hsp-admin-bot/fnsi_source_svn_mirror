SELECT /*%expand */*
  FROM mst_add_monitor                -- バイタル・モニタ項目追加マスタ
 WHERE facility_cd = /*facilityCd*/'' -- 施設コード
   AND is_disp = '1'                  -- 表示フラグ
   AND is_del = '0'                   -- 削除フラグ
-- 9312 ADD Sort case
order by
  vital_monitor_class
   , vital_monitor_item_cd
;
