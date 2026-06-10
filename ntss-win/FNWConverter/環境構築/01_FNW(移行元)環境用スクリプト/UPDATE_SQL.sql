-- 処理結果出力
set feedback on
-- 不要なスペースは削除
set trimspool on
-- 出力ページ設定
set pages 999
-- 1行の出力サイズ設定
set linesize 32767
-- dbms_output出力設定
set serveroutput on size 200000

-- 出力ファイル名
spool .\データコンバート環境更新.log

set echo on


-- 接続
-- 【注意】実行前に接続先を必ず確認すること
connect nkk/nkk@nkkfn3;

----------------------------------------------------------
--- ↓↓実行対象のSQLファイルパス記載
----------------------------------------------------------
--例
--@.\SQL\aaa.sql

-------------------------------
-- テーブル作成
-------------------------------
@.\SQL\CREATE_TABLE_TSS_MST.sql
@.\SQL\CREATE_TABLE_TSS_ORD.sql
@.\SQL\CREATE_TABLE_TSS_PAT.sql
@.\SQL\CREATE_TABLE_SYNC_CONV_VALUE.sql
@.\SQL\CREATE_TABLE_SYNC_CUSTOM_CONVERT_VALUE.sql
@.\SQL\CREATE_TABLE_SYNC_FK_CONV_INFO.sql
@.\SQL\CREATE_TABLE_SYNC_SEQ_COLUMN.sql
@.\SQL\CREATE_TABLE_SYNC_UNIQUE.sql
@.\SQL\CREATE_TABLE_SYNC_SYS_CHECKLIST.sql
@.\SQL\CREATE_TABLE_SYNC_ORD_CHECKLIST_HIST.sql
@.\SQL\CREATE_TABLE_SYNC_CHECKLIST_HIST.sql
@.\SQL\CREATE_TABLE_SYNC_TABLE_INFO.sql
@.\SQL\CREATE_TABLE_SYNC_FACILITY_CD.sql
@.\SQL\CREATE_TABLE_SYNC_CondSet.sql
@.\SQL\CREATE_TABLE_SYNC_CONV_REASON.sql
@.\SQL\CREATE_TABLE_SYNC_MST_HIS.sql
@.\SQL\CREATE_TABLE_SYNC_SYS_PAT_CUSTOM_KEY.sql
@.\SQL\CREATE_TABLE_SYNC_IND_HISTORY_DETAIL.sql
@.\SQL\CREATE_TABLE_SYNC_MEDICINE_LATEST_NO.sql
@.\SQL\CREATE_TABLE_SYNC_CondLogin.sql
@.\SQL\CREATE_TABLE_LIST_WATER_SURVEY_TYPE_TEXT.sql
@.\SQL\CREATE_TABLE_SYNC_MAINTE_PARTS_DETAIL.sql
@.\SQL\CREATE_TABLE_SYNC_CHECKLIST_PERIOD_DETAIL.sql
@.\SQL\CREATE_TABLE_SYNC_MON_DATA_MAP.sql
@.\SQL\CREATE_TABLE_SYNC_TREATEMENT_LAYOUT.sql
@.\SQL\CREATE_TABLE_SYNC_FNSI_MEDICINE_LATEST_NO.sql
@.\SQL\CREATE_TABLE_SYNC_DISP_ITEM_INFO.sql
@.\SQL\CREATE_TABLE_SYNC_SET_MEDICINE.sql
@.\SQL\CREATE_TABLE_SYNC_MST_DEVICE_HIS.sql
@.\SQL\CREATE_TABLE_SYNC_COOP_CONVERT_SET.sql
-------------------------------
-- レコード登録
-------------------------------
@.\SQL\INSERT_TABLE_TSS_MST.sql
@.\SQL\INSERT_TABLE_TSS_ORD.sql
@.\SQL\INSERT_TABLE_TSS_PAT.sql
@.\SQL\INSERT_TABLE_SYNC_CONV_VALUE.sql
@.\SQL\INSERT_TABLE_SYNC_CUSTOM_CONVERT_VALUE.sql
@.\SQL\INSERT_TABLE_SYNC_FK_CONV_INFO.sql
@.\SQL\INSERT_TABLE_SYNC_SEQ_COLUMN.sql
@.\SQL\INSERT_TABLE_SYNC_UNIQUE.sql
@.\SQL\INSERT_TABLE_SYNC_TABLE_INFO.sql
@.\SQL\INSERT_TABLE_SYNC_MON_DATA_MAP.sql

exit ;
