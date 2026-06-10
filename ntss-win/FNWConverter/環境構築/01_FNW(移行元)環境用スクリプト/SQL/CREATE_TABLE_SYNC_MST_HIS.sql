-- テーブル削除
-- DROP TABLE SYNC_MST_HIS CASCADE CONSTRAINTS;
declare
      num number;
begin
    select count(1) into num from user_tables where table_name = upper('SYNC_MST_HIS') ;
    if num > 0 then
        execute immediate 'drop table SYNC_MST_HIS CASCADE CONSTRAINTS' ;
    end if;
end;
/
-- テーブル作成
CREATE TABLE SYNC_MST_HIS
(
    TABLENAME VARCHAR2(50),
    KEY VARCHAR2(100),  
    DISP_ORDER NUMBER(5), 
    DEL_FLG CHAR(1),  
    IN_HOSPITAL_CD1 VARCHAR2(30), 
    IN_HOSPITAL_CD2 VARCHAR2(30),
	IN_HOSPITAL_CD3 VARCHAR2(30),
	SERIES_CD VARCHAR2(3)
)
    tablespace NKK_DATA_COP;
-- コメント追加
COMMENT ON TABLE "SYNC_MST_HIS" IS '前回コンバートデータバックアップテーブル';

COMMENT ON COLUMN "SYNC_MST_HIS"."TABLENAME" IS 'テーブル名';
COMMENT ON COLUMN "SYNC_MST_HIS"."KEY" IS '主キー';
COMMENT ON COLUMN "SYNC_MST_HIS"."DISP_ORDER" IS '表示順';
COMMENT ON COLUMN "SYNC_MST_HIS"."DEL_FLG" IS '表示フラグ';
COMMENT ON COLUMN "SYNC_MST_HIS"."IN_HOSPITAL_CD1" IS '院内コード1';
COMMENT ON COLUMN "SYNC_MST_HIS"."IN_HOSPITAL_CD2" IS '院内コード2';
COMMENT ON COLUMN "SYNC_MST_HIS"."IN_HOSPITAL_CD3" IS '院内コード3';
COMMENT ON COLUMN "SYNC_MST_HIS"."SERIES_CD" IS '系列施設コード';


