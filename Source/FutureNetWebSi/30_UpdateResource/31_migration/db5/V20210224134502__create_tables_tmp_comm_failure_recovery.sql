-- テーブル削除
DROP TABLE IF EXISTS tmp_comm_failure_recovery;
-- テーブル作成
CREATE TABLE tmp_comm_failure_recovery
(
    facility_cd character varying(6) NOT NULL,  --施設コード
    machine_type_cd character varying(3) NOT NULL,  --型式コード
    machine_serial character varying(8) NOT NULL,  --製造番号
    ord_no bigint,  --システムで管理する一意なオーダ番号
    next_ord_no bigint,  --次回透析オーダ番号
    pat_id bigint,  --システムで管理する一意な患者ID
    next_patid bigint,  --次患者ID
    start_date timestamp(3),  --透析開始日時
    end_date timestamp(3),  --透析終了日時
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3)  --更新日時
)
WITH (
    OIDS=FALSE
);
-- ユーザ設定
ALTER TABLE tmp_comm_failure_recovery OWNER TO nkk5;
-- コメント追加
COMMENT ON TABLE "tmp_comm_failure_recovery" IS E'通信障害回復用ワーク表';
COMMENT ON COLUMN "tmp_comm_failure_recovery"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "tmp_comm_failure_recovery"."machine_type_cd" IS E'型式コード';
COMMENT ON COLUMN "tmp_comm_failure_recovery"."machine_serial" IS E'製造番号';
COMMENT ON COLUMN "tmp_comm_failure_recovery"."ord_no" IS E'システムで管理する一意なオーダ番号';
COMMENT ON COLUMN "tmp_comm_failure_recovery"."next_ord_no" IS E'次回透析オーダ番号';
COMMENT ON COLUMN "tmp_comm_failure_recovery"."pat_id" IS E'システムで管理する一意な患者ID';
COMMENT ON COLUMN "tmp_comm_failure_recovery"."next_patid" IS E'次患者ID';
COMMENT ON COLUMN "tmp_comm_failure_recovery"."start_date" IS E'透析開始日時';
COMMENT ON COLUMN "tmp_comm_failure_recovery"."end_date" IS E'透析終了日時';
COMMENT ON COLUMN "tmp_comm_failure_recovery"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "tmp_comm_failure_recovery"."up_date" IS E'更新日時';
