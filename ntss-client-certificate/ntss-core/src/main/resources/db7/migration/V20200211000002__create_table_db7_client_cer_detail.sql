
DROP TABLE IF EXISTS client_cer_detail;

CREATE TABLE client_cer_detail
(
    cl_certificate_id SERIAL,
    password_cl character varying(256) NOT NULL,
    max_download integer NOT NULL,
    cur_download integer NOT NULL,
    facility_cd character varying(40) NOT NULL,
    expired_date timestamp without time zone NOT NULL,
    latest_issued_user character varying(40),
    reg_date timestamp without time zone NOT NULL,
    up_date timestamp without time zone NOT NULL,
    CONSTRAINT cl_details_pkey PRIMARY KEY (cl_certificate_id)
)WITH (
    OIDS=FALSE
);

COMMENT ON TABLE "client_cer_detail" IS E'クライアント証明書の詳細';
COMMENT ON COLUMN "client_cer_detail"."password_cl" IS E'証明書のパスワード';
COMMENT ON COLUMN "client_cer_detail"."max_download" IS E'最大ダウンロード数';
COMMENT ON COLUMN "client_cer_detail"."cur_download" IS E'現在のダウンロード番号';
COMMENT ON COLUMN "client_cer_detail"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "client_cer_detail"."expired_date" IS E'公開期限';
COMMENT ON COLUMN "client_cer_detail"."cl_certificate_id" IS E'クライアント証明書ID';
COMMENT ON COLUMN "client_cer_detail"."latest_issued_user" IS E'最後の発行ユーザー';
COMMENT ON COLUMN "client_cer_detail"."reg_date" IS E'登録日';
COMMENT ON COLUMN "client_cer_detail"."up_date" IS E'更新日';