SELECT /*%expand*/*
  FROM mst_exam_item                                                 -- 検査項目マスタ
 WHERE facility_cd = /*facilityCd*/NULL                              -- 施設コード
   AND is_disp = '1'                                                 -- 表示フラグ
   AND is_del  = '0'                                                 -- 削除フラグ
   AND exam_class  = /*examClass*/NULL                               -- 検査使用区分
   AND default_calc_exam_item_cd IN /*defaultCalcExamItemCd*/(NULL)  -- システム標準計算検査項目
;
