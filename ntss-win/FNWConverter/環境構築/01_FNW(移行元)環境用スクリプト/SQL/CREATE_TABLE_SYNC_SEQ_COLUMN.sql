-- テーブル削除
--DROP TABLE SYNC_SEQ_COLUMN CASCADE CONSTRAINTS;
declare
      num number;
begin
    select count(1) into num from user_tables where table_name = upper('SYNC_SEQ_COLUMN') ;
    if num > 0 then
        execute immediate 'drop table SYNC_SEQ_COLUMN CASCADE CONSTRAINTS' ;
    end if;
end;
/
-- テーブル作成
CREATE TABLE SYNC_SEQ_COLUMN
(
    NTSS_TABLE_NAME VARCHAR2(50) NOT NULL,  --NTSSテーブル名
    NTSS_COLUMN_NO NUMBER(3,0) NOT NULL,  --NTSSカラムNo
    NTSS_COLUMN_NAME VARCHAR2(50) NOT NULL,  --NTSSカラム名
    UNIQUE_COLUMNS VARCHAR2(100) NOT NULL  --ユニークカラム
)
    tablespace NKK_DATA_COP;
-- コメント追加
COMMENT ON TABLE "SYNC_SEQ_COLUMN" IS 'シーケンス定義';
COMMENT ON COLUMN "SYNC_SEQ_COLUMN"."NTSS_TABLE_NAME" IS 'NTSSテーブル名';
COMMENT ON COLUMN "SYNC_SEQ_COLUMN"."NTSS_COLUMN_NO" IS 'NTSSカラムNo';
COMMENT ON COLUMN "SYNC_SEQ_COLUMN"."NTSS_COLUMN_NAME" IS 'NTSSカラム名';
COMMENT ON COLUMN "SYNC_SEQ_COLUMN"."UNIQUE_COLUMNS" IS 'ユニークカラム';
