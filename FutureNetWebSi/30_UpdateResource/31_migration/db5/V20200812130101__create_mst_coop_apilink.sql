-- テーブル削除
DROP TABLE IF EXISTS mst_coop_apilink;
-- テーブル作成
CREATE TABLE mst_coop_apilink
(
    ctl_no bigserial NOT NULL,  --管理番号
    facility_cd character varying(6),  --施設コード
    coop_cd character varying(20),  --電文種別
    coop_cd_index character varying(10),  --付帯情報（電文）
    crud character varying(1),  --作成更新区分
    direction character varying(1),  --向き（送受信）
    api_timing_io character varying(1),  --発行タイミング（更新）
    api_timing_ba character varying(1),  --発行タイミング（前後）
    api_timing_seq bigint,  --発行タイミング（シーケンス）
    api_uri character varying,  --api-URI
    api_method character varying(10),  --httpメソッド
    api_body jsonb,  --リクエストbody
    continue_api_status jsonb,  --処理継続レスポンスステータス
    after_api_status jsonb,  --処理後ステータス
    is_del character varying(1) NOT NULL DEFAULT '0',  --削除フラグ
    user_id bigint,  --操作者ID
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_coop_apilink_01 PRIMARY KEY (ctl_no)
)
WITH (
    OIDS=FALSE
);

-- コメント追加
COMMENT ON TABLE "mst_coop_apilink" IS E'連携API関連付けマスタ';
COMMENT ON COLUMN "mst_coop_apilink"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "mst_coop_apilink"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_coop_apilink"."coop_cd" IS E'電文種別';
COMMENT ON COLUMN "mst_coop_apilink"."coop_cd_index" IS E'付帯情報（電文）';
COMMENT ON COLUMN "mst_coop_apilink"."crud" IS E'作成更新区分';
COMMENT ON COLUMN "mst_coop_apilink"."direction" IS E'向き（送受信）';
COMMENT ON COLUMN "mst_coop_apilink"."api_timing_io" IS E'発行タイミング（更新）';
COMMENT ON COLUMN "mst_coop_apilink"."api_timing_ba" IS E'発行タイミング（前後）';
COMMENT ON COLUMN "mst_coop_apilink"."api_timing_seq" IS E'発行タイミング（シーケンス）';
COMMENT ON COLUMN "mst_coop_apilink"."api_uri" IS E'api-URI';
COMMENT ON COLUMN "mst_coop_apilink"."api_method" IS E'httpメソッド';
COMMENT ON COLUMN "mst_coop_apilink"."api_body" IS E'リクエストbody';
COMMENT ON COLUMN "mst_coop_apilink"."continue_api_status" IS E'処理継続レスポンスステータス';
COMMENT ON COLUMN "mst_coop_apilink"."after_api_status" IS E'処理後ステータス';
COMMENT ON COLUMN "mst_coop_apilink"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_coop_apilink"."user_id" IS E'操作者ID';
COMMENT ON COLUMN "mst_coop_apilink"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_coop_apilink"."up_date" IS E'更新日時';
