-- テーブル削除
DROP TABLE IF EXISTS ord_monitor;
-- テーブル作成
CREATE TABLE ord_monitor
(
    ord_monitor_ctl_no bigserial NOT NULL,  --実績モニタデータ管理番号
    bio_moni_ctl_no bigint,  --生体モニタリング管理番号
    ord_no bigint,  --システムで管理する一意なオーダ番号
    monitor_data jsonb,  --モニタデータ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    occur_date timestamp(3),  --発生日時
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_ord_monitor_01 PRIMARY KEY (ord_monitor_ctl_no)
)
WITH (
    OIDS=FALSE
);

-- コメント追加
COMMENT ON TABLE "ord_monitor" IS E'実績モニタデータ';
COMMENT ON COLUMN "ord_monitor"."ord_monitor_ctl_no" IS E'実績モニタデータ管理番号';
COMMENT ON COLUMN "ord_monitor"."bio_moni_ctl_no" IS E'生体モニタリング管理番号';
COMMENT ON COLUMN "ord_monitor"."ord_no" IS E'システムで管理する一意なオーダ番号';
COMMENT ON COLUMN "ord_monitor"."monitor_data" IS E'モニタデータ';
COMMENT ON COLUMN "ord_monitor"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "ord_monitor"."occur_date" IS E'発生日時';
COMMENT ON COLUMN "ord_monitor"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "ord_monitor"."up_date" IS E'更新日時';
