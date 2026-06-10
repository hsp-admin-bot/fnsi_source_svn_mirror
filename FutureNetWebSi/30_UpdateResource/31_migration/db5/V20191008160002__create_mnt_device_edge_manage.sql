-- テーブル削除
DROP TABLE IF EXISTS mnt_device_edge_manage;
-- テーブル作成
CREATE TABLE mnt_device_edge_manage
(
    manage_no bigserial NOT NULL,  --DE管理番号
    facility_cd character varying(6) NOT NULL,  --施設コード
    device_edge_no numeric(2,0) NOT NULL,  --デバイスエッジ番号
    user_id bigint NOT NULL,  --指示者
    order_class smallint NOT NULL,  --指示種別
    order_target_class smallint NOT NULL,  --指示対象
    response_status smallint NOT NULL,  --応答ステータス
    manage_info jsonb,  --情報
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_mnt_device_edge_manage_01 PRIMARY KEY (manage_no)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mnt_device_edge_manage" IS E'デバイスエッジ制御指示管理';
COMMENT ON COLUMN "mnt_device_edge_manage"."manage_no" IS E'DE管理番号';
COMMENT ON COLUMN "mnt_device_edge_manage"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mnt_device_edge_manage"."device_edge_no" IS E'デバイスエッジ番号';
COMMENT ON COLUMN "mnt_device_edge_manage"."user_id" IS E'指示者';
COMMENT ON COLUMN "mnt_device_edge_manage"."order_class" IS E'指示種別';
COMMENT ON COLUMN "mnt_device_edge_manage"."order_target_class" IS E'指示対象';
COMMENT ON COLUMN "mnt_device_edge_manage"."response_status" IS E'応答ステータス';
COMMENT ON COLUMN "mnt_device_edge_manage"."manage_info" IS E'情報';
COMMENT ON COLUMN "mnt_device_edge_manage"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mnt_device_edge_manage"."up_date" IS E'更新日時';



