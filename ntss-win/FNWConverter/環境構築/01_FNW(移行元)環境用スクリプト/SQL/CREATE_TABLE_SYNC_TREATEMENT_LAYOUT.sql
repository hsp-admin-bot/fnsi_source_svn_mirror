-- テーブル削除
-- DROP TABLE SYNC_TREATEMENT_LAYOUT CASCADE CONSTRAINTS;
declare
      num number;
begin
    select count(1) into num from user_tables where table_name = upper('SYNC_TREATEMENT_LAYOUT') ;
    if num > 0 then
        execute immediate 'drop table SYNC_TREATEMENT_LAYOUT CASCADE CONSTRAINTS' ;
    end if;
end;
/
-- テーブル作成
CREATE TABLE SYNC_TREATEMENT_LAYOUT
(
    FNGROUP_CD VARCHAR2(8) NOT NULL,
    TYPE VARCHAR2(5) NOT NULL,
    CONVERT_DATETIME DATE NOT NULL,
    FNW_TABLE_NAME  VARCHAR2(40) NOT NULL
)
    tablespace NKK_DATA_COP;