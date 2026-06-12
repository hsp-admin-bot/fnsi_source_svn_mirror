-- テーブル削除
-- DROP TABLE SYNC_FACILITY_CD CASCADE CONSTRAINTS;
declare
      num number;
begin
    select count(1) into num from user_tables where table_name = upper('SYNC_FACILITY_CD') ;
    if num > 0 then
        execute immediate 'drop table SYNC_FACILITY_CD CASCADE CONSTRAINTS' ;
    end if;
end;
/
-- テーブル作成
CREATE TABLE SYNC_FACILITY_CD
(
    ID VARCHAR2(50), 
    FACILITY_CD VARCHAR2(50),
    SERIES_CD VARCHAR2(50),
    VALUE VARCHAR2(256),
    HASH_VALUE VARCHAR2(100),
    PRIMARY KEY("ID"),
    COOPSET VARCHAR2(10),
    COOPVERSION VARCHAR2(10)
)
    tablespace NKK_DATA_COP;