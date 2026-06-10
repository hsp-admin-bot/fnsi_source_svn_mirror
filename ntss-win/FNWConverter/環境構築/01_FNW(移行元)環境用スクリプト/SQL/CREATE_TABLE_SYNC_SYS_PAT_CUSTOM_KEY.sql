-- テーブル削除
-- DROP TABLE SYNC_SYS_PAT_CUSTOM_KEY CASCADE CONSTRAINTS;
declare
      num number;
begin
    select count(1) into num from user_tables where table_name = upper('SYNC_SYS_PAT_CUSTOM_KEY') ;
    if num > 0 then
        execute immediate 'drop table SYNC_SYS_PAT_CUSTOM_KEY CASCADE CONSTRAINTS' ;
    end if;
end;
/
-- テーブル作成
CREATE TABLE SYNC_SYS_PAT_CUSTOM_KEY
(
    CUSTOM_KEY_CD VARCHAR2(10),
    PATID VARCHAR2(50),
    SERIES_CD VARCHAR2(100)
)
    tablespace NKK_DATA_COP;





