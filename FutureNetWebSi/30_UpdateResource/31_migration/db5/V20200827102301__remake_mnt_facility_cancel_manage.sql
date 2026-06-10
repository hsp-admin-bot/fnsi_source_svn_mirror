-- テーブル削除
DROP TABLE IF EXISTS mnt_facility_cancel_manage;

-- テーブル作成
CREATE TABLE mnt_facility_cancel_manage
(
    ctl_no bigserial NOT NULL, -- 管理番号
    facility_cd CHARACTER VARYING(6) NOT NULL, -- 施設コード
    proc_class CHARACTER VARYING(1), -- 処理区分（1: 施設解約, 2: 期間外削除）
    proc_period INTEGER, -- 処理対象期間
    st_date TIMESTAMP(3), -- 処理開始日
    stats JSONB, -- 統計情報
    proc_status CHARACTER VARYING(1) DEFAULT '0', -- ステータス
    is_disp CHARACTER VARYING(1) DEFAULT '1', -- 表示フラグ
    is_del CHARACTER VARYING(1) DEFAULT '0', -- 削除フラグ
    reg_date TIMESTAMP(3), -- 登録日時
    up_date TIMESTAMP(3), -- 更新日時
    CONSTRAINT unq_mnt_facility_cancel_manage_01 PRIMARY KEY (ctl_no)
)
WITH (
    OIDS=FALSE
);

-- コメント追加
COMMENT ON TABLE "mnt_facility_cancel_manage" IS E'施設解約管理';

COMMENT ON COLUMN "mnt_facility_cancel_manage"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "mnt_facility_cancel_manage"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mnt_facility_cancel_manage"."proc_class" IS E'処理区分';
COMMENT ON COLUMN "mnt_facility_cancel_manage"."proc_period" IS E'処理対象期間';
COMMENT ON COLUMN "mnt_facility_cancel_manage"."st_date" IS E'処理開始日';
COMMENT ON COLUMN "mnt_facility_cancel_manage"."stats" IS E'統計情報';
COMMENT ON COLUMN "mnt_facility_cancel_manage"."proc_status" IS E'ステータス';
COMMENT ON COLUMN "mnt_facility_cancel_manage"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mnt_facility_cancel_manage"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mnt_facility_cancel_manage"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mnt_facility_cancel_manage"."up_date" IS E'更新日時';
