select
  exam_pattern_cd                                 -- 患者検査パターンID
  , pat_id                                        -- 患者ID
  , facility_cd                                   -- 施設コード
  , fn_pat_id                                     -- FNW+で管理する施設内の一意な患者ID
  , reg_exam_date                                 -- 登録時検査日時
  , reg_order_class                               -- 登録時検査区分
  , exam_pattern                                  -- 検査依頼パターン
  , exam_week                                     -- 指定曜日
  , exam_from                                     -- 指定期間開始日
  , exam_to                                       -- 指定期間終了日
  , order_exam_set_cd                             -- 検査依頼コード
  , exam_order_info                               -- 検査依頼情報
  , order_label_info                              -- ラベル情報
  , is_del                                        -- 削除フラグ
  , reg_date                                      -- 登録日時
  , up_date
from pat_exam_pattern
where
  pat_id = /* params.get("patId") */null
and
  to_char(exam_from,'YYYY/MM/DD') <=  /* params.get("toDate") */null
and
  to_char(exam_to,'YYYY/MM/DD') >=  /* params.get("fromDate") */null
;
