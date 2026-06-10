-- テーブル削除
DROP TABLE IF EXISTS sys_monitor_item;
-- テーブル作成
CREATE TABLE sys_monitor_item
(
    moni_data_no character varying(5) NOT NULL,  --モニタデータ番号
    moni_data_type character varying(1),  --モニタデータ種別
    moni_data_name character varying,  --モニタデータ項目名
    moni_data_short_name character varying,  --モニタデータ短縮名
    data_type numeric(1,0) DEFAULT 0,  --データ種別
    decimal_figure numeric(2,0),  --小数部桁数
    unit character varying,  --単位
    upper numeric(10,2),  --最大値
    lower numeric(10,2),  --最小値
    is_disp character varying(1),  --表示有無
    vital_monitor_class character varying(1),  --バイタル・モニタ区分
    conv_item jsonb,  --変換項目
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_sys_monitor_item_01 PRIMARY KEY (moni_data_no)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "sys_monitor_item" IS E'モニタ項目';
COMMENT ON COLUMN "sys_monitor_item"."moni_data_no" IS E'モニタデータ番号';
COMMENT ON COLUMN "sys_monitor_item"."moni_data_type" IS E'モニタデータ種別';
COMMENT ON COLUMN "sys_monitor_item"."moni_data_name" IS E'モニタデータ項目名';
COMMENT ON COLUMN "sys_monitor_item"."moni_data_short_name" IS E'モニタデータ短縮名';
COMMENT ON COLUMN "sys_monitor_item"."data_type" IS E'データ種別';
COMMENT ON COLUMN "sys_monitor_item"."decimal_figure" IS E'小数部桁数';
COMMENT ON COLUMN "sys_monitor_item"."unit" IS E'単位';
COMMENT ON COLUMN "sys_monitor_item"."upper" IS E'最大値';
COMMENT ON COLUMN "sys_monitor_item"."lower" IS E'最小値';
COMMENT ON COLUMN "sys_monitor_item"."is_disp" IS E'表示有無';
COMMENT ON COLUMN "sys_monitor_item"."vital_monitor_class" IS E'バイタル・モニタ区分';
COMMENT ON COLUMN "sys_monitor_item"."conv_item" IS E'変換項目';
COMMENT ON COLUMN "sys_monitor_item"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sys_monitor_item"."up_date" IS E'更新日時';
