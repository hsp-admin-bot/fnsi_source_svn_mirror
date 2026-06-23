UPDATE "ntss"."sys_data_set" 
SET "sql" = 'select
  *
from
  ord_main
where
  ord_no = @ordNo
and is_del = ''0''
and rst_dialysis_state <>''0'''
WHERE
	sql_cd = '2';