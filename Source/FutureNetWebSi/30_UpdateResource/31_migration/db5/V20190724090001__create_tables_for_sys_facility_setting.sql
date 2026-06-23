-- テーブル削除（システム施設設定）
DROP TABLE IF EXISTS sys_facility_setting;
-- テーブル作成（システム施設設定）
CREATE TABLE sys_facility_setting
(
    facility_setting_no character varying(4) NOT NULL,  --施設設定番号
    setting_name character varying(256),  --設定名称
    default_value character varying,  --初期値
    input_type numeric(1) NOT NULL,  --入力方法
    option_value character varying,  --オプション情報
    function_name character varying(256),  --機能名
    maker_setting numeric(1) NOT NULL,  --操作権限可否
    description character varying,  --設定説明
    disp_order numeric(5),  --表示順
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
           
    CONSTRAINT unq_sys_facility_setting_01 PRIMARY KEY (facility_setting_no)
)WITH (
    OIDS=FALSE
);

-- コメント追加
COMMENT ON TABLE "sys_facility_setting" IS E'システム施設設定';
COMMENT ON COLUMN "sys_facility_setting"."facility_setting_no" IS E'施設設定番号';
COMMENT ON COLUMN "sys_facility_setting"."setting_name" IS E'設定名称';
COMMENT ON COLUMN "sys_facility_setting"."default_value" IS E'初期値';
COMMENT ON COLUMN "sys_facility_setting"."input_type" IS E'入力方法';
COMMENT ON COLUMN "sys_facility_setting"."option_value" IS E'オプション情報';
COMMENT ON COLUMN "sys_facility_setting"."function_name" IS E'機能名';
COMMENT ON COLUMN "sys_facility_setting"."maker_setting" IS E'操作権限可否';
COMMENT ON COLUMN "sys_facility_setting"."description" IS E'設定説明';
COMMENT ON COLUMN "sys_facility_setting"."disp_order" IS E'表示順';
COMMENT ON COLUMN "sys_facility_setting"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sys_facility_setting"."up_date" IS E'更新日時';
