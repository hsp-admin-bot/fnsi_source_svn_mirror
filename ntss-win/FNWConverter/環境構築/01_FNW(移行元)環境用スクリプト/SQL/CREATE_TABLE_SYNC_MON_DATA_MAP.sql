-- テーブル削除
-- DROP TABLE SYNC_MON_DATA_MAP CASCADE CONSTRAINTS;
declare
      num number;
begin
    select count(1) into num from user_tables where table_name = upper('SYNC_MON_DATA_MAP') ;
    if num > 0 then
        execute immediate 'drop table SYNC_MON_DATA_MAP CASCADE CONSTRAINTS' ;
    end if;
end;
/
-- テーブル作成
CREATE TABLE SYNC_MON_DATA_MAP
(
    TABLE_NAME VARCHAR2(20), 
    KIND_CD NUMBER,
    FNW_ITEM_CD NUMBER,
    FNSI_ITEM_CD VARCHAR2(16),
    FNSI_DATA_CLASS NUMBER
)
    tablespace NKK_DATA_COP;