-- テーブル削除
declare
      num number;
begin
    select count(1) into num from user_tables where table_name = upper('SYNC_FNSI_MEDICINE_LATEST_NO') ;
    if num > 0 then
        execute immediate 'drop table SYNC_FNSI_MEDICINE_LATEST_NO CASCADE CONSTRAINTS' ;
    end if;
end;
/
-- テーブル作成
CREATE TABLE SYNC_FNSI_MEDICINE_LATEST_NO
(
    PATID CHAR(12) NOT NULL,
    NO NUMBER(12) NOT NULL,
	FACILITYCD VARCHAR(12) NOT NULL
)
    tablespace NKK_DATA_COP;
