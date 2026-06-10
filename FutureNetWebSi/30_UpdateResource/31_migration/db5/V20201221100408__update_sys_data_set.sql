--------------------------------------------------
-- データセット
-- ラベルのSQL文を更新
--------------------------------------------------
UPDATE
  sys_data_set
SET
  "sql" = '
   select
    pat_id
    , 
    hosp_pat_id
    , ntss.personal_info_decrypt(pat_last_name)||ntss.personal_info_decrypt(pat_first_name) as pat_name
    , ntss.personal_info_decrypt(pat_last_name_kana)||ntss.personal_info_decrypt(pat_first_name_kana) as pat_name_kana
from
    ntss.pat_personal_main
where
    is_del = ''0''
and
    pat_id  IN (@patIds)
order by pat_id
  ',
  up_date = current_timestamp
WHERE
  sql_cd = 17
;
