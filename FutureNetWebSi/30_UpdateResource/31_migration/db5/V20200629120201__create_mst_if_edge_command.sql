-- テーブル削除
DROP TABLE IF EXISTS mst_if_edge_command;
-- テーブル作成
CREATE TABLE mst_if_edge_command
(
    ctl_no bigserial NOT NULL,  --管理番号
    command_key character varying(30) NOT NULL,  --コマンドキー
    command character varying,  --コマンド内容
    add_setting character varying(1),  --設定ファイル追加
    is_del character varying(1),  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_if_edge_command_01 PRIMARY KEY (ctl_no)

)
;
-- ユーザ設定

-- コメント追加
COMMENT ON TABLE "mst_if_edge_command" IS E'連携オーダ番号';
COMMENT ON COLUMN "mst_if_edge_command"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "mst_if_edge_command"."command" IS E'コマンド内容';
COMMENT ON COLUMN "mst_if_edge_command"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_if_edge_command"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_if_edge_command"."up_date" IS E'更新日時';


insert into mst_if_edge_command values ( nextval('mst_if_edge_command_ctl_no_seq'),'start','systemctl restart nodered','0','0',now(),now());
insert into mst_if_edge_command values ( nextval('mst_if_edge_command_ctl_no_seq'),'stop','systemctl stop nodered','0','0',now(),now());
insert into mst_if_edge_command values ( nextval('mst_if_edge_command_ctl_no_seq'),'sendCnvStart','rm /home/ntss/if_edge/conf/send.skip','0','0',now(),now());
insert into mst_if_edge_command values ( nextval('mst_if_edge_command_ctl_no_seq'),'sendCnvStop','touch /home/ntss/if_edge/conf/send.skip','0','0',now(),now());
insert into mst_if_edge_command values ( nextval('mst_if_edge_command_ctl_no_seq'),'recvCnvStart','rm /home/ntss/if_edge/conf/receive.skip','0','0',now(),now());
insert into mst_if_edge_command values ( nextval('mst_if_edge_command_ctl_no_seq'),'recvCnvStop','touch /home/ntss/if_edge/conf/receive.skip','0','0',now(),now());
insert into mst_if_edge_command values ( nextval('mst_if_edge_command_ctl_no_seq'),'deliveryStart','rm /home/ntss/if_edge/conf/distribute.skip','0','0',now(),now());
insert into mst_if_edge_command values ( nextval('mst_if_edge_command_ctl_no_seq'),'deliveryStop','touch /home/ntss/if_edge/conf/distribute.skip
','0','0',now(),now());
insert into mst_if_edge_command values ( nextval('mst_if_edge_command_ctl_no_seq'),'sendEdgeSetting','datapath=DATA_PATH

cp /home/ntss/if_edge/maint/$datapath/files/setting.config  /home/ntss/if_edge/conf/ifedge_setting.json
','1','0',now(),now());
