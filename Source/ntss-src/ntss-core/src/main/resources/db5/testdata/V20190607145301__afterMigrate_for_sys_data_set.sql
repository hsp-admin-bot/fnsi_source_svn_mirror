UPDATE
  sys_data_set
SET
 "sql"=
'
 select
   hosp_pat_id,
 	 personal_info_decrypt(pat_last_name)||personal_info_decrypt(pat_first_name) as pat_name
 from
   pat_personal_main
 where
   is_del = ''0''
 and
   pat_id = @patId
'
  , detail='[{"data_code": "pat_id", "field_name": "hosp_pat_id"}, {"data_code": "pat_name", "field_name": "pat_name"}]'
WHERE
  sql_cd = 1
;

UPDATE
  sys_data_set
SET
  "sql"=
'
 select
   *
   , to_char(rst_start_date, ''hh24:mm'') as rst_start_date_format
   , to_char(rst_end_date, ''hh24:mm'') as rst_end_date_format
 from
   ord_main
 where
   ord_no = @ordNo
'
  , detail='[{"data_code": "rst_start_date", "field_name": "rst_start_date_format"}, {"data_code": "rst_end_date", "field_name": "rst_end_date_format"}]'
WHERE
  sql_cd = 2
;
