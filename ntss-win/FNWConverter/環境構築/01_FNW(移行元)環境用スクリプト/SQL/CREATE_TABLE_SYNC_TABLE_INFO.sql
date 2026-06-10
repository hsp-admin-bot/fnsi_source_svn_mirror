-- テーブル削除
--DROP TABLE SYNC_TABLE_INFO CASCADE CONSTRAINTS;
declare
      num number;
begin
    select count(1) into num from user_tables where table_name = upper('SYNC_TABLE_INFO') ;
    if num > 0 then
        execute immediate 'drop table SYNC_TABLE_INFO CASCADE CONSTRAINTS' ;
    end if;
end;
/
-- テーブル作成
CREATE TABLE SYNC_TABLE_INFO
(
    NTSS_TABLE_NAME VARCHAR2(50),  --NTSSテーブル名
    NO_FACILITY_CD_FLG VARCHAR2(1) DEFAULT '0'  --施設コードなしフラグ
    ,CONSTRAINT SYNC_TABLE_INFO_PRI PRIMARY KEY (NTSS_TABLE_NAME)
    using index tablespace NKK_INDEX_COP
)
    tablespace NKK_DATA_COP;
-- コメント追加
COMMENT ON TABLE "SYNC_TABLE_INFO" IS 'テーブル固有情報';
COMMENT ON COLUMN "SYNC_TABLE_INFO"."NTSS_TABLE_NAME" IS 'NTSSテーブル名';
COMMENT ON COLUMN "SYNC_TABLE_INFO"."NO_FACILITY_CD_FLG" IS '施設コードなしフラグ';
