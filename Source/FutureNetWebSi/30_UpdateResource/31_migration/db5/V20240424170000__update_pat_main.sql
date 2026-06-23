--#10544:pat_main infect_info (infect_info　exam_dateの不正データ修復)
UPDATE pat_main 
SET infect_info =
  CAST( 
    regexp_replace( 
      CAST(infect_info AS text), 
      '-', 
      '', 
      'g'
    ) AS jsonb
  )
where
  CAST(infect_info AS text)like '%exam_date%'
  and CAST(infect_info AS text)like '%-%';