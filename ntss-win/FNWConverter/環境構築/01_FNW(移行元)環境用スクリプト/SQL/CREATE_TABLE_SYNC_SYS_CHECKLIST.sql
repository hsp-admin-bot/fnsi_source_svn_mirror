-- テーブル削除
-- DROP TABLE SYNC_SYS_CHECKLIST CASCADE CONSTRAINTS;
declare
      num number;
begin
    select count(1) into num from user_tables where table_name = upper('SYNC_SYS_CHECKLIST') ;
    if num > 0 then
        execute immediate 'drop table SYNC_SYS_CHECKLIST CASCADE CONSTRAINTS' ;
    end if;
end;
/
-- テーブル作成
CREATE TABLE SYNC_SYS_CHECKLIST
(
    PATID VARCHAR2(50),  --患者ID
	JOIN_ITEM_NUMBER VARCHAR2(50),
    ITEM_NUMBER NUMBER,  --項目番号
    LIST_CD VARCHAR2(2),  --リストコード
    FUNK_FLG CHAR(1),  --機能フラグ
    CLASS_CD VARCHAR2(3),  --分類コード
    UP_DATE DATE,  --更新日
    SERIES_CD CHAR(3)  --系列施設コード
)
    tablespace NKK_DATA_COP;
-- コメント追加
COMMENT ON TABLE "SYNC_SYS_CHECKLIST" IS 'チェックリスト項目設定';
COMMENT ON COLUMN "SYNC_SYS_CHECKLIST"."JOIN_ITEM_NUMBER" IS '転換する前の項目番号をまとめ格納';
COMMENT ON COLUMN "SYNC_SYS_CHECKLIST"."ITEM_NUMBER" IS '項目番号';
COMMENT ON COLUMN "SYNC_SYS_CHECKLIST"."LIST_CD" IS 'リストコード';
COMMENT ON COLUMN "SYNC_SYS_CHECKLIST"."FUNK_FLG" IS '機能フラグ';
COMMENT ON COLUMN "SYNC_SYS_CHECKLIST"."CLASS_CD" IS '分類コード';
COMMENT ON COLUMN "SYNC_SYS_CHECKLIST"."UP_DATE" IS '更新日時';
COMMENT ON COLUMN "SYNC_SYS_CHECKLIST"."SERIES_CD" IS '系列施設コード';
