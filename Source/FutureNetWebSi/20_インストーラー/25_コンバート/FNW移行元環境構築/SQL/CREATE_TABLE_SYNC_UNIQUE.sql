-- テーブル削除
-- DROP TABLE SYNC_UNIQUE CASCADE CONSTRAINTS;
declare
      num number;
begin
    select count(1) into num from user_tables where table_name = upper('SYNC_UNIQUE') ;
    if num > 0 then
        execute immediate 'drop table SYNC_UNIQUE CASCADE CONSTRAINTS' ;
    end if;
end;
/
-- テーブル作成
CREATE TABLE SYNC_UNIQUE
(
    NTSS_TABLE_NAME VARCHAR2(50),  --NTSSテーブル名
    CONSTRAINT_NAME VARCHAR2(50),  --ユニーク制約名
    UNIQUE_COLUMNS VARCHAR2(100),  --ユニークカラム
    NTSS_SEQ_COLUMN_NAME VARCHAR2(50)  --シーケンス発番カラム名
    ,CONSTRAINT SYNC_UNIQUE_PRI PRIMARY KEY (NTSS_TABLE_NAME,CONSTRAINT_NAME)
    using index tablespace NKK_INDEX_COP
)
    tablespace NKK_DATA_COP;
-- コメント追加
COMMENT ON TABLE "SYNC_UNIQUE" IS 'ユニーク制約定義';
COMMENT ON COLUMN "SYNC_UNIQUE"."NTSS_TABLE_NAME" IS 'NTSSテーブル名';
COMMENT ON COLUMN "SYNC_UNIQUE"."CONSTRAINT_NAME" IS 'ユニーク制約名';
COMMENT ON COLUMN "SYNC_UNIQUE"."UNIQUE_COLUMNS" IS 'ユニークカラム';
COMMENT ON COLUMN "SYNC_UNIQUE"."NTSS_SEQ_COLUMN_NAME" IS 'シーケンス発番カラム名';
