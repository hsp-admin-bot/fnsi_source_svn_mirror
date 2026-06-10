DROP TABLE IF EXISTS client_cer_facility;

CREATE TABLE client_cer_facility
(
    facility_cd character varying(40) NOT NULL,
    facility_password character varying(256) NOT NULL,
    attempt_fail integer NOT NULL,
    reg_date timestamp without time zone NOT NULL,
    up_date timestamp without time zone NOT NULL,
    CONSTRAINT cl_facilities_pkey PRIMARY KEY (facility_cd)
)WITH (
    OIDS=FALSE
);
COMMENT ON TABLE "client_cer_facility" IS E'施設詳細';
COMMENT ON COLUMN "client_cer_facility"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "client_cer_facility"."facility_password" IS E'施設のパスワード';
COMMENT ON COLUMN "client_cer_facility"."attempt_fail" IS E'ログイン失敗回数';
COMMENT ON COLUMN "client_cer_facility"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "client_cer_facility"."up_date" IS E'更新日時';