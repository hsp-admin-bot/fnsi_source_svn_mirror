-- テーブル削除
DROP TABLE IF EXISTS mnt_if_edge_manage;
-- テーブル作成
CREATE TABLE mnt_if_edge_manage
(
    ctl_no bigserial NOT NULL,  --管理番号
    facility_cd character varying(6) NOT NULL,  --施設コード
    response_status smallint NOT NULL,  --応答ステータス
    edge_result jsonb,  --連携エッジ実行結果
    is_del character varying(1),  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mnt_if_edge_manage_01 PRIMARY KEY (ctl_no)

);
-- コメント追加
COMMENT ON TABLE "mnt_if_edge_manage" IS E'連携オーダ番号';
COMMENT ON COLUMN "mnt_if_edge_manage"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "mnt_if_edge_manage"."response_status" IS E'応答ステータス';
COMMENT ON COLUMN "mnt_if_edge_manage"."edge_result" IS E'連携エッジ実行結果';
COMMENT ON COLUMN "mnt_if_edge_manage"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mnt_if_edge_manage"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mnt_if_edge_manage"."up_date" IS E'更新日時';
