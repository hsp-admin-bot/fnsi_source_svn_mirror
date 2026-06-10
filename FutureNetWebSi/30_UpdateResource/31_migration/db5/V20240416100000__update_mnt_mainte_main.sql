--#10452：点検結果　Detail date不正修復
UPDATE mnt_mainte_main 
SET
  detail = CAST( 
       regexp_replace( 
           CAST(detail AS text), 
           '"date": "[^"]*?",', 
           '"date": "' || to_char(up_date, 'YYYY-MM-DD') || '",', 
           'g'   
    ) AS jsonb
  )
  where mainte_class = '2';
