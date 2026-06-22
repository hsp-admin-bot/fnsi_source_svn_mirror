SELECT /*%expand*/*
  FROM mst_exam_item                                      -- 検査項目マスタ
 WHERE facility_cd = /*facilityCd*/NULL                   -- 施設コード
   AND is_disp = '1'                                      -- 表示フラグ
   AND is_del  = '0'                                      -- 削除フラグ
   AND exam_item_cd IN /*examItemCdList*/(NULL)           -- 検査項目コード
 ORDER BY exam_item_cd                                    -- 検査項目コード
;
