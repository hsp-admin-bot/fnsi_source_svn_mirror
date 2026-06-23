-- テーブル削除
DROP TABLE IF EXISTS mst_coop_layout;
-- テーブル作成
CREATE TABLE mst_coop_layout
(
    ctl_no bigserial NOT NULL,  --管理番号
    facility_cd character varying(6) NOT NULL,  --施設コード
    coop_cd character varying(20) NOT NULL,  --電文種別
    direction character varying(1) NOT NULL,  --向き（送受信）
    coop_cd_sub character varying NOT NULL,  --電文種別補足コード
    coop_format character varying,  --電文フォーマット
    coop_name character varying,  --レイアウト名称
    coop_vender character varying,  --対応ベンダー名
    description character varying,  --説明
    is_editable character varying(1),  --編集可否フラグ
    coop_setting XML,  --連携設定
    coop_ext_setting jsonb,  --拡張設定
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    user_id bigint,  --操作者ID
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時

    CONSTRAINT unq_mst_coop_layout_01 PRIMARY KEY (ctl_no)

)
WITH (
    OIDS=FALSE
)
;
-- コメント追加
COMMENT ON TABLE "mst_coop_layout" IS E'連携電文設定マスタ';
COMMENT ON COLUMN "mst_coop_layout"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "mst_coop_layout"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_coop_layout"."coop_cd" IS E'電文種別';
COMMENT ON COLUMN "mst_coop_layout"."direction" IS E'向き（送受信）';
COMMENT ON COLUMN "mst_coop_layout"."coop_cd_sub" IS E'電文種別補足コード';
COMMENT ON COLUMN "mst_coop_layout"."coop_format" IS E'電文フォーマット';
COMMENT ON COLUMN "mst_coop_layout"."coop_name" IS E'レイアウト名称';
COMMENT ON COLUMN "mst_coop_layout"."coop_vender" IS E'対応ベンダー名';
COMMENT ON COLUMN "mst_coop_layout"."description" IS E'説明';
COMMENT ON COLUMN "mst_coop_layout"."is_editable" IS E'編集可否フラグ';
COMMENT ON COLUMN "mst_coop_layout"."coop_setting" IS E'連携設定';
COMMENT ON COLUMN "mst_coop_layout"."coop_ext_setting" IS E'拡張設定';
COMMENT ON COLUMN "mst_coop_layout"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_coop_layout"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_coop_layout"."user_id" IS E'操作者ID';
COMMENT ON COLUMN "mst_coop_layout"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_coop_layout"."up_date" IS E'更新日時';

-- テーブル削除
DROP TABLE IF EXISTS mst_coop_facility;
-- テーブル作成
CREATE TABLE mst_coop_facility
(
    ctl_no bigserial NOT NULL,  --管理番号
    facility_cd character varying(6) NOT NULL,  --施設コード
    description character varying,  --説明
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    if_edge_setting jsonb,  --IFエッジ設定
    common_setting jsonb,  --各機能共通設定
    user_id bigint,  --操作者ID
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_coop_facility_01 PRIMARY KEY (ctl_no)

)
WITH (
    OIDS=FALSE
)
;
-- コメント追加
COMMENT ON TABLE "mst_coop_facility" IS E'連携設定マスタ';
COMMENT ON COLUMN "mst_coop_facility"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "mst_coop_facility"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_coop_facility"."description" IS E'説明';
COMMENT ON COLUMN "mst_coop_facility"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_coop_facility"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_coop_facility"."if_edge_setting" IS E'IFエッジ設定';
COMMENT ON COLUMN "mst_coop_facility"."common_setting" IS E'各機能共通設定';
COMMENT ON COLUMN "mst_coop_facility"."user_id" IS E'操作者ID';
COMMENT ON COLUMN "mst_coop_facility"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_coop_facility"."up_date" IS E'更新日時';

-- テーブル削除
DROP TABLE IF EXISTS mst_coop_distribute;
-- テーブル作成
CREATE TABLE mst_coop_distribute
(
    ctl_no bigserial NOT NULL,  --管理番号
    facility_cd character varying(6) NOT NULL,  --施設コード
    coop_cd character varying(20) NOT NULL,  --電文種別
    coop_cd_index character varying(10) NOT NULL DEFAULT '',  --付帯情報（電文）
    crud character varying(1) NOT NULL,  --作成更新区分
    direction character varying(1) NOT NULL,  --向き（送受信）
    coop_vender character varying,  --対応ベンダー名
    description character varying,  --説明
    is_editable character varying(1),  --編集可否フラグ
    distribute_setting jsonb,  --配信設定
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    user_id bigint,  --操作者ID
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_coop_distribute_01 PRIMARY KEY (ctl_no)

)
WITH (
    OIDS=FALSE
)
;
-- コメント追加
COMMENT ON TABLE "mst_coop_distribute" IS E'連携配信設定マスタ';
COMMENT ON COLUMN "mst_coop_distribute"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "mst_coop_distribute"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_coop_distribute"."coop_cd" IS E'電文種別';
COMMENT ON COLUMN "mst_coop_distribute"."coop_cd_index" IS E'付帯情報（電文）';
COMMENT ON COLUMN "mst_coop_distribute"."crud" IS E'作成更新区分';
COMMENT ON COLUMN "mst_coop_distribute"."direction" IS E'向き（送受信）';
COMMENT ON COLUMN "mst_coop_distribute"."coop_vender" IS E'対応ベンダー名';
COMMENT ON COLUMN "mst_coop_distribute"."description" IS E'説明';
COMMENT ON COLUMN "mst_coop_distribute"."is_editable" IS E'編集可否フラグ';
COMMENT ON COLUMN "mst_coop_distribute"."distribute_setting" IS E'配信設定';
COMMENT ON COLUMN "mst_coop_distribute"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_coop_distribute"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_coop_distribute"."user_id" IS E'操作者ID';
COMMENT ON COLUMN "mst_coop_distribute"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_coop_distribute"."up_date" IS E'更新日時';

-- テーブル削除
DROP TABLE IF EXISTS mnt_if_edge_healthmon;
-- テーブル作成
CREATE TABLE mnt_if_edge_healthmon
(
    ctl_no bigserial,  --管理番号
    facility_cd character varying(6) NOT NULL,  --施設コード
    if_edge_no numeric(2) NOT NULL,  --IFエッジ番号
    healthmon_facility_conn jsonb,  --エッジステータス
    healthmon_server_conn jsonb,  --サーバステータス
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mnt_if_edge_healthmon_01 PRIMARY KEY (ctl_no)

)
WITH (
    OIDS=FALSE
)
;

-- コメント追加
COMMENT ON TABLE "mnt_if_edge_healthmon" IS E'連携エッジヘルスモニタ';
COMMENT ON COLUMN "mnt_if_edge_healthmon"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "mnt_if_edge_healthmon"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mnt_if_edge_healthmon"."if_edge_no" IS E'IFエッジ番号';
COMMENT ON COLUMN "mnt_if_edge_healthmon"."healthmon_facility_conn" IS E'エッジステータス';
COMMENT ON COLUMN "mnt_if_edge_healthmon"."healthmon_server_conn" IS E'サーバステータス';
COMMENT ON COLUMN "mnt_if_edge_healthmon"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mnt_if_edge_healthmon"."up_date" IS E'更新日時';

-- テーブル削除
DROP TABLE IF EXISTS mst_if_edge;
-- テーブル作成
CREATE TABLE mst_if_edge
(
    serial_no character varying(20) NOT NULL,  --製造番号
    facility_cd character varying(6),  --施設コード
    if_edge_no numeric(2),  --IFエッジ番号
    if_edge_name character varying,  --IFエッジ名
    is_disp character varying(1),  --表示フラグ
    is_del character varying(1),  --削除フラグ
    setting_date timestamp(3),  --設置日
    delete_date timestamp(3),  --破棄日
    memo character varying(255),  --メモ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_if_edge_01 PRIMARY KEY (serial_no)

)
WITH (
    OIDS=FALSE
)
;
-- コメント追加
COMMENT ON TABLE "mst_if_edge" IS E'連携エッジマスタ';
COMMENT ON COLUMN "mst_if_edge"."serial_no" IS E'製造番号';
COMMENT ON COLUMN "mst_if_edge"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_if_edge"."if_edge_no" IS E'IFエッジ番号';
COMMENT ON COLUMN "mst_if_edge"."if_edge_name" IS E'IFエッジ名';
COMMENT ON COLUMN "mst_if_edge"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_if_edge"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_if_edge"."setting_date" IS E'設置日';
COMMENT ON COLUMN "mst_if_edge"."delete_date" IS E'破棄日';
COMMENT ON COLUMN "mst_if_edge"."memo" IS E'メモ';
COMMENT ON COLUMN "mst_if_edge"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_if_edge"."up_date" IS E'更新日時';

-- テーブル削除
DROP TABLE IF EXISTS mst_coop_layout_detail;
-- テーブル作成
CREATE TABLE mst_coop_layout_detail
(
    ctl_no bigserial NOT NULL,  --管理番号
    facility_cd character varying(6) NOT NULL,  --施設コード
    coop_cd character varying(20) NOT NULL,  --電文種別
    direction character varying(1) NOT NULL,  --向き（送受信）
    coop_cd_detail character varying(20) NOT NULL,  --電文種別詳細コード
    coop_cd_detail_sub character varying(20) NOT NULL,  --電文種別詳細補足コード
    coop_name character varying,  --レイアウト名称
    description character varying,  --説明
    is_editable character varying(1),  --編集可否フラグ
    coop_setting XML,  --連携設定
    coop_ext_setting jsonb,  --拡張設定
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    user_id bigint,  --操作者ID
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_coop_layout_detail_01 PRIMARY KEY (ctl_no)

)
WITH (
    OIDS=FALSE
)
;
-- コメント追加
COMMENT ON TABLE "mst_coop_layout_detail" IS E'連携電文設定マスタ詳細';
COMMENT ON COLUMN "mst_coop_layout_detail"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "mst_coop_layout_detail"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_coop_layout_detail"."coop_cd" IS E'電文種別';
COMMENT ON COLUMN "mst_coop_layout_detail"."direction" IS E'向き（送受信）';
COMMENT ON COLUMN "mst_coop_layout_detail"."coop_cd_detail" IS E'電文種別詳細コード';
COMMENT ON COLUMN "mst_coop_layout_detail"."coop_cd_detail_sub" IS E'電文種別詳細補足コード';
COMMENT ON COLUMN "mst_coop_layout_detail"."coop_name" IS E'レイアウト名称';
COMMENT ON COLUMN "mst_coop_layout_detail"."description" IS E'説明';
COMMENT ON COLUMN "mst_coop_layout_detail"."is_editable" IS E'編集可否フラグ';
COMMENT ON COLUMN "mst_coop_layout_detail"."coop_setting" IS E'連携設定';
COMMENT ON COLUMN "mst_coop_layout_detail"."coop_ext_setting" IS E'拡張設定';
COMMENT ON COLUMN "mst_coop_layout_detail"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_coop_layout_detail"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_coop_layout_detail"."user_id" IS E'操作者ID';
COMMENT ON COLUMN "mst_coop_layout_detail"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_coop_layout_detail"."up_date" IS E'更新日時';

