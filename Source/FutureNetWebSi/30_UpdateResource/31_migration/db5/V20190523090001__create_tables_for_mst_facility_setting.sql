-- テーブル削除（施設設定マスタ）
DROP TABLE IF EXISTS mst_facility_setting;
-- テーブル作成（施設設定マスタ）
CREATE TABLE mst_facility_setting
(
    facility_cd character varying(6) NOT NULL,  --施設コード
    ctl_no numeric(4,0) NOT NULL,  --管理番号
    function_cd character varying(3),  --機能コード
    name character varying(256),  --名称
    value character varying,  --値
    description character varying(4000),  --説明
    is_editable character varying(1),  --編集可否フラグ
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_facility_setting_01 PRIMARY KEY (facility_cd,ctl_no)
)
WITH (
    OIDS=FALSE
);
-- コメント追加（施設設定マスタ）
COMMENT ON TABLE "mst_facility_setting" IS E'施設設定マスタ';
COMMENT ON COLUMN "mst_facility_setting"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_facility_setting"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "mst_facility_setting"."function_cd" IS E'機能コード';
COMMENT ON COLUMN "mst_facility_setting"."name" IS E'名称';
COMMENT ON COLUMN "mst_facility_setting"."value" IS E'値';
COMMENT ON COLUMN "mst_facility_setting"."description" IS E'説明';
COMMENT ON COLUMN "mst_facility_setting"."is_editable" IS E'編集可否フラグ';
COMMENT ON COLUMN "mst_facility_setting"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_facility_setting"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_facility_setting"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_facility_setting"."up_date" IS E'更新日時';
