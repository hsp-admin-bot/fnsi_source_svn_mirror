-- DROP INDEX idx_sync_convert_hstry_dtl_01; 
declare
      num number;
begin
    select count(1) into num from user_indexes where index_name = upper('idx_sync_convert_hstry_dtl_01') ;
    if num > 0 then
        execute immediate 'DROP INDEX idx_sync_convert_hstry_dtl_01' ;
    end if;
end;
/
CREATE INDEX idx_sync_convert_hstry_dtl_01 ON sync_convert_history_dtl (CONVERTTS);
