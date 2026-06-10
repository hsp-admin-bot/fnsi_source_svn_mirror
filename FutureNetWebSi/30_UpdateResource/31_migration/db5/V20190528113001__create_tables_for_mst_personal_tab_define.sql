-- テーブル削除
DROP TABLE IF EXISTS mst_personal_tab_define;
-- テーブル作成
CREATE TABLE mst_personal_tab_define
(
    tab_define_cd serial NOT NULL,  --タブ定義コード
    facility_cd character varying(6) NOT NULL,  --施設コード
    display_name character varying(100) NOT NULL,  --タブ表示名
    contents_id character varying(500) NOT NULL,  --タブコンテンツID
    disp_order smallint NOT NULL,  --タブの表示順（昇順）
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_personal_tab_define_01 PRIMARY KEY (tab_define_cd),
    CONSTRAINT unq_mst_personal_tab_define_02 UNIQUE(facility_cd, disp_order)
)
WITH (
    OIDS=FALSE
);

-- コメント追加
COMMENT ON TABLE "mst_personal_tab_define" IS E'施設ごとの個人設定タブ定義';
COMMENT ON COLUMN "mst_personal_tab_define"."tab_define_cd" IS E'タブ定義コード';
COMMENT ON COLUMN "mst_personal_tab_define"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_personal_tab_define"."display_name" IS E'タブ表示名';
COMMENT ON COLUMN "mst_personal_tab_define"."contents_id" IS E'タブコンテンツID';
COMMENT ON COLUMN "mst_personal_tab_define"."disp_order" IS E'タブの表示順（昇順）';
COMMENT ON COLUMN "mst_personal_tab_define"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_personal_tab_define"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_personal_tab_define"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_personal_tab_define"."up_date" IS E'更新日時';
