--患者基本情報.インプラント 導入日、除去日 から"-"除去 
UPDATE pat_main
SET implant_info = 
  CAST( 
    regexp_replace( 
      CAST(implant_info AS text), 
      '(\d{4})-(\d{2})-(\d{2})',
      '\1\2\3',
      'g'
    ) AS jsonb
  )
WHERE
  jsonb_path_exists(
    implant_info,
    '$.reg_date ? (@ like_regex ".*-.*")'
  )
  OR
  jsonb_path_exists(
    implant_info,
    '$.remove_date ? (@ like_regex ".*-.*")'
  )
;
