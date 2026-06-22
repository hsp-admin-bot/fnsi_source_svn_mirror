SELECT /*%expand*/*
  FROM pat_exam_main                                                         -- 患者検査結果
 WHERE pat_id = /* patId */NULL                                             -- 患者ID
   AND exam_status = '1'                                                    -- 状況区分
   AND to_char(result_exam_date, 'yyyyMMdd') > /*examDate*/'2199/01/01'   -- 結果時検査日時
   AND is_del = '0'                                                             -- 削除フラグ
 ORDER BY result_exam_date ASC                                              -- 結果時検査日時
     , reg_order_class     ASC                                              -- 登録時検査区分
;
