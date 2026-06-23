-- 共通設定タブ定義テーブル
-- テーブル削除
DROP TABLE IF EXISTS sys_personal_settings_define;
-- テーブル作成
CREATE TABLE sys_personal_settings_define
(
    personal_settings_cd serial NOT NULL,  --共通設定ID
    tab_define_cd integer NOT NULL,  --タブ定義コード
    edit_level character varying(1),  --表示管理レベル
    item_info jsonb,  --設定項目情報
    combo_data jsonb,  --固定コンボデータ
    reference_combo_def jsonb,  --参照型コンボデータ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_sys_personal_settings_define_01 PRIMARY KEY (personal_settings_cd),
    CONSTRAINT unq_sys_personal_settings_define_02 UNIQUE (tab_define_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "sys_personal_settings_define" IS E'共通設定タブ定義';
COMMENT ON COLUMN "sys_personal_settings_define"."personal_settings_cd" IS E'共通設定ID';
COMMENT ON COLUMN "sys_personal_settings_define"."tab_define_cd" IS E'タブ定義コード';
COMMENT ON COLUMN "sys_personal_settings_define"."edit_level" IS E'表示管理レベル';
COMMENT ON COLUMN "sys_personal_settings_define"."item_info" IS E'設定項目情報';
COMMENT ON COLUMN "sys_personal_settings_define"."combo_data" IS E'固定コンボデータ';
COMMENT ON COLUMN "sys_personal_settings_define"."reference_combo_def" IS E'参照型コンボデータ';
COMMENT ON COLUMN "sys_personal_settings_define"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sys_personal_settings_define"."up_date" IS E'更新日時';
