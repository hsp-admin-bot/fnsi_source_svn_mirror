-- テーブル削除
-- DROP TABLE SYNC_CONDSET CASCADE CONSTRAINTS;
declare
      num number;
begin
    select count(1) into num from user_tables where table_name = upper('SYNC_CONDSET') ;
    if num > 0 then
        execute immediate 'drop table SYNC_CONDSET CASCADE CONSTRAINTS' ;
    end if;
end;
/
-- テーブル作成
CREATE TABLE SYNC_CONDSET
(
    IsChecked VARCHAR2(50),  --NTSSテーブル名
    LineNumber VARCHAR2(50),  --NTSSテーブル名
    Boold VARCHAR2(2000),  --ユニーク制約名
    p_A VARCHAR2(2000),  --ユニークカラム
    p_V VARCHAR2(2000),  --シーケンス発番カラム名
    p_SN VARCHAR2(2000),
	R_R VARCHAR2(2000),
    AUTOMATIC NUMBER(1),
    SERIES_CD CHAR(3) NOT NULL
)
    tablespace NKK_DATA_COP;
-- コメント追加
COMMENT ON TABLE "SYNC_CONDSET" IS '設定値';

COMMENT ON COLUMN "SYNC_CONDSET"."ISCHECKED" IS '予約方法';
COMMENT ON COLUMN "SYNC_CONDSET"."LINENUMBER" IS '桁保留';
COMMENT ON COLUMN "SYNC_CONDSET"."BOOLD" IS '血液回路';
COMMENT ON COLUMN "SYNC_CONDSET"."P_A" IS '穿刺針(A針)';
COMMENT ON COLUMN "SYNC_CONDSET"."P_V" IS '穿刺針(V針)';
COMMENT ON COLUMN "SYNC_CONDSET"."P_SN" IS '穿刺針(SN)';
COMMENT ON COLUMN "SYNC_CONDSET"."R_R" IS '観察記録種別';
COMMENT ON COLUMN "SYNC_CONDSET"."AUTOMATIC" IS '出力完了後アップロードと送信を自動実行(1自動実行)';
COMMENT ON COLUMN "SYNC_CONDSET"."SERIES_CD" IS '系列施設';

INSERT INTO "NKK"."SYNC_CONDSET" ( "ISCHECKED", "LINENUMBER", "BOOLD", "P_A", "P_V", "P_SN", "R_R", "AUTOMATIC","SERIES_CD" )
select  '2', '11', NULL, NULL, NULL, NULL, NULL, 1,SERIES_CD from  SYS_SERIES_FACILITY;
