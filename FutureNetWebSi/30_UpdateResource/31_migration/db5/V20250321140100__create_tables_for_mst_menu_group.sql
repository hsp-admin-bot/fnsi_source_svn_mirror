-- テーブル削除
DROP TABLE IF EXISTS mst_menu_group;
-- テーブル作成
CREATE TABLE mst_menu_group
(
  menu_group_cd bigserial NOT NULL,  --URLコード
  facility_cd character varying(6) NOT NULL,  --施設コード
  menu_group_name character varying(256) NOT NULL,  --メニューグループ名
  menu_list jsonb NOT NULL DEFAULT '[]'::jsonb, --メニューリスト
  icon_info jsonb NOT NULL DEFAULT '{}'::jsonb, --アイコン情報
  is_disp character varying(1) DEFAULT '1',  --表示フラグ
  is_del character varying(1) DEFAULT '0',  --削除フラグ
  reg_date timestamp(3),  --登録日時
  up_date timestamp(3),  --更新日時
  CONSTRAINT unq_mst_menu_group_01 PRIMARY KEY (menu_group_cd)
);
-- コメント追加
COMMENT ON TABLE "mst_menu_group" IS E'メニューグループマスタ';
COMMENT ON COLUMN "mst_menu_group"."menu_group_cd" IS E'システムで管理する一意なメニューグループコード';
COMMENT ON COLUMN "mst_menu_group"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_menu_group"."menu_group_name" IS E'メニューグループ名';
COMMENT ON COLUMN "mst_menu_group"."menu_list" IS E'メニューリスト';
COMMENT ON COLUMN "mst_menu_group"."icon_info" IS E'アイコン情報';
COMMENT ON COLUMN "mst_menu_group"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_menu_group"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_menu_group"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_menu_group"."up_date" IS E'更新日時';
