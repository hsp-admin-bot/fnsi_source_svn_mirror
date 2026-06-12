-- テーブル削除
-- DROP TABLE SYNC_CONDSET CASCADE CONSTRAINTS;
declare
      num number;
begin
    select count(1) into num from user_tables where table_name = upper('SYNC_LOGIN') ;
    if num > 0 then
        execute immediate 'drop table SYNC_LOGIN CASCADE CONSTRAINTS' ;
    end if;
end;
/
-- テーブル作成
CREATE TABLE SYNC_LOGIN
(
    id VARCHAR2(50), 
    login VARCHAR2(50),
    pass VARCHAR2(50),
    token VARCHAR2(2000)
)
    tablespace NKK_DATA_COP;

INSERT INTO "NKK"."SYNC_LOGIN" ("ID", "LOGIN", "PASS", "TOKEN") VALUES ('1', NULL, NULL, NULL);
