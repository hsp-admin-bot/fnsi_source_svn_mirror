-- テーブル削除
-- DROP TABLE SYNC_MST_DEVICE_HIS CASCADE CONSTRAINTS;
declare
      num number;
begin
    select count(1) into num from user_tables where table_name = upper('SYNC_MST_DEVICE_HIS') ;
    if num > 0 then
        execute immediate 'drop table SYNC_MST_DEVICE_HIS CASCADE CONSTRAINTS' ;
    end if;
end;
/
-- テーブル作成
CREATE TABLE SYNC_MST_DEVICE_HIS
(
    DEVICE_NO NUMBER(10,0) NOT NULL,  --NTSSテーブル名
    DEVICE_OPTION VARCHAR2(4000)
)
    tablespace NKK_DATA_COP;
-- コメント追加
COMMENT ON TABLE "SYNC_MST_DEVICE_HIS" IS 'MST_DEVICEの履歴';

