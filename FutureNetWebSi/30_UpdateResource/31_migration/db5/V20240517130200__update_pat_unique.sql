-- 患者固有情報.既往歴情報 >> 死亡日、転帰変更日 から"-"除去 
UPDATE pat_unique
SET medical_hst_info = 
  CAST( 
    regexp_replace( 
      CAST(medical_hst_info AS text), 
      '(\d{4})-(\d{2})-(\d{2})',
      '\1\2\3',
      'g'
    ) AS jsonb
  )
WHERE
    jsonb_path_exists(
        medical_hst_info,
        '$.die_date ? (@ like_regex ".*-.*")'
    )
    OR
    jsonb_path_exists(
        medical_hst_info,
        '$.out_come_date ? (@ like_regex ".*-.*")'
    )
;

-- 患者固有情報.入外・転入出情報 >> 日付(開始～終了) から"-"除去 
UPDATE pat_unique
SET in_out_visit_history_info = 
  CAST( 
    regexp_replace( 
      CAST(in_out_visit_history_info AS text), 
      '(\d{4})-(\d{2})-(\d{2})',
      '\1\2\3',
      'g'
    ) AS jsonb
  )
WHERE
    jsonb_path_exists(
        in_out_visit_history_info,
        '$.period_start_date ? (@ like_regex ".*-.*")'
    )
    OR
    jsonb_path_exists(
        in_out_visit_history_info,
        '$.period_end_date ? (@ like_regex ".*-.*")'
    )
;
