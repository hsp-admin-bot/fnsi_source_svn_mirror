-- テーブル削除
-- DROP TABLE SYNC_CONVERT_HISTORY CASCADE CONSTRAINTS;
declare
      num number;
begin
    select count(1) into num from user_tables where table_name = upper('SYNC_CONVERT_HISTORY') ;
    if num > 0 then
        execute immediate 'drop table SYNC_CONVERT_HISTORY CASCADE CONSTRAINTS' ;
    end if;
end;
/
-- テーブル作成
CREATE TABLE SYNC_CONVERT_HISTORY
(
    SEQ_NO NUMBER(6),  --シーケンス番号
    FACILITY_CD VARCHAR2(6),  --施設コード
    TABLE_KIND VARCHAR2(3),  --テーブル種別
    TABLE_NAME VARCHAR2(30),  --テーブル名
    CONVERT_DATETIME DATE,  --コンバート日時
    START_DATE DATE,  --期間開始日
    END_DATE DATE  --期間終了日
    ,CONSTRAINT SYNC_CONVERT_HISTORY_PRI PRIMARY KEY (SEQ_NO)
    using index tablespace NKK_INDEX_COP
)
    tablespace NKK_DATA_COP;
-- コメント追加
COMMENT ON TABLE "SYNC_CONVERT_HISTORY" IS 'コンバート履歴';
COMMENT ON COLUMN "SYNC_CONVERT_HISTORY"."SEQ_NO" IS 'シーケンス番号';
COMMENT ON COLUMN "SYNC_CONVERT_HISTORY"."FACILITY_CD" IS '施設コード';
COMMENT ON COLUMN "SYNC_CONVERT_HISTORY"."TABLE_KIND" IS 'テーブル種別';
COMMENT ON COLUMN "SYNC_CONVERT_HISTORY"."TABLE_NAME" IS 'テーブル名';
COMMENT ON COLUMN "SYNC_CONVERT_HISTORY"."CONVERT_DATETIME" IS 'コンバート日時';
COMMENT ON COLUMN "SYNC_CONVERT_HISTORY"."START_DATE" IS '期間開始日';
COMMENT ON COLUMN "SYNC_CONVERT_HISTORY"."END_DATE" IS '期間終了日';
