--------------------------------------------------
-- 患者経過総合ビューアレイアウトマスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_pat_viewer_layout;
-- テーブル作成
CREATE TABLE mst_pat_viewer_layout
(
layout_cd bigserial NOT NULL,  --レイアウトコード
facility_cd character varying(6),  --施設コード
layout_name character varying,  --レイアウト名
disp_item_info jsonb,  --表示項目
is_disp character varying(1) DEFAULT '1',  --表示フラグ
is_del character varying(1) DEFAULT '0',  --削除フラグ
reg_date timestamp(3),  --登録日時
up_date timestamp(3),  --更新日時
CONSTRAINT unq_mst_pat_viewer_layout_01 PRIMARY KEY (layout_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_pat_viewer_layout" IS E'患者経過総合ビューアレイアウトマスタ';
COMMENT ON COLUMN "mst_pat_viewer_layout"."layout_cd" IS E'レイアウトコード';
COMMENT ON COLUMN "mst_pat_viewer_layout"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_pat_viewer_layout"."layout_name" IS E'レイアウト名';
COMMENT ON COLUMN "mst_pat_viewer_layout"."disp_item_info" IS E'表示項目';
COMMENT ON COLUMN "mst_pat_viewer_layout"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_pat_viewer_layout"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_pat_viewer_layout"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_pat_viewer_layout"."up_date" IS E'更新日時';
