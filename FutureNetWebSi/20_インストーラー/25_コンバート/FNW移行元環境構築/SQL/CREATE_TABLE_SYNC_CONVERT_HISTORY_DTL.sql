-- テーブル削除
-- DROP TABLE SYNC_CONVERT_HISTORY_DTL CASCADE CONSTRAINTS;
declare
      num number;
begin
    select count(1) into num from user_tables where table_name = upper('SYNC_CONVERT_HISTORY_DTL') ;
    if num > 0 then
        execute immediate 'drop table SYNC_CONVERT_HISTORY_DTL CASCADE CONSTRAINTS' ;
    end if;
end;
/
-- テーブル作成
CREATE TABLE SYNC_CONVERT_HISTORY_DTL
(
    SEQ_NO NUMBER(6),  --シーケンス番号
    CONVERTTS VARCHAR2(100)  --患者ID
    ,CONSTRAINT SYNC_CONVERT_HISTORY_DTL_PRI PRIMARY KEY (SEQ_NO,CONVERTTS)
    using index tablespace NKK_INDEX_COP
)
    tablespace NKK_DATA_COP;
-- コメント追加
COMMENT ON TABLE "SYNC_CONVERT_HISTORY_DTL" IS 'コンバート履歴詳細';
COMMENT ON COLUMN "SYNC_CONVERT_HISTORY_DTL"."SEQ_NO" IS 'シーケンス番号';
COMMENT ON COLUMN "SYNC_CONVERT_HISTORY_DTL"."CONVERTTS" IS 'コンバート対象';
