SELECT /*%expand*/*
  FROM pat_exam_main                                      -- 患者検査結果
 WHERE pat_id = /* patId */NULL                           -- 患者ID
   AND result_exam_date >= /* examDateFrom */'1970/01/01' -- 結果時検査日時
   AND result_exam_date <  /* examDateTo */'2199/01/01'   -- 結果時検査日時
   AND is_del = '0'                                       -- 削除フラグ
 ORDER BY result_exam_date ASC                            -- 結果時検査日時
     , reg_order_class     ASC                            -- 登録時検査区分
;
