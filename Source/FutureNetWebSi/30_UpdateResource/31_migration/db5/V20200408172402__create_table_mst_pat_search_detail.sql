DROP TABLE IF EXISTS mst_pat_search_detail;

CREATE TABLE IF NOT EXISTS mst_pat_search_detail
(
    search_cd bigserial NOT NULL,  --詳細患者検索コード
    search_name character varying,  --詳細患者検索名
    user_id bigint NOT NULL,  --利用者ID
    facility_cd character varying(6) NOT NULL, -- 施設コード
    search_condition json,  --検索条件内容
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_pat_search_detail_01 PRIMARY KEY (search_cd)
);

COMMENT ON TABLE "mst_pat_search_detail" IS E'詳細患者検索マスタ';
COMMENT ON COLUMN "mst_pat_search_detail"."search_cd" IS E'詳細患者検索コード';
COMMENT ON COLUMN "mst_pat_search_detail"."search_name" IS E'詳細患者検索名';
COMMENT ON COLUMN "mst_pat_search_detail"."user_id" IS E'利用者ID';
COMMENT ON COLUMN "mst_pat_search_detail"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_pat_search_detail"."search_condition" IS E'検索条件内容';
COMMENT ON COLUMN "mst_pat_search_detail"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_pat_search_detail"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_pat_search_detail"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_pat_search_detail"."up_date" IS E'更新日時';
