-- テーブル削除
DROP TABLE IF EXISTS mnt_batch_manager;
-- テーブル作成
CREATE TABLE mnt_batch_manager
(
    ctl_no numeric(4,0) NOT NULL,  --管理番号
    batch_name character varying,  --バッチ処理名称
    division character varying,  --処理区分
    status character varying(1) DEFAULT '0',  --処理ステータス
    description character varying,  --説明
    start_time timestamp(3),  --開始時刻
    end_time timestamp(3),  --終了時刻
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mnt_batch_manager_01 PRIMARY KEY (ctl_no)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mnt_batch_manager" IS E'バッチ稼働状況管理';
COMMENT ON COLUMN "mnt_batch_manager"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "mnt_batch_manager"."batch_name" IS E'バッチ処理名称';
COMMENT ON COLUMN "mnt_batch_manager"."division" IS E'処理区分';
COMMENT ON COLUMN "mnt_batch_manager"."status" IS E'処理ステータス';
COMMENT ON COLUMN "mnt_batch_manager"."description" IS E'説明';
COMMENT ON COLUMN "mnt_batch_manager"."start_time" IS E'開始時刻';
COMMENT ON COLUMN "mnt_batch_manager"."end_time" IS E'終了時刻';
COMMENT ON COLUMN "mnt_batch_manager"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mnt_batch_manager"."up_date" IS E'更新日時';
