-- テーブル削除
-- DROP TABLE SYNC_WATER_SURVEY_TYPE_TEXT CASCADE CONSTRAINTS;
declare
      num number;
begin
    select count(1) into num from user_tables where table_name = upper('SYNC_WATER_SURVEY_TYPE_TEXT') ;
    if num > 0 then
        execute immediate 'drop table SYNC_WATER_SURVEY_TYPE_TEXT CASCADE CONSTRAINTS' ;
    end if;
end;
/
-- テーブル作成
CREATE TABLE SYNC_WATER_SURVEY_TYPE_TEXT
(
    SURVEY_TYPE_CD CHAR(2 BYTE) NOT NULL,  --水質種別コード
    TEXT_NO VARCHAR2(4) NOT NULL,  --結果文字列番号
    TEXT VARCHAR2(64) NOT NULL,  --結果文字列
    UP_DATE DATE NOT NULL,  --更新日時
    CHECKED VARCHAR2(5) NOT NULL　 --デフォルト
)
    tablespace NKK_DATA_COP;
-- コメント追加
COMMENT ON TABLE "SYNC_WATER_SURVEY_TYPE_TEXT" IS '水質種別文字列リスト';
COMMENT ON COLUMN "SYNC_WATER_SURVEY_TYPE_TEXT"."SURVEY_TYPE_CD" IS '水質種別コード';
COMMENT ON COLUMN "SYNC_WATER_SURVEY_TYPE_TEXT"."TEXT_NO" IS '結果文字列番号';
COMMENT ON COLUMN "SYNC_WATER_SURVEY_TYPE_TEXT"."TEXT" IS '結果文字列';
COMMENT ON COLUMN "SYNC_WATER_SURVEY_TYPE_TEXT"."UP_DATE" IS '更新日時';
COMMENT ON COLUMN "SYNC_WATER_SURVEY_TYPE_TEXT"."CHECKED" IS 'デフォルト';
