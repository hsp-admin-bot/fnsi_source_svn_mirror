-- テーブル削除
-- DROP TABLE SYNC_DISP_ITEM_INFO CASCADE CONSTRAINTS;
declare
      num number;
begin
    select count(1) into num from user_tables where table_name = upper('SYNC_DISP_ITEM_INFO') ;
    if num > 0 then
        execute immediate 'drop table SYNC_DISP_ITEM_INFO CASCADE CONSTRAINTS' ;
    end if;
end;
/
-- テーブル作成
CREATE TABLE SYNC_DISP_ITEM_INFO
(
    COMPONENT VARCHAR2(20) NOT NULL,  --mst_pat_viewer_layout.disp_item_info[component]
    CATEGORYNO VARCHAR2(4) NOT NULL, --mst_pat_viewer_layout.disp_item_info[categoryNo]
    CATEGORYNAME VARCHAR2(20) NOT NULL,  --mst_pat_viewer_layout.disp_item_info[categoryName]
    NO VARCHAR2(4) NOT NULL,  
    GRAPHKIND NUMBER(1,0), --SYS_MUL_GRAPH_DETAIL[GRAPH_KIND]
    SUBCATEGORYNAME  VARCHAR2(20) NOT NULL --mst_pat_viewer_layout.disp_item_info[subCategoryName]
)
    tablespace NKK_DATA_COP;
-- コメント追加
COMMENT ON TABLE "SYNC_DISP_ITEM_INFO" IS 'mst_pat_viewer_layout.disp_item_info';
COMMENT ON COLUMN "SYNC_DISP_ITEM_INFO"."COMPONENT" IS 'mst_pat_viewer_layout.disp_item_info[component]';
COMMENT ON COLUMN "SYNC_DISP_ITEM_INFO"."CATEGORYNO" IS 'mst_pat_viewer_layout.disp_item_info[categoryNo]';
COMMENT ON COLUMN "SYNC_DISP_ITEM_INFO"."CATEGORYNAME" IS 'mst_pat_viewer_layout.disp_item_info[categoryName]';
COMMENT ON COLUMN "SYNC_DISP_ITEM_INFO"."NO" IS '';
COMMENT ON COLUMN "SYNC_DISP_ITEM_INFO"."GRAPHKIND" IS 'SYS_MUL_GRAPH_DETAIL[GRAPH_KIND]';
COMMENT ON COLUMN "SYNC_DISP_ITEM_INFO"."SUBCATEGORYNAME" IS 'mst_pat_viewer_layout.disp_item_info[subCategoryName]';


INSERT INTO "NKK"."SYNC_DISP_ITEM_INFO" ("COMPONENT", "CATEGORYNO", "CATEGORYNAME", "NO", "GRAPHKIND", "SUBCATEGORYNAME") VALUES ('weight', '1006', '体重グラフ①', '1', '0', '体重グラフ');
INSERT INTO "NKK"."SYNC_DISP_ITEM_INFO" ("COMPONENT", "CATEGORYNO", "CATEGORYNAME", "NO", "GRAPHKIND", "SUBCATEGORYNAME") VALUES ('weight', '1007', '体重グラフ②', '2', '0', '体重グラフ');
INSERT INTO "NKK"."SYNC_DISP_ITEM_INFO" ("COMPONENT", "CATEGORYNO", "CATEGORYNAME", "NO", "GRAPHKIND", "SUBCATEGORYNAME") VALUES ('weight', '1020', '体重グラフ③', '3', '0', '体重グラフ');
INSERT INTO "NKK"."SYNC_DISP_ITEM_INFO" ("COMPONENT", "CATEGORYNO", "CATEGORYNAME", "NO", "GRAPHKIND", "SUBCATEGORYNAME") VALUES ('weight', '1021', '体重グラフ④', '4', '0', '体重グラフ');
INSERT INTO "NKK"."SYNC_DISP_ITEM_INFO" ("COMPONENT", "CATEGORYNO", "CATEGORYNAME", "NO", "GRAPHKIND", "SUBCATEGORYNAME") VALUES ('exam-result', '1008', '検査結果グラフ①', '1', '1', '検査結果グラフ');
INSERT INTO "NKK"."SYNC_DISP_ITEM_INFO" ("COMPONENT", "CATEGORYNO", "CATEGORYNAME", "NO", "GRAPHKIND", "SUBCATEGORYNAME") VALUES ('exam-result', '1009', '検査結果グラフ②', '2', '1', '検査結果グラフ');
INSERT INTO "NKK"."SYNC_DISP_ITEM_INFO" ("COMPONENT", "CATEGORYNO", "CATEGORYNAME", "NO", "GRAPHKIND", "SUBCATEGORYNAME") VALUES ('exam-result', '1010', '検査結果グラフ③', '3', '1', '検査結果グラフ');
INSERT INTO "NKK"."SYNC_DISP_ITEM_INFO" ("COMPONENT", "CATEGORYNO", "CATEGORYNAME", "NO", "GRAPHKIND", "SUBCATEGORYNAME") VALUES ('exam-result', '1011', '検査結果グラフ④', '4', '1', '検査結果グラフ');
INSERT INTO "NKK"."SYNC_DISP_ITEM_INFO" ("COMPONENT", "CATEGORYNO", "CATEGORYNAME", "NO", "GRAPHKIND", "SUBCATEGORYNAME") VALUES ('drug-graph', '1012', '薬剤グラフ①', '1', '2', '薬剤グラフ');
INSERT INTO "NKK"."SYNC_DISP_ITEM_INFO" ("COMPONENT", "CATEGORYNO", "CATEGORYNAME", "NO", "GRAPHKIND", "SUBCATEGORYNAME") VALUES ('drug-graph', '1013', '薬剤グラフ②', '2', '2', '薬剤グラフ');
INSERT INTO "NKK"."SYNC_DISP_ITEM_INFO" ("COMPONENT", "CATEGORYNO", "CATEGORYNAME", "NO", "GRAPHKIND", "SUBCATEGORYNAME") VALUES ('drug-graph', '1014', '薬剤グラフ③', '3', '2', '薬剤グラフ');
INSERT INTO "NKK"."SYNC_DISP_ITEM_INFO" ("COMPONENT", "CATEGORYNO", "CATEGORYNAME", "NO", "GRAPHKIND", "SUBCATEGORYNAME") VALUES ('drug-graph', '1015', '薬剤グラフ④', '4', '2', '薬剤グラフ');
INSERT INTO "NKK"."SYNC_DISP_ITEM_INFO" ("COMPONENT", "CATEGORYNO", "CATEGORYNAME", "NO", "GRAPHKIND", "SUBCATEGORYNAME") VALUES ('comprehensive', '1024', '複合グラフ①', '1', '-1', '複合グラフ');
INSERT INTO "NKK"."SYNC_DISP_ITEM_INFO" ("COMPONENT", "CATEGORYNO", "CATEGORYNAME", "NO", "GRAPHKIND", "SUBCATEGORYNAME") VALUES ('comprehensive', '1025', '複合グラフ②', '2', '-1', '複合グラフ');
INSERT INTO "NKK"."SYNC_DISP_ITEM_INFO" ("COMPONENT", "CATEGORYNO", "CATEGORYNAME", "NO", "GRAPHKIND", "SUBCATEGORYNAME") VALUES ('comprehensive', '1026', '複合グラフ③', '3', '-1', '複合グラフ');
INSERT INTO "NKK"."SYNC_DISP_ITEM_INFO" ("COMPONENT", "CATEGORYNO", "CATEGORYNAME", "NO", "GRAPHKIND", "SUBCATEGORYNAME") VALUES ('comprehensive', '1027', '複合グラフ④', '4', '-1', '複合グラフ');

