-- テーブル削除
DROP TABLE IF EXISTS mst_if_edge_command;
-- テーブル作成
CREATE TABLE mst_if_edge_command
(
    ctl_no bigserial NOT NULL,  --管理番号
    command_key character varying(30) NOT NULL,  --コマンドキー
    command character varying,  --コマンド内容
    is_del character varying(1),  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_if_edge_command_01 PRIMARY KEY (ctl_no)
)
;
-- コメント追加
COMMENT ON TABLE "mst_if_edge_command" IS E'連携エッジコマンドマスタ';
COMMENT ON COLUMN "mst_if_edge_command"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "mst_if_edge_command"."command" IS E'コマンド内容';
COMMENT ON COLUMN "mst_if_edge_command"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_if_edge_command"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_if_edge_command"."up_date" IS E'更新日時';
