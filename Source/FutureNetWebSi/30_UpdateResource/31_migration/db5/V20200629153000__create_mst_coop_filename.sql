-- テーブル削除
DROP TABLE IF EXISTS mst_coop_filename;
-- テーブル作成
CREATE TABLE mst_coop_filename
(
    ctl_no bigserial NOT NULL,  --管理番号
    facility_cd character varying(6) NOT NULL,  --施設コード
    coop_cd character varying(20) NOT NULL,  --電文種別
    coop_cd_index character varying(10) NOT NULL DEFAULT '',  --付帯情報（電文）
    pdf_name jsonb,  --PDFファイル名
    dump_name jsonb,  --電文パス名
    compression_name jsonb,  --圧縮ファイル名
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    user_id bigint,  --操作者ID
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_coop_filename_01 PRIMARY KEY (ctl_no)
);
-- コメント追加
COMMENT ON TABLE "mst_coop_filename" IS E'外部連携用ファイル名管理';
COMMENT ON COLUMN "mst_coop_filename"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "mst_coop_filename"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_coop_filename"."coop_cd" IS E'電文種別';
COMMENT ON COLUMN "mst_coop_filename"."coop_cd_index" IS E'付帯情報（電文）';
COMMENT ON COLUMN "mst_coop_filename"."pdf_name" IS E'PDFファイル名';
COMMENT ON COLUMN "mst_coop_filename"."dump_name" IS E'電文パス名';
COMMENT ON COLUMN "mst_coop_filename"."compression_name" IS E'圧縮ファイル名';
COMMENT ON COLUMN "mst_coop_filename"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_coop_filename"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_coop_filename"."user_id" IS E'操作者ID';
COMMENT ON COLUMN "mst_coop_filename"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_coop_filename"."up_date" IS E'更新日時';
