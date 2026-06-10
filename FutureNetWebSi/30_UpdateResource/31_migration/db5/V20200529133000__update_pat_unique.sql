-- 削除済み患者のpat_unique.is_delを'1'に更新する
UPDATE 
  pat_unique
SET 
  is_del = '1' 
FROM 
  pat_main 
WHERE 
  pat_unique.pat_id = pat_main.pat_id 
  AND 
  pat_main.is_del = '1' 
  AND 
  pat_unique.is_del = '0';
