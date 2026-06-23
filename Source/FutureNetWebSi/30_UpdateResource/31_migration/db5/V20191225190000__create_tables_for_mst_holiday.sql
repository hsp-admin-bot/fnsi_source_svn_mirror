-- テーブル削除
DROP TABLE IF EXISTS mst_holiday;

-- テーブル作成
CREATE TABLE mst_holiday
(
    holiday_cd bigserial,
    facility_cd character varying(6) NOT NULL,
    class character varying(1),
    holiday_y integer,
    holiday_json jsonb,
    is_disp character varying(1),
    is_del character varying(1),
    reg_date timestamp(3),
    up_date timestamp(3),
    CONSTRAINT mst_holiday_pkey PRIMARY KEY (holiday_cd)
);

CREATE UNIQUE INDEX mst_holiday_pkey_02
ON mst_holiday(holiday_y, facility_cd)
WHERE is_disp = '1';

COMMENT ON TABLE "mst_holiday" IS E'休日マスタ';
COMMENT ON COLUMN "mst_holiday"."holiday_cd" IS E'休日コード';
COMMENT ON COLUMN "mst_holiday"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_holiday"."class" IS E'種別コード';
COMMENT ON COLUMN "mst_holiday"."holiday_y" IS E'対象年';
COMMENT ON COLUMN "mst_holiday"."holiday_json" IS E'休日詳細';
COMMENT ON COLUMN "mst_holiday"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_holiday"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_holiday"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_holiday"."up_date" IS E'更新日時';